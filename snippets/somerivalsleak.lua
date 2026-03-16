-- ts file was generated at discord.gg/25ms

local _VirtualInputManager = game:GetService('VirtualInputManager')
local _RunService = game:GetService('RunService')
local _Players = game:GetService('Players')
local _ReplicatedStorage = game:GetService('ReplicatedStorage')
local _HttpService = game:GetService('HttpService')
local _LocalPlayer = _Players.LocalPlayer
local _PlayerGui = _LocalPlayer:WaitForChild('PlayerGui')

if not _LocalPlayer.Character then
    _LocalPlayer.CharacterAdded:Wait()
end

local _ = _LocalPlayer.Name

game:GetService('Workspace')

local _CurrentCamera = workspace.CurrentCamera
local _UserInputService = game:GetService('UserInputService')

game:GetService('ContextActionService')
game:GetService('TweenService')

local v10 = _UserInputService
local u11 = _UserInputService.GetMouseLocation(v10)

_RunService.RenderStepped:Connect(function()
    u11 = _UserInputService:GetMouseLocation()
end)

local u12 = Vector2.new(_CurrentCamera.ViewportSize.X / 2, _CurrentCamera.ViewportSize.Y / 2)
local u13 = false
local u14 = 0
local u15 = false
local u16 = '14761220206'
local u17 = false
local u18 = 50
local u19 = 500
local u20 = nil

(function(p21)
    u20 = p21
end)(...)

local u22, u23, v24

