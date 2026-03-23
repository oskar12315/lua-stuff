local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library
Library._allModules = {}
Library._keybindWidgetEnabled = false
Library._keybindWidgetFrame = nil
Library._configFolder = "MCClientConfigs"

local Theme = {
    Background       = Color3.fromRGB(22, 22, 28),
    CategoryBg       = Color3.fromRGB(28, 28, 36),
    CategoryBorder   = Color3.fromRGB(48, 48, 60),
    CategoryHeader   = Color3.fromRGB(200, 200, 215),
    ModuleEnabled    = Color3.fromRGB(230, 140, 180),
    ModuleDisabled   = Color3.fromRGB(185, 185, 195),
    OptionText       = Color3.fromRGB(150, 150, 162),
    OptionValue      = Color3.fromRGB(215, 215, 225),
    AccentPink       = Color3.fromRGB(230, 140, 180),
    SliderBg         = Color3.fromRGB(42, 42, 52),
    SliderFill       = Color3.fromRGB(230, 140, 180),
    ToggleOn         = Color3.fromRGB(230, 140, 180),
    ToggleOff        = Color3.fromRGB(55, 55, 68),
    Knob             = Color3.fromRGB(220, 220, 230),
    DropBg           = Color3.fromRGB(32, 32, 42),
    DropHover        = Color3.fromRGB(48, 48, 60),
    DropBorder       = Color3.fromRGB(55, 55, 68),
    BindText         = Color3.fromRGB(120, 120, 135),
    Separator        = Color3.fromRGB(42, 42, 52),
    PickerBg         = Color3.fromRGB(30, 30, 38),
    Font             = Enum.Font.Gotham,
    FontSemi         = Enum.Font.GothamSemibold,
    FontBold         = Enum.Font.GothamBold,
}

-- ═══════════════════════════════════
-- UTILS
-- ═══════════════════════════════════
local function Create(c, p, ch)
    local i = Instance.new(c)
    if p then
        for k, v in pairs(p) do
            if k ~= "Parent" then i[k] = v end
        end
        if p.Parent then i.Parent = p.Parent end
    end
    if ch then for _, x in ipairs(ch) do x.Parent = i end end
    return i
end

local function Tween(inst, dur, props, style, dir)
    local t = TweenService:Create(inst, TweenInfo.new(dur, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function HSVfromRGB(c)
    local r, g, b = c.R, c.G, c.B
    local mx, mn = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, mx
    local d = mx - mn
    s = mx == 0 and 0 or d / mx
    if mx ~= mn then
        if mx == r then h = (g - b) / d + (g < b and 6 or 0)
        elseif mx == g then h = (b - r) / d + 2
        else h = (r - g) / d + 4 end
        h = h / 6
    end
    return h, s, v
end

-- safe file system
local function SafeWriteFile(path, content)
    pcall(function()
        if writefile then writefile(path, content) end
    end)
end

local function SafeReadFile(path)
    local ok, result = pcall(function()
        if readfile and isfile and isfile(path) then
            return readfile(path)
        end
        return nil
    end)
    return ok and result or nil
end

local function SafeDeleteFile(path)
    pcall(function()
        if delfile and isfile and isfile(path) then delfile(path) end
    end)
end

local function SafeMakeFolder(path)
    pcall(function()
        if makefolder and not isfolder(path) then makefolder(path) end
    end)
end

local function SafeListFiles(path)
    local ok, result = pcall(function()
        if listfiles and isfolder and isfolder(path) then
            return listfiles(path)
        end
        return {}
    end)
    return ok and result or {}
end

-- ═══════════════════════════════════
-- MAIN
-- ═══════════════════════════════════
function Library.new(clientName)
    local self = setmetatable({}, Library)
    self.Name = clientName or "Client"
    self.Categories = {}
    self.Visible = true
    self.ToggleKey = Enum.KeyCode.RightShift
    self._allModules = {}
    self._allOptions = {}
    self._connections = {}

    local existing = LocalPlayer.PlayerGui:FindFirstChild("MCClientUI")
    if existing then existing:Destroy() end

    self.ScreenGui = Create("ScreenGui", {
        Name = "MCClientUI",
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999,
    })

    -- main container - NO dark overlay, just the columns
    self.MainFrame = Create("ScrollingFrame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0, 55),
        Size = UDim2.new(1, -32, 1, -70),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ClipsDescendants = false,
    })

    Create("UIListLayout", {
        Parent = self.MainFrame,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })

    Create("UIPadding", {
        Parent = self.MainFrame,
        PaddingLeft = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
    })

    -- keybind widget
    self:_createKeybindWidget()

    -- toggle UI
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self.Visible = not self.Visible
            self.MainFrame.Visible = self.Visible
        end
    end))

    -- keybind processing
    local heldKeys = {}
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        heldKeys[input.KeyCode] = true
        for _, mod in ipairs(self._allModules) do
            if mod._bindKey and mod._bindKey == input.KeyCode and mod._bindKey ~= Enum.KeyCode.Unknown then
                local mode = mod._bindMode or "toggle"
                if mode == "toggle" then
                    mod:SetEnabled(not mod.Enabled)
                elseif mode == "hold" then
                    mod:SetEnabled(true)
                end
                -- "always" is handled in RunService
            end
        end
    end))

    table.insert(self._connections, UserInputService.InputEnded:Connect(function(input, gpe)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        heldKeys[input.KeyCode] = nil
        for _, mod in ipairs(self._allModules) do
            if mod._bindKey and mod._bindKey == input.KeyCode and mod._bindKey ~= Enum.KeyCode.Unknown then
                local mode = mod._bindMode or "toggle"
                if mode == "hold" then
                    mod:SetEnabled(false)
                end
            end
        end
    end))

    SafeMakeFolder(Library._configFolder)

    return self
