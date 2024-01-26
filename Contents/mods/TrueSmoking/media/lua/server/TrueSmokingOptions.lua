require('TrueSmoking')

TrueSmoking = TrueSmoking or {}
TrueSmoking.Options = TrueSmoking.Options or {}

TrueSmoking.Options.keySmoke = {
    name = "Take Puff",
    key = Keyboard.KEY_K,
}

TrueSmoking.Options.keyStopSmoke = {
    name = "Stop Smoking",
    key = 39,
}

--Not implemented
TrueSmoking.Options.passiveSmokeToggle = true
--Not implemented
TrueSmoking.Options.passiveSmokeTime = {
    min = 20,
    max = 40,
}
--Not implemented
TrueSmoking.Options.burnLimits = {
    lower = 0.0305,
    upper = 0.0095,
}