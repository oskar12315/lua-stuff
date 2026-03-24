local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

local Theme = {
    CategoryBg       = Color3.fromRGB(28, 28, 36),
    CategoryBorder   = Color3.fromRGB(48, 48, 60),
    CategoryHeader   = Color3.fromRGB(200, 200, 215),
    ModuleEnabled    = Color3.fromRGB(230, 140, 180),
    ModuleDisabled   = Color3.fromRGB(185, 185, 195),
    OptionText       = Color3.fromRGB(150, 150, 162),
    OptionValue      = Color3.fromRGB(215, 215, 225),
    Accent           = Color3.fromRGB(230, 140, 180),
    SliderBg         = Color3.fromRGB(42, 42, 52),
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

local CONFIG_FOLDER = "MCClientConfigs"
local AUTO_CONFIG = "_autoload"

local function Create(c, p)
    local i = Instance.new(c)
    if p then
        for k, v in pairs(p) do
            if k ~= "Parent" then pcall(function() i[k] = v end) end
        end
        if p.Parent then i.Parent = p.Parent end
    end
    return i
end

local function Tween(inst, dur, props, style)
    local t = TweenService:Create(inst, TweenInfo.new(dur, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
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

local function SafeWrite(path, content)
    pcall(function() if writefile then writefile(path, content) end end)
end
local function SafeRead(path)
    local ok, r = pcall(function()
        if readfile and isfile and isfile(path) then return readfile(path) end
    end)
    return ok and r or nil
end
local function SafeDelete(path)
    pcall(function() if delfile and isfile and isfile(path) then delfile(path) end end)
end
local function SafeMkdir(path)
    pcall(function() if makefolder and (not isfolder or not isfolder(path)) then makefolder(path) end end)
end
local function SafeList(path)
    local ok, r = pcall(function()
        if listfiles and isfolder and isfolder(path) then return listfiles(path) end
        return {}
    end)
    return ok and r or {}
end

function Library.new(clientName)
    local self = setmetatable({}, Library)
    self.Name = clientName or "Client"
    self.Categories = {}
    self.Visible = true
    self.ToggleKey = Enum.KeyCode.RightShift
    self._modules = {}
    self._options = {}
    self._connections = {}
    self._accentElements = {}
    self._popups = {}
    self._activePopup = nil
    self._unloaded = false

    local existing = LocalPlayer.PlayerGui:FindFirstChild("MCClientUI")
    if existing then existing:Destroy() end

    self.Gui = Create("ScreenGui", {
        Name = "MCClientUI",
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999,
    })

    self.MainFrame = Create("ScrollingFrame", {
        Name = "Main",
        Parent = self.Gui,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0, 16),
        Size = UDim2.new(1, -32, 1, -32),
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

    -- popup layer (renders above everything)
    self.PopupLayer = Create("Frame", {
        Name = "Popups",
        Parent = self.Gui,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100,
    })

    -- click-away to close popups
    local popupClickAway = Create("TextButton", {
        Name = "ClickAway",
        Parent = self.PopupLayer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 99,
        Visible = false,
    })
    self._clickAway = popupClickAway

    popupClickAway.MouseButton1Click:Connect(function()
        self:_closeActivePopup()
    end)

    -- keybind widget
    self:_buildKeybindWidget()

    -- toggle UI
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or self._unloaded then return end
        if input.KeyCode == self.ToggleKey then
            self.Visible = not self.Visible
            self.MainFrame.Visible = self.Visible
            if not self.Visible then self:_closeActivePopup() end
        end
    end))

    -- keybind processing
    local heldKeys = {}
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or self._unloaded then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        heldKeys[input.KeyCode] = true
        for _, m in ipairs(self._modules) do
            if m._bindKey and m._bindKey == input.KeyCode and m._bindKey ~= Enum.KeyCode.Unknown then
                if m._bindMode == "toggle" then
                    m:SetEnabled(not m.Enabled)
                elseif m._bindMode == "hold" then
                    m:SetEnabled(true)
                end
            end
        end
    end))

    table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
        if self._unloaded then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        heldKeys[input.KeyCode] = nil
        for _, m in ipairs(self._modules) do
            if m._bindKey and m._bindKey == input.KeyCode and m._bindMode == "hold" then
                m:SetEnabled(false)
            end
        end
    end))

    SafeMkdir(CONFIG_FOLDER)

    -- auto load last config
    task.defer(function()
        task.wait(0.5)
        self:LoadConfig(AUTO_CONFIG)
    end)

    return self