end

-- ═══════════════════════════════════
-- KEYBIND WIDGET
-- ═══════════════════════════════════
function Library:_createKeybindWidget()
    self._keybindWidgetFrame = Create("Frame", {
        Name = "KeybindWidget",
        Parent = self.ScreenGui,
        BackgroundColor3 = Theme.CategoryBg,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -180, 0.5, -100),
        Size = UDim2.new(0, 160, 0, 30),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self._keybindWidgetFrame })
    Create("UIStroke", { Color = Theme.CategoryBorder, Thickness = 1, Transparency = 0.4, Parent = self._keybindWidgetFrame })

    Create("TextLabel", {
        Parent = self._keybindWidgetFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        Font = Theme.FontBold,
        Text = "KEYBINDS",
        TextColor3 = Theme.CategoryHeader,
        TextSize = 11,
        LayoutOrder = 0,
    })

    Create("UIPadding", {
        Parent = self._keybindWidgetFrame,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
    })

    self._keybindWidgetList = Create("Frame", {
        Parent = self._keybindWidgetFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
    })

    Create("UIListLayout", {
        Parent = self._keybindWidgetList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })

    Create("UIListLayout", {
        Parent = self._keybindWidgetFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })

    -- dragging for widget
    local dragging, dragStart, startPos = false, nil, nil
    self._keybindWidgetFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self._keybindWidgetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            self._keybindWidgetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- update loop
    RunService.Heartbeat:Connect(function()
        if not self._keybindWidgetFrame.Visible then return end
        -- clear old
        for _, c in ipairs(self._keybindWidgetList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        -- rebuild active binds
        local idx = 0
        for _, mod in ipairs(self._allModules) do
            if mod.Enabled and mod._bindKey and mod._bindKey ~= Enum.KeyCode.Unknown then
                idx = idx + 1
                local r = Create("Frame", {
                    Parent = self._keybindWidgetList,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    LayoutOrder = idx,
                })
                Create("TextLabel", {
                    Parent = r,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.65, 0, 1, 0),
                    Font = Theme.Font,
                    Text = mod.Name,
                    TextColor3 = Theme.ModuleEnabled,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                Create("TextLabel", {
                    Parent = r,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.65, 0, 0, 0),
                    Size = UDim2.new(0.35, 0, 1, 0),
                    Font = Theme.Font,
                    Text = "[" .. mod._bindKey.Name .. "]",
                    TextColor3 = Theme.BindText,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
            end
        end
    end)
end

function Library:SetKeybindWidgetVisible(visible)
    self._keybindWidgetEnabled = visible
    self._keybindWidgetFrame.Visible = visible
end

-- ═══════════════════════════════════
-- CONFIG SYSTEM
-- ═══════════════════════════════════
function Library:SaveConfig(name)
    local data = {}
    for id, opt in pairs(self._allOptions) do
        local entry = { id = id, type = opt.Type }
        if opt.Type == "Toggle" then
            entry.value = opt.Value
        elseif opt.Type == "Slider" then
            entry.value = opt.Value
        elseif opt.Type == "Dropdown" then
            entry.value = opt.Value
        elseif opt.Type == "ColorPicker" then
            entry.value = { opt.Value.R, opt.Value.G, opt.Value.B }
        elseif opt.Type == "Keybind" then
            entry.value = opt.Value ~= Enum.KeyCode.Unknown and opt.Value.Name or "Unknown"
            entry.mode = opt.Mode or "toggle"
        end
        table.insert(data, entry)
    end

    -- also save module states
    local modStates = {}
    for _, mod in ipairs(self._allModules) do
        table.insert(modStates, {
            name = mod._fullId,
            enabled = mod.Enabled,
            bindKey = mod._bindKey and mod._bindKey ~= Enum.KeyCode.Unknown and mod._bindKey.Name or nil,
            bindMode = mod._bindMode or "toggle",
        })
    end

    local saveData = { options = data, modules = modStates }
    local json = HttpService:JSONEncode(saveData)
    SafeMakeFolder(Library._configFolder)
    SafeWriteFile(Library._configFolder .. "/" .. name .. ".json", json)
end

function Library:LoadConfig(name)
    local raw = SafeReadFile(Library._configFolder .. "/" .. name .. ".json")
    if not raw then return false end

    local ok, saveData = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or not saveData then return false end

    -- load options
    if saveData.options then
        for _, entry in ipairs(saveData.options) do
            local opt = self._allOptions[entry.id]
            if opt then
                if opt.Type == "Toggle" and entry.value ~= nil then
                    opt:Set(entry.value)
                elseif opt.Type == "Slider" and entry.value then
                    opt:Set(entry.value)
                elseif opt.Type == "Dropdown" and entry.value then
                    opt:Set(entry.value)
                elseif opt.Type == "ColorPicker" and entry.value then
                    opt:Set(Color3.new(entry.value[1], entry.value[2], entry.value[3]))
                elseif opt.Type == "Keybind" and entry.value then
                    local key = Enum.KeyCode[entry.value] or Enum.KeyCode.Unknown
                    opt:Set(key, entry.mode)
                end
            end
        end
    end

    -- load module states
    if saveData.modules then
        for _, ms in ipairs(saveData.modules) do
            for _, mod in ipairs(self._allModules) do
                if mod._fullId == ms.name then
                    mod:SetEnabled(ms.enabled)
                    if ms.bindKey then
                        mod._bindKey = Enum.KeyCode[ms.bindKey] or Enum.KeyCode.Unknown
                    end
                    mod._bindMode = ms.bindMode or "toggle"
                    if mod._updateBindDisplay then mod:_updateBindDisplay() end
                end
            end
        end
    end

    return true
end

function Library:DeleteConfig(name)
    SafeDeleteFile(Library._configFolder .. "/" .. name .. ".json")
end

function Library:GetConfigs()
    local files = SafeListFiles(Library._configFolder)
    local configs = {}
    for _, f in ipairs(files) do
        local n = f:match("([^/\\]+)%.json$")
        if n then table.insert(configs, n) end
    end
    return configs
end

-- ═══════════════════════════════════
-- CATEGORY
-- ═══════════════════════════════════
function Library:Category(name)
    local cat = { Name = name, Modules = {}, Library = self }
    local catIdx = #self.Categories + 1

    cat.Frame = Create("Frame", {
        Name = "Cat_" .. name,
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.CategoryBg,
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 0, 40),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = catIdx,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = cat.Frame })
    Create("UIStroke", { Color = Theme.CategoryBorder, Thickness = 1, Transparency = 0.4, Parent = cat.Frame })

    -- internal layout
    local innerFrame = Create("Frame", {
        Name = "Inner",
        Parent = cat.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    Create("UIListLayout", {
        Parent = innerFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })

    Create("UIPadding", {
        Parent = innerFrame,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    })

    -- header
    Create("TextLabel", {
        Name = "Header",
        Parent = innerFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Font = Theme.FontBold,
        Text = string.upper(name),
        TextColor3 = Theme.CategoryHeader,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    })

    -- separator
    local sepWrap = Create("Frame", {
        Parent = innerFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 6),
        LayoutOrder = 1,
    })
    Create("Frame", {
        Parent = sepWrap,
        BackgroundColor3 = Theme.Separator,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 1),
    })

    -- module list
    cat.ModuleList = Create("Frame", {
        Name = "ModList",
        Parent = innerFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
    })

    Create("UIListLayout", {
        Parent = cat.ModuleList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })

    cat._innerFrame = innerFrame

    function cat:Module(moduleName)
        return Library._CreateModule(self, moduleName)
    end

    table.insert(self.Categories, cat)
    return cat
end

-- ═══════════════════════════════════
-- MODULE
-- ═══════════════════════════════════
function Library._CreateModule(cat, moduleName)
    local lib = cat.Library
    local mod = {
        Name = moduleName,
        Enabled = false,
        Expanded = false,
        Options = {},
        Category = cat,
        Callback = nil,
        _bindKey = nil,
        _bindMode = "toggle",
        _fullId = cat.Name .. "." .. moduleName,
        _optionCount = 0,
        _expandedHeight = 0,
    }

    local modIdx = #cat.Modules + 1

    -- container
    mod.Container = Create("Frame", {
        Name = "Mod_" .. moduleName,
        Parent = cat.ModuleList,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        LayoutOrder = modIdx,
        ClipsDescendants = true,
    })

    -- header button
    mod.HeaderBtn = Create("TextButton", {
        Name = "Header",
        Parent = mod.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        Text = "",
        AutoButtonColor = false,
    })

    -- name
    mod.NameLabel = Create("TextLabel", {
        Parent = mod.HeaderBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Font = Theme.FontSemi,
        Text = string.lower(moduleName),
        TextColor3 = Theme.ModuleDisabled,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- bind label (far right)
    mod.BindLabel = Create("TextLabel", {
        Parent = mod.HeaderBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -65, 0, 0),
        Size = UDim2.new(0, 62, 1, 0),
        Font = Theme.Font,
        Text = "",
        TextColor3 = Theme.BindText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    -- options frame (starts at height 0, animated)
    mod.OptionsFrame = Create("Frame", {
        Name = "Opts",
        Parent = mod.Container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 26),
        Size = UDim2.new(1, -8, 0, 0),
        ClipsDescendants = true,
    })

    -- accent bar
    mod.AccentBar = Create("Frame", {
        Parent = mod.OptionsFrame,
        BackgroundColor3 = Theme.AccentPink,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, 2, 1, -4),
    })

    mod.OptionsInner = Create("Frame", {
        Parent = mod.OptionsFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    mod.OptionsLayout = Create("UIListLayout", {
        Parent = mod.OptionsInner,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    })

    Create("UIPadding", {
        Parent = mod.OptionsInner,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 8),
    })

    -- update bind display
    function mod:_updateBindDisplay()
        if self._bindKey and self._bindKey ~= Enum.KeyCode.Unknown then
            self.BindLabel.Text = "[" .. self._bindKey.Name .. "]"
        else
            self.BindLabel.Text = ""
        end
    end

    -- set enabled
    function mod:SetEnabled(state)
        self.Enabled = state
        if state then
            Tween(self.NameLabel, 0.15, { TextColor3 = Theme.ModuleEnabled })
        else
            Tween(self.NameLabel, 0.15, { TextColor3 = Theme.ModuleDisabled })
        end
        if self.Callback then self.Callback(state) end
    end

    -- smooth expand/collapse
    local function recalcHeight()
        task.defer(function()
            local h = mod.OptionsLayout.AbsoluteContentSize.Y + 12
            mod._expandedHeight = h
            if mod.Expanded then
                Tween(mod.OptionsFrame, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
                Tween(mod.Container, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
            end
        end)
    end

    -- left click toggle
    mod.HeaderBtn.MouseButton1Click:Connect(function()
        mod:SetEnabled(not mod.Enabled)
    end)

    -- right click expand with smooth animation
    mod.HeaderBtn.MouseButton2Click:Connect(function()
        if mod._optionCount == 0 then return end
        mod.Expanded = not mod.Expanded
        if mod.Expanded then
            local h = mod.OptionsLayout.AbsoluteContentSize.Y + 12
            mod._expandedHeight = h
            Tween(mod.OptionsFrame, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
            Tween(mod.Container, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
        else
            Tween(mod.OptionsFrame, 0.25, { Size = UDim2.new(1, -8, 0, 0) }, Enum.EasingStyle.Quart)
            Tween(mod.Container, 0.25, { Size = UDim2.new(1, 0, 0, 26) }, Enum.EasingStyle.Quart)
        end
    end)

    -- hover
    mod.HeaderBtn.MouseEnter:Connect(function()
        if not mod.Enabled then
            Tween(mod.NameLabel, 0.08, { TextColor3 = Color3.fromRGB(225, 225, 235) })
        end
    end)
    mod.HeaderBtn.MouseLeave:Connect(function()
        if not mod.Enabled then
            Tween(mod.NameLabel, 0.08, { TextColor3 = Theme.ModuleDisabled })
        end
    end)

    -- ═══════════════════════════════
    -- MODULE API
    -- ═══════════════════════════════
    function mod:OnToggle(cb)
        self.Callback = cb
        return self
    end

    -- helper for option registration
    local function regOpt(opt, id)
        mod._optionCount = mod._optionCount + 1
        lib._allOptions[id] = opt
        -- recalc after adding
        task.defer(recalcHeight)
    end

    -- ─── TOGGLE ───
    function mod:Toggle(name, default, callback)
        local id = self._fullId .. "." .. name
        local opt = { Type = "Toggle", Value = default or false, Name = name, Callback = callback }

        local row = Create("Frame", {
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = self._optionCount + 1,
        })

        Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -44, 1, 0),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local bg = Create("Frame", {
            Parent = row,
            BackgroundColor3 = opt.Value and Theme.ToggleOn or Theme.ToggleOff,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -36, 0.5, -7),
            Size = UDim2.new(0, 30, 0, 14),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bg })

        local knob = Create("Frame", {
            Parent = bg,
            BackgroundColor3 = Theme.Knob,
            BorderSizePixel = 0,
            Position = opt.Value and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
            Size = UDim2.new(0, 10, 0, 10),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

        local btn = Create("TextButton", {
            Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 5,
        })

        function opt:Set(val)
            opt.Value = val
            if val then
                Tween(bg, 0.2, { BackgroundColor3 = Theme.ToggleOn })
                Tween(knob, 0.2, { Position = UDim2.new(1, -13, 0.5, -5) })
            else
                Tween(bg, 0.2, { BackgroundColor3 = Theme.ToggleOff })
                Tween(knob, 0.2, { Position = UDim2.new(0, 2, 0.5, -5) })
            end
            if opt.Callback then opt.Callback(val) end
        end

        btn.MouseButton1Click:Connect(function()
            opt:Set(not opt.Value)
        end)

        table.insert(self.Options, opt)
        regOpt(opt, id)
        return opt
    end

    -- ─── SLIDER ───
    function mod:Slider(name, default, min, max, callback, suffix, decimals)
        suffix = suffix or ""
        decimals = decimals or 1
        default = default or min
        local id = self._fullId .. "." .. name
        local opt = { Type = "Slider", Value = default, Name = name, Callback = callback }

        local row = Create("Frame", {
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            LayoutOrder = self._optionCount + 1,
        })

        Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.6, 0, 0, 15),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local valLabel = Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.6, 0, 0, 0),
            Size = UDim2.new(0.4, 0, 0, 15),
            Font = Theme.FontSemi,
            Text = tostring(default) .. suffix,
            TextColor3 = Theme.OptionValue,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
        })

        local track = Create("Frame", {
            Parent = row,
            BackgroundColor3 = Theme.SliderBg,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 19),
            Size = UDim2.new(1, 0, 0, 5),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

        local pct = math.clamp((default - min) / (max - min), 0, 1)
        local fill = Create("Frame", {
            Parent = track,
            BackgroundColor3 = Theme.SliderFill,
            BorderSizePixel = 0,
            Size = UDim2.new(pct, 0, 1, 0),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

        local knob = Create("Frame", {
            Parent = track,
            BackgroundColor3 = Theme.Knob,
            BorderSizePixel = 0,
            Position = UDim2.new(pct, -5, 0.5, -5),
            Size = UDim2.new(0, 10, 0, 10),
            ZIndex = 3,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

        local sliderBtn = Create("TextButton", {
            Parent = track,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 14),
            Position = UDim2.new(0, 0, 0, -7),
            Text = "", ZIndex = 5,
        })

        local sliding = false

        local function doUpdate(input)
            local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local raw = min + (max - min) * p
            local val = math.floor(raw * (10 ^ decimals) + 0.5) / (10 ^ decimals)
            opt.Value = val
            valLabel.Text = tostring(val) .. suffix
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -5, 0.5, -5)
            if callback then callback(val) end
        end

        function opt:Set(val)
            val = math.clamp(val, min, max)
            local p = (val - min) / (max - min)
            opt.Value = val
            valLabel.Text = tostring(val) .. suffix
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -5, 0.5, -5)
            if callback then callback(val) end
        end

        sliderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                doUpdate(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then doUpdate(input) end
        end)

        table.insert(self.Options, opt)
        regOpt(opt, id)
        return opt
    end

    -- ─── DROPDOWN ───
    function mod:Dropdown(name, items, default, callback)
        local id = self._fullId .. "." .. name
        local opt = { Type = "Dropdown", Value = default or items[1], Items = items, Name = name, Callback = callback }
        local dropOpen = false

        local row = Create("Frame", {
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = self._optionCount + 1,
            ClipsDescendants = false,
        })

        Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 0, 22),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local valBtn = Create("TextButton", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.5, 0, 0, 22),
            Font = Theme.FontSemi,
            Text = tostring(opt.Value),
            TextColor3 = Theme.OptionValue,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            AutoButtonColor = false,
        })

        -- dropdown list (absolute positioned to not affect layout)
        local dropFrame = Create("Frame", {
            Parent = row,
            BackgroundColor3 = Theme.DropBg,
            BorderSizePixel = 0,
            Position = UDim2.new(0.3, 0, 0, 24),
            Size = UDim2.new(0.7, 0, 0, 0),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 50,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = dropFrame })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = dropFrame })

        local dLayout = Create("UIListLayout", {
            Parent = dropFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
        })
        Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = dropFrame })

        local itemBtns = {}
        for i, item in ipairs(items) do
            local ib = Create("TextButton", {
                Parent = dropFrame,
                BackgroundColor3 = Theme.DropBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Theme.Font,
                Text = item,
                TextColor3 = (item == opt.Value) and Theme.AccentPink or Theme.OptionText,
                TextSize = 11,
                AutoButtonColor = false,
                LayoutOrder = i,
                ZIndex = 51,
            })
            table.insert(itemBtns, ib)

            ib.MouseEnter:Connect(function() Tween(ib, 0.1, { BackgroundColor3 = Theme.DropHover }) end)
            ib.MouseLeave:Connect(function() Tween(ib, 0.1, { BackgroundColor3 = Theme.DropBg }) end)

            ib.MouseButton1Click:Connect(function()
                opt.Value = item
                valBtn.Text = item
                for _, b in ipairs(itemBtns) do
                    b.TextColor3 = (b.Text == item) and Theme.AccentPink or Theme.OptionText
                end
                dropOpen = false
                Tween(dropFrame, 0.2, { Size = UDim2.new(0.7, 0, 0, 0) }, Enum.EasingStyle.Quart)
                task.delay(0.2, function() dropFrame.Visible = false end)
                if callback then callback(item) end
            end)
        end

        function opt:Set(val)
            opt.Value = val
            valBtn.Text = val
            for _, b in ipairs(itemBtns) do
                b.TextColor3 = (b.Text == val) and Theme.AccentPink or Theme.OptionText
            end
            if callback then callback(val) end
        end

        valBtn.MouseButton1Click:Connect(function()
            dropOpen = not dropOpen
            if dropOpen then
                dropFrame.Visible = true
                local h = #items * 20 + 4
                Tween(dropFrame, 0.25, { Size = UDim2.new(0.7, 0, 0, h) }, Enum.EasingStyle.Quart)
            else
                Tween(dropFrame, 0.2, { Size = UDim2.new(0.7, 0, 0, 0) }, Enum.EasingStyle.Quart)
                task.delay(0.2, function() dropFrame.Visible = false end)
            end
        end)

        table.insert(self.Options, opt)
        regOpt(opt, id)
        return opt
    end

    -- ─── COLOR PICKER (FIXED) ───
    function mod:ColorPicker(name, default, callback)
        default = default or Color3.new(1, 0, 0)
        local h, s, v = HSVfromRGB(default)
        local id = self._fullId .. "." .. name
        local opt = { Type = "ColorPicker", Value = default, Name = name, Callback = callback }
        local pickerOpen = false

        local row = Create("Frame", {
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = self._optionCount + 1,
            ClipsDescendants = false,
        })

        Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -28, 0, 22),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local preview = Create("TextButton", {
            Parent = row,
            BackgroundColor3 = default,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -20, 0.5, -6),
            Size = UDim2.new(0, 16, 0, 12),
            Text = "",
            AutoButtonColor = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = preview })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = preview })

        -- picker panel (absolute)
        local panel = Create("Frame", {
            Parent = row,
            BackgroundColor3 = Theme.PickerBg,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 24),
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 50,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = panel })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = panel })

        -- SV box - FIXED: proper white corner
        local svBox = Create("Frame", {
            Parent = panel,
            BackgroundColor3 = Color3.new(1, 1, 1), -- start white
            BorderSizePixel = 0,
            Position = UDim2.new(0, 6, 0, 6),
            Size = UDim2.new(1, -28, 0, 80),
            ZIndex = 51,
            ClipsDescendants = true,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = svBox })

        -- hue color overlay (left=white, right=hue color)
        local hueOverlay = Create("Frame", {
            Parent = svBox,
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 52,
        })
        Create("UIGradient", {
            Parent = hueOverlay,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
        })

        -- black overlay (bottom = black)
        local blackOverlay = Create("Frame", {
            Parent = svBox,
            BackgroundColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 53,
        })
        Create("UIGradient", {
            Parent = blackOverlay,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Rotation = 90,
        })

        -- cursor
        local svCursor = Create("Frame", {
            Parent = svBox,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(s, -5, 1 - v, -5),
            Size = UDim2.new(0, 10, 0, 10),
            ZIndex = 56,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })
        Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5, Parent = svCursor })

        -- hue bar
        local hueBar = Create("Frame", {
            Parent = panel,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(1, -18, 0, 6),
            Size = UDim2.new(0, 10, 0, 80),
            ZIndex = 51,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = hueBar })
        Create("UIGradient", {
            Parent = hueBar,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
            }),
            Rotation = 90,
        })

        local hueCursor = Create("Frame", {
            Parent = hueBar,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(0, -2, h, -2),
            Size = UDim2.new(1, 4, 0, 4),
            ZIndex = 56,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = hueCursor })
        Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = hueCursor })

        local svBtn = Create("TextButton", { Parent = svBox, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 57 })
        local hueBtn = Create("TextButton", { Parent = hueBar, BackgroundTransparency = 1, Size = UDim2.new(1, 8, 1, 0), Position = UDim2.new(0, -4, 0, 0), Text = "", ZIndex = 57 })

        local function updateCol()
            opt.Value = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = opt.Value
            hueOverlay.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            hueCursor.Position = UDim2.new(0, -2, h, -2)
            if callback then callback(opt.Value) end
        end

        function opt:Set(color)
            h, s, v = HSVfromRGB(color)
            updateCol()
        end

        local dragSV, dragH = false, false
        svBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragSV = true
                s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                updateCol()
            end
        end)
        hueBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragH = true
                h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 0.999)
                updateCol()
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = false; dragH = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if dragSV then
                    s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                    updateCol()
                elseif dragH then
                    h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 0.999)
                    updateCol()
                end
            end
        end)

        preview.MouseButton1Click:Connect(function()
            pickerOpen = not pickerOpen
            if pickerOpen then
                panel.Visible = true
                Tween(panel, 0.25, { Size = UDim2.new(1, 0, 0, 92) }, Enum.EasingStyle.Quart)
            else
                Tween(panel, 0.2, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quart)
                task.delay(0.2, function() panel.Visible = false end)
            end
        end)

        table.insert(self.Options, opt)
        regOpt(opt, id)
        return opt
    end

    -- ─── KEYBIND (with bind mode: toggle/hold/always) ───
    function mod:Keybind(name, default, callback)
        local id = self._fullId .. "." .. name
        default = default or Enum.KeyCode.Unknown
        local opt = { Type = "Keybind", Value = default, Name = name, Mode = "toggle", Callback = callback }
        local listening = false

        -- set module bind
        mod._bindKey = default
        mod._bindMode = "toggle"
        mod:_updateBindDisplay()

        local row = Create("Frame", {
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = self._optionCount + 1,
            ClipsDescendants = false,
        })

        Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.45, 0, 1, 0),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local bindBtn = Create("TextButton", {
            Parent = row,
            BackgroundColor3 = Theme.DropBg,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -55, 0.5, -9),
            Size = UDim2.new(0, 52, 0, 18),
            Font = Theme.Font,
            Text = default ~= Enum.KeyCode.Unknown and default.Name or "none",
            TextColor3 = Theme.OptionValue,
            TextSize = 10,
            AutoButtonColor = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = bindBtn })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = bindBtn })

        -- mode dropdown (right click on bind button)
        local modeFrame = Create("Frame", {
            Parent = row,
            BackgroundColor3 = Theme.DropBg,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -55, 0, 22),
            Size = UDim2.new(0, 80, 0, 0),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 60,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = modeFrame })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = modeFrame })

        local mLayout = Create("UIListLayout", {
            Parent = modeFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
        })
        Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = modeFrame })

        local modes = { "toggle", "hold", "always" }
        local modeBtns = {}
        for i, m in ipairs(modes) do
            local mb = Create("TextButton", {
                Parent = modeFrame,
                BackgroundColor3 = Theme.DropBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Theme.Font,
                Text = m,
                TextColor3 = (m == opt.Mode) and Theme.AccentPink or Theme.OptionText,
                TextSize = 11,
                AutoButtonColor = false,
                LayoutOrder = i,
                ZIndex = 61,
            })
            table.insert(modeBtns, mb)

            mb.MouseEnter:Connect(function() Tween(mb, 0.1, { BackgroundColor3 = Theme.DropHover }) end)
            mb.MouseLeave:Connect(function() Tween(mb, 0.1, { BackgroundColor3 = Theme.DropBg }) end)

            mb.MouseButton1Click:Connect(function()
                opt.Mode = m
                mod._bindMode = m
                for _, b in ipairs(modeBtns) do
                    b.TextColor3 = (b.Text == m) and Theme.AccentPink or Theme.OptionText
                end
                -- close mode dropdown
                Tween(modeFrame, 0.2, { Size = UDim2.new(0, 80, 0, 0) }, Enum.EasingStyle.Quart)
                task.delay(0.2, function() modeFrame.Visible = false end)
                -- if always, enable immediately
                if m == "always" then
                    mod:SetEnabled(true)
                end
            end)
        end

        -- left click: listen for key
        bindBtn.MouseButton1Click:Connect(function()
            listening = true
            bindBtn.Text = "..."
            Tween(bindBtn, 0.1, { TextColor3 = Theme.AccentPink })
        end)

        -- right click: show mode dropdown
        bindBtn.MouseButton2Click:Connect(function()
            if modeFrame.Visible then
                Tween(modeFrame, 0.2, { Size = UDim2.new(0, 80, 0, 0) }, Enum.EasingStyle.Quart)
                task.delay(0.2, function() modeFrame.Visible = false end)
            else
                modeFrame.Visible = true
                Tween(modeFrame, 0.25, { Size = UDim2.new(0, 80, 0, #modes * 20 + 4) }, Enum.EasingStyle.Quart)
            end
        end)

        local listenConn
        listenConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if not listening then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    opt.Value = Enum.KeyCode.Unknown
                    bindBtn.Text = "none"
                    mod._bindKey = Enum.KeyCode.Unknown
                else
                    opt.Value = input.KeyCode
                    bindBtn.Text = input.KeyCode.Name
                    mod._bindKey = input.KeyCode
                end
                mod:_updateBindDisplay()
                Tween(bindBtn, 0.1, { TextColor3 = Theme.OptionValue })
                listening = false
            end
        end)

        function opt:Set(key, mode)
            opt.Value = key
            mod._bindKey = key
            bindBtn.Text = key ~= Enum.KeyCode.Unknown and key.Name or "none"
            if mode then
                opt.Mode = mode
                mod._bindMode = mode
                for _, b in ipairs(modeBtns) do
                    b.TextColor3 = (b.Text == mode) and Theme.AccentPink or Theme.OptionText
                end
            end
            mod:_updateBindDisplay()
        end

        table.insert(self.Options, opt)
        regOpt(opt, id)
        return opt
    end

    -- ─── LABEL ───
    function mod:Label(text)
        local lbl = Create("TextLabel", {
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Font = Theme.Font,
            Text = text,
            TextColor3 = Theme.BindText,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = self._optionCount + 1,
        })
        self._optionCount = self._optionCount + 1
        task.defer(recalcHeight)
    end

    -- ─── SEPARATOR ───
    function mod:Separator()
        local sep = Create("Frame", {
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6),
            LayoutOrder = self._optionCount + 1,
        })
        Create("Frame", {
            Parent = sep,
            BackgroundColor3 = Theme.Separator,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })
        self._optionCount = self._optionCount + 1
        task.defer(recalcHeight)
    end

    table.insert(cat.Modules, mod)
    table.insert(lib._allModules, mod)
    return mod
end

-- ═══════════════════════════════════
-- CONFIG MODULE HELPER
-- ═══════════════════════════════════
function Library:_CreateConfigModule(cat)
    local mod = cat:Module("config")
    local lib = self

    local selectedConfig = "default"

    -- text input for config name
    local inputRow = Create("Frame", {
        Parent = mod.OptionsInner,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = 0,
    })

    Create("TextLabel", {
        Parent = inputRow,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.35, 0, 1, 0),
        Font = Theme.Font,
        Text = "name",
        TextColor3 = Theme.OptionText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local configInput = Create("TextBox", {
        Parent = inputRow,
        BackgroundColor3 = Theme.DropBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.35, 4, 0.5, -9),
        Size = UDim2.new(0.65, -4, 0, 18),
        Font = Theme.Font,
        Text = "default",
        PlaceholderText = "config name",
        PlaceholderColor3 = Theme.BindText,
        TextColor3 = Theme.OptionValue,
        TextSize = 11,
        ClearTextOnFocus = false,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = configInput })
    Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = configInput })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = configInput })

    configInput.FocusLost:Connect(function()
        selectedConfig = configInput.Text
    end)

    mod._optionCount = mod._optionCount + 1

    -- buttons
    local function makeConfigBtn(text, order, cb)
        local btn = Create("TextButton", {
            Parent = mod.OptionsInner,
            BackgroundColor3 = Theme.DropBg,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 22),
            Font = Theme.FontSemi,
            Text = text,
            TextColor3 = Theme.OptionValue,
            TextSize = 11,
            AutoButtonColor = false,
            LayoutOrder = order,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = btn })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = btn })

        btn.MouseEnter:Connect(function() Tween(btn, 0.1, { BackgroundColor3 = Theme.DropHover }) end)
        btn.MouseLeave:Connect(function() Tween(btn, 0.1, { BackgroundColor3 = Theme.DropBg }) end)

        btn.MouseButton1Click:Connect(function()
            selectedConfig = configInput.Text
            if cb then cb() end
        end)

        mod._optionCount = mod._optionCount + 1
    end

    makeConfigBtn("save config", 1, function()
        lib:SaveConfig(selectedConfig)
    end)

    makeConfigBtn("load config", 2, function()
        lib:LoadConfig(selectedConfig)
    end)

    makeConfigBtn("delete config", 3, function()
        lib:DeleteConfig(selectedConfig)
    end)

    -- dropdown showing available configs
    local configList = {}

    local configDrop = mod:Dropdown("configs", {"default"}, "default", function(val)
        selectedConfig = val
        configInput.Text = val
    end)

    -- refresh function
    local function refreshConfigs()
        local cfgs = lib:GetConfigs()
        if #cfgs == 0 then cfgs = {"default"} end
        -- we can't dynamically rebuild dropdown items easily, but we store reference
        configList = cfgs
    end

    -- refresh on expand
    local origExpanded = mod.HeaderBtn.MouseButton2Click
    -- we'll just refresh periodically when expanded
    task.spawn(function()
        while task.wait(2) do
            if mod.Expanded then refreshConfigs() end
        end
    end)

    return mod
end

function Library:Destroy()
    for _, c in ipairs(self._connections) do
        if c.Disconnect then c:Disconnect() end
    end
    self.ScreenGui:Destroy()
end

return Library
