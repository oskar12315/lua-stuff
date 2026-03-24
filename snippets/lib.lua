local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local Library = {}
Library.__index = Library

local Theme = {
    CatBg = Color3.fromRGB(28, 28, 36),
    CatBorder = Color3.fromRGB(48, 48, 60),
    CatHeader = Color3.fromRGB(200, 200, 215),
    ModOn = Color3.fromRGB(230, 140, 180),
    ModOff = Color3.fromRGB(185, 185, 195),
    OptText = Color3.fromRGB(150, 150, 162),
    OptVal = Color3.fromRGB(215, 215, 225),
    Accent = Color3.fromRGB(230, 140, 180),
    SlBg = Color3.fromRGB(42, 42, 52),
    TgOn = Color3.fromRGB(230, 140, 180),
    TgOff = Color3.fromRGB(55, 55, 68),
    Knob = Color3.fromRGB(220, 220, 230),
    DrBg = Color3.fromRGB(32, 32, 42),
    DrHov = Color3.fromRGB(48, 48, 60),
    DrBor = Color3.fromRGB(55, 55, 68),
    BindTxt = Color3.fromRGB(120, 120, 135),
    Sep = Color3.fromRGB(42, 42, 52),
    PkBg = Color3.fromRGB(30, 30, 38),
    SrBg = Color3.fromRGB(32, 32, 40),
    SrBor = Color3.fromRGB(55, 55, 65),
    SrTxt = Color3.fromRGB(180, 180, 190),
}

local Fonts = {
    Regular = Enum.Font.Gotham,
    Semi = Enum.Font.GothamSemibold,
    Bold = Enum.Font.GothamBold,
}

local CFG_DIR = "MCClientConfigs"
local AUTO_CFG = "_autoload"

local function Make(class, props)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then
                pcall(function() inst[k] = v end)
            end
        end
        if props.Parent then inst.Parent = props.Parent end
    end
    return inst
end

local function Anim(inst, dur, props, style)
    local tw = TweenService:Create(
        inst,
        TweenInfo.new(dur, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function ColorToHSV(col)
    local r, g, b = col.R, col.G, col.B
    local mx = math.max(r, g, b)
    local mn = math.min(r, g, b)
    local h, s, v = 0, 0, mx
    local d = mx - mn
    s = (mx == 0) and 0 or (d / mx)
    if mx ~= mn then
        if mx == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif mx == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

-- File operations
local function FileWrite(path, content)
    pcall(function()
        if writefile then writefile(path, content) end
    end)
end

local function FileRead(path)
    local ok, result = pcall(function()
        if readfile and isfile and isfile(path) then
            return readfile(path)
        end
        return nil
    end)
    return ok and result or nil
end

local function FileDelete(path)
    pcall(function()
        if delfile and isfile and isfile(path) then delfile(path) end
    end)
end

local function FileDir(path)
    pcall(function()
        if makefolder and (not isfolder or not isfolder(path)) then
            makefolder(path)
        end
    end)
end

local function FileList(path)
    local ok, result = pcall(function()
        if listfiles and isfolder and isfolder(path) then
            return listfiles(path)
        end
        return {}
    end)
    return ok and result or {}
end

-- ═══════════════════════════════════
-- CENTRALIZED INPUT (one connection for all drags)
-- ═══════════════════════════════════
local DragSystem = {
    sliders = {},
    svPickers = {},
    huePickers = {},
    ready = false,
}

function DragSystem.Setup(lib)
    if DragSystem.ready then return end
    DragSystem.ready = true

    table.insert(lib.connections, UserInputService.InputChanged:Connect(function(input)
        if lib.destroyed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        for _, s in ipairs(DragSystem.sliders) do
            if s.dragging then s.update(input) end
        end
        for _, s in ipairs(DragSystem.svPickers) do
            if s.dragging then s.update(input) end
        end
        for _, s in ipairs(DragSystem.huePickers) do
            if s.dragging then s.update(input) end
        end
    end))

    table.insert(lib.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        for _, s in ipairs(DragSystem.sliders) do s.dragging = false end
        for _, s in ipairs(DragSystem.svPickers) do s.dragging = false end
        for _, s in ipairs(DragSystem.huePickers) do s.dragging = false end
    end))
end

-- ═══════════════════════════════════
-- LIBRARY
-- ═══════════════════════════════════
function Library.new(clientName)
    local self = setmetatable({}, Library)

    self.name = clientName or "Client"
    self.categories = {}
    self.modules = {}
    self.options = {}
    self.connections = {}
    self.accentTracked = {}
    self.catHeaders = {}
    self.keybindListeners = {}
    self.visible = true
    self.toggleKey = Enum.KeyCode.RightShift
    self.destroyed = false
    self.activePopup = nil

    -- cleanup old
    local old = LP.PlayerGui:FindFirstChild("MCClientUI")
    if old then old:Destroy() end

    -- screen gui
    self.gui = Make("ScreenGui", {
        Name = "MCClientUI",
        Parent = LP:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
        DisplayOrder = 999,
    })

    -- layers with explicit ZIndex ordering
    -- Layer 1: main content (categories)
    self.contentLayer = Make("Frame", {
        Name = "ContentLayer",
        Parent = self.gui,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
    })

    -- Layer 2: search (above categories)
    self.searchLayer = Make("Frame", {
        Name = "SearchLayer",
        Parent = self.gui,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 50,
    })

    -- Layer 3: popups (above everything)
    self.popupLayer = Make("Frame", {
        Name = "PopupLayer",
        Parent = self.gui,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100,
    })

    -- click-away button for popups
    self.clickAway = Make("TextButton", {
        Name = "ClickAway",
        Parent = self.popupLayer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 100,
        Visible = false,
    })
    self.clickAway.MouseButton1Click:Connect(function()
        self:ClosePopup()
    end)

    -- build search bar
    self:BuildSearch()

    -- build main scroll area
    self.mainScroll = Make("ScrollingFrame", {
        Name = "MainScroll",
        Parent = self.contentLayer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 52),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, -20, 1, -60),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ClipsDescendants = false,
        ZIndex = 1,
    })

    Make("UIListLayout", {
        Parent = self.mainScroll,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })

    -- build keybind widget
    self:BuildKeybindWidget()

    -- setup centralized drag system
    DragSystem.Setup(self)

    -- toggle UI visibility
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or self.destroyed then return end
        if input.KeyCode == self.toggleKey then
            self.visible = not self.visible
            self.contentLayer.Visible = self.visible
            self.searchFrame.Visible = self.visible
            if not self.visible then
                self:ClosePopup()
            end
        end
    end))

    -- keybind input processing
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or self.destroyed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        -- check if any keybind is listening for input
        for _, listener in ipairs(self.keybindListeners) do
            if listener.listening then
                if input.KeyCode == Enum.KeyCode.Escape then
                    listener.assign(Enum.KeyCode.Unknown)
                else
                    listener.assign(input.KeyCode)
                end
                listener.listening = false
                return
            end
        end

        -- process module keybinds
        for _, mod in ipairs(self.modules) do
            if mod.bindKey and mod.bindKey == input.KeyCode and mod.bindKey ~= Enum.KeyCode.Unknown then
                if mod.bindMode == "toggle" then
                    mod:SetEnabled(not mod.enabled)
                elseif mod.bindMode == "hold" then
                    mod:SetEnabled(true)
                end
            end
        end
    end))

    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if self.destroyed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, mod in ipairs(self.modules) do
            if mod.bindKey and mod.bindKey == input.KeyCode and mod.bindMode == "hold" then
                mod:SetEnabled(false)
            end
        end
    end))

    FileDir(CFG_DIR)

    -- auto-load config after everything is set up
    task.delay(1.5, function()
        if not self.destroyed then
            self:LoadConfig(AUTO_CFG)
        end
    end)

    return self
