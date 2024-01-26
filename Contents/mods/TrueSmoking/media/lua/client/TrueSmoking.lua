require 'TimedActions/ISBaseTimedAction'
require 'ISUI/ISInventoryPaneContextMenu'

require 'MF_ISMoodle'
require 'TrueSmokingOptions'
require 'GreenFireOverrides'
require 'TrueSmokingOverrides'

TrueSmoking = TrueSmoking or {}

--Find a smoke from inventory and start smoking
function TrueSmoking:startSmoking()
    print('start smoking')
    if not self.isSmoking then
        self.isSmoking = true
        self.smokeLit = true
        getPlayer():getModData().isSmoking = true
        self.puffTimeMark = os.time();
        print('smoke event start')
        Events.EveryOneMinute.Add(TrueSmoking.smoking)
    end
end

--Check if we are still smoking, calculate stat changes, take passive puffs
function TrueSmoking.smoking()
    local isSmoking = TrueSmoking.isSmoking
    local smokeLength = TrueSmoking.smokeItem.smokeLength
    local burnRate = TrueSmoking.smokeItem.burnRate
    local smokeLit = TrueSmoking.smokeLit
    local item = TrueSmoking.smokeItem

    TrueSmoking.hasSmokerTrait = getPlayer():HasTrait('Smoker')

     if getActivatedMods():contains("jiggasGreenfireMod") then
         if TrueSmoking.player:getModData().GreenFireSmokeHalf and smokeLength < 0.6 and smokeLength > 0.4 then
             TrueSmoking:stopSmoking()
             TrueSmoking.player:getModData().GreenFireSmokeHalf = false
             --GreenFireCoughSmoke()
         end
     end

    if isSmoking then
        if smokeLit then
            if getActivatedMods():contains("MoreSmokes") then
                SandboxVars.MoreSmokes.StonedDecreaseMulti = 0
            end
        end
        if smokeLength > burnRate then
            TrueSmoking:smoke()
        end
        if TrueSmoking.smokeItem.smokeLength <= TrueSmoking.smokeItem.burnRate then
            TrueSmoking:stopSmoking()
        end
    end
    if not isSmoking then
        TrueSmoking:stopSmoking()
    end
end

function TrueSmoking:smoke()
    --Try to take a passivePuff
    self:takePuff()

    local dt = os.difftime(os.time(), self.passiveTimeMark or os.time())

    if self.passiveTimeMark == nil then
        self.passiveTimeMark = os.time()
        return
    elseif dt >= 2 then
        if self.smokeLit then
            self:updateBurnRate(dt)
            --All smoking handled through OnEat_Cigarettes for stat changes
            print('Calling OnEat w/ %: '..truncateToDecimalPlaces(self.smokeItem.smokeLength,4))
            OnEat_OverTime(self.item,  getPlayer(), self.smokeItem.smokeLength)
            self.passiveTimeMark = os.time()
        end
    end
    self:updateMoodle()
end

function TrueSmoking:updateBurnRate()
    local burnRate = self.smokeItem.burnRate
    if self.takingPuff then
        local smoothFactor = 0.575
        print('burnRate: '..truncateToDecimalPlaces(burnRate,4))
        self.smokeItem.burnRate = cubicEaseOut(burnRate, self.upperBurnLimit*1.25, smoothFactor)
    else
        local smoothFactor = 0.685
        if getPlayer():isRunning() or getPlayer():isSprinting() then smoothFactor = 0.2 end
        print('burnRate: '..truncateToDecimalPlaces(burnRate,4))
        self.smokeItem.burnRate = cubicEaseOut(burnRate, self.lowerBurnLimit/2, smoothFactor)
        -- Check if the smoke is 'notLit'
        if self.smokeItem.burnRate < self.lowerBurnLimit then
            print('Smoke is out')
            self.smokeLit = false
        end
    end
    -- Calculate new smokeLength
    self.smokeItem.smokeLength = self.smokeItem.smokeLength - self.smokeItem.burnRate
end

function TrueSmoking:lightSmoke()
    if not self.smokeLit then
        --TODO Add variability here with traits and things
        local min, max = 0.0135, 0.0165
        local newBurnRate = min + (ZombRand(0,100)/100) * (max - min)
        self.smokeItem.burnRate = newBurnRate
        self.smokeLit = true
    end
end

--Idle smoking when character is idle and time has passed
function TrueSmoking:takePuff()
    if self.puffTimeMark == nil then
        self.puffTimeMark = os.time()
        return
    elseif self.isSmoking and
            not self.player:isStrafing() and not self.player:isRunning() and not self.player:isSprinting()
            and not self.player:isAiming() and not self.player:isAsleep() and not self.player:isPerformingAnAction()
    then
        local time = os.difftime(os.time(), self.puffTimeMark)
        --TODO add in trait based chance to keep smoke going
        if time > ZombRand(20,40) then
            ISTimedActionQueue.add(TakePuff:new(self.player, self.item, self, true))
        end
    end
end

