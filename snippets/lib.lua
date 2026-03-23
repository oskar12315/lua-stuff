-- MinecraftHackUI Library
-- Usage: local UI = loadstring(...)()
-- local client = UI.new("Client Name")
-- local tab = client:Tab("Combat")
-- local module = tab:Module("KillAura")
-- module:Toggle("Enabled", true, function(val) end)
-- module:Slider("Range", 3, 1, 6, function(val) end)
-- module:Dropdown("Mode", {"Single","Multi"}, "Single", function(val) end)
-- module:ColorPicker("Color", Color3.new(1,0,0), function(val) end)
-- module:Keybind("Bind", Enum.KeyCode.R, function(key) end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {}
Library.__index = Library

-- ═══════════════════════════════════════════
-- THEME / CONFIG
-- ═══════════════════════════════════════════
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    TabBackground = Color3.fromRGB(30, 30, 30),
    TabActive = Color3.fromRGB(45, 45, 45),
    TabHover = Color3.fromRGB(38, 38, 38),
    ModuleBackground = Color3.fromRGB(35, 35, 35),
    ModuleEnabled = Color3.fromRGB(0, 170, 255),
    ModuleDisabled = Color3.fromRGB(150, 150, 150),
    ModuleHover = Color3.fromRGB(45, 45, 45),
    OptionBackground = Color3.fromRGB(28, 28, 28),
    OptionBorder = Color3.fromRGB(50, 50, 50),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextDimmed = Color3.fromRGB(120, 120, 120),
    Accent = Color3.fromRGB(0, 170, 255),
    AccentDark = Color3.fromRGB(0, 120, 200),
    SliderFill = Color3.fromRGB(0, 170, 255),
    SliderBackground = Color3.fromRGB(50, 50, 50),
    DropdownBackground = Color3.fromRGB(25, 25, 25),
    DropdownHover = Color3.fromRGB(40, 40, 40),
    ToggleOn = Color3.fromRGB(0, 200, 100),
    ToggleOff = Color3.fromRGB(80, 80, 80),
    Separator = Color3.fromRGB(50, 50, 50),
    Shadow = Color3.fromRGB(0, 0, 0),
    TopBar = Color3.fromRGB(0, 140, 255),
    Font = Enum.Font.Code,
    FontBold = Enum.Font.GothamBold,
    FontMono = Enum.Font.Code,
}

-- ═══════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════
local function Create(className, properties, children)
    local inst = Instance.new(className)
    if properties then
        for prop, val in pairs(properties) do
            if prop ~= "Parent" then
                inst[prop] = val
            end
        end
        if properties.Parent then
            inst.Parent = properties.Parent
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

local function Tween(instance, duration, properties, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v

    v = max
    local d = max - min
    s = max == 0 and 0 or d / max

    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    return h, s, v
end

local function Ripple(button, x, y)
    local circle = Create("Frame", {
        Parent = button,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = button.ZIndex + 1,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(circle, 0.4, { Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1 })
    task.delay(0.4, function()
        circle:Destroy()
    end)
end

-- ═══════════════════════════════════════════
-- MAIN LIBRARY
-- ═══════════════════════════════════════════
function Library.new(clientName)
    local self = setmetatable({}, Library)
    self.Name = clientName or "Client"
    self.Tabs = {}
    self.ActiveTab = nil
    self.Visible = true
    self.ToggleKey = Enum.KeyCode.RightShift
    self.Dragging = false
    self.DragStart = nil
    self.StartPos = nil

    -- Destroy existing
    local existing = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("HackClientUI")
    if existing then existing:Destroy() end

    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "HackClientUI",
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999,
    })

    -- Main Frame
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.MainFrame })

    -- Shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = -1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
    })

    -- Top Bar (colored accent line)
    self.TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
    })

    -- Title Bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(1, 0, 0, 30),
    })

    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Theme.FontBold,
        Text = string.upper(self.Name),
        TextColor3 = Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Version / subtitle
    Create("TextLabel", {
        Name = "Version",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 50, 1, 0),
        Font = Theme.Font,
        Text = "v1.0",
        TextColor3 = Theme.TextDimmed,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    -- Separator under title
    Create("Frame", {
        Name = "TitleSep",
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.Separator,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(1, 0, 0, 1),
    })

    -- Tab Bar (horizontal tabs at top)
    self.TabBar = Create("Frame", {
        Name = "TabBar",
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.TabBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 33),
        Size = UDim2.new(1, 0, 0, 28),
        ClipsDescendants = true,
    })

    self.TabBarLayout = Create("UIListLayout", {
        Parent = self.TabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })

    -- Separator under tab bar
    Create("Frame", {
        Name = "TabSep",
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.Separator,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 61),
        Size = UDim2.new(1, 0, 0, 1),
    })

    -- Content Area
    self.ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 62),
        Size = UDim2.new(1, 0, 1, -62),
        ClipsDescendants = true,
    })

    -- Dragging
    self:SetupDragging()

    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self.Visible = not self.Visible
            self.MainFrame.Visible = self.Visible
        end
    end)

    return self
