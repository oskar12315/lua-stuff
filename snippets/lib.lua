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
    KbwName = Color3.fromRGB(240, 240, 250),
    KbwBind = Color3.fromRGB(200, 200, 215),
    KbwHeader = Color3.fromRGB(250, 250, 255),
    LoadBg = Color3.fromRGB(14, 14, 18),
    LoadBar = Color3.fromRGB(230, 140, 180),
    LoadBarBg = Color3.fromRGB(40, 40, 50),
    LoadText = Color3.fromRGB(200, 200, 215),
    LoadSub = Color3.fromRGB(130, 130, 145),
}

local F = { R = Enum.Font.Gotham, S = Enum.Font.GothamSemibold, B = Enum.Font.GothamBold }
local CFG_DIR = "MCClientConfigs"
local AUTO_CFG = "_autoload"

local function Make(c, p)
    local i = Instance.new(c)
    if p then
        for k, v in pairs(p) do
            if k ~= "Parent" then pcall(function() i[k] = v end) end
        end
        if p.Parent then i.Parent = p.Parent end
    end
    return i
end

local function Tw(i, d, p, s)
    local t = TweenService:Create(i, TweenInfo.new(d, s or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
    t:Play()
    return t
end

local function HSV(c)
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

local function FW(p, c) pcall(function() if writefile then writefile(p, c) end end) end
local function FR(p) local o, r = pcall(function() if readfile and isfile and isfile(p) then return readfile(p) end end); return o and r or nil end
local function FD(p) pcall(function() if delfile and isfile and isfile(p) then delfile(p) end end) end
local function FM(p) pcall(function() if makefolder and (not isfolder or not isfolder(p)) then makefolder(p) end end) end
local function FL(p) local o, r = pcall(function() if listfiles and isfolder and isfolder(p) then return listfiles(p) end return {} end); return o and r or {} end

local Drags = { sl = {}, sv = {}, hu = {}, ok = false }
function Drags.Init(lib)
    if Drags.ok then return end
    Drags.ok = true
    table.insert(lib.conn, UserInputService.InputChanged:Connect(function(inp)
        if lib.dead then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            for _, x in ipairs(Drags.sl) do if x.on then x.fn(inp) end end
            for _, x in ipairs(Drags.sv) do if x.on then x.fn(inp) end end
            for _, x in ipairs(Drags.hu) do if x.on then x.fn(inp) end end
        end
    end))
    table.insert(lib.conn, UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, x in ipairs(Drags.sl) do x.on = false end
            for _, x in ipairs(Drags.sv) do x.on = false end
            for _, x in ipairs(Drags.hu) do x.on = false end
        end
    end))
end

local function ShowLoading(gui, clientName, onDone)
    local loadFrame = Make("Frame", {
        Parent = gui,
        BackgroundColor3 = Theme.LoadBg,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 500,
    })

    local center = Make("Frame", {
        Parent = loadFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 300, 0, 100), ZIndex = 501,
    })

    local title = Make("TextLabel", {
        Parent = center, BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, 0, 0, 30), Font = F.B,
        Text = string.upper(clientName), TextColor3 = Theme.Accent,
        TextSize = 22, ZIndex = 502,
    })

    local subtitle = Make("TextLabel", {
        Parent = center, BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 32), AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, 0, 0, 18), Font = F.R,
        Text = "loading...", TextColor3 = Theme.LoadSub,
        TextSize = 12, ZIndex = 502,
    })

    local barBg = Make("Frame", {
        Parent = center, BackgroundColor3 = Theme.LoadBarBg,
        Position = UDim2.new(0.5, 0, 0, 60), AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0.8, 0, 0, 4), ZIndex = 502,
    })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barBg })

    local barFill = Make("Frame", {
        Parent = barBg, BackgroundColor3 = Theme.LoadBar,
        Size = UDim2.new(0, 0, 1, 0), ZIndex = 503,
    })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barFill })

    local pctText = Make("TextLabel", {
        Parent = center, BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 70), AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, 0, 0, 16), Font = F.R,
        Text = "0%", TextColor3 = Theme.LoadSub,
        TextSize = 10, ZIndex = 502,
    })

    task.spawn(function()
        local stages = {
            { pct = 0.15, text = "initializing modules..." },
            { pct = 0.30, text = "loading categories..." },
            { pct = 0.50, text = "setting up keybinds..." },
            { pct = 0.65, text = "building ui elements..." },
            { pct = 0.80, text = "loading config..." },
            { pct = 0.92, text = "finalizing..." },
            { pct = 1.00, text = "done!" },
        }
        for _, stage in ipairs(stages) do
            subtitle.Text = stage.text
            Tw(barFill, 0.3, { Size = UDim2.new(stage.pct, 0, 1, 0) }, Enum.EasingStyle.Quart)
            pctText.Text = math.floor(stage.pct * 100) .. "%"
            task.wait(math.random(15, 35) / 100)
        end
        task.wait(0.3)
        Tw(loadFrame, 0.5, { BackgroundTransparency = 1 })
        Tw(title, 0.3, { TextTransparency = 1 })
        Tw(subtitle, 0.3, { TextTransparency = 1 })
        Tw(barBg, 0.3, { BackgroundTransparency = 1 })
        Tw(barFill, 0.3, { BackgroundTransparency = 1 })
        Tw(pctText, 0.3, { TextTransparency = 1 })
        task.wait(0.5)
        loadFrame:Destroy()
        if onDone then onDone() end
    end)
end