end

-- ═══════════════════════════════════
-- ACCENT SYSTEM
-- ═══════════════════════════════════
function Library:TrackAccent(instance, property)
    table.insert(self.accentTracked, {
        instance = instance,
        property = property,
    })
end

function Library:UpdateAccent(newColor)
    Theme.Accent = newColor
    Theme.ModOn = newColor
    Theme.TgOn = newColor

    -- update all tracked accent elements
    for _, entry in ipairs(self.accentTracked) do
        if entry.instance and entry.instance.Parent then
            pcall(function()
                entry.instance[entry.property] = newColor
            end)
        end
    end

    -- update enabled module name labels
    for _, mod in ipairs(self.modules) do
        if mod.enabled and mod.nameLabel then
            mod.nameLabel.TextColor3 = newColor
        end
        if mod.accentBar then
            mod.accentBar.BackgroundColor3 = newColor
        end
    end

    -- update category headers
    for _, lbl in ipairs(self.catHeaders) do
        if lbl and lbl.Parent then
            lbl.TextColor3 = newColor
        end
    end
end

-- ═══════════════════════════════════
-- POPUP SYSTEM
-- ═══════════════════════════════════
function Library:ClosePopup()
    if self.activePopup then
        local popup = self.activePopup
        self.activePopup = nil
        self.clickAway.Visible = false
        if popup.onClose then
            popup.onClose()
        end
    end
end

function Library:OpenPopup(popupData)
    self:ClosePopup()
    self.activePopup = popupData
    self.clickAway.Visible = true
end

-- ═══════════════════════════════════
-- SEARCH BAR (on search layer, above everything)
-- ═══════════════════════════════════
function Library:BuildSearch()
    self.searchFrame = Make("Frame", {
        Parent = self.searchLayer,
        BackgroundColor3 = Theme.SrBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 280, 0, 30),
        ZIndex = 50,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.searchFrame })
    Make("UIStroke", {
        Color = Theme.SrBor, Thickness = 1, Transparency = 0.3,
        Parent = self.searchFrame,
    })

    -- icon on left
    Make("ImageLabel", {
        Parent = self.searchFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Image = "rbxassetid://132302594577680",
        ImageColor3 = Theme.BindTxt,
        ZIndex = 51,
        ScaleType = Enum.ScaleType.Fit,
    })

    self.searchInput = Make("TextBox", {
        Parent = self.searchFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Fonts.Regular,
        Text = "",
        PlaceholderText = "search...",
        PlaceholderColor3 = Theme.BindTxt,
        TextColor3 = Theme.SrTxt,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 51,
    })

    -- results dropdown - ON SEARCH LAYER so it's above categories
    self.searchResults = Make("Frame", {
        Parent = self.searchLayer,
        BackgroundColor3 = Theme.DrBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -140, 0, 46),
        Size = UDim2.new(0, 280, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 55,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 5), Parent = self.searchResults })
    Make("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = self.searchResults })

    self.searchResultsLayout = Make("UIListLayout", {
        Parent = self.searchResults,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })
    Make("UIPadding", {
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3),
        Parent = self.searchResults,
    })

    self.searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        self:PerformSearch()
    end)

    self.searchInput.Focused:Connect(function()
        self:PerformSearch()
    end)

    self.searchInput.FocusLost:Connect(function()
        task.delay(0.2, function()
            self.searchResults.Visible = false
            self.searchResults.Size = UDim2.new(0, 280, 0, 0)
        end)
    end)
end