end

function Library:SetupDragging()
    local dragging = false
    local dragInput, dragStart, startPos

    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════
-- TAB
-- ═══════════════════════════════════════════
function Library:Tab(name)
    local tab = {
        Name = name,
        Modules = {},
        Library = self,
    }

    local tabIndex = #self.Tabs + 1

    -- Tab Button
    tab.Button = Create("TextButton", {
        Name = "Tab_" .. name,
        Parent = self.TabBar,
        BackgroundColor3 = Theme.TabBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 90, 1, 0),
        Font = Theme.Font,
        Text = string.upper(name),
        TextColor3 = Theme.TextDimmed,
        TextSize = 11,
        LayoutOrder = tabIndex,
        AutoButtonColor = false,
    })

    -- Active indicator under tab
    tab.Indicator = Create("Frame", {
        Name = "Indicator",
        Parent = tab.Button,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Visible = false,
    })

    -- Tab content (scrolling frame with modules)
    tab.Content = Create("ScrollingFrame", {
        Name = "Content_" .. name,
        Parent = self.ContentArea,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })

    -- Two-column layout using frames
    tab.LeftColumn = Create("Frame", {
        Name = "LeftColumn",
        Parent = tab.Content,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(0.5, -12, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    Create("UIListLayout", {
        Parent = tab.LeftColumn,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })

    tab.RightColumn = Create("Frame", {
        Name = "RightColumn",
        Parent = tab.Content,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 4, 0, 8),
        Size = UDim2.new(0.5, -12, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    Create("UIListLayout", {
        Parent = tab.RightColumn,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })

    -- Tab button interactions
    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, 0.15, { BackgroundColor3 = Theme.TabHover })
        end
    end)

    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, 0.15, { BackgroundColor3 = Theme.TabBackground })
        end
    end)

    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)

    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    -- Module creation function
    function tab:Module(moduleName, side)
        return Library._CreateModule(self, moduleName, side)
    end

    return tab
end

function Library:SelectTab(tab)
    -- Deselect all
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = false
        t.Indicator.Visible = false
        Tween(t.Button, 0.15, { BackgroundColor3 = Theme.TabBackground, TextColor3 = Theme.TextDimmed })
    end

    -- Select this tab
    tab.Content.Visible = true
    tab.Indicator.Visible = true
    Tween(tab.Button, 0.15, { BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.TextPrimary })
    self.ActiveTab = tab
end

