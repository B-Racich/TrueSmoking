if getActivatedMods().contains('jiggasGreenfireMod') then
    local GreenFireCoughSmoke = cantFinishSmoking
    function CantFinishSmoking()
        getPlayer():getModData().GreenFireSmokeHalf = true
    end
end