end

function Library:_closeActivePopup()
    if self._activePopup then
        local popup = self._activePopup
        self._activePopup = nil
        self._clickAway.Visible = false
        if popup.close then popup.close() end
    end
end

function Library:_openPopup(popupData)
    self:_closeActivePopup()
    self._activePopup = popupData
    self._clickAway.Visible = true
end

function Library:_updateAccent(color)
    Theme.Accent = color
    Theme.ModuleEnabled = color
    Theme.ToggleOn = color
    Theme.SliderFill = color
    for _, entry in ipairs(self._accentElements) do
        if entry.inst and entry.inst.Parent then
            pcall(function()
                entry.inst[entry.prop] = color
            end)
        end
    end
    for _, m in ipairs(self._modules) do
        if m.Enabled and m.NameLabel then
            m.NameLabel.TextColor3 = color
        end
        if m.AccentBar then
            m.AccentBar.BackgroundColor3 = color
        end
    end
end

function Library:_trackAccent(inst, prop)
    table.insert(self._accentElements, { inst = inst, prop = prop })
end

-- ═══════════════════════════════
-- KEYBIND WIDGET
-- ═══════════════════════════════
function Library:_buildKeybindWidget()
    self._kbWidget = Create("Frame", {
        Name = "KBWidget",
        Parent = self.Gui,
        BackgroundColor3 = Theme.CategoryBg,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -175, 0.5, -80),
        Size = UDim2.new(0, 155, 0, 26),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self._kbWidget })
    Create("UIStroke", { Color = Theme.CategoryBorder, Thickness = 1, Transparency = 0.4, Parent = self._kbWidget })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = self._kbWidget })

    Create("TextLabel", {
        Parent = self._kbWidget,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Theme.FontBold,
        Text = "KEYBINDS",
        TextColor3 = Theme.CategoryHeader,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    })

    self._kbList = Create("Frame", {
        Parent = self._kbWidget,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
    })
    Create("UIListLayout", { Parent = self._kbList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1) })
    Create("UIListLayout", { Parent = self._kbWidget, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })

    -- drag
    local dragging, dragStart, startPos = false, nil, nil
    self._kbWidget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = self._kbWidget.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            self._kbWidget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- update
    RunService.Heartbeat:Connect(function()
        if self._unloaded or not self._kbWidget.Visible then return end
        for _, c in ipairs(self._kbList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local idx = 0
        for _, m in ipairs(self._modules) do
            if m.Enabled and m._bindKey and m._bindKey ~= Enum.KeyCode.Unknown then
                idx = idx + 1
                local r = Create("Frame", { Parent = self._kbList, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = idx })
                local nl = Create("TextLabel", { Parent = r, BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0), Font = Theme.Font, Text = m.Name, TextColor3 = Theme.Accent, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left })
                self:_trackAccent(nl, "TextColor3")
                Create("TextLabel", { Parent = r, BackgroundTransparency = 1, Position = UDim2.new(0.7, 0, 0, 0), Size = UDim2.new(0.3, 0, 1, 0), Font = Theme.Font, Text = "[" .. m._bindKey.Name .. "]", TextColor3 = Theme.BindText, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Right })
            end
        end
    end)
end

-- ═══════════════════════════════
-- CONFIG
-- ═══════════════════════════════
function Library:SaveConfig(name)
    local data = { options = {}, modules = {} }
    for id, opt in pairs(self._options) do
        local e = { id = id, type = opt.Type }
        if opt.Type == "Toggle" then e.value = opt.Value
        elseif opt.Type == "Slider" then e.value = opt.Value
        elseif opt.Type == "Dropdown" then e.value = opt.Value
        elseif opt.Type == "ColorPicker" then e.value = { opt.Value.R, opt.Value.G, opt.Value.B }
        elseif opt.Type == "Keybind" then
            e.value = opt.Value ~= Enum.KeyCode.Unknown and opt.Value.Name or "Unknown"
            e.mode = opt.Mode or "toggle"
        end
        table.insert(data.options, e)
    end
    for _, m in ipairs(self._modules) do
        table.insert(data.modules, {
            id = m._id,
            enabled = m.Enabled,
            bindKey = m._bindKey and m._bindKey ~= Enum.KeyCode.Unknown and m._bindKey.Name or nil,
            bindMode = m._bindMode,
        })
    end
    SafeMkdir(CONFIG_FOLDER)
    SafeWrite(CONFIG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data))
