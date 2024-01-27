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

function cubicEaseOut(val, tar, percent)
    local t = 1 - percent
    local x = tar + (1 - t^3) * (val - tar)
    --print('val: ',val,' tar: ',tar,' x: ',x,' %: ',1-percent)
    return x
end

function setPlayerStats(player, levels, delta, percent)
    local player = player
    local stats = player:getStats()
    local body = player:getBodyDamage()

    if delta == nil then
        stats:setStress(levels.stress)
        body:setUnhappynessLevel(levels.unhappyness)
        stats:setStressFromCigarettes(levels.stressFromCig)
        player:setTimeSinceLastSmoke(levels.timeSinceLastSmoke)
        body:setFoodSicknessLevel(levels.foodSick)
        body:setBoredomLevel(levels.boredom)
        stats:setFatigue(levels.fatigue)
        stats:setThirst(levels.thirst)
        stats:setPanic(levels.panic)

        if checkForMod("MoreSmokes") then
            player:getModData().StonedChange = levels.stonedChange
        end

        checkForMod('EvolvingTraitsWorld', function()
            player:getModData().EvolvingTraitsWorld.modData.SmokeSystem.smokerModData.SmokingAddiction = levels.ETWaddiction
        end)
    else
        setStatCheck('stress', levels, delta, percent, (function(statChange)
            stats:setStress(statChange)
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
                print('Level Before: ',player:getModData().StonedChange)
                player:getModData().StonedChange = statChange
                print('Level After: ',player:getModData().StonedChange)
            end))
        end

        if checkForMod('EvolvingTraitsWorld') then
            setStatCheck('stonedChange', levels, delta, percent, (function(statChange)
                player:getModData().EvolvingTraitsWorld.modData.SmokeSystem.smokerModData.SmokingAddiction = statChange
            end))
        end
    end
end

function setStatCheck(stat, levels, delta, percent, func)
    local function helper(val, x)
        --print(val, x)
        if math.abs(x) > val then
            --delta[stat] = delta[stat] - math.abs(x)
            --check positive changes to stop if hitting 0
            if delta[stat] > 0 then
                if delta[stat] - math.abs(x) > 0 then
                    --print(string.upper(stat),' D:B-',delta[stat],' D:A-',delta[stat] - math.abs(x))
                    delta[stat] = delta[stat] - math.abs(x)
                else
                    delta[stat] = 0
                end
            elseif delta[stat] < 0 then
                if delta[stat] + math.abs(x) < 0 then
                    --print(string.upper(stat),' D:B-',delta[stat],' D:A-',delta[stat] + math.abs(x))
                    delta[stat] = delta[stat] + math.abs(x)
                else
                    delta[stat] = 0
                end
            end
        end
    end
    print(stat,' :: ',delta[stat])
    if math.abs(delta[stat]) > 0 then
        local statBefore = levels[stat]
        local statAfter = cubicEaseOut(levels[stat], (levels[stat] + delta[stat]), percent)

        if TrueSmoking.hasSmokerTrait and TrueSmoking.smokeItem.onEat == 'OnEat_Cigarettes' then
            if stat == 'stress' or stat == 'stressFromCig' or stat == 'timeSinceLastSmoke' then
                statAfter = cubicEaseOut(levels[stat], 0, percent)
            end
        end

        if statAfter < 0 then statAfter = 0 end
        if statAfter > 100 then statAfter = 100 end
        local statChange = statAfter-statBefore

        func(statAfter)

        --CHECKS FOR VARIOUS STATS TO ENSURE CHANGES
        if stat == 'stress' and TrueSmoking.smokeItem.onEat == 'OnEat_Cigarettes' then
            helper(0.0001, statChange)
        elseif stat == 'foodSick' or stat == 'unhappyness' then
            helper(0.5, statChange)
        elseif stat == 'panic' then
            helper(0.001, statChange)
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
        o.ETWaddiction = character:getModData().EvolvingTraitsWorld.modData.SmokeSystem.smokerModData.SmokingAddiction or 0
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
        print(stat, ' -- ',x)
        if isInList(stat, largeStats) then
            if math.abs(x) > 1 then
                return x
            elseif isInList(stat, itemStats) and item[stat] ~= 0 then
                return item[stat]
            else
                return 0
            end
        else
            if math.abs(x) > 0.01 then
                return x
            elseif stat == 'stress' and item[stat] ~= 0 then
                return item[stat]
            else
                return 0
            end
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
    return o
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