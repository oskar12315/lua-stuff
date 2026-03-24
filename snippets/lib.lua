local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

local Theme = {
    CategoryBg     = Color3.fromRGB(28, 28, 36),
    CategoryBorder = Color3.fromRGB(48, 48, 60),
    CategoryHeader = Color3.fromRGB(200, 200, 215),
    ModuleEnabled  = Color3.fromRGB(230, 140, 180),
    ModuleDisabled = Color3.fromRGB(185, 185, 195),
    OptionText     = Color3.fromRGB(150, 150, 162),
    OptionValue    = Color3.fromRGB(215, 215, 225),
    Accent         = Color3.fromRGB(230, 140, 180),
    SliderBg       = Color3.fromRGB(42, 42, 52),
    ToggleOn       = Color3.fromRGB(230, 140, 180),
    ToggleOff      = Color3.fromRGB(55, 55, 68),
    Knob           = Color3.fromRGB(220, 220, 230),
    DropBg         = Color3.fromRGB(32, 32, 42),
    DropHover      = Color3.fromRGB(48, 48, 60),
    DropBorder     = Color3.fromRGB(55, 55, 68),
    BindText       = Color3.fromRGB(120, 120, 135),
    Separator      = Color3.fromRGB(42, 42, 52),
    PickerBg       = Color3.fromRGB(30, 30, 38),
    SearchBg       = Color3.fromRGB(32, 32, 40),
    SearchBorder   = Color3.fromRGB(55, 55, 65),
    SearchText     = Color3.fromRGB(180, 180, 190),
    Font           = Enum.Font.Gotham,
    FontSemi       = Enum.Font.GothamSemibold,
    FontBold       = Enum.Font.GothamBold,
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

local function Tw(inst, dur, props, style)
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

local function SafeWrite(p, c) pcall(function() if writefile then writefile(p, c) end end) end
local function SafeRead(p)
    local ok, r = pcall(function() if readfile and isfile and isfile(p) then return readfile(p) end end)
    return ok and r or nil
end
local function SafeDelete(p) pcall(function() if delfile and isfile and isfile(p) then delfile(p) end end) end
local function SafeMkdir(p) pcall(function() if makefolder and (not isfolder or not isfolder(p)) then makefolder(p) end end) end
local function SafeList(p)
    local ok, r = pcall(function() if listfiles and isfolder and isfolder(p) then return listfiles(p) end return {} end)
    return ok and r or {}
end

-- ═══════════════════════════════
-- CENTRALIZED INPUT MANAGER
-- ═══════════════════════════════
-- prevents duplicate connections per slider/picker
local InputManager = {}
InputManager._sliders = {}
InputManager._svDrags = {}
InputManager._hueDrags = {}
InputManager._initialized = false

function InputManager.Init(lib)
    if InputManager._initialized then return end
    InputManager._initialized = true

    table.insert(lib._connections, UserInputService.InputChanged:Connect(function(input)
        if lib._unloaded then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            for _, sd in ipairs(InputManager._sliders) do
                if sd.active then sd.update(input) end
            end
            for _, sv in ipairs(InputManager._svDrags) do
                if sv.active then sv.update(input) end
            end
            for _, hd in ipairs(InputManager._hueDrags) do
                if hd.active then hd.update(input) end
            end
        end
    end))

    table.insert(lib._connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, sd in ipairs(InputManager._sliders) do sd.active = false end
            for _, sv in ipairs(InputManager._svDrags) do sv.active = false end
            for _, hd in ipairs(InputManager._hueDrags) do hd.active = false end
        end
    end))
end

function InputManager.AddSlider(data)
    table.insert(InputManager._sliders, data)
end
function InputManager.AddSVDrag(data)
    table.insert(InputManager._svDrags, data)
end
function InputManager.AddHueDrag(data)
    table.insert(InputManager._hueDrags, data)
end

