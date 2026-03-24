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
    Ft = Enum.Font.Gotham,
    FtS = Enum.Font.GothamSemibold,
    FtB = Enum.Font.GothamBold,
}

local CFG_DIR = "MCClientConfigs"
local AUTO_CFG = "_autoload"

local function C(c, p)
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

local function SW(p, c) pcall(function() if writefile then writefile(p, c) end end) end
local function SR(p) local o, r = pcall(function() if readfile and isfile and isfile(p) then return readfile(p) end end); return o and r or nil end
local function SD(p) pcall(function() if delfile and isfile and isfile(p) then delfile(p) end end) end
local function SM(p) pcall(function() if makefolder and (not isfolder or not isfolder(p)) then makefolder(p) end end) end
local function SL(p) local o, r = pcall(function() if listfiles and isfolder and isfolder(p) then return listfiles(p) end return {} end); return o and r or {} end

local IM = { sl = {}, sv = {}, hu = {}, init = false }
function IM.Init(lib)
    if IM.init then return end
    IM.init = true
    table.insert(lib._cn, UserInputService.InputChanged:Connect(function(inp)
        if lib._dead then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            for _, x in ipairs(IM.sl) do if x.on then x.fn(inp) end end
            for _, x in ipairs(IM.sv) do if x.on then x.fn(inp) end end
            for _, x in ipairs(IM.hu) do if x.on then x.fn(inp) end end
        end
    end))
    table.insert(lib._cn, UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, x in ipairs(IM.sl) do x.on = false end
            for _, x in ipairs(IM.sv) do x.on = false end
            for _, x in ipairs(IM.hu) do x.on = false end
        end
    end))
end

function Library.new(name)
    local self = setmetatable({}, Library)
    self.Name = name or "Client"
    self.Cats = {}
    self.Vis = true
    self.TKey = Enum.KeyCode.RightShift
    self._mods = {}
    self._opts = {}
    self._cn = {}
    self._accEls = {}
    self._pop = nil
    self._dead = false
    self._kbl = {}
    self._catHeaderLabels = {}

    local old = LP.PlayerGui:FindFirstChild("MCClientUI")
    if old then old:Destroy() end

    self.Gui = C("ScreenGui", {
        Name = "MCClientUI", Parent = LP:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, DisplayOrder = 999,
    })

    self:_mkSearch()

    -- center wrapper
    self._cw = C("Frame", {
        Parent = self.Gui, BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 52), AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, 0, 1, -60),
    })

    -- inner scroll for horizontal
    self.Main = C("ScrollingFrame", {
        Parent = self._cw, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ClipsDescendants = false,
    })

    self._mainLayout = C("UIListLayout", {
        Parent = self.Main,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })

    self.PopLayer = C("Frame", {
        Parent = self.Gui, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 100,
    })
    self._ca = C("TextButton", {
        Parent = self.PopLayer, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 99, Visible = false,
    })
    self._ca.MouseButton1Click:Connect(function() self:_cpop() end)

    self:_mkKB()
    IM.Init(self)

    table.insert(self._cn, UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe or self._dead then return end
        if inp.KeyCode == self.TKey then
            self.Vis = not self.Vis
            self._cw.Visible = self.Vis
            self._sf.Visible = self.Vis
            if not self.Vis then self:_cpop() end
        end
    end))

    table.insert(self._cn, UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe or self._dead then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, kl in ipairs(self._kbl) do
            if kl.on then
                if inp.KeyCode == Enum.KeyCode.Escape then kl.set(Enum.KeyCode.Unknown)
                else kl.set(inp.KeyCode) end
                kl.on = false
                return
            end
        end
        for _, m in ipairs(self._mods) do
            if m._bk and m._bk == inp.KeyCode and m._bk ~= Enum.KeyCode.Unknown then
                if m._bm == "toggle" then m:SetOn(not m.On)
                elseif m._bm == "hold" then m:SetOn(true) end
            end
        end
    end))

    table.insert(self._cn, UserInputService.InputEnded:Connect(function(inp)
        if self._dead then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, m in ipairs(self._mods) do
            if m._bk and m._bk == inp.KeyCode and m._bm == "hold" then
                m:SetOn(false)
            end
        end
    end))

    SM(CFG_DIR)
    task.delay(1, function()
        if not self._dead then self:Load(AUTO_CFG) end
    end)

    return self
end

