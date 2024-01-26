-- DarkSlayerEX's Item Tweaker Core: an API for tweaking existing items without redefining them entirely.
--Initializes the tables needed for the code to run
if not ItemTweaker then  ItemTweaker = {} end
if not TweakItem then  TweakItem = {} end
if not TweakItemData then  TweakItemData = {} end

--Prep code to make the changes to all item in the TweakItemData table.
function ItemTweaker.tweakItems()
    local item;
    for k,v in pairs(TweakItemData) do
        for t,y in pairs(v) do
            item = ScriptManager.instance:getItem(k);
            if item ~= nil then
                item:DoParam(t.." = "..y);
                print(k..": "..t..", "..y);
            end
        end
    end
end

function TweakItem(itemName, itemProperty, propertyValue)
    if not TweakItemData[itemName] then
        TweakItemData[itemName] = {};
    end
    TweakItemData[itemName][itemProperty] = propertyValue;
end

Events.OnGameBoot.Add(ItemTweaker.tweakItems)

if getActivatedMods():contains("Smoker") then
    TweakItem("SM.SMSmokingDeviceWithPinchTobacco", "BurnLength", 1.0)
    TweakItem("SM.SMSmokingDeviceWithPinchTobacco", "BurnRate", 0.03)
    TweakItem("SM.SMCigarette", "BurnLength", 1.0)
    TweakItem("SM.SMCigarette", "BurnRate", 0.03)
    TweakItem("SM.SMHomemadeCigarette", "BurnLength", 1.0)
    TweakItem("SM.SMHomemadeCigarette", "BurnRate", 0.03)
    TweakItem("SM.SMHomemadeCigarette2", "BurnLength", 1.0)
    TweakItem("SM.SMHomemadeCigarette2", "BurnRate", 0.03)
    TweakItem("SM.SMCigaretteLight", "BurnLength", 1.0)
    TweakItem("SM.SMCigaretteLight", "BurnRate", 0.03)
    TweakItem("SM.SMPCigaretteMenthol", "BurnLength", 1.0)
    TweakItem("SM.SMPCigaretteMenthol", "BurnRate", 0.03)
    TweakItem("SM.SMPCigaretteGold", "BurnLength", 1.0)
    TweakItem("SM.SMPCigaretteGold", "BurnRate", 0.03)
    TweakItem("SM.SMButt", "BurnLength", 1.0)
    TweakItem("SM.SMButt", "BurnRate", 0.03)
    TweakItem("SM.SMButt2", "BurnLength", 1.0)
    TweakItem("SM.SMButt2", "BurnRate", 0.03)
    TweakItem("SM.SMSmokingBlendBong", "BurnLength", 1.0)
    TweakItem("SM.SMSmokingBlendBong", "BurnRate", 0.03)
    TweakItem("SM.SMSmokingBlendPipe", "BurnLength", 1.0)
    TweakItem("SM.SMSmokingBlendPipe", "BurnRate", 0.03)
    TweakItem("SM.SMSmokingDeviceWithSmokingBlend", "BurnLength", 1.0)
    TweakItem("SM.SMSmokingDeviceWithSmokingBlend", "BurnRate", 0.03)
    TweakItem("SM.SMSmokingDeviceWithCannabisShake", "BurnLength", 1.0)
    TweakItem("SM.SMSmokingDeviceWithCannabisShake", "BurnRate", 0.03)
end

if getActivatedMods():contains("SDelight") then
    TweakItem("SDelight.MaduroCigarSingle", "BurnLength", 1.0)
    TweakItem("SDelight.MaduroCigarSingle", "BurnRate", 0.03)
    TweakItem("SDelight.ColoradoCigarSingle", "BurnLength", 1.0)
    TweakItem("SDelight.ColoradoCigarSingle", "BurnRate", 0.03)
    TweakItem("SDelight.ClaroCigarSingle", "BurnLength", 1.0)
    TweakItem("SDelight.ClaroCigarSingle", "BurnRate", 0.03)
end

