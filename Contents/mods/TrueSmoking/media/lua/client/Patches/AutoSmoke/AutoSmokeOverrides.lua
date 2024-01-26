local originalCanSmoke = AutoSmoke.canSmoke
function AutoSmoke:canSmoke()
    return not getPlayer():getModData().isSmoking and originalCanSmoke(self)
end

local oldFunc = onKeyPressed
Events.OnKeyPressed.Remove(oldFunc)

local function onKeyPressed(key)
    if AutoSmoke.player and key == AutoSmoke.Options.keySmoke.key and AutoSmoke:canSmoke() then
        if AutoSmoke.Options.characterSpeaks then
            AutoSmoke.pressedKey = true
        end
        AutoSmoke:checkInventory()
    end
end

Events.OnKeyPressed.Add(onKeyPressed)