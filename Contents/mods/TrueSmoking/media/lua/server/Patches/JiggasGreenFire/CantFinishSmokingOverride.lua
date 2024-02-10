require('TrueSmoking')
if getActivatedMods():contains('jiggasGreenfireMod') then
    local originalCough = CantFinishSmoking

    function CantFinishSmoking(char)
        TrueSmoking.GreenFireSmokeHalf = true
    end

    function greenFireCough(char)
        originalCough(char)
    end
end