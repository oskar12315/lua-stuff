--[[
    Minecraft Hack Client Style UI Library
    
    Usage:
        local UI = require(this)
        local Client = UI.new("Catalyst")
        
        local combat = Client:Category("COMBAT")
        local ka = combat:Module("killaura")
        ka:Slider("range", 4, 1, 8, function(v) end)
        ka:Slider("cps", 12, 1, 20, function(v) end)
        ka:Toggle("players", true, function(v) end)
        ka:Toggle("mobs", false, function(v) end)
        ka:Dropdown("mode", {"single","multi","switch"}, "switch", function(v) end)
        ka:Keybind("bind", Enum.KeyCode.S, function() end)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

-- ═══════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════
local Theme = {
    Background       = Color3.fromRGB(18, 18, 22),
    CategoryBg       = Color3.fromRGB(24, 24, 30),
    CategoryBorder   = Color3.fromRGB(45, 45, 55),
    CategoryHeader   = Color3.fromRGB(200, 200, 210),
    ModuleEnabled    = Color3.fromRGB(230, 140, 180),  -- pink when on
    ModuleDisabled   = Color3.fromRGB(200, 200, 210),  -- white/gray when off
    OptionText       = Color3.fromRGB(160, 160, 170),
    OptionValueText  = Color3.fromRGB(220, 220, 230),
    AccentPink       = Color3.fromRGB(230, 140, 180),
    AccentPinkDark   = Color3.fromRGB(180, 100, 140),
    SliderBg         = Color3.fromRGB(40, 40, 50),
    SliderFill       = Color3.fromRGB(230, 140, 180),
    ToggleOnBg       = Color3.fromRGB(230, 140, 180),
    ToggleOffBg      = Color3.fromRGB(60, 60, 70),
    ToggleKnob       = Color3.fromRGB(220, 220, 230),
    DropdownBg       = Color3.fromRGB(30, 30, 38),
    DropdownHover    = Color3.fromRGB(45, 45, 55),
    DropdownBorder   = Color3.fromRGB(55, 55, 65),
    SettingsBorder   = Color3.fromRGB(40, 40, 50),
    KeybindText      = Color3.fromRGB(140, 140, 150),
    KeybindBracket   = Color3.fromRGB(100, 100, 110),
    Separator        = Color3.fromRGB(40, 40, 50),
    PickerBg         = Color3.fromRGB(28, 28, 35),
    Font             = Enum.Font.Gotham,
    FontSemibold     = Enum.Font.GothamSemibold,
    FontBold         = Enum.Font.GothamBold,
}

-- ═══════════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════════
local function Create(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then
                inst[k] = v
            end
        end
        if props.Parent then
            inst.Parent = props.Parent
        end
    end
    if children then
        for _, c in ipairs(children) do
            c.Parent = inst
        end
    end
    return inst
end

local function Tween(inst, dur, props, style, dir)
    local t = TweenService:Create(inst, TweenInfo.new(dur, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function RGBtoHSV(c)
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

-- ═══════════════════════════════════════════
-- MAIN LIBRARY
-- ═══════════════════════════════════════════
function Library.new(clientName)
    local self = setmetatable({}, Library)
    self.Name = clientName or "Client"
    self.Categories = {}
    self.Visible = true
    self.ToggleKey = Enum.KeyCode.RightShift

    -- cleanup
    local existing = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MCClientUI")
    if existing then existing:Destroy() end

    self.ScreenGui = Create("ScreenGui", {
        Name = "MCClientUI",
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999,
    })

    -- dark background overlay (subtle)
    self.Overlay = Create("Frame", {
        Name = "Overlay",
        Parent = self.ScreenGui,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
    })

    -- main container that holds all category columns side by side
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 20),
        Size = UDim2.new(1, -40, 1, -40),
        ClipsDescendants = false,
    })

    -- horizontal layout for categories
    self.ColumnsLayout = Create("UIListLayout", {
        Parent = self.MainFrame,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })

    -- toggle visibility
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self.Visible = not self.Visible
            self.MainFrame.Visible = self.Visible
            self.Overlay.Visible = self.Visible
        end
    end)

    return self
end

-- ═══════════════════════════════════════════
-- CATEGORY (each column)
-- ═══════════════════════════════════════════
function Library:Category(name)
    local cat = {
        Name = name,
        Modules = {},
        Library = self,
    }

    local catIndex = #self.Categories + 1

    -- outer column frame
    cat.Frame = Create("Frame", {
        Name = "Cat_" .. name,
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.CategoryBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 220, 0, 40), -- will auto-size Y
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = catIndex,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = cat.Frame })
    Create("UIStroke", { Color = Theme.CategoryBorder, Thickness = 1, Transparency = 0.3, Parent = cat.Frame })

    -- inner padding
    Create("UIPadding", {
        Parent = cat.Frame,
        PaddingTop = UDim.new(0, 0),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 0),
        PaddingRight = UDim.new(0, 0),
    })

    -- header
    cat.Header = Create("TextLabel", {
        Name = "Header",
        Parent = cat.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Font = Theme.FontBold,
        Text = string.upper(name),
        TextColor3 = Theme.CategoryHeader,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    })
    Create("UIPadding", {
        Parent = cat.Header,
        PaddingLeft = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 0),
    })

    -- separator under header
    cat.HeaderSep = Create("Frame", {
        Name = "HeaderSep",
        Parent = cat.Frame,
        BackgroundColor3 = Theme.Separator,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 0, 0),
        LayoutOrder = 1,
    })

    -- modules list container
    cat.ModuleList = Create("Frame", {
        Name = "ModuleList",
        Parent = cat.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
    })

    Create("UIListLayout", {
        Parent = cat.ModuleList,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })

    -- we need a vertical layout for the whole cat.Frame children
    local mainLayout = Create("UIListLayout", {
        Parent = cat.Frame,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })

    function cat:Module(moduleName)
        return Library._CreateModule(self, moduleName)
    end

    table.insert(self.Categories, cat)
    return cat