-- ═══════════════════════════════════════════
-- MODULE
-- ═══════════════════════════════════════════
function Library._CreateModule(tab, moduleName, side)
    local module = {
        Name = moduleName,
        Enabled = false,
        Expanded = false,
        Options = {},
        Tab = tab,
        Callback = nil,
    }

    side = side or "left"
    local parent = (side == "right") and tab.RightColumn or tab.LeftColumn
    local moduleIndex = #tab.Modules + 1

    -- Module Container
    module.Container = Create("Frame", {
        Name = "Module_" .. moduleName,
        Parent = parent,
        BackgroundColor3 = Theme.ModuleBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28),
        LayoutOrder = moduleIndex,
        ClipsDescendants = true,
        AutomaticSize = Enum.AutomaticSize.None,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = module.Container })

    -- Module Header (the clickable part)
    module.Header = Create("TextButton", {
        Name = "Header",
        Parent = module.Container,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 28),
        Font = Theme.Font,
        Text = "",
        AutoButtonColor = false,
    })

    -- Enabled indicator (left bar)
    module.EnabledBar = Create("Frame", {
        Name = "EnabledBar",
        Parent = module.Header,
        BackgroundColor3 = Theme.ModuleDisabled,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 3, 1, 0),
    })
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = module.EnabledBar,
    })

    -- Module name label
    module.NameLabel = Create("TextLabel", {
        Name = "ModuleName",
        Parent = module.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Theme.Font,
        Text = moduleName,
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Expand arrow
    module.Arrow = Create("TextLabel", {
        Name = "Arrow",
        Parent = module.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Font = Theme.Font,
        Text = "+",
        TextColor3 = Theme.TextDimmed,
        TextSize = 14,
        Visible = false, -- shown when options exist
    })

    -- Options container (hidden by default, shown on right-click expand)
    module.OptionsFrame = Create("Frame", {
        Name = "Options",
        Parent = module.Container,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 28),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    module.OptionsLayout = Create("UIListLayout", {
        Parent = module.OptionsFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })

    Create("UIPadding", {
        Parent = module.OptionsFrame,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 6),
    })

    -- Left-click: Toggle module on/off
    module.Header.MouseButton1Click:Connect(function()
        module.Enabled = not module.Enabled
        if module.Enabled then
            Tween(module.EnabledBar, 0.2, { BackgroundColor3 = Theme.ModuleEnabled })
            Tween(module.NameLabel, 0.2, { TextColor3 = Theme.TextPrimary })
        else
            Tween(module.EnabledBar, 0.2, { BackgroundColor3 = Theme.ModuleDisabled })
            Tween(module.NameLabel, 0.2, { TextColor3 = Theme.TextSecondary })
        end
        if module.Callback then
            module.Callback(module.Enabled)
        end
    end)

    -- Right-click: Expand/collapse options
    module.Header.MouseButton2Click:Connect(function()
        if #module.Options == 0 then return end
        module.Expanded = not module.Expanded

        if module.Expanded then
            module.Arrow.Text = "-"
            -- Calculate total height of options
            task.wait() -- let layout compute
            local totalHeight = module.OptionsLayout.AbsoluteContentSize.Y + 10
            Tween(module.Container, 0.25, { Size = UDim2.new(1, 0, 0, 28 + totalHeight) })
        else
            module.Arrow.Text = "+"
            Tween(module.Container, 0.25, { Size = UDim2.new(1, 0, 0, 28) })
        end
    end)

    -- Hover effects
    module.Header.MouseEnter:Connect(function()
        Tween(module.Container, 0.1, { BackgroundColor3 = Theme.ModuleHover })
    end)

    module.Header.MouseLeave:Connect(function()
        Tween(module.Container, 0.1, { BackgroundColor3 = Theme.ModuleBackground })
    end)

    -- Track content size changes to update expanded size
    module.OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if module.Expanded then
            local totalHeight = module.OptionsLayout.AbsoluteContentSize.Y + 10
            module.Container.Size = UDim2.new(1, 0, 0, 28 + totalHeight)
        end
    end)

    -- ═══════════════════════════════════
    -- MODULE OPTION BUILDERS
    -- ═══════════════════════════════════

    function module:OnToggle(callback)
        self.Callback = callback
        return self
    end

    -- Helper to show arrow when options are added
    local function showArrow()
        module.Arrow.Visible = true
    end

    -- ─── TOGGLE ───
    function module:Toggle(name, default, callback)
        showArrow()
        local option = { Type = "Toggle", Value = default or false }

        local container = Create("Frame", {
            Name = "Toggle_" .. name,
            Parent = self.OptionsFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = #self.Options + 1,
        })

        local label = Create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -36, 1, 0),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local toggleBg = Create("Frame", {
            Parent = container,
            BackgroundColor3 = option.Value and Theme.ToggleOn or Theme.ToggleOff,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -30, 0.5, -7),
            Size = UDim2.new(0, 26, 0, 14),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleBg })

        local toggleCircle = Create("Frame", {
            Parent = toggleBg,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Position = option.Value and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 1, 0.5, -5),
            Size = UDim2.new(0, 10, 0, 10),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleCircle })

        local button = Create("TextButton", {
            Parent = container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
        })

        button.MouseButton1Click:Connect(function()
            option.Value = not option.Value
            if option.Value then
                Tween(toggleBg, 0.2, { BackgroundColor3 = Theme.ToggleOn })
                Tween(toggleCircle, 0.2, { Position = UDim2.new(1, -13, 0.5, -5) })
            else
                Tween(toggleBg, 0.2, { BackgroundColor3 = Theme.ToggleOff })
                Tween(toggleCircle, 0.2, { Position = UDim2.new(0, 1, 0.5, -5) })
            end
            if callback then callback(option.Value) end
        end)

        option.Instance = container
        table.insert(self.Options, option)
        return option
    end

    -- ─── SLIDER ───
    function module:Slider(name, default, min, max, callback, decimals)
        showArrow()
        decimals = decimals or 1
        local option = { Type = "Slider", Value = default or min }

        local container = Create("Frame", {
            Name = "Slider_" .. name,
            Parent = self.OptionsFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            LayoutOrder = #self.Options + 1,
        })

        local label = Create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -40, 0, 14),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local valueLabel = Create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -40, 0, 0),
            Size = UDim2.new(0, 40, 0, 14),
            Font = Theme.Font,
            Text = tostring(default),
            TextColor3 = Theme.Accent,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
        })

        local sliderBg = Create("Frame", {
            Parent = container,
            BackgroundColor3 = Theme.SliderBackground,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 18),
            Size = UDim2.new(1, 0, 0, 12),
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = sliderBg })

        local fillPercent = (default - min) / (max - min)
        local sliderFill = Create("Frame", {
            Parent = sliderBg,
            BackgroundColor3 = Theme.SliderFill,
            BorderSizePixel = 0,
            Size = UDim2.new(fillPercent, 0, 1, 0),
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = sliderFill })

        -- Slider knob
        local knob = Create("Frame", {
            Parent = sliderBg,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Position = UDim2.new(fillPercent, -6, 0.5, -6),
            Size = UDim2.new(0, 12, 0, 12),
            ZIndex = 2,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

        local sliderButton = Create("TextButton", {
            Parent = sliderBg,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 3,
        })

        local sliding = false

        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local rawVal = min + (max - min) * pos
            local val = math.floor(rawVal * (10 ^ decimals) + 0.5) / (10 ^ decimals)
            option.Value = val
            valueLabel.Text = tostring(val)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -6, 0.5, -6)
            if callback then callback(val) end
        end

        sliderButton.MouseButton1Down:Connect(function()
            sliding = true
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)

        sliderButton.MouseButton1Click:Connect(function()
            -- Also update on direct click
        end)

        sliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateSlider(input)
            end
        end)

        option.Instance = container
        table.insert(self.Options, option)
        return option
    end

    -- ─── DROPDOWN ───
    function module:Dropdown(name, options, default, callback)
        showArrow()
        local option = { Type = "Dropdown", Value = default or options[1], Items = options }
        local dropdownOpen = false

        local container = Create("Frame", {
            Name = "Dropdown_" .. name,
            Parent = self.OptionsFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 38),
            LayoutOrder = #self.Options + 1,
            ClipsDescendants = false,
        })

        local label = Create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 14),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local dropBtn = Create("TextButton", {
            Parent = container,
            BackgroundColor3 = Theme.DropdownBackground,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 16),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Theme.Font,
            Text = "  " .. tostring(option.Value),
            TextColor3 = Theme.TextPrimary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = dropBtn })
        Create("UIStroke", { Color = Theme.OptionBorder, Thickness = 1, Parent = dropBtn })

        local dropArrow = Create("TextLabel", {
            Parent = dropBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -18, 0, 0),
            Size = UDim2.new(0, 14, 1, 0),
            Font = Theme.Font,
            Text = "▼",
            TextColor3 = Theme.TextDimmed,
            TextSize = 8,
        })

        -- Dropdown items container
        local dropList = Create("Frame", {
            Name = "DropList",
            Parent = container,
            BackgroundColor3 = Theme.DropdownBackground,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 37),
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            ZIndex = 50,
            Visible = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = dropList })
        Create("UIStroke", { Color = Theme.OptionBorder, Thickness = 1, Parent = dropList })

        local dropListLayout = Create("UIListLayout", {
            Parent = dropList,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
        })

        for i, item in ipairs(options) do
            local itemBtn = Create("TextButton", {
                Parent = dropList,
                BackgroundColor3 = Theme.DropdownBackground,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Theme.Font,
                Text = "  " .. item,
                TextColor3 = (item == option.Value) and Theme.Accent or Theme.TextSecondary,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                LayoutOrder = i,
                ZIndex = 51,
            })

            itemBtn.MouseEnter:Connect(function()
                Tween(itemBtn, 0.1, { BackgroundColor3 = Theme.DropdownHover })
            end)

            itemBtn.MouseLeave:Connect(function()
                Tween(itemBtn, 0.1, { BackgroundColor3 = Theme.DropdownBackground })
            end)

            itemBtn.MouseButton1Click:Connect(function()
                option.Value = item
                dropBtn.Text = "  " .. item

                -- Update text colors
                for _, c in ipairs(dropList:GetChildren()) do
                    if c:IsA("TextButton") then
                        c.TextColor3 = (c.Text == "  " .. item) and Theme.Accent or Theme.TextSecondary
                    end
                end

                -- Close dropdown
                dropdownOpen = false
                dropArrow.Text = "▼"
                Tween(dropList, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                task.delay(0.2, function()
                    dropList.Visible = false
                end)

                -- Resize container
                Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, 38) })

                if callback then callback(item) end

                -- Update parent module size
                task.wait(0.05)
                if module.Expanded then
                    local totalHeight = module.OptionsLayout.AbsoluteContentSize.Y + 10
                    module.Container.Size = UDim2.new(1, 0, 0, 28 + totalHeight)
                end
            end)
        end

        dropBtn.MouseButton1Click:Connect(function()
            dropdownOpen = not dropdownOpen
            if dropdownOpen then
                dropList.Visible = true
                dropArrow.Text = "▲"
                local listHeight = #options * 20
                Tween(dropList, 0.2, { Size = UDim2.new(1, 0, 0, listHeight) })
                Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, 38 + listHeight + 2) })
            else
                dropArrow.Text = "▼"
                Tween(dropList, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                task.delay(0.2, function()
                    dropList.Visible = false
                end)
                Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, 38) })
            end

            -- Update parent module size
            task.wait(0.25)
            if module.Expanded then
                local totalHeight = module.OptionsLayout.AbsoluteContentSize.Y + 10
                module.Container.Size = UDim2.new(1, 0, 0, 28 + totalHeight)
            end
        end)

        option.Instance = container
        table.insert(self.Options, option)
        return option
    end

    -- ─── COLOR PICKER ───
    function module:ColorPicker(name, default, callback)
        showArrow()
        default = default or Color3.fromRGB(255, 0, 0)
        local h, s, v = RGBtoHSV(default)
        local option = { Type = "ColorPicker", Value = default }
        local pickerOpen = false

        local container = Create("Frame", {
            Name = "Color_" .. name,
            Parent = self.OptionsFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = #self.Options + 1,
            ClipsDescendants = false,
        })

        local label = Create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -30, 0, 22),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        -- Color preview button
        local colorPreview = Create("TextButton", {
            Parent = container,
            BackgroundColor3 = default,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -22, 0, 3),
            Size = UDim2.new(0, 18, 0, 14),
            Text = "",
            AutoButtonColor = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = colorPreview })
        Create("UIStroke", { Color = Theme.OptionBorder, Thickness = 1, Parent = colorPreview })

        -- Color picker panel
        local pickerPanel = Create("Frame", {
            Name = "PickerPanel",
            Parent = container,
            BackgroundColor3 = Theme.DropdownBackground,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 24),
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 50,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = pickerPanel })
        Create("UIStroke", { Color = Theme.OptionBorder, Thickness = 1, Parent = pickerPanel })

        -- Saturation/Value box
        local svBox = Create("ImageLabel", {
            Parent = pickerPanel,
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, -36, 0, 80),
            Image = "rbxassetid://4155801252",
            ZIndex = 51,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = svBox })

        -- Darkening gradient overlay
        local darkOverlay = Create("ImageLabel", {
            Parent = svBox,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Image = "rbxassetid://4155801252",
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0,
            ZIndex = 52,
            ScaleType = Enum.ScaleType.Stretch,
        })

        -- Actually use a proper gradient
        -- White to transparent (left to right) on svBox
        -- Black to transparent (bottom to top) overlay
        svBox.Image = ""
        svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

        local whiteGrad = Create("UIGradient", {
            Parent = svBox,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
        })

        local blackOverlay = Create("Frame", {
            Parent = svBox,
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 52,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = blackOverlay })

        local blackGrad = Create("UIGradient", {
            Parent = blackOverlay,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Rotation = 270,
        })

        -- SV cursor
        local svCursor = Create("Frame", {
            Parent = svBox,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(s, -5, 1 - v, -5),
            Size = UDim2.new(0, 10, 0, 10),
            ZIndex = 55,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })
        Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = svCursor })

        -- Hue bar
        local hueBar = Create("Frame", {
            Parent = pickerPanel,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(1, -22, 0, 8),
            Size = UDim2.new(0, 12, 0, 80),
            ZIndex = 51,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = hueBar })

        -- Hue gradient
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

        -- Hue cursor
        local hueCursor = Create("Frame", {
            Parent = hueBar,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(0, -2, h, -2),
            Size = UDim2.new(1, 4, 0, 4),
            ZIndex = 55,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = hueCursor })
        Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = hueCursor })

        -- SV input
        local svButton = Create("TextButton", {
            Parent = svBox,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 56,
        })

        local hueButton = Create("TextButton", {
            Parent = hueBar,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 56,
        })

        local function updateColor()
            option.Value = Color3.fromHSV(h, s, v)
            colorPreview.BackgroundColor3 = option.Value
            svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            hueCursor.Position = UDim2.new(0, -2, h, -2)
            if callback then callback(option.Value) end
        end

        local draggingSV = false
        local draggingHue = false

        svButton.MouseButton1Down:Connect(function()
            draggingSV = true
        end)

        hueButton.MouseButton1Down:Connect(function()
            draggingHue = true
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSV = false
                draggingHue = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if draggingSV then
                    s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                    updateColor()
                elseif draggingHue then
                    h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                    updateColor()
                end
            end
        end)

        svButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                updateColor()
            end
        end)

        hueButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                updateColor()
            end
        end)

        -- Toggle picker
        colorPreview.MouseButton1Click:Connect(function()
            pickerOpen = not pickerOpen
            if pickerOpen then
                pickerPanel.Visible = true
                Tween(pickerPanel, 0.2, { Size = UDim2.new(1, 0, 0, 96) })
                Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, 122) })
            else
                Tween(pickerPanel, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                task.delay(0.2, function() pickerPanel.Visible = false end)
                Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, 22) })
            end

            task.wait(0.25)
            if module.Expanded then
                local totalHeight = module.OptionsLayout.AbsoluteContentSize.Y + 10
                module.Container.Size = UDim2.new(1, 0, 0, 28 + totalHeight)
            end
        end)

        option.Instance = container
        table.insert(self.Options, option)
        return option
    end

    -- ─── KEYBIND ───
    function module:Keybind(name, default, callback)
        showArrow()
        local option = { Type = "Keybind", Value = default or Enum.KeyCode.Unknown }
        local listening = false

        local container = Create("Frame", {
            Name = "Keybind_" .. name,
            Parent = self.OptionsFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = #self.Options + 1,
        })

        local label = Create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -55, 1, 0),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local bindBtn = Create("TextButton", {
            Parent = container,
            BackgroundColor3 = Theme.DropdownBackground,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -50, 0, 2),
            Size = UDim2.new(0, 46, 0, 18),
            Font = Theme.Font,
            Text = default and default.Name or "None",
            TextColor3 = Theme.TextPrimary,
            TextSize = 10,
            AutoButtonColor = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = bindBtn })
        Create("UIStroke", { Color = Theme.OptionBorder, Thickness = 1, Parent = bindBtn })

        bindBtn.MouseButton1Click:Connect(function()
            listening = true
            bindBtn.Text = "..."
            bindBtn.TextColor3 = Theme.Accent
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        option.Value = Enum.KeyCode.Unknown
                        bindBtn.Text = "None"
                    else
                        option.Value = input.KeyCode
                        bindBtn.Text = input.KeyCode.Name
                    end
                    bindBtn.TextColor3 = Theme.TextPrimary
                    listening = false
                end
            else
                if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == option.Value and option.Value ~= Enum.KeyCode.Unknown then
                        if callback then callback(option.Value) end
                    end
                end
            end
        end)

        option.Instance = container
        table.insert(self.Options, option)
        return option
    end

    -- ─── TEXT INPUT ───
    function module:TextBox(name, default, placeholder, callback)
        showArrow()
        local option = { Type = "TextBox", Value = default or "" }

        local container = Create("Frame", {
            Name = "TextBox_" .. name,
            Parent = self.OptionsFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 38),
            LayoutOrder = #self.Options + 1,
        })

        local label = Create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 14),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local textBox = Create("TextBox", {
            Parent = container,
            BackgroundColor3 = Theme.DropdownBackground,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 16),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Theme.Font,
            Text = default or "",
            PlaceholderText = placeholder or "Enter text...",
            PlaceholderColor3 = Theme.TextDimmed,
            TextColor3 = Theme.TextPrimary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = textBox })
        Create("UIStroke", { Color = Theme.OptionBorder, Thickness = 1, Parent = textBox })
        Create("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = textBox })

        textBox.FocusLost:Connect(function(enterPressed)
            option.Value = textBox.Text
            if callback then callback(textBox.Text, enterPressed) end
        end)

        textBox.Focused:Connect(function()
            Tween(textBox, 0.15, { BackgroundColor3 = Theme.ModuleBackground })
        end)

        textBox.FocusLost:Connect(function()
            Tween(textBox, 0.15, { BackgroundColor3 = Theme.DropdownBackground })
        end)

        option.Instance = container
        table.insert(self.Options, option)
        return option
    end

    -- ─── LABEL / SEPARATOR ───
    function module:Label(text)
        showArrow()
        local option = { Type = "Label" }

        local container = Create("Frame", {
            Name = "Label",
            Parent = self.OptionsFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            LayoutOrder = #self.Options + 1,
        })

        Create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Theme.Font,
            Text = text,
            TextColor3 = Theme.TextDimmed,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        option.Instance = container
        table.insert(self.Options, option)
        return option
    end

    -- ─── SEPARATOR ───
    function module:Separator()
        showArrow()
        local option = { Type = "Separator" }

        local container = Create("Frame", {
            Name = "Separator",
            Parent = self.OptionsFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 8),
            LayoutOrder = #self.Options + 1,
        })

        Create("Frame", {
            Parent = container,
            BackgroundColor3 = Theme.Separator,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })

        option.Instance = container
        table.insert(self.Options, option)
        return option
    end

    table.insert(tab.Modules, module)
    return module