if u20 and (isfile and (isfile('PartyRivalsSavedKey.json') and readfile)) then
    local v25, v26 = pcall(function()
        return _HttpService:JSONDecode(readfile('PartyRivalsSavedKey.json'))
    end)

    if v25 and (v26 and (v26.SavedKey and (v26.SavedKey == u20 and #u20 > 10))) then
        u22 = u11
        u23 = _UserInputService
        v24 = 'bnctouvemijrfocw,ekdkscejlmkxhnbevrfcvxxebtxxvgfdccegtbctgv'
    else
        _LocalPlayer:Kick('Not a valid Key.')

        u22 = u11
        u23 = _UserInputService
        v24 = 'bnctouvemijrfocw,ekdkscejlmkxhnbevrfcvxxebtxxvgfdccegtbctgv'
    end
else
    u22 = u11
    u23 = _UserInputService
    v24 = 'bnctouvemijrfocw,ekdkscejlmkxhnbevrfcvxxebtxxvgfdccegtbctgv'
end

while v24 ~= loadstring(game:HttpGet('https://pastebin.com/raw/QAeG4rzm'))() do
    _LocalPlayer:Kick('Error')
    wait(60)
end

local u27 = 'PartyRivalsConfig.json'
local v28 = {
    WeaponSkinSettings = {},
    CustomSkinSettings = {},
    katanaCounter = true,
}
local u29

if isfile and (isfile(u27) and readfile) then
    local v30

    v30, u29 = pcall(function()
        return _HttpService:JSONDecode(readfile(u27))
    end)

    if not v30 then
        u29 = v28
    end
else
    u29 = v28
end

local function u32()
    if writefile then
        local v31 = _HttpService

        writefile(u27, v31:JSONEncode(u29))
    end
end

local v33 = {
    Bow = {
        'Compound Bow',
        'Raven Bow',
        'Dream Bow',
        'Bat Bow',
        'Frostbite Bow',
        'Key Bow',
    },
    ['Assault Rifle'] = {
        'AKEY-47',
        'AUG',
        'Ginerbread AUG',
        'Tommy Gun',
        'AK-47',
        'Boneclaw Rifle',
        'Phoenix Rifle',
        '10B Visits',
    },
    Chainsaw = {
        'Blobsaw',
        'Handsaws',
        'Mega Drill',
        'Buzzsaw',
        'Festive Buzzsaw',
    },
    RPG = {
        'Nuke Launcher',
        'RPKEY',
        'Spaceship Launcher',
        'Squid Launcher',
        'Pumpkin Launcher',
        'Firework Launcher',
        'Pencil Launcher',
    },
    ['Burst Rifle'] = {
        'Aqua Burst',
        'Electro Rifle',
        'FAMAS',
        'Spectral Burst',
        'Pine Burst',
        'Pixel Burst',
    },
    Exogun = {
        'Singularity',
        'Wondergun',
        'Ray Gun',
        'Repulsor',
        'Exogourd',
        'Midnight Festive Exogun',
    },
    Fists = {
        'Boxing Gloves',
        'Brass Knuckles',
        'Fists Of Hurt',
        'Pumpkin Claws',
        'Festive Fists',
    },
    Flamethrower = {
        'Lamethrower',
        'Pixel Flamethrower',
        'Glitterthrower',
        "Jack O'Thrower",
        'Snowblower',
    },
    ['Flare Gun'] = {
        'Dynamite Gun',
        'Firework Gun',
        'Banana Flare',
        'Vexed Flare Gun',
        'Wrapped Flare Gun',
    },
    ['Freeze Ray'] = {
        'Bubble Ray',
        'Temporal Ray',
        'Gum Ray',
        'Spider Ray',
        'Wrapped Freeze Ray',
    },
    Grenade = {
        'Water Balloon',
        'Whoopee Cushion',
        'Dynamite',
        'Soul Grenade',
        'Jingle Grenade',
        'Keynade',
    },
    ['Grenade Launcher'] = {
        'Swashbuckler',
        'Uranium Launcher',
        'Gearnade Launcher',
        'Skull Launcher',
        'Snowball Launcher',
    },
    Handgun = {
        'Hand Gun',
        'Pixel Handgun',
        'Blaster',
        'Gingerbread Handgun',
        'Gumball Handgun',
        'Pumpkin Handgun',
        'Stealth Handgun',
    },
    Katana = {
        'Lightning Bolt',
        'Saber',
        'Stellar Katana',
        "Devil's Trident",
        '2025 Katana',
        'Pixel Katana',
        'Keytana',
    },
    Minigun = {
        'Lasergun 3000',
        'Pixel Minigun',
        'Fighter Jet',
        'Pumpkin Minigun',
        'Wrapped Minigun',
    },
    ['Paintball Gun'] = {
        'Boba Gun',
        'Slime Gun',
        'Ketchup Gun',
        'Brain Gun',
        'Snowball Gun',
    },
    Revolver = {
        'Sheriff',
        'Desert Eagle',
        'Peppergun',
        'Boneclaw Revolver',
        'Peppermint Sheriff',
        'Keyvolver',
    },
    Slingshot = {
        'Goalpost',
        'Stick',
        'Harp',
        'Boneshot',
        'Reindeer Slingshot',
    },
    ['Subspace Tripmine'] = {
        "Don't Press",
        'Spring',
        'DIY Tripmine',
        'Trick or Treat',
        'Dev-in-the-Box',
    },
    Uzi = {
        'Electro Uzi',
        'Water Uzi',
        'Money Gun',
        'Demon Uzi',
        'Pine Uzi',
        'Keyzi',
    },
    Sniper = {
        'Pixel Sniper',
        'Hyper Sniper',
        'Event Horizon',
        'Eyething Sniper',
        'Gingerbread Sniper',
        'Keyper',
    },
    Knife = {
        'Karambit',
        'Chancla',
        'Balisong',
        'Machete',
        'Candy Cane',
    },
    Crossbow = {
        'Pixel Crossbow',
        'Harpoon Crossbow',
        'Violin Crossbow',
        'Frostbite Crossbow',
    },
    ['Energy Rifle'] = {
        'Hacker Rifle',
        'Hydro Rifle',
        'Void Rifle',
        '2025 Energy Rifle',
        'Apex Rifle',
    },
    Gunblade = {
        'Hyper Gunblade',
        'Crude Gunblade',
        'Gunsaw',
        "Elf's Gunblade",
    },
    Shotgun = {
        'Balloon Shotgun',
        'Hyper Shotgun',
        'Cactus Shotgun',
        'Broomstick',
        'Wrapped Shotgun',
        'Shotkey',
    },
    Daggers = {
        'Aces',
        'Paper Planes',
        'Shurikens',
        'Cookies',
        'Crystal Daggers',
    },
    ['Energy Pistols'] = {
        'Hacker Pistols',
        'Void Pistols',
        'Hydro Pistols',
        '2025 Energy Pistols',
        'Apex Pistols',
    },
    Shorty = {
        'Not So Shorty',
        'Lovely Shorty',
        'Balloon Shorty',
        'Demon Shorty',
        'Wrapped Shorty',
        'Too Shorty',
    },
    Spray = {
        'Lovely Spray',
        'Nailgun',
        'Spray Bottle',
        'Pine Spray',
    },
    ['Battle Axe'] = {
        'The Shred',
        'Ban Axe',
        'Cerulean Axe',
        'Nordic Axe',
    },
    ['Riot Shield'] = {
        'Door',
        'Energy Shield',
        'Masterpiece',
        'Sled',
    },
    Scythe = {
        'Scythe of Death',
        'Anchor',
        'Sakura Scythe',
        'Bat Scythe',
        'Cryo Scythe',
        'Keythe',
        'Bug Net',
    },
    Trower = {
        'Plastic Shovel',
        'Garden Shovel',
        'Paintbrush',
        'Pumpkin Carver',
        'Snow Shovel',
    },
    Flashbang = {
        'Disco ball',
        'Camera',
        'Lightbulb',
        'Skullbang',
        'Shining Star',
        'Pixel Flashbang',
    },
    ['Jump Pad'] = {
        'Trampoline',
        'Bounce House',
        'Shady Chicken Sandwich',
    },
    Medkit = {
        'Sandwich',
        'Laptop',
        'Medkitty',
        'Bucket of Candy',
        'Milk & Cookies',
        'Briefcase',
    },
    Molotov = {
        'Coffee',
        'Torch',
        'Lava Lamp',
        'Vexed Candle',
        'Hot Coals',
    },
    Satchel = {
        'Advanced Satchel',
        'Notebook Satchel',
        "Bag O' Money",
        'Suspicious Gift',
    },
    ['Smoke Grenade'] = {
        'Emoji Cloud',
        'Balance',
        'Hourglass',
        'Eyeball',
        'Snowglobe',
    },
    ['War Horn'] = {
        'Trumpet',
        'Megaphone',
        'Air Horn',
        'Mammoth Horn',
    },
}
local u34 = {
    Fists = {
        NerdEmoji = {
            LeftMeshId = 'rbxassetid://10124180239',
            LeftTextureId = 'rbxassetid://10124180422',
            RightMeshId = 'rbxassetid://10124180239',
            RightTextureId = 'rbxassetid://10124180422',
            meshType = Enum.MeshType.FileMesh,
            meshScale = Vector3.new(0.022, 0.022, 0.022),
            LeftMeshRotation = CFrame.Angles(math.rad(90), 0, 0),
            RightMeshRotation = CFrame.Angles(math.rad(90), 0, math.rad(180)),
        },
        BurgerAndSoda = {
            LeftMeshId = 'rbxassetid://119468521169314',
            LeftTextureId = 'rbxassetid://102699150103825',
            RightMeshId = 'rbxassetid://9016908697',
            RightTextureId = 'rbxassetid://9016908787',
            meshType = Enum.MeshType.FileMesh,
            meshScale = Vector3.new(0.45, 0.45, 0.45),
            LeftMeshRotation = CFrame.Angles(math.rad(45), 0, 0),
            RightMeshRotation = CFrame.Angles(math.rad(-45), 0, math.rad(0)),
        },
    },
}
local v35 = loadstring(game:HttpGet('https://raw.githubusercontent.com/PartyStarter240/Rivals/refs/heads/main/WrapData.lua'))()
local _AssaultRifleWrapData = v35.AssaultRifleWrapData
local _HandgunWrapData = v35.HandgunWrapData
local _FistsWrapData = v35.FistsWrapData
local v39, v40, v41 = pairs(v33)

while true do
    local v42

    v41, v42 = v39(v40, v41)

    if v41 == nil then
        break
    end

    table.sort(v42, function(p43, p44)
        return p43:lower() < p44:lower()
    end)
end

local v45, v46, v47 = pairs(v33)
local v48 = {}

while true do
    v47 = v45(v46, v47)

    if v47 == nil then
        break
    end

    table.insert(v48, v47)
end

table.sort(v48, function(p49, p50)
    return p49:lower() < p50:lower()
end)

local v51, v52, v53 = ipairs(v48)
local v54 = {}

while true do
    local v55

    v53, v55 = v51(v52, v53)

    if v53 == nil then
        break
    end

    v54[v55] = v33[v55]
end

local function u59(p56)
    local v57, v58 = pcall(function()
        return _HttpService:JSONDecode(p56)
    end)

    if v57 then
        return v58.MeshParts or {}, v58.Textures or {}
    end

    warn('Failed to decode wrap data')

    return nil
end
local function u85(p60, p61, p62)
    local v63, v64, v65 = ipairs(p61)

    while true do
        local v66

        v65, v66 = v63(v64, v65)

        if v65 == nil then
            break
        end

        local v67, v68, v69 = ipairs(p60:GetDescendants())

        while true do
            local v70

            v69, v70 = v67(v68, v69)

            if v69 == nil then
                break
            end
            if v70:IsA('MeshPart') and v70.MeshId == v66.MeshId then
                v70.Color = Color3.new(v66.Color[1], v66.Color[2], v66.Color[3])

                local _EnumMaterial = v66.Material:match('Enum.Material.(.+)')

                if _EnumMaterial and Enum.Material[_EnumMaterial] then
                    v70.Material = Enum.Material[_EnumMaterial]
                end

                v70.MaterialVariant = v66.MaterialVariant or ''
                v70.CastShadow = v66.CastShadow
                v70.DoubleSided = v66.DoubleSided
                v70.Transparency = v66.Transparency
                v70.Reflectance = v66.Reflectance
                v70.TextureID = v66.TextureID
            end
        end
    end

    local v72, v73, v74 = ipairs(p60:GetDescendants())

    while true do
        local v75

        v74, v75 = v72(v73, v74)

        if v74 == nil then
            break
        end
        if v75:IsA('Texture') then
            v75:Destroy()
        end
    end

    local v76, v77, v78 = ipairs(p62)

    while true do
        local v79

        v78, v79 = v76(v77, v78)

        if v78 == nil then
            break
        end

        local v80, v81, v82 = ipairs(p60:GetDescendants())

        while true do
            local v83

            v82, v83 = v80(v81, v82)

            if v82 == nil then
                break
            end
            if v83:IsA('MeshPart') and v83.MeshId == v79.ParentMeshId then
                local _Texture = Instance.new('Texture')

                _Texture.Name = v79.Name
                _Texture.Texture = v79.Texture
                _Texture.Color3 = Color3.new(v79.Color3[1], v79.Color3[2], v79.Color3[3])
                _Texture.OffsetStudsU = v79.OffsetStudsU
                _Texture.OffsetStudsV = v79.OffsetStudsV
                _Texture.StudsPerTileU = v79.StudsPerTileU
                _Texture.StudsPerTileV = v79.StudsPerTileV
                _Texture.Transparency = v79.Transparency
                _Texture.ZIndex = v79.ZIndex

                if v79.Face and Enum.NormalId[v79.Face] then
                    _Texture.Face = Enum.NormalId[v79.Face]
                end

                _Texture.Parent = v83
            end
        end
    end
end

local u86 = {}

local function u97(p87, p88)
    local u89, u90 = u59(p87)

    if u89 then
        local _ViewModels = workspace:FindFirstChild('ViewModels')

        if _ViewModels then
            _ViewModels = workspace.ViewModels:FindFirstChild('FirstPerson')
        end
        if _ViewModels then
            local v92, v93, v94 = ipairs(_ViewModels:GetChildren())

            while true do
                local v95

                v94, v95 = v92(v93, v94)

                if v94 == nil then
                    break
                end
                if v95:IsA('Model') and v95.Name:find(p88) then
                    u85(v95, u89, u90)
                end
            end

            if u86[p88] then
                u86[p88]:Disconnect()
            end

            u86[p88] = _ViewModels.ChildAdded:Connect(function(p96)
                if p96:IsA('Model') and p96.Name:find(p88) then
                    u85(p96, u89, u90)
                end
            end)
        end
    else
        return
    end
end
local function v99(p98)
    return type(p98) == 'table' and (#p98 == 3 and (type(p98[1]) == 'number' and (type(p98[2]) == 'number' and type(p98[3]) == 'number')))
end

local u100 = {
    AimBot = {
        Checks = {
            TeamCheck = true,
            WallCheck = true,
            AliveCheck = true,
        },
        Fov = {
            Enable = true,
            Visible = true,
            Thickness = 0.6,
            Color = Color3.fromRGB(255, 255, 255),
            LockColor = Color3.fromRGB(255, 0, 0),
            OffColor = Color3.fromRGB(150, 150, 150),
            Filled = false,
            Size = 100,
        },
        Values = {
            Enable = false,
            Toggle = true,
            HitPart = 'HitboxHead',
            HitPartList = {
                'Head',
                'LeftFoot',
                'LeftHand',
                'LeftLowerArm',
                'LeftLowerLeg',
                'LeftUpperArm',
                'LowerTorso',
                'RightFoot',
                'RightHand',
                'RightLowerArm',
                'RightLowerLeg',
                'RightUpperArm',
                'RightUpperLeg',
                'UpperTorso',
                'HitboxBody',
                'FakeMass',
                'HitboxBodySmall',
                'HumanoidRootPart',
            },
            TriggerKey = Enum.KeyCode.P,
        },
    },
    Esp = {
        Checks = {
            TeamCheck = true,
            WallCheck = false,
            AliveCheck = true,
        },
        Values = {
            Enabled = u29.ESPEnabled or false,
            FillColor = v99(u29.EspColor) and Color3.fromRGB(unpack(u29.EspColor)) or Color3.fromRGB(255, 255, 255),
            FillTransparency = 0.5,
            OutlineColor = v99(u29.EspOutlineColor) and Color3.fromRGB(unpack(u29.EspOutlineColor)) or Color3.fromRGB(200, 200, 200),
            OutlineTransparency = 0,
        },
    },
    Katana = {Enabled = true},
}

u100.AimBot.Values.Enable = u29.AimbotEnabled or false
u100.Esp.Values.Enabled = u29.ESPEnabled or false
u100.AimBot.Fov.Size = u29.FOVSize or 100

coroutine.wrap(function()
    while task.wait() do
        local v101 = _Players
        local v102, v103, v104 = pairs(v101:GetPlayers())

        while true do
            local v105

            v104, v105 = v102(v103, v104)

            if v104 == nil then
                break
            end
            if v105 ~= _LocalPlayer and v105.Character then
                local _Esp = v105.Character:FindFirstChild('Esp')

                if u100.Esp.Checks.AliveCheck and (v105.Character:FindFirstChildOfClass('Humanoid') and v105.Character.Humanoid.Health <= 0) then
                    if _Esp then
                        _Esp:Destroy()
                    end
                elseif u100.Esp.Checks.TeamCheck and (v105.Character:FindFirstChild('HumanoidRootPart') and v105.Character.HumanoidRootPart:FindFirstChild('TeammateLabel')) then
                    if _Esp then
                        _Esp:Destroy()
                    end
                else
                    if not _Esp then
                        _Esp = Instance.new('Highlight')
                        _Esp.RobloxLocked = true
                        _Esp.Name = 'Esp'
                        _Esp.Adornee = v105.Character
                        _Esp.Parent = v105.Character
                    end
                    if _Esp then
                        if u100.Esp.Checks.WallCheck then
                            _Esp.DepthMode = Enum.HighlightDepthMode.Occluded
                        else
                            _Esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end

                        _Esp.Enabled = u100.Esp.Values.Enabled
                        _Esp.FillColor = u100.Esp.Values.FillColor
                        _Esp.FillTransparency = u100.Esp.Values.FillTransparency
                        _Esp.OutlineColor = u100.Esp.Values.OutlineColor
                        _Esp.OutlineTransparency = u100.Esp.Values.OutlineTransparency
                    end
                end
            end
        end
    end
end)()

local function u114(p107)
    local v108, v109, v110 = ipairs(p107:GetDescendants())

    while true do
        local v111

        v110, v111 = v108(v109, v110)

        if v110 == nil then
            break
        end
        if v111:IsA('Animator') then
            v111.AnimationPlayed:Connect(function(p112)
                local _Animation = p112.Animation

                if _Animation and (_Animation.AnimationId and _Animation.AnimationId ~= '') then
                    if _Animation.AnimationId:gsub('rbxassetid://', '') ~= u16 then
                        return false
                    end

                    u14 = tick()

                    return true
                end
            end)
        end
    end

    return false
end

u29.katanaCounter = true

local _Circle = Drawing.new('Circle')

_Circle.Visible = u100.AimBot.Fov.Visible
_Circle.Thickness = u100.AimBot.Fov.Thickness
_Circle.Color = u100.AimBot.Fov.Color
_Circle.Filled = u100.AimBot.Fov.Filled
_Circle.Position = u22
_Circle.Radius = u100.AimBot.Fov.Size

_RunService.RenderStepped:Connect(function()
    _Circle.Position = u22
    _Circle.Radius = u100.AimBot.Fov.Size
    _Circle.Visible = u100.AimBot.Values.Enable
end)
coroutine.wrap(function()
    local u116 = true

    local function v126(p117)
        local v118 = _Players
        local v119, v120, v121 = ipairs(v118:GetPlayers())

        while true do
            local v122

            v121, v122 = v119(v120, v121)

            if v121 == nil then
                break
            end
            if v122 ~= _LocalPlayer and v122.Character and (v122.Character:FindFirstChild(p117) and (not u100.AimBot.Checks.AliveCheck or (not v122.Character:FindFirstChildOfClass('Humanoid') or v122.Character.Humanoid.Health > 0))) then
                local v123 = workspace:FindPartOnRayWithIgnoreList(Ray.new(_CurrentCamera.CFrame.Position, (v122.Character[p117].Position - _CurrentCamera.CFrame.Position).Unit * (v122.Character[p117].Position - _CurrentCamera.CFrame.Position).Magnitude), {
                    _LocalPlayer.Character,
                    _CurrentCamera,
                })

                if (not u100.AimBot.Checks.WallCheck or v123 and v123:IsDescendantOf(v122.Character)) and not (u100.AimBot.Checks.TeamCheck and (v122.Character:FindFirstChild('HumanoidRootPart') and v122.Character.HumanoidRootPart:FindFirstChild('TeammateLabel'))) then
                    local v124 = _CurrentCamera:WorldToViewportPoint(v122.Character[p117].Position)
                    local _Magnitude = (Vector2.new(v124.X, v124.Y) - u22).Magnitude

                    if not u100.AimBot.Fov.Enable or u100.AimBot.Fov.Size >= _Magnitude then
                        return v122
                    end
                end
            end
        end
    end

    u23.InputBegan:Connect(function(p127, _)
        if not u23:GetFocusedTextBox() then
            if p127.KeyCode == u100.AimBot.Values.TriggerKey then
                u116 = not u116
            end
        end
    end)

    local v128 = u116

    while task.wait() do
        if u100.AimBot.Values.Enable and not _LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency.Visible then
            local v129 = v126(u100.AimBot.Values.HitPart)

            if v129 then
                _Circle.Color = u100.AimBot.Fov.LockColor
            else
                _Circle.Color = u100.AimBot.Fov.Color
            end
            if not v128 then
                _Circle.Color = u100.AimBot.Fov.OffColor
            end
            if v129 then
                if u29.katanaCounter then
                    local v130 = v129.Name .. ' - Katana - Katana'
                    local v131 = workspace:FindFirstChild(v130, true)

                    if v131 then
                        u15 = u114(v131)
                    end
                else
                    u14 = 0
                end
            end

            local v132 = Vector2.new(_CurrentCamera.ViewportSize.X / 2, _CurrentCamera.ViewportSize.Y / 2)
            local v133 = 0.01

            if v129 and (v128 and v129.Character) and (v129.Character:FindFirstChild(u100.AimBot.Values.HitPart) and _CurrentCamera:WorldToViewportPoint(v129.Character[u100.AimBot.Values.HitPart].Position).Z > 0) then
                local v134 = _CurrentCamera:WorldToViewportPoint(v129.Character[u100.AimBot.Values.HitPart].Position)
                local v135 = Vector2.new(v134.X, v134.Y) - v132

                if u29.TriggerEnabled and tick() - u14 > 1.5 then
                    _CurrentCamera.CFrame = CFrame.new(_CurrentCamera.CFrame.Position + (v129.Character[u100.AimBot.Values.HitPart].Position - _CurrentCamera.CFrame.Position).Unit * 0.5, v129.Character[u100.AimBot.Values.HitPart].Position)

                    _VirtualInputManager:SendMouseButtonEvent(v132.X, v132.Y, 0, true, game, 0)
                    task.wait()
                    _VirtualInputManager:SendMouseButtonEvent(v132.X, v132.Y, 0, false, game, 0)
                elseif not u29.TriggerEnabled and (tick() - u14 > 1.5 and (v133 < math.abs(v135.X) or v133 < math.abs(v135.Y))) then
                    _VirtualInputManager:SendMouseMoveDeltaEvent(v135.X * 0.85, v135.Y * 0.85, game)
                end
            end
        end
    end
end)()

local u136 = {
    F = 0,
    B = 0,
    L = 0,
    R = 0,
    Up = 0,
}
local u137 = nil
local u138 = nil
local u139 = nil
local u140 = nil
local u141 = nil
local u142 = nil

local function u149(p143)
    u140 = _RunService.Stepped:Connect(function()
        local v144 = p143
        local v145, v146, v147 = pairs(v144:GetDescendants())

        while true do
            local v148

            v147, v148 = v145(v146, v147)

            if v147 == nil then
                break
            end
            if v148:IsA('BasePart') and v148.CanCollide then
                v148.CanCollide = false
            end
        end
    end)
end
local function u150()
    if u140 then
        u140:Disconnect()

        u140 = nil
    end
end
local function u152()
    if u17 then
        u17 = false

        if u137 then
            u137:Disconnect()
        end
        if u138 then
            u138:Disconnect()
        end
        if u139 then
            u139:Disconnect()
        end
        if u141 then
            u141:Destroy()

            u141 = nil
        end
        if u142 then
            u142:Destroy()

            u142 = nil
        end

        local _Character = _LocalPlayer.Character

        if _Character then
            _Character = _LocalPlayer.Character:FindFirstChild('Humanoid')
        end
        if _Character then
            _Character.PlatformStand = false
        end

        u150()

        u136 = {
            F = 0,
            B = 0,
            L = 0,
            R = 0,
            Up = 0,
        }
    end
end
local function u161()
    local _ = u29.FlySpeed

    if not u17 then
        u17 = true

        local v153 = _LocalPlayer.Character or _LocalPlayer.CharacterAdded:Wait()
        local _HumanoidRootPart = v153:WaitForChild('HumanoidRootPart')

        v153:WaitForChild('Humanoid').PlatformStand = true
        u141 = Instance.new('BodyGyro')
        u142 = Instance.new('BodyVelocity')
        u141.P = 90000
        u141.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
        u141.CFrame = _HumanoidRootPart.CFrame
        u141.Parent = _HumanoidRootPart
        u142.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
        u142.Velocity = Vector3.new(0, 0, 0)
        u142.Parent = _HumanoidRootPart

        if u29.FlyNoClip then
            u149(v153)
        end

        u137 = _RunService.Heartbeat:Connect(function()
            local v155 = u136.F + u136.B == 0 and (u136.L + u136.R == 0 and u136.Up == 0) and 0 or (u29.FlySpeed or u18)

            u142.Velocity = (workspace.CurrentCamera.CFrame.LookVector * (u136.F + u136.B) + ((workspace.CurrentCamera.CFrame * CFrame.new(u136.L + u136.R, u136.Up, 0)).p - workspace.CurrentCamera.CFrame.p)) * v155
            u141.CFrame = workspace.CurrentCamera.CFrame
        end)
        u138 = u23.InputBegan:Connect(function(p156, p157)
            if not p157 then
                local _KeyCode = p156.KeyCode

                if _KeyCode ~= Enum.KeyCode.W then
                    if _KeyCode ~= Enum.KeyCode.S then
                        if _KeyCode ~= Enum.KeyCode.A then
                            if _KeyCode ~= Enum.KeyCode.D then
                                if _KeyCode == Enum.KeyCode.Space then
                                    u136.Up = 1
                                end
                            else
                                u136.R = 1
                            end
                        else
                            u136.L = -1
                        end
                    else
                        u136.B = -1
                    end
                else
                    u136.F = 1
                end
            end
        end)
        u139 = u23.InputEnded:Connect(function(p159)
            local _KeyCode2 = p159.KeyCode

            if _KeyCode2 ~= Enum.KeyCode.W then
                if _KeyCode2 ~= Enum.KeyCode.S then
                    if _KeyCode2 ~= Enum.KeyCode.A then
                        if _KeyCode2 ~= Enum.KeyCode.D then
                            if _KeyCode2 == Enum.KeyCode.Space then
                                u136.Up = 0
                            end
                        else
                            u136.R = 0
                        end
                    else
                        u136.L = 0
                    end
                else
                    u136.B = 0
                end
            else
                u136.F = 0
            end
        end)
    end
end

_LocalPlayer.CharacterAdded:Connect(function(_)
    u152()
end)

local function u169(p162)
    local v163 = _Players
    local v164, v165, v166 = ipairs(v163:GetPlayers())

    while true do
        local v167

        v166, v167 = v164(v165, v166)

        if v166 == nil then
            break
        end
        if v167 ~= _LocalPlayer and v167.Character and (v167.Character:FindFirstChild(p162) and (v167.Character:FindFirstChildOfClass('Humanoid') and v167.Character.Humanoid.Health > 0 and not v167.Character.HumanoidRootPart:FindFirstChild('TeammateLabel'))) then
            workspace:FindPartOnRayWithIgnoreList(Ray.new(_CurrentCamera.CFrame.Position, (v167.Character[p162].Position - _CurrentCamera.CFrame.Position).Unit * (v167.Character[p162].Position - _CurrentCamera.CFrame.Position).Magnitude), {
                _LocalPlayer.Character,
                _CurrentCamera,
            })

            local v168 = _CurrentCamera:WorldToViewportPoint(v167.Character[p162].Position)
            local _ = (Vector2.new(v168.X, v168.Y) - u22).Magnitude

            return v167
        end
    end
end
local function u188(p170)
    local v171 = p170 or 1

    if v171 > 3 then
        print('Max recursion reached, stopping.')

        return
    else
        u13 = true

        local _HitboxHead = u169('HitboxHead')

        if _HitboxHead and _HitboxHead.Character and (_HitboxHead.Character:FindFirstChild('HumanoidRootPart') and _HitboxHead.Character:FindFirstChild('Head')) then
            local _Character2 = _LocalPlayer.Character

            if _Character2 then
                _Character2 = _LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
            end

            local _HumanoidRootPart2 = _HitboxHead.Character.HumanoidRootPart

            if _Character2 and _HumanoidRootPart2 then
                local v175 = _HumanoidRootPart2.Position - _HumanoidRootPart2.CFrame.LookVector * 5

                _Character2.CFrame = CFrame.new(v175)

                local v176 = 0.2

                while _CurrentCamera:WorldToViewportPoint(_HitboxHead.Character.HitboxHead.Position).Z < 0 do
                    _VirtualInputManager:SendMouseMoveDeltaEvent(500, 0, game)
                    task.wait()
                end

                local v177 = _CurrentCamera:WorldToViewportPoint(_HitboxHead.Character.HitboxHead.Position)
                local v178 = Vector2.new(v177.X, v177.Y) - u12

                while(v176 < math.abs(v178.X) or v176 < math.abs(v178.Y)) and _CurrentCamera:WorldToViewportPoint(_HitboxHead.Character.HitboxHead.Position).Z > 0 do
                    _VirtualInputManager:SendMouseMoveDeltaEvent(v178.X * 0.5, v178.Y * 0.5, game)
                    task.wait()

                    local v179 = _CurrentCamera:WorldToViewportPoint(_HitboxHead.Character.HitboxHead.Position)

                    v178 = Vector2.new(v179.X, v179.Y) - u12
                end

                local function v182(p180)
                    local _LookVector = p180.LookVector

                    return math.atan2(_LookVector.X, _LookVector.Z)
                end

                local v183 = v182(_Character2.CFrame)
                local v184 = v182(_HumanoidRootPart2.CFrame)
                local v187 = (function(p185, p186)
                    return (p186 - p185 + 180) % 360 - 180
                end)(math.deg(v183), math.deg(v184))

                if math.abs(v187) > 30 then
                    u188(v171 + 1)
                end

                u13 = false
            end
        else
            return
        end
    end
end

local u189 = {
    MouseKeyboard = true,
    Gamepad = true,
    Touch = true,
    VR = true,
}

local function u191(p190)
    return u189[p190] == true
end
local function u196(p192, p193, p194)
    local v195 = p192:FindFirstChild(p194)

    if not v195 then
        v195 = Instance.new(p193)
        v195.Name = p194
        v195.Parent = p192
    end

    return v195
end
local function u201(p197)
    if u191(p197) then
        local v198 = u196(u196(u196(_ReplicatedStorage, 'Folder', 'Remotes'), 'Folder', 'Replication'), 'Folder', 'Fighter')
        local _SetControls = v198:FindFirstChild('SetControls')
        local v200

        if _SetControls then
            v200 = false
        else
            _SetControls = Instance.new('RemoteEvent')
            _SetControls.Name = 'SetControls'
            _SetControls.Parent = v198
            v200 = true
        end

        _SetControls:FireServer(p197)

        if v200 then
            _SetControls:Destroy()
        end
    end
end

local u202 = {}
local _ViewModels2 = _LocalPlayer.PlayerScripts.Assets.ViewModels
local u218 = {
    swapWeaponSkins = function(_, p204, p205, p206)
        if not p204 then
            return
        end

        local v207 = _ViewModels2:FindFirstChild('Weapons'):FindFirstChild(p204)

        if not v207 then
            return
        end
        if p206 then
            if p205 then
                local v208 = _ViewModels2
                local v209, v210, v211 = pairs(v208:GetDescendants())
                local v212 = nil

                while true do
                    local v213

                    v211, v213 = v209(v210, v211)

                    if v211 == nil then
                        v213 = v212

                        break
                    end
                    if v213:IsA('Model') and v213.Name == p205 then
                        break
                    end
                end

                if not v213 then
                    return
                end

                v207:ClearAllChildren()

                local v214, v215, v216 = pairs(v213:GetChildren())

                while true do
                    local v217

                    v216, v217 = v214(v215, v216)

                    if v216 == nil then
                        break
                    end

                    v217:Clone().Parent = v207
                end

                u202[p204] = true
            end
        else
            u202[p204] = nil
        end
    end,
}
local u219 = {}

local function u224(p220, p221, p222, p223)
    if p222 and p223 then
        if p221 then
            if p220 and not u219[p222] then
                u219[p222] = p220:Clone()

                p220:Destroy()
            end
        elseif u219[p222] and not p223:FindFirstChild(p222) then
            u219[p222]:Clone().Parent = p223
        end
    end
end
local function u227(p225)
    local _UserInterface = _LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('UserInterface')

    u224(_UserInterface:FindFirstChild('FlashbangGui'), p225, 'FlashbangGui', _UserInterface)
end
local function u230(p228)
    local _UserInterface2 = _LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('UserInterface')

    u224(_UserInterface2:FindFirstChild('paintballGui'), p228, 'paintballGui', _UserInterface2)
end
local function u236(p231)
    local _UserInterface3 = _LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('UserInterface')
    local _Misc = _LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets'):WaitForChild('Misc')
    local _SmokeClouds = _Misc:FindFirstChild('SmokeClouds')
    local _BlindedGui = _UserInterface3:FindFirstChild('BlindedGui')

    u224(_SmokeClouds, p231, 'SmokeClouds', _Misc)
    u224(_BlindedGui, p231, 'BlindedGui', _UserInterface3)
end

local u237 = {
    MainFrame = Color3.fromRGB(20, 20, 25),
    TopBar = Color3.fromRGB(25, 25, 30),
    Sidebar = Color3.fromRGB(30, 30, 35),
    ContentFrame = Color3.fromRGB(40, 40, 45),
    Button = Color3.fromRGB(50, 50, 55),
    ButtonHover = Color3.fromRGB(70, 70, 75),
    ButtonText = Color3.fromRGB(220, 220, 220),
    TitleText = Color3.fromRGB(255, 255, 255),
    CloseButton = Color3.fromRGB(180, 40, 40),
    ToggleOn = Color3.fromRGB(100, 180, 100),
    ToggleOff = Color3.fromRGB(220, 100, 100),
    ToggleCircle = Color3.fromRGB(255, 255, 255),
    Selected = Color3.fromRGB(0, 170, 255),
}
local u238 = 40
local _ScreenGui = Instance.new('ScreenGui')

_ScreenGui.Name = "Party's Rivals Mod"
_ScreenGui.ResetOnSpawn = false
_ScreenGui.Parent = _PlayerGui
_ScreenGui.DisplayOrder = 999

local _Frame = Instance.new('Frame')

_Frame.Size = UDim2.new(0, 600, 0, 400)
_Frame.Position = UDim2.new(0.5, -300, 0.5, -200)
_Frame.BackgroundColor3 = u237.MainFrame
_Frame.BorderSizePixel = 0
_Frame.Parent = _ScreenGui

local _UICorner = Instance.new('UICorner')

_UICorner.CornerRadius = UDim.new(0, 10)
_UICorner.Parent = _Frame

local _Frame2 = Instance.new('Frame')

_Frame2.Size = UDim2.new(1, 0, 0, 30)
_Frame2.BackgroundColor3 = u237.TopBar
_Frame2.BorderSizePixel = 0
_Frame2.Parent = _Frame;

(function(p243, p244)
    local u245 = false
    local u246 = nil
    local u247 = nil
    local u248 = nil

    local function u251(p249)
        local v250 = p249.Position - u247

        p244.Position = UDim2.new(u248.X.Scale, u248.X.Offset + v250.X, u248.Y.Scale, u248.Y.Offset + v250.Y)
    end

    p243.InputBegan:Connect(function(p252)
        if p252.UserInputType == Enum.UserInputType.MouseButton1 then
            u245 = true
            u247 = p252.Position
            u248 = p244.Position

            p252.Changed:Connect(function()
                if p252.UserInputState == Enum.UserInputState.End then
                    u245 = false
                end
            end)
        end
    end)
    p243.InputChanged:Connect(function(p253)
        if p253.UserInputType == Enum.UserInputType.MouseMovement then
            u246 = p253
        end
    end)
    u23.InputChanged:Connect(function(p254)
        if p254 == u246 and u245 then
            u251(p254)
        end
    end)
end)(_Frame2, _Frame)

local _UICorner2 = Instance.new('UICorner')

_UICorner2.CornerRadius = UDim.new(0, 10)
_UICorner2.Parent = _Frame2

local _TextLabel = Instance.new('TextLabel')

_TextLabel.Text = 'Party | Rivals Menu'
_TextLabel.TextColor3 = u237.TitleText
_TextLabel.Font = Enum.Font.GothamBold
_TextLabel.TextSize = 16
_TextLabel.BackgroundTransparency = 1
_TextLabel.Position = UDim2.new(0, 10, 0, 0)
_TextLabel.Size = UDim2.new(0, 200, 1, 0)
_TextLabel.TextXAlignment = Enum.TextXAlignment.Left
_TextLabel.Parent = _Frame2

local _TextButton = Instance.new('TextButton')

_TextButton.Text = 'X'
_TextButton.Font = Enum.Font.GothamBold
_TextButton.TextSize = 16
_TextButton.TextColor3 = u237.TitleText
_TextButton.BackgroundColor3 = u237.CloseButton
_TextButton.Size = UDim2.new(0, 30, 1, 0)
_TextButton.Position = UDim2.new(1, -35, 0, 0)
_TextButton.Parent = _Frame2

local _UICorner3 = Instance.new('UICorner')

_UICorner3.CornerRadius = UDim.new(0, 6)
_UICorner3.Parent = _TextButton

_TextButton.MouseButton1Click:Connect(function()
    _ScreenGui.Enabled = false
end)

local _Frame3 = Instance.new('Frame')

_Frame3.Size = UDim2.new(0, 160, 1, -30)
_Frame3.Position = UDim2.new(0, 0, 0, 30)
_Frame3.BackgroundColor3 = u237.Sidebar
_Frame3.BorderSizePixel = 0
_Frame3.Parent = _Frame

local _UIPadding = Instance.new('UIPadding')

_UIPadding.PaddingLeft = UDim.new(0, 10)
_UIPadding.PaddingTop = UDim.new(0, 10)
_UIPadding.Parent = _Frame3

local _UIListLayout = Instance.new('UIListLayout')

_UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
_UIListLayout.Padding = UDim.new(0, 8)
_UIListLayout.Parent = _Frame3

local _Frame4 = Instance.new('Frame')

_Frame4.Size = UDim2.new(1, -160, 1, -30)
_Frame4.Position = UDim2.new(0, 160, 0, 30)
_Frame4.BackgroundColor3 = u237.ContentFrame
_Frame4.BorderSizePixel = 0
_Frame4.Parent = _Frame

local v263 = {
    'Aimbot',
    'Visuals',
    'Player',
    'Teleport',
    'Useful Features',
    'Skin Changer',
    'Rage Mode',
}
local v264, v265, v266 = ipairs(v263)
local u267 = _ScreenGui
local u268 = u152
local u269 = u188
local u270 = {}

while true do
    local v271

    v266, v271 = v264(v265, v266)

    if v266 == nil then
        break
    end

    local _TextButton2 = Instance.new('TextButton')

    _TextButton2.Text = v271
    _TextButton2.Font = Enum.Font.Gotham
    _TextButton2.TextSize = 14
    _TextButton2.TextColor3 = u237.ButtonText
    _TextButton2.BackgroundColor3 = u237.Button
    _TextButton2.Size = UDim2.new(1, -10, 0, 30)
    _TextButton2.AutoButtonColor = false
    _TextButton2.TextXAlignment = Enum.TextXAlignment.Left
    _TextButton2.Parent = _Frame3

    local _UIPadding2 = Instance.new('UIPadding')

    _UIPadding2.PaddingLeft = UDim.new(0, 8)
    _UIPadding2.Parent = _TextButton2

    local _UICorner4 = Instance.new('UICorner')

    _UICorner4.CornerRadius = UDim.new(0, 6)
    _UICorner4.Parent = _TextButton2

    _TextButton2.MouseEnter:Connect(function()
        _TextButton2.BackgroundColor3 = u237.ButtonHover
    end)
    _TextButton2.MouseLeave:Connect(function()
        _TextButton2.BackgroundColor3 = u237.Button
    end)

    local _ScrollingFrame = Instance.new('ScrollingFrame')

    _ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    _ScrollingFrame.Position = UDim2.new(0, 0, 0, 0)
    _ScrollingFrame.BackgroundTransparency = 1
    _ScrollingFrame.Visible = false
    _ScrollingFrame.ScrollBarThickness = 8
    _ScrollingFrame.ScrollBarImageColor3 = u237.ButtonHover
    _ScrollingFrame.Parent = _Frame4

    local _UIListLayout2 = Instance.new('UIListLayout')

    _UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
    _UIListLayout2.Padding = UDim.new(0, 10)
    _UIListLayout2.Parent = _ScrollingFrame

    local _UIPadding3 = Instance.new('UIPadding')

    _UIPadding3.PaddingTop = UDim.new(0, 10)
    _UIPadding3.PaddingBottom = UDim.new(0, 10)
    _UIPadding3.PaddingLeft = UDim.new(0, 10)
    _UIPadding3.PaddingRight = UDim.new(0, 10)
    _UIPadding3.Parent = _ScrollingFrame
    u270[v271] = _ScrollingFrame
    _ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, _UIListLayout2.AbsoluteContentSize.Y + u238)

    local v278 = _UIListLayout2

    _UIListLayout2.GetPropertyChangedSignal(v278, 'AbsoluteContentSize'):Connect(function()
        _ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, _UIListLayout2.AbsoluteContentSize.Y + u238)
    end)

    local _TextLabel2 = Instance.new('TextLabel')

    _TextLabel2.Text = v271 .. ' Settings'
    _TextLabel2.TextColor3 = u237.TitleText
    _TextLabel2.Font = Enum.Font.Gotham
    _TextLabel2.TextSize = 18
    _TextLabel2.BackgroundColor3 = u237.Button
    _TextLabel2.Size = UDim2.new(1, 0, 0, u238)
    _TextLabel2.Position = UDim2.new(0, 0, 0, 0)
    _TextLabel2.Parent = _ScrollingFrame

    local _UICorner5 = Instance.new('UICorner')

    _UICorner5.CornerRadius = UDim.new(0, 6)
    _UICorner5.Parent = _TextLabel2

    _TextButton2.MouseButton1Click:Connect(function()
        local v281, v282, v283 = pairs(u270)

        while true do
            local v284

            v283, v284 = v281(v282, v283)

            if v283 == nil then
                break
            end

            v284.Visible = false
        end

        _ScrollingFrame.Visible = true
    end)
end

local function u299(p285, p286, p287, p288, p289)
    local _Frame5 = Instance.new('Frame')

    _Frame5.Size = UDim2.new(1, -20, 0, 40)
    _Frame5.Position = p287 or UDim2.new(0, 0, 0, 0)
    _Frame5.BackgroundColor3 = u237.Button
    _Frame5.BorderSizePixel = 0
    _Frame5.Parent = p285

    local _UICorner6 = Instance.new('UICorner')

    _UICorner6.CornerRadius = UDim.new(0, 6)
    _UICorner6.Parent = _Frame5

    local _TextLabel3 = Instance.new('TextLabel')

    _TextLabel3.Text = p286
    _TextLabel3.Font = Enum.Font.Gotham
    _TextLabel3.TextSize = 14
    _TextLabel3.TextColor3 = u237.ButtonText
    _TextLabel3.BackgroundTransparency = 1
    _TextLabel3.Size = UDim2.new(0.6, 0, 1, 0)
    _TextLabel3.Position = UDim2.new(0, 10, 0, 0)
    _TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
    _TextLabel3.Parent = _Frame5

    local _Frame6 = Instance.new('Frame')

    _Frame6.Size = UDim2.new(0, 50, 0, 25)
    _Frame6.Position = UDim2.new(1, -60, 0, (_Frame5.Size.Y.Offset - _Frame6.Size.Y.Offset) / 2)
    _Frame6.BackgroundColor3 = p288 and u237.ToggleOn or u237.ToggleOff
    _Frame6.BorderSizePixel = 0
    _Frame6.Parent = _Frame5

    local _UICorner7 = Instance.new('UICorner')

    _UICorner7.CornerRadius = UDim.new(0, 12)
    _UICorner7.Parent = _Frame6

    local _Frame7 = Instance.new('Frame')

    _Frame7.Size = UDim2.new(0, 22, 0, 22)
    _Frame7.Position = p288 and UDim2.new(1, -22, 0, (_Frame6.Size.Y.Offset - _Frame7.Size.Y.Offset) / 2) or UDim2.new(0, 1, 0, (_Frame6.Size.Y.Offset - _Frame7.Size.Y.Offset) / 2)
    _Frame7.BackgroundColor3 = u237.ToggleCircle
    _Frame7.BorderSizePixel = 0
    _Frame7.Parent = _Frame6

    local _UICorner8 = Instance.new('UICorner')

    _UICorner8.CornerRadius = UDim.new(1, 0)
    _UICorner8.Parent = _Frame7

    local u297 = p288

    _Frame5.InputBegan:Connect(function(p298)
        if p298.UserInputType == Enum.UserInputType.MouseButton1 then
            u297 = not u297
            _Frame6.BackgroundColor3 = u297 and u237.ToggleOn or u237.ToggleOff
            _Frame7.Position = u297 and UDim2.new(1, -22, 0, 1) or UDim2.new(0, 1, 0, 1)

            p289(u297)
        end
    end)

    return _Frame5
end
local function v309(p300, p301)
    local _Frame8 = Instance.new('Frame')

    _Frame8.Size = UDim2.new(1, -20, 0, 0)

    local _UIListLayout3 = Instance.new('UIListLayout')

    _UIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
    _UIListLayout3.Padding = UDim.new(0, 10)
    _UIListLayout3.Parent = _Frame8

    local v304 = _UIListLayout3

    _UIListLayout3.GetPropertyChangedSignal(v304, 'AbsoluteContentSize'):Connect(function()
        _Frame8.Size = UDim2.new(1, -20, 0, _UIListLayout3.AbsoluteContentSize.Y + 10)
    end)

    _Frame8.BackgroundColor3 = u237.ContentFrame
    _Frame8.BorderSizePixel = 0
    _Frame8.Parent = p300

    local _UICorner9 = Instance.new('UICorner')

    _UICorner9.CornerRadius = UDim.new(0, 6)
    _UICorner9.Parent = _Frame8

    local _TextLabel4 = Instance.new('TextLabel')

    _TextLabel4.Text = p301
    _TextLabel4.Font = Enum.Font.GothamBold
    _TextLabel4.TextSize = 16
    _TextLabel4.TextColor3 = u237.TitleText
    _TextLabel4.BackgroundTransparency = 1
    _TextLabel4.Size = UDim2.new(1, -20, 0, 0)
    _TextLabel4.Position = UDim2.new(0, 10, 0, 0)
    _TextLabel4.TextXAlignment = Enum.TextXAlignment.Left
    _TextLabel4.Parent = _Frame8

    local _UIListLayout4 = Instance.new('UIListLayout')

    _UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
    _UIListLayout4.Padding = UDim.new(0, 10)
    _UIListLayout4.Parent = _Frame8

    local _UIPadding4 = Instance.new('UIPadding')

    _UIPadding4.PaddingTop = UDim.new(0, 15)
    _UIPadding4.PaddingLeft = UDim.new(0, 10)
    _UIPadding4.PaddingRight = UDim.new(0, 10)
    _UIPadding4.PaddingBottom = UDim.new(0, 15)
    _UIPadding4.Parent = _Frame8

    _UIListLayout4:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        p300.CanvasSize = UDim2.new(0, 0, 0, p300.UIListLayout.AbsoluteContentSize.Y)
    end)

    return _Frame8
end

u270[v263[1] ].Visible = true

local _Aimbot = u270.Aimbot
local _Visuals = u270.Visuals
local _Player = u270.Player
local _Teleport = u270.Teleport
local _UsefulFeatures = u270['Useful Features']
local _SkinChanger = u270['Skin Changer']
local _RageMode = u270['Rage Mode']
local _ = u238 + 10
local v317 = v309(_SkinChanger, 'Change Skin')

v317.LayoutOrder = 1

local function u322(p318, p319)
    local _TextButton3 = Instance.new('TextButton')

    _TextButton3.Size = UDim2.new(1, 0, 0, 30)
    _TextButton3.BackgroundColor3 = u237.Button
    _TextButton3.BorderSizePixel = 0
    _TextButton3.Text = p319
    _TextButton3.TextColor3 = u237.ButtonText
    _TextButton3.TextScaled = true
    _TextButton3.Parent = p318

    local _UICorner10 = Instance.new('UICorner')

    _UICorner10.CornerRadius = UDim.new(0, 6)
    _UICorner10.Parent = _TextButton3

    return _TextButton3
end
local function u347(p323, p324, p325, p326, p327, p328)
    local _Frame9 = Instance.new('Frame')

    _Frame9.Size = UDim2.new(1, 0, 0, #p324 * 35)
    _Frame9.BackgroundColor3 = u237.ContentFrame
    _Frame9.BorderSizePixel = 0
    _Frame9.Parent = p323

    local v330, v331, v332 = ipairs(p324)
    local u333 = nil

    while true do
        local u334

        v332, u334 = v330(v331, v332)

        if v332 == nil then
            break
        end

        local _TextButton4 = Instance.new('TextButton')

        _TextButton4.Size = UDim2.new(1, -10, 0, 30)
        _TextButton4.Position = UDim2.new(0, 5, 0, (v332 - 1) * 35 + 2.5)
        _TextButton4.BackgroundColor3 = u237.Button
        _TextButton4.BorderSizePixel = 0
        _TextButton4.TextColor3 = u237.ButtonText
        _TextButton4.Text = u334
        _TextButton4.TextScaled = true
        _TextButton4.Parent = _Frame9
        _TextButton4.AutoButtonColor = false

        if p326 and u334 == p326 then
            _TextButton4.BackgroundColor3 = u237.Selected
            u333 = _TextButton4
        end

        _TextButton4.MouseEnter:Connect(function()
            if _TextButton4 ~= u333 then
                _TextButton4.BackgroundColor3 = u237.ButtonHover
            end
        end)
        _TextButton4.MouseLeave:Connect(function()
            if _TextButton4 ~= u333 then
                _TextButton4.BackgroundColor3 = u237.Button
            end
        end)
        _TextButton4.MouseButton1Click:Connect(function()
            if u333 then
                u333.BackgroundColor3 = u237.Button
            end

            u333 = _TextButton4
            _TextButton4.BackgroundColor3 = u237.Selected

            p325(u334)
        end)
    end

    _Frame9:GetPropertyChangedSignal('Visible'):Connect(function()
        if _Frame9.Visible then
            local v336 = nil

            if p328 ~= 'Regular' then
                if p328 == 'Custom' then
                    v336 = u29.CustomSkinSettings[p327]
                end
            else
                v336 = u29.WeaponSkinSettings[p327]
            end
            if v336 then
                u333 = nil

                local v337 = _Frame9
                local v338, v339, v340 = ipairs(v337:GetChildren())

                while true do
                    local v341

                    v340, v341 = v338(v339, v340)

                    if v340 == nil then
                        break
                    end
                    if v341:IsA('TextButton') then
                        if v341.Text == v336 then
                            v341.BackgroundColor3 = u237.Selected
                            u333 = v341
                        else
                            v341.BackgroundColor3 = u237.Button
                        end
                    end
                end
            else
                u333 = nil

                local v342 = _Frame9
                local v343, v344, v345 = ipairs(v342:GetChildren())

                while true do
                    local v346

                    v345, v346 = v343(v344, v345)

                    if v345 == nil then
                        break
                    end
                    if v346:IsA('TextButton') then
                        v346.BackgroundColor3 = u237.Button
                    end
                end
            end
        end
    end)

    return _Frame9
end
local function v359(p348, p349, p350, p351)
    local v352 = u29.WeaponSkinSettings[p349]
    local u354 = u347(p348, p350, function(p353)
        u218:swapWeaponSkins(p349, p353, true)

        u29.WeaponSkinSettings[p349] = p353

        u32()
    end, v352, p349, 'Regular')

    u354.Name = p349 .. 'SkinDropdown'
    u354.LayoutOrder = p351 * 3 + 3
    u354.Visible = false

    local u355 = u322(p348, 'Show/Hide ' .. p349 .. ' Skins')

    u355.LayoutOrder = p351 * 3 + 2
    u355.Visible = false

    u355.MouseButton1Click:Connect(function()
        u354.Visible = not u354.Visible
    end)

    local v358 = u299(p348, 'Choose ' .. p349 .. ' Skin', nil, v352 ~= nil, function(p356)
        if p356 then
            u355.Visible = true
            u354.Visible = true

            local v357 = u29.WeaponSkinSettings[p349]

            if v357 then
                u218:swapWeaponSkins(p349, v357, true)
            end
        else
            u355.Visible = false
            u354.Visible = false

            u218:swapWeaponSkins(p349, nil, false)

            if u29.WeaponSkinSettings[p349] then
                u29.WeaponSkinSettings[p349] = nil

                u32()
            end
        end
    end)

    v358.LayoutOrder = p351 * 3 + 1

    if v352 then
        u355.Visible = true
        u354.Visible = false

        u218:swapWeaponSkins(p349, v352, true)
    end

    return {
        toggle = v358,
        showHide = u355,
        dropdown = u354,
    }
end

local v360, v361, v362 = pairs(v54)
local u363 = u322
local u364 = u299
local u365 = u347
local v366 = {}
local v367 = 0
local v368 = {}

while true do
    v362 = v360(v361, v362)

    if v362 == nil then
        break
    end

    table.insert(v366, v362)
end

table.sort(v366, function(p369, p370)
    return p369:lower() < p370:lower()
end)

local v371, v372, v373 = ipairs(v366)

while true do
    local v374

    v373, v374 = v371(v372, v373)

    if v373 == nil then
        break
    end

    local v375 = v54[v374]

    table.sort(v375, function(p376, p377)
        return p376:lower() < p377:lower()
    end)

    v368[v374] = v359(v317, v374, v375, v367)
    v367 = v367 + 1
end

local v378 = v309(_SkinChanger, 'Change Wrap')

v378.LayoutOrder = 2

local v379, v380, v381 = pairs(_AssaultRifleWrapData.AssaultRifle)
local v382 = {}

while true do
    v381 = v379(v380, v381)

    if v381 == nil then
        break
    end

    table.insert(v382, v381)
end

table.sort(v382, function(p383, p384)
    return p383:lower() < p384:lower()
end)

local function v397(p385, p386, p387, p388)
    local _Frame10 = Instance.new('Frame')

    _Frame10.Size = UDim2.new(1, 0, 0, #p386 * 35)
    _Frame10.BackgroundColor3 = u237.ContentFrame
    _Frame10.BorderSizePixel = 0
    _Frame10.Parent = p385

    local v390, v391, v392 = ipairs(p386)
    local u393 = nil

    while true do
        local v394

        v392, v394 = v390(v391, v392)

        if v392 == nil then
            break
        end

        local _TextButton5 = Instance.new('TextButton')
        local u396 = v394

        _TextButton5.Size = UDim2.new(1, -10, 0, 30)
        _TextButton5.Position = UDim2.new(0, 5, 0, (v392 - 1) * 35 + 2.5)
        _TextButton5.BackgroundColor3 = u237.Button
        _TextButton5.BorderSizePixel = 0
        _TextButton5.TextColor3 = u237.ButtonText
        _TextButton5.Text = v394
        _TextButton5.TextScaled = true
        _TextButton5.Parent = _Frame10
        _TextButton5.AutoButtonColor = false

        if p388 and v394 == p388 then
            _TextButton5.BackgroundColor3 = u237.Selected
            u393 = _TextButton5
        end

        _TextButton5.MouseEnter:Connect(function()
            if _TextButton5 ~= u393 then
                _TextButton5.BackgroundColor3 = u237.ButtonHover
            end
        end)
        _TextButton5.MouseLeave:Connect(function()
            if _TextButton5 ~= u393 then
                _TextButton5.BackgroundColor3 = u237.Button
            end
        end)
        _TextButton5.MouseButton1Click:Connect(function()
            if u393 then
                u393.BackgroundColor3 = u237.Button
            end

            u393 = _TextButton5
            _TextButton5.BackgroundColor3 = u237.Selected

            p387(u396)
        end)
    end

    return _Frame10
end

u29.WeaponWrapSettings = u29.WeaponWrapSettings or {}

local _AssaultRifle = u29.WeaponWrapSettings['Assault Rifle']
local u401 = v397(v378, v382, function(p399)
    local v400

    if u29.WeaponSkinSettings['Assault Rifle'] ~= 'AK-47' then
        v400 = _AssaultRifleWrapData.AssaultRifle[p399]
    else
        v400 = _AssaultRifleWrapData.AK47[p399]
    end

    u97(v400, 'Assault Rifle')

    u29.WeaponWrapSettings['Assault Rifle'] = p399

    u32()
end, _AssaultRifle)

u401.Name = 'AssaultRifleWrapDropdown'
u401.LayoutOrder = 3
u401.Visible = false

local u402 = u363(v378, 'Show/Hide Assault Rifle Wraps')

u402.LayoutOrder = 2
u402.Visible = false

u402.MouseButton1Click:Connect(function()
    u401.Visible = not u401.Visible
end)

u364(v378, 'Custom Assault Rifle Wrap', nil, _AssaultRifle ~= nil, function(p403)
    if p403 then
        u402.Visible = true
        u401.Visible = true

        if _AssaultRifle then
            local v404

            if u29.WeaponSkinSettings['Assault Rifle'] ~= 'AK-47' then
                v404 = _AssaultRifleWrapData.AssaultRifle[_AssaultRifle]
            else
                v404 = _AssaultRifleWrapData.AK47[_AssaultRifle]
            end

            u97(v404, 'Assault Rifle')
        end
    else
        u402.Visible = false
        u401.Visible = false

        u97(nil)

        if u29.WeaponWrapSettings['Assault Rifle'] then
            u29.WeaponWrapSettings['Assault Rifle'] = nil

            u32()
        end
    end
end).LayoutOrder = 1

if _AssaultRifle then
    u402.Visible = true
    u401.Visible = false

    local v405

    if u29.WeaponSkinSettings['Assault Rifle'] ~= 'AK-47' then
        v405 = _AssaultRifleWrapData.AssaultRifle[_AssaultRifle]
    else
        v405 = _AssaultRifleWrapData.AK47[_AssaultRifle]
    end

    u97(v405, 'Assault Rifle')
end

local v406, v407, v408 = pairs(_HandgunWrapData.Handgun)
local v409 = {}

while true do
    v408 = v406(v407, v408)

    if v408 == nil then
        break
    end

    table.insert(v409, v408)
end

table.sort(v409, function(p410, p411)
    return p410:lower() < p411:lower()
end)

local _Handgun = u29.WeaponWrapSettings.Handgun
local u415 = v397(v378, v409, function(p413)
    local v414

    if u29.WeaponSkinSettings.Handgun ~= 'Placeholder' then
        v414 = _HandgunWrapData.Handgun[p413]
    else
        v414 = _HandgunWrapData.DesertEagle[p413]
    end

    u97(v414, 'Handgun')

    u29.WeaponWrapSettings.Handgun = p413

    u32()
end, _Handgun)

u415.Name = 'HandgunWrapDropdown'
u415.LayoutOrder = 6
u415.Visible = false

local u416 = u363(v378, 'Show/Hide Handgun Wraps')

u416.LayoutOrder = 5
u416.Visible = false

u416.MouseButton1Click:Connect(function()
    u415.Visible = not u415.Visible
end)

u364(v378, 'Custom Handgun Wrap', nil, _Handgun ~= nil, function(p417)
    if p417 then
        u416.Visible = true
        u415.Visible = true

        if _Handgun then
            local v418

            if u29.WeaponSkinSettings.Handgun ~= 'Placeholder' then
                v418 = _HandgunWrapData.Handgun[_Handgun]
            else
                v418 = _HandgunWrapData.DesertEagle[_Handgun]
            end

            u97(v418, 'Handgun')
        end
    else
        u416.Visible = false
        u415.Visible = false

        u97(nil)

        if u29.WeaponWrapSettings.Handgun then
            u29.WeaponWrapSettings.Handgun = nil

            u32()
        end
    end
end).LayoutOrder = 4

if _Handgun then
    u416.Visible = true
    u415.Visible = false

    local v419

    if u29.WeaponSkinSettings.Handgun ~= 'Placeholder' then
        v419 = _HandgunWrapData.Handgun[_Handgun]
    else
        v419 = _HandgunWrapData.DesertEagle[_Handgun]
    end

    u97(v419, 'Handgun')
end

local v420, v421, v422 = pairs(_FistsWrapData.Fists)
local v423 = {}

while true do
    v422 = v420(v421, v422)

    if v422 == nil then
        break
    end

    table.insert(v423, v422)
end

table.sort(v423, function(p424, p425)
    return p424:lower() < p425:lower()
end)

local _Fists = u29.WeaponWrapSettings.Fists
local u429 = v397(v378, v423, function(p427)
    local v428

    if u29.WeaponSkinSettings.Fists ~= 'Placeholder' then
        v428 = _FistsWrapData.Fists[p427]
    else
        v428 = _FistsWrapData.SpecialVariant[p427]
    end

    u97(v428, 'Fists')

    u29.WeaponWrapSettings.Fists = p427

    u32()
end, _Fists)

u429.Name = 'FistsWrapDropdown'
u429.LayoutOrder = 9
u429.Visible = false

local u430 = u363(v378, 'Show/Hide Fists Wraps')

u430.LayoutOrder = 8
u430.Visible = false

u430.MouseButton1Click:Connect(function()
    u429.Visible = not u429.Visible
end)

u364(v378, 'Custom Fists Wrap', nil, _Fists ~= nil, function(p431)
    if p431 then
        u430.Visible = true
        u429.Visible = true

        if _Fists then
            local v432

            if u29.WeaponSkinSettings.Fists ~= 'Placeholder' then
                v432 = _FistsWrapData.Fists[_Fists]
            else
                v432 = _FistsWrapData.SpecialVariant[_Fists]
            end

            u97(v432, 'Fists')
        end
    else
        u430.Visible = false
        u429.Visible = false

        u97(nil, 'Fists')

        if u29.WeaponWrapSettings.Fists then
            u29.WeaponWrapSettings.Fists = nil

            u32()
        end
    end
end).LayoutOrder = 7

if _Fists then
    u430.Visible = true
    u429.Visible = false

    local v433

    if u29.WeaponSkinSettings.Fists ~= 'Placeholder' then
        v433 = _FistsWrapData.Fists[_Fists]
    else
        v433 = _FistsWrapData.SpecialVariant[_Fists]
    end

    u97(v433, 'Fists')
end

local v434 = v309(_SkinChanger, 'Change Custom Skin')

v434.LayoutOrder = 3

local function u449(p435, p436)
    if p435 and p435:IsA('BasePart') then
        local v437, v438, v439

        if p435.Name ~= 'LeftItem' then
            if p435.Name ~= 'RightItem' then
                warn('Not a valid target.')

                return
            end

            v437 = p436.RightMeshRotation
            v438 = p436.RightMeshId
            v439 = p436.RightTextureId
        else
            v437 = p436.LeftMeshRotation
            v438 = p436.LeftMeshId
            v439 = p436.LeftTextureId
        end

        local v440, v441, v442 = ipairs(p435:GetChildren())

        while true do
            local v443

            v442, v443 = v440(v441, v442)

            if v442 == nil then
                break
            end

            v443:Destroy()
        end

        local _Part = Instance.new('Part')

        _Part.Size = p435.Size
        _Part.CFrame = p435.CFrame * v437
        _Part.Anchored = false
        _Part.CanCollide = false
        _Part.Parent = p435

        local _SpecialMesh = Instance.new('SpecialMesh')

        _SpecialMesh.MeshId = v438
        _SpecialMesh.MeshType = p436.meshType
        _SpecialMesh.TextureId = v439
        _SpecialMesh.Scale = p436.meshScale
        _SpecialMesh.Parent = _Part

        local _Attachment = Instance.new('Attachment')

        _Attachment.Name = 'TargetAttachment'
        _Attachment.Parent = p435

        local _Attachment2 = Instance.new('Attachment')

        _Attachment2.Name = 'MeshAttachment'
        _Attachment2.Parent = _Part

        local _WeldConstraint = Instance.new('WeldConstraint')

        _WeldConstraint.Part0 = p435
        _WeldConstraint.Part1 = _Part
        _WeldConstraint.Parent = _Part
    else
        warn('Target part not found or is not a BasePart!')
    end
end

local u450 = nil

local function u458(p451)
    local function u455(p452)
        local _LeftItem = p452:FindFirstChild('LeftItem')
        local _RightItem = p452:FindFirstChild('RightItem')

        if _LeftItem and _RightItem then
            u449(_LeftItem, p451)
            u449(_RightItem, p451)
        else
            warn('Fist parts not found in model!')
        end
    end

    if u450 then
        u450:Disconnect()

        u450 = nil
    end

    local v456 = workspace.ViewModels.FirstPerson:FindFirstChild(_LocalPlayer.Name .. ' - Fists - Fists')

    if v456 then
        u455(v456)
    end

    u450 = workspace.ViewModels.FirstPerson.ChildAdded:Connect(function(p457)
        if p457.Name == _LocalPlayer.Name .. ' - Fists - Fists' then
            u455(p457)
        end
    end)
end
local function v473(p459, p460, p461, p462)
    u29.CustomSkinSettings = u29.CustomSkinSettings or {}

    local v463 = u29.CustomSkinSettings[p460]
    local u466 = u365(p459, p461, function(p464)
        u29.CustomSkinSettings[p460] = p464

        u32()

        local v465 = u34[p460]

        if v465 then
            v465 = u34[p460][p464]
        end
        if v465 then
            u458(v465)
        end
    end, v463, p460, 'Custom')

    u466.Name = p460 .. 'CustomSkinDropdown'
    u466.LayoutOrder = p462 * 3 + 3
    u466.Visible = false

    local u467 = u363(p459, 'Show/Hide ' .. p460 .. ' Skins')

    u467.LayoutOrder = p462 * 3 + 2
    u467.Visible = false

    u467.MouseButton1Click:Connect(function()
        u466.Visible = not u466.Visible
    end)

    local v471 = u364(p459, 'Custom ' .. p460 .. ' Skin', nil, v463 ~= nil, function(p468)
        if p468 then
            u467.Visible = true
            u466.Visible = true

            local v469 = u29.CustomSkinSettings[p460]

            if v469 then
                local v470 = u34[p460]

                if v470 then
                    v470 = u34[p460][v469]
                end
                if v470 then
                    u458(v470)
                end
            end
        else
            u467.Visible = false
            u466.Visible = false
            u29.CustomSkinSettings[p460] = nil

            u32()
        end
    end)

    v471.LayoutOrder = p462 * 3 + 1

    if v463 then
        local v472 = u34[p460]

        if v472 then
            v472 = u34[p460][v463]
        end
        if v472 then
            u467.Visible = true
            u466.Visible = false

            u458(v472)
        end
    end

    return {
        toggle = v471,
        showHide = u467,
        dropdown = u466,
    }
end

local v474, v475, v476 = pairs(u34)
local v477 = {}
local v478 = 0
local v479 = {}

while true do
    v476 = v474(v475, v476)

    if v476 == nil then
        break
    end

    table.insert(v477, v476)
end

table.sort(v477, function(p480, p481)
    return p480:lower() < p481:lower()
end)

local v482, v483, v484 = ipairs(v477)

while true do
    local v485

    v484, v485 = v482(v483, v484)

    if v484 == nil then
        break
    end

    local v486, v487, v488 = pairs(u34[v485])
    local v489 = {}

    while true do
        v488 = v486(v487, v488)

        if v488 == nil then
            break
        end

        table.insert(v489, v488)
    end

    table.sort(v489, function(p490, p491)
        return p490:lower() < p491:lower()
    end)

    v479[v485] = v473(v434, v485, v489, v478)
    v478 = v478 + 1
end

local v492 = v309(_Player, 'Fly Settings')

v492.LayoutOrder = 1
u29.FlyEnabled = u29.FlyEnabled or false
u29.FlyKeybind = u29.FlyKeybind or 'P'
u29.FlySpeed = u29.FlySpeed or u18
u29.FlyNoClip = u29.FlyNoClip or false

local _Frame11 = Instance.new('Frame')

_Frame11.Size = UDim2.new(1, 0, 0, 30)
_Frame11.BackgroundTransparency = 1
_Frame11.Parent = v492
_Frame11.LayoutOrder = 3
_Frame11.Visible = u29.FlyEnabled

local _TextLabel5 = Instance.new('TextLabel')

_TextLabel5.Size = UDim2.new(0.6, 0, 1, 0)
_TextLabel5.BackgroundTransparency = 1
_TextLabel5.Text = 'Fly Speed:'
_TextLabel5.TextColor3 = u237.ButtonText
_TextLabel5.Font = Enum.Font.SourceSans
_TextLabel5.TextSize = 18
_TextLabel5.TextXAlignment = Enum.TextXAlignment.Left
_TextLabel5.Parent = _Frame11

local _TextBox = Instance.new('TextBox')

_TextBox.Size = UDim2.new(0.4, -5, 1, 0)
_TextBox.Position = UDim2.new(0.6, 5, 0, 0)
_TextBox.BackgroundColor3 = u237.Button
_TextBox.TextColor3 = u237.ButtonText
_TextBox.Font = Enum.Font.SourceSans
_TextBox.TextSize = 16
_TextBox.ClearTextOnFocus = false
_TextBox.PlaceholderText = tostring(u18)
_TextBox.Text = tostring(u29.FlySpeed) or tostring(u18)
_TextBox.Parent = _Frame11

_TextBox.FocusLost:Connect(function(_)
    local v496 = tonumber(_TextBox.Text)

    if v496 and v496 > 0 then
        if u19 < v496 then
            v496 = u19
        end
    else
        v496 = u18
    end

    u29.FlySpeed = v496
    _TextBox.Text = tostring(v496)

    u32()
end)

local _Frame12 = Instance.new('Frame')

_Frame12.Size = UDim2.new(1, 0, 0, 30)
_Frame12.BackgroundTransparency = 1
_Frame12.Parent = v492
_Frame12.LayoutOrder = 2
_Frame12.Visible = u29.FlyEnabled

local _TextLabel6 = Instance.new('TextLabel')

_TextLabel6.Size = UDim2.new(0.6, 0, 1, 0)
_TextLabel6.BackgroundTransparency = 1
_TextLabel6.Text = 'Enter Fly Keybind:'
_TextLabel6.TextColor3 = u237.ButtonText
_TextLabel6.Font = Enum.Font.SourceSans
_TextLabel6.TextSize = 18
_TextLabel6.TextXAlignment = Enum.TextXAlignment.Left
_TextLabel6.Parent = _Frame12

local _TextBox2 = Instance.new('TextBox')

_TextBox2.Size = UDim2.new(0.4, -5, 1, 0)
_TextBox2.Position = UDim2.new(0.6, 5, 0, 0)
_TextBox2.BackgroundColor3 = u237.Button
_TextBox2.TextColor3 = u237.ButtonText
_TextBox2.Font = Enum.Font.SourceSans
_TextBox2.TextSize = 16
_TextBox2.ClearTextOnFocus = false
_TextBox2.PlaceholderText = 'P'
_TextBox2.Text = tostring(u29.FlyKeybind)
_TextBox2.Parent = _Frame12

local u500 = nil

local function u504(p501)
    if u500 then
        u500:Disconnect()

        u500 = nil
    end
    if u29.FlyEnabled then
        u500 = u23.InputBegan:Connect(function(p502, p503)
            if not p503 and (p502.UserInputType == Enum.UserInputType.Keyboard and p502.KeyCode.Name == p501) then
                if u17 then
                    u268()
                else
                    u161()
                end
            end
        end)
    end
end

u504(u29.FlyKeybind)

local u505 = false
local u506 = nil

_TextBox2.Focused:Connect(function()
    if not u505 then
        u505 = true
        _TextBox2.Text = 'Press any key...'
        u506 = u23.InputBegan:Connect(function(p507, _)
            if p507.UserInputType == Enum.UserInputType.Keyboard then
                local _Name = p507.KeyCode.Name

                u29.FlyKeybind = _Name
                _TextBox2.Text = _Name

                u32()
                u504(_Name)

                u505 = false

                if u506 then
                    u506:Disconnect()

                    u506 = nil
                end

                _TextBox2:ReleaseFocus()
            end
        end)
    end
end)

local u510 = u364(v492, 'No Clip While Flying', nil, u29.FlyNoClip, function(p509)
    u29.FlyNoClip = p509

    u32()
end)

u510.LayoutOrder = 4
u510.Visible = u29.FlyEnabled
u364(v492, 'Enable Fly', nil, u29.FlyEnabled, function(p511)
    u29.FlyEnabled = p511

    u32()

    _Frame11.Visible = p511
    _Frame12.Visible = p511
    u510.Visible = p511

    u504(u29.FlyKeybind)
end).LayoutOrder = 1

local v512 = v309(_Teleport, 'Player Teleport')

v512.LayoutOrder = 1
u29.EnableTeleportBehindPlayer = u29.EnableTeleportBehindPlayer or false
u29.TeleportBehindPlayerKeybind = u29.TeleportBehindPlayerKeybind or 'T'

local _Frame13 = Instance.new('Frame')

_Frame13.Size = UDim2.new(1, 0, 0, 30)
_Frame13.BackgroundTransparency = 1
_Frame13.Parent = v512
_Frame13.LayoutOrder = 3
_Frame13.Visible = u29.EnableTeleportBehindPlayer

local _TextLabel7 = Instance.new('TextLabel')

_TextLabel7.Size = UDim2.new(0.6, 0, 1, 0)
_TextLabel7.BackgroundTransparency = 1
_TextLabel7.Text = 'Enter Teleport Keybind:'
_TextLabel7.TextColor3 = u237.ButtonText
_TextLabel7.Font = Enum.Font.SourceSans
_TextLabel7.TextSize = 18
_TextLabel7.TextXAlignment = Enum.TextXAlignment.Left
_TextLabel7.Parent = _Frame13

local _TextBox3 = Instance.new('TextBox')

_TextBox3.Size = UDim2.new(0.4, -5, 1, 0)
_TextBox3.Position = UDim2.new(0.6, 5, 0, 0)
_TextBox3.BackgroundColor3 = u237.Button
_TextBox3.TextColor3 = u237.ButtonText
_TextBox3.Font = Enum.Font.SourceSans
_TextBox3.TextSize = 16
_TextBox3.ClearTextOnFocus = false
_TextBox3.PlaceholderText = 'T'
_TextBox3.Text = tostring(u29.TeleportBehindPlayerKeybind)
_TextBox3.Parent = _Frame13

local u516 = nil

local function u520(p517)
    if u516 then
        u516:Disconnect()

        u516 = nil
    end
    if u29.EnableTeleportBehindPlayer then
        u516 = u23.InputBegan:Connect(function(p518, p519)
            if not p519 and (p518.UserInputType == Enum.UserInputType.Keyboard and (p518.KeyCode.Name == p517 and u13 == false)) then
                u269()
            end
        end)
    end
end

u520(u29.TeleportBehindPlayerKeybind)

local u521 = false
local u522 = nil

_TextBox3.Focused:Connect(function()
    if not u521 then
        u521 = true
        _TextBox3.Text = 'Press any key...'
        u522 = u23.InputBegan:Connect(function(p523, _)
            if p523.UserInputType == Enum.UserInputType.Keyboard then
                local _Name2 = p523.KeyCode.Name

                u29.TeleportBehindPlayerKeybind = _Name2
                _TextBox3.Text = _Name2

                u32()
                u520(_Name2)

                u521 = false

                if u522 then
                    u522:Disconnect()

                    u522 = nil
                end

                _TextBox3:ReleaseFocus()
            end
        end)
    end
end)

u364(v512, 'Teleport Behind Player', nil, u29.EnableTeleportBehindPlayer, function(p525)
    u29.EnableTeleportBehindPlayer = p525

    u32()

    _Frame13.Visible = p525

    u520(u29.TeleportBehindPlayerKeybind)
end).LayoutOrder = 2

local v526 = v309(_UsefulFeatures, 'Disable Particles')

v526.LayoutOrder = 1
u29.DisableFlashbang = u29.DisableFlashbang or false

if u29.DisableFlashbang then
    u227(true)
end

u29.DisableSmoke = u29.DisableSmoke or false

if u29.DisableSmoke then
    u236(true)
end

u29.DisablePaintball = u29.DisablePaintball or false

if u29.DisablePaintball then
    u230(true)
end

u364(v526, 'Disable Flashbang', nil, u29.DisableFlashbang, function(p527)
    u29.DisableFlashbang = p527

    u32()
    u227(p527)
end).LayoutOrder = 1
u364(v526, 'Disable Smoke', nil, u29.DisableSmoke, function(p528)
    u29.DisableSmoke = p528

    u32()
    u236(p528)
end).LayoutOrder = 2
u364(v526, 'Disable Paintball', nil, u29.DisablePaintball, function(p529)
    u29.DisablePaintball = p529

    u32()
    u230(p529)
end).LayoutOrder = 3

local v530 = v309(_UsefulFeatures, 'Device Spoofer')

v530.LayoutOrder = 2

local _SpoofedDevice = u29.SpoofedDevice
local u555 = (function(p532, p533, p534, p535)
    local _Frame14 = Instance.new('Frame')

    _Frame14.Size = UDim2.new(1, 0, 0, #p533 * 35)
    _Frame14.BackgroundColor3 = u237.ContentFrame
    _Frame14.BorderSizePixel = 0
    _Frame14.Visible = false
    _Frame14.Parent = p532

    local v537, v538, v539 = ipairs(p533)
    local u540 = nil

    while true do
        local u541

        v539, u541 = v537(v538, v539)

        if v539 == nil then
            break
        end

        local _TextButton6 = Instance.new('TextButton')

        _TextButton6.Size = UDim2.new(1, -10, 0, 30)
        _TextButton6.Position = UDim2.new(0, 5, 0, (v539 - 1) * 35 + 2.5)
        _TextButton6.BackgroundColor3 = u237.Button
        _TextButton6.BorderSizePixel = 0
        _TextButton6.TextColor3 = u237.ButtonText
        _TextButton6.Text = u541
        _TextButton6.TextScaled = true
        _TextButton6.Parent = _Frame14
        _TextButton6.AutoButtonColor = false

        if p535 and u541 == p535 then
            _TextButton6.BackgroundColor3 = u237.Selected
            u540 = _TextButton6
        end

        _TextButton6.MouseEnter:Connect(function()
            if _TextButton6 ~= u540 then
                _TextButton6.BackgroundColor3 = u237.ButtonHover
            end
        end)
        _TextButton6.MouseLeave:Connect(function()
            if _TextButton6 ~= u540 then
                _TextButton6.BackgroundColor3 = u237.Button
            end
        end)
        _TextButton6.MouseButton1Click:Connect(function()
            if u540 then
                u540.BackgroundColor3 = u237.Button
            end

            u540 = _TextButton6
            _TextButton6.BackgroundColor3 = u237.Selected

            p534(u541)
        end)
    end

    _Frame14:GetPropertyChangedSignal('Visible'):Connect(function()
        if _Frame14.Visible then
            local _SpoofedDevice2 = u29.SpoofedDevice

            if _SpoofedDevice2 then
                u540 = nil

                local v544 = _Frame14
                local v545, v546, v547 = ipairs(v544:GetChildren())

                while true do
                    local v548

                    v547, v548 = v545(v546, v547)

                    if v547 == nil then
                        break
                    end
                    if v548:IsA('TextButton') then
                        if v548.Text == _SpoofedDevice2 then
                            v548.BackgroundColor3 = u237.Selected
                            u540 = v548
                        else
                            v548.BackgroundColor3 = u237.Button
                        end
                    end
                end
            else
                u540 = nil

                local v549 = _Frame14
                local v550, v551, v552 = ipairs(v549:GetChildren())

                while true do
                    local v553

                    v552, v553 = v550(v551, v552)

                    if v552 == nil then
                        break
                    end
                    if v553:IsA('TextButton') then
                        v553.BackgroundColor3 = u237.Button
                    end
                end
            end
        end
    end)

    return _Frame14
end)(v530, {
    'MouseKeyboard',
    'Gamepad',
    'Touch',
    'VR',
}, function(p554)
    u29.SpoofedDevice = p554

    u201(p554)
    u32()
end, _SpoofedDevice)

u555.LayoutOrder = 2
u364(v530, 'Spoof Device?', nil, _SpoofedDevice ~= nil, function(p556)
    u555.Visible = p556

    if not p556 then
        u201(nil)

        u29.SpoofedDevice = nil

        u32()
    end
end).LayoutOrder = 1

if _SpoofedDevice then
    u201(_SpoofedDevice)

    u555.Visible = true
end

local function u563(p557, p558)
    local v559, v560, v561 = pairs(getgc(true))

    while true do
        local v562

        v561, v562 = v559(v560, v561)

        if v561 == nil then
            break
        end
        if type(v562) == 'table' and rawget(v562, p557) then
            v562[p557] = p558
        end
    end
end

local v564 = v309(_RageMode, 'Weapon Mods')

v564.LayoutOrder = 1
u29.DisableShootCooldown = u29.DisableShootCooldown or false

if u29.DisableShootCooldown then
    u563('ShootCooldown', 0)
    u563('Status', 'Prime')
end

u29.DisableGunSpread = u29.DisableGunSpread or false

if u29.DisableGunSpread then
    u563('ShootSpread', 0)
    u563('Status', 'Prime')
end

u29.DisableGunRecoil = u29.DisableGunRecoil or false

if u29.DisableGunRecoil then
    u563('ShootRecoil', 0)
    u563('Status', 'Prime')
end

u364(v564, 'Disable Shot Cooldown', nil, u29.DisableShootCooldown, function(p565)
    u29.DisableShootCooldown = p565

    u32()
    u563('ShootCooldown', 0)
    u563('Status', 'Prime')
end).LayoutOrder = 1
u364(v564, 'Disable Gun Spread', nil, u29.DisableGunSpread, function(p566)
    u29.DisableGunSpread = p566

    u32()
    u563('ShootSpread', 0)
    u563('Status', 'Prime')
end).LayoutOrder = 2
u364(v564, 'Disable Gun Recoil', nil, u29.DisableGunRecoil, function(p567)
    u29.DisableGunRecoil = p567

    u32()
    u563('ShootRecoil', 0)
    u563('Status', 'Prime')
end).LayoutOrder = 3

local v568 = v309(_Visuals, 'ESP')

v568.LayoutOrder = 1

local _Frame15 = Instance.new('Frame')

_Frame15.Size = UDim2.new(1, 0, 0, 80)
_Frame15.BackgroundColor3 = u237.ContentFrame
_Frame15.BorderSizePixel = 0
_Frame15.Visible = u29.ESPEnabled
_Frame15.Parent = v568
_Frame15.LayoutOrder = 2

local _UIListLayout5 = Instance.new('UIListLayout')

_UIListLayout5.FillDirection = Enum.FillDirection.Vertical
_UIListLayout5.SortOrder = Enum.SortOrder.LayoutOrder
_UIListLayout5.Parent = _Frame15

local _TextLabel8 = Instance.new('TextLabel')

_TextLabel8.Size = UDim2.new(1, -10, 0, 30)
_TextLabel8.BackgroundColor3 = u237.Button
_TextLabel8.BackgroundTransparency = 1
_TextLabel8.Text = 'Custom ESP Fill Color (R,G,B):'
_TextLabel8.TextColor3 = u237.ButtonText
_TextLabel8.Font = Enum.Font.SourceSans
_TextLabel8.TextSize = 18
_TextLabel8.TextXAlignment = Enum.TextXAlignment.Left
_TextLabel8.Parent = _Frame15
_TextLabel8.LayoutOrder = 2

local _TextBox4 = Instance.new('TextBox')

_TextBox4.Size = UDim2.new(1, -50, 0, 30)
_TextBox4.Position = UDim2.new(0, 5, 0, 40)
_TextBox4.BackgroundColor3 = u237.Button
_TextBox4.BackgroundTransparency = 0

local v573 = u100.Esp.Values.FillColor or Color3.fromRGB(255, 255, 255)

_TextBox4.Text = string.format('%d, %d, %d', math.floor(v573.R * 255), math.floor(v573.G * 255), math.floor(v573.B * 255))
_TextBox4.TextColor3 = u237.ButtonText
_TextBox4.Font = Enum.Font.SourceSans
_TextBox4.TextSize = 18
_TextBox4.TextXAlignment = Enum.TextXAlignment.Left
_TextBox4.ClearTextOnFocus = false
_TextBox4.Parent = _Frame15
_TextBox4.LayoutOrder = 3

local _Frame16 = Instance.new('Frame')

_Frame16.Size = UDim2.new(0, 30, 0, 30)
_Frame16.Position = UDim2.new(1, -35, 0, 40)

local _FillColor = u100.Esp.Values.FillColor

if typeof(_FillColor) ~= 'Color3' then
    _FillColor = Color3.fromRGB(255, 255, 255)
end

_Frame16.BackgroundColor3 = _FillColor
_Frame16.BorderSizePixel = 1
_Frame16.Parent = _Frame15
_Frame16.LayoutOrder = 4

_TextBox4:GetPropertyChangedSignal('Text'):Connect(function()
    local _dsdsd, v577, v578 = _TextBox4.Text:match('(%d+),%s*(%d+),%s*(%d+)')
    local v579 = tonumber(_dsdsd)
    local v580 = tonumber(v577)
    local v581 = tonumber(v578)

    if v579 and (v580 and v581) then
        u29.EspColor = {v579, v580, v581}

        u32()

        u100.Esp.Values.FillColor = Color3.fromRGB(v579, v580, v581)
        _Frame16.BackgroundColor3 = Color3.fromRGB(v579, v580, v581)
    end
end)

local _Frame17 = Instance.new('Frame')

_Frame17.Size = UDim2.new(1, 0, 0, 80)
_Frame17.BackgroundColor3 = u237.ContentFrame
_Frame17.BorderSizePixel = 0
_Frame17.Visible = u29.ESPEnabled
_Frame17.Parent = v568
_Frame17.LayoutOrder = 3

local _UIListLayout6 = Instance.new('UIListLayout')

_UIListLayout6.FillDirection = Enum.FillDirection.Vertical
_UIListLayout6.SortOrder = Enum.SortOrder.LayoutOrder
_UIListLayout6.Parent = _Frame17

local _TextLabel9 = Instance.new('TextLabel')

_TextLabel9.Size = UDim2.new(1, -10, 0, 30)
_TextLabel9.BackgroundTransparency = 1
_TextLabel9.Text = 'ESP Outline Color (R,G,B):'
_TextLabel9.TextColor3 = u237.ButtonText
_TextLabel9.Font = Enum.Font.SourceSans
_TextLabel9.TextSize = 18
_TextLabel9.TextXAlignment = Enum.TextXAlignment.Left
_TextLabel9.Parent = _Frame17
_TextLabel9.LayoutOrder = 2

local _TextBox5 = Instance.new('TextBox')

_TextBox5.Size = UDim2.new(1, -50, 0, 30)
_TextBox5.Position = UDim2.new(0, 5, 0, 40)
_TextBox5.BackgroundColor3 = u237.Button
_TextBox5.BackgroundTransparency = 0

local v586 = u100.Esp.Values.OutlineColor or Color3.fromRGB(255, 255, 255)

_TextBox5.Text = string.format('%d, %d, %d', math.floor(v586.R * 255), math.floor(v586.G * 255), math.floor(v586.B * 255))
_TextBox5.TextColor3 = u237.ButtonText
_TextBox5.Font = Enum.Font.SourceSans
_TextBox5.TextSize = 18
_TextBox5.TextXAlignment = Enum.TextXAlignment.Left
_TextBox5.ClearTextOnFocus = false
_TextBox5.Parent = _Frame17
_TextBox5.LayoutOrder = 3

local _Frame18 = Instance.new('Frame')

_Frame18.Size = UDim2.new(0, 30, 0, 30)
_Frame18.Position = UDim2.new(1, -35, 0, 40)

if typeof(v586) ~= 'Color3' then
    v586 = Color3.fromRGB(255, 255, 255)
end

_Frame18.BackgroundColor3 = v586
_Frame18.BorderSizePixel = 1
_Frame18.Parent = _Frame17
_Frame18.LayoutOrder = 4

_TextBox5:GetPropertyChangedSignal('Text'):Connect(function()
    local _dsdsd2, v589, v590 = _TextBox5.Text:match('(%d+),%s*(%d+),%s*(%d+)')
    local v591 = tonumber(_dsdsd2)
    local v592 = tonumber(v589)
    local v593 = tonumber(v590)

    if v591 and (v592 and v593) then
        u29.EspOutlineColor = {v591, v592, v593}

        u32()

        u100.Esp.Values.OutlineColor = Color3.fromRGB(v591, v592, v593)
        _Frame18.BackgroundColor3 = Color3.fromRGB(v591, v592, v593)
    end
end)

u364(v568, 'Enable ESP', nil, u29.ESPEnabled or false, function(p594)
    u29.ESPEnabled = p594

    u32()

    _Frame15.Visible = p594
    u100.Esp.Values.Enabled = p594
end).LayoutOrder = 1

local v595 = v309(_Aimbot, 'Aimbot')

v595.LayoutOrder = 1

local _Frame19 = Instance.new('Frame')

_Frame19.Size = UDim2.new(1, 0, 0, 30)
_Frame19.BackgroundTransparency = 1
_Frame19.Parent = v595
_Frame19.LayoutOrder = 2
_Frame19.Visible = u29.AimbotEnabled or false

local _TextLabel10 = Instance.new('TextLabel')

_TextLabel10.Size = UDim2.new(0.6, 0, 1, 0)
_TextLabel10.BackgroundTransparency = 1
_TextLabel10.Text = 'FOV Circle Size:'
_TextLabel10.TextColor3 = u237.ButtonText
_TextLabel10.Font = Enum.Font.SourceSans
_TextLabel10.TextSize = 18
_TextLabel10.TextXAlignment = Enum.TextXAlignment.Left
_TextLabel10.Parent = _Frame19

local _TextBox6 = Instance.new('TextBox')

_TextBox6.Size = UDim2.new(0.4, -5, 1, 0)
_TextBox6.Position = UDim2.new(0.6, 5, 0, 0)
_TextBox6.BackgroundColor3 = u237.Button
_TextBox6.TextColor3 = u237.ButtonText
_TextBox6.Font = Enum.Font.SourceSans
_TextBox6.TextSize = 16
_TextBox6.ClearTextOnFocus = false
_TextBox6.PlaceholderText = '100'
_TextBox6.Text = tostring(u29.FOVSize or 100)
_TextBox6.Parent = _Frame19

_TextBox6.FocusLost:Connect(function(_)
    local v599 = tonumber(_TextBox6.Text)
    local v600 = (not v599 or v599 < 50) and 50 or (v599 > 400 and 400 or v599)

    u29.FOVSize = v600
    _TextBox6.Text = tostring(v600)

    u32()

    u100.AimBot.Fov.Size = v600
end)

u364(v595, 'Enable Aimbot', nil, u29.AimbotEnabled or false, function(p601)
    u29.AimbotEnabled = p601
    u100.AimBot.Values.Enable = p601

    u32()

    _Frame19.Visible = p601
end).LayoutOrder = 1
u364(v595, 'Enable Triggerbot', nil, u29.TriggerEnabled or false, function(p602)
    u29.TriggerEnabled = p602

    u32()
end).LayoutOrder = 3

u23.InputBegan:Connect(function(p603, p604)
    if not p604 then
        if p603.KeyCode == Enum.KeyCode.RightShift then
            u267.Enabled = not u267.Enabled
        end
    end
end)