end

function Library:LoadConfig(name)
    local raw = SafeRead(CONFIG_FOLDER .. "/" .. name .. ".json")
    if not raw then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or not data then return false end

    if data.options then
        for _, e in ipairs(data.options) do
            local opt = self._options[e.id]
            if opt and opt.Set then
                if opt.Type == "Toggle" and e.value ~= nil then opt:Set(e.value)
                elseif opt.Type == "Slider" and e.value then opt:Set(e.value)
                elseif opt.Type == "Dropdown" and e.value then opt:Set(e.value)
                elseif opt.Type == "ColorPicker" and e.value then opt:Set(Color3.new(e.value[1], e.value[2], e.value[3]))
                elseif opt.Type == "Keybind" and e.value then
                    opt:Set(Enum.KeyCode[e.value] or Enum.KeyCode.Unknown, e.mode)
                end
            end
        end
    end
    if data.modules then
        for _, ms in ipairs(data.modules) do
            for _, m in ipairs(self._modules) do
                if m._id == ms.id then
                    m:SetEnabled(ms.enabled or false)
                    if ms.bindKey then m._bindKey = Enum.KeyCode[ms.bindKey] or Enum.KeyCode.Unknown end
                    m._bindMode = ms.bindMode or "toggle"
                    m:_updateBind()
                end
            end
        end
    end
    return true
end

function Library:DeleteConfig(name)
    SafeDelete(CONFIG_FOLDER .. "/" .. name .. ".json")
end

function Library:GetConfigs()
    local files = SafeList(CONFIG_FOLDER)
    local out = {}
    for _, f in ipairs(files) do
        local n = f:match("([^/\\]+)%.json$")
        if n and n ~= AUTO_CONFIG then table.insert(out, n) end
    end
    return out
end

function Library:AutoSave()
    self:SaveConfig(AUTO_CONFIG)
end

-- ═══════════════════════════════
-- UNLOAD
-- ═══════════════════════════════
function Library:Unload()
    self._unloaded = true
    -- auto save before unloading
    self:AutoSave()
    -- disable all modules
    for _, m in ipairs(self._modules) do
        m:SetEnabled(false)
    end
    -- disconnect
    for _, c in ipairs(self._connections) do
        pcall(function() c:Disconnect() end)
    end
    task.wait(0.1)
    self.Gui:Destroy()
end

-- ═══════════════════════════════
-- CATEGORY
-- ═══════════════════════════════
function Library:Category(name)
    local cat = { Name = name, Modules = {}, Library = self }
    local idx = #self.Categories + 1

    cat.Frame = Create("Frame", {
        Name = "Cat_" .. name,
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.CategoryBg,
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 0, 40),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = idx,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = cat.Frame })
    Create("UIStroke", { Color = Theme.CategoryBorder, Thickness = 1, Transparency = 0.4, Parent = cat.Frame })

    local inner = Create("Frame", {
        Parent = cat.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    Create("UIListLayout", { Parent = inner, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) })
    Create("UIPadding", { Parent = inner, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

    Create("TextLabel", {
        Parent = inner,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Font = Theme.FontBold,
        Text = string.upper(name),
        TextColor3 = Theme.CategoryHeader,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    })

    local sepW = Create("Frame", { Parent = inner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6), LayoutOrder = 1 })
    Create("Frame", { Parent = sepW, BackgroundColor3 = Theme.Separator, BackgroundTransparency = 0.5, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1) })

    cat.ModList = Create("Frame", {
        Parent = inner,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
    })
    Create("UIListLayout", { Parent = cat.ModList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) })

    function cat:Module(n) return Library._Module(self, n) end

    table.insert(self.Categories, cat)
    return cat
end

