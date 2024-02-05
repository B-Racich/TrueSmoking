require 'TimedActions/ISBaseTimedAction'
require 'ISUI/ISInventoryPaneContextMenu'


require 'GreenFireOverrides'
require 'TrueSmokingOverrides'
require 'TrueSmokingUtils'

TrueSmoking = TrueSmoking or {}

--Find a smoke from inventory and start smoking
function TrueSmoking:startSmoking()
    print('start smoking')
    if not self.isSmoking then
        self.isSmoking = true
        self.smokeLit = true
        self.panicReductionBeforeSmoking = getPlayer():getBodyDamage():getPanicReductionValue()
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
                if isInList(item.onEat, TrueSmoking.funcsToHook) then
                    SandboxVars.MoreSmokes.StonedDecreaseMulti = 0
                    getPlayer():getBodyDamage():setPanicReductionValue(0)
                end
            end
        else
            if getActivatedMods():contains('MoreSmokes') then
                if isInList(item.onEat, TrueSmoking.funcsToHook) then
                    SandboxVars.MoreSmokes.StonedDecreaseMulti = TrueSmoking.StonedDecreaseMulti or 2
                    math.min(getPlayer():getBodyDamage():setPanicReductionValue(0.06),getPlayer:getBodyDamage():setPanicReductionValue(TrueSmoking.panicReductionBeforeSmoking))
                end
            end
        end
        if smokeLength > burnRate then
            TrueSmoking:smoke()
        end
        if TrueSmoking.smokeItem.smokeLength <= TrueSmoking.smokeItem.burnRate then
            TrueSmoking:stopSmoking()
        end
    end
end

function TrueSmoking:smoke()
    --Try to take a passivePuff
    if self.Options.PassiveSmoking then
        self:takePuff()
    end

    local dt = os.difftime(os.time(), self.passiveTimeMark or os.time())

    if self.passiveTimeMark == nil then
        self.passiveTimeMark = os.time()
        return
    elseif dt >= 2 then
        if self.smokeLit then
            self:updateBurnRate(dt)
            --All smoking handled through OnEat_Cigarettes for stat changes
            print('Calling OnEat_OverTime w/ SmokeLength: '..truncateToDecimalPlaces(self.smokeItem.smokeLength,4))
            OnEat_OverTime(self.item,  getPlayer(), self.smokeItem.smokeLength)
            self.passiveTimeMark = os.time()
        end
    end
end

function TrueSmoking:updateBurnRate()
    local burnRate = self.smokeItem.burnRate
    if self.takingPuff then
        print('burnRate: '..truncateToDecimalPlaces(burnRate,4))
        self.smokeItem.burnRate = cubicEaseOut(burnRate, self.Options.SmokeMaxBurnLimit, self.Options.SmokePuffingIncrease)
    else
        local smoothFactor = self.Options.SmokePuffingDecrease
        if getPlayer():isRunning() or getPlayer():isSprinting() then smoothFactor = self.Options.SmokePuffingDecreaseRunning end
        print('burnRate: '..truncateToDecimalPlaces(burnRate,4))
        self.smokeItem.burnRate = cubicEaseOut(burnRate, self.Options.SmokeMinBurnLimit*0.95, smoothFactor)
        -- Check if the smoke is 'notLit'
        if self.Options.SmokeRelighting and self.smokeItem.burnRate < self.Options.SmokeMinBurnLimit then
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
        if time > ZombRand(self.Options.PassiveSmokingMinTime,self.Options.PassiveSmokingMaxTime) then
            ISTimedActionQueue.add(TakePuff:new(self.player, self.item, self, true))
        end
    end
end

--Stop smoking, kill the moodle, nil the data
function TrueSmoking:stopSmoking()
    print('stopSmoking')

    self.Moodle.stop()

    self.isSmoking = false
    self.smokeLit = false
    getPlayer():getModData().isSmoking = false
    self.takingPuff = false
    self.statsDelta = nil

    if getActivatedMods():contains("MoreSmokes") then
        if self.item ~= nil and isInList(self.smokeItem.onEat, self.funcsToHook) then
            SandboxVars.MoreSmokes.StonedDecreaseMulti = self.StonedDecreaseMulti or 2
            math.min(getPlayer():getBodyDamage():setPanicReductionValue(0.06),getPlayer():getBodyDamage():setPanicReductionValue(self.panicReductionBeforeSmoking))
        end
    end

    self.item = nil

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

    TrueSmoking.player = getPlayer()

    TrueSmoking.funcsToHook = {'MoreSmokes.onEatJoint','MoreSmokes.onEatBlunt','MoreSmokes.onEatMixed',
                               'MoreSmokes.onEatPipe','MoreSmokes.onEatHookah','MoreSmokes.onEatBong','MoreSmokes.onEatBluntPlus',
                               'MoreSmokes.onEatCannabisPlus',
                               'OnSmoke_Blunt','OnSmoke_Cannabis','OnSmoke_CannaCigar','OnSmoke_Cigar','OnSmoke_HCCannabis',}

    --MoreSmokes
    if getActivatedMods():contains("MoreSmokes") then
        TrueSmoking.StonedDecreaseMulti = SandboxVars.MoreSmokes.StonedDecreaseMulti or 2
    end

    TrueSmoking.Moodle.start()

    --Keybinds
    Events.OnKeyStartPressed.Add(TrueSmoking.onKeyStartPressed)

    --Toggles the Smoke option in the context menu
    Events.OnFillInventoryObjectContextMenu.Add(TrueSmoking.toggleSmokeMenuOption)
end

function TrueSmoking.stop()
    TrueSmoking:stopSmoking()
    TrueSmoking.Moodle.stop()
    Events.EveryOneMinute.Remove(TrueSmoking.Moodle.update)
    Events.OnKeyStartPressed.Remove(TrueSmoking.onKeyStartPressed)
    Events.OnFillInventoryObjectContextMenu.Remove(TrueSmoking.toggleSmokeMenuOption)
end

function TrueSmoking.init()
    TrueSmoking.Options.init()
end

--Events.OnGameBoot.Add(init)
Events.OnCreatePlayer.Add(TrueSmoking.start)
Events.OnPlayerDeath.Add(TrueSmoking.stop)
Events.OnGameBoot.Add(TrueSmoking.init)