if getActivatedMods():contains("MoreSmokes") then
    TweakItem("MoreSmokes.MSCigarette", "BurnLength", 1.0)
    TweakItem("MoreSmokes.MSCigarette", "BurnRate", 0.03)

    TweakItem("MoreSmokes.Cigarillo", "BurnLength", 1.0)
    TweakItem("MoreSmokes.Cigarillo", "BurnRate", 0.03)
    TweakItem("MoreSmokes.MSCigar", "BurnLength", 1.0)
    TweakItem("MoreSmokes.MSCigar", "BurnRate", 0.03)
    TweakItem("MoreSmokes.JointNorthernLights", "BurnLength", 1.0)
    TweakItem("MoreSmokes.JointNorthernLights", "BurnRate", 0.03)
    TweakItem("MoreSmokes.JointPurpleHaze", "BurnLength", 1.0)
    TweakItem("MoreSmokes.JointPurpleHaze", "BurnRate", 0.03)
    TweakItem("MoreSmokes.JointSourDiesel", "BurnLength", 1.0)
    TweakItem("MoreSmokes.JointSourDiesel", "BurnRate", 0.03)
    TweakItem("MoreSmokes.JointIndigoFog", "BurnLength", 1.0)
    TweakItem("MoreSmokes.JointIndigoFog", "BurnRate", 0.03)

    TweakItem("MoreSmokes.BluntNorthernLights", "BurnLength", 1.0)
    TweakItem("MoreSmokes.BluntNorthernLights", "BurnRate", 0.03)
    TweakItem("MoreSmokes.BluntPurpleHaze", "BurnLength", 1.0)
    TweakItem("MoreSmokes.BluntPurpleHaze", "BurnRate", 0.03)
    TweakItem("MoreSmokes.BluntSourDiesel", "BurnLength", 1.0)
    TweakItem("MoreSmokes.BluntSourDiesel", "BurnRate", 0.03)
    TweakItem("MoreSmokes.BluntBackwoods", "BurnLength", 1.0)
    TweakItem("MoreSmokes.BluntBackwoods", "BurnRate", 0.03)
    TweakItem("MoreSmokes.SpliffNorthernLights", "BurnLength", 1.0)
    TweakItem("MoreSmokes.SpliffNorthernLights", "BurnRate", 0.03)
    TweakItem("MoreSmokes.SpliffPurpleHaze", "BurnLength", 1.0)
    TweakItem("MoreSmokes.SpliffPurpleHaze", "BurnRate", 0.03)
    TweakItem("MoreSmokes.SpliffSourDiesel", "BurnLength", 1.0)
    TweakItem("MoreSmokes.SpliffSourDiesel", "BurnRate", 0.03)
    TweakItem("MoreSmokes.CigarPlus", "BurnLength", 1.0)
    TweakItem("MoreSmokes.CigarPlus", "BurnRate", 0.03)

    TweakItem("MoreSmokes.JointNorthernLightsPlus", "BurnLength", 1.0)
    TweakItem("MoreSmokes.JointNorthernLightsPlus", "BurnRate", 0.03)
    TweakItem("MoreSmokes.JointPurpleHazePlus", "BurnLength", 1.0)
    TweakItem("MoreSmokes.JointPurpleHazePlus", "BurnRate", 0.03)
    TweakItem("MoreSmokes.JointSourDieselPlus", "BurnLength", 1.0)
    TweakItem("MoreSmokes.JointSourDieselPlus", "BurnRate", 0.03)
    TweakItem("MoreSmokes.CigarPlus", "BurnLength", 1.0)
    TweakItem("MoreSmokes.CigarPlus", "BurnRate", 0.03)
    TweakItem("MoreSmokes.CigarPlus", "BurnLength", 1.0)
    TweakItem("MoreSmokes.CigarPlus", "BurnRate", 0.03)

    local vessels = {'SmokePipe1','SmokePipe2','SmokePipe3','SmokePipeGlassBlue','SmokePipeGlassGreen',
                     'SmokePipeGlassYellow','SmokePipePink','Hookah1','Hookah2','Hookah3','Bong1v1',
                     'Bong1v2','Bong1v3','Bong1v4','Bong2v1','Bong2v2','Bong2v3','Bong2v4','Bong3v1',
                     'Bong3v2','Bong3v3','Bong3v4','Bong4v1','Bong4v2','Bong4v3','Bong4v4','Bong5'}

    local substances = {'Tobacco','NorthernLights','PurpleHaze','SourDiesel'}

    for i,v in ipairs(vessels) do
        for j, s in ipairs(substances) do
            TweakItem("MoreSmokes."..v..s, "BurnLength", 1.0)
            TweakItem("MoreSmokes."..v..s, "BurnRate", 0.03)
        end
    end
end