-- ═══════════════════════════════
-- MODULE
-- ═══════════════════════════════
function Library._Module(cat, name)
    local lib = cat.Library
    local mod = {
        Name = name,
        Enabled = false,
        Expanded = false,
        _opts = {},
        _optCount = 0,
        _bindKey = nil,
        _bindMode = "toggle",
        _id = cat.Name .. "." .. name,
        Callback = nil,
    }

    local mi = #cat.Modules + 1

    mod.Container = Create("Frame", {
        Name = "M_" .. name,
        Parent = cat.ModList,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        LayoutOrder = mi,
        ClipsDescendants = true,
    })

    mod.Btn = Create("TextButton", {
        Parent = mod.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        Text = "",
        AutoButtonColor = false,
    })

    mod.NameLabel = Create("TextLabel", {
        Parent = mod.Btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Font = Theme.FontSemi,
        Text = string.lower(name),
        TextColor3 = Theme.ModuleDisabled,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    mod.BindLabel = Create("TextLabel", {
        Parent = mod.Btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -68, 0, 0),
        Size = UDim2.new(0, 65, 1, 0),
        Font = Theme.Font,
        Text = "",
        TextColor3 = Theme.BindText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    mod.OptsFrame = Create("Frame", {
        Parent = mod.Container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 26),
        Size = UDim2.new(1, -8, 0, 0),
        ClipsDescendants = true,
    })

    mod.AccentBar = Create("Frame", {
        Parent = mod.OptsFrame,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, 2, 1, -4),
    })
    lib:_trackAccent(mod.AccentBar, "BackgroundColor3")

    mod.OptsInner = Create("Frame", {
        Parent = mod.OptsFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    mod.OptsLayout = Create("UIListLayout", { Parent = mod.OptsInner, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) })
    Create("UIPadding", { Parent = mod.OptsInner, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8) })

    function mod:_updateBind()
        if self._bindKey and self._bindKey ~= Enum.KeyCode.Unknown then
            self.BindLabel.Text = "[" .. self._bindKey.Name .. "]"
        else
            self.BindLabel.Text = ""
        end
    end

    function mod:SetEnabled(state)
        self.Enabled = state
        Tween(self.NameLabel, 0.15, { TextColor3 = state and Theme.Accent or Theme.ModuleDisabled })
        if self.Callback then self.Callback(state) end
    end

    local function recalc()
        task.defer(function()
            if mod.Expanded then
                local h = mod.OptsLayout.AbsoluteContentSize.Y + 12
                Tween(mod.OptsFrame, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
                Tween(mod.Container, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
            end
        end)
    end

    mod.Btn.MouseButton1Click:Connect(function() mod:SetEnabled(not mod.Enabled) end)

    mod.Btn.MouseButton2Click:Connect(function()
        if mod._optCount == 0 then return end
        mod.Expanded = not mod.Expanded
        if mod.Expanded then
            local h = mod.OptsLayout.AbsoluteContentSize.Y + 12
            Tween(mod.OptsFrame, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
            Tween(mod.Container, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
        else
            lib:_closeActivePopup()
            Tween(mod.OptsFrame, 0.25, { Size = UDim2.new(1, -8, 0, 0) }, Enum.EasingStyle.Quart)
            Tween(mod.Container, 0.25, { Size = UDim2.new(1, 0, 0, 26) }, Enum.EasingStyle.Quart)
        end
    end)

    mod.Btn.MouseEnter:Connect(function()
        if not mod.Enabled then Tween(mod.NameLabel, 0.08, { TextColor3 = Color3.fromRGB(225, 225, 235) }) end
    end)
    mod.Btn.MouseLeave:Connect(function()
        if not mod.Enabled then Tween(mod.NameLabel, 0.08, { TextColor3 = Theme.ModuleDisabled }) end
    end)

    function mod:OnToggle(cb) self.Callback = cb; return self end

    -- ─── TOGGLE ───
    function mod:Toggle(tname, default, callback)
        local id = self._id .. "." .. tname
        local opt = { Type = "Toggle", Value = default or false, Callback = callback }
        self._optCount = self._optCount + 1

        local row = Create("Frame", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self._optCount })
        Create("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -44, 1, 0), Font = Theme.Font, Text = tname, TextColor3 = Theme.OptionText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local bg = Create("Frame", { Parent = row, BackgroundColor3 = opt.Value and Theme.ToggleOn or Theme.ToggleOff, BorderSizePixel = 0, Position = UDim2.new(1, -36, 0.5, -7), Size = UDim2.new(0, 30, 0, 14) })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bg })
        if opt.Value then lib:_trackAccent(bg, "BackgroundColor3") end

        local knob = Create("Frame", { Parent = bg, BackgroundColor3 = Theme.Knob, BorderSizePixel = 0, Position = opt.Value and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5), Size = UDim2.new(0, 10, 0, 10) })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

        local btn = Create("TextButton", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 5 })

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

        btn.MouseButton1Click:Connect(function() opt:Set(not opt.Value) end)

        lib._options[id] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- ─── SLIDER ───
    function mod:Slider(sname, default, min, max, callback, suffix, decimals)
        suffix = suffix or ""; decimals = decimals or 1; default = default or min
        local id = self._id .. "." .. sname
        local opt = { Type = "Slider", Value = default, Callback = callback }
        self._optCount = self._optCount + 1

        local row = Create("Frame", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = self._optCount })
        Create("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 0, 15), Font = Theme.Font, Text = sname, TextColor3 = Theme.OptionText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
        local vl = Create("TextLabel", { Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0.6, 0, 0, 0), Size = UDim2.new(0.4, 0, 0, 15), Font = Theme.FontSemi, Text = tostring(default) .. suffix, TextColor3 = Theme.OptionValue, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right })

        local track = Create("Frame", { Parent = row, BackgroundColor3 = Theme.SliderBg, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 19), Size = UDim2.new(1, 0, 0, 5) })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

        local pct = math.clamp((default - min) / (max - min), 0, 1)
        local fill = Create("Frame", { Parent = track, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.new(pct, 0, 1, 0) })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
        lib:_trackAccent(fill, "BackgroundColor3")

        local knob = Create("Frame", { Parent = track, BackgroundColor3 = Theme.Knob, BorderSizePixel = 0, Position = UDim2.new(pct, -5, 0.5, -5), Size = UDim2.new(0, 10, 0, 10), ZIndex = 3 })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

        local sb = Create("TextButton", { Parent = track, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 14), Position = UDim2.new(0, 0, 0, -7), Text = "", ZIndex = 5 })

        local sliding = false

        local function upd(input)
            local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + (max - min) * p) * (10 ^ decimals) + 0.5) / (10 ^ decimals)
            opt.Value = val; vl.Text = tostring(val) .. suffix
            fill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, -5, 0.5, -5)
            if callback then callback(val) end
        end

        function opt:Set(val)
            val = math.clamp(val, min, max)
            local p = (val - min) / (max - min)
            opt.Value = val; vl.Text = tostring(val) .. suffix
            fill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, -5, 0.5, -5)
            if callback then callback(val) end
        end

        sb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; upd(input) end
        end)
        table.insert(lib._connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end))
        table.insert(lib._connections, UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then upd(input) end
        end))

        lib._options[id] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- ─── DROPDOWN (popup on screen level) ───
    function mod:Dropdown(dname, items, default, callback)
        local id = self._id .. "." .. dname
        local opt = { Type = "Dropdown", Value = default or items[1], Items = items, Callback = callback }
        self._optCount = self._optCount + 1

        local row = Create("Frame", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self._optCount })
        Create("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Font = Theme.Font, Text = dname, TextColor3 = Theme.OptionText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local valBtn = Create("TextButton", {
            Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0), Font = Theme.FontSemi, Text = tostring(opt.Value),
            TextColor3 = Theme.OptionValue, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, AutoButtonColor = false,
        })

        -- popup frame (on popup layer)
        local popFrame = Create("Frame", {
            Parent = lib.PopupLayer,
            BackgroundColor3 = Theme.DropBg,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 120, 0, 0),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 110,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = popFrame })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = popFrame })
        local pLayout = Create("UIListLayout", { Parent = popFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) })
        Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = popFrame })

        local itemBtns = {}
        for i, item in ipairs(items) do
            local ib = Create("TextButton", {
                Parent = popFrame, BackgroundColor3 = Theme.DropBg, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20), Font = Theme.Font, Text = item,
                TextColor3 = (item == opt.Value) and Theme.Accent or Theme.OptionText,
                TextSize = 11, AutoButtonColor = false, LayoutOrder = i, ZIndex = 111,
            })
            if item == opt.Value then lib:_trackAccent(ib, "TextColor3") end
            table.insert(itemBtns, ib)

            ib.MouseEnter:Connect(function() Tween(ib, 0.1, { BackgroundColor3 = Theme.DropHover }) end)
            ib.MouseLeave:Connect(function() Tween(ib, 0.1, { BackgroundColor3 = Theme.DropBg }) end)

            ib.MouseButton1Click:Connect(function()
                opt.Value = item; valBtn.Text = item
                for _, b in ipairs(itemBtns) do b.TextColor3 = (b.Text == item) and Theme.Accent or Theme.OptionText end
                lib:_closeActivePopup()
                if callback then callback(item) end
            end)
        end

        function opt:Set(val)
            opt.Value = val; valBtn.Text = val
            for _, b in ipairs(itemBtns) do b.TextColor3 = (b.Text == val) and Theme.Accent or Theme.OptionText end
            if callback then callback(val) end
        end

        valBtn.MouseButton1Click:Connect(function()
            if lib._activePopup and lib._activePopup.frame == popFrame then
                lib:_closeActivePopup()
                return
            end
            local absPos = valBtn.AbsolutePosition
            local absSize = valBtn.AbsoluteSize
            popFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
            popFrame.Size = UDim2.new(0, math.max(absSize.X, 100), 0, 0)
            popFrame.Visible = true
            local targetH = #items * 20 + 4
            Tween(popFrame, 0.2, { Size = UDim2.new(0, math.max(absSize.X, 100), 0, targetH) }, Enum.EasingStyle.Quart)

            lib:_openPopup({
                frame = popFrame,
                close = function()
                    Tween(popFrame, 0.15, { Size = UDim2.new(0, popFrame.AbsoluteSize.X, 0, 0) }, Enum.EasingStyle.Quart)
                    task.delay(0.15, function() popFrame.Visible = false end)
                end,
            })
        end)

        lib._options[id] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- ─── COLOR PICKER (popup on screen level) ───
    function mod:ColorPicker(cname, default, callback)
        default = default or Color3.new(1, 0, 0)
        local h, s, v = HSVfromRGB(default)
        local id = self._id .. "." .. cname
        local opt = { Type = "ColorPicker", Value = default, Callback = callback }
        self._optCount = self._optCount + 1

        local row = Create("Frame", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self._optCount })
        Create("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 22), Font = Theme.Font, Text = cname, TextColor3 = Theme.OptionText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local preview = Create("TextButton", {
            Parent = row, BackgroundColor3 = default, BorderSizePixel = 0,
            Position = UDim2.new(1, -20, 0.5, -6), Size = UDim2.new(0, 16, 0, 12),
            Text = "", AutoButtonColor = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = preview })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = preview })

        -- popup picker
        local panel = Create("Frame", {
            Parent = lib.PopupLayer,
            BackgroundColor3 = Theme.PickerBg,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 180, 0, 100),
            Visible = false,
            ZIndex = 110,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = panel })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = panel })

        -- SV box
        local svBox = Create("Frame", {
            Parent = panel, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -32, 1, -16),
            ZIndex = 111, ClipsDescendants = true,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = svBox })

        local hueOv = Create("Frame", { Parent = svBox, BackgroundColor3 = Color3.fromHSV(h, 1, 1), Size = UDim2.new(1, 0, 1, 0), ZIndex = 112 })
        Create("UIGradient", { Parent = hueOv, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) })

        local blackOv = Create("Frame", { Parent = svBox, BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.new(1, 0, 1, 0), ZIndex = 113 })
        Create("UIGradient", { Parent = blackOv, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }), Rotation = 90 })

        local svCur = Create("Frame", { Parent = svBox, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.new(s, -5, 1 - v, -5), Size = UDim2.new(0, 10, 0, 10), ZIndex = 116 })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCur })
        Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5, Parent = svCur })

        local svBtn = Create("TextButton", { Parent = svBox, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 117 })

        -- Hue bar
        local hueBar = Create("Frame", { Parent = panel, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.new(1, -20, 0, 8), Size = UDim2.new(0, 10, 1, -16), ZIndex = 111 })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = hueBar })
        Create("UIGradient", {
            Parent = hueBar, Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
            }),
        })

        local hueCur = Create("Frame", { Parent = hueBar, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.new(0, -2, h, -2), Size = UDim2.new(1, 4, 0, 4), ZIndex = 116 })
        Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = hueCur })
        Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = hueCur })

        local hueBtn = Create("TextButton", { Parent = hueBar, BackgroundTransparency = 1, Size = UDim2.new(1, 8, 1, 0), Position = UDim2.new(0, -4, 0, 0), Text = "", ZIndex = 117 })

        local dragSV, dragH = false, false

        local function updateCol()
            opt.Value = Color3.fromHSV(math.clamp(h, 0, 0.999), s, v)
            preview.BackgroundColor3 = opt.Value
            hueOv.BackgroundColor3 = Color3.fromHSV(math.clamp(h, 0, 0.999), 1, 1)
            svCur.Position = UDim2.new(s, -5, 1 - v, -5)
            hueCur.Position = UDim2.new(0, -2, h, -2)
            if callback then callback(opt.Value) end
        end

        function opt:Set(color)
            h, s, v = HSVfromRGB(color)
            updateCol()
        end

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
        table.insert(lib._connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = false; dragH = false end
        end))
        table.insert(lib._connections, UserInputService.InputChanged:Connect(function(input)
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
        end))

        preview.MouseButton1Click:Connect(function()
            if lib._activePopup and lib._activePopup.frame == panel then
                lib:_closeActivePopup()
                return
            end
            local absPos = preview.AbsolutePosition
            panel.Position = UDim2.new(0, absPos.X - 160, 0, absPos.Y + 16)
            panel.Visible = true

            lib:_openPopup({
                frame = panel,
                close = function()
                    panel.Visible = false
                    dragSV = false; dragH = false
                end,
            })
        end)

        lib._options[id] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- ─── KEYBIND (with right-click mode popup) ───
    function mod:Keybind(kname, default, callback)
        default = default or Enum.KeyCode.Unknown
        local id = self._id .. "." .. kname
        local opt = { Type = "Keybind", Value = default, Mode = "toggle", Callback = callback }
        self._optCount = self._optCount + 1

        mod._bindKey = default
        mod._bindMode = "toggle"
        mod:_updateBind()

        local row = Create("Frame", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self._optCount })
        Create("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.4, 0, 1, 0), Font = Theme.Font, Text = kname, TextColor3 = Theme.OptionText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local bindBtn = Create("TextButton", {
            Parent = row, BackgroundColor3 = Theme.DropBg, BorderSizePixel = 0,
            Position = UDim2.new(1, -55, 0.5, -9), Size = UDim2.new(0, 52, 0, 18),
            Font = Theme.Font, Text = default ~= Enum.KeyCode.Unknown and default.Name or "none",
            TextColor3 = Theme.OptionValue, TextSize = 10, AutoButtonColor = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = bindBtn })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = bindBtn })

        local listening = false

        -- mode popup
        local modeFrame = Create("Frame", {
            Parent = lib.PopupLayer,
            BackgroundColor3 = Theme.DropBg,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 80, 0, 0),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 110,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = modeFrame })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = modeFrame })
        Create("UIListLayout", { Parent = modeFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) })
        Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = modeFrame })

        local modes = { "toggle", "hold", "always" }
        local modeBtns = {}
        for i, m in ipairs(modes) do
            local mb = Create("TextButton", {
                Parent = modeFrame, BackgroundColor3 = Theme.DropBg, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20), Font = Theme.Font, Text = m,
                TextColor3 = (m == opt.Mode) and Theme.Accent or Theme.OptionText,
                TextSize = 11, AutoButtonColor = false, LayoutOrder = i, ZIndex = 111,
            })
            table.insert(modeBtns, mb)
            mb.MouseEnter:Connect(function() Tween(mb, 0.1, { BackgroundColor3 = Theme.DropHover }) end)
            mb.MouseLeave:Connect(function() Tween(mb, 0.1, { BackgroundColor3 = Theme.DropBg }) end)
            mb.MouseButton1Click:Connect(function()
                opt.Mode = m; mod._bindMode = m
                for _, b in ipairs(modeBtns) do b.TextColor3 = (b.Text == m) and Theme.Accent or Theme.OptionText end
                lib:_closeActivePopup()
                if m == "always" then mod:SetEnabled(true) end
            end)
        end

        -- left click: listen
        bindBtn.MouseButton1Click:Connect(function()
            listening = true
            bindBtn.Text = "..."
            Tween(bindBtn, 0.1, { TextColor3 = Theme.Accent })
        end)

        -- right click: mode popup
        bindBtn.MouseButton2Click:Connect(function()
            if lib._activePopup and lib._activePopup.frame == modeFrame then
                lib:_closeActivePopup(); return
            end
            local ap = bindBtn.AbsolutePosition
            local as = bindBtn.AbsoluteSize
            modeFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 2)
            modeFrame.Size = UDim2.new(0, 80, 0, 0)
            modeFrame.Visible = true
            Tween(modeFrame, 0.2, { Size = UDim2.new(0, 80, 0, #modes * 20 + 4) }, Enum.EasingStyle.Quart)
            lib:_openPopup({
                frame = modeFrame,
                close = function()
                    Tween(modeFrame, 0.15, { Size = UDim2.new(0, 80, 0, 0) }, Enum.EasingStyle.Quart)
                    task.delay(0.15, function() modeFrame.Visible = false end)
                end,
            })
        end)

        table.insert(lib._connections, UserInputService.InputBegan:Connect(function(input, gpe)
            if not listening then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    opt.Value = Enum.KeyCode.Unknown; bindBtn.Text = "none"
                    mod._bindKey = Enum.KeyCode.Unknown
                else
                    opt.Value = input.KeyCode; bindBtn.Text = input.KeyCode.Name
                    mod._bindKey = input.KeyCode
                end
                mod:_updateBind()
                Tween(bindBtn, 0.1, { TextColor3 = Theme.OptionValue })
                listening = false
            end
        end))

        function opt:Set(key, mode)
            opt.Value = key; mod._bindKey = key
            bindBtn.Text = key ~= Enum.KeyCode.Unknown and key.Name or "none"
            if mode then
                opt.Mode = mode; mod._bindMode = mode
                for _, b in ipairs(modeBtns) do b.TextColor3 = (b.Text == mode) and Theme.Accent or Theme.OptionText end
            end
            mod:_updateBind()
        end

        lib._options[id] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- ─── LABEL ───
    function mod:Label(text)
        self._optCount = self._optCount + 1
        Create("TextLabel", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Theme.Font, Text = text, TextColor3 = Theme.BindText, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = self._optCount })
        task.defer(recalc)
    end

    -- ─── SEPARATOR ───
    function mod:Separator()
        self._optCount = self._optCount + 1
        local s = Create("Frame", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6), LayoutOrder = self._optCount })
        Create("Frame", { Parent = s, BackgroundColor3 = Theme.Separator, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1) })
        task.defer(recalc)
    end

    -- ─── BUTTON ───
    function mod:Button(text, callback)
        self._optCount = self._optCount + 1
        local btn = Create("TextButton", {
            Parent = self.OptsInner, BackgroundColor3 = Theme.DropBg, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 22), Font = Theme.FontSemi, Text = text,
            TextColor3 = Theme.OptionValue, TextSize = 11, AutoButtonColor = false, LayoutOrder = self._optCount,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = btn })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = btn })
        btn.MouseEnter:Connect(function() Tween(btn, 0.1, { BackgroundColor3 = Theme.DropHover }) end)
        btn.MouseLeave:Connect(function() Tween(btn, 0.1, { BackgroundColor3 = Theme.DropBg }) end)
        btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        task.defer(recalc)
    end

    -- ─── TEXTBOX ───
    function mod:TextBox(tname, default, placeholder, callback)
        self._optCount = self._optCount + 1
        local id = self._id .. "." .. tname
        local opt = { Type = "TextBox", Value = default or "" }

        local row = Create("Frame", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = self._optCount })
        Create("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Font = Theme.Font, Text = tname, TextColor3 = Theme.OptionText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local tb = Create("TextBox", {
            Parent = row, BackgroundColor3 = Theme.DropBg, BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 16), Size = UDim2.new(1, 0, 0, 18),
            Font = Theme.Font, Text = default or "", PlaceholderText = placeholder or "",
            PlaceholderColor3 = Theme.BindText, TextColor3 = Theme.OptionValue,
            TextSize = 11, ClearTextOnFocus = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = tb })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = tb })
        Create("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = tb })

        tb.FocusLost:Connect(function()
            opt.Value = tb.Text
            if callback then callback(tb.Text) end
        end)

        function opt:Set(val) tb.Text = val; opt.Value = val end
        function opt:Get() return tb.Text end

        lib._options[id] = opt
        task.defer(recalc)
        return opt
    end

    table.insert(cat.Modules, mod)
    table.insert(lib._modules, mod)
    return mod
end

return Library