function Library.new(name)
    local self = setmetatable({}, Library)
    self.name = name or "Client"
    self.cats = {}
    self.mods = {}
    self.opts = {}
    self.conn = {}
    self.accTrk = {}
    self.catHdrs = {}
    self.kbListen = {}
    self.vis = true
    self.tKey = Enum.KeyCode.P
    self.dead = false
    self.popup = nil
    self._animating = false
    self._loaded = false

    function self:SetKey(key)
        self.tKey = key
    end

    local old = LP.PlayerGui:FindFirstChild("MCHUI")
    if old then old:Destroy() end

    self.gui = Make("ScreenGui", {
        Name = "MCHUI",
        Parent = LP:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
        DisplayOrder = 999,
        IgnoreGuiInset = true,
    })

    self.cLayer = Make("Frame", {
        Parent = self.gui, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 1, Visible = true,
    })

    self.sLayer = Make("Frame", {
        Parent = self.gui, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 50, Visible = true,
    })

    self.pLayer = Make("Frame", {
        Parent = self.gui, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 100,
    })

    self.away = Make("TextButton", {
        Parent = self.pLayer, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 100, Visible = false,
    })
    self.away.MouseButton1Click:Connect(function() self:CPop() end)

    self:MkSearch()

    self.scroll = Make("ScrollingFrame", {
        Parent = self.cLayer, BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 52), AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, -20, 1, -60),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X,
        ClipsDescendants = false, ZIndex = 1,
    })

    Make("UIListLayout", {
        Parent = self.scroll,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })

    self:MkKBW()
    Drags.Init(self)

    -- loading screen - blocks input until done
    ShowLoading(self.gui, self.name, function()
        self._loaded = true
        for i, cat in ipairs(self.cats) do
            cat.frame.BackgroundTransparency = 1
            task.delay(i * 0.05, function()
                Tw(cat.frame, 0.35, { BackgroundTransparency = 0.06 }, Enum.EasingStyle.Quart)
            end)
        end
    end)

    -- toggle - ONLY works after loading
    table.insert(self.conn, UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe or self.dead or self._animating or not self._loaded then return end
        if inp.KeyCode == self.tKey then
            self._animating = true
            self.vis = not self.vis
            self.searchDrop.Visible = false

            if self.vis then
                self.cLayer.Visible = true
                self.sLayer.Visible = true
                self.searchFrame.Visible = true
                self.cLayer.Position = UDim2.new(0, 0, -0.015, 0)
                Tw(self.cLayer, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quart)
                for i, cat in ipairs(self.cats) do
                    cat.frame.BackgroundTransparency = 1
                    task.delay(i * 0.04, function()
                        Tw(cat.frame, 0.3, { BackgroundTransparency = 0.06 }, Enum.EasingStyle.Quart)
                    end)
                end
                self.searchFrame.BackgroundTransparency = 1
                Tw(self.searchFrame, 0.3, { BackgroundTransparency = 0 })
                task.delay(0.4, function() self._animating = false end)
            else
                self:CPop()
                Tw(self.cLayer, 0.25, { Position = UDim2.new(0, 0, 0.015, 0) }, Enum.EasingStyle.Quart)
                Tw(self.searchFrame, 0.2, { BackgroundTransparency = 1 })
                for _, cat in ipairs(self.cats) do
                    Tw(cat.frame, 0.2, { BackgroundTransparency = 1 })
                end
                task.delay(0.3, function()
                    if not self.vis then
                        self.cLayer.Visible = false
                        self.searchFrame.Visible = false
                        self.sLayer.Visible = false
                    end
                    self._animating = false
                end)
            end
        end
    end))

    -- keybinds - ONLY works after loading
    table.insert(self.conn, UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe or self.dead or not self._loaded then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if inp.KeyCode == self.tKey then return end

        for _, kl in ipairs(self.kbListen) do
            if kl.on then
                if inp.KeyCode == Enum.KeyCode.Escape then kl.set(Enum.KeyCode.Unknown)
                else kl.set(inp.KeyCode) end
                kl.on = false
                return
            end
        end

        for _, m in ipairs(self.mods) do
            if m.bk and m.bk ~= Enum.KeyCode.Unknown and m.bk == inp.KeyCode then
                if m.bm == "toggle" then m:SetOn(not m.on)
                elseif m.bm == "hold" then m:SetOn(true) end
            end
        end
    end))

    table.insert(self.conn, UserInputService.InputEnded:Connect(function(inp)
        if self.dead or not self._loaded then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, m in ipairs(self.mods) do
            if m.bk and m.bk == inp.KeyCode and m.bm == "hold" then m:SetOn(false) end
        end
    end))

    -- heartbeat - delayed start, skip zero heights
    local hbFrame = 0
    RunService.Heartbeat:Connect(function()
        if self.dead then return end
        hbFrame = hbFrame + 1
        if hbFrame < 90 then return end

        for _, cat in ipairs(self.cats) do
            if not cat.collapsed then
                local h = cat.mlLayout.AbsoluteContentSize.Y
                if h > 0 and math.abs(h - cat.lastH) > 0.5 then
                    cat.lastH = h
                    cat.ml.Size = UDim2.new(1, -24, 0, h)
                    cat.frame.Size = UDim2.new(0, 200, 0, 44 + h)
                end
            end
        end
    end)

    FM(CFG_DIR)
    task.delay(4, function()
        if not self.dead then self:Load(AUTO_CFG) end
    end)

    return self
end