function Library:PerformSearch()
    local query = string.lower(self.searchInput.Text)

    -- clear old results
    for _, child in ipairs(self.searchResults:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    if query == "" then
        self.searchResults.Visible = false
        self.searchResults.Size = UDim2.new(0, 280, 0, 0)
        return
    end

    local results = {}
    for _, mod in ipairs(self.modules) do
        local nameMatch = string.find(string.lower(mod.name), query, 1, true)
        local catMatch = string.find(string.lower(mod.categoryName), query, 1, true)
        local optMatch = false

        if not nameMatch and not catMatch then
            for _, opt in ipairs(mod.optionsList) do
                if opt.label and string.find(string.lower(opt.label), query, 1, true) then
                    optMatch = true
                    break
                end
            end
        end

        if nameMatch or catMatch or optMatch then
            table.insert(results, mod)
            if #results >= 8 then break end
        end
    end

    if #results == 0 then
        self.searchResults.Visible = false
        self.searchResults.Size = UDim2.new(0, 280, 0, 0)
        return
    end

    for i, mod in ipairs(results) do
        local resultBtn = Make("TextButton", {
            Parent = self.searchResults,
            BackgroundColor3 = Theme.DrBg,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26),
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = i,
            ZIndex = 56,
        })

        Make("TextLabel", {
            Parent = resultBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0.6, -10, 1, 0),
            Font = Fonts.Semi,
            Text = string.lower(mod.name),
            TextColor3 = Theme.OptVal,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 57,
        })

        Make("TextLabel", {
            Parent = resultBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.6, 0, 0, 0),
            Size = UDim2.new(0.4, -8, 1, 0),
            Font = Fonts.Regular,
            Text = string.lower(mod.categoryName),
            TextColor3 = Theme.BindTxt,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 57,
        })

        resultBtn.MouseEnter:Connect(function()
            Anim(resultBtn, 0.08, { BackgroundColor3 = Theme.DrHov })
        end)
        resultBtn.MouseLeave:Connect(function()
            Anim(resultBtn, 0.08, { BackgroundColor3 = Theme.DrBg })
        end)

        resultBtn.MouseButton1Click:Connect(function()
            self.searchResults.Visible = false
            self.searchInput.Text = ""
            self:PulseModule(mod)
        end)
    end

    self.searchResults.Visible = true
    Anim(self.searchResults, 0.2, {
        Size = UDim2.new(0, 280, 0, #results * 26 + 6),
    }, Enum.EasingStyle.Quart)
end

function Library:PulseModule(mod)
    -- expand category if collapsed
    if mod.categoryRef and mod.categoryRef.collapsed then
        mod.categoryRef:Expand()
        task.wait(0.35)
    end

    -- pulse the module
    task.spawn(function()
        for i = 1, 3 do
            mod.container.BackgroundColor3 = Theme.Accent
            Anim(mod.container, 0.12, { BackgroundTransparency = 0.3 })
            task.wait(0.2)
            Anim(mod.container, 0.2, { BackgroundTransparency = 1 })
            task.wait(0.25)
        end
    end)
end

-- ═══════════════════════════════════
-- KEYBIND WIDGET
-- ═══════════════════════════════════
function Library:BuildKeybindWidget()
    self.kbWidget = Make("Frame", {
        Parent = self.gui,
        BackgroundColor3 = Theme.CatBg,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -175, 0.5, -80),
        Size = UDim2.new(0, 155, 0, 26),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 90,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.kbWidget })
    Make("UIStroke", {
        Color = Theme.CatBorder, Thickness = 1, Transparency = 0.4,
        Parent = self.kbWidget,
    })
    Make("UIPadding", {
        PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
        Parent = self.kbWidget,
    })
    Make("UIListLayout", {
        Parent = self.kbWidget,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })

    Make("TextLabel", {
        Parent = self.kbWidget,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Fonts.Bold,
        Text = "KEYBINDS",
        TextColor3 = Theme.CatHeader,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    })

    self.kbWidgetList = Make("Frame", {
        Parent = self.kbWidget,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
    })
    Make("UIListLayout", {
        Parent = self.kbWidgetList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
    })

    -- drag
    local dragging, dragStart, startPos = false, nil, nil
    self.kbWidget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.kbWidget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.kbWidget.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))

    -- update loop
    local tick = 0
    RunService.Heartbeat:Connect(function()
        if self.destroyed or not self.kbWidget.Visible then return end
        tick = tick + 1
        if tick % 15 ~= 0 then return end

        for _, child in ipairs(self.kbWidgetList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local idx = 0
        for _, mod in ipairs(self.modules) do
            if mod.enabled and mod.bindKey and mod.bindKey ~= Enum.KeyCode.Unknown then
                idx = idx + 1
                local row = Make("Frame", {
                    Parent = self.kbWidgetList,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    LayoutOrder = idx,
                })
                Make("TextLabel", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Fonts.Regular,
                    Text = mod.name,
                    TextColor3 = Theme.Accent,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                Make("TextLabel", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.7, 0, 0, 0),
                    Size = UDim2.new(0.3, 0, 1, 0),
                    Font = Fonts.Regular,
                    Text = "[" .. mod.bindKey.Name .. "]",
                    TextColor3 = Theme.BindTxt,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
            end
        end
    end)
end

-- ═══════════════════════════════════
-- CONFIG SYSTEM
-- ═══════════════════════════════════
function Library:SaveConfig(configName)
    local data = { options = {}, modules = {} }

    for id, opt in pairs(self.options) do
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
            entry.value = (opt.Value ~= Enum.KeyCode.Unknown) and opt.Value.Name or "Unknown"
            entry.mode = opt.Mode or "toggle"
        end
        table.insert(data.options, entry)
    end

    for _, mod in ipairs(self.modules) do
        table.insert(data.modules, {
            id = mod.fullId,
            enabled = mod.enabled,
            bindKey = (mod.bindKey and mod.bindKey ~= Enum.KeyCode.Unknown) and mod.bindKey.Name or nil,
            bindMode = mod.bindMode,
        })
    end

    FileDir(CFG_DIR)
    FileWrite(CFG_DIR .. "/" .. configName .. ".json", HttpService:JSONEncode(data))
end

function Library:LoadConfig(configName)
    local raw = FileRead(CFG_DIR .. "/" .. configName .. ".json")
    if not raw then return false end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not ok or not data then return false end

    if data.options then
        for _, entry in ipairs(data.options) do
            local opt = self.options[entry.id]
            if opt and opt.Set then
                pcall(function()
                    if opt.Type == "Toggle" and entry.value ~= nil then
                        opt:Set(entry.value)
                    elseif opt.Type == "Slider" and entry.value then
                        opt:Set(entry.value)
                    elseif opt.Type == "Dropdown" and entry.value then
                        opt:Set(entry.value)
                    elseif opt.Type == "ColorPicker" and entry.value then
                        opt:Set(Color3.new(entry.value[1], entry.value[2], entry.value[3]))
                    elseif opt.Type == "Keybind" and entry.value then
                        opt:Set(
                            Enum.KeyCode[entry.value] or Enum.KeyCode.Unknown,
                            entry.mode
                        )
                    end
                end)
            end
        end
    end

    if data.modules then
        for _, ms in ipairs(data.modules) do
            for _, mod in ipairs(self.modules) do
                if mod.fullId == ms.id then
                    mod:SetEnabled(ms.enabled or false)
                    if ms.bindKey then
                        mod.bindKey = Enum.KeyCode[ms.bindKey] or Enum.KeyCode.Unknown
                    end
                    mod.bindMode = ms.bindMode or "toggle"
                    mod:UpdateBindLabel()
                end
            end
        end
    end

    return true
end

function Library:DeleteConfig(configName)
    FileDelete(CFG_DIR .. "/" .. configName .. ".json")
end

function Library:GetConfigs()
    local files = FileList(CFG_DIR)
    local configs = {}
    for _, f in ipairs(files) do
        local n = f:match("([^/\\]+)%.json$")
        if n and n ~= AUTO_CFG then
            table.insert(configs, n)
        end
    end
    return configs
end

function Library:Unload()
    self.destroyed = true
    self:SaveConfig(AUTO_CFG)
    for _, mod in ipairs(self.modules) do
        mod:SetEnabled(false)
    end
    for _, conn in ipairs(self.connections) do
        pcall(function() conn:Disconnect() end)
    end
    task.wait(0.1)
    self.gui:Destroy()
end

-- ═══════════════════════════════════
-- CATEGORY
-- ═══════════════════════════════════
function Library:AddCategory(catName)
    local cat = {
        name = catName,
        moduleList = {},
        library = self,
        collapsed = false,
        currentHeight = 0,
    }

    local catIndex = #self.categories + 1

    cat.frame = Make("Frame", {
        Parent = self.mainScroll,
        BackgroundColor3 = Theme.CatBg,
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 0, 44),
        LayoutOrder = catIndex,
        ZIndex = 1,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = cat.frame })
    Make("UIStroke", {
        Color = Theme.CatBorder, Thickness = 1, Transparency = 0.4,
        Parent = cat.frame,
    })

    -- header
    local headerBtn = Make("TextButton", {
        Parent = cat.frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
    })

    local headerLabel = Make("TextLabel", {
        Parent = headerBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -36, 1, 0),
        Font = Fonts.Bold,
        Text = string.upper(catName),
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    self:TrackAccent(headerLabel, "TextColor3")
    table.insert(self.catHeaders, headerLabel)

    local arrowLabel = Make("TextLabel", {
        Parent = headerBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 0),
        Size = UDim2.new(0, 14, 1, 0),
        Font = Fonts.Regular,
        Text = "▼",
        TextColor3 = Theme.BindTxt,
        TextSize = 9,
        ZIndex = 3,
    })

    -- separator
    local separator = Make("Frame", {
        Parent = cat.frame,
        BackgroundColor3 = Theme.Sep,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(1, -24, 0, 1),
        ZIndex = 2,
    })

    -- module list
    cat.modListFrame = Make("Frame", {
        Parent = cat.frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 40),
        Size = UDim2.new(1, -24, 0, 0),
        ClipsDescendants = true,
        ZIndex = 2,
    })

    cat.modListLayout = Make("UIListLayout", {
        Parent = cat.modListFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })

    -- track content size changes
    local function refreshCatHeight()
        if cat.collapsed then return end
        local contentH = cat.modListLayout.AbsoluteContentSize.Y
        cat.currentHeight = contentH
        cat.modListFrame.Size = UDim2.new(1, -24, 0, contentH)
        cat.frame.Size = UDim2.new(0, 200, 0, 44 + contentH)
    end

    cat.modListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCatHeight)
    cat.refreshHeight = refreshCatHeight

    -- initial height after a frame
    task.defer(function()
        task.wait(0.1)
        refreshCatHeight()
    end)

    function cat:Expand()
        self.collapsed = false
        arrowLabel.Text = "▼"
        separator.Visible = true
        local h = self.modListLayout.AbsoluteContentSize.Y
        self.currentHeight = h
        Anim(self.modListFrame, 0.3, {
            Size = UDim2.new(1, -24, 0, h),
        }, Enum.EasingStyle.Quart)
        Anim(self.frame, 0.3, {
            Size = UDim2.new(0, 200, 0, 44 + h),
        }, Enum.EasingStyle.Quart)
    end

    function cat:Collapse()
        self.collapsed = true
        arrowLabel.Text = "▶"
        Anim(self.modListFrame, 0.3, {
            Size = UDim2.new(1, -24, 0, 0),
        }, Enum.EasingStyle.Quart)
        Anim(self.frame, 0.3, {
            Size = UDim2.new(0, 200, 0, 36),
        }, Enum.EasingStyle.Quart)
        task.delay(0.3, function()
            if self.collapsed then separator.Visible = false end
        end)
    end

    headerBtn.MouseButton1Click:Connect(function()
        if cat.collapsed then
            cat:Expand()
        else
            cat:Collapse()
        end
    end)

    headerBtn.MouseEnter:Connect(function()
        Anim(headerLabel, 0.1, {
            TextColor3 = Color3.fromRGB(255, 180, 210),
        })
    end)
    headerBtn.MouseLeave:Connect(function()
        Anim(headerLabel, 0.1, { TextColor3 = Theme.Accent })
    end)

    function cat:AddModule(moduleName)
        return Library._BuildModule(self, moduleName)
    end

    table.insert(self.categories, cat)
    return cat
