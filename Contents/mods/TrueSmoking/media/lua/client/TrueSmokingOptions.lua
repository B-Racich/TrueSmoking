require('TrueSmoking')

TrueSmoking.Options = TrueSmoking.Options or {}

TrueSmoking.Options.passiveSmoking = true
TrueSmoking.Options.smokeRelighting = true

TrueSmoking.Options.keySmoke = {
    name = 'Take Puff/Relight',
    key = Keyboard.KEY_K,
}

TrueSmoking.Options.keyStopSmoke = {
    name = 'Stop Smoking',
    key = Keyboard.KEY_COLON,
}

function TrueSmoking.Options.init()
    if ModOptions and ModOptions.getInstance then
        local function onModOptionsApply(optionValues)
            TrueSmoking.Options.PassiveSmoking = optionValues.settings.options.PassiveSmoking;
            TrueSmoking.Options.PassiveSmokingMinTime = (optionValues.settings.options.PassiveSmokingMinTime*10)-10
            TrueSmoking.Options.PassiveSmokingMaxTime = (optionValues.settings.options.PassiveSmokingMaxTime*10)-10
        end

        ModOptions:AddKeyBinding('[True Smoking]', TrueSmoking.Options.keySmoke)
        ModOptions:AddKeyBinding('[True Smoking]', TrueSmoking.Options.keyStopSmoke)

        local SETTINGS = {
            options_data = {
                PassiveSmoking = {
                    name = 'UI_TrueSmoking_PassiveSmoking',
                    tooltip = 'UI_TrueSmoking_PassiveSmoking_tooltip',
                    default = true,
                    OnApplyMainMenu = onModOptionsApply,
                    OnApplyInGame = onModOptionsApply,
                },
                PassiveSmokingMinTime = {
                    '0','10','20','30','40','50','60',
                    name = 'UI_TrueSmoking_PassiveSmokingMinTime',
                    tooltip = 'UI_TrueSmoking_PassiveSmokingMinTime_tooltip',
                    default = 2,
                    OnApplyMainMenu = onModOptionsApply,
                    OnApplyInGame = onModOptionsApply,
                },
                PassiveSmokingMaxTime = {
                    '10','20','30','40','50','60','70','80','90','100','110','120',
                    name = 'UI_TrueSmoking_PassiveSmokingMinTime',
                    tooltip = 'UI_TrueSmoking_PassiveSmokingMaxTime_tooltip',
                    default = 2,
                    OnApplyMainMenu = onModOptionsApply,
                    OnApplyInGame = onModOptionsApply,
                },
            },
            mod_id = 'TrueSmoking',
            mod_shortname = 'True Smoking',
            mod_fullname = 'True Smoking',
        }
        ModOptions:getInstance(SETTINGS)
        ModOptions:loadFile()

        Events.OnPreMapLoad.Add(function()
            TrueSmoking.Options.SmokePuffingIncrease = SandboxVars.TrueSmoking.SmokePuffingIncrease
            TrueSmoking.Options.SmokePuffingDecrease = SandboxVars.TrueSmoking.SmokePuffingDecrease
            TrueSmoking.Options.SmokePuffingDecreaseRunning = SandboxVars.TrueSmoking.SmokePuffingDecreaseRunning

            TrueSmoking.Options.SmokeRelighting = SandboxVars.TrueSmoking.SmokeRelighting
            TrueSmoking.Options.SmokeMinBurnLimit = SandboxVars.TrueSmoking.SmokeMinBurnLimit
            TrueSmoking.Options.SmokeMaxBurnLimit = SandboxVars.TrueSmoking.SmokeMaxBurnLimit

            onModOptionsApply({ settings = SETTINGS })
        end)
    end
end