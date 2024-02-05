require 'MF_ISMoodle'
require 'TrueSmoking'

TrueSmoking.Moodle = TrueSmoking.Moodle or {}

function TrueSmoking.Moodle.start()
    if getActivatedMods():contains('MoodleFramework') then
        MF.createMoodle('smoking')
        print('create moodle')
    end

    Events.EveryOneMinute.Add(TrueSmoking.Moodle.update)
end

function TrueSmoking.Moodle.stop()
    if getActivatedMods():contains('MoodleFramework') then
        local moodle = MF.getMoodle('smoking')
        if moodle ~= nil then
            moodle:setValue(0.5)
            moodle:setPicture(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/notSmoking.png'))
        end
    end
end

function TrueSmoking.Moodle.update()
    if not TrueSmoking.isSmoking then return end
    if getActivatedMods():contains('MoodleFramework') then
        local moodle = MF.getMoodle('smoking')
        if moodle == nil then return end
        --print('Update Moodle')
        local item = TrueSmoking.smokeItem
        local smokeLit = TrueSmoking.smokeLit or false
        local displayedPercentage = string.format('%.2f', item.smokeLength * 100)

        local isUp = false
        local chevs = 1

        local lower, upper = TrueSmoking.Options.SmokeMinBurnLimit, TrueSmoking.Options.SmokeMaxBurnLimit
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
        moodle:setDescription(moodle:getGoodBadNeutral(),moodle:getLevel(),getText('Moodles_smoking_Custom',truncateToDecimalPlaces(item.burnRate,4), displayedPercentage))
        moodle:setBackground(moodle:getGoodBadNeutral(),moodle:getLevel(),getTexture('media/ui/Moodles/bg.png'))
        moodle:setChevronCount(chevs)
        moodle:setChevronIsUp(isUp)
    end
end