end

-- ═══════════════════════════════════
-- MODULE
-- ═══════════════════════════════════
function Library._BuildModule(cat, moduleName)
    local lib = cat.library

    local mod = {
        name = moduleName,
        enabled = false,
        expanded = false,
        optionsList = {},
        optionCount = 0,
        bindKey = nil,
        bindMode = "toggle",
        fullId = cat.name .. "." .. moduleName,
        categoryName = cat.name,
        categoryRef = cat,
        callback = nil,
    }

    local modIndex = #cat.moduleList + 1

    mod.container = Make("Frame", {
        Parent = cat.modListFrame,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 26),
        LayoutOrder = modIndex,
        ClipsDescendants = true,
        ZIndex = 2,
    })

    local headerButton = Make("TextButton", {
        Parent = mod.container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
    })

    mod.nameLabel = Make("TextLabel", {
        Parent = headerButton,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -72, 1, 0),
        Font = Fonts.Semi,
        Text = string.lower(moduleName),
        TextColor3 = Theme.ModOff,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    mod.bindLabel = Make("TextLabel", {
        Parent = headerButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.new(0, 68, 1, 0),
        Font = Fonts.Regular,
        Text = "",
        TextColor3 = Theme.BindTxt,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 4,
    })

    -- options container
    mod.optsFrame = Make("Frame", {
        Parent = mod.container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 26),
        Size = UDim2.new(1, -8, 0, 0),
        ClipsDescendants = true,
        ZIndex = 3,
    })

    mod.accentBar = Make("Frame", {
        Parent = mod.optsFrame,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, 2, 1, -4),
        ZIndex = 4,
    })
    lib:TrackAccent(mod.accentBar, "BackgroundColor3")

    mod.optsInner = Make("Frame", {
        Parent = mod.optsFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 4,
    })

    mod.optsLayout = Make("UIListLayout", {
        Parent = mod.optsInner,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    })

    Make("UIPadding", {
        Parent = mod.optsInner,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 8),
    })

    function mod:UpdateBindLabel()
        if self.bindKey and self.bindKey ~= Enum.KeyCode.Unknown then
            self.bindLabel.Text = "[" .. self.bindKey.Name .. "]"
        else
            self.bindLabel.Text = ""
        end
    end

    function mod:SetEnabled(state)
        self.enabled = state
        Anim(self.nameLabel, 0.15, {
            TextColor3 = state and Theme.Accent or Theme.ModOff,
        })
        if self.callback then
            pcall(self.callback, state)
        end
    end

    local function recalcModHeight()
        task.defer(function()
            task.wait(0.02)
            if mod.expanded then
                local h = mod.optsLayout.AbsoluteContentSize.Y + 12
                Anim(mod.optsFrame, 0.3, {
                    Size = UDim2.new(1, -8, 0, h),
                }, Enum.EasingStyle.Quart)
                Anim(mod.container, 0.3, {
                    Size = UDim2.new(1, 0, 0, 26 + h),
                }, Enum.EasingStyle.Quart)
                task.delay(0.35, function()
                    cat.refreshHeight()
                end)
            end
        end)
    end

    -- left click: toggle
    headerButton.MouseButton1Click:Connect(function()
        mod:SetEnabled(not mod.enabled)
    end)

    -- right click: expand/collapse settings
    headerButton.MouseButton2Click:Connect(function()
        if mod.optionCount == 0 then return end
        mod.expanded = not mod.expanded

        if mod.expanded then
            local h = mod.optsLayout.AbsoluteContentSize.Y + 12
            Anim(mod.optsFrame, 0.3, {
                Size = UDim2.new(1, -8, 0, h),
            }, Enum.EasingStyle.Quart)
            Anim(mod.container, 0.3, {
                Size = UDim2.new(1, 0, 0, 26 + h),
            }, Enum.EasingStyle.Quart)
        else
            lib:ClosePopup()
            Anim(mod.optsFrame, 0.25, {
                Size = UDim2.new(1, -8, 0, 0),
            }, Enum.EasingStyle.Quart)
            Anim(mod.container, 0.25, {
                Size = UDim2.new(1, 0, 0, 26),
            }, Enum.EasingStyle.Quart)
        end

        task.delay(0.35, function()
            cat.refreshHeight()
        end)
    end)

    -- hover
    headerButton.MouseEnter:Connect(function()
        if not mod.enabled then
            Anim(mod.nameLabel, 0.08, {
                TextColor3 = Color3.fromRGB(225, 225, 235),
            })
        end
    end)
    headerButton.MouseLeave:Connect(function()
        if not mod.enabled then
            Anim(mod.nameLabel, 0.08, { TextColor3 = Theme.ModOff })
        end
    end)

    function mod:OnToggle(cb)
        self.callback = cb
        return self
    end

    -- ═══ TOGGLE ═══
    function mod:Toggle(optName, default, cb)
        local id = self.fullId .. "." .. optName
        local opt = {
            Type = "Toggle",
            Value = default or false,
            Callback = cb,
            label = optName,
        }
        self.optionCount = self.optionCount + 1

        local row = Make("Frame", {
            Parent = self.optsInner, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self.optionCount, ZIndex = 5,
        })
        Make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -44, 1, 0),
            Font = Fonts.Regular, Text = optName, TextColor3 = Theme.OptText,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        })

        local bg = Make("Frame", {
            Parent = row,
            BackgroundColor3 = opt.Value and Theme.TgOn or Theme.TgOff,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -36, 0.5, -7),
            Size = UDim2.new(0, 30, 0, 14),
            ZIndex = 6,
        })
        Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bg })
        if opt.Value then lib:TrackAccent(bg, "BackgroundColor3") end

        local knob = Make("Frame", {
            Parent = bg, BackgroundColor3 = Theme.Knob, BorderSizePixel = 0,
            Position = opt.Value and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
            Size = UDim2.new(0, 10, 0, 10), ZIndex = 7,
        })
        Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

        local btn = Make("TextButton", {
            Parent = row, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 8,
        })

        function opt:Set(val)
            opt.Value = val
            Anim(bg, 0.2, {
                BackgroundColor3 = val and Theme.TgOn or Theme.TgOff,
            })
            Anim(knob, 0.2, {
                Position = val and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
            })
            if opt.Callback then pcall(opt.Callback, val) end
        end

        btn.MouseButton1Click:Connect(function() opt:Set(not opt.Value) end)

        lib.options[id] = opt
        table.insert(self.optionsList, opt)
        task.defer(recalcModHeight)
        return opt
    end

    -- ═══ SLIDER ═══
    function mod:Slider(optName, default, minVal, maxVal, cb, suffix, decimals)
        suffix = suffix or ""
        decimals = decimals or 1
        default = default or minVal
        local id = self.fullId .. "." .. optName
        local opt = { Type = "Slider", Value = default, Callback = cb, label = optName }
        self.optionCount = self.optionCount + 1

        local row = Make("Frame", {
            Parent = self.optsInner, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34), LayoutOrder = self.optionCount, ZIndex = 5,
        })
        Make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 0, 15),
            Font = Fonts.Regular, Text = optName, TextColor3 = Theme.OptText,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        })
        local valLabel = Make("TextLabel", {
            Parent = row, BackgroundTransparency = 1,
            Position = UDim2.new(0.6, 0, 0, 0), Size = UDim2.new(0.4, 0, 0, 15),
            Font = Fonts.Semi, Text = tostring(default) .. suffix,
            TextColor3 = Theme.OptVal, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6,
        })

        local track = Make("Frame", {
            Parent = row, BackgroundColor3 = Theme.SlBg, BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 19), Size = UDim2.new(1, 0, 0, 5), ZIndex = 6,
        })
        Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

        local pct = math.clamp((default - minVal) / (maxVal - minVal), 0, 1)
        local fill = Make("Frame", {
            Parent = track, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
            Size = UDim2.new(pct, 0, 1, 0), ZIndex = 7,
        })
        Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
        lib:TrackAccent(fill, "BackgroundColor3")

        local knob = Make("Frame", {
            Parent = track, BackgroundColor3 = Theme.Knob, BorderSizePixel = 0,
            Position = UDim2.new(pct, -5, 0.5, -5), Size = UDim2.new(0, 10, 0, 10), ZIndex = 8,
        })
        Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

        local sliderBtn = Make("TextButton", {
            Parent = track, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 14), Position = UDim2.new(0, 0, 0, -7),
            Text = "", ZIndex = 9,
        })

        local sliderData = { dragging = false }
        sliderData.update = function(input)
            local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor((minVal + (maxVal - minVal) * p) * (10 ^ decimals) + 0.5) / (10 ^ decimals)
            opt.Value = val
            valLabel.Text = tostring(val) .. suffix
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -5, 0.5, -5)
            if cb then cb(val) end
        end
        table.insert(DragSystem.sliders, sliderData)

        function opt:Set(val)
            val = math.clamp(val, minVal, maxVal)
            local p = (val - minVal) / (maxVal - minVal)
            opt.Value = val
            valLabel.Text = tostring(val) .. suffix
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -5, 0.5, -5)
            if cb then cb(val) end
        end

        sliderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliderData.dragging = true
                sliderData.update(input)
            end
        end)

        lib.options[id] = opt
        table.insert(self.optionsList, opt)
        task.defer(recalcModHeight)
        return opt
    end

    -- ═══ DROPDOWN ═══
    function mod:Dropdown(optName, items, default, cb)
        local id = self.fullId .. "." .. optName
        local opt = { Type = "Dropdown", Value = default or items[1], Items = items, Callback = cb, label = optName }
        self.optionCount = self.optionCount + 1

        local row = Make("Frame", {
            Parent = self.optsInner, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self.optionCount, ZIndex = 5,
        })
        Make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0),
            Font = Fonts.Regular, Text = optName, TextColor3 = Theme.OptText,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        })

        local valBtn = Make("TextButton", {
            Parent = row, BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
            Font = Fonts.Semi, Text = tostring(opt.Value), TextColor3 = Theme.OptVal,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
            AutoButtonColor = false, ZIndex = 6,
        })

        -- popup on popup layer
        local popFrame = Make("Frame", {
            Parent = lib.popupLayer, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
            Size = UDim2.new(0, 120, 0, 0), ClipsDescendants = true,
            Visible = false, ZIndex = 110,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 4), Parent = popFrame })
        Make("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = popFrame })
        Make("UIListLayout", { Parent = popFrame, SortOrder = Enum.SortOrder.LayoutOrder })
        Make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = popFrame })

        local itemButtons = {}
        for i, item in ipairs(items) do
            local ib = Make("TextButton", {
                Parent = popFrame, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 22), Font = Fonts.Regular, Text = item,
                TextColor3 = (item == opt.Value) and Theme.Accent or Theme.OptText,
                TextSize = 11, AutoButtonColor = false, LayoutOrder = i, ZIndex = 111,
            })
            table.insert(itemButtons, ib)

            ib.MouseEnter:Connect(function() Anim(ib, 0.08, { BackgroundColor3 = Theme.DrHov }) end)
            ib.MouseLeave:Connect(function() Anim(ib, 0.08, { BackgroundColor3 = Theme.DrBg }) end)
            ib.MouseButton1Click:Connect(function()
                opt.Value = item
                valBtn.Text = item
                for _, b in ipairs(itemButtons) do
                    b.TextColor3 = (b.Text == item) and Theme.Accent or Theme.OptText
                end
                lib:ClosePopup()
                if cb then cb(item) end
            end)
        end

        function opt:Set(val)
            opt.Value = val
            valBtn.Text = val
            for _, b in ipairs(itemButtons) do
                b.TextColor3 = (b.Text == val) and Theme.Accent or Theme.OptText
            end
            if cb then cb(val) end
        end

        valBtn.MouseButton1Click:Connect(function()
            if lib.activePopup and lib.activePopup.frame == popFrame then
                lib:ClosePopup()
                return
            end
            local absPos = valBtn.AbsolutePosition
            local absSize = valBtn.AbsoluteSize
            local width = math.max(absSize.X, 100)
            popFrame.Position = UDim2.new(0, absPos.X + absSize.X - width, 0, absPos.Y + absSize.Y + 2)
            popFrame.Size = UDim2.new(0, width, 0, 0)
            popFrame.Visible = true
            Anim(popFrame, 0.2, {
                Size = UDim2.new(0, width, 0, #items * 22 + 4),
            }, Enum.EasingStyle.Quart)

            lib:OpenPopup({
                frame = popFrame,
                onClose = function()
                    Anim(popFrame, 0.15, {
                        Size = UDim2.new(0, width, 0, 0),
                    }, Enum.EasingStyle.Quart)
                    task.delay(0.15, function() popFrame.Visible = false end)
                end,
            })
        end)

        lib.options[id] = opt
        table.insert(self.optionsList, opt)
        task.defer(recalcModHeight)
        return opt
    end

    -- ═══ COLOR PICKER ═══
    function mod:ColorPicker(optName, default, cb)
        default = default or Color3.new(1, 0, 0)
        local h, s, v = ColorToHSV(default)
        local id = self.fullId .. "." .. optName
        local opt = { Type = "ColorPicker", Value = default, Callback = cb, label = optName }
        self.optionCount = self.optionCount + 1

        local row = Make("Frame", {
            Parent = self.optsInner, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self.optionCount, ZIndex = 5,
        })
        Make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 22),
            Font = Fonts.Regular, Text = optName, TextColor3 = Theme.OptText,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        })

        local preview = Make("TextButton", {
            Parent = row, BackgroundColor3 = default, BorderSizePixel = 0,
            Position = UDim2.new(1, -20, 0.5, -6), Size = UDim2.new(0, 16, 0, 12),
            Text = "", AutoButtonColor = false, ZIndex = 6,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 3), Parent = preview })
        Make("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = preview })

        -- popup
        local panel = Make("Frame", {
            Parent = lib.popupLayer, BackgroundColor3 = Theme.PkBg, BorderSizePixel = 0,
            Size = UDim2.new(0, 180, 0, 100), Visible = false, ZIndex = 110,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 5), Parent = panel })
        Make("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = panel })

        -- SV box
        local svBox = Make("Frame", {
            Parent = panel, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -32, 1, -16),
            ZIndex = 111, ClipsDescendants = true,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 3), Parent = svBox })

        local hueOverlay = Make("Frame", {
            Parent = svBox, BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 112,
        })
        Make("UIGradient", {
            Parent = hueOverlay,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
        })

        local blackOverlay = Make("Frame", {
            Parent = svBox, BackgroundColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 113,
        })
        Make("UIGradient", {
            Parent = blackOverlay,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Rotation = 90,
        })

        local svCursor = Make("Frame", {
            Parent = svBox, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            Position = UDim2.new(s, -5, 1 - v, -5), Size = UDim2.new(0, 10, 0, 10), ZIndex = 116,
        })
        Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })
        Make("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5, Parent = svCursor })

        local svButton = Make("TextButton", {
            Parent = svBox, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 117,
        })

        -- hue bar
        local hueBar = Make("Frame", {
            Parent = panel, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            Position = UDim2.new(1, -20, 0, 8), Size = UDim2.new(0, 10, 1, -16), ZIndex = 111,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 3), Parent = hueBar })
        Make("UIGradient", {
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

        local hueCursor = Make("Frame", {
            Parent = hueBar, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            Position = UDim2.new(0, -2, h, -2), Size = UDim2.new(1, 4, 0, 4), ZIndex = 116,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 2), Parent = hueCursor })
        Make("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = hueCursor })

        local hueButton = Make("TextButton", {
            Parent = hueBar, BackgroundTransparency = 1,
            Size = UDim2.new(1, 8, 1, 0), Position = UDim2.new(0, -4, 0, 0),
            Text = "", ZIndex = 117,
        })

        local function updateColor()
            opt.Value = Color3.fromHSV(math.clamp(h, 0, 0.999), s, v)
            preview.BackgroundColor3 = opt.Value
            hueOverlay.BackgroundColor3 = Color3.fromHSV(math.clamp(h, 0, 0.999), 1, 1)
            svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            hueCursor.Position = UDim2.new(0, -2, h, -2)
            if cb then cb(opt.Value) end
        end

        function opt:Set(color)
            h, s, v = ColorToHSV(color)
            updateColor()
        end

        local svDrag = { dragging = false }
        svDrag.update = function(input)
            s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
            updateColor()
        end
        table.insert(DragSystem.svPickers, svDrag)

        local hueDrag = { dragging = false }
        hueDrag.update = function(input)
            h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 0.999)
            updateColor()
        end
        table.insert(DragSystem.huePickers, hueDrag)

        svButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                svDrag.dragging = true
                svDrag.update(input)
            end
        end)

        hueButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDrag.dragging = true
                hueDrag.update(input)
            end
        end)

        preview.MouseButton1Click:Connect(function()
            if lib.activePopup and lib.activePopup.frame == panel then
                lib:ClosePopup()
                return
            end
            local absPos = preview.AbsolutePosition
            panel.Position = UDim2.new(0, absPos.X - 160, 0, absPos.Y + 16)
            panel.Visible = true
            lib:OpenPopup({
                frame = panel,
                onClose = function()
                    panel.Visible = false
                    svDrag.dragging = false
                    hueDrag.dragging = false
                end,
            })
        end)

        lib.options[id] = opt
        table.insert(self.optionsList, opt)
        task.defer(recalcModHeight)
        return opt
    end

    -- ═══ KEYBIND ═══
    function mod:Keybind(optName, default, cb)
        default = default or Enum.KeyCode.Unknown
        local id = self.fullId .. "." .. optName
        local opt = { Type = "Keybind", Value = default, Mode = "toggle", Callback = cb, label = optName }
        self.optionCount = self.optionCount + 1

        mod.bindKey = default
        mod.bindMode = "toggle"
        mod:UpdateBindLabel()

        local row = Make("Frame", {
            Parent = self.optsInner, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self.optionCount, ZIndex = 5,
        })
        Make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.4, 0, 1, 0),
            Font = Fonts.Regular, Text = optName, TextColor3 = Theme.OptText,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        })

        local bindBtn = Make("TextButton", {
            Parent = row, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
            Position = UDim2.new(1, -55, 0.5, -9), Size = UDim2.new(0, 52, 0, 18),
            Font = Fonts.Regular, Text = (default ~= Enum.KeyCode.Unknown) and default.Name or "none",
            TextColor3 = Theme.OptVal, TextSize = 10, AutoButtonColor = false, ZIndex = 6,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 3), Parent = bindBtn })
        Make("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = bindBtn })

        -- mode popup
        local modeFrame = Make("Frame", {
            Parent = lib.popupLayer, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
            Size = UDim2.new(0, 80, 0, 0), ClipsDescendants = true,
            Visible = false, ZIndex = 110,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 4), Parent = modeFrame })
        Make("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = modeFrame })
        Make("UIListLayout", { Parent = modeFrame, SortOrder = Enum.SortOrder.LayoutOrder })
        Make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = modeFrame })

        local modes = { "toggle", "hold", "always" }
        local modeButtons = {}
        for i, mode in ipairs(modes) do
            local mb = Make("TextButton", {
                Parent = modeFrame, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20), Font = Fonts.Regular, Text = mode,
                TextColor3 = (mode == opt.Mode) and Theme.Accent or Theme.OptText,
                TextSize = 11, AutoButtonColor = false, LayoutOrder = i, ZIndex = 111,
            })
            table.insert(modeButtons, mb)

            mb.MouseEnter:Connect(function() Anim(mb, 0.08, { BackgroundColor3 = Theme.DrHov }) end)
            mb.MouseLeave:Connect(function() Anim(mb, 0.08, { BackgroundColor3 = Theme.DrBg }) end)
            mb.MouseButton1Click:Connect(function()
                opt.Mode = mode
                mod.bindMode = mode
                for _, b in ipairs(modeButtons) do
                    b.TextColor3 = (b.Text == mode) and Theme.Accent or Theme.OptText
                end
                lib:ClosePopup()
                if mode == "always" then mod:SetEnabled(true) end
            end)
        end

        -- listener
        local listener = { listening = false }
        listener.assign = function(key)
            opt.Value = key
            mod.bindKey = key
            bindBtn.Text = (key ~= Enum.KeyCode.Unknown) and key.Name or "none"
            mod:UpdateBindLabel()
            Anim(bindBtn, 0.1, { TextColor3 = Theme.OptVal })
        end
        table.insert(lib.keybindListeners, listener)

        -- left click: listen
        bindBtn.MouseButton1Click:Connect(function()
            listener.listening = true
            bindBtn.Text = "..."
            Anim(bindBtn, 0.1, { TextColor3 = Theme.Accent })
        end)

        -- right click: mode popup
        bindBtn.MouseButton2Click:Connect(function()
            if lib.activePopup and lib.activePopup.frame == modeFrame then
                lib:ClosePopup()
                return
            end
            local absPos = bindBtn.AbsolutePosition
            local absSize = bindBtn.AbsoluteSize
            modeFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
            modeFrame.Size = UDim2.new(0, 80, 0, 0)
            modeFrame.Visible = true
            Anim(modeFrame, 0.2, {
                Size = UDim2.new(0, 80, 0, #modes * 20 + 4),
            }, Enum.EasingStyle.Quart)

            lib:OpenPopup({
                frame = modeFrame,
                onClose = function()
                    Anim(modeFrame, 0.15, {
                        Size = UDim2.new(0, 80, 0, 0),
                    }, Enum.EasingStyle.Quart)
                    task.delay(0.15, function() modeFrame.Visible = false end)
                end,
            })
        end)

        function opt:Set(key, mode)
            opt.Value = key
            mod.bindKey = key
            bindBtn.Text = (key ~= Enum.KeyCode.Unknown) and key.Name or "none"
            if mode then
                opt.Mode = mode
                mod.bindMode = mode
                for _, b in ipairs(modeButtons) do
                    b.TextColor3 = (b.Text == mode) and Theme.Accent or Theme.OptText
                end
            end
            mod:UpdateBindLabel()
        end

        lib.options[id] = opt
        table.insert(self.optionsList, opt)
        task.defer(recalcModHeight)
        return opt
    end

    -- ═══ BUTTON ═══
    function mod:Button(text, cb)
        self.optionCount = self.optionCount + 1
        local btn = Make("TextButton", {
            Parent = self.optsInner, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 22), Font = Fonts.Semi, Text = text,
            TextColor3 = Theme.OptVal, TextSize = 11, AutoButtonColor = false,
            LayoutOrder = self.optionCount, ZIndex = 5,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 3), Parent = btn })
        Make("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = btn })
        btn.MouseEnter:Connect(function() Anim(btn, 0.08, { BackgroundColor3 = Theme.DrHov }) end)
        btn.MouseLeave:Connect(function() Anim(btn, 0.08, { BackgroundColor3 = Theme.DrBg }) end)
        btn.MouseButton1Click:Connect(function() if cb then cb() end end)
        task.defer(recalcModHeight)
    end

    -- ═══ TEXTBOX ═══
    function mod:TextBox(optName, default, placeholder, cb)
        self.optionCount = self.optionCount + 1
        local opt = { Type = "TextBox", Value = default or "", label = optName }

        local row = Make("Frame", {
            Parent = self.optsInner, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36), LayoutOrder = self.optionCount, ZIndex = 5,
        })
        Make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
            Font = Fonts.Regular, Text = optName, TextColor3 = Theme.OptText,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        })
        local textBox = Make("TextBox", {
            Parent = row, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 16), Size = UDim2.new(1, 0, 0, 18),
            Font = Fonts.Regular, Text = default or "", PlaceholderText = placeholder or "",
            PlaceholderColor3 = Theme.BindTxt, TextColor3 = Theme.OptVal,
            TextSize = 11, ClearTextOnFocus = false, ZIndex = 6,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 3), Parent = textBox })
        Make("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = textBox })
        Make("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = textBox })

        textBox.FocusLost:Connect(function()
            opt.Value = textBox.Text
            if cb then cb(textBox.Text) end
        end)

        function opt:Set(val) textBox.Text = val; opt.Value = val end
        function opt:Get() return textBox.Text end

        lib.options[self.fullId .. "." .. optName] = opt
        table.insert(self.optionsList, opt)
        task.defer(recalcModHeight)
        return opt
    end

    -- ═══ LABEL ═══
    function mod:Label(text)
        self.optionCount = self.optionCount + 1
        Make("TextLabel", {
            Parent = self.optsInner, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16), Font = Fonts.Regular, Text = text,
            TextColor3 = Theme.BindTxt, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = self.optionCount, ZIndex = 5,
        })
        task.defer(recalcModHeight)
    end

    -- ═══ SEPARATOR ═══
    function mod:Separator()
        self.optionCount = self.optionCount + 1
        local sepFrame = Make("Frame", {
            Parent = self.optsInner, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6), LayoutOrder = self.optionCount, ZIndex = 5,
        })
        Make("Frame", {
            Parent = sepFrame, BackgroundColor3 = Theme.Sep, BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 6,
        })
        task.defer(recalcModHeight)
    end

    table.insert(cat.moduleList, mod)
    table.insert(lib.modules, mod)
    return mod
end

return Library