function Library:_mkSearch()
    self._sf = C("Frame", {
        Parent = self.Gui, BackgroundColor3 = Theme.SrBg, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 12), AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 280, 0, 30),
    })
    C("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self._sf })
    C("UIStroke", { Color = Theme.SrBor, Thickness = 1, Transparency = 0.3, Parent = self._sf })

    C("ImageLabel", {
        Parent = self._sf, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -9), Size = UDim2.new(0, 18, 0, 18),
        Image = "rbxassetid://132302594577680", ImageColor3 = Theme.BindTxt,
        ZIndex = 5, ScaleType = Enum.ScaleType.Fit,
    })

    self._sb = C("TextBox", {
        Parent = self._sf, BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -40, 1, 0),
        Font = Theme.Ft, Text = "", PlaceholderText = "search...",
        PlaceholderColor3 = Theme.BindTxt, TextColor3 = Theme.SrTxt,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
    })

    self._sd = C("Frame", {
        Parent = self._sf, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 4), Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true, Visible = false, ZIndex = 200,
    })
    C("UICorner", { CornerRadius = UDim.new(0, 5), Parent = self._sd })
    C("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = self._sd })
    self._sdl = C("UIListLayout", { Parent = self._sd, SortOrder = Enum.SortOrder.LayoutOrder })
    C("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), Parent = self._sd })

    self._sb:GetPropertyChangedSignal("Text"):Connect(function() self:_doSr() end)
    self._sb.Focused:Connect(function() self:_doSr() end)
    self._sb.FocusLost:Connect(function()
        task.delay(0.2, function()
            self._sd.Visible = false
            self._sd.Size = UDim2.new(1, 0, 0, 0)
        end)
    end)
end

function Library:_doSr()
    local q = string.lower(self._sb.Text)
    for _, c in ipairs(self._sd:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    if q == "" then self._sd.Visible = false; self._sd.Size = UDim2.new(1, 0, 0, 0); return end

    local hits = {}
    for _, m in ipairs(self._mods) do
        local found = string.find(string.lower(m.Name), q, 1, true) or string.find(string.lower(m._cn), q, 1, true)
        if not found then
            for _, o in ipairs(m._ol) do
                if o._lb and string.find(string.lower(o._lb), q, 1, true) then found = true; break end
            end
        end
        if found then hits[#hits+1] = m; if #hits >= 8 then break end end
    end

    if #hits == 0 then self._sd.Visible = false; self._sd.Size = UDim2.new(1, 0, 0, 0); return end

    for i, m in ipairs(hits) do
        local rb = C("TextButton", {
            Parent = self._sd, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26), Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 201,
        })
        C("TextLabel", {
            Parent = rb, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0.6, -10, 1, 0), Font = Theme.FtS, Text = string.lower(m.Name),
            TextColor3 = Theme.OptVal, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202,
        })
        C("TextLabel", {
            Parent = rb, BackgroundTransparency = 1, Position = UDim2.new(0.6, 0, 0, 0),
            Size = UDim2.new(0.4, -8, 1, 0), Font = Theme.Ft, Text = string.lower(m._cn),
            TextColor3 = Theme.BindTxt, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 202,
        })
        rb.MouseEnter:Connect(function() Tw(rb, 0.08, { BackgroundColor3 = Theme.DrHov }) end)
        rb.MouseLeave:Connect(function() Tw(rb, 0.08, { BackgroundColor3 = Theme.DrBg }) end)
        rb.MouseButton1Click:Connect(function()
            self._sd.Visible = false; self._sb.Text = ""
            self:_pulse(m)
        end)
    end

    self._sd.Visible = true
    Tw(self._sd, 0.2, { Size = UDim2.new(1, 0, 0, #hits * 26 + 6) }, Enum.EasingStyle.Quart)
end

function Library:_pulse(mod)
    if mod._cr and mod._cr._col then mod._cr:Expand() end
    task.spawn(function()
        for i = 1, 3 do
            mod.Box.BackgroundColor3 = Theme.Accent
            Tw(mod.Box, 0.12, { BackgroundTransparency = 0.3 })
            task.wait(0.2)
            Tw(mod.Box, 0.2, { BackgroundTransparency = 1 })
            task.wait(0.25)
        end
    end)
end

function Library:_mkKB()
    self._kbw = C("Frame", {
        Parent = self.Gui, BackgroundColor3 = Theme.CatBg, BackgroundTransparency = 0.08,
        BorderSizePixel = 0, Position = UDim2.new(1, -175, 0.5, -80),
        Size = UDim2.new(0, 155, 0, 26), AutomaticSize = Enum.AutomaticSize.Y, Visible = false,
    })
    C("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self._kbw })
    C("UIStroke", { Color = Theme.CatBorder, Thickness = 1, Transparency = 0.4, Parent = self._kbw })
    C("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = self._kbw })
    C("UIListLayout", { Parent = self._kbw, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })

    C("TextLabel", {
        Parent = self._kbw, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
        Font = Theme.FtB, Text = "KEYBINDS", TextColor3 = Theme.CatHeader,
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0,
    })

    self._kbl2 = C("Frame", {
        Parent = self._kbw, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1,
    })
    C("UIListLayout", { Parent = self._kbl2, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1) })

    local dg, ds, sp = false, nil, nil
    self._kbw.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dg = true; ds = inp.Position; sp = self._kbw.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dg = false end end)
        end
    end)
    table.insert(self._cn, UserInputService.InputChanged:Connect(function(inp)
        if dg and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - ds
            self._kbw.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end))

    local tk = 0
    RunService.Heartbeat:Connect(function()
        if self._dead or not self._kbw.Visible then return end
        tk = tk + 1; if tk % 15 ~= 0 then return end
        for _, c in ipairs(self._kbl2:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local idx = 0
        for _, m in ipairs(self._mods) do
            if m.On and m._bk and m._bk ~= Enum.KeyCode.Unknown then
                idx = idx + 1
                local r = C("Frame", { Parent = self._kbl2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = idx })
                C("TextLabel", { Parent = r, BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0), Font = Theme.Ft, Text = m.Name, TextColor3 = Theme.Accent, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left })
                C("TextLabel", { Parent = r, BackgroundTransparency = 1, Position = UDim2.new(0.7, 0, 0, 0), Size = UDim2.new(0.3, 0, 1, 0), Font = Theme.Ft, Text = "[" .. m._bk.Name .. "]", TextColor3 = Theme.BindTxt, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Right })
            end
        end
    end)
end

function Library:_cpop()
    if self._pop then
        local p = self._pop; self._pop = nil; self._ca.Visible = false
        if p.close then p.close() end
    end
end

function Library:_opop(d) self:_cpop(); self._pop = d; self._ca.Visible = true end

function Library:_uacc(col)
    Theme.Accent = col; Theme.ModOn = col; Theme.TgOn = col
    for _, e in ipairs(self._accEls) do
        if e.i and e.i.Parent then pcall(function() e.i[e.p] = col end) end
    end
    for _, m in ipairs(self._mods) do
        if m.On and m.NL then m.NL.TextColor3 = col end
        if m.AB then m.AB.BackgroundColor3 = col end
    end
    -- update category headers to accent
    for _, lbl in ipairs(self._catHeaderLabels) do
        if lbl and lbl.Parent then lbl.TextColor3 = col end
    end
end

function Library:_trk(i, p) self._accEls[#self._accEls+1] = { i = i, p = p } end

function Library:Save(n)
    local d = { opts = {}, mods = {} }
    for id, o in pairs(self._opts) do
        local e = { id = id, t = o.Type }
        if o.Type == "Toggle" then e.v = o.Value
        elseif o.Type == "Slider" then e.v = o.Value
        elseif o.Type == "Dropdown" then e.v = o.Value
        elseif o.Type == "ColorPicker" then e.v = { o.Value.R, o.Value.G, o.Value.B }
        elseif o.Type == "Keybind" then
            e.v = o.Value ~= Enum.KeyCode.Unknown and o.Value.Name or "Unknown"
            e.m = o.Mode or "toggle"
        end
        d.opts[#d.opts+1] = e
    end
    for _, m in ipairs(self._mods) do
        d.mods[#d.mods+1] = {
            id = m._id, on = m.On,
            bk = m._bk and m._bk ~= Enum.KeyCode.Unknown and m._bk.Name or nil,
            bm = m._bm,
        }
    end
    SM(CFG_DIR)
    SW(CFG_DIR .. "/" .. n .. ".json", HttpService:JSONEncode(d))
end

function Library:Load(n)
    local raw = SR(CFG_DIR .. "/" .. n .. ".json")
    if not raw then return false end
    local ok, d = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or not d then return false end
    if d.opts then
        for _, e in ipairs(d.opts) do
            local o = self._opts[e.id]
            if o and o.Set then
                pcall(function()
                    if o.Type == "Toggle" and e.v ~= nil then o:Set(e.v)
                    elseif o.Type == "Slider" and e.v then o:Set(e.v)
                    elseif o.Type == "Dropdown" and e.v then o:Set(e.v)
                    elseif o.Type == "ColorPicker" and e.v then o:Set(Color3.new(e.v[1], e.v[2], e.v[3]))
                    elseif o.Type == "Keybind" and e.v then o:Set(Enum.KeyCode[e.v] or Enum.KeyCode.Unknown, e.m)
                    end
                end)
            end
        end
    end
    if d.mods then
        for _, ms in ipairs(d.mods) do
            for _, m in ipairs(self._mods) do
                if m._id == ms.id then
                    m:SetOn(ms.on or false)
                    if ms.bk then m._bk = Enum.KeyCode[ms.bk] or Enum.KeyCode.Unknown end
                    m._bm = ms.bm or "toggle"
                    m:_ub()
                end
            end
        end
    end
    return true
end

function Library:Delete(n) SD(CFG_DIR .. "/" .. n .. ".json") end

function Library:Configs()
    local f = SL(CFG_DIR); local o = {}
    for _, x in ipairs(f) do local n = x:match("([^/\\]+)%.json$"); if n and n ~= AUTO_CFG then o[#o+1] = n end end
    return o
end

function Library:Unload()
    self._dead = true; self:Save(AUTO_CFG)
    for _, m in ipairs(self._mods) do m:SetOn(false) end
    for _, c in ipairs(self._cn) do pcall(function() c:Disconnect() end) end
    task.wait(0.1); self.Gui:Destroy()
end

-- ═══════════════════════════════
-- CATEGORY - NO AutomaticSize, manual height tracking
-- ═══════════════════════════════
function Library:Category(catName)
    local cat = { Name = catName, Mods = {}, Lib = self, _col = false, _modListH = 0 }
    local idx = #self.Cats + 1

    cat.Frame = C("Frame", {
        Name = "Cat_" .. catName, Parent = self.Main,
        BackgroundColor3 = Theme.CatBg, BackgroundTransparency = 0.06,
        BorderSizePixel = 0, Size = UDim2.new(0, 200, 0, 44), LayoutOrder = idx,
    })
    C("UICorner", { CornerRadius = UDim.new(0, 6), Parent = cat.Frame })
    C("UIStroke", { Color = Theme.CatBorder, Thickness = 1, Transparency = 0.4, Parent = cat.Frame })

    -- header button
    local hdr = C("TextButton", {
        Parent = cat.Frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 36),
        Text = "", AutoButtonColor = false,
    })

    local hdrLbl = C("TextLabel", {
        Parent = hdr, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -36, 1, 0),
        Font = Theme.FtB, Text = string.upper(catName),
        TextColor3 = Theme.Accent, -- ACCENT COLOR for headers
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    })
    self:_trk(hdrLbl, "TextColor3")
    table.insert(self._catHeaderLabels, hdrLbl)

    local arrow = C("TextLabel", {
        Parent = hdr, BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 0), Size = UDim2.new(0, 14, 1, 0),
        Font = Theme.Ft, Text = "▼", TextColor3 = Theme.BindTxt, TextSize = 9,
    })

    -- separator
    local sep = C("Frame", {
        Parent = cat.Frame, BackgroundColor3 = Theme.Sep, BackgroundTransparency = 0.5,
        BorderSizePixel = 0, Position = UDim2.new(0, 12, 0, 36), Size = UDim2.new(1, -24, 0, 1),
    })

    -- module list container - NOT auto-sized
    cat.ML = C("Frame", {
        Parent = cat.Frame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 40), Size = UDim2.new(1, -24, 0, 0),
        ClipsDescendants = true,
    })

    cat._mll = C("UIListLayout", {
        Parent = cat.ML, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0),
    })

    -- track content size and update frame height
    local function updateCatHeight()
        if cat._col then return end
        local h = cat._mll.AbsoluteContentSize.Y
        cat._modListH = h
        cat.ML.Size = UDim2.new(1, -24, 0, h)
        cat.Frame.Size = UDim2.new(0, 200, 0, 44 + h)
    end

    cat._mll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCatHeight)

    -- also run once after a short delay to get initial size
    task.defer(function()
        task.wait(0.05)
        updateCatHeight()
    end)

    cat._updateH = updateCatHeight

    function cat:Expand()
        cat._col = false
        arrow.Text = "▼"
        sep.Visible = true
        local h = cat._mll.AbsoluteContentSize.Y
        cat._modListH = h
        Tw(cat.ML, 0.3, { Size = UDim2.new(1, -24, 0, h) }, Enum.EasingStyle.Quart)
        Tw(cat.Frame, 0.3, { Size = UDim2.new(0, 200, 0, 44 + h) }, Enum.EasingStyle.Quart)
    end

    function cat:Collapse()
        cat._col = true
        arrow.Text = "▶"
        Tw(cat.ML, 0.3, { Size = UDim2.new(1, -24, 0, 0) }, Enum.EasingStyle.Quart)
        Tw(cat.Frame, 0.3, { Size = UDim2.new(0, 200, 0, 36) }, Enum.EasingStyle.Quart)
        task.delay(0.3, function() if cat._col then sep.Visible = false end end)
    end

    hdr.MouseButton1Click:Connect(function()
        if cat._col then cat:Expand() else cat:Collapse() end
    end)
    hdr.MouseEnter:Connect(function() Tw(hdrLbl, 0.1, { TextColor3 = Color3.fromRGB(255, 180, 210) }) end)
    hdr.MouseLeave:Connect(function() Tw(hdrLbl, 0.1, { TextColor3 = Theme.Accent }) end)

    function cat:Module(n) return Library._Mod(self, n) end

    self.Cats[#self.Cats+1] = cat
    return cat
end

-- ═══════════════════════════════
-- MODULE
-- ═══════════════════════════════
function Library._Mod(cat, name)
    local lib = cat.Lib
    local mod = {
        Name = name, On = false, Exp = false,
        _ol = {}, _oc = 0, _bk = nil, _bm = "toggle",
        _id = cat.Name .. "." .. name, _cn = cat.Name, _cr = cat, Cb = nil,
    }

    local mi = #cat.Mods + 1

    -- module container - starts at exactly 26px, NOT auto-sized
    mod.Box = C("Frame", {
        Name = "M_" .. name, Parent = cat.ML,
        BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 26),
        LayoutOrder = mi, ClipsDescendants = true,
    })

    mod.Btn = C("TextButton", {
        Parent = mod.Box, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26), Text = "", AutoButtonColor = false,
    })

    mod.NL = C("TextLabel", {
        Parent = mod.Btn, BackgroundTransparency = 1, Size = UDim2.new(1, -72, 1, 0),
        Font = Theme.FtS, Text = string.lower(name), TextColor3 = Theme.ModOff,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    })

    mod.BL = C("TextLabel", {
        Parent = mod.Btn, BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 0), Size = UDim2.new(0, 68, 1, 0),
        Font = Theme.Ft, Text = "", TextColor3 = Theme.BindTxt,
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
    })

    mod.OF = C("Frame", {
        Parent = mod.Box, BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 26), Size = UDim2.new(1, -8, 0, 0),
        ClipsDescendants = true,
    })

    mod.AB = C("Frame", {
        Parent = mod.OF, BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.55,
        BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 2), Size = UDim2.new(0, 2, 1, -4),
    })
    lib:_trk(mod.AB, "BackgroundColor3")

    mod.OI = C("Frame", {
        Parent = mod.OF, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    mod.OL = C("UIListLayout", { Parent = mod.OI, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) })
    C("UIPadding", { Parent = mod.OI, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8) })

    function mod:_ub()
        if self._bk and self._bk ~= Enum.KeyCode.Unknown then
            self.BL.Text = "[" .. self._bk.Name .. "]"
        else self.BL.Text = "" end
    end

    function mod:SetOn(st)
        self.On = st
        Tw(self.NL, 0.15, { TextColor3 = st and Theme.Accent or Theme.ModOff })
        if self.Cb then pcall(self.Cb, st) end
    end

    local function recalc()
        task.defer(function()
            task.wait(0.02)
            if mod.Exp then
                local h = mod.OL.AbsoluteContentSize.Y + 12
                Tw(mod.OF, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
                Tw(mod.Box, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
                task.delay(0.35, function() cat._updateH() end)
            end
        end)
    end

    mod.Btn.MouseButton1Click:Connect(function() mod:SetOn(not mod.On) end)

    mod.Btn.MouseButton2Click:Connect(function()
        if mod._oc == 0 then return end
        mod.Exp = not mod.Exp
        if mod.Exp then
            local h = mod.OL.AbsoluteContentSize.Y + 12
            Tw(mod.OF, 0.3, { Size = UDim2.new(1, -8, 0, h) }, Enum.EasingStyle.Quart)
            Tw(mod.Box, 0.3, { Size = UDim2.new(1, 0, 0, 26 + h) }, Enum.EasingStyle.Quart)
        else
            lib:_cpop()
            Tw(mod.OF, 0.25, { Size = UDim2.new(1, -8, 0, 0) }, Enum.EasingStyle.Quart)
            Tw(mod.Box, 0.25, { Size = UDim2.new(1, 0, 0, 26) }, Enum.EasingStyle.Quart)
        end
        task.delay(0.35, function() cat._updateH() end)
    end)

    mod.Btn.MouseEnter:Connect(function()
        if not mod.On then Tw(mod.NL, 0.08, { TextColor3 = Color3.fromRGB(225, 225, 235) }) end
    end)
    mod.Btn.MouseLeave:Connect(function()
        if not mod.On then Tw(mod.NL, 0.08, { TextColor3 = Theme.ModOff }) end
    end)

    function mod:OnToggle(cb) self.Cb = cb; return self end

    -- ═══ TOGGLE ═══
    function mod:Toggle(tn, def, cb)
        local id = self._id .. "." .. tn
        local o = { Type = "Toggle", Value = def or false, Callback = cb, _lb = tn }
        self._oc = self._oc + 1

        local row = C("Frame", { Parent = self.OI, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self._oc })
        C("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -44, 1, 0), Font = Theme.Ft, Text = tn, TextColor3 = Theme.OptText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local bg = C("Frame", { Parent = row, BackgroundColor3 = o.Value and Theme.TgOn or Theme.TgOff, BorderSizePixel = 0, Position = UDim2.new(1, -36, 0.5, -7), Size = UDim2.new(0, 30, 0, 14) })
        C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bg })
        if o.Value then lib:_trk(bg, "BackgroundColor3") end

        local kn = C("Frame", { Parent = bg, BackgroundColor3 = Theme.Knob, BorderSizePixel = 0, Position = o.Value and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5), Size = UDim2.new(0, 10, 0, 10) })
        C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = kn })

        local btn = C("TextButton", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 5 })

        function o:Set(v)
            o.Value = v
            Tw(bg, 0.2, { BackgroundColor3 = v and Theme.TgOn or Theme.TgOff })
            Tw(kn, 0.2, { Position = v and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5) })
            if o.Callback then pcall(o.Callback, v) end
        end
        btn.MouseButton1Click:Connect(function() o:Set(not o.Value) end)

        lib._opts[id] = o; self._ol[#self._ol+1] = o; task.defer(recalc)
        return o
    end

    -- ═══ SLIDER ═══
    function mod:Slider(sn, def, mn, mx, cb, sfx, dec)
        sfx = sfx or ""; dec = dec or 1; def = def or mn
        local id = self._id .. "." .. sn
        local o = { Type = "Slider", Value = def, Callback = cb, _lb = sn }
        self._oc = self._oc + 1

        local row = C("Frame", { Parent = self.OI, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = self._oc })
        C("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 0, 15), Font = Theme.Ft, Text = sn, TextColor3 = Theme.OptText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
        local vl = C("TextLabel", { Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0.6, 0, 0, 0), Size = UDim2.new(0.4, 0, 0, 15), Font = Theme.FtS, Text = tostring(def) .. sfx, TextColor3 = Theme.OptVal, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right })

        local tr = C("Frame", { Parent = row, BackgroundColor3 = Theme.SlBg, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 19), Size = UDim2.new(1, 0, 0, 5) })
        C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = tr })

        local p = math.clamp((def - mn) / (mx - mn), 0, 1)
        local fl = C("Frame", { Parent = tr, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.new(p, 0, 1, 0) })
        C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fl })
        lib:_trk(fl, "BackgroundColor3")

        local kb = C("Frame", { Parent = tr, BackgroundColor3 = Theme.Knob, BorderSizePixel = 0, Position = UDim2.new(p, -5, 0.5, -5), Size = UDim2.new(0, 10, 0, 10), ZIndex = 3 })
        C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = kb })

        local sb = C("TextButton", { Parent = tr, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 14), Position = UDim2.new(0, 0, 0, -7), Text = "", ZIndex = 5 })

        local sd = { on = false }
        sd.fn = function(inp)
            local pp = math.clamp((inp.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
            local val = math.floor((mn + (mx - mn) * pp) * (10^dec) + 0.5) / (10^dec)
            o.Value = val; vl.Text = tostring(val) .. sfx
            fl.Size = UDim2.new(pp, 0, 1, 0); kb.Position = UDim2.new(pp, -5, 0.5, -5)
            if cb then cb(val) end
        end
        IM.sl[#IM.sl+1] = sd

        function o:Set(v)
            v = math.clamp(v, mn, mx); local pp = (v - mn) / (mx - mn)
            o.Value = v; vl.Text = tostring(v) .. sfx
            fl.Size = UDim2.new(pp, 0, 1, 0); kb.Position = UDim2.new(pp, -5, 0.5, -5)
            if cb then cb(v) end
        end

        sb.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then sd.on = true; sd.fn(inp) end end)

        lib._opts[id] = o; self._ol[#self._ol+1] = o; task.defer(recalc)
        return o
    end

    -- ═══ DROPDOWN ═══
    function mod:Dropdown(dn, items, def, cb)
        local id = self._id .. "." .. dn
        local o = { Type = "Dropdown", Value = def or items[1], Items = items, Callback = cb, _lb = dn }
        self._oc = self._oc + 1

        local row = C("Frame", { Parent = self.OI, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self._oc })
        C("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Font = Theme.Ft, Text = dn, TextColor3 = Theme.OptText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local vb = C("TextButton", { Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), Font = Theme.FtS, Text = tostring(o.Value), TextColor3 = Theme.OptVal, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, AutoButtonColor = false })

        local pf = C("Frame", { Parent = lib.PopLayer, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0, Size = UDim2.new(0, 120, 0, 0), ClipsDescendants = true, Visible = false, ZIndex = 110 })
        C("UICorner", { CornerRadius = UDim.new(0, 4), Parent = pf })
        C("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = pf })
        C("UIListLayout", { Parent = pf, SortOrder = Enum.SortOrder.LayoutOrder })
        C("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = pf })

        local ibs = {}
        for i, item in ipairs(items) do
            local ib = C("TextButton", { Parent = pf, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 22), Font = Theme.Ft, Text = item, TextColor3 = (item == o.Value) and Theme.Accent or Theme.OptText, TextSize = 11, AutoButtonColor = false, LayoutOrder = i, ZIndex = 111 })
            ibs[#ibs+1] = ib
            ib.MouseEnter:Connect(function() Tw(ib, 0.08, { BackgroundColor3 = Theme.DrHov }) end)
            ib.MouseLeave:Connect(function() Tw(ib, 0.08, { BackgroundColor3 = Theme.DrBg }) end)
            ib.MouseButton1Click:Connect(function()
                o.Value = item; vb.Text = item
                for _, b in ipairs(ibs) do b.TextColor3 = (b.Text == item) and Theme.Accent or Theme.OptText end
                lib:_cpop(); if cb then cb(item) end
            end)
        end

        function o:Set(v) o.Value = v; vb.Text = v; for _, b in ipairs(ibs) do b.TextColor3 = (b.Text == v) and Theme.Accent or Theme.OptText end; if cb then cb(v) end end

        vb.MouseButton1Click:Connect(function()
            if lib._pop and lib._pop.frame == pf then lib:_cpop(); return end
            local ap, as = vb.AbsolutePosition, vb.AbsoluteSize
            local w = math.max(as.X, 100)
            pf.Position = UDim2.new(0, ap.X + as.X - w, 0, ap.Y + as.Y + 2)
            pf.Size = UDim2.new(0, w, 0, 0); pf.Visible = true
            Tw(pf, 0.2, { Size = UDim2.new(0, w, 0, #items * 22 + 4) }, Enum.EasingStyle.Quart)
            lib:_opop({ frame = pf, close = function()
                Tw(pf, 0.15, { Size = UDim2.new(0, w, 0, 0) }, Enum.EasingStyle.Quart)
                task.delay(0.15, function() pf.Visible = false end)
            end })
        end)

        lib._opts[id] = o; self._ol[#self._ol+1] = o; task.defer(recalc)
        return o
    end

    -- ═══ COLOR PICKER ═══
    function mod:ColorPicker(cn, def, cb)
        def = def or Color3.new(1, 0, 0)
        local h, s, v = HSV(def)
        local id = self._id .. "." .. cn
        local o = { Type = "ColorPicker", Value = def, Callback = cb, _lb = cn }
        self._oc = self._oc + 1

        local row = C("Frame", { Parent = self.OI, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self._oc })
        C("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 22), Font = Theme.Ft, Text = cn, TextColor3 = Theme.OptText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local prev = C("TextButton", { Parent = row, BackgroundColor3 = def, BorderSizePixel = 0, Position = UDim2.new(1, -20, 0.5, -6), Size = UDim2.new(0, 16, 0, 12), Text = "", AutoButtonColor = false })
        C("UICorner", { CornerRadius = UDim.new(0, 3), Parent = prev })
        C("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = prev })

        local pnl = C("Frame", { Parent = lib.PopLayer, BackgroundColor3 = Theme.PkBg, BorderSizePixel = 0, Size = UDim2.new(0, 180, 0, 100), Visible = false, ZIndex = 110 })
        C("UICorner", { CornerRadius = UDim.new(0, 5), Parent = pnl })
        C("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = pnl })

        local svB = C("Frame", { Parent = pnl, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -32, 1, -16), ZIndex = 111, ClipsDescendants = true })
        C("UICorner", { CornerRadius = UDim.new(0, 3), Parent = svB })

        local hO = C("Frame", { Parent = svB, BackgroundColor3 = Color3.fromHSV(h, 1, 1), Size = UDim2.new(1, 0, 1, 0), ZIndex = 112 })
        C("UIGradient", { Parent = hO, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) })

        local bO = C("Frame", { Parent = svB, BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.new(1, 0, 1, 0), ZIndex = 113 })
        C("UIGradient", { Parent = bO, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }), Rotation = 90 })

        local svC = C("Frame", { Parent = svB, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.new(s, -5, 1-v, -5), Size = UDim2.new(0, 10, 0, 10), ZIndex = 116 })
        C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svC })
        C("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5, Parent = svC })

        local svBt = C("TextButton", { Parent = svB, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 117 })

        local hBr = C("Frame", { Parent = pnl, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.new(1, -20, 0, 8), Size = UDim2.new(0, 10, 1, -16), ZIndex = 111 })
        C("UICorner", { CornerRadius = UDim.new(0, 3), Parent = hBr })
        C("UIGradient", { Parent = hBr, Rotation = 90, Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }) })

        local hC = C("Frame", { Parent = hBr, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.new(0, -2, h, -2), Size = UDim2.new(1, 4, 0, 4), ZIndex = 116 })
        C("UICorner", { CornerRadius = UDim.new(0, 2), Parent = hC })
        C("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = hC })

        local hBt = C("TextButton", { Parent = hBr, BackgroundTransparency = 1, Size = UDim2.new(1, 8, 1, 0), Position = UDim2.new(0, -4, 0, 0), Text = "", ZIndex = 117 })

        local function upd()
            o.Value = Color3.fromHSV(math.clamp(h, 0, 0.999), s, v)
            prev.BackgroundColor3 = o.Value
            hO.BackgroundColor3 = Color3.fromHSV(math.clamp(h, 0, 0.999), 1, 1)
            svC.Position = UDim2.new(s, -5, 1-v, -5)
            hC.Position = UDim2.new(0, -2, h, -2)
            if cb then cb(o.Value) end
        end

        function o:Set(c) h, s, v = HSV(c); upd() end

        local svD = { on = false }
        svD.fn = function(inp)
            s = math.clamp((inp.Position.X - svB.AbsolutePosition.X) / svB.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((inp.Position.Y - svB.AbsolutePosition.Y) / svB.AbsoluteSize.Y, 0, 1)
            upd()
        end
        IM.sv[#IM.sv+1] = svD

        local hD = { on = false }
        hD.fn = function(inp) h = math.clamp((inp.Position.Y - hBr.AbsolutePosition.Y) / hBr.AbsoluteSize.Y, 0, 0.999); upd() end
        IM.hu[#IM.hu+1] = hD

        svBt.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then svD.on = true; svD.fn(inp) end end)
        hBt.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then hD.on = true; hD.fn(inp) end end)

        prev.MouseButton1Click:Connect(function()
            if lib._pop and lib._pop.frame == pnl then lib:_cpop(); return end
            local ap = prev.AbsolutePosition
            pnl.Position = UDim2.new(0, ap.X - 160, 0, ap.Y + 16); pnl.Visible = true
            lib:_opop({ frame = pnl, close = function() pnl.Visible = false; svD.on = false; hD.on = false end })
        end)

        lib._opts[id] = o; self._ol[#self._ol+1] = o; task.defer(recalc)
        return o
    end

    -- ═══ KEYBIND ═══
    function mod:Keybind(kn, def, cb)
        def = def or Enum.KeyCode.Unknown
        local id = self._id .. "." .. kn
        local o = { Type = "Keybind", Value = def, Mode = "toggle", Callback = cb, _lb = kn }
        self._oc = self._oc + 1
        mod._bk = def; mod._bm = "toggle"; mod:_ub()

        local row = C("Frame", { Parent = self.OI, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self._oc })
        C("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.4, 0, 1, 0), Font = Theme.Ft, Text = kn, TextColor3 = Theme.OptText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })

        local bb = C("TextButton", { Parent = row, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0, Position = UDim2.new(1, -55, 0.5, -9), Size = UDim2.new(0, 52, 0, 18), Font = Theme.Ft, Text = def ~= Enum.KeyCode.Unknown and def.Name or "none", TextColor3 = Theme.OptVal, TextSize = 10, AutoButtonColor = false })
        C("UICorner", { CornerRadius = UDim.new(0, 3), Parent = bb })
        C("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = bb })

        local mf = C("Frame", { Parent = lib.PopLayer, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0, Size = UDim2.new(0, 80, 0, 0), ClipsDescendants = true, Visible = false, ZIndex = 110 })
        C("UICorner", { CornerRadius = UDim.new(0, 4), Parent = mf })
        C("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = mf })
        C("UIListLayout", { Parent = mf, SortOrder = Enum.SortOrder.LayoutOrder })
        C("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = mf })

        local modes = { "toggle", "hold", "always" }
        local mbs = {}
        for i, m in ipairs(modes) do
            local mb = C("TextButton", { Parent = mf, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 20), Font = Theme.Ft, Text = m, TextColor3 = (m == o.Mode) and Theme.Accent or Theme.OptText, TextSize = 11, AutoButtonColor = false, LayoutOrder = i, ZIndex = 111 })
            mbs[#mbs+1] = mb
            mb.MouseEnter:Connect(function() Tw(mb, 0.08, { BackgroundColor3 = Theme.DrHov }) end)
            mb.MouseLeave:Connect(function() Tw(mb, 0.08, { BackgroundColor3 = Theme.DrBg }) end)
            mb.MouseButton1Click:Connect(function()
                o.Mode = m; mod._bm = m
                for _, b in ipairs(mbs) do b.TextColor3 = (b.Text == m) and Theme.Accent or Theme.OptText end
                lib:_cpop(); if m == "always" then mod:SetOn(true) end
            end)
        end

        local ls = { on = false }
        ls.set = function(key)
            o.Value = key; mod._bk = key
            bb.Text = key ~= Enum.KeyCode.Unknown and key.Name or "none"
            mod:_ub(); Tw(bb, 0.1, { TextColor3 = Theme.OptVal })
        end
        lib._kbl[#lib._kbl+1] = ls

        bb.MouseButton1Click:Connect(function() ls.on = true; bb.Text = "..."; Tw(bb, 0.1, { TextColor3 = Theme.Accent }) end)

        bb.MouseButton2Click:Connect(function()
            if lib._pop and lib._pop.frame == mf then lib:_cpop(); return end
            local ap, as = bb.AbsolutePosition, bb.AbsoluteSize
            mf.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 2); mf.Size = UDim2.new(0, 80, 0, 0); mf.Visible = true
            Tw(mf, 0.2, { Size = UDim2.new(0, 80, 0, #modes * 20 + 4) }, Enum.EasingStyle.Quart)
            lib:_opop({ frame = mf, close = function() Tw(mf, 0.15, { Size = UDim2.new(0, 80, 0, 0) }, Enum.EasingStyle.Quart); task.delay(0.15, function() mf.Visible = false end) end })
        end)

        function o:Set(key, mode)
            o.Value = key; mod._bk = key; bb.Text = key ~= Enum.KeyCode.Unknown and key.Name or "none"
            if mode then o.Mode = mode; mod._bm = mode; for _, b in ipairs(mbs) do b.TextColor3 = (b.Text == mode) and Theme.Accent or Theme.OptText end end
            mod:_ub()
        end

        lib._opts[id] = o; self._ol[#self._ol+1] = o; task.defer(recalc)
        return o
    end

    -- ═══ BUTTON ═══
    function mod:Button(text, cb)
        self._oc = self._oc + 1
        local btn = C("TextButton", { Parent = self.OI, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 22), Font = Theme.FtS, Text = text, TextColor3 = Theme.OptVal, TextSize = 11, AutoButtonColor = false, LayoutOrder = self._oc })
        C("UICorner", { CornerRadius = UDim.new(0, 3), Parent = btn })
        C("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = btn })
        btn.MouseEnter:Connect(function() Tw(btn, 0.08, { BackgroundColor3 = Theme.DrHov }) end)
        btn.MouseLeave:Connect(function() Tw(btn, 0.08, { BackgroundColor3 = Theme.DrBg }) end)
        btn.MouseButton1Click:Connect(function() if cb then cb() end end)
        task.defer(recalc)
    end

    -- ═══ TEXTBOX ═══
    function mod:TextBox(tn, def, ph, cb)
        self._oc = self._oc + 1
        local o = { Type = "TextBox", Value = def or "", _lb = tn }
        local row = C("Frame", { Parent = self.OI, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = self._oc })
        C("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Font = Theme.Ft, Text = tn, TextColor3 = Theme.OptText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
        local tb = C("TextBox", { Parent = row, BackgroundColor3 = Theme.DrBg, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 16), Size = UDim2.new(1, 0, 0, 18), Font = Theme.Ft, Text = def or "", PlaceholderText = ph or "", PlaceholderColor3 = Theme.BindTxt, TextColor3 = Theme.OptVal, TextSize = 11, ClearTextOnFocus = false })
        C("UICorner", { CornerRadius = UDim.new(0, 3), Parent = tb })
        C("UIStroke", { Color = Theme.DrBor, Thickness = 1, Parent = tb })
        C("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = tb })
        tb.FocusLost:Connect(function() o.Value = tb.Text; if cb then cb(tb.Text) end end)
        function o:Set(v) tb.Text = v; o.Value = v end
        function o:Get() return tb.Text end
        lib._opts[self._id .. "." .. tn] = o; self._ol[#self._ol+1] = o; task.defer(recalc)
        return o
    end

    -- ═══ LABEL ═══
    function mod:Label(text)
        self._oc = self._oc + 1
        C("TextLabel", { Parent = self.OI, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Theme.Ft, Text = text, TextColor3 = Theme.BindTxt, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = self._oc })
        task.defer(recalc)
    end

    -- ═══ SEPARATOR ═══
    function mod:Separator()
        self._oc = self._oc + 1
        local s = C("Frame", { Parent = self.OI, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6), LayoutOrder = self._oc })
        C("Frame", { Parent = s, BackgroundColor3 = Theme.Sep, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1) })
        task.defer(recalc)
    end

    cat.Mods[#cat.Mods+1] = mod
    lib._mods[#lib._mods+1] = mod
    return mod
end

return Library