function Library:MkSearch()
    self.searchFrame = Make("Frame", {
        Parent = self.sLayer, BackgroundColor3 = Theme.SrBg, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 12), AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 280, 0, 30), ZIndex = 50,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.searchFrame })
    Make("UIStroke", { Color = Theme.SrBor, Thickness = 1, Transparency = 0.3, Parent = self.searchFrame })

    Make("ImageLabel", {
        Parent = self.searchFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -9), Size = UDim2.new(0, 18, 0, 18),
        Image = "rbxassetid://132302594577680", ImageColor3 = Theme.BindTxt,
        ZIndex = 51, ScaleType = Enum.ScaleType.Fit,
    })

    self.searchBox = Make("TextBox", {
        Parent = self.searchFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -40, 1, 0),
        Font = F.R, Text = "", PlaceholderText = "search...",
        PlaceholderColor3 = Theme.BindTxt, TextColor3 = Theme.SrTxt,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false, ZIndex = 51,
    })

    self.searchDrop = Make("Frame", {
        Parent = self.sLayer, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
        Position = UDim2.new(0.5, -140, 0, 46), Size = UDim2.new(0, 280, 0, 0),
        ClipsDescendants = true, Visible = false, ZIndex = 55,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 5), Parent = self.searchDrop })
    Make("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = self.searchDrop })
    self.sdLayout = Make("UIListLayout", { Parent = self.searchDrop, SortOrder = Enum.SortOrder.LayoutOrder })
    Make("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), Parent = self.searchDrop })

    self.searchBox:GetPropertyChangedSignal("Text"):Connect(function() self:DoSearch() end)
    self.searchBox.Focused:Connect(function() self:DoSearch() end)
    self.searchBox.FocusLost:Connect(function()
        task.delay(0.2, function()
            self.searchDrop.Visible = false
            self.searchDrop.Size = UDim2.new(0, 280, 0, 0)
        end)
    end)
end

function Library:DoSearch()
    local q = string.lower(self.searchBox.Text)
    for _, c in ipairs(self.searchDrop:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    if q == "" then self.searchDrop.Visible = false; self.searchDrop.Size = UDim2.new(0, 280, 0, 0); return end

    local hits = {}
    for _, m in ipairs(self.mods) do
        local ok = string.find(string.lower(m.name), q, 1, true) or string.find(string.lower(m.catN), q, 1, true)
        if not ok then
            for _, o in ipairs(m.ol) do
                if o.lb and string.find(string.lower(o.lb), q, 1, true) then ok = true; break end
            end
        end
        if ok then hits[#hits + 1] = m; if #hits >= 8 then break end end
    end

    if #hits == 0 then self.searchDrop.Visible = false; self.searchDrop.Size = UDim2.new(0, 280, 0, 0); return end

    for i, m in ipairs(hits) do
        local rb = Make("TextButton", {
            Parent = self.searchDrop, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26), Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 56,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 4), Parent = rb })
        Make("TextLabel", {
            Parent = rb, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0.6, -10, 1, 0), Font = F.S, Text = string.lower(m.name),
            TextColor3 = Theme.OptVal, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 57,
        })
        Make("TextLabel", {
            Parent = rb, BackgroundTransparency = 1, Position = UDim2.new(0.6, 0, 0, 0),
            Size = UDim2.new(0.4, -8, 1, 0), Font = F.R, Text = string.lower(m.catN),
            TextColor3 = Theme.BindTxt, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 57,
        })
        rb.MouseEnter:Connect(function() Tw(rb, 0.08, { BackgroundColor3 = Theme.DrHov }) end)
        rb.MouseLeave:Connect(function() Tw(rb, 0.08, { BackgroundColor3 = Theme.DrBg }) end)
        rb.MouseButton1Click:Connect(function()
            self.searchDrop.Visible = false; self.searchBox.Text = ""
            self:Pulse(m)
        end)
    end

    self.searchDrop.Visible = true
    Tw(self.searchDrop, 0.2, { Size = UDim2.new(0, 280, 0, #hits * 26 + 6) }, Enum.EasingStyle.Quart)
end

function Library:Pulse(mod)
    if mod.catRef and mod.catRef.collapsed then mod.catRef:Expand(); task.wait(0.4) end
    task.spawn(function()
        local corner = Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = mod.box })
        for i = 1, 3 do
            mod.box.BackgroundColor3 = Theme.Accent
            Tw(mod.box, 0.12, { BackgroundTransparency = 0.25 })
            task.wait(0.2)
            Tw(mod.box, 0.2, { BackgroundTransparency = 1 })
            task.wait(0.25)
        end
        task.wait(0.1)
        if corner and corner.Parent then corner:Destroy() end
    end)
end

function Library:MkKBW()
    self.kbw = Make("Frame", {
        Parent = self.gui, BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BackgroundTransparency = 0, BorderSizePixel = 0,
        Position = UDim2.new(1, -175, 0.5, -80),
        Size = UDim2.new(0, 155, 0, 26), AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false, ZIndex = 90,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.kbw })
    Make("UIStroke", { Color = Theme.CatBorder, Thickness = 1, Transparency = 0.2, Parent = self.kbw })
    Make("UIPadding", {
        PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
        Parent = self.kbw,
    })
    Make("UIListLayout", { Parent = self.kbw, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })

    Make("TextLabel", {
        Parent = self.kbw, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
        Font = F.B, Text = "KEYBINDS", TextColor3 = Theme.KbwHeader,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0,
    })

    local sepFrame = Make("Frame", {
        Parent = self.kbw, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 1), LayoutOrder = 1,
    })
    Make("Frame", {
        Parent = sepFrame, BackgroundColor3 = Theme.Sep, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1),
    })

    self.kbwList = Make("Frame", {
        Parent = self.kbw, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2,
    })
    Make("UIListLayout", { Parent = self.kbwList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) })

    local dg, ds, sp = false, nil, nil
    self.kbw.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dg = true; ds = inp.Position; sp = self.kbw.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dg = false end
            end)
        end
    end)
    table.insert(self.conn, UserInputService.InputChanged:Connect(function(inp)
        if dg and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - ds
            self.kbw.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end))

    local tk = 0
    RunService.Heartbeat:Connect(function()
        if self.dead or not self.kbw.Visible then return end
        tk = tk + 1
        if tk % 15 ~= 0 then return end
        for _, c in ipairs(self.kbwList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local idx = 0
        for _, m in ipairs(self.mods) do
            if m.on and m.bk and m.bk ~= Enum.KeyCode.Unknown then
                idx = idx + 1
                local r = Make("Frame", {
                    Parent = self.kbwList, BackgroundColor3 = Color3.fromRGB(35, 35, 45),
                    BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = idx,
                })
                Make("UICorner", { CornerRadius = UDim.new(0, 4), Parent = r })
                Make("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = r })
                Make("TextLabel", {
                    Parent = r, BackgroundTransparency = 1, Size = UDim2.new(0.65, 0, 1, 0),
                    Font = F.S, Text = m.name, TextColor3 = Theme.KbwName,
                    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
                })
                Make("TextLabel", {
                    Parent = r, BackgroundTransparency = 1, Position = UDim2.new(0.65, 0, 0, 0),
                    Size = UDim2.new(0.35, 0, 1, 0), Font = F.S,
                    Text = "[" .. m.bk.Name .. "]", TextColor3 = Theme.KbwBind,
                    TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right,
                })
            end
        end
    end)
end

function Library:CPop()
    if self.popup then
        local p = self.popup; self.popup = nil; self.away.Visible = false
        if p.cl then p.cl() end
    end
end
function Library:OPop(d) self:CPop(); self.popup = d; self.away.Visible = true end

function Library:UAcc(c)
    Theme.Accent = c; Theme.ModOn = c; Theme.TgOn = c; Theme.LoadBar = c
    for _, e in ipairs(self.accTrk) do
        if e.i and e.i.Parent then pcall(function() e.i[e.p] = c end) end
    end
    for _, m in ipairs(self.mods) do
        if m.on and m.nl then m.nl.TextColor3 = c end
        if m.ab then m.ab.BackgroundColor3 = c end
    end
    for _, l in ipairs(self.catHdrs) do
        if l and l.Parent then l.TextColor3 = c end
    end
end
function Library:Trk(i, p) self.accTrk[#self.accTrk + 1] = { i = i, p = p } end

function Library:Save(n)
    local d = { opts = {}, mods = {} }
    for id, o in pairs(self.opts) do
        local e = { id = id, t = o.Type }
        if o.Type == "Toggle" then e.v = o.Value
        elseif o.Type == "Slider" then e.v = o.Value
        elseif o.Type == "Dropdown" then e.v = o.Value
        elseif o.Type == "ColorPicker" then e.v = { o.Value.R, o.Value.G, o.Value.B }
        elseif o.Type == "Keybind" then
            e.v = o.Value ~= Enum.KeyCode.Unknown and o.Value.Name or "Unknown"
            e.m = o.Mode
        end
        d.opts[#d.opts + 1] = e
    end
    for _, m in ipairs(self.mods) do
        d.mods[#d.mods + 1] = {
            id = m.fid, on = m.on,
            bk = m.bk and m.bk ~= Enum.KeyCode.Unknown and m.bk.Name or nil,
            bm = m.bm,
        }
    end
    FM(CFG_DIR); FW(CFG_DIR .. "/" .. n .. ".json", HttpService:JSONEncode(d))
end

function Library:Load(n)
    local raw = FR(CFG_DIR .. "/" .. n .. ".json")
    if not raw then return end
    local ok, d = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or not d then return end
    if d.opts then
        for _, e in ipairs(d.opts) do
            local o = self.opts[e.id]
            if o and o.Set then pcall(function()
                if o.Type == "Toggle" then o:Set(e.v)
                elseif o.Type == "Slider" then o:Set(e.v)
                elseif o.Type == "Dropdown" then o:Set(e.v)
                elseif o.Type == "ColorPicker" and e.v then o:Set(Color3.new(e.v[1], e.v[2], e.v[3]))
                elseif o.Type == "Keybind" then o:Set(Enum.KeyCode[e.v] or Enum.KeyCode.Unknown, e.m)
                end
            end) end
        end
    end
    if d.mods then
        for _, ms in ipairs(d.mods) do
            for _, m in ipairs(self.mods) do
                if m.fid == ms.id then
    
                    -- HARD BLOCK: never restore modules that call Unload
                    local isUnload = string.find(string.lower(m.name), "unload")

                    if not isUnload then
                        m:SetOn(ms.on or false)
                    else
                        m:SetOn(false)
                    end

                    -- restore keybind + mode
                    if ms.bk then
                        m.bk = Enum.KeyCode[ms.bk] or Enum.KeyCode.Unknown
                    end
                    m.bm = ms.bm or "toggle"
                    m:UB()
                end
            end
        end
    end

function Library:Del(n) FD(CFG_DIR .. "/" .. n .. ".json") end
function Library:Cfgs()
    local f = FL(CFG_DIR); local o = {}
    for _, x in ipairs(f) do local n = x:match("([^/\\]+)%.json$"); if n and n ~= AUTO_CFG then o[#o + 1] = n end end
    return o
end

function Library:Unload()
    self.dead = true
    self:Save(AUTO_CFG)
    for _, m in ipairs(self.mods) do m:SetOn(false) end

    -- animate out
    for i = #self.cats, 1, -1 do
        local cat = self.cats[i]
        task.delay((#self.cats - i) * 0.06, function()
            Tw(cat.frame, 0.3, {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 200, 0, 0),
            }, Enum.EasingStyle.Quart)
        end)
    end

    Tw(self.searchFrame, 0.3, { BackgroundTransparency = 1 })

    if self.kbw.Visible then
        Tw(self.kbw, 0.3, { BackgroundTransparency = 1, Size = UDim2.new(0, 155, 0, 0) })
    end

    task.delay(#self.cats * 0.06 + 0.4, function()
        local flash = Make("Frame", {
            Parent = self.gui,
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.85,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 999,
        })
        Make("UICorner", { CornerRadius = UDim.new(0, 0), Parent = flash })
        Tw(flash, 0.4, { BackgroundTransparency = 1 })
        task.delay(0.5, function()
            for _, c in ipairs(self.conn) do pcall(function() c:Disconnect() end) end
            self.gui:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════
-- CATEGORY
-- ═══════════════════════════════════
function Library:Cat(catName)
    local cat = {
        name = catName, mods = {}, lib = self,
        collapsed = false, lastH = 0,
    }
    local idx = #self.cats + 1

    cat.frame = Make("Frame", {
        Parent = self.scroll, BackgroundColor3 = Theme.CatBg, BackgroundTransparency = 0.06,
        BorderSizePixel = 0, Size = UDim2.new(0, 200, 0, 36), LayoutOrder = idx, ZIndex = 1,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = cat.frame })
    Make("UIStroke", { Color = Theme.CatBorder, Thickness = 1, Transparency = 0.4, Parent = cat.frame })

    local hBtn = Make("TextButton", {
        Parent = cat.frame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36), Text = "", AutoButtonColor = false, ZIndex = 2,
    })

    local hLbl = Make("TextLabel", {
        Parent = hBtn, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -36, 1, 0),
        Font = F.B, Text = string.upper(catName), TextColor3 = Theme.Accent,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
    })
    self:Trk(hLbl, "TextColor3")
    self.catHdrs[#self.catHdrs + 1] = hLbl

    local arrow = Make("TextLabel", {
        Parent = hBtn, BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 0), Size = UDim2.new(0, 14, 1, 0),
        Font = F.R, Text = "▼", TextColor3 = Theme.BindTxt, TextSize = 9, ZIndex = 3,
    })

    local sep = Make("Frame", {
        Parent = cat.frame, BackgroundColor3 = Theme.Sep, BackgroundTransparency = 0.5,
        BorderSizePixel = 0, Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(1, -24, 0, 1), ZIndex = 2,
    })

    cat.ml = Make("Frame", {
        Parent = cat.frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 40),
        Size = UDim2.new(1, -24, 0, 0), ClipsDescendants = true, ZIndex = 2,
    })

    cat.mlLayout = Make("UIListLayout", {
        Parent = cat.ml, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0),
    })

    function cat:Expand()
        self.collapsed = false
        self.lastH = -1
        arrow.Text = "▼"
        sep.Visible = true
    end

    function cat:Collapse()
        self.collapsed = true
        arrow.Text = "▶"
        self.lastH = 0
        Tw(self.ml, 0.3, { Size = UDim2.new(1, -24, 0, 0) }, Enum.EasingStyle.Quart)
        Tw(self.frame, 0.3, { Size = UDim2.new(0, 200, 0, 36) }, Enum.EasingStyle.Quart)
        task.delay(0.3, function()
            if self.collapsed then sep.Visible = false end
        end)
    end

    hBtn.MouseButton1Click:Connect(function()
        if cat.collapsed then cat:Expand() else cat:Collapse() end
    end)
    hBtn.MouseEnter:Connect(function() Tw(hLbl, 0.1, { TextColor3 = Color3.fromRGB(255, 180, 210) }) end)
    hBtn.MouseLeave:Connect(function() Tw(hLbl, 0.1, { TextColor3 = Theme.Accent }) end)

    function cat:Mod(n) return Library._Mod(self, n) end

    self.cats[#self.cats + 1] = cat
    return cat
end

-- ═══════════════════════════════════
-- MODULE
-- ═══════════════════════════════════
function Library._Mod(cat, name)
    local lib = cat.lib
    local mod = {
        name = name, on = false, exp = false,
        ol = {}, oc = 0, bk = nil, bm = "toggle",
        fid = cat.name .. "." .. name, catN = cat.name, catRef = cat, cb = nil,
    }
    local mi = #cat.mods + 1

    mod.box = Make("Frame", {
        Parent = cat.ml, BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = mi,
        ClipsDescendants = true, ZIndex = 2,
    })

    local hb = Make("TextButton", {
        Parent = mod.box, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26),
        Text = "", AutoButtonColor = false, ZIndex = 3,
    })

    mod.nl = Make("TextLabel", {
        Parent = hb, BackgroundTransparency = 1, Size = UDim2.new(1, -72, 1, 0),
        Font = F.S, Text = string.lower(name), TextColor3 = Theme.ModOff,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
    })

    mod.bl = Make("TextLabel", {
        Parent = hb, BackgroundTransparency = 1, Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.new(0, 68, 1, 0), Font = F.R, Text = "", TextColor3 = Theme.BindTxt,
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4,
    })

    mod.of = Make("Frame", {
        Parent = mod.box, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 26),
        Size = UDim2.new(1, -8, 0, 0), ClipsDescendants = true, ZIndex = 3,
    })

    mod.ab = Make("Frame", {
        Parent = mod.of, BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.55,
        BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, 2, 1, -4), ZIndex = 4,
    })
    lib:Trk(mod.ab, "BackgroundColor3")

    mod.oi = Make("Frame", {
        Parent = mod.of, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -16, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 4,
    })
    mod.oiL = Make("UIListLayout", { Parent = mod.oi, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) })
    Make("UIPadding", { Parent = mod.oi, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8) })

    function mod:UB()
        if self.bk and self.bk ~= Enum.KeyCode.Unknown then self.bl.Text = "[" .. self.bk.Name .. "]"
        else self.bl.Text = "" end
    end

    function mod:SetOn(st)
        self.on = st
        Tw(self.nl, 0.15, { TextColor3 = st and Theme.Accent or Theme.ModOff })
        if self.cb then pcall(self.cb, st) end
    end

    local function recalc()
        task.defer(function()
            task.wait(0.03)
            if mod.exp then
                local h = mod.oiL.AbsoluteContentSize.Y + 12
                Tw(mod.of, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
                Tw(mod.box, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
            end
        end)
    end

    hb.MouseButton1Click:Connect(function() mod:SetOn(not mod.on) end)
    hb.MouseButton2Click:Connect(function()
        if mod.oc == 0 then return end
        mod.exp = not mod.exp
        if mod.exp then
            local h = mod.oiL.AbsoluteContentSize.Y + 12
            Tw(mod.of, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
            Tw(mod.box, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
        else
            lib:CPop()
            Tw(mod.of, 0.25, { Size = UDim2.new(1, -8, 0, 0) }, Enum.EasingStyle.Quart)
            Tw(mod.box, 0.25, { Size = UDim2.new(1, 0, 0, 26) }, Enum.EasingStyle.Quart)
        end
    end)

    hb.MouseEnter:Connect(function() if not mod.on then Tw(mod.nl, 0.08, { TextColor3 = Color3.fromRGB(225, 225, 235) }) end end)
    hb.MouseLeave:Connect(function() if not mod.on then Tw(mod.nl, 0.08, { TextColor3 = Theme.ModOff }) end end)

    function mod:OnToggle(cb) self.cb = cb; return self end

    function mod:Toggle(tn,def,cb) local id=self.fid.."."..tn;local o={Type="Toggle",Value=def or false,Callback=cb,lb=tn};self.oc=self.oc+1;local row=Make("Frame",{Parent=self.oi,BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),LayoutOrder=self.oc,ZIndex=5});Make("TextLabel",{Parent=row,BackgroundTransparency=1,Size=UDim2.new(1,-44,1,0),Font=F.R,Text=tn,TextColor3=Theme.OptText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6});local bg=Make("Frame",{Parent=row,BackgroundColor3=o.Value and Theme.TgOn or Theme.TgOff,BorderSizePixel=0,Position=UDim2.new(1,-36,0.5,-7),Size=UDim2.new(0,30,0,14),ZIndex=6});Make("UICorner",{CornerRadius=UDim.new(1,0),Parent=bg});if o.Value then lib:Trk(bg,"BackgroundColor3") end;local kn=Make("Frame",{Parent=bg,BackgroundColor3=Theme.Knob,BorderSizePixel=0,Position=o.Value and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5),Size=UDim2.new(0,10,0,10),ZIndex=7});Make("UICorner",{CornerRadius=UDim.new(1,0),Parent=kn});local btn=Make("TextButton",{Parent=row,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=8});function o:Set(v) o.Value=v;Tw(bg,0.2,{BackgroundColor3=v and Theme.TgOn or Theme.TgOff});Tw(kn,0.2,{Position=v and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5)});if o.Callback then pcall(o.Callback,v) end end;btn.MouseButton1Click:Connect(function() o:Set(not o.Value) end);lib.opts[id]=o;self.ol[#self.ol+1]=o;task.defer(recalc);return o end

    function mod:Slider(sn,def,mn,mx,cb,sfx,dec) sfx=sfx or"";dec=dec or 1;def=def or mn;local id=self.fid.."."..sn;local o={Type="Slider",Value=def,Callback=cb,lb=sn};self.oc=self.oc+1;local row=Make("Frame",{Parent=self.oi,BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),LayoutOrder=self.oc,ZIndex=5});Make("TextLabel",{Parent=row,BackgroundTransparency=1,Size=UDim2.new(0.6,0,0,15),Font=F.R,Text=sn,TextColor3=Theme.OptText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6});local vl=Make("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0.6,0,0,0),Size=UDim2.new(0.4,0,0,15),Font=F.S,Text=tostring(def)..sfx,TextColor3=Theme.OptVal,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=6});local tr=Make("Frame",{Parent=row,BackgroundColor3=Theme.SlBg,BorderSizePixel=0,Position=UDim2.new(0,0,0,19),Size=UDim2.new(1,0,0,5),ZIndex=6});Make("UICorner",{CornerRadius=UDim.new(1,0),Parent=tr});local p=math.clamp((def-mn)/(mx-mn),0,1);local fl=Make("Frame",{Parent=tr,BackgroundColor3=Theme.Accent,BorderSizePixel=0,Size=UDim2.new(p,0,1,0),ZIndex=7});Make("UICorner",{CornerRadius=UDim.new(1,0),Parent=fl});lib:Trk(fl,"BackgroundColor3");local kb=Make("Frame",{Parent=tr,BackgroundColor3=Theme.Knob,BorderSizePixel=0,Position=UDim2.new(p,-5,0.5,-5),Size=UDim2.new(0,10,0,10),ZIndex=8});Make("UICorner",{CornerRadius=UDim.new(1,0),Parent=kb});local sb=Make("TextButton",{Parent=tr,BackgroundTransparency=1,Size=UDim2.new(1,0,1,14),Position=UDim2.new(0,0,0,-7),Text="",ZIndex=9});local sd={on=false};sd.fn=function(inp) local pp=math.clamp((inp.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1);local val=math.floor((mn+(mx-mn)*pp)*(10^dec)+0.5)/(10^dec);o.Value=val;vl.Text=tostring(val)..sfx;fl.Size=UDim2.new(pp,0,1,0);kb.Position=UDim2.new(pp,-5,0.5,-5);if cb then cb(val) end end;Drags.sl[#Drags.sl+1]=sd;function o:Set(v) v=math.clamp(v,mn,mx);local pp=(v-mn)/(mx-mn);o.Value=v;vl.Text=tostring(v)..sfx;fl.Size=UDim2.new(pp,0,1,0);kb.Position=UDim2.new(pp,-5,0.5,-5);if cb then cb(v) end end;sb.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then sd.on=true;sd.fn(inp) end end);lib.opts[id]=o;self.ol[#self.ol+1]=o;task.defer(recalc);return o end

    function mod:Dropdown(dn,items,def,cb) local id=self.fid.."."..dn;local o={Type="Dropdown",Value=def or items[1],Callback=cb,lb=dn};self.oc=self.oc+1;local row=Make("Frame",{Parent=self.oi,BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),LayoutOrder=self.oc,ZIndex=5});Make("TextLabel",{Parent=row,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),Font=F.R,Text=dn,TextColor3=Theme.OptText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6});local vb=Make("TextButton",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0.5,0,0,0),Size=UDim2.new(0.5,0,1,0),Font=F.S,Text=tostring(o.Value),TextColor3=Theme.OptVal,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,AutoButtonColor=false,ZIndex=6});local pf=Make("Frame",{Parent=lib.pLayer,BackgroundColor3=Theme.DrBg,BorderSizePixel=0,Size=UDim2.new(0,120,0,0),ClipsDescendants=true,Visible=false,ZIndex=110});Make("UICorner",{CornerRadius=UDim.new(0,4),Parent=pf});Make("UIStroke",{Color=Theme.DrBor,Thickness=1,Parent=pf});Make("UIListLayout",{Parent=pf,SortOrder=Enum.SortOrder.LayoutOrder});Make("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,2),Parent=pf});local ibs={};for i,item in ipairs(items) do local ib=Make("TextButton",{Parent=pf,BackgroundColor3=Theme.DrBg,BorderSizePixel=0,Size=UDim2.new(1,0,0,22),Font=F.R,Text=item,TextColor3=(item==o.Value) and Theme.Accent or Theme.OptText,TextSize=11,AutoButtonColor=false,LayoutOrder=i,ZIndex=111});ibs[#ibs+1]=ib;ib.MouseEnter:Connect(function() Tw(ib,0.08,{BackgroundColor3=Theme.DrHov}) end);ib.MouseLeave:Connect(function() Tw(ib,0.08,{BackgroundColor3=Theme.DrBg}) end);ib.MouseButton1Click:Connect(function() o.Value=item;vb.Text=item;for _,b in ipairs(ibs) do b.TextColor3=(b.Text==item) and Theme.Accent or Theme.OptText end;lib:CPop();if cb then cb(item) end end) end;function o:Set(v) o.Value=v;vb.Text=v;for _,b in ipairs(ibs) do b.TextColor3=(b.Text==v) and Theme.Accent or Theme.OptText end;if cb then cb(v) end end;vb.MouseButton1Click:Connect(function() if lib.popup and lib.popup.fr==pf then lib:CPop();return end;local ap,as=vb.AbsolutePosition,vb.AbsoluteSize;local w=math.max(as.X,100);pf.Position=UDim2.new(0,ap.X+as.X-w,0,ap.Y+as.Y+2);pf.Size=UDim2.new(0,w,0,0);pf.Visible=true;Tw(pf,0.2,{Size=UDim2.new(0,w,0,#items*22+4)},Enum.EasingStyle.Quart);lib:OPop({fr=pf,cl=function() Tw(pf,0.15,{Size=UDim2.new(0,w,0,0)},Enum.EasingStyle.Quart);task.delay(0.15,function() pf.Visible=false end) end}) end);lib.opts[id]=o;self.ol[#self.ol+1]=o;task.defer(recalc);return o end

    function mod:ColorPicker(cn,def,cb) def=def or Color3.new(1,0,0);local h,s,v=HSV(def);local id=self.fid.."."..cn;local o={Type="ColorPicker",Value=def,Callback=cb,lb=cn};self.oc=self.oc+1;local row=Make("Frame",{Parent=self.oi,BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),LayoutOrder=self.oc,ZIndex=5});Make("TextLabel",{Parent=row,BackgroundTransparency=1,Size=UDim2.new(1,-28,0,22),Font=F.R,Text=cn,TextColor3=Theme.OptText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6});local pv=Make("TextButton",{Parent=row,BackgroundColor3=def,BorderSizePixel=0,Position=UDim2.new(1,-20,0.5,-6),Size=UDim2.new(0,16,0,12),Text="",AutoButtonColor=false,ZIndex=6});Make("UICorner",{CornerRadius=UDim.new(0,3),Parent=pv});Make("UIStroke",{Color=Theme.DrBor,Thickness=1,Parent=pv});local pnl=Make("Frame",{Parent=lib.pLayer,BackgroundColor3=Theme.PkBg,BorderSizePixel=0,Size=UDim2.new(0,180,0,100),Visible=false,ZIndex=110});Make("UICorner",{CornerRadius=UDim.new(0,5),Parent=pnl});Make("UIStroke",{Color=Theme.DrBor,Thickness=1,Parent=pnl});local svB=Make("Frame",{Parent=pnl,BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.new(0,8,0,8),Size=UDim2.new(1,-32,1,-16),ZIndex=111,ClipsDescendants=true});Make("UICorner",{CornerRadius=UDim.new(0,3),Parent=svB});local hO=Make("Frame",{Parent=svB,BackgroundColor3=Color3.fromHSV(h,1,1),Size=UDim2.new(1,0,1,0),ZIndex=112});Make("UIGradient",{Parent=hO,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})});local bO=Make("Frame",{Parent=svB,BackgroundColor3=Color3.new(0,0,0),Size=UDim2.new(1,0,1,0),ZIndex=113});Make("UIGradient",{Parent=bO,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}),Rotation=90});local svC=Make("Frame",{Parent=svB,BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.new(s,-5,1-v,-5),Size=UDim2.new(0,10,0,10),ZIndex=116});Make("UICorner",{CornerRadius=UDim.new(1,0),Parent=svC});Make("UIStroke",{Color=Color3.new(0,0,0),Thickness=1.5,Parent=svC});local svBt=Make("TextButton",{Parent=svB,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=117});local hBr=Make("Frame",{Parent=pnl,BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.new(1,-20,0,8),Size=UDim2.new(0,10,1,-16),ZIndex=111});Make("UICorner",{CornerRadius=UDim.new(0,3),Parent=hBr});Make("UIGradient",{Parent=hBr,Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.167,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.333,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.667,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(0.833,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})});local hCC=Make("Frame",{Parent=hBr,BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.new(0,-2,h,-2),Size=UDim2.new(1,4,0,4),ZIndex=116});Make("UICorner",{CornerRadius=UDim.new(0,2),Parent=hCC});Make("UIStroke",{Color=Color3.new(0,0,0),Thickness=1,Parent=hCC});local hBt=Make("TextButton",{Parent=hBr,BackgroundTransparency=1,Size=UDim2.new(1,8,1,0),Position=UDim2.new(0,-4,0,0),Text="",ZIndex=117});local function upd() o.Value=Color3.fromHSV(math.clamp(h,0,0.999),s,v);pv.BackgroundColor3=o.Value;hO.BackgroundColor3=Color3.fromHSV(math.clamp(h,0,0.999),1,1);svC.Position=UDim2.new(s,-5,1-v,-5);hCC.Position=UDim2.new(0,-2,h,-2);if cb then cb(o.Value) end end;function o:Set(c) h,s,v=HSV(c);upd() end;local svD={on=false};svD.fn=function(inp) s=math.clamp((inp.Position.X-svB.AbsolutePosition.X)/svB.AbsoluteSize.X,0,1);v=1-math.clamp((inp.Position.Y-svB.AbsolutePosition.Y)/svB.AbsoluteSize.Y,0,1);upd() end;Drags.sv[#Drags.sv+1]=svD;local hD={on=false};hD.fn=function(inp) h=math.clamp((inp.Position.Y-hBr.AbsolutePosition.Y)/hBr.AbsoluteSize.Y,0,0.999);upd() end;Drags.hu[#Drags.hu+1]=hD;svBt.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then svD.on=true;svD.fn(inp) end end);hBt.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then hD.on=true;hD.fn(inp) end end);pv.MouseButton1Click:Connect(function() if lib.popup and lib.popup.fr==pnl then lib:CPop();return end;local ap=pv.AbsolutePosition;pnl.Position=UDim2.new(0,ap.X-160,0,ap.Y+16);pnl.Visible=true;lib:OPop({fr=pnl,cl=function() pnl.Visible=false;svD.on=false;hD.on=false end}) end);lib.opts[id]=o;self.ol[#self.ol+1]=o;task.defer(recalc);return o end

    function mod:Keybind(kn,def,cb) def=def or Enum.KeyCode.Unknown;local id=self.fid.."."..kn;local o={Type="Keybind",Value=def,Mode="toggle",Callback=cb,lb=kn};self.oc=self.oc+1;mod.bk=def;mod.bm="toggle";mod:UB();local row=Make("Frame",{Parent=self.oi,BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),LayoutOrder=self.oc,ZIndex=5});Make("TextLabel",{Parent=row,BackgroundTransparency=1,Size=UDim2.new(0.4,0,1,0),Font=F.R,Text=kn,TextColor3=Theme.OptText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6});local bb=Make("TextButton",{Parent=row,BackgroundColor3=Theme.DrBg,BorderSizePixel=0,Position=UDim2.new(1,-55,0.5,-9),Size=UDim2.new(0,52,0,18),Font=F.R,Text=def~=Enum.KeyCode.Unknown and def.Name or"none",TextColor3=Theme.OptVal,TextSize=10,AutoButtonColor=false,ZIndex=6});Make("UICorner",{CornerRadius=UDim.new(0,3),Parent=bb});Make("UIStroke",{Color=Theme.DrBor,Thickness=1,Parent=bb});local mf=Make("Frame",{Parent=lib.pLayer,BackgroundColor3=Theme.DrBg,BorderSizePixel=0,Size=UDim2.new(0,80,0,0),ClipsDescendants=true,Visible=false,ZIndex=110});Make("UICorner",{CornerRadius=UDim.new(0,4),Parent=mf});Make("UIStroke",{Color=Theme.DrBor,Thickness=1,Parent=mf});Make("UIListLayout",{Parent=mf,SortOrder=Enum.SortOrder.LayoutOrder});Make("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,2),Parent=mf});local modes={"toggle","hold","always"};local mbs={};for i,m in ipairs(modes) do local mb=Make("TextButton",{Parent=mf,BackgroundColor3=Theme.DrBg,BorderSizePixel=0,Size=UDim2.new(1,0,0,20),Font=F.R,Text=m,TextColor3=(m==o.Mode) and Theme.Accent or Theme.OptText,TextSize=11,AutoButtonColor=false,LayoutOrder=i,ZIndex=111});mbs[#mbs+1]=mb;mb.MouseEnter:Connect(function() Tw(mb,0.08,{BackgroundColor3=Theme.DrHov}) end);mb.MouseLeave:Connect(function() Tw(mb,0.08,{BackgroundColor3=Theme.DrBg}) end);mb.MouseButton1Click:Connect(function() o.Mode=m;mod.bm=m;for _,b in ipairs(mbs) do b.TextColor3=(b.Text==m) and Theme.Accent or Theme.OptText end;lib:CPop();if m=="always" then mod:SetOn(true) end end) end;local ls={on=false};ls.set=function(key) o.Value=key;mod.bk=key;bb.Text=key~=Enum.KeyCode.Unknown and key.Name or"none";mod:UB();Tw(bb,0.1,{TextColor3=Theme.OptVal}) end;lib.kbListen[#lib.kbListen+1]=ls;bb.MouseButton1Click:Connect(function() ls.on=true;bb.Text="...";Tw(bb,0.1,{TextColor3=Theme.Accent}) end);bb.MouseButton2Click:Connect(function() if lib.popup and lib.popup.fr==mf then lib:CPop();return end;local ap,as=bb.AbsolutePosition,bb.AbsoluteSize;mf.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+2);mf.Size=UDim2.new(0,80,0,0);mf.Visible=true;Tw(mf,0.2,{Size=UDim2.new(0,80,0,#modes*20+4)},Enum.EasingStyle.Quart);lib:OPop({fr=mf,cl=function() Tw(mf,0.15,{Size=UDim2.new(0,80,0,0)},Enum.EasingStyle.Quart);task.delay(0.15,function() mf.Visible=false end) end}) end);function o:Set(key,mode) o.Value=key;mod.bk=key;bb.Text=key~=Enum.KeyCode.Unknown and key.Name or"none";if mode then o.Mode=mode;mod.bm=mode;for _,b in ipairs(mbs) do b.TextColor3=(b.Text==mode) and Theme.Accent or Theme.OptText end end;mod:UB() end;lib.opts[id]=o;self.ol[#self.ol+1]=o;task.defer(recalc);return o end

    function mod:Button(text,cb) self.oc=self.oc+1;local btn=Make("TextButton",{Parent=self.oi,BackgroundColor3=Theme.DrBg,BorderSizePixel=0,Size=UDim2.new(1,0,0,22),Font=F.S,Text=text,TextColor3=Theme.OptVal,TextSize=11,AutoButtonColor=false,LayoutOrder=self.oc,ZIndex=5});Make("UICorner",{CornerRadius=UDim.new(0,3),Parent=btn});Make("UIStroke",{Color=Theme.DrBor,Thickness=1,Parent=btn});btn.MouseEnter:Connect(function() Tw(btn,0.08,{BackgroundColor3=Theme.DrHov}) end);btn.MouseLeave:Connect(function() Tw(btn,0.08,{BackgroundColor3=Theme.DrBg}) end);btn.MouseButton1Click:Connect(function() if cb then cb() end end);task.defer(recalc) end

    function mod:TextBox(tn,def,ph,cb) self.oc=self.oc+1;local o={Type="TextBox",Value=def or"",lb=tn};local row=Make("Frame",{Parent=self.oi,BackgroundTransparency=1,Size=UDim2.new(1,0,0,36),LayoutOrder=self.oc,ZIndex=5});Make("TextLabel",{Parent=row,BackgroundTransparency=1,Size=UDim2.new(1,0,0,14),Font=F.R,Text=tn,TextColor3=Theme.OptText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6});local tb=Make("TextBox",{Parent=row,BackgroundColor3=Theme.DrBg,BorderSizePixel=0,Position=UDim2.new(0,0,0,16),Size=UDim2.new(1,0,0,18),Font=F.R,Text=def or"",PlaceholderText=ph or"",PlaceholderColor3=Theme.BindTxt,TextColor3=Theme.OptVal,TextSize=11,ClearTextOnFocus=false,ZIndex=6});Make("UICorner",{CornerRadius=UDim.new(0,3),Parent=tb});Make("UIStroke",{Color=Theme.DrBor,Thickness=1,Parent=tb});Make("UIPadding",{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,5),Parent=tb});tb.FocusLost:Connect(function() o.Value=tb.Text;if cb then cb(tb.Text) end end);function o:Set(v) tb.Text=v;o.Value=v end;function o:Get() return tb.Text end;lib.opts[self.fid.."."..tn]=o;self.ol[#self.ol+1]=o;task.defer(recalc);return o end

    function mod:Label(text) self.oc=self.oc+1;Make("TextLabel",{Parent=self.oi,BackgroundTransparency=1,Size=UDim2.new(1,0,0,16),Font=F.R,Text=text,TextColor3=Theme.BindTxt,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=self.oc,ZIndex=5});task.defer(recalc) end

    function mod:Separator() self.oc=self.oc+1;local s=Make("Frame",{Parent=self.oi,BackgroundTransparency=1,Size=UDim2.new(1,0,0,6),LayoutOrder=self.oc,ZIndex=5});Make("Frame",{Parent=s,BackgroundColor3=Theme.Sep,BorderSizePixel=0,Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,1),ZIndex=6});task.defer(recalc) end

    cat.mods[#cat.mods + 1] = mod
    lib.mods[#lib.mods + 1] = mod
    return mod
end

return Library
