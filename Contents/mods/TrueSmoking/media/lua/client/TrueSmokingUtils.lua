function isInList(str, list)
    if str == "" then
        return false
    end
    local listString = table.concat(list, ",")
    return string.find(listString, str) ~= nil
end

function truncateToDecimalPlaces(value, decimalPlaces)
    local multiplier = 10 ^ decimalPlaces
    return math.floor(value * multiplier) / multiplier
end

function cubicEaseOut(val, tar, percent, stat)
    local t = 1 - percent
    local x = tar + (1 - t^3) * (val - tar)
    --debugPrint('val: ',truncateToDecimalPlaces(val,6),' tar: ',truncateToDecimalPlaces(tar,6),' x: ',truncateToDecimalPlaces(x,6),' %: ',truncateToDecimalPlaces(1-percent,6), ' stat:: ', stat)
    return x
end

function debugPrint(str)
    if TrueSmoking.Options.DebugPrint or true then
        print(str)
    end
end

function setPlayerStats(player, levels, delta, percent)
    local player = player
    local stats = player:getStats()
    local body = player:getBodyDamage()

    if delta == nil then
        --stats:setStressFromCigarettes(levels.stressFromCig)
        --player:setTimeSinceLastSmoke(levels.timeSinceLastSmoke)
        stats:setStressFromCigarettes(0)
        player:setTimeSinceLastSmoke(0)
        stats:setStress(levels.stress)

        body:setUnhappynessLevel(levels.unhappyness)
        body:setFoodSicknessLevel(levels.foodSick)
        body:setBoredomLevel(levels.boredom)
        stats:setFatigue(levels.fatigue)
        stats:setThirst(levels.thirst)
        stats:setPanic(levels.panic)

        if checkForMod("MoreSmokes") then
            player:getModData().StonedChange = levels.stonedChange
        end

        if checkForMod('EvolvingTraitsWorld') then
            player:getModData().EvolvingTraitsWorld.SmokeSystem.SmokingAddiction = levels.ETWaddiction
        end

        if checkForMod('jiggasGreenfireMod') then
            --player:getModData().stonedamt = levels.stonedamt
            --player:getModData().potcount = levels.potcount
        end
    else
        setStatCheck('stress', levels, delta, percent, (function(statChange)
            stats:setStress(statChange)
            --print('stress was set w/ ',statChange)
        end))

        setStatCheck('unhappyness', levels, delta, percent, (function(statChange)
            body:setUnhappynessLevel(statChange)
        end))

        setStatCheck('stressFromCig', levels, delta, percent, (function(statChange)
            stats:setStressFromCigarettes(statChange)
        end))

        setStatCheck('timeSinceLastSmoke', levels, delta, percent, (function(statChange)
            player:setTimeSinceLastSmoke(statChange)
        end))

        setStatCheck('foodSick', levels, delta, percent, (function(statChange)
            body:setFoodSicknessLevel(statChange)
        end))

        setStatCheck('boredom', levels, delta, percent, (function(statChange)
            body:setBoredomLevel(statChange)
        end))

        setStatCheck('fatigue', levels, delta, percent, (function(statChange)
            stats:setFatigue(statChange)
        end))

        setStatCheck('thirst', levels, delta, percent, (function(statChange)
            stats:setThirst(statChange)
        end))

        setStatCheck('panic', levels, delta, percent, (function(statChange)
            stats:setPanic(statChange)
        end))

        if checkForMod('MoreSmokes') then
            setStatCheck('stonedChange', levels, delta, percent, (function(statChange)
                --print('Level Before: ',player:getModData().StonedChange)
                player:getModData().StonedChange = statChange
                --print('Level After: ',player:getModData().StonedChange)
            end))
        end

        if checkForMod('EvolvingTraitsWorld') then
            setStatCheck('stonedChange', levels, delta, percent, (function(statChange)
                player:getModData().EvolvingTraitsWorld.modData.SmokeSystem.smokerModData.SmokingAddiction = statChange
            end))
        end

        if checkForMod('jiggasGreenfireMod') then
            --setStatCheck('stonedamt', levels, delta, percent, (function(statChange)
            --    player:getModData().stonedamt = statChange
            --end))
            --setStatCheck('potcount', levels, delta, percent, (function(statChange)
            --    player:getModData().potcount = statChange
            --end))
        end
    end
end