end

-- ═══════════════════════════════════════════
-- MODULE
-- ═══════════════════════════════════════════
function Library._CreateModule(cat, moduleName)
    local mod = {
        Name = moduleName,
        Enabled = false,
        Expanded = false,
        Options = {},
        Category = cat,
        Callback = nil,
        Keybind = nil,
    }

    local modIndex = #cat.Modules + 1

    -- module wrapper (contains header row + expandable options)
    mod.Container = Create("Frame", {
        Name = "Mod_" .. moduleName,
        Parent = cat.ModuleList,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = modIndex,
        ClipsDescendants = true,
    })

    -- module header row (the clickable name)
    mod.HeaderRow = Create("TextButton", {
        Name = "HeaderRow",
        Parent = mod.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Font = Theme.FontSemibold,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 0,
    })

    -- module name label
    mod.NameLabel = Create("TextLabel", {
        Name = "ModName",
        Parent = mod.HeaderRow,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Theme.FontSemibold,
        Text = string.lower(moduleName),
        TextColor3 = Theme.ModuleDisabled,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- keybind label (shown on right side like [S])
    mod.BindLabel = Create("TextLabel", {
        Name = "BindLabel",
        Parent = mod.HeaderRow,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Font = Theme.Font,
        Text = "",
        TextColor3 = Theme.KeybindBracket,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    Create("UIPadding", {
        Parent = mod.BindLabel,
        PaddingRight = UDim.new(0, 14),
    })

    -- options container (expanded area below module name)
    mod.OptionsFrame = Create("Frame", {
        Name = "Options",
        Parent = mod.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        Visible = false,
    })

    -- left accent bar for expanded options
    mod.AccentBar = Create("Frame", {
        Name = "AccentBar",
        Parent = mod.OptionsFrame,
        BackgroundColor3 = Theme.AccentPink,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0, 2, 1, 0),
    })

    -- options inner list
    mod.OptionsInner = Create("Frame", {
        Name = "OptionsInner",
        Parent = mod.OptionsFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 2),
        Size = UDim2.new(1, -38, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    mod.OptionsLayout = Create("UIListLayout", {
        Parent = mod.OptionsInner,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })

    Create("UIPadding", {
        Parent = mod.OptionsInner,
        PaddingBottom = UDim.new(0, 6),
    })

    -- container layout
    Create("UIListLayout", {
        Parent = mod.Container,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    })

    -- ─── LEFT CLICK: toggle module ───
    mod.HeaderRow.MouseButton1Click:Connect(function()
        mod.Enabled = not mod.Enabled
        if mod.Enabled then
            Tween(mod.NameLabel, 0.15, { TextColor3 = Theme.ModuleEnabled })
        else
            Tween(mod.NameLabel, 0.15, { TextColor3 = Theme.ModuleDisabled })
        end
        if mod.Callback then
            mod.Callback(mod.Enabled)
        end
    end)

    -- ─── RIGHT CLICK: expand/collapse settings ───
    mod.HeaderRow.MouseButton2Click:Connect(function()
        if #mod.Options == 0 then return end
        mod.Expanded = not mod.Expanded
        mod.OptionsFrame.Visible = mod.Expanded
    end)

    -- ─── HOVER ───
    mod.HeaderRow.MouseEnter:Connect(function()
        if not mod.Enabled then
            Tween(mod.NameLabel, 0.1, { TextColor3 = Color3.fromRGB(230, 230, 240) })
        end
    end)

    mod.HeaderRow.MouseLeave:Connect(function()
        if not mod.Enabled then
            Tween(mod.NameLabel, 0.1, { TextColor3 = Theme.ModuleDisabled })
        end
    end)

    -- ═════════════════════════════════
    -- OPTION BUILDERS
    -- ═════════════════════════════════

    function mod:OnToggle(callback)
        self.Callback = callback
        return self
    end

    -- ─── TOGGLE ───
    function mod:Toggle(name, default, callback)
        local opt = { Type = "Toggle", Value = default or false, Name = name }

        local row = Create("Frame", {
            Name = "Toggle_" .. name,
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            LayoutOrder = #self.Options + 1,
        })

        local label = Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        -- toggle switch background
        local toggleBg = Create("Frame", {
            Parent = row,
            BackgroundColor3 = opt.Value and Theme.ToggleOnBg or Theme.ToggleOffBg,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -38, 0.5, -8),
            Size = UDim2.new(0, 32, 0, 16),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleBg })

        -- toggle knob
        local knob = Create("Frame", {
            Parent = toggleBg,
            BackgroundColor3 = Theme.ToggleKnob,
            BorderSizePixel = 0,
            Position = opt.Value and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
            Size = UDim2.new(0, 12, 0, 12),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

        local btn = Create("TextButton", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 5,
        })

        btn.MouseButton1Click:Connect(function()
            opt.Value = not opt.Value
            if opt.Value then
                Tween(toggleBg, 0.2, { BackgroundColor3 = Theme.ToggleOnBg })
                Tween(knob, 0.2, { Position = UDim2.new(1, -15, 0.5, -6) })
            else
                Tween(toggleBg, 0.2, { BackgroundColor3 = Theme.ToggleOffBg })
                Tween(knob, 0.2, { Position = UDim2.new(0, 2, 0.5, -6) })
            end
            if callback then callback(opt.Value) end
        end)

        table.insert(self.Options, opt)
        return opt
    end

    -- ─── SLIDER ───
    function mod:Slider(name, default, min, max, callback, suffix, decimals)
        suffix = suffix or ""
        decimals = decimals or 1
        default = default or min
        local opt = { Type = "Slider", Value = default, Name = name }

        local row = Create("Frame", {
            Name = "Slider_" .. name,
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            LayoutOrder = #self.Options + 1,
        })

        -- top row: label + value
        local label = Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.6, 0, 0, 16),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local valueLabel = Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.6, 0, 0, 0),
            Size = UDim2.new(0.4, 0, 0, 16),
            Font = Theme.FontSemibold,
            Text = tostring(default) .. suffix,
            TextColor3 = Theme.OptionValueText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
        })

        -- slider track
        local track = Create("Frame", {
            Parent = row,
            BackgroundColor3 = Theme.SliderBg,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 20),
            Size = UDim2.new(1, 0, 0, 6),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

        local fillPct = math.clamp((default - min) / (max - min), 0, 1)
        local fill = Create("Frame", {
            Parent = track,
            BackgroundColor3 = Theme.SliderFill,
            BorderSizePixel = 0,
            Size = UDim2.new(fillPct, 0, 1, 0),
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

        -- knob
        local knob = Create("Frame", {
            Parent = track,
            BackgroundColor3 = Theme.ToggleKnob,
            BorderSizePixel = 0,
            Position = UDim2.new(fillPct, -5, 0.5, -5),
            Size = UDim2.new(0, 10, 0, 10),
            ZIndex = 3,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

        local sliderBtn = Create("TextButton", {
            Parent = track,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 10),
            Position = UDim2.new(0, 0, 0, -5),
            Text = "",
            ZIndex = 5,
        })

        local sliding = false

        local function update(input)
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local raw = min + (max - min) * pct
            local val = math.floor(raw * (10 ^ decimals) + 0.5) / (10 ^ decimals)
            opt.Value = val
            valueLabel.Text = tostring(val) .. suffix
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -5, 0.5, -5)
            if callback then callback(val) end
        end

        sliderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input)
            end
        end)

        table.insert(self.Options, opt)
        return opt
    end

    -- ─── DROPDOWN ───
    function mod:Dropdown(name, items, default, callback)
        local opt = { Type = "Dropdown", Value = default or items[1], Items = items, Name = name }
        local dropOpen = false

        local row = Create("Frame", {
            Name = "Drop_" .. name,
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = #self.Options + 1,
            ClipsDescendants = false,
        })

        -- top row with label + current value
        local topRow = Create("Frame", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            LayoutOrder = 0,
        })

        local label = Create("TextLabel", {
            Parent = topRow,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local valueBtn = Create("TextButton", {
            Parent = topRow,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
            Font = Theme.FontSemibold,
            Text = tostring(opt.Value),
            TextColor3 = Theme.OptionValueText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            AutoButtonColor = false,
        })

        -- dropdown list
        local dropList = Create("Frame", {
            Name = "DropList",
            Parent = row,
            BackgroundColor3 = Theme.DropdownBg,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 26),
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 20,
            LayoutOrder = 1,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = dropList })
        Create("UIStroke", { Color = Theme.DropdownBorder, Thickness = 1, Parent = dropList })

        local dropLayout = Create("UIListLayout", {
            Parent = dropList,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
        })

        Create("UIPadding", {
            Parent = dropList,
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 2),
        })

        for i, item in ipairs(items) do
            local itemBtn = Create("TextButton", {
                Parent = dropList,
                BackgroundColor3 = Theme.DropdownBg,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 22),
                Font = Theme.Font,
                Text = item,
                TextColor3 = (item == opt.Value) and Theme.AccentPink or Theme.OptionText,
                TextSize = 11,
                AutoButtonColor = false,
                LayoutOrder = i,
                ZIndex = 21,
            })

            itemBtn.MouseEnter:Connect(function()
                Tween(itemBtn, 0.1, { BackgroundColor3 = Theme.DropdownHover })
            end)
            itemBtn.MouseLeave:Connect(function()
                Tween(itemBtn, 0.1, { BackgroundColor3 = Theme.DropdownBg })
            end)

            itemBtn.MouseButton1Click:Connect(function()
                opt.Value = item
                valueBtn.Text = item
                -- update colors
                for _, c in ipairs(dropList:GetChildren()) do
                    if c:IsA("TextButton") then
                        c.TextColor3 = (c.Text == item) and Theme.AccentPink or Theme.OptionText
                    end
                end
                -- close
                dropOpen = false
                dropList.Visible = false
                if callback then callback(item) end
            end)
        end

        valueBtn.MouseButton1Click:Connect(function()
            dropOpen = not dropOpen
            dropList.Visible = dropOpen
        end)

        -- layout for the row
        Create("UIListLayout", {
            Parent = row,
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        })

        table.insert(self.Options, opt)
        return opt
    end

    -- ─── COLOR PICKER ───
    function mod:ColorPicker(name, default, callback)
        default = default or Color3.fromRGB(255, 0, 0)
        local h, s, v = RGBtoHSV(default)
        local opt = { Type = "ColorPicker", Value = default, Name = name }
        local pickerOpen = false

        local row = Create("Frame", {
            Name = "Color_" .. name,
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = #self.Options + 1,
            ClipsDescendants = false,
        })

        local topRow = Create("Frame", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            LayoutOrder = 0,
        })

        Create("TextLabel", {
            Parent = topRow,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 1, 0),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local preview = Create("TextButton", {
            Parent = topRow,
            BackgroundColor3 = default,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -22, 0.5, -7),
            Size = UDim2.new(0, 18, 0, 14),
            Text = "",
            AutoButtonColor = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = preview })
        Create("UIStroke", { Color = Theme.DropdownBorder, Thickness = 1, Parent = preview })

        -- picker panel
        local panel = Create("Frame", {
            Parent = row,
            BackgroundColor3 = Theme.PickerBg,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 100),
            Visible = false,
            LayoutOrder = 1,
            ZIndex = 20,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = panel })
        Create("UIStroke", { Color = Theme.DropdownBorder, Thickness = 1, Parent = panel })

        -- SV box
        local svBox = Create("Frame", {
            Parent = panel,
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, -34, 0, 82),
            ZIndex = 21,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = svBox })

        -- white gradient (left to right saturation)
        Create("UIGradient", {
            Parent = svBox,
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
        })

        -- black overlay (bottom to top value)
        local blackOv = Create("Frame", {
            Parent = svBox,
            BackgroundColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 22,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = blackOv })
        Create("UIGradient", {
            Parent = blackOv,
            Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
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
            ZIndex = 25,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })
        Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = svCursor })

        -- hue bar
        local hueBar = Create("Frame", {
            Parent = panel,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(1, -20, 0, 8),
            Size = UDim2.new(0, 10, 0, 82),
            ZIndex = 21,
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
            ZIndex = 25,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = hueCursor })
        Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = hueCursor })

        -- input buttons
        local svBtn = Create("TextButton", {
            Parent = svBox,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 26,
        })

        local hueBtn = Create("TextButton", {
            Parent = hueBar,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 6, 1, 0),
            Position = UDim2.new(0, -3, 0, 0),
            Text = "",
            ZIndex = 26,
        })

        local function updateColor()
            opt.Value = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = opt.Value
            svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            hueCursor.Position = UDim2.new(0, -2, h, -2)
            if callback then callback(opt.Value) end
        end

        local dragSV, dragHue = false, false

        svBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragSV = true
                s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                updateColor()
            end
        end)

        hueBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragHue = true
                h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                updateColor()
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragSV = false
                dragHue = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if dragSV then
                    s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                    updateColor()
                elseif dragHue then
                    h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                    updateColor()
                end
            end
        end)

        preview.MouseButton1Click:Connect(function()
            pickerOpen = not pickerOpen
            panel.Visible = pickerOpen
        end)

        Create("UIListLayout", {
            Parent = row,
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        })

        table.insert(self.Options, opt)
        return opt
    end

    -- ─── KEYBIND ───
    function mod:Keybind(name, default, callback)
        local opt = { Type = "Keybind", Value = default or Enum.KeyCode.Unknown, Name = name }
        local listening = false

        -- set the module-level bind display
        local function updateBindDisplay()
            if opt.Value and opt.Value ~= Enum.KeyCode.Unknown then
                mod.BindLabel.Text = "[" .. opt.Value.Name .. "]"
            else
                mod.BindLabel.Text = "[none]"
            end
        end
        updateBindDisplay()

        -- also create an option row if you want it in the expanded section
        local row = Create("Frame", {
            Name = "Bind_" .. name,
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            LayoutOrder = #self.Options + 1,
        })

        Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.OptionText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local bindBtn = Create("TextButton", {
            Parent = row,
            BackgroundColor3 = Theme.DropdownBg,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -60, 0.5, -10),
            Size = UDim2.new(0, 56, 0, 20),
            Font = Theme.Font,
            Text = opt.Value ~= Enum.KeyCode.Unknown and opt.Value.Name or "none",
            TextColor3 = Theme.OptionValueText,
            TextSize = 11,
            AutoButtonColor = false,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = bindBtn })
        Create("UIStroke", { Color = Theme.DropdownBorder, Thickness = 1, Parent = bindBtn })

        bindBtn.MouseButton1Click:Connect(function()
            listening = true
            bindBtn.Text = "..."
            Tween(bindBtn, 0.1, { TextColor3 = Theme.AccentPink })
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        opt.Value = Enum.KeyCode.Unknown
                        bindBtn.Text = "none"
                    else
                        opt.Value = input.KeyCode
                        bindBtn.Text = input.KeyCode.Name
                    end
                    Tween(bindBtn, 0.1, { TextColor3 = Theme.OptionValueText })
                    updateBindDisplay()
                    listening = false
                end
            else
                if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == opt.Value and opt.Value ~= Enum.KeyCode.Unknown then
                        -- toggle the module via keybind
                        mod.Enabled = not mod.Enabled
                        if mod.Enabled then
                            Tween(mod.NameLabel, 0.15, { TextColor3 = Theme.ModuleEnabled })
                        else
                            Tween(mod.NameLabel, 0.15, { TextColor3 = Theme.ModuleDisabled })
                        end
                        if mod.Callback then mod.Callback(mod.Enabled) end
                        if callback then callback(opt.Value) end
                    end
                end
            end
        end)

        table.insert(self.Options, opt)
        return opt
    end

    -- ─── LABEL ───
    function mod:Label(text)
        local opt = { Type = "Label" }
        Create("TextLabel", {
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Font = Theme.Font,
            Text = text,
            TextColor3 = Theme.KeybindBracket,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = #self.Options + 1,
        })
        table.insert(self.Options, opt)
        return opt
    end

    -- ─── SEPARATOR ───
    function mod:Separator()
        local opt = { Type = "Separator" }
        local sep = Create("Frame", {
            Parent = self.OptionsInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 8),
            LayoutOrder = #self.Options + 1,
        })
        Create("Frame", {
            Parent = sep,
            BackgroundColor3 = Theme.Separator,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })
        table.insert(self.Options, opt)
        return opt
    end

    table.insert(cat.Modules, mod)
    return mod
end

function Library:Destroy()
    self.ScreenGui:Destroy()
end

return Library
