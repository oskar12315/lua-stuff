

local SmileUILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/RblxScriptsOG/Smile-Hub-UI/refs/heads/main/lib.lua"))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local itemLib = require(game:GetService("ReplicatedStorage").Modules.ItemLibrary)
local cosmeticLib = require(game:GetService("ReplicatedStorage").Modules.CosmeticLibrary)
local animLib = require(game:GetService("ReplicatedStorage").Modules.AnimationLibrary)

_G.skinPresets = {}

local function getSavePath()
    return "smilehub/skin_changer.json"
end

local function saveSkins()
    local success, error = pcall(function()
        local data = HttpService:JSONEncode(_G.skinPresets)
        if writefile then
            writefile(getSavePath(), data)
        end
    end)
    if not success then
        warn("Failed to save skins:", error)
    end
end

local function loadSkins()
    local success, error = pcall(function()
        if readfile and isfile and isfile(getSavePath()) then
            local data = readfile(getSavePath())
            _G.skinPresets = HttpService:JSONDecode(data)
            local skinCount = 0
            for _ in pairs(_G.skinPresets) do skinCount = skinCount + 1 end
        else

        end
    end)
    if not success then
        warn("Failed to load skins:", error)
        _G.skinPresets = {}

    end
end

loadSkins()

_G.EquipSkin = function(weaponName, skinName)
    _G.skinPresets[weaponName] = skinName

    local viewmodels = itemLib.ViewModels
    local cosmetics = cosmeticLib.Cosmetics
    local ogViewmodel = viewmodels[weaponName]

    if not ogViewmodel then
        warn("No viewmodel for " .. weaponName)
        return
    end

    local skinCosmetic = cosmetics[skinName]
    if not skinCosmetic then
        warn("Cannot apply " .. skinName .. " to " .. weaponName)
        return
    end
    if skinCosmetic.Type ~= "Skin" then
        warn(skinName .. " is not a skin")
        return
    end
    
    local skinViewmodel = viewmodels[skinName]
    if not skinViewmodel then
        warn("No viewmodel for skin " .. skinName)
        return
    end

    ogViewmodel.Image = skinViewmodel.Image or ogViewmodel.Image
    ogViewmodel.ImageHighResolution = skinViewmodel.ImageHighResolution or ogViewmodel.ImageHighResolution
    ogViewmodel.ImageCentered = skinViewmodel.ImageCentered or ogViewmodel.ImageCentered
    ogViewmodel.EliminationFeedImage = skinViewmodel.EliminationFeedImage or ogViewmodel.EliminationFeedImage
    ogViewmodel.EliminationFeedImageScale = skinViewmodel.EliminationFeedImageScale or ogViewmodel.EliminationFeedImageScale
    ogViewmodel.RootPartOffset = skinViewmodel.RootPartOffset or ogViewmodel.RootPartOffset

    ogViewmodel.Animations = {}
    for animType, animName in pairs(skinViewmodel.Animations or {}) do
        ogViewmodel.Animations[animType] = animName
        if not animLib.Info[animName] then
            warn("animation " .. animName .. " not in AnimationLibrary")
        end
    end

    saveSkins()
    SmileUILib:Notify("$mile Hub", "Equipped " .. skinName .. " for " .. weaponName)
end

task.wait(5)
local Assets = player.PlayerScripts:WaitForChild("Assets", 10)
local ViewModels = Assets and Assets:WaitForChild("ViewModels", 10)
if not ViewModels then
    return
end

local starterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local starterAssets = starterPlayerScripts:WaitForChild("Assets", 10)
local starterViewModels = starterAssets and starterAssets:WaitForChild("ViewModels", 10)

local function applySkinToWeapon(wModel)
    local wName = wModel.Name
    local targetSkin = _G.skinPresets[wName]
    if not targetSkin then return end

    local skinModel = starterViewModels:FindFirstChild(targetSkin, true)
    if not skinModel or not skinModel:IsA("Model") then
        warn("not found: " .. targetSkin)
        return
    end

    wModel:ClearAllChildren()
    local copied = 0
    for _, part in ipairs(skinModel:GetChildren()) do
        part:Clone().Parent = wModel
        copied += 1
    end
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local weaponsFolder = player.Character and player.Character:FindFirstChild("Weapons")
            if weaponsFolder then
                for _, w in pairs(weaponsFolder:GetChildren()) do
                    if w:IsA("Model") and not w:FindFirstChild("SkinApplied") then
                        local tag = Instance.new("StringValue")
                        tag.Name = "SkinApplied"
                        tag.Parent = w
                        applySkinToWeapon(w)
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, vm in pairs(ViewModels:GetDescendants()) do
                if vm:IsA("Model") and _G.skinPresets[vm.Name] and not vm:FindFirstChild("SkinApplied") then
                    local tag = Instance.new("StringValue")
                    tag.Name = "SkinApplied"
                    tag.Parent = vm
                    applySkinToWeapon(vm)
                end
            end
        end)
    end
end)

SmileUILib:Notify("$mile Hub", "Skin Changer Loaded", 3)

local customScriptURL = "https://smile-hub.vercel.app/rivals/skin-changer.lua"

if queue_on_teleport then
    queue_on_teleport([[
        task.spawn(function()
            local success, err = pcall(function()
                local response = game:HttpGet("]] .. customScriptURL .. [[", true)
                loadstring(response)()
            end)
            if not success then
                warn("Failed to load queued script:", err)
            end
        end)
    ]])
end