if getActivatedMods():contains("jiggasGreenfireMod") then
    --GFRoundBongs_items.txt
    TweakItem("Greenfire.TobaccoBong", "BurnLength", 1.0)
    TweakItem("Greenfire.TobaccoBong", "BurnRate", 0.03)
    TweakItem("Greenfire.WeedBong", "BurnLength", 1.0)
    TweakItem("Greenfire.WeedBong", "BurnRate", 0.03)
    TweakItem("Greenfire.ShakeBong", "BurnLength", 1.0)
    TweakItem("Greenfire.ShakeBong", "BurnRate", 0.03)
    TweakItem("Greenfire.KiefBong", "BurnLength", 1.0)
    TweakItem("Greenfire.KiefBong", "BurnRate", 0.03)
    TweakItem("Greenfire.HashBong", "BurnLength", 1.0)
    TweakItem("Greenfire.HashBong", "BurnRate", 0.03)

    local colors = {'red','blue','green','orange','yellow','magenta','pastelred','pastelblue',
    'pastelgreen','pastelorange','pastelyellow','pastelpurple','darkbrown','darkbeige',
    'tan','darkforestgreen','navy','royalpurple','black','gray','white','arabiangold',
    'persianpink'}

    for i,v in ipairs(colors) do
        TweakItem("Greenfire.TobaccoBong_"..v, "BurnLength", 1.0)
        TweakItem("Greenfire.TobaccoBong_"..v, "BurnRate", 0.03)
        TweakItem("Greenfire.WeedBong_"..v, "BurnLength", 1.0)
        TweakItem("Greenfire.WeedBong_"..v, "BurnRate", 0.03)
        TweakItem("Greenfire.ShakeBong_"..v, "BurnLength", 1.0)
        TweakItem("Greenfire.ShakeBong_"..v, "BurnRate", 0.03)
        TweakItem("Greenfire.KiefBong_"..v, "BurnLength", 1.0)
        TweakItem("Greenfire.KiefBong_"..v, "BurnRate", 0.03)
        TweakItem("Greenfire.HashBong_"..v, "BurnLength", 1.0)
        TweakItem("Greenfire.HashBong_"..v, "BurnRate", 0.03)
    end

    --GreenfireCannabis.txt
    TweakItem("Greenfire.Joint", "BurnLength", 1.0)
    TweakItem("Greenfire.Joint", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfJoint", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfJoint", "BurnRate", 0.03)
    TweakItem("Greenfire.KiefJoint", "BurnLength", 1.0)
    TweakItem("Greenfire.KiefJoint", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfKiefJoint", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfKiefJoint", "BurnRate", 0.03)
    TweakItem("Greenfire.HashJoint", "BurnLength", 1.0)
    TweakItem("Greenfire.HashJoint", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfHashJoint", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfHashJoint", "BurnRate", 0.03)
    TweakItem("Greenfire.WeedPipe", "BurnLength", 1.0)
    TweakItem("Greenfire.WeedPipe", "BurnRate", 0.03)
    TweakItem("Greenfire.ShakePipe", "BurnLength", 1.0)
    TweakItem("Greenfire.ShakePipe", "BurnRate", 0.03)
    TweakItem("Greenfire.KiefPipe", "BurnLength", 1.0)
    TweakItem("Greenfire.KiefPipe", "BurnRate", 0.03)
    TweakItem("Greenfire.HashPipe", "BurnLength", 1.0)
    TweakItem("Greenfire.HashPipe", "BurnRate", 0.03)
    TweakItem("Greenfire.CannaCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.CannaCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfCannaCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfCannaCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.PreCannaCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.PreCannaCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfPreCannaCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfPreCannaCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.DelCannaCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.DelCannaCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfDelCannaCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfDelCannaCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.ResCannaCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.ResCannaCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfResCannaCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfResCannaCigar", "BurnRate", 0.03)
    --GreenfireMixed.txt
    TweakItem("Greenfire.Blunt", "BurnLength", 1.0)
    TweakItem("Greenfire.Blunt", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfBlunt", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfBlunt", "BurnRate", 0.03)
    TweakItem("Greenfire.MixedBlunt", "BurnLength", 1.0)
    TweakItem("Greenfire.MixedBlunt", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfMixedBlunt", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfMixedBlunt", "BurnRate", 0.03)
    TweakItem("Greenfire.KiefBlunt", "BurnLength", 1.0)
    TweakItem("Greenfire.KiefBlunt", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfKiefBlunt", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfKiefBlunt", "BurnRate", 0.03)
    TweakItem("Greenfire.HashBlunt", "BurnLength", 1.0)
    TweakItem("Greenfire.HashBlunt", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfHashBlunt", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfHashBlunt", "BurnRate", 0.03)
    TweakItem("Greenfire.SpaceBlunt", "BurnLength", 1.0)
    TweakItem("Greenfire.SpaceBlunt", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfSpaceBlunt", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfSpaceBlunt", "BurnRate", 0.03)
    TweakItem("Greenfire.Spliff", "BurnLength", 1.0)
    TweakItem("Greenfire.Spliff", "BurnRate", 0.03)
    --GreenfireTobacco.txt
    TweakItem("Greenfire.GFCigarette", "BurnLength", 1.0)
    TweakItem("Greenfire.GFCigarette", "BurnRate", 0.03)
    TweakItem("Greenfire.BluntCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.BluntCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfBluntCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfBluntCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.GFCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.GFCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.HalfCigar", "BurnLength", 1.0)
    TweakItem("Greenfire.HalfCigar", "BurnRate", 0.03)
    TweakItem("Greenfire.TobaccoPipe", "BurnLength", 1.0)
    TweakItem("Greenfire.TobaccoPipe", "BurnRate", 0.03)
end