-- ═══════════════════════════════
-- LIBRARY
-- ═══════════════════════════════
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
    self._activePopup = nil
    self._unloaded = false
    self._keybindListening = {}

    local existing = LocalPlayer.PlayerGui:FindFirstChild("MCClientUI")
    if existing then existing:Destroy() end

    self.Gui = Create("ScreenGui", {
        Name = "MCClientUI",
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999,
    })

    -- search bar at top
    self:_buildSearchBar()

    -- main columns container
    self.MainFrame = Create("ScrollingFrame", {
        Name = "Main",
        Parent = self.Gui,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0, 52),
        Size = UDim2.new(1, -32, 1, -60),
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
    Create("UIPadding", { Parent = self.MainFrame, PaddingLeft = UDim.new(0, 4), PaddingTop = UDim.new(0, 4) })

    -- popup layer
    self.PopupLayer = Create("Frame", {
        Name = "Popups",
        Parent = self.Gui,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100,
    })

    self._clickAway = Create("TextButton", {
        Parent = self.PopupLayer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 99,
        Visible = false,
    })
    self._clickAway.MouseButton1Click:Connect(function() self:_closePopup() end)

    -- keybind widget
    self:_buildKeybindWidget()

    -- init centralized input
    InputManager.Init(self)

    -- toggle UI with RightShift
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or self._unloaded then return end
        if input.KeyCode == self.ToggleKey then
            self.Visible = not self.Visible
            self.MainFrame.Visible = self.Visible
            self._searchFrame.Visible = self.Visible
            if not self.Visible then self:_closePopup() end
        end
    end))

    -- keybind processing
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or self._unloaded then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        -- check if any keybind is listening
        for _, kl in ipairs(self._keybindListening) do
            if kl.active then
                if input.KeyCode == Enum.KeyCode.Escape then
                    kl.set(Enum.KeyCode.Unknown)
                else
                    kl.set(input.KeyCode)
                end
                kl.active = false
                return
            end
        end

        -- process module keybinds
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
        for _, m in ipairs(self._modules) do
            if m._bindKey and m._bindKey == input.KeyCode and m._bindMode == "hold" then
                m:SetEnabled(false)
            end
        end
    end))

    SafeMkdir(CONFIG_FOLDER)
    task.defer(function()
        task.wait(0.5)
        self:LoadConfig(AUTO_CONFIG)
    end)

    return self
end

-- ═══════════════════════════════
-- SEARCH BAR
-- ═══════════════════════════════
function Library:_buildSearchBar()
    self._searchFrame = Create("Frame", {
        Parent = self.Gui,
        BackgroundColor3 = Theme.SearchBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(0, 280, 0, 30),
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self._searchFrame })
    Create("UIStroke", { Color = Theme.SearchBorder, Thickness = 1, Transparency = 0.3, Parent = self._searchFrame })

    -- search icon
    local icon = Create("ImageLabel", {
        Parent = self._searchFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -28, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Image = "rbxassetid://132302594577680",
        ImageColor3 = Theme.BindText,
        ZIndex = 5,
    })

    self._searchBox = Create("TextBox", {
        Parent = self._searchFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Theme.Font,
        Text = "",
        PlaceholderText = "search modules...",
        PlaceholderColor3 = Theme.BindText,
        TextColor3 = Theme.SearchText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })

    -- results dropdown
    self._searchResults = Create("Frame", {
        Parent = self._searchFrame,
        BackgroundColor3 = Theme.DropBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 200,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = self._searchResults })
    Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = self._searchResults })

    self._searchResultsLayout = Create("UIListLayout", {
        Parent = self._searchResults,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })
    Create("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), Parent = self._searchResults })

    self._searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:_updateSearch()
    end)

    self._searchBox.Focused:Connect(function()
        self:_updateSearch()
    end)

    self._searchBox.FocusLost:Connect(function()
        task.delay(0.15, function()
            self._searchResults.Visible = false
            Tw(self._searchResults, 0.15, { Size = UDim2.new(1, 0, 0, 0) })
        end)
    end)