--Stop smoking, kill the moodle, nil the data
function TrueSmoking:stopSmoking()
    print('stopSmoking')
    local moodle = MF.getMoodle('smoking')
    if moodle ~= nil then
        moodle:setValue(0.5)
        moodle:setPicture(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/notSmoking.png'))
    end

    self.isSmoking = false
    self.smokeLit = false
    getPlayer():getModData().isSmoking = false
    self.takingPuff = false
    self.item = nil
    self.statsDelta = nil

    if getActivatedMods():contains("MoreSmokes") then
        SandboxVars.MoreSmokes.StonedDecreaseMulti = self.StonedDecreaseMulti
    end

    Events.EveryOneMinute.Remove(TrueSmoking.smoking)
end

--Grab relevant data from item
function TrueSmoking:getSmokeInfo(item)
    print('getSmokeInfo')
    self.item = item

    self.smokeItem.onEat = item:getOnEat() or ''

    self.smokeItem.stress = item:getStressChange() or -5
    self.smokeItem.boredom = item:getBoredomChange() or 0
    self.smokeItem.unhappyness = item:getUnhappyChange() or 0
    self.smokeItem.fatigue = item:getFatigueChange() or 0
    self.smokeItem.thirst = item:getThirstChange() or 0

    self.smokeItem.smokeLength = item:getModData().SmokeLength or 1.0
    self.smokeItem.burnRate = item:getModData().BurnRate or 0.0175
end

--Check for blocking actions on the character
function TrueSmoking:canSmoke()
    return not self.isSmoking and not self.player:isStrafing() and not self.player:isRunning() and not self.player:isSprinting()
            and not self.player:isAiming() and not self.player:isAsleep() and not self.player:isPerformingAnAction()
end

function TrueSmoking.updateMoodle()
    if not TrueSmoking.isSmoking then return end
    local moodle = MF.getMoodle('smoking')
    if moodle == nil then return end
    --print('Update Moodle')
    local item = TrueSmoking.smokeItem
    local smokeLit = TrueSmoking.smokeLit or false
    local displayedPercentage = string.format('%.2f', item.smokeLength * 100)

    local isUp = false
    local chevs = 1

    local lower, upper = TrueSmoking.lowerBurnLimit, TrueSmoking.upperBurnLimit
    local diff = upper - lower
    local mid = lower+(diff/2)

    if item.burnRate > mid then
        isUp = true
        local d = upper - diff/5
        if item.burnRate > d then
            chevs = 2
        end
    else
        local d = lower + diff/10
        if item.burnRate < d then
            chevs = 2
        end
    end

    moodle:setThresholds(0.10, 0.20, 0.35, 0.4999, 0.5001, 0.65, 0.85, 0.90)

    if smokeLit then
        moodle:setPicture(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/smoking.png'))
    else
        chevs = 0
        moodle:setPicture(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/notSmoking.png'))
        moodle:doWiggle()
    end
    moodle:setValue(item.smokeLength)
    moodle:setDescription(moodle:getGoodBadNeutral(),moodle:getLevel(),getText('Moodles_smoking_Custom', displayedPercentage))
    moodle:setBackground(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/bg.png'))
    moodle:setChevronCount(chevs)
    moodle:setChevronIsUp(isUp)
end

function TrueSmoking.onKeyStartPressed(key)
    if TrueSmoking.player then
        if TrueSmoking.isSmoking and TrueSmoking.smokeLit and key == TrueSmoking.Options.keySmoke.key then
            ISTimedActionQueue.add(TakePuff:new(TrueSmoking.player, TrueSmoking.item, TrueSmoking))
        elseif TrueSmoking.isSmoking and not TrueSmoking.smokeLit and key == TrueSmoking.Options.keySmoke.key then
            ISTimedActionQueue.add(TakePuff:new(TrueSmoking.player, TrueSmoking.item, TrueSmoking, true))
        elseif not TrueSmoking.isSmoking and key == TrueSmoking.Options.keySmoke.key then
            --SmokingOverhaul:startSmoking()
        elseif key == TrueSmoking.Options.keyStopSmoke.key then
            TrueSmoking:stopSmoking()
        end
    end
end

--Toggles the 'Smoke' option and kicks off the smoking code
function TrueSmoking.toggleSmokeMenuOption(player, context, items)
    for i, v in ipairs(items) do
        local item = v
        local hasSmoke = nil

        if not instanceof(v, 'InventoryItem') then item = v.items[1] end

        hasSmoke = context:getOptionFromName(getText('ContextMenu_Smoke'))
        if hasSmoke then
            if TrueSmoking.isSmoking then
                hasSmoke.notAvailable = true
            else
                hasSmoke.notAvailable = false
            end
        end
    end
end

function TrueSmoking.start()
    TrueSmoking.smokeItem = TrueSmoking.smokeItem or {}
    TrueSmoking.statsDelta = TrueSmoking.statsDelta or nil
    TrueSmoking.statsBefore = TrueSmoking.statsBefore or nil
    TrueSmoking.statsAfter = TrueSmoking.statsAfter or nil

    TrueSmoking.upperBurnLimit = 0.0305
    TrueSmoking.lowerBurnLimit = 0.0095

    TrueSmoking.player = getPlayer()

    --MoreSmokes
    if getActivatedMods():contains("MoreSmokes") then
        TrueSmoking.StonedDecreaseMulti = SandboxVars.MoreSmokes.StonedDecreaseMulti or 2
    end

    if getActivatedMods():contains('MoodleFramework') then
        MF.createMoodle('smoking')
        print('create moodle')
    end

    Events.EveryOneMinute.Add(TrueSmoking.updateMoodle)

    --Keybinds
    Events.OnKeyStartPressed.Add(TrueSmoking.onKeyStartPressed)

    --Toggles the Smoke option in the context menu
    Events.OnFillInventoryObjectContextMenu.Add(TrueSmoking.toggleSmokeMenuOption)
end

function TrueSmoking.stop()
    TrueSmoking:stopSmoking()
    Events.EveryOneMinute.Remove(TrueSmoking.updateMoodle)
    Events.OnKeyStartPressed.Remove(TrueSmoking.onKeyStartPressed)
    Events.OnFillInventoryObjectContextMenu.Remove(TrueSmoking.toggleSmokeMenuOption)
end

--Events.OnGameBoot.Add(init)
Events.OnCreatePlayer.Add(TrueSmoking.start)
Events.OnPlayerDeath.Add(TrueSmoking.stop)