require "TimedActions/ISBaseTimedAction"

TakePuff = ISBaseTimedAction:derive("TakePuff")

function TakePuff:isValid()
    --Check if we have a smoke lit
    if self.TrueSmoking.isSmoking then return true else return false end
end

function TakePuff:update()
    -- Trigger every game update when the action is perform
    if (not self.passiveSmoking and not isKeyDown(self.TrueSmoking.Options.keySmoke.key)) or
    (self.passiveSmoking and os.difftime(os.time(), self.TrueSmoking.puffTimeMark) >= 3) then
        self.TrueSmoking.takingPuff = false
        self:forceComplete()
        ISBaseTimedAction.stop(self)
    end
end

function TakePuff:waitToStart()
    --Wait for timed actions to finish
    if not self.character:isStrafing() and not self.character:isRunning() and not self.character:isSprinting()
            and not self.character:isAiming() and not self.character:isAsleep() and not self.character:isPerformingAnAction()
    then return false else return true end
end

function TakePuff:start()
    --Set the animation
    print('Start puff')
    self:setActionAnim(CharacterActionAnims.Eat)
    self:setAnimVariable("FoodType", "Cigarettes")
    self:setOverrideHandModels(nil, self.item)

    --Track puff
    self.TrueSmoking.takingPuff = true
    self.TrueSmoking.puffTimeMark = os.time()
end

function TakePuff:stop()
    self.TrueSmoking.takingPuff = false
    self:forceComplete()
    ISBaseTimedAction.stop(self)
end

function TakePuff:perform()
    --Track puff
    print('End puff')
    if not self.TrueSmoking.smokeLit then
        self.TrueSmoking:lightSmoke()
    end
    self.TrueSmoking.takingPuff = false
    self.TrueSmoking.puffTimeMark = os.time()
    ISBaseTimedAction.perform(self)
end

function TakePuff:new(character, item, TrueSmoking, passiveSmoking)
    local o = {
        stopOnWalk = false,
        stopOnRun = true,
        stopOnAim = true,
        forceProgressBar = false,
        character = character,
        item = item,
        TrueSmoking = TrueSmoking,
        passiveSmoking = passiveSmoking or false,
    }
    setmetatable(o, self)
    self.__index = self

    --if passiveSmoking then o.maxTime = 80 else o.maxTime = -1 end
    o.maxTime = -1
    return o
end