end

function Library:_updateSearch()
    local query = string.lower(self._searchBox.Text)

    -- clear old results
    for _, c in ipairs(self._searchResults:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    if query == "" then
        self._searchResults.Visible = false
        Tw(self._searchResults, 0.15, { Size = UDim2.new(1, 0, 0, 0) })
        return
    end

    local results = {}
    for _, m in ipairs(self._modules) do
        local name = string.lower(m.Name)
        local cat = string.lower(m._catName)
        if string.find(name, query, 1, true) or string.find(cat, query, 1, true) then
            table.insert(results, m)
        end
        -- also search option names
        if #results < 20 then
            for _, opt in ipairs(m._opts) do
                if opt._name and string.find(string.lower(opt._name), query, 1, true) then
                    local found = false
                    for _, r in ipairs(results) do
                        if r == m then found = true; break end
                    end
                    if not found then table.insert(results, m) end
                end
            end
        end
    end

    if #results == 0 then
        self._searchResults.Visible = false
        Tw(self._searchResults, 0.15, { Size = UDim2.new(1, 0, 0, 0) })
        return
    end

    local maxShow = math.min(#results, 8)
    for i = 1, maxShow do
        local m = results[i]
        local rb = Create("TextButton", {
            Parent = self._searchResults,
            BackgroundColor3 = Theme.DropBg,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 24),
            Font = Theme.Font,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = i,
            ZIndex = 201,
        })

        Create("TextLabel", {
            Parent = rb,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0.6, -10, 1, 0),
            Font = Theme.FontSemi,
            Text = string.lower(m.Name),
            TextColor3 = Theme.OptionValue,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 202,
        })

        Create("TextLabel", {
            Parent = rb,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.6, 0, 0, 0),
            Size = UDim2.new(0.4, -8, 1, 0),
            Font = Theme.Font,
            Text = string.lower(m._catName),
            TextColor3 = Theme.BindText,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 202,
        })

        rb.MouseEnter:Connect(function() Tw(rb, 0.08, { BackgroundColor3 = Theme.DropHover }) end)
        rb.MouseLeave:Connect(function() Tw(rb, 0.08, { BackgroundColor3 = Theme.DropBg }) end)

        rb.MouseButton1Click:Connect(function()
            self._searchResults.Visible = false
            self._searchBox.Text = ""
            self:_pulseModule(m)
        end)
    end

    self._searchResults.Visible = true
    local targetH = maxShow * 24 + 6
    Tw(self._searchResults, 0.2, { Size = UDim2.new(1, 0, 0, targetH) }, Enum.EasingStyle.Quart)
end

function Library:_pulseModule(mod)
    -- make sure category is expanded
    if mod._catRef and mod._catRef._collapsed then
        mod._catRef:_setCollapsed(false)
    end

    -- scroll into view if needed (flash the module)
    local container = mod.Container
    if not container then return end

    -- pulse animation: flash 3 times
    task.spawn(function()
        for i = 1, 3 do
            Tw(container, 0.15, { BackgroundTransparency = 0 })
            container.BackgroundColor3 = Theme.Accent
            task.wait(0.2)
            Tw(container, 0.2, { BackgroundTransparency = 1 })
            task.wait(0.25)
        end
    end)
end

-- ═══════════════════════════════
-- KEYBIND WIDGET
-- ═══════════════════════════════
function Library:_buildKeybindWidget()
    self._kbWidget = Create("Frame", {
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
    Create("UIListLayout", { Parent = self._kbWidget, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })

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

    local dragging, dragStart, startPos = false, nil, nil
    self._kbWidget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = self._kbWidget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            self._kbWidget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))

    local lastUpdate = 0
    RunService.Heartbeat:Connect(function()
        if self._unloaded or not self._kbWidget.Visible then return end
        lastUpdate = lastUpdate + 1
        if lastUpdate % 10 ~= 0 then return end -- throttle updates
        for _, c in ipairs(self._kbList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local idx = 0
        for _, m in ipairs(self._modules) do
            if m.Enabled and m._bindKey and m._bindKey ~= Enum.KeyCode.Unknown then
                idx = idx + 1
                local r = Create("Frame", { Parent = self._kbList, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = idx })
                Create("TextLabel", { Parent = r, BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0), Font = Theme.Font, Text = m.Name, TextColor3 = Theme.Accent, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left })
                Create("TextLabel", { Parent = r, BackgroundTransparency = 1, Position = UDim2.new(0.7, 0, 0, 0), Size = UDim2.new(0.3, 0, 1, 0), Font = Theme.Font, Text = "[" .. m._bindKey.Name .. "]", TextColor3 = Theme.BindText, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Right })
            end
        end
    end)
end

-- ═══════════════════════════════
-- POPUP MANAGEMENT
-- ═══════════════════════════════
function Library:_closePopup()
    if self._activePopup then
        local p = self._activePopup
        self._activePopup = nil
        self._clickAway.Visible = false
        if p.close then p.close() end
    end
end

function Library:_openPopup(data)
    self:_closePopup()
    self._activePopup = data
    self._clickAway.Visible = true
end

-- ═══════════════════════════════
-- ACCENT
-- ═══════════════════════════════
function Library:_updateAccent(color)
    Theme.Accent = color
    Theme.ModuleEnabled = color
    Theme.ToggleOn = color
    Theme.SliderFill = color
    for _, e in ipairs(self._accentElements) do
        if e.inst and e.inst.Parent then
            pcall(function() e.inst[e.prop] = color end)
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
                pcall(function()
                    if opt.Type == "Toggle" and e.value ~= nil then opt:Set(e.value)
                    elseif opt.Type == "Slider" and e.value then opt:Set(e.value)
                    elseif opt.Type == "Dropdown" and e.value then opt:Set(e.value)
                    elseif opt.Type == "ColorPicker" and e.value then opt:Set(Color3.new(e.value[1], e.value[2], e.value[3]))
                    elseif opt.Type == "Keybind" and e.value then
                        opt:Set(Enum.KeyCode[e.value] or Enum.KeyCode.Unknown, e.mode)
                    end
                end)
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

function Library:DeleteConfig(name) SafeDelete(CONFIG_FOLDER .. "/" .. name .. ".json") end

function Library:GetConfigs()
    local files = SafeList(CONFIG_FOLDER)
    local out = {}
    for _, f in ipairs(files) do
        local n = f:match("([^/\\]+)%.json$")
        if n and n ~= AUTO_CONFIG then table.insert(out, n) end
    end
    return out
end

function Library:AutoSave() self:SaveConfig(AUTO_CONFIG) end

function Library:Unload()
    self._unloaded = true
    self:AutoSave()
    for _, m in ipairs(self._modules) do m:SetEnabled(false) end
    for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    task.wait(0.1)
    self.Gui:Destroy()
end

-- ═══════════════════════════════
-- CATEGORY (with collapsible header)
-- ═══════════════════════════════
function Library:Category(name)
    local cat = { Name = name, Modules = {}, Library = self, _collapsed = false }
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
        ClipsDescendants = true,
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
    Create("UIPadding", { Parent = inner, PaddingTop = UDim.new(0, 0), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

    -- clickable header
    local headerBtn = Create("TextButton", {
        Parent = inner,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Font = Theme.FontBold,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 0,
    })

    local headerLabel = Create("TextLabel", {
        Parent = headerBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Theme.FontBold,
        Text = string.upper(name),
        TextColor3 = Theme.CategoryHeader,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local collapseArrow = Create("TextLabel", {
        Parent = headerBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 0, 0),
        Size = UDim2.new(0, 14, 1, 0),
        Font = Theme.Font,
        Text = "▼",
        TextColor3 = Theme.BindText,
        TextSize = 9,
    })

    -- separator
    local sepW = Create("Frame", { Parent = inner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 4), LayoutOrder = 1 })
    Create("Frame", { Parent = sepW, BackgroundColor3 = Theme.Separator, BackgroundTransparency = 0.5, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1) })

    -- module list wrapper (this gets hidden on collapse)
    cat.ModListWrapper = Create("Frame", {
        Parent = inner,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        ClipsDescendants = true,
    })

    cat.ModList = Create("Frame", {
        Parent = cat.ModListWrapper,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    Create("UIListLayout", { Parent = cat.ModList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) })

    cat._innerFrame = inner

    function cat:_setCollapsed(collapsed)
        cat._collapsed = collapsed
        if collapsed then
            collapseArrow.Text = "▶"
            Tw(cat.ModListWrapper, 0.3, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quart)
            Tw(sepW, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
        else
            collapseArrow.Text = "▼"
            cat.ModListWrapper.AutomaticSize = Enum.AutomaticSize.None
            task.defer(function()
                local targetH = cat.ModList.AbsoluteSize.Y
                Tw(cat.ModListWrapper, 0.3, { Size = UDim2.new(1, 0, 0, targetH) }, Enum.EasingStyle.Quart)
                task.delay(0.35, function()
                    cat.ModListWrapper.AutomaticSize = Enum.AutomaticSize.Y
                end)
            end)
            Tw(sepW, 0.2, { Size = UDim2.new(1, 0, 0, 4) })
        end
    end

    headerBtn.MouseButton1Click:Connect(function()
        cat:_setCollapsed(not cat._collapsed)
    end)

    headerBtn.MouseEnter:Connect(function()
        Tw(headerLabel, 0.1, { TextColor3 = Color3.fromRGB(235, 235, 245) })
    end)
    headerBtn.MouseLeave:Connect(function()
        Tw(headerLabel, 0.1, { TextColor3 = Theme.CategoryHeader })
    end)

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
        _catName = cat.Name,
        _catRef = cat,
        Callback = nil,
    }

    local mi = #cat.Modules + 1

    mod.Container = Create("Frame", {
        Name = "M_" .. name,
        Parent = cat.ModList,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
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
        Size = UDim2.new(1, -72, 1, 0),
        Font = Theme.FontSemi,
        Text = string.lower(name),
        TextColor3 = Theme.ModuleDisabled,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    mod.BindLabel = Create("TextLabel", {
        Parent = mod.Btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.new(0, 68, 1, 0),
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
        Tw(self.NameLabel, 0.15, { TextColor3 = state and Theme.Accent or Theme.ModuleDisabled })
        if self.Callback then pcall(self.Callback, state) end
    end

    local function recalc()
        task.defer(function()
            if mod.Expanded then
                local h = mod.OptsLayout.AbsoluteContentSize.Y + 12
                Tw(mod.OptsFrame, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
                Tw(mod.Container, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
            end
        end)
    end

    mod.Btn.MouseButton1Click:Connect(function() mod:SetEnabled(not mod.Enabled) end)

    mod.Btn.MouseButton2Click:Connect(function()
        if mod._optCount == 0 then return end
        mod.Expanded = not mod.Expanded
        if mod.Expanded then
            local h = mod.OptsLayout.AbsoluteContentSize.Y + 12
            Tw(mod.OptsFrame, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
            Tw(mod.Container, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
        else
            lib:_closePopup()
            Tw(mod.OptsFrame, 0.25, { Size = UDim2.new(1, -8, 0, 0) }, Enum.EasingStyle.Quart)
            Tw(mod.Container, 0.25, { Size = UDim2.new(1, 0, 0, 26) }, Enum.EasingStyle.Quart)
        end
    end)

    mod.Btn.MouseEnter:Connect(function()
        if not mod.Enabled then Tw(mod.NameLabel, 0.08, { TextColor3 = Color3.fromRGB(225, 225, 235) }) end
    end)
    mod.Btn.MouseLeave:Connect(function()
        if not mod.Enabled then Tw(mod.NameLabel, 0.08, { TextColor3 = Theme.ModuleDisabled }) end
    end)

    function mod:OnToggle(cb) self.Callback = cb; return self end

    -- ═══════ OPTIONS ═══════

    -- TOGGLE
    function mod:Toggle(tname, default, callback)
        local id = self._id .. "." .. tname
        local opt = { Type = "Toggle", Value = default or false, Callback = callback, _name = tname }
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
            Tw(bg, 0.2, { BackgroundColor3 = val and Theme.ToggleOn or Theme.ToggleOff })
            Tw(knob, 0.2, { Position = val and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5) })
            if opt.Callback then pcall(opt.Callback, val) end
        end

        btn.MouseButton1Click:Connect(function() opt:Set(not opt.Value) end)

        lib._options[id] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- SLIDER
    function mod:Slider(sname, default, min, max, callback, suffix, decimals)
        suffix = suffix or ""; decimals = decimals or 1; default = default or min
        local id = self._id .. "." .. sname
        local opt = { Type = "Slider", Value = default, Callback = callback, _name = sname }
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

        local sliderData = { active = false }
        sliderData.update = function(input)
            local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + (max - min) * p) * (10 ^ decimals) + 0.5) / (10 ^ decimals)
            opt.Value = val; vl.Text = tostring(val) .. suffix
            fill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, -5, 0.5, -5)
            if callback then callback(val) end
        end
        InputManager.AddSlider(sliderData)

        function opt:Set(val)
            val = math.clamp(val, min, max)
            local p = (val - min) / (max - min)
            opt.Value = val; vl.Text = tostring(val) .. suffix
            fill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, -5, 0.5, -5)
            if callback then callback(val) end
        end

        sb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliderData.active = true; sliderData.update(input)
            end
        end)

        lib._options[id] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- DROPDOWN (popup)
    function mod:Dropdown(dname, items, default, callback)
        local id = self._id .. "." .. dname
        local opt = { Type = "Dropdown", Value = default or items[1], Items = items, Callback = callback, _name = dname }
        self._optCount = self._optCount + 1

        local row = Create("Frame", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self._optCount })
        Create("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Font = Theme.Font, Text = dname, TextColor3 = Theme.OptionText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local valBtn = Create("TextButton", {
            Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0), Font = Theme.FontSemi, Text = tostring(opt.Value),
            TextColor3 = Theme.OptionValue, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, AutoButtonColor = false,
        })

        local popFrame = Create("Frame", {
            Parent = lib.PopupLayer, BackgroundColor3 = Theme.DropBg, BorderSizePixel = 0,
            Size = UDim2.new(0, 120, 0, 0), ClipsDescendants = true, Visible = false, ZIndex = 110,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = popFrame })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = popFrame })
        Create("UIListLayout", { Parent = popFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) })
        Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = popFrame })

        local itemBtns = {}
        for i, item in ipairs(items) do
            local ib = Create("TextButton", {
                Parent = popFrame, BackgroundColor3 = Theme.DropBg, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 22), Font = Theme.Font, Text = item,
                TextColor3 = (item == opt.Value) and Theme.Accent or Theme.OptionText,
                TextSize = 11, AutoButtonColor = false, LayoutOrder = i, ZIndex = 111,
            })
            table.insert(itemBtns, ib)
            ib.MouseEnter:Connect(function() Tw(ib, 0.08, { BackgroundColor3 = Theme.DropHover }) end)
            ib.MouseLeave:Connect(function() Tw(ib, 0.08, { BackgroundColor3 = Theme.DropBg }) end)
            ib.MouseButton1Click:Connect(function()
                opt.Value = item; valBtn.Text = item
                for _, b in ipairs(itemBtns) do b.TextColor3 = (b.Text == item) and Theme.Accent or Theme.OptionText end
                lib:_closePopup()
                if callback then callback(item) end
            end)
        end

        function opt:Set(val)
            opt.Value = val; valBtn.Text = val
            for _, b in ipairs(itemBtns) do b.TextColor3 = (b.Text == val) and Theme.Accent or Theme.OptionText end
            if callback then callback(val) end
        end

        valBtn.MouseButton1Click:Connect(function()
            if lib._activePopup and lib._activePopup.frame == popFrame then lib:_closePopup(); return end
            local ap = valBtn.AbsolutePosition; local as = valBtn.AbsoluteSize
            popFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 2)
            popFrame.Size = UDim2.new(0, math.max(as.X, 100), 0, 0)
            popFrame.Visible = true
            Tw(popFrame, 0.2, { Size = UDim2.new(0, math.max(as.X, 100), 0, #items * 22 + 4) }, Enum.EasingStyle.Quart)
            lib:_openPopup({
                frame = popFrame,
                close = function()
                    Tw(popFrame, 0.15, { Size = UDim2.new(0, popFrame.AbsoluteSize.X, 0, 0) }, Enum.EasingStyle.Quart)
                    task.delay(0.15, function() popFrame.Visible = false end)
                end,
            })
        end)

        lib._options[id] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- COLOR PICKER (popup)
    function mod:ColorPicker(cname, default, callback)
        default = default or Color3.new(1, 0, 0)
        local h, s, v = HSVfromRGB(default)
        local id = self._id .. "." .. cname
        local opt = { Type = "ColorPicker", Value = default, Callback = callback, _name = cname }
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

        local panel = Create("Frame", {
            Parent = lib.PopupLayer, BackgroundColor3 = Theme.PickerBg, BorderSizePixel = 0,
            Size = UDim2.new(0, 180, 0, 100), Visible = false, ZIndex = 110,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = panel })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = panel })

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

        local svDrag = { active = false }
        svDrag.update = function(input)
            s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
            updateCol()
        end
        InputManager.AddSVDrag(svDrag)

        local hueDrag = { active = false }
        hueDrag.update = function(input)
            h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 0.999)
            updateCol()
        end
        InputManager.AddHueDrag(hueDrag)

        svBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                svDrag.active = true; svDrag.update(input)
            end
        end)
        hueBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDrag.active = true; hueDrag.update(input)
            end
        end)

        preview.MouseButton1Click:Connect(function()
            if lib._activePopup and lib._activePopup.frame == panel then lib:_closePopup(); return end
            local ap = preview.AbsolutePosition
            panel.Position = UDim2.new(0, ap.X - 160, 0, ap.Y + 16)
            panel.Visible = true
            lib:_openPopup({
                frame = panel,
                close = function()
                    panel.Visible = false
                    svDrag.active = false; hueDrag.active = false
                end,
            })
        end)

        lib._options[id] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- KEYBIND
    function mod:Keybind(kname, default, callback)
        default = default or Enum.KeyCode.Unknown
        local id = self._id .. "." .. kname
        local opt = { Type = "Keybind", Value = default, Mode = "toggle", Callback = callback, _name = kname }
        self._optCount = self._optCount + 1

        mod._bindKey = default; mod._bindMode = "toggle"; mod:_updateBind()

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

        -- mode popup
        local modeFrame = Create("Frame", {
            Parent = lib.PopupLayer, BackgroundColor3 = Theme.DropBg, BorderSizePixel = 0,
            Size = UDim2.new(0, 80, 0, 0), ClipsDescendants = true, Visible = false, ZIndex = 110,
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
            mb.MouseEnter:Connect(function() Tw(mb, 0.08, { BackgroundColor3 = Theme.DropHover }) end)
            mb.MouseLeave:Connect(function() Tw(mb, 0.08, { BackgroundColor3 = Theme.DropBg }) end)
            mb.MouseButton1Click:Connect(function()
                opt.Mode = m; mod._bindMode = m
                for _, b in ipairs(modeBtns) do b.TextColor3 = (b.Text == m) and Theme.Accent or Theme.OptionText end
                lib:_closePopup()
                if m == "always" then mod:SetEnabled(true) end
            end)
        end

        -- listener entry
        local listener = { active = false }
        listener.set = function(key)
            opt.Value = key; mod._bindKey = key
            bindBtn.Text = key ~= Enum.KeyCode.Unknown and key.Name or "none"
            mod:_updateBind()
            Tw(bindBtn, 0.1, { TextColor3 = Theme.OptionValue })
        end
        table.insert(lib._keybindListening, listener)

        bindBtn.MouseButton1Click:Connect(function()
            listener.active = true
            bindBtn.Text = "..."
            Tw(bindBtn, 0.1, { TextColor3 = Theme.Accent })
        end)

        bindBtn.MouseButton2Click:Connect(function()
            if lib._activePopup and lib._activePopup.frame == modeFrame then lib:_closePopup(); return end
            local ap = bindBtn.AbsolutePosition; local as = bindBtn.AbsoluteSize
            modeFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 2)
            modeFrame.Size = UDim2.new(0, 80, 0, 0)
            modeFrame.Visible = true
            Tw(modeFrame, 0.2, { Size = UDim2.new(0, 80, 0, #modes * 20 + 4) }, Enum.EasingStyle.Quart)
            lib:_openPopup({
                frame = modeFrame,
                close = function()
                    Tw(modeFrame, 0.15, { Size = UDim2.new(0, 80, 0, 0) }, Enum.EasingStyle.Quart)
                    task.delay(0.15, function() modeFrame.Visible = false end)
                end,
            })
        end)

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

    -- BUTTON
    function mod:Button(text, callback)
        self._optCount = self._optCount + 1
        local btn = Create("TextButton", {
            Parent = self.OptsInner, BackgroundColor3 = Theme.DropBg, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 22), Font = Theme.FontSemi, Text = text,
            TextColor3 = Theme.OptionValue, TextSize = 11, AutoButtonColor = false, LayoutOrder = self._optCount,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = btn })
        Create("UIStroke", { Color = Theme.DropBorder, Thickness = 1, Parent = btn })
        btn.MouseEnter:Connect(function() Tw(btn, 0.08, { BackgroundColor3 = Theme.DropHover }) end)
        btn.MouseLeave:Connect(function() Tw(btn, 0.08, { BackgroundColor3 = Theme.DropBg }) end)
        btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        task.defer(recalc)
    end

    -- TEXTBOX
    function mod:TextBox(tname, default, placeholder, callback)
        self._optCount = self._optCount + 1
        local opt = { Type = "TextBox", Value = default or "", _name = tname }

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

        tb.FocusLost:Connect(function() opt.Value = tb.Text; if callback then callback(tb.Text) end end)
        function opt:Set(val) tb.Text = val; opt.Value = val end
        function opt:Get() return tb.Text end

        lib._options[self._id .. "." .. tname] = opt
        table.insert(self._opts, opt)
        task.defer(recalc)
        return opt
    end

    -- LABEL
    function mod:Label(text)
        self._optCount = self._optCount + 1
        Create("TextLabel", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Theme.Font, Text = text, TextColor3 = Theme.BindText, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = self._optCount })
        task.defer(recalc)
    end

    -- SEPARATOR
    function mod:Separator()
        self._optCount = self._optCount + 1
        local s = Create("Frame", { Parent = self.OptsInner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6), LayoutOrder = self._optCount })
        Create("Frame", { Parent = s, BackgroundColor3 = Theme.Separator, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1) })
        task.defer(recalc)
    end

    table.insert(cat.Modules, mod)
    table.insert(lib._modules, mod)
    return mod
end

return Library