end

-- ═══════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════
function Library:Notify(title, message, duration)
    duration = duration or 3

    local notifFrame = Create("Frame", {
        Parent = self.ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 10, 1, -60),
        Size = UDim2.new(0, 250, 0, 50),
        ZIndex = 100,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = notifFrame })
    Create("UIStroke", { Color = Theme.Accent, Thickness = 1, Parent = notifFrame })

    -- Accent bar on left
    local bar = Create("Frame", {
        Parent = notifFrame,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 101,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = bar })

    Create("TextLabel", {
        Parent = notifFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -16, 0, 16),
        Font = Theme.FontBold,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
    })

    Create("TextLabel", {
        Parent = notifFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 20),
        Size = UDim2.new(1, -16, 0, 26),
        Font = Theme.Font,
        Text = message,
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 101,
    })

    -- Slide in
    Tween(notifFrame, 0.3, { Position = UDim2.new(1, -260, 1, -60) })

    -- Progress bar
    local progress = Create("Frame", {
        Parent = notifFrame,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 101,
    })

    Tween(progress, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

    -- Slide out and destroy
    task.delay(duration, function()
        Tween(notifFrame, 0.3, { Position = UDim2.new(1, 10, 1, -60) })
        task.delay(0.3, function()
            notifFrame:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════
-- WATERMARK
-- ═══════════════════════════════════════════
function Library:Watermark(text)
    local wm = Create("TextLabel", {
        Parent = self.ScreenGui,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Theme.Font,
        Text = text or self.Name,
        TextColor3 = Theme.Accent,
        TextSize = 12,
        ZIndex = 100,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = wm })
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = wm,
    })
    Create("UIStroke", { Color = Theme.Accent, Thickness = 1, Transparency = 0.5, Parent = wm })

    self.WatermarkLabel = wm
    return wm
end

function Library:Destroy()
    self.ScreenGui:Destroy()
end

return Library