function setStatCheck(stat, levels, delta, percent, func)
    local function helper(check, statChange)
        if math.abs(statChange) > check then
            -- Check positive changes to stop at 0
            if delta[stat] > 0 then
                --print(stat,'::',delta[stat],'::',statChange)
                delta[stat] = math.max(delta[stat] - math.abs(statChange), 0)
                -- Check negative changes to stop at 0
            elseif delta[stat] < 0 then
                --print(stat,'::',delta[stat],'::',statChange)
                delta[stat] = math.min(delta[stat] + math.abs(statChange), 0)
            end
        end
    end
    if math.abs(delta[stat]) > 0 then
        local statBefore = levels[stat]
        local statAfter = statBefore
        if TrueSmoking.hasSmokerTrait and TrueSmoking.smokeItem.onEat == 'OnEat_Cigarettes' and (stat == 'stress' or stat == 'stressFromCig' or stat == 'timeSinceLastSmoke') then
            if TrueSmoking.smokeItem.isButt then
                statAfter = cubicEaseOut(levels[stat], levels[stat]*.75, percent, stat)
            elseif TrueSmoking.smokeItem.isHalf then
                statAfter = cubicEaseOut(levels[stat],  levels[stat]/2, percent, stat)
            else
                statAfter = cubicEaseOut(levels[stat], 0, percent, stat)
            end
        else
            statAfter = cubicEaseOut(levels[stat], (levels[stat] + delta[stat]), percent, stat)
        end

        if statAfter < 0 then statAfter = 0 end
        if statAfter > 100 then statAfter = 100 end
        local statChange = statAfter-statBefore

        func(statAfter)
        --debugPrint(str = 'STAT::',stat,' BEFORE::',truncateToDecimalPlaces(levels[stat],6),' DELTA::',truncateToDecimalPlaces(statChange,6),' AFTER::',truncateToDecimalPlaces(statAfter,6))

        --CHECKS FOR VARIOUS STATS TO ENSURE CHANGES
        if stat == 'stress' and TrueSmoking.smokeItem.onEat == 'OnEat_Cigarettes' then
            helper(0.0001, statChange)
        elseif stat == 'foodSick' or stat == 'unhappyness' then
            helper(0.5, statChange)
        elseif stat == 'panic' then
            helper(0.1, statChange)
        else
            helper(0.0001, statChange)
        end
    end
end

function getPlayerStats(player)
    local o = {}
    o.stress = player:getStats():getStress()
    o.boredom = player:getBodyDamage():getBoredomLevel()
    o.unhappyness = player:getBodyDamage():getUnhappynessLevel()
    o.fatigue = player:getStats():getFatigue()
    o.thirst = player:getStats():getThirst()
    o.stressFromCig = player:getStats():getStressFromCigarettes()
    o.timeSinceLastSmoke = player:getTimeSinceLastSmoke()
    o.panic = player:getStats():getPanic()
    o.foodSick = player:getBodyDamage():getFoodSicknessLevel()
    o.stonedChange = player:getModData().StonedChange or 0

    if checkForMod('EvolvingTraitsWorld') then
        o.ETWaddiction = player:getModData().EvolvingTraitsWorld.SmokeSystem.SmokingAddiction or 0
    end

    if checkForMod('jiggasGreenfireMod') then
        o.stonedamt = player:getModData().stonedamt or 0
        o.potcount = player:getModData().potcount or 0
    end

    return o
end

function getStatsDelta(before, after)
    local function helper(stat)
        --cig < 10, rest < 100
        local largeStats = {'boredom','unhappyness','panic','foodSick','stonedChange'}
        local itemStats = {'boredom','unhappyness'}
        local item = TrueSmoking.smokeItem
        local x = after[stat]-before[stat]
        --print(stat, ' -- ',x)
        if math.abs(x) > (isInList(stat, largeStats) and 1 or 0.01) then
            --print('Using projected stats ', stat)
            return x
        elseif isInList(stat, itemStats) and item[stat] ~= 0 then
            --print('Getting Item stats ',stat)
            return item[stat]
        else
            return 0
        end
    end

    local o = {}
    o.stress = helper('stress')
    o.boredom = helper('boredom')
    o.unhappyness = helper('unhappyness')
    o.fatigue = helper('fatigue')
    o.thirst = helper('thirst')
    o.stressFromCig = helper('stressFromCig')
    o.timeSinceLastSmoke = helper('timeSinceLastSmoke')
    o.panic = helper('panic')
    o.foodSick = helper('foodSick')
    o.stonedChange = helper('stonedChange')

    if checkForMod('EvolvingTraitsWorld') then
        o.ETWaddiction = helper('ETWaddiction')
    end

    if checkForMod('jiggasGreenfireMod') then
        o.stonedamt = helper('stonedamt')
        o.potcount = helper('potcount')
    end

    return o
end

function greenFireHalf(fullType)
    local map = {
        ['Greenfire.SpaceBlunt'] = 'Greenfire.HalfSpaceBlunt',
        ['Greenfire.HashBlunt'] = 'Greenfire.HalfHashBlunt',
        ['Greenfire.KiefBlunt'] = 'Greenfire.HalfKiefBlunt',
        ['Greenfire.MixedBlunt'] = 'Greenfire.HalfMixedBlunt',
        ['Greenfire.Blunt'] = 'Greenfire.HalfBlunt',
        ['Greenfire.Joint'] = 'Greenfire.HalfJoint',
        ['Greenfire.KiefJoint'] = 'Greenfire.HalfKiefJoint',
        ['Greenfire.HashJoint'] = 'Greenfire.HalfHashJoint',
        ['Greenfire.Cigar'] = 'Greenfire.HalfCigar',
        ['Greenfire.BluntCigar'] = 'Greenfire.HalfBluntCigar',
    }
    return map[fullType]
end

function addItem()
    local player = getPlayer()
    local item = TrueSmoking.smokeItem.replaceOnUse
    if item and item ~= '' then
        player:getInventory():AddItem(item)
    end
end

function checkForMod(mod)
    return getActivatedMods():contains(mod)
end

function callModFunction(func)
    return function(item, player, percent)
        func(item, player, percent)
        return getPlayerStats(player)
    end
end