require 'TimedActions/ISEatFoodAction'

require 'TrueSmoking'
require 'TrueSmokingUtils'
require 'ETWFunctionsOverride'

TrueSmoking = TrueSmoking or {}

local originalActionNew = ISEatFoodAction.new
local originalActionIsValid = ISEatFoodAction.isValid

--Hook and check if we are doing a smoke action, 0 the stat data on item to fake consume and start SmokingOverhaul
function ISEatFoodAction:new (character, item, percentage)
    local o = {}
    local onEat = item:getOnEat() or ''
    local modOnEat = item:getModData().modOnEat or ''
    local name = item:getFullType() or ''
    local funcsToHook = {'OnEat_Cigarettes','MoreSmokes.onEatJoint','MoreSmokes.onEatBlunt','MoreSmokes.onEatMixed',
                            'MoreSmokes.onEatPipe','MoreSmokes.onEatHookah','MoreSmokes.onEatBong','MoreSmokes.onEatBluntPlus',
                            'MoreSmokes.onEatCannabisPlus',
                            'OnSmoke_Blunt','OnSmoke_Cannabis','OnSmoke_CannaCigar','OnSmoke_Cigar','OnSmoke_HCCannabis',}
    local itemsToSkip = {'MoreSmokes.ChewingTobacco'}
    local hook = 'OnEat_Hook'

    TrueSmoking.isSmokeItem = false
    TrueSmoking.statsBefore = getPlayerStats(character)
    o = originalActionNew(self, character, item, percentage)
    --Shorten anim to light and puff
    if isInList(onEat, funcsToHook) and not isInList(name, itemsToSkip) then
        print('Hooking: '..onEat..' -> '..hook)
        if not TrueSmoking.isSmoking then TrueSmoking:getSmokeInfo(item) end
        TrueSmoking.isSmokeItem = true
        if modOnEat ~= hook then
            item:getModData().modOnEat = onEat
            item:setOnEat(hook)
        end
        o.item = item
        o.maxTime = 80;
    end

    return o
end

function ISEatFoodAction:isValid()
    if self.item:getOnEat() == nil or self.item:getOnEat() == '' then
        return originalActionIsValid(self)
    else
        return not TrueSmoking.isSmoking
    end
end

function OnEat_Hook(food, character, percent)
    local modOnEat = food:getModData().modOnEat or ''
    local tableName, funcName = modOnEat:match("([^%.]+)%.([^%.]+)")
    local modTable, functionToCall

    local before = TrueSmoking.statsBefore

    if tableName and funcName then
        modTable = _G[tableName]
        functionToCall = modTable and modTable[funcName]
    else
        functionToCall = _G[modOnEat]
    end

    if type(functionToCall) == "function" then
        print('Calling mod function: ' .. modOnEat)
        local modFunction = callModFunction(functionToCall)
        TrueSmoking.statsAfter = modFunction(food, character, percent)
        TrueSmoking.statsDelta = getStatsDelta(TrueSmoking.statsBefore, TrueSmoking.statsAfter)
    end

    --Reset stats from original OnEat changes
    if TrueSmoking.isSmokeItem then
        TrueSmoking.isSmokeItem = false
        setPlayerStats(character, before)
        TrueSmoking:startSmoking()
    end
end

function OnEat_OverTime(food, character, percent)
    local current, delta = getPlayerStats(character), TrueSmoking.statsDelta

    if getActivatedMods():contains("jiggasAddictionMod") then
        character:getModData().cigsmoked = true;
    end

    if getActivatedMods():contains("EvolvingTraitsWorld") then
        ETWOnEat(character, TrueSmoking.puffPercent)
    end

    setPlayerStats(character, current, delta, percent)
end