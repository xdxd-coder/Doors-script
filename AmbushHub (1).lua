warn("--- [AMBUSH HUB] EXECUTING SCRIPT ---")
pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Ambush Hub", Text = "Script started, loading UI...", Duration = 6 }) end)
print("[AMBUSH HUB] Loading Services")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end
R4N_KeyTab = {}
-- English only. No language picker, no remote langpack fetch.
R4N_LANGPACK = {}
R4N_LANG = "en"


do
    local genv = (getgenv and getgenv()) or _G
    local isDoors = game.PlaceId == 6516141723 or game.PlaceId == 6839171747 or game.GameId == 2440500124
    if not isDoors then
        if genv.R4N_AUTOEXEC then genv.R4N_AUTOEXEC = nil return end
        pcall(function() LocalPlayer:Kick("This script is only for DOORS. Join DOORS and execute it correctly.") end)
        return
    end
    genv.R4N_AUTOEXEC = nil
end

R4N_SRC = nil
pcall(function()
    local info = debug.getinfo and debug.getinfo(1, "S")
    local s = info and info.source
    if type(s) == "string" and #s > 20000 and s:sub(1, 1) ~= "@" and s:sub(1, 1) ~= "=" then R4N_SRC = s end
end)
R4N_AE_STATUS = "off"
function R4N_QueueAutoExec()
    pcall(function()
        local CACHE = "RON_Cache.lua"
        local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
        if not (isfile and readfile and isfile("RON_AutoExec.json")) then return end
        local d = HttpService:JSONDecode(readfile("RON_AutoExec.json"))
        if type(d) ~= "table" or not d.on then R4N_AE_STATUS = "off" return end
        if not qot then R4N_AE_STATUS = "noqueue" return end
        local loader
        if R4N_SRC then
            if writefile then pcall(writefile, CACHE, R4N_SRC) end
            if isfile(CACHE) then
                loader = "loadstring(readfile(" .. string.format("%q", CACHE) .. "))()"
            elseif #R4N_SRC < 2000000 then
                loader = "loadstring(" .. string.format("%q", R4N_SRC) .. ")()"
            end
            R4N_AE_STATUS = loader and "ok" or "nosource"
        elseif isfile(CACHE) then
            loader = "loadstring(readfile(" .. string.format("%q", CACHE) .. "))()"
            R4N_AE_STATUS = "cache"
        else
            for _, f in ipairs({ "RON-HUB-FINAL.lua", "RON-HUB.lua", "RON.lua" }) do
                if isfile(f) then
                    loader = "loadstring(readfile(" .. string.format("%q", f) .. "))()"
                    break
                end
            end
            R4N_AE_STATUS = loader and "file" or "nosource"
        end
        if not loader then return end
        local genv = (getgenv and getgenv()) or _G
        if genv.R4N_QUEUED then return end
        genv.R4N_QUEUED = true
        qot("local g=(getgenv and getgenv()) or _G;g.R4N_QUEUED=nil;"
            .. "local okf,f=pcall(readfile,\"RON_AutoExec.json\");if okf and f and not f:find('\"on\":true',1,true) then return end;"
            .. "g.R4N_AUTOEXEC=true;if not game:IsLoaded() then game.Loaded:Wait() end;task.wait(1);" .. loader)
    end)
end
R4N_QueueAutoExec()

math.randomseed(os.time())

print("[AMBUSH HUB] Services Loaded")
print("[AMBUSH HUB] Loading Icon")
local ICON_ID = 107740382639133
local ICON_FILE = "RON_Icon.png"
local FALLBACK_ICON = "shield"

local function IsPng(data)
    return type(data) == "string" and #data > 8 and data:sub(2, 4) == "PNG"
end

local function ResolveImageId(id)
    local ok, result = pcall(function()
        local obj = game:GetObjects("rbxassetid://" .. id)[1]
        if obj then
            local tex = obj.Texture or obj.Image or obj.ColorMapContent
            if tex then
                return tostring(tex):match("id=(%d+)") or tostring(tex):match("(%d+)$")
            end
        end
    end)
    if ok and result then
        return result
    end
    return tostring(id)
end

local function GetIconAsset()
    local canFile = isfile and writefile and readfile and getcustomasset

    if canFile and isfile(ICON_FILE) then
        local ok, data = pcall(readfile, ICON_FILE)
        if ok and IsPng(data) then
            local ok2, asset = pcall(getcustomasset, ICON_FILE)
            if ok2 and asset then
                return asset
            end
        elseif delfile then
            pcall(delfile, ICON_FILE)
        end
    end

    local imageId = ResolveImageId(ICON_ID)

    if canFile then
        local ok, data = pcall(function()
            return game:HttpGet("https://assetdelivery.roblox.com/v1/asset/?id=" .. imageId)
        end)
        if ok and IsPng(data) then
            pcall(writefile, ICON_FILE, data)
            local ok2, asset = pcall(getcustomasset, ICON_FILE)
            if ok2 and asset then
                return asset
            end
        end
    end

    if imageId and imageId ~= tostring(ICON_ID) then
        return "rbxassetid://" .. imageId
    end

    return FALLBACK_ICON
end

local IconAsset = FALLBACK_ICON
pcall(function()
    if isfile and readfile and getcustomasset and isfile(ICON_FILE) then
        local data = readfile(ICON_FILE)
        if IsPng(data) then
            local asset = getcustomasset(ICON_FILE)
            if asset then IconAsset = asset end
        end
    end
end)
task.spawn(function() pcall(GetIconAsset) end)

print("[AMBUSH HUB] Icon loaded")
print("[AMBUSH HUB] Loading Execution Count")
local ExecCountFile = "RON_ExecCount.txt"
local executionCount = 1

if isfile and readfile and writefile then
    if isfile(ExecCountFile) then
        local ok, raw = pcall(readfile, ExecCountFile)
        local current = ok and tonumber(raw)
        if current then
            executionCount = current + 1
        end
    end
    pcall(writefile, ExecCountFile, tostring(executionCount))
end

local currentExecutor = "Unknown Executor"
if identifyexecutor then
    currentExecutor = identifyexecutor()
elseif getexecutorname then
    currentExecutor = getexecutorname()
end

print("[AMBUSH HUB] Execution Count loaded")
-- English only — no language picker. Direct load.


print("[AMBUSH HUB] Loading WindUI")
print("[AMBUSH HUB] Loading WindUI")
local WindUI, Window = (function()
    local env = (getgenv and getgenv()) or _G

    local permanent = {
        isfolder  = function() return false end,
        makefolder = function() end,
        cloneref  = function(o) return o end,
        gethui    = function() return game:GetService("CoreGui") end,
    }
    local temporary = {
        isfile    = function() return false end,
        readfile  = function() return "" end,
        writefile = function() end,
        listfiles = function() return {} end,
        delfile   = function() end,
        delfolder = function() end,
    }
    local addedTemp = {}
    for name, fn in pairs(permanent) do
        if type(env[name]) ~= "function" then pcall(function() env[name] = fn end) end
    end
    for name, fn in pairs(temporary) do
        if type(env[name]) ~= "function" then
            local ok = pcall(function() env[name] = fn end)
            if ok then addedTemp[#addedTemp + 1] = name end
        end
    end

    local function notify(msg)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Ambush Hub", Text = msg, Duration = 8
            })
        end)
    end

    local sources = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://github.com/Footagesus/WindUI/releases/download/1.6.41/main.lua",
    }

    local function withTimeout(seconds, fn)
        local done, result = false, nil
        task.spawn(function()
            local ok, r = pcall(fn)
            if ok then result = r end
            done = true
        end)
        local t0 = os.clock()
        while not done and os.clock() - t0 < seconds do task.wait(0.1) end
        if not done then warn("[AMBUSH HUB] Timeout waiting for WindUI") end
        return result
    end

    local function tryLoadRaw(url)
        local okGet, src = pcall(function() return game:HttpGet(url) end)
        if not okGet or type(src) ~= "string" or #src < 1000 then
            warn("[AMBUSH HUB] HttpGet failed: " .. url .. " -> " .. tostring(src))
            return nil
        end
        local fn, cerr = loadstring(src)
        if type(fn) ~= "function" then
            warn("[AMBUSH HUB] loadstring failed: " .. url .. " -> " .. tostring(cerr))
            return nil
        end
        local okRun, lib = pcall(fn)
        if not okRun or type(lib) ~= "table" or type(lib.CreateWindow) ~= "function" then
            warn("[AMBUSH HUB] WindUI invalid: " .. url .. " -> " .. tostring(lib))
            return nil
        end
        return lib
    end

    local function makeWindow(lib, icon, full)
        local cfg = {
            Title = "Ambush Hub",
            Icon = icon,
            Author = "void script",
            Folder = "RON_Configs",
            Size = UDim2.fromOffset(580, 460),
            Theme = "Dark",
        }
        if full then
            cfg.Transparent = true
            cfg.SideBarWidth = 170
            cfg.HasOutline = true
        end
        return pcall(function() return lib:CreateWindow(cfg) end)
    end

    local lib, win
    for _, url in ipairs(sources) do
        local candidate = withTimeout(25, function() return tryLoadRaw(url) end)
        if candidate then
            local ok, w = makeWindow(candidate, IconAsset, true)
            if not ok then
                warn("[AMBUSH HUB] CreateWindow failed (full config): " .. tostring(w))
                ok, w = makeWindow(candidate, FALLBACK_ICON, true)
            end
            if not ok then
                warn("[AMBUSH HUB] CreateWindow failed (icon fallback): " .. tostring(w))
                ok, w = makeWindow(candidate, FALLBACK_ICON, false)
            end
            if ok and w then
                lib, win = candidate, w
                break
            end
            warn("[AMBUSH HUB] CreateWindow failed (minimal config): " .. tostring(w))
        end
    end

    for _, name in ipairs(addedTemp) do
        pcall(function() env[name] = nil end)
    end

    if not lib or not win then
        warn("[AMBUSH HUB] Could not load WindUI from any source")
        notify("Could not load the UI. Check your internet/executor and try again.")
        return nil, nil
    end
    return lib, win
end)()

if not WindUI or not Window then
    return
end

-- Custom background image — applied to the WindUI window
task.spawn(function()
    local sgui = WindUI and WindUI.ScreenGui
    if not sgui then return end
    local win = sgui:FindFirstChild("Window")
    if not win then return end
    local bg = win:FindFirstChild("Background", true)
    if bg and bg:IsA("ImageLabel") then
        bg.Image = "rbxassetid://0"  -- clear default
    end
    -- Try to fetch + save the PNG, then set it as a custom asset
    pcall(function()
        if writefile and readfile and isfile and getcustomasset then
            if not isfile("AmbushHub_BG.png") then
                local ok, data = pcall(function()
                    return game:HttpGet("https://raw.githubusercontent.com/drovcho/Neverloseui-void/refs/heads/main/background.png")
                end)
                if ok and type(data) == "string" and #data > 100 then
                    pcall(writefile, "AmbushHub_BG.png", data)
                end
            end
            if isfile("AmbushHub_BG.png") then
                local ok2, asset = pcall(getcustomasset, "AmbushHub_BG.png")
                if ok2 and asset then
                    -- Find or create a background image in the WindUI window
                    local frame = win:FindFirstChild("MainFrame") or win:FindFirstChild("Content")
                    if frame then
                        local img = frame:FindFirstChild("AmbushHubBG")
                        if not img then
                            img = Instance.new("ImageLabel")
                            img.Name = "AmbushHubBG"
                            img.Size = UDim2.fromScale(1, 1)
                            img.Position = UDim2.fromScale(0, 0)
                            img.BackgroundTransparency = 1
                            img.ZIndex = -1  -- behind everything
                            img.Parent = frame
                        end
                        img.Image = asset
                        img.ScaleType = Enum.ScaleType.Crop
                    end
                    return
                end
            end
        end
        -- Fallback: use the direct URL (won't work on all executors)
        local frame = win:FindFirstChild("MainFrame") or win:FindFirstChild("Content")
        if frame then
            local img = frame:FindFirstChild("AmbushHubBG")
            if not img then
                img = Instance.new("ImageLabel")
                img.Name = "AmbushHubBG"
                img.Size = UDim2.fromScale(1, 1)
                img.Position = UDim2.fromScale(0, 0)
                img.BackgroundTransparency = 1
                img.ZIndex = -1
                img.Parent = frame
            end
            img.Image = "https://raw.githubusercontent.com/drovcho/Neverloseui-void/refs/heads/main/background.png"
            img.ScaleType = Enum.ScaleType.Crop
        end
    end)
end)

-- Keep the WindUI hub and its auxiliary layers above regular game interfaces.
do
    local HUB_DISPLAY_ORDER = 999999

    local function RaiseScreenGui(gui)
        if not gui then return end
        pcall(function()
            if gui:IsA("ScreenGui") then
                gui.DisplayOrder = HUB_DISPLAY_ORDER
                gui.IgnoreGuiInset = true
            end
        end)
    end

    local function RaiseWindUIGuis()
        RaiseScreenGui(WindUI.ScreenGui)
        RaiseScreenGui(WindUI.NotificationGui)
        RaiseScreenGui(WindUI.DropdownGui)
        RaiseScreenGui(WindUI.TooltipGui)
    end

    RaiseWindUIGuis()
    task.defer(RaiseWindUIGuis)
    task.delay(0.5, RaiseWindUIGuis)
end

R4N_I18N = R4N_LANGPACK.Titles or {}
do
    local dict = R4N_LANG ~= "en" and R4N_I18N[R4N_LANG]
    if dict then
        local function tr(cfg)
            if type(cfg) == "table" and type(cfg.Title) == "string" then
                local t = dict[cfg.Title]
                if t then cfg.Title = t end
            end
        end
        local METHODS = { "Section", "Button", "Toggle", "Slider", "Dropdown", "Input", "Keybind", "Colorpicker", "ColorPicker", "Paragraph" }
        local origTab = Window.Tab
        Window.Tab = function(self, cfg, ...)
            tr(cfg)
            local tab = origTab(self, cfg, ...)
            if type(tab) == "table" then
                for _, m in ipairs(METHODS) do
                    local f = tab[m]
                    if type(f) == "function" then
                        tab[m] = function(s, c, ...) tr(c) return f(s, c, ...) end
                    end
                end
            end
            return tab
        end
    end
end

local MainTab       = Window:Tab({ Title = "Main",     Icon = "house" })
local InfoTab       = Window:Tab({ Title = "Info",     Icon = "info" })
local VisualsTab    = Window:Tab({ Title = "Visuals",  Icon = "eye" })
local PlayerTab     = Window:Tab({ Title = "Player",   Icon = "user" })
local AutomationTab = Window:Tab({ Title = "Automation", Icon = "zap" })
local AntiCheatTab  = Window:Tab({ Title = "Anticheat", Icon = "shield" })
local AntisTab      = Window:Tab({ Title = "Antis",   Icon = "ban" })
ArchivesTab  = Window:Tab({ Title = "Archives",  Icon = "archive" })
StairwellTab = Window:Tab({ Title = "Stairwell", Icon = "layers" })
local AlertsTab     = Window:Tab({ Title = "Alerts",   Icon = "bell" })
local MiscTab       = Window:Tab({ Title = "Misc",     Icon = "ellipsis" })
FunTab = Window:Tab({ Title = "Fun", Icon = "smile" })
local InfiniteItemsTab = Window:Tab({ Title = "Infinite Items", Icon = "infinity" })
local KeybindsTab   = Window:Tab({ Title = "Keybinds",   Icon = "keyboard" })
local ConfigsTab    = Window:Tab({ Title = "Configs",   Icon = "settings" })

for _, t in ipairs({}) do
    t:Paragraph({ Title = "Soon", Desc = "This tab has no features yet." })
end

-- ════════════════════════════════════════════════════════════════
-- AMBUSH HUB — FPS & PING OVERLAY (premium glass card, animated border)
-- ════════════════════════════════════════════════════════════════
do
    local Stats = game:GetService("Stats")
    local RunSvc = game:GetService("RunService")
    local Hui = (gethui and gethui()) or game:GetService("CoreGui")

    local overlay = Instance.new("ScreenGui")
    overlay.Name = "AmbushHubStats"
    overlay.ResetOnSpawn = false
    overlay.IgnoreGuiInset = true
    overlay.DisplayOrder = 32766
    pcall(function() overlay.Parent = Hui end)
    if not overlay.Parent then
        overlay.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Compact glass card with clipped corners + animated gradient border
    local W, H = 160, 72
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Position = UDim2.new(1, -10, 0, 10)
    panel.Size = UDim2.fromOffset(W, H)
    panel.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true  -- clips inner content to rounded corners
    panel.Parent = overlay

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 14)
    pc.Parent = panel

    -- Subtle gradient fill (deep navy → near-black)
    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 36)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 16)),
    })
    bgGrad.Rotation = 45
    bgGrad.Parent = panel

    -- Outer accent stroke with teal→cyan→purple gradient (animated)
    local ps = Instance.new("UIStroke")
    ps.Color = Color3.fromRGB(0, 255, 200)
    ps.Thickness = 1.5
    ps.Transparency = 0.15
    ps.Parent = panel
    local pg = Instance.new("UIGradient")
    pg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 255, 200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(120, 100, 255)),
    })
    pg.Rotation = 0
    pg.Parent = ps

    -- Inner padding container (compact)
    local inner = Instance.new("Frame")
    inner.BackgroundTransparency = 1
    inner.Position = UDim2.new(0, 10, 0, 8)
    inner.Size = UDim2.new(1, -20, 1, -16)
    inner.Parent = panel

    -- Top row: FPS
    local topRow = Instance.new("Frame")
    topRow.BackgroundTransparency = 1
    topRow.Size = UDim2.new(1, 0, 0, 26)
    topRow.Parent = inner

    local fpsIcon = Instance.new("TextLabel")
    fpsIcon.BackgroundTransparency = 1
    fpsIcon.Size = UDim2.new(0, 30, 1, 0)
    fpsIcon.Font = Enum.Font.GothamBold
    fpsIcon.TextSize = 10
    fpsIcon.Text = "FPS"
    fpsIcon.TextColor3 = Color3.fromRGB(150, 160, 190)
    fpsIcon.TextXAlignment = Enum.TextXAlignment.Left
    fpsIcon.Parent = topRow

    local fpsVal = Instance.new("TextLabel")
    fpsVal.BackgroundTransparency = 1
    fpsVal.Position = UDim2.new(0, 34, 0, 0)
    fpsVal.Size = UDim2.new(1, -34, 1, 0)
    fpsVal.Font = Enum.Font.RobotoMono
    fpsVal.TextSize = 20
    fpsVal.Text = "60"
    fpsVal.TextColor3 = Color3.fromRGB(0, 255, 157)
    fpsVal.TextXAlignment = Enum.TextXAlignment.Left
    fpsVal.Parent = topRow

    -- Subtle bar under the FPS number
    local fpsBarBg = Instance.new("Frame")
    fpsBarBg.Name = "FpsBarBg"
    fpsBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    fpsBarBg.BackgroundTransparency = 0.3
    fpsBarBg.BorderSizePixel = 0
    fpsBarBg.Position = UDim2.new(0, 34, 1, -3)
    fpsBarBg.Size = UDim2.new(1, -34, 0, 3)
    fpsBarBg.Parent = topRow
    local fbbc = Instance.new("UICorner")
    fbbc.CornerRadius = UDim.new(1, 0)
    fbbc.Parent = fpsBarBg

    local fpsBar = Instance.new("Frame")
    fpsBar.Name = "FpsBar"
    fpsBar.BackgroundColor3 = Color3.fromRGB(0, 255, 157)
    fpsBar.BorderSizePixel = 0
    fpsBar.Size = UDim2.new(1, 0, 1, 0)
    fpsBar.Parent = fpsBarBg
    local fbc = Instance.new("UICorner")
    fbc.CornerRadius = UDim.new(1, 0)
    fbc.Parent = fpsBar
    local fbg = Instance.new("UIGradient")
    fbg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 157)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
    })
    fbg.Parent = fpsBar

    -- Bottom row: Ping
    local botRow = Instance.new("Frame")
    botRow.BackgroundTransparency = 1
    botRow.Position = UDim2.new(0, 0, 1, -26)
    botRow.Size = UDim2.new(1, 0, 0, 26)
    botRow.Parent = inner

    local pingIcon = Instance.new("TextLabel")
    pingIcon.BackgroundTransparency = 1
    pingIcon.Size = UDim2.new(0, 30, 1, 0)
    pingIcon.Font = Enum.Font.GothamBold
    pingIcon.TextSize = 10
    pingIcon.Text = "PING"
    pingIcon.TextColor3 = Color3.fromRGB(160, 170, 200)
    pingIcon.TextXAlignment = Enum.TextXAlignment.Left
    pingIcon.Parent = botRow

    local pingVal = Instance.new("TextLabel")
    pingVal.BackgroundTransparency = 1
    pingVal.Position = UDim2.new(0, 34, 0, 0)
    pingVal.Size = UDim2.new(1, -34, 1, 0)
    pingVal.Font = Enum.Font.RobotoMono
    pingVal.TextSize = 20
    pingVal.Text = "0ms"
    pingVal.TextColor3 = Color3.fromRGB(0, 200, 255)
    pingVal.TextXAlignment = Enum.TextXAlignment.Left
    pingVal.Parent = botRow

    local pingBarBg = Instance.new("Frame")
    pingBarBg.Name = "PingBarBg"
    pingBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    pingBarBg.BackgroundTransparency = 0.3
    pingBarBg.BorderSizePixel = 0
    pingBarBg.Position = UDim2.new(0, 34, 1, -3)
    pingBarBg.Size = UDim2.new(1, -34, 0, 3)
    pingBarBg.Parent = botRow
    local pbbc = Instance.new("UICorner")
    pbbc.CornerRadius = UDim.new(1, 0)
    pbbc.Parent = pingBarBg

    local pingBar = Instance.new("Frame")
    pingBar.Name = "PingBar"
    pingBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    pingBar.BorderSizePixel = 0
    pingBar.Size = UDim2.new(1, 0, 1, 0)
    pingBar.Parent = pingBarBg
    local pbc = Instance.new("UICorner")
    pbc.CornerRadius = UDim.new(1, 0)
    pbc.Parent = pingBar
    local pbg = Instance.new("UIGradient")
    pbg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 100, 255)),
    })
    pbg.Parent = pingBar

    -- Animated border rotation
    local gradRot = 0
    RunSvc.RenderStepped:Connect(function(dt)
        gradRot = (gradRot + dt * 30) % 360
        pg.Rotation = gradRot
    end)

    local fpsSmooth, frames, lastT, lastPing = 60, 0, tick(), 0
    RunSvc.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - lastT >= 0.5 then
            local raw = frames / (now - lastT)
            fpsSmooth = fpsSmooth * 0.7 + raw * 0.3
            frames = 0
            lastT = now
            local fpsColor
            if fpsSmooth >= 50 then fpsColor = Color3.fromRGB(0, 255, 157)
            elseif fpsSmooth >= 30 then fpsColor = Color3.fromRGB(255, 200, 60)
            else fpsColor = Color3.fromRGB(255, 80, 100) end
            fpsVal.Text = string.format("%.0f", fpsSmooth)
            fpsVal.TextColor3 = fpsColor
            fpsBar.BackgroundColor3 = fpsColor
            local pct = math.clamp(fpsSmooth / 60, 0, 1)
            fpsBar.Size = UDim2.new(pct, 0, 1, 0)
        end
    end)
    task.spawn(function()
        while true do
            task.wait(1)
            local ok, val = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            if ok and type(val) == "number" then
                lastPing = val
            end
            local pingColor
            if lastPing <= 100 then pingColor = Color3.fromRGB(0, 200, 255)
            elseif lastPing <= 200 then pingColor = Color3.fromRGB(255, 200, 60)
            else pingColor = Color3.fromRGB(255, 80, 100) end
            pingVal.Text = string.format("%dms", lastPing)
            pingVal.TextColor3 = pingColor
            pingBar.BackgroundColor3 = pingColor
            local pct = 1 - math.clamp(lastPing / 300, 0, 1)
            pingBar.Size = UDim2.new(pct, 0, 1, 0)
        end
    end)
end

print("[AMBUSH HUB] WindUI loaded")
print("[AMBUSH HUB] WindUI loaded")

-- Script icon next to the title (image asset 86208808843462)
task.spawn(function()
    task.wait(0.5)
    local sgui = WindUI and WindUI.ScreenGui
    if not sgui then return end
    local win = sgui:FindFirstChild("Window")
    if not win then return end
    local topbar = win:FindFirstChild("TopBar") or win:FindFirstChild("Header")
    if not topbar then return end
    local title = topbar:FindFirstChild("Title") or topbar:FindFirstChild("TitleDisplay")
    -- remove any previous icon so we don't stack duplicates on re-execute
    local existing = topbar:FindFirstChild("AmbushHubIcon")
    if existing then existing:Destroy() end
    local icon = Instance.new("ImageLabel")
    icon.Name = "AmbushHubIcon"
    icon.Image = "rbxassetid://86208808843462"
    icon.Size = UDim2.new(0, 26, 0, 26)
    icon.Position = UDim2.new(0, 10, 0.5, -13)
    icon.BackgroundTransparency = 1
    icon.Parent = topbar
    if title then
        title.Position = UDim2.new(0, 44, 0.5, 0)
        title.AnchorPoint = Vector2.new(0, 0.5)
    end
end)
print("[AMBUSH HUB] Loading Info Tab")
InfoTab:Section({ Title = "User Info" })

local avatarUrl = string.format(
    "rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150",
    LocalPlayer.UserId
)

InfoTab:Paragraph({
    Title = "User Profile",
    Desc = string.format(
        "Username: %s\nDisplay Name: %s\nUser ID: %d\nExecutor: %s\nExecutions: %d",
        LocalPlayer.Name,
        LocalPlayer.DisplayName,
        LocalPlayer.UserId,
        currentExecutor,
        executionCount
    ),
    Image = avatarUrl,
    ImageSize = 48
})

InfoTab:Section({ Title = "Current Session" })
local sessionPara = InfoTab:Paragraph({ Title = "Session", Desc = "Reading game data..." })
task.spawn(function()
    local RunSvc = game:GetService("RunService")
    local frames, last = 0, os.clock()
    RunSvc.RenderStepped:Connect(function() frames = frames + 1 end)
    local started = os.clock()
    while true do
        task.wait(1)
        local now = os.clock()
        local fps = math.floor(frames / math.max(now - last, 0.001) + 0.5)
        frames, last = 0, now
        local floorName, room, ping, playersN = "Lobby", "-", "?", #game:GetService("Players"):GetPlayers()
        pcall(function()
            local gd = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
            local f = gd and gd:FindFirstChild("Floor")
            if f then floorName = tostring(f.Value) end
        end)
        pcall(function() room = tostring(LocalPlayer:GetAttribute("CurrentRoom") or "-") end)
        pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms" end)
        local mins = math.floor((now - started) / 60)
        local txt = string.format(
            "Floor: %s\nCurrent room: %s\nPlayers: %d\nFPS: %d\nPing: %s\nTime with script: %d min",
            floorName, room, playersN, fps, ping, mins
        )
        pcall(function() sessionPara:SetDesc(txt) end)
    end
end)

InfoTab:Section({ Title = "Script Info" })

InfoTab:Paragraph({
    Title = "About Ambush Hub",
    Desc = "A specialized script for DOORS by void script team.\nCreators: VANTA & void.\nCreated: 2026-10-20.\nVersion: 1.0.5 (Ambush Hub)"
})

InfoTab:Paragraph({
    Title = "Where everything is",
    Desc = "Visuals: ESP, chase paths (Seek / Eyestalk) and lighting.\n"
        .. "Player: movement, speed, jump, fly, noclip.\n"
        .. "Automation: Auto Doors bot, Auto Interact (with ignore list), library code, minecart, Dam Seek, Cringle. Stairwell and Archives tabs.\n"
        .. "Anticheat: position / crouch spoof (strong spoof), ladder safe mode and manipulation.\n"
        .. "Antis: entity bypass and Seek / Figure combos.\n"
        .. "Alerts: notifications for entities, items, library code and Ransom.\n"
        .. "Misc: revive and utilities.\n"
        .. "Fun: turn into Seek, Honcho or Figure (only you see it).\n"
        .. "Keybinds: every key and floating button can be remapped.\n"
        .. "Configs: save and load your settings."
})

InfoTab:Paragraph({
    Title = "Good to know",
    Desc = "Features marked experimental may not work on some floors: check the console if something is unresponsive.\n"
        .. "On mobile, floating buttons can be shown / hidden in the Keybinds tab.\n"
        .. "Switching mode mid-run re-configures the script and adds new options at the bottom of Visuals."
})

print("[AMBUSH HUB] Info tab loaded")
print("[AMBUSH HUB] Loading ESP")
print("[AMBUSH HUB] Loading Item ESP (0/4)")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ITEM_NAMES = {
    "Alarm Clock", "Aloe", "Bandage", "Bandage Pack", "Battery", "Battery Pack", "Boxing Gloves", "Buddy", "Bulklight",
    "Bread", "Candle", "Candy", "Trick or Treat Bag", "Compass", "Crucifix", "Disc", "Donut", "Fih Flakes", "Flare", "Flashlight", "Glowstick",
    "Gold Gun", "Green Herb", "Gween Soda", "Holy Hand Grenade", "Honcho Mug", "Mug", "Lunch Box", "Waiting Ticket", "Paper Cup", "Fih Food", "Pack of Gween Soda", "Honey Pot", "Iron Key",
    "Knockback Stick", "Lantern", "Laser Pointer", "Leftovers", "Lighter", "Lockpicks", "Lotus",
    "Moonlight Candle", "Moonlight Float", "Multitool", "NVCS-3000", "Paper Plane",
    "Pizza", "Pocket Mirror", "Rift Jar", "Shakelight", "Shears", "Skeleton Key", "Smoothie", "Spotlight",
    "Starlight Bottle", "Starlight Jug", "Starlight Vial", "Straplight", "Tip Jar", "Vitamins",
    "Big Bomb", "Bomb", "Cheese", "Knockbomb", "Nanner", "Nanner Peel", "Rift Candle", "Rift Smoothie",
    "Snake Box", "Stop Sign",
    "Fuel Can", "Broken Monitor", "Broken Lamp", "Bottle Crate", "Coin Roll", "Peach Cobbler", "Briefcase", "Scanner", "Large Screw",
    "Abraham's Hat",
}

local function Norm(s)
    return (tostring(s):lower():gsub("[^%w]", ""))
end

local ITEM_LOOKUP = {}
for _, name in ipairs(ITEM_NAMES) do
    ITEM_LOOKUP[Norm(name)] = name
end
ITEM_LOOKUP["bandage"] = "Bandage"
ITEM_LOOKUP["bandages"] = "Bandage"
ITEM_LOOKUP["lockpick"] = "Lockpicks"
ITEM_LOOKUP["vitamin"] = "Vitamins"
ITEM_LOOKUP["holygrenade"] = "Holy Hand Grenade"
ITEM_LOOKUP["bandagepack"] = "Bandage Pack"
ITEM_LOOKUP["glowsticks"] = "Glowstick"
ITEM_LOOKUP["straplights"] = "Straplight"
ITEM_LOOKUP["bulklights"] = "Bulklight"
ITEM_LOOKUP["crucifixwall"] = "Crucifix"
ITEM_LOOKUP["treatbag"] = "Trick or Treat Bag"
ITEM_LOOKUP["candybag"] = "Trick or Treat Bag"
ITEM_LOOKUP["trickortreat"] = "Trick or Treat Bag"

ITEM_LOOKUP["glitchfragment"] = "Glitch Fragment"
ITEM_LOOKUP["glitchcube"] = "Glitch Fragment"
ITEM_LOOKUP["lotuspetal"] = "Lotus Petal"
ITEM_LOOKUP["scannermodule"] = "Scanner Module"
ITEM_LOOKUP["modulescanner"] = "Scanner Module"
do
    local PENDING_DEX_NAMES = {
        ScannerModule = "Drive",
        AbrahamHat = "AbrahamHat",
    }
    if PENDING_DEX_NAMES.ScannerModule ~= "" then ITEM_LOOKUP[Norm(PENDING_DEX_NAMES.ScannerModule)] = "Scanner Module" end
    if PENDING_DEX_NAMES.AbrahamHat ~= "" then ITEM_LOOKUP[Norm(PENDING_DEX_NAMES.AbrahamHat)] = "Abraham's Hat" end
end
local SPECIAL_CATS = { ["Glitch Fragment"] = "glitch", ["Lotus Petal"] = "lotus", ["Scanner Module"] = "scanner", ["Stardust"] = "stardust" }
ITEM_LOOKUP["batterypack"] = "Battery Pack"
ITEM_LOOKUP["jerrycan"] = "Fuel Can"
ITEM_LOOKUP["dinkylamp"] = "Broken Lamp"
ITEM_LOOKUP["objectscanner"] = "Scanner"
ITEM_LOOKUP["gweensodapack"] = "Pack of Gween Soda"
ITEM_LOOKUP["stardustpickup"] = "Stardust"

local INTERNAL_ALIASES = {
    AlarmClock = "Alarm Clock", AloeVera = "Aloe", BandagePack = "Bandage Pack", BatteryPack = "Battery Pack",
    BigBomb = "Big Bomb", Bomb = "Bomb", BoxingGloves = "Boxing Gloves", Bread = "Bread", Bulklight = "Bulklight",
    Candle = "Candle", Cheese = "Cheese", Compass = "Compass", Crucifix = "Crucifix", Donut = "Donut",
    Flashlight = "Flashlight", Glowsticks = "Glowstick", GoldGun = "Gold Gun", GoldBlaster = "Gold Gun",
    GweenSoda = "Gween Soda", GweenSodaPack = "Pack of Gween Soda", HolyGrenade = "Holy Hand Grenade", KnockbackStick = "Knockback Stick",
    Knockbomb = "Knockbomb", Lantern = "Lantern", LaserPointer = "Laser Pointer", Lighter = "Lighter",
    Lockpick = "Lockpicks", Multitool = "Multitool", Nanner = "Nanner", NannerPeel = "Nanner Peel",
    Pizza = "Pizza", PocketMirror = "Pocket Mirror", RiftCandle = "Rift Candle", RiftJar = "Rift Jar",
    RiftSmoothie = "Rift Smoothie", Shakelight = "Shakelight", Shears = "Shears", SkeletonKey = "Skeleton Key",
    Smoothie = "Smoothie", SnakeBox = "Snake Box", StarBottle = "Starlight Bottle", StarJug = "Starlight Jug",
    StarVial = "Starlight Vial", StopSign = "Stop Sign", Straplight = "Straplight", TipJar = "Tip Jar",
    Vitamins = "Vitamins",
    JerryCan = "Fuel Can", BrokenMonitor = "Broken Monitor", DinkyLamp = "Broken Lamp", BottleCrate = "Bottle Crate",
    CoinRoll = "Coin Roll", PeachCobbler = "Peach Cobbler", Briefcase = "Briefcase", ObjectScanner = "Scanner",
    LargeScrew = "Large Screw",
}
for k, v in pairs(INTERNAL_ALIASES) do ITEM_LOOKUP[Norm(k)] = v end

local function ResolveItem(candidates)
    for _, cand in ipairs(candidates) do
        if type(cand) == "string" and cand ~= "" then
            local n = Norm(cand)
            if ITEM_LOOKUP[n] then return ITEM_LOOKUP[n] end
        end
    end
    for _, cand in ipairs(candidates) do
        if type(cand) == "string" and #cand >= 4 then
            local n = Norm(cand)
            local best, bestLen
            for k, name in pairs(ITEM_LOOKUP) do
                if #k >= 6 and n:find(k, 1, true) then
                    if not bestLen or #k > bestLen then best, bestLen = name, #k end
                end
            end
            if best then return best end
        end
    end
end

local KEY_NAMES = {
    KeyObtain = "Key",
    ElectricalKeyObtain = "Electrical Room Key",
    FuseObtain = "Fuse",
}
local OBJECTIVE_NAMES = {
    LeverForGate = "Lever",
    TimerLever = "Timer Lever",
    LiveHintBook = "Library Book",
    LiveBreakerPolePickup = "Breaker Pole",
    StairwellFireAlarm = "Fire Alarm Lever",
    ["Sally's Toy"] = "Sally's Toy",
    SallysToy = "Sally's Toy",
    SallyToy = "Sally's Toy",
    WaterPump = "Water Pump",
}
local STARDUST_NAMES = { Stardust = "Stardust", StardustPickup = "Stardust" }

print("[AMBUSH HUB] Item ESP loaded (1/4)")
print("[AMBUSH HUB] Loading Entity ESP (1/4)")
local ENTITY_DEFS = {
    { "Rush", "*", { "rushmoving", "rush" } },
    { "Ambush", "*", { "ambushmoving", "ambush" } },
    { "Eyes", "*", { "eyes" } },
    { "Halt", "*", { "halt" } },
    { "Jeff", "*", { "jeffthekiller", "jeff" } },
    { "Jeff the Killer", "*", { "jeffthekiller" } },
    { "Snare", "*", { "snare" } },
    { "Glitch", "*", {} },
    { "Glitched Rush", "*", {} },
    { "Glitched Ambush", "*", {} },
    { "Seek", "Hotel Mines", { "seekmoving", "seekrig", "seek" } },
    { "Figure", "Hotel Mines", { "figureragdoll", "figurerig", "figure" } },
    { "Timothy", "Hotel Mines", { "timothy" } },
    { "Void", "Hotel Mines", { "void" } },
    { "Bob", "Hotel Mines", { "bob" } },
    { "El Goblino", "Hotel Mines", { "elgoblino", "goblino" } },
    { "Dread", "Hotel Mines", { "dread" } },
    { "Grumble", "Mines", { "grumble" } },
    { "Queen Grumble", "Mines", { "queengrumble" } },
    { "Giggle", "Hotel Mines", { "giggle" } },
    { "Gloombat", "Hotel Mines", { "gloombat" } },
    { "Firedamp", "Hotel Mines", { "firedamp" } },
    { "Blitz", "Hotel Mines Backdoor", { "backdoorrush", "blitz" } },
    { "Lookman", "Hotel Mines Backdoor", { "backdoorlookman", "lookman" } },
    { "Haste", "Hotel Backdoor", { "haste" } },
    { "Groundskeeper", "Outdoors", { "groundskeeper", "thegroundskeeper" } },
    { "Caw", "Outdoors", { "caw" } },
    { "Monument", "Outdoors", { "monument" } },
    { "Surge", "Outdoors", { "surge" } },
    { "Mandrake", "Outdoors", { "mandrake" } },
    { "Eyestalk", "Outdoors", { "eyestalk" } },
    { "Bramble", "Outdoors", { "bramble" } },
    { "Grampy", "Outdoors", { "grampy" } },
    { "World Lotus", "Outdoors", { "worldlotus", "theworldlotus" } },
    { "Honcho", "Archives", { "honcho" } },
    { "Drone", "Archives", { "drone" } },
    { "Forget-Me-Nots", "Archives", { "forgetmenot", "forgetmenots" } },
    { "Teller", "Archives", { "teller" } },
    { "Alma", "Archives", { "alma" } },
    { "Portrait", "Archives", { "portrait" } },
    { "A-60", "Archives", { "a60", "bash", "bashmoving", "bashrig", "bashmodel", "bashentity" } },
    { "A-120", "Archives", { "a120", "scribbles" } },
    { "Discoloration", "Archives", { "discoloration" } },
    { "Currents", "Archives", { "currents" } },
    { "Creak", "Stairwell", { "creak" } },
    { "Noise", "*", { "noisemodel", "noise" } },
    { "Noise TV", "*", { "tvstand" } },
    { "Stem", "Stairwell", { "stem", "stemmoving", "stemrig", "stemmodel", "stementity", "stemsentity", "stems" } },
    { "Meld", "Stairwell", { "meld" } },
    { "Cobbler", "Stairwell", { "cobbler" } },
    { "Hijack", "Stairwell", { "hijack" } },
    { "Crusher", "Stairwell", { "crusher" } },
}

local ENTITY_LIST, ENTITY_MODES, ENTITY_TOKENS = {}, {}, {}
for _, d in ipairs(ENTITY_DEFS) do
    ENTITY_LIST[#ENTITY_LIST + 1] = d[1]
    local set = {}
    for m in d[2]:gmatch("%S+") do set[m] = true end
    ENTITY_MODES[d[1]] = set
    for _, tok in ipairs(d[3]) do ENTITY_TOKENS[#ENTITY_TOKENS + 1] = { tok, d[1] } end
end
table.sort(ENTITY_TOKENS, function(a, b) return #a[1] > #b[1] end)

local STRICT_SKIP = {
    portrait = true, monument = true, currents = true, bob = true, jack = true,
    void = true, dupe = true, jeff = true, timothy = true, eyes = true,
}

local GLITCH_TOKENS = {
    { "RNIUSHCg",  "Glitched Rush" },
    { "AR0xMBUSH", "Glitched Ambush" },
}

local ENTITY_EXACT = {
    RushMoving = "Rush", AmbushMoving = "Ambush", BackdoorRush = "Blitz", BackdoorLookman = "Lookman",
    Lookman = "Lookman", Eyes = "Eyes", Halt = "Halt",
    JeffTheKiller = "Jeff", A60 = "A-60", A120 = "A-120", Bash = "A-60", Scribbles = "A-120", Snare = "Snare",
}

local EXCLUDED_EXACT = { jack = true, ransom = true, a90 = true, shadow = true, screech = true }
local function IsExcludedEntity(name)
    local n = Norm(name)
    if EXCLUDED_EXACT[n] then return true end
    if n:find("screech", 1, true) or n:find("ransom", 1, true) then return true end
    if n:find("shadow", 1, true) then return true end
    return name:find("SCJVEREECH", 1, true) ~= nil
end

STRICT_SKIP.__stem = {
    stem = true, stems = true, stemsentity = true, stemmoving = true, stemrig = true, stemmodel = true, stementity = true, stemragdoll = true,
    stemmonster = true, stemchase = true, stemmover = true, stemclient = true, stemfake = true, stemreal = true,
}
local function EntityLabel(name, strict, allowSkip)
    if IsExcludedEntity(name) then return nil end
    if ENTITY_EXACT[name] then return ENTITY_EXACT[name] end
    for _, g in ipairs(GLITCH_TOKENS) do
        if name:find(g[1], 1, true) then return g[2] end
    end
    local n = Norm(name)
    if not strict and n:sub(1, 6) == "glitch" and not n:find("fragment", 1, true) then
        if n:find("ambush", 1, true) then return "Glitched Ambush" end
        if n:find("rush", 1, true) then return "Glitched Rush" end
        return nil
    end
    if STRICT_SKIP.__stem[n] and (allowSkip or not strict) then return "Stem" end
    local nb = n
    for _, suf in ipairs({ "moving", "model", "entity", "rig" }) do
        if #nb > #suf and nb:sub(-#suf) == suf then nb = nb:sub(1, #nb - #suf) break end
    end
    for _, t in ipairs(ENTITY_TOKENS) do
        local tok = t[1]
        if strict then
            if n == tok and (allowSkip or not STRICT_SKIP[tok]) then return t[2] end
        elseif #tok <= 4 then
            if n == tok or nb == tok then return t[2] end
        elseif n:sub(1, #tok) == tok then
            return t[2]
        end
    end
end

print("[AMBUSH HUB] Loaded Entity ESP (2/4)")
print("[AMBUSH HUB] Loading Entity Name Cache (2/4)")
do
    local rawNorm, rawExcl, rawLabel = Norm, IsExcludedEntity, EntityLabel
    local normC, normN = {}, 0
    Norm = function(x)
        if type(x) ~= "string" then return rawNorm(x) end
        local v = normC[x]
        if v == nil then
            if normN > 8000 then normC, normN = {}, 0 end
            v = rawNorm(x)
            normC[x] = v
            normN = normN + 1
        end
        return v
    end
    local exC, exN = {}, 0
    IsExcludedEntity = function(name)
        local v = exC[name]
        if v == nil then
            if exN > 8000 then exC, exN = {}, 0 end
            v = rawExcl(name) and true or false
            exC[name] = v
            exN = exN + 1
        end
        return v
    end
    local lbC, lbN = { {}, {}, {}, {} }, 0
    EntityLabel = function(name, strict, allowSkip)
        local c = lbC[(strict and 1 or 0) + (allowSkip and 2 or 0) + 1]
        local v = c[name]
        if v == nil then
            if lbN > 8000 then lbC, lbN = { {}, {}, {}, {} }, 0; c = lbC[(strict and 1 or 0) + (allowSkip and 2 or 0) + 1] end
            v = rawLabel(name, strict, allowSkip) or false
            c[name] = v
            lbN = lbN + 1
        end
        return v or nil
    end
end

print("[AMBUSH HUB] Loaded Entity Name Cache (3/4)")
print("[AMBUSH HUB] Loading ESP Config (3/4)")
local GOLD_NAMES = { GoldPile = "Gold" }
local HIDE_NAMES = { Wardrobe = "Closet", Bed = "Bed", Toolshed = "Tool Shed", Locker = "Locker" }

local MAX_HIGHLIGHTS = 26

local Cfg = {
    MaxDistance = 400,
    MaxObjects = 70,
    TextSize = 22,
    Font = "Oswald",
    PlayerNames = "Display Name",
    ShowName = true,
    ShowDistance = true,
    Unit = "Meters",
    FillTransparency = 0.75,
    OutlineTransparency = 0,
    TracerOrigin = "Bottom",
    TracerThickness = 1.5,
    UnlistedItems = true,
    ItemFilter = {},
    UnlistedEntities = false,
    EntityFilter = {},
    Debug = false,
    DebugVerbose = false,
    Overlay = false,
    HideLooted = true,
    AutoPreset = false,
    RoomEntities = true,
    Categories = {
        doors      = { Enabled = false, Color = Color3.fromHex("#00eaff") },
        gold       = { Enabled = false, Color = Color3.fromHex("#ffe400") },
        keys       = { Enabled = false, Color = Color3.fromHex("#12ff00") },
        wardrobes  = { Enabled = false, Color = Color3.fromHex("#007000") },
        chests     = { Enabled = false, Color = Color3.fromHex("#ffe400") },
        items      = { Enabled = false, Color = Color3.fromHex("#fc00ff") },
        objectives = { Enabled = false, Color = Color3.fromHex("#12ff00") },
        stardust   = { Enabled = false, Color = Color3.fromHex("#ff7800") },
        entities   = { Enabled = false, Color = Color3.fromHex("#ff0000") },
        dupe       = { Enabled = false, Color = Color3.fromHex("#ff0000") },
        drawers    = { Enabled = false, Color = Color3.fromHex("#d9a066") },
        lockers    = { Enabled = false, Color = Color3.fromHex("#8fa8ff") },
        interactables = { Enabled = false, Color = Color3.fromHex("#7fffd4") },
        glitch     = { Enabled = false, Color = Color3.fromHex("#8100a6") },
        lotus      = { Enabled = false, Color = Color3.fromHex("#ff6ff7") },
        scanner    = { Enabled = false, Color = Color3.fromHex("#a145ff") },
        stairs     = { Enabled = false, Color = Color3.fromHex("#ff5fa2") },
        exit       = { Enabled = false, Color = Color3.fromHex("#93ff85") },
        cart       = { Enabled = false, Color = Color3.fromHex("#6d77ff") },
        players    = { Enabled = false, Color = Color3.fromHex("#3b82f6") },
    }
}

print("[AMBUSH HUB] Loaded ESP Config (4/4)")
print("[AMBUSH HUB] Fully Loaded ESP")
print("[AMBUSH HUB] Loading Tracers")
for _, c in pairs(Cfg.Categories) do c.Tracer = false end

print("[AMBUSH HUB] Loaded Tracers")
print("[AMBUSH HUB] Loading ESP Fonts")
local FONT_LIST = { "Oswald", "Roboto Sans", "Nunito", "Gotham Bold", "Ubuntu", "Source Sans", "Code" }
local FONT_MAP = {
    ["Oswald"] = Enum.Font.Oswald,
    ["Roboto Sans"] = Enum.Font.Roboto,
    ["Nunito"] = Enum.Font.Nunito,
    ["Gotham Bold"] = Enum.Font.GothamBold,
    ["Ubuntu"] = Enum.Font.Ubuntu,
    ["Source Sans"] = Enum.Font.SourceSansBold,
    ["Code"] = Enum.Font.Code,
}

for _, name in ipairs(ITEM_NAMES) do
    Cfg.ItemFilter[name] = true
end
for _, name in ipairs(ENTITY_LIST) do
    Cfg.EntityFilter[name] = true
end

print("[AMBUSH HUB] Loaded ESP Fonts")
print("[AMBUSH HUB] Loading Debug Logger")
local DebugLog, DebugSeen = {}, {}
local function Dbg(kind, inst, extra)
    if not Cfg.Debug then return end
    local key = kind .. ":" .. inst.Name
    if DebugSeen[key] then return end
    DebugSeen[key] = true
    local okName, full = pcall(function() return inst:GetFullName() end)
    local line = string.format("[%s] %s | %s%s", kind, inst.Name, okName and full or "?", extra and (" | " .. extra) or "")
    DebugLog[#DebugLog + 1] = line
    print("[AMBUSH HUB DEBUG] " .. line)
end

print("[AMBUSH HUB] Loaded Debug Logger")
print("[AMBUSH HUB] Loading Render Containers")
local Gui = Instance.new("ScreenGui")
Gui.Name = "RON_ESP_Lines"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999

local Holder = Instance.new("Folder")
Holder.Name = "RON_ESP"

local okParent = pcall(function()
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    Gui.Parent = parent
    Holder.Parent = parent
end)
if not okParent then
    Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    Holder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Tracked = {}

print("[AMBUSH HUB] Loaded Render Containers")
print("[AMBUSH HUB] Loading Gamemodes")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Setters = {}
local Mode = { Name = "Unknown", Raw = "" }
local ModeParagraph

local MODE_CATS = {
    Hotel     = { "doors", "dupe", "gold", "keys", "wardrobes", "chests", "objectives", "stardust", "entities", "items", "drawers", "glitch" },
    Mines     = { "doors", "gold", "keys", "wardrobes", "chests", "objectives", "stardust", "entities", "items", "drawers", "lockers", "glitch" },
    Backdoor  = { "doors", "objectives", "stardust", "entities", "items", "drawers", "glitch" },
    Outdoors  = { "doors", "gold", "keys", "stardust", "entities", "items", "glitch", "lotus", "stardust", "interactables" },
    Archives  = { "doors", "stardust", "entities", "items", "drawers", "interactables", "glitch" },
    Stairwell = { "doors", "stardust", "entities", "items", "interactables", "glitch", "objectives", "exit", "cart" },
    Rooms     = { "doors", "stardust", "entities", "items", "wardrobes", "lockers", "glitch" },
    Lobby     = {},
    Unknown   = { "doors", "gold", "keys", "wardrobes", "chests", "objectives", "entities", "items", "drawers", "lockers" },
}
MODE_CATS.Fools = MODE_CATS.Hotel
do
    local seen = {}
    for _, list in pairs(MODE_CATS) do
        if not seen[list] then
            seen[list] = true
            list[#list + 1] = "players"
            if list ~= MODE_CATS.Lobby then list[#list + 1] = "scanner" end
        end
    end
    MODE_CATS.Mines[#MODE_CATS.Mines + 1] = "stairs"
end
do
    local all = {}
    for id in pairs(Cfg.Categories) do all[#all + 1] = id end
    table.sort(all)
    MODE_CATS.Test = all
end
Mode.All = function() return Mode.Name == "Unknown" or Mode.Name == "Test" end

for _, n in ipairs({ "A-60", "A-120" }) do
    if ENTITY_MODES[n] then ENTITY_MODES[n]["Rooms"] = true end
end
local function EntityModeKey()
    return Mode.Name == "Fools" and "Hotel" or Mode.Name
end
local function CurrentEntityList()
    local out, key = {}, EntityModeKey()
    for _, d in ipairs(ENTITY_DEFS) do
        local set = ENTITY_MODES[d[1]]
        if Mode.All() or set["*"] or set[key] then out[#out + 1] = d[1] end
    end
    return out
end

local MODE_EXACT = {
    hotel = "Hotel", fools = "Fools", mines = "Mines", backdoor = "Backdoor", outdoors = "Outdoors",
    garden = "Outdoors", archives = "Archives", stairwell = "Stairwell", rooms = "Rooms",
}
local MODE_RULES = {
    { "backdoor", "Backdoor" }, { "stair", "Stairwell" }, { "archive", "Archives" },
    { "outdoor", "Outdoors" }, { "garden", "Outdoors" }, { "mine", "Mines" },
    { "hotel", "Hotel" }, { "fool", "Fools" },
}

local Active = {}
local Rescan, OnModeApplied, PurgeInactive, ApplyPreset

local function SetActive(modeName)
    local new = {}
    for _, id in ipairs(MODE_CATS[modeName] or MODE_CATS.Unknown) do new[id] = true end
    Active = new
end

local Force = { Name = "Auto" }

local LOBBY_PLACE_ID = 6516141723
local GAME_PLACE_ID = 6839171747
local function IsLobby()
    if game.PlaceId == LOBBY_PLACE_ID then return true end
    if game.PlaceId ~= GAME_PLACE_ID then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local mu = pg and pg:FindFirstChild("MainUI")
        if mu and mu:FindFirstChild("LobbyFrame") then return true end
    end
    return false
end

local function ReadModeRaw()
    local raw, strings = {}, {}
    local gd = ReplicatedStorage:FindFirstChild("GameData")
    if gd then
        for _, c in ipairs(gd:GetChildren()) do
            if c:IsA("ValueBase") then
                local ok, v = pcall(function() return c.Value end)
                if ok and v ~= nil and typeof(v) ~= "Instance" then
                    raw[#raw + 1] = c.Name .. "=" .. tostring(v)
                    if type(v) == "string" then strings[#strings + 1] = v:lower() end
                end
            end
        end
        for k, v in pairs(gd:GetAttributes()) do
            raw[#raw + 1] = k .. "=" .. tostring(v)
            if type(v) == "string" then strings[#strings + 1] = v:lower() end
        end
    end
    Mode.Raw = table.concat(raw, "; ")

    for _, s in ipairs(strings) do
        if MODE_EXACT[s] then return MODE_EXACT[s] end
    end
    local text = table.concat(strings, " ")
    for _, r in ipairs(MODE_RULES) do
        if text:find(r[1], 1, true) then return r[2] end
    end
    local rooms = Workspace:FindFirstChild("CurrentRooms")
    if rooms then
        for _, r in ipairs(rooms:GetChildren()) do
            if r.Name:match("^%a%-%d+$") then return "Archives" end
        end
    end
    return "Unknown"
end

local function ReadMode()
    local okR, name = pcall(ReadModeRaw)
    if Force.Name ~= "Auto" then return Force.Name end
    local okL, lobby = pcall(IsLobby)
    if okL and lobby then return "Lobby" end
    return okR and name or "Unknown"
end

local function WaitForMode(timeout)
    local t0 = os.clock()
    while true do
        local ok, name = pcall(ReadMode)
        if ok and name ~= "Unknown" then return name end
        if os.clock() - t0 >= timeout then return "Unknown" end
        task.wait(0.5)
    end
end

local function ApplyMode(name)
    Mode.Name = name
    SetActive(name)
    print("[AMBUSH HUB] Game mode: " .. name .. " (" .. Mode.Raw .. ")")
    if PurgeInactive then PurgeInactive() end
    if OnModeApplied then pcall(OnModeApplied) end
    if Cfg.AutoPreset and ApplyPreset then pcall(ApplyPreset, name) end
    if Rescan then Rescan() end
    local forced = Force.Name ~= "Auto"
    pcall(function()
        WindUI:Notify({ Title = "Game Mode", Content = (forced and "Forced: " or "Detected: ") .. name .. ". Only its ESP options are loaded.", Duration = 4 })
    end)
    if ModeParagraph then
        pcall(function() ModeParagraph:SetTitle((forced and "Forced: " or "Detected: ") .. name) end)
    end
end

local function WatchMode()
    local name = ReadMode()
    if name ~= Mode.Name and (name ~= "Unknown" or Force.Name == "Unknown") then ApplyMode(name) end
end

Mode.Name = WaitForMode(12)
SetActive(Mode.Name)
print("[AMBUSH HUB] Game mode: " .. Mode.Name .. " (" .. Mode.Raw .. ")")

local Overlay = Instance.new("TextLabel")
Overlay.Name = "RON_Overlay"
Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
Overlay.BackgroundTransparency = 0.45
Overlay.BorderSizePixel = 0
Overlay.TextColor3 = Color3.fromRGB(230, 230, 230)
Overlay.Font = Enum.Font.Code
Overlay.TextSize = 13
Overlay.TextXAlignment = Enum.TextXAlignment.Left
Overlay.TextYAlignment = Enum.TextYAlignment.Top
Overlay.TextWrapped = true
Overlay.Size = UDim2.fromOffset(300, 10)
Overlay.AutomaticSize = Enum.AutomaticSize.Y
Overlay.Position = UDim2.fromOffset(8, 70)
Overlay.Visible = false

Overlay.Parent = Gui

local function UpdateOverlay()
    Overlay.Visible = Cfg.Overlay
    if not Cfg.Overlay then return end
    local counts, total, shown = {}, 0, 0
    for _, e in pairs(Tracked) do
        counts[e.Cat] = (counts[e.Cat] or 0) + 1
        total = total + 1
        if e.Shown then shown = shown + 1 end
    end
    local list = {}
    for k, n in pairs(counts) do list[#list + 1] = k .. "=" .. n end
    table.sort(list)
    Overlay.Text = string.format(
        "RON DEBUG\nMode: %s\nRoom: %s\nTracked: %d (shown %d)\n%s\nGameData: %s",
        Mode.Name, tostring(LocalPlayer:GetAttribute("CurrentRoom")), total, shown,
        #list > 0 and table.concat(list, ", ") or "-", Mode.Raw ~= "" and Mode.Raw or "-"
    )
end
local function GetPart(inst)
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
    end
end

print("[AMBUSH HUB] Loaded Gamemodes")
print("[AMBUSH HUB] Loading Visual Instances")
Mode.Free = function(e)
    local hl, box, bb, line = e.HL, e.Box, e.BB, e.Line
    e.HL, e.Box, e.BB, e.TL, e.Line = nil, nil, nil, nil, nil
    e.Col, e.Fill, e.Out, e.Text, e.TS, e.TF, e.BoxT, e.HidSince = nil, nil, nil, nil, nil, nil, nil, nil
    if hl then pcall(hl.Destroy, hl) end
    if box then pcall(box.Destroy, box) end
    if bb then pcall(bb.Destroy, bb) end
    if line then pcall(line.Destroy, line) end
end

Mode.Build = function(e)
    if e.HL then return end
    local hl = Instance.new("Highlight")
    hl.Name = "R4N_ESP"
    hl.Adornee = e.Inst
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = Cfg.FillTransparency or 0.75
    hl.OutlineTransparency = Cfg.OutlineTransparency or 0
    hl.Enabled = false
    hl.Parent = Holder

    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = e.Part
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = e.Part.Size
    box.Visible = false
    box.Parent = Holder

    local bb = Instance.new("BillboardGui")
    bb.Adornee = e.Part
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(300, 80)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.LightInfluence = 0
    bb.ResetOnSpawn = false
    bb.Enabled = false
    bb.Parent = Holder

    local tl = Instance.new("TextLabel")
    tl.BackgroundTransparency = 1
    tl.Size = UDim2.fromScale(1, 1)
    tl.Font = FONT_MAP[Cfg.Font] or Enum.Font.Oswald
    tl.TextStrokeTransparency = 0.35
    tl.TextStrokeColor3 = Color3.new(0, 0, 0)
    tl.Parent = bb

    e.HL, e.Box, e.BB, e.TL = hl, box, bb, tl
end

local function RemoveEntry(inst)
    local e = Tracked[inst]
    if not e then return end
    Tracked[inst] = nil
    if e.Conn then pcall(e.Conn.Disconnect, e.Conn); e.Conn = nil end
    Mode.Free(e)
end

local function HideEntry(e)
    e.Shown = false
    if not e.HL and not e.Line then return end
    if e.HL then
        e.HL.Enabled = false
        e.Box.Visible = false
        e.BB.Enabled = false
    end
    if e.Line then e.Line.Visible = false end
    local now = os.clock()
    if not e.HidSince then
        e.HidSince = now
    elseif now - e.HidSince > 5 then
        Mode.Free(e)
    end
end

local OnEntitySeen
local ExtraSerialize, ExtraApply

local PRIORITY = {
    interactables = 1, doors = 2, drawers = 2, lockers = 2,
    items = 3, chests = 3, glitch = 4, scanner = 4, lotus = 3, stardust = 3,
    keys = 4, gold = 4, objectives = 4, wardrobes = 4,
    entities = 6, dupe = 6, players = 5, stairs = 1,
    exit = 4, cart = 4,
}

local Watch = { Limited = { Stem = true, Drone = true, Drones = true }, M = {}, Loop = false, Gold = setmetatable({}, { __mode = "k" }) }

local BURROW_WORDS = { "burrow", "hole", "den", "mound", "nest", "tunnel", "lair", "pit", "dirt", "hill", "spawn", "madriguera" }
function Watch.IsBurrowName(name)
    local n = name:lower()
    for _, w in ipairs(BURROW_WORDS) do
        if n:find(w, 1, true) then return true end
    end
    return false
end

function Watch.IsBurrow(inst)
    local p, i = inst, 0
    while p and p ~= Workspace and i < 5 do
        local n = p.Name:lower()
        if n:find("burrow", 1, true) or n:find("madriguera", 1, true) or n:find("mandrake", 1, true) then
            return true
        end
        p, i = p.Parent, i + 1
    end
    return false
end

function Watch.Run()
    if Watch.Loop then return end
    Watch.Loop = true
    task.spawn(function()
        while next(Watch.M) do
            task.wait(0.2)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            for inst, w in pairs(Watch.M) do
                if not inst.Parent then
                    Watch.M[inst] = nil
                elseif hrp then
                    local ok, pos = pcall(function()
                        return inst:IsA("Model") and inst:GetPivot().Position or inst.Position
                    end)
                    if ok and pos then
                        if not w.Start then
                            w.Start = pos
                        elseif (pos - w.Start).Magnitude > 3 and (pos - hrp.Position).Magnitude <= 50 then
                            Watch.M[inst] = nil
                            Watch.Promote(inst, w.Opts)
                        end
                    end
                end
            end
        end
        Watch.Loop = false
    end)
end

local function Register(inst, cat, label, opts)
    if not Active[cat] then return end

    if cat == "entities" and label == "Mandrake" and not (opts and opts.Direct) then
        if not Tracked[inst] and not Watch.M[inst] and not Watch.IsBurrowName(inst.Name) then
            Watch.M[inst] = { Opts = opts }
            Watch.Run()
        end
        return
    end

    local existing = Tracked[inst]
    if existing then
        if (PRIORITY[cat] or 3) > (PRIORITY[existing.Cat] or 3) then
            RemoveEntry(inst)
        else
            return
        end
    end
    local part = (opts and opts.Part) or GetPart(inst)
    if not part then return end

    local conn = inst.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveEntry(inst) end
    end)

    Tracked[inst] = {
        Inst = inst, Cat = cat, Label = label, Part = part, Conn = conn,
        Known = opts and opts.Known, Key = opts and opts.Key, Prompt = opts and opts.Prompt, GeoT = 0, NoGeo = false, RoomNum = opts and opts.RoomNum, Door = opts and opts.Door,
        Dist = 0, Shown = false,
    }

    if OnEntitySeen and (cat == "entities" or cat == "dupe") and opts and opts.Known then
        pcall(OnEntitySeen, opts.Key or label, inst)
    end
    if cat == "items" and Watch.OnItem then
        pcall(Watch.OnItem, label, inst, opts and opts.Known, opts and opts.Key)
    end

    if Cfg.DebugVerbose then
        Dbg("REG:" .. cat, inst, "label=" .. tostring(label))
    end
end

function Watch.Promote(inst, opts)
    local o = {}
    for k, v in pairs(opts or {}) do o[k] = v end
    o.Direct = true
    Register(inst, "entities", "Mandrake", o)
end

function Watch.RegisterGold(target)
    if Tracked[target] or Watch.Gold[target] or Watch.IsBurrow(target) then return end
    Watch.Gold[target] = true
    task.spawn(function()
        for _ = 1, 15 do
            if not target.Parent then break end
            local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and GetPart(target) then
                local visible = false
                local list = target:IsA("BasePart") and { target } or target:GetDescendants()
                for _, d in ipairs(list) do
                    if d:IsA("BasePart") and d.Transparency < 0.95 then
                        visible = true
                        break
                    end
                end
                if visible and prompt.Enabled and prompt.MaxActivationDistance > 0 then
                    local value = target:GetAttribute("GoldValue")
                    Register(target, "gold", value and ("Gold [" .. value .. "]") or "Gold", { Prompt = prompt })
                end
                break
            end
            task.wait(0.3)
        end
        Watch.Gold[target] = nil
    end)
end

print("[AMBUSH HUB] Loaded Visual Instances")
print("[AMBUSH HUB] Loading Workspace Element Detection")
local CurrentRooms

local function HasTrackedAncestor(inst)
    local p = inst.Parent
    while p and p ~= CurrentRooms and p ~= Workspace do
        if Tracked[p] then return true end
        p = p.Parent
    end
    return false
end

local function RegisterWhenReady(inst, cat, label)
    Register(inst, cat, label)
    if Tracked[inst] or GetPart(inst) then return end
    task.spawn(function()
        for _ = 1, 30 do
            task.wait(0.2)
            if not inst.Parent or Tracked[inst] then return end
            if GetPart(inst) then
                Register(inst, cat, label)
                return
            end
        end
    end)
end

local function RegisterByName(target)
    local n = target.Name
    if KEY_NAMES[n] then
        Register(target, "keys", KEY_NAMES[n])
    elseif OBJECTIVE_NAMES[n] then
        RegisterWhenReady(target, "objectives", OBJECTIVE_NAMES[n])
    elseif STARDUST_NAMES[n] then
        Register(target, "stardust", STARDUST_NAMES[n])
    elseif GOLD_NAMES[n] then
        Watch.RegisterGold(target)
    else
        return false
    end
    return true
end

local STAIR_ASSETS = {
    ExitSignStairwell = { "exit", "Emergency Exit" },
    ShoppingCart = { "cart", "Shopping Cart" },
    StairwellScrapper = { "interactables", "Depot" },
}

local function InStairRoot(inst, allowMisc)
    if CurrentRooms and inst:IsDescendantOf(CurrentRooms) then return true end
    if allowMisc then
        local misc = Workspace:FindFirstChild("Misc")
        if misc and inst:IsDescendantOf(misc) then return true end
    end
    return false
end

local function StairOwner(inst)
    local p, i, found, cat, label = inst, 0, nil, nil, nil
    while p and p ~= Workspace and i < 10 do
        local def = STAIR_ASSETS[p.Name]
        if def and (p:IsA("Model") or p:IsA("BasePart")) and InStairRoot(p, p.Name == "ShoppingCart") then
            found, cat, label = p, def[1], def[2]
        end
        p, i = p.Parent, i + 1
    end
    return found, cat, label
end

local function RegisterCrusher(inst)
    local function try()
        if Tracked[inst] then return true end
        if GetPart(inst) then
            Register(inst, "entities", "Crusher", { Known = true, Key = "Crusher" })
            return true
        end
    end
    if try() then return end
    task.spawn(function()
        for _ = 1, 30 do
            task.wait(0.2)
            if not inst.Parent then return end
            if try() then return end
        end
    end)
end

local GENERIC_PARTS = { Handle = true, Hitbox = true, Base = true, Main = true, Part = true, Model = true }
local KNOWN_PROMPTS = {
    HidePrompt = true, ModulePrompt = true, HerbPrompt = true, ActivateEventPrompt = true,
    LootPrompt = true, UnlockPrompt = true, SkullPrompt = true, Prompt = true,
    HintPrompt = true, InteractPrompt = true,
}
local HIDE_EXACT = { Wardrobe = "Closet", Toolshed = "Tool Shed" }

local function HideLabel(name)
    if HIDE_NAMES[name] then return HIDE_NAMES[name] end
    local n = Norm(name)
    if n:find("wardrobe", 1, true) or n:find("closet", 1, true) then return "Closet" end
    if n:find("cupboard", 1, true) then return "Cupboard" end
    if n:find("locker", 1, true) then return "Locker" end
    if n:find("shed", 1, true) then return "Tool Shed" end
    if n:find("bed", 1, true) then return "Bed" end
    return (name:gsub("_", " "))
end
local CHEST_EXACT = { ChestBox = "Chest", ChestBoxLocked = "Locked Chest" }

local CONTAINER_WORDS = { "drawer", "dresser", "desk", "table", "cabinet", "shelf", "nightstand", "makeshift" }

local function ClassifyContainer(name)
    local n = Norm(name)
    if n:find("toolbox", 1, true) then return "lockers", "Toolbox" end
    if n:find("locker", 1, true) then
        if n:find("small", 1, true) or n:find("mini", 1, true) then return "lockers", "Small Locker" end
        return "lockers", "Item Locker"
    end
    for _, w in ipairs(CONTAINER_WORDS) do
        if n:find(w, 1, true) then
            return "drawers", (w == "makeshift") and "Makeshift Drawer" or "Drawer"
        end
    end
end

local function IsKnownObject(name)
    if KEY_NAMES[name] or OBJECTIVE_NAMES[name] or STARDUST_NAMES[name] or GOLD_NAMES[name] then return true end
    if Norm(name):find("sally", 1, true) then return true end
    return ResolveItem({ name }) ~= nil
end

local function IsContainerModel(m)
    if not m then return false end
    if ClassifyContainer(m.Name) then return true end
    local e = Tracked[m]
    return e ~= nil and (e.Cat == "drawers" or e.Cat == "lockers" or e.Cat == "chests" or e.Cat == "wardrobes")
end

local function ResolveTarget(prompt)
    local t = prompt.Parent
    if t and t:IsA("Attachment") then t = t.Parent end
    if not t then return nil end
    if IsKnownObject(t.Name) then return t end
    if t:IsA("BasePart") then
        local pm = t.Parent
        if pm and pm:IsA("Model") and pm.Parent ~= CurrentRooms and not IsContainerModel(pm) then t = pm end
    end
    while GENERIC_PARTS[t.Name] and t.Parent and t.Parent:IsA("Model") and t.Parent.Parent ~= CurrentRooms
        and not IsContainerModel(t.Parent) and not IsKnownObject(t.Name) do
        t = t.Parent
    end
    return t
end

local function CleanName(name)
    return (name:gsub("_", " "):gsub("(%l)(%u)", "%1 %2"))
end

local function ProcessContainerPrompt(prompt)
    local so, sc, sl = StairOwner(prompt)
    if so then
        if Active[sc] then RegisterWhenReady(so, sc, sl) end
        return
    end
    local t = ResolveTarget(prompt)
    if not t or t == Workspace then return end
    if Watch.IsBurrow(t) then return end
    if CurrentRooms and t.Parent == CurrentRooms and not OBJECTIVE_NAMES[t.Name] then return end
    if RegisterByName(t) then return end
    if HasTrackedAncestor(t) then return end

    local low = Norm(t.Name)
    if low == "door" or low == "lock" or low:find("dupe", 1, true) then return end
    if t:FindFirstChild("HidePrompt", true) then return end

    local cat, label = ClassifyContainer(t.Name)
    if cat then
        Register(t, cat, label, { Prompt = prompt })
    elseif prompt.Name == "LootPrompt" then
        Register(t, "drawers", CleanName(t.Name), { Prompt = prompt })
        Dbg("CONTAINER?", t, "LootPrompt mode=" .. Mode.Name)
    else
        Register(t, "interactables", CleanName(t.Name), { Prompt = prompt })
        Dbg("ACTIVATE?", t, "mode=" .. Mode.Name)
    end
end

local function Process(inst)
    if inst:IsA("ProximityPrompt") then
        local pn = inst.Name
        if pn == "HidePrompt" then
            if not Active.wardrobes then return end
            local m = inst:FindFirstAncestorWhichIsA("Model")
            if m and m ~= CurrentRooms and m.Parent ~= CurrentRooms then
                if not HIDE_NAMES[m.Name] then Dbg("HIDE?", m) end
                Register(m, "wardrobes", HideLabel(m.Name))
            end
        elseif pn == "ModulePrompt" or pn == "HerbPrompt" then
            if not (Active.items or Active.keys or Active.objectives or Active.gold
                or Active.stardust or Active.glitch or Active.lotus or Active.scanner) then return end
            local t = ResolveTarget(inst)
            if not t then return end
            if Watch.IsBurrow(t) or Watch.IsBurrow(inst) then return end
            if RegisterByName(t) then return end
            if Tracked[t] and not IsContainerModel(t) then return end

            local nn = Norm(t.Name)
            if nn:find("sally", 1, true) then
                RegisterWhenReady(t, "objectives", "Sally's Toy")
                return
            end

            local objText = inst.ObjectText
            local cands = { t.Name, t:GetAttribute("DisplayName"), objText }
            if pn == "HerbPrompt" then cands[#cands + 1] = "Green Herb" end
            local display = ResolveItem(cands)
            if not display then
                local blob = Norm(t.Name) .. "|" .. Norm(tostring(t:GetAttribute("DisplayName") or "")) .. "|" .. Norm(tostring(objText or ""))
                if blob:find("glitch", 1, true) then
                    display = "Glitch Fragment"
                elseif blob:find("stardust", 1, true) then
                    display = "Stardust"
                elseif blob:find("module", 1, true) and blob:find("scan", 1, true) then
                    display = "Scanner Module"
                end
            end
            if not display and Mode.Name == "Outdoors" then return end
            if Cfg.Debug then
                local byName, byText = ResolveItem({ t.Name }), ResolveItem({ objText })
                if byName and byText and byName ~= byText then
                    Dbg("ITEM-MISMATCH", t, "model=" .. byName .. " text=" .. byText)
                end
            end
            if not display then
                Dbg("ITEM?", t, "prompt=" .. pn .. " objectText=" .. tostring(objText))
            end
            local special = display and SPECIAL_CATS[display]
            if special then
                Register(t, special, display, { Known = true, Key = display })
            else
                Register(t, "items", display or CleanName(t.Name), { Known = display ~= nil, Key = display })
            end
        elseif pn == "ActivateEventPrompt" or pn == "LootPrompt" then
            if not (Active.drawers or Active.lockers or Active.interactables) then return end
            ProcessContainerPrompt(inst)
        elseif not KNOWN_PROMPTS[pn] then
            Dbg("PROMPT?", inst.Parent or inst, "prompt=" .. pn .. " mode=" .. Mode.Name)
        end
        return
    end

    if inst:IsA("Model") or inst:IsA("BasePart") then
        if inst.Name == "Crusher" then
            local pr = inst.Parent
            if Active.entities and pr and pr.Name == "StairwellCrusher" and CurrentRooms and inst:IsDescendantOf(CurrentRooms) then
                RegisterCrusher(inst)
                return
            end
        else
            local sd = STAIR_ASSETS[inst.Name]
            if sd and Active[sd[1]] then
                local owner = StairOwner(inst)
                if owner then RegisterWhenReady(owner, sd[1], sd[2]) end
                return
            end
        end
        if RegisterByName(inst) then return end
        if inst:IsA("Model") then
            local n = inst.Name
            local lab = (Active.entities and Cfg.RoomEntities and inst.Parent ~= Workspace) and EntityLabel(n, true) or nil
            if HIDE_EXACT[n] then
                Register(inst, "wardrobes", HIDE_EXACT[n])
            elseif lab and not HasTrackedAncestor(inst) then
                Register(inst, "entities", lab, { Known = true, Key = lab })
            else
                local cl = CHEST_EXACT[n]
                if type(cl) == "string" then
                    Register(inst, "chests", cl)
                else
                    if cl == nil then
                        local low = n:lower()
                        cl = false
                        if low:find("chest", 1, true) then
                            local label = "Chest"
                            if low:find("locked", 1, true) then label = "Locked Chest"
                            elseif low:find("vine", 1, true) then label = "Vine Chest" end
                            cl = { label }
                        end
                        CHEST_EXACT[n] = cl
                    end
                    if cl and not HasTrackedAncestor(inst) then Register(inst, "chests", cl[1]) end
                end
            end
        end
    end
end

local function RegisterDoor(room, door)
    if not door:IsA("Model") or door.Name ~= "Door" then return end
    local num = tonumber(room.Name)
    local label = "Door " .. (num and (num + 1) or room.Name)
    local panels = {}
    for _, c in ipairs(door:GetChildren()) do
        if c.Name == "Door" and c:IsA("BasePart") then panels[#panels + 1] = c end
    end
    if #panels == 2 then
        local hm = door:FindFirstChild("R4N_HighlightModel")
        if not hm then
            hm = Instance.new("Model")
            hm.Name = "R4N_HighlightModel"
            for _, p in ipairs(panels) do
                local hp = Instance.new("Part")
                hp.Name = "HighlightPart"
                hp.Transparency = 0.999
                hp.Size = p.Size
                hp.CFrame = p.CFrame
                hp.CanCollide, hp.CanQuery, hp.CanTouch, hp.CastShadow = false, false, false, false
                hp.Massless = true
                hp.Anchored = false
                hp.Parent = hm
                local w = Instance.new("WeldConstraint")
                w.Part0, w.Part1 = hp, p
                w.Parent = hp
            end
            hm.Parent = door
        end
        local first = hm:FindFirstChild("HighlightPart")
        if first then
            if Tracked[door] then RemoveEntry(door) end
            Register(hm, "doors", label, { Part = first, RoomNum = num, Door = door })
            return
        end
    end
    local leaf = door:FindFirstChild("Door")
    if leaf and leaf:IsA("BasePart") then
        local hp = door:FindFirstChild("HighlightPart")
        if not hp then
            hp = Instance.new("Part")
            hp.Name = "HighlightPart"
            hp.Transparency = 0.999
            hp.Size = leaf.Size
            hp.CFrame = leaf.CFrame
            hp.CanCollide, hp.CanQuery, hp.CanTouch, hp.CastShadow = false, false, false, false
            hp.Massless = true
            hp.Anchored = false
            local w = Instance.new("WeldConstraint")
            w.Part0, w.Part1 = hp, leaf
            w.Parent = hp
            hp.Parent = door
        end
        if Tracked[door] then RemoveEntry(door) end
        Register(hp, "doors", label, { Part = hp, RoomNum = num, Door = door })
        return
    end
    Register(door, "doors", label, {
        Part = door:FindFirstChild("Door") or GetPart(door),
        RoomNum = num, Door = door,
    })
end

local function ScanRoom(room)
    task.spawn(function()
        local found = room:WaitForChild("Door", 10)
        for _, c in ipairs(room:GetChildren()) do RegisterDoor(room, c) end
        if found and found.Parent == room then return end
        local conn
        conn = room.ChildAdded:Connect(function(c)
            RegisterDoor(room, c)
            if c.Name == "Door" and conn then conn:Disconnect() conn = nil end
        end)
        room.AncestryChanged:Once(function() if conn then conn:Disconnect() conn = nil end end)
    end)
end

PurgeInactive = function()
    for inst, e in pairs(Tracked) do
        if not Active[e.Cat] then RemoveEntry(inst) end
    end
end

local IGNORE = { CurrentRooms = true, Drops = true, Camera = true, Terrain = true }

local function IsDupeName(name)
    local l = name:lower()
    if l:find("dupl", 1, true) then return false end
    return l == "doorfake" or l == "fakedoor" or l:match("^dupe") ~= nil
end

local function RegisterEntityWhenReady(m, label, known)
    task.spawn(function()
        for _ = 1, 20 do
            if not m.Parent then return end
            if GetPart(m) then
                Register(m, "entities", label, { Known = known, Key = known and label or nil })
                return
            end
            task.wait(0.1)
        end
    end)
end

local function ProcessEntity(m, initial)
    if not Active.entities then return end
    if not m:IsA("Model") or Tracked[m] then return end
    if IGNORE[m.Name] or IsDupeName(m.Name) or IsExcludedEntity(m.Name) or Players:GetPlayerFromCharacter(m) then return end

    local label = EntityLabel(m.Name, false)
    if label then
        RegisterEntityWhenReady(m, label, true)
        return
    end
    if initial or not Cfg.UnlistedEntities then return end
    Dbg("ENTITY?", m, "mode=" .. Mode.Name)
    RegisterEntityWhenReady(m, CleanName(m.Name), false)
end

local function ProcessDupe(m)
    if not Active.dupe or not m:IsA("Model") or Tracked[m] then return end
    if not CurrentRooms or not m:IsDescendantOf(CurrentRooms) then return end
    if m.Name == "Door" or not IsDupeName(m.Name) then return end

    local room = m
    while room.Parent and room.Parent ~= CurrentRooms do room = room.Parent end
    Dbg("DUPE", m, "room=" .. room.Name .. " mode=" .. Mode.Name)
    Register(m, "dupe", "Dupe [Fake Door]", { Known = true, Key = "Dupe", RoomNum = tonumber(room.Name) })
end

local function ProcessRig(m)
    if not Active.entities or not Cfg.RoomEntities then return end
    if not m or not m:IsA("Model") or m == Workspace or Tracked[m] then return end
    if Players:GetPlayerFromCharacter(m) or IGNORE[m.Name] or IsDupeName(m.Name) or IsExcludedEntity(m.Name) or HasTrackedAncestor(m) then return end

    local label = EntityLabel(m.Name, true, true)
    if not label then
        Dbg("RIG?", m, "mode=" .. Mode.Name)
        return
    end
    RegisterEntityWhenReady(m, label, true)
end

local function StairLabel(name)
    local n = Norm(name)
    if n:find("ladder", 1, true) then return "Ladder" end
    if n == "stairs" or n == "stair" or n:find("staircase", 1, true) then return "Stairs" end
    return nil
end

local function ProcessStairs(d)
    if not Active.stairs or Tracked[d] then return end
    if d:IsA("TrussPart") then
        local owner = d
        local p = d.Parent
        if p and p:IsA("Model") and p ~= Workspace and p ~= CurrentRooms
            and not (CurrentRooms and p.Parent == CurrentRooms) and not Players:GetPlayerFromCharacter(p) then
            owner = p
        end
        if not Tracked[owner] and not HasTrackedAncestor(owner) then
            Register(owner, "stairs", "Ladder")
        end
    elseif d:IsA("Model") then
        local lab = StairLabel(d.Name)
        if lab and not HasTrackedAncestor(d) and not Players:GetPlayerFromCharacter(d) then
            Register(d, "stairs", lab)
        end
    end
end

local function HasWord(v, w)
    return type(v) == "string" and v:lower():find(w, 1, true) ~= nil
end
local function NoiseIsHijack(d)
    if HasWord(d.Name, "hijack") then return true end
    for k, v in pairs(d:GetAttributes()) do
        if HasWord(k, "hijack") or HasWord(v, "hijack") then return true end
    end
    local n = 0
    for _, x in ipairs(d:GetDescendants()) do
        if HasWord(x.Name, "hijack") then return true end
        for k, v in pairs(x:GetAttributes()) do
            if HasWord(k, "hijack") or HasWord(v, "hijack") then return true end
        end
        n = n + 1
        if n > 300 then break end
    end
    return false
end
local function DescribeChildren(d)
    local out = {}
    for _, c in ipairs(d:GetChildren()) do out[#out + 1] = c.ClassName .. ":" .. c.Name end
    for k, v in pairs(d:GetAttributes()) do out[#out + 1] = "@" .. k .. "=" .. tostring(v) end
    return table.concat(out, ", ")
end

local function ProcessNoise(d)
    if not Active.entities or Tracked[d] then return end
    if not (d:IsA("Model") or d:IsA("BasePart")) then return end
    local nm = d.Name
    if nm == "NoiseModel" then
        local cam = Workspace:FindFirstChild("Camera")
        if not (cam and d.Parent == cam) then return end
        Dbg("NOISEMODEL", d, DescribeChildren(d))
        task.spawn(function()
            local t0 = os.clock()
            local label = "Noise"
            while d.Parent and os.clock() - t0 < 1.2 do
                if NoiseIsHijack(d) then label = "Hijack" break end
                task.wait(0.1)
            end
            if not d.Parent then return end
            for _ = 1, 20 do
                if not d.Parent then return end
                if GetPart(d) then
                    Register(d, "entities", label, { Known = true, Key = label })
                    return
                end
                task.wait(0.1)
            end
        end)
    elseif nm == "TV_Stand" then
        local p = d.Parent
        if p and p.Name == "Assets" and CurrentRooms and d:IsDescendantOf(CurrentRooms) then
            RegisterEntityWhenReady(d, "Noise TV", true)
        end
    end
end

local function ProcessLoose(d)
    if not Active.entities or Tracked[d] or not d:IsA("Model") then return end
    if d.Name == "NoiseModel" then return end
    local p = d.Parent
    local cam = Workspace:FindFirstChild("Camera")
    local char = LocalPlayer.Character
    if not ((cam and p == cam) or (char and p == char)) then return end
    if IsExcludedEntity(d.Name) then return end
    local label = EntityLabel(d.Name, false)
    if not label or label == "Mandrake" then return end
    local set = ENTITY_MODES[label]
    if not Mode.All() and set and not set["*"] and not set[EntityModeKey()] then return end
    Dbg("LOOSE", d, "label=" .. label)
    RegisterEntityWhenReady(d, label, true)
end

local function OnDescendant(d)
    if not (d:IsA("ProximityPrompt") or d:IsA("Model") or d:IsA("BasePart") or d:IsA("Humanoid") or d:IsA("AnimationController")) then return end
    if d:IsA("Model") and Active.entities and not Tracked[d] and STRICT_SKIP.__stem[Norm(d.Name)] then
        local set = ENTITY_MODES["Stem"]
        if (Mode.Name == "Unknown" or Mode.Name == "Test" or (set and set[EntityModeKey()]))
            and not Players:GetPlayerFromCharacter(d) and not HasTrackedAncestor(d) then
            Dbg("STEM", d, "mode=" .. Mode.Name)
            RegisterEntityWhenReady(d, "Stem", true)
        end
    end
    Process(d)
    ProcessStairs(d)
    ProcessNoise(d)
    ProcessLoose(d)
    if d:IsA("Model") then
        if IsDupeName(d.Name) then ProcessDupe(d) end
        if Active.entities and not Tracked[d] then
            for _, g in ipairs(GLITCH_TOKENS) do
                if d.Name:find(g[1], 1, true) then
                    ProcessEntity(d, false)
                    break
                end
            end
        end
    elseif d:IsA("Humanoid") or d:IsA("AnimationController") then
        ProcessRig(d.Parent)
    end
end

Rescan = function()
    Mode.Gen = (Mode.Gen or 0) + 1
    local gen = Mode.Gen
    task.spawn(function()
        local n, t0 = 0, os.clock()
        for _, d in ipairs(Workspace:GetDescendants()) do
            pcall(OnDescendant, d)
            n = n + 1
            if n % 100 == 0 and os.clock() - t0 > (Watch.Budget2 or 0.004) then
                task.wait()
                t0 = os.clock()
                if Mode.Gen ~= gen then return end
            end
        end
        for _, c in ipairs(Workspace:GetChildren()) do pcall(ProcessEntity, c, true) end
        if CurrentRooms then
            for _, room in ipairs(CurrentRooms:GetChildren()) do
                for _, c in ipairs(room:GetChildren()) do pcall(RegisterDoor, room, c) end
            end
        end
    end)
end

print("[AMBUSH HUB] Loaded Workspace Element Detection")
print("[AMBUSH HUB] Loading Mode Connections")
do
    local queue, head, tail = {}, 1, 0
    Workspace.DescendantAdded:Connect(function(d)
        if d:IsA("ProximityPrompt") or d:IsA("Model") or d:IsA("BasePart") or d:IsA("Humanoid") or d:IsA("AnimationController") then
            if d.Name == "R4N_HighlightModel" or d.Name == "HighlightPart" then return end
            local fh = R4N_FunHolder
            if fh and d:IsDescendantOf(fh) then return end
            tail = tail + 1
            queue[tail] = d
        end
    end)
    RunService.Heartbeat:Connect(function()
        if head > tail then return end
        local t0 = os.clock()
        while head <= tail do
            local d = queue[head]
            queue[head] = nil
            head = head + 1
            if d.Parent then pcall(OnDescendant, d) end
            if head % 5 == 0 and os.clock() - t0 > (Watch.Budget or 0.0025) then break end
        end
        if head > tail then head, tail = 1, 0 end
    end)
end
Workspace.ChildAdded:Connect(function(c) pcall(ProcessEntity, c, false) end)

CurrentRooms = Workspace:FindFirstChild("CurrentRooms")
task.spawn(function()
    if not CurrentRooms then
        CurrentRooms = Workspace:WaitForChild("CurrentRooms", 60)
        if CurrentRooms then Rescan() end
    end
    if not CurrentRooms then
        Dbg("NOROOMS", Workspace, "CurrentRooms not found")
        return
    end
    for _, room in ipairs(CurrentRooms:GetChildren()) do ScanRoom(room) end
    CurrentRooms.ChildAdded:Connect(ScanRoom)
end)
Rescan()

print("[AMBUSH HUB] Loaded Mode Connections")
print("[AMBUSH HUB] Loading Player ESP")
do
    local function TrackPlayer(plr)
        if plr == LocalPlayer then return end
        local function onChar(char)
            task.spawn(function()
                local root = char:WaitForChild("HumanoidRootPart", 10)
                if not root or not char.Parent then return end
                local name = (Cfg.PlayerNames == "Username") and plr.Name or plr.DisplayName
                Register(char, "players", name, { Known = true, Key = plr.Name })
            end)
        end
        if plr.Character then onChar(plr.Character) end
        plr.CharacterAdded:Connect(onChar)
    end
    for _, p in ipairs(Players:GetPlayers()) do TrackPlayer(p) end
    Players.PlayerAdded:Connect(TrackPlayer)
end

print("[AMBUSH HUB] Loaded Player ESP")
print("[AMBUSH HUB] Loading Rendering")
local function FilterPasses(e)
    if e.Cat == "items" then
        if e.Known then return Cfg.ItemFilter[e.Key] == true end
        return Cfg.UnlistedItems
    elseif e.Cat == "entities" then
        if e.Known then
            local set = ENTITY_MODES[e.Key]
            if not Mode.All() and set and not set["*"] and not set[EntityModeKey()] then
                return false
            end
            return Cfg.EntityFilter[e.Key] == true
        end
        return Cfg.UnlistedEntities
    end
    return true
end

local function HasVisibleGeometry(inst)
    if inst:IsA("BasePart") then return inst.Transparency < 0.95 end
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("BasePart") and d.Transparency < 0.95 then return true end
    end
    return false
end

Mode.Sort = function(a, b)
    local pa = a.Cat == "entities" and 0 or 1
    local pb = b.Cat == "entities" and 0 or 1
    if pa ~= pb then return pa < pb end
    return a.Dist < b.Dist
end

local function Refresh()
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local any = false
    for id, c in pairs(Cfg.Categories) do
        if c.Enabled and Active[id] then any = true break end
    end
    if not any then
        for _, e in pairs(Tracked) do
            if e.Shown or e.HL or e.Line then Mode.Free(e) end
            e.Shown = false
        end
        Mode.TracerList = nil
        return
    end

    local camPos = cam.CFrame.Position
    local currentRoom = LocalPlayer:GetAttribute("CurrentRoom")
    local list, n = {}, 0
    local maxDist = Cfg.MaxDistance

    for inst, e in pairs(Tracked) do
        local part = e.Part
        if not part.Parent then
            RemoveEntry(inst)
        else
            local cat = e.Cat
            local ok = Active[cat] and Cfg.Categories[cat].Enabled and FilterPasses(e)
            if ok and (cat == "doors" or cat == "dupe") and e.RoomNum and currentRoom and e.RoomNum < currentRoom then
                ok = false
            end
            if ok and e.Prompt and Cfg.HideLooted then
                local pr = e.Prompt
                if not pr.Parent or pr.Enabled == false then ok = false end
            end
            if ok then
                local d = (part.Position - camPos).Magnitude
                e.Dist = d
                ok = (cat == "entities" and not (Watch.Limited[e.Key] or Watch.Limited[e.Label])) or d <= maxDist
            end
            if ok then
                n = n + 1
                list[n] = e
            else
                HideEntry(e)
            end
        end
    end

    local maxHL = Watch.MaxHL or MAX_HIGHLIGHTS
    local cap = math.min(Cfg.MaxObjects or 120, Watch.PerfCap or math.huge)
    if n > maxHL or n > cap then
        table.sort(list, Mode.Sort)
        for i = cap + 1, n do
            HideEntry(list[i])
            list[i] = nil
        end
        if n > cap then n = cap end
    end
    do
        local kept, kn, used = {}, 0, 0
        for i = 1, n do
            local e = list[i]
            if e.NoGeo then
                kn = kn + 1
                kept[kn] = e
            elseif used < maxHL then
                used = used + 1
                kn = kn + 1
                kept[kn] = e
            else
                HideEntry(e)
            end
        end
        list, n = kept, kn
    end

    local now = os.clock()
    local meters = Cfg.Unit == "Meters"
    local fontEnum = FONT_MAP[Cfg.Font] or Enum.Font.Oswald
    local textSize = Cfg.TextSize
    local bbHeight = math.ceil(textSize * 2.5) + 6
    local fillT, outT = Cfg.FillTransparency, Cfg.OutlineTransparency
    local showName, showDist = Cfg.ShowName, Cfg.ShowDistance
    local tracers, tn = {}, 0

    for i = 1, n do
        local e = list[i]
        local cat = e.Cat
        local cc = Cfg.Categories[cat]
        local color = cc.Color
        if Cfg.Rainbow and Cfg.RainbowColor then color = Cfg.RainbowColor end
        e.Shown = true
        e.HidSince = nil
        if not e.HL then Mode.Build(e) end

        if cat == "doors" then
            e.Base = e.Base or e.Label
            e.Label = e.Base .. (((e.Door or e.Inst):FindFirstChild("Lock")) and " [Locked]" or "")
        elseif cat == "players" then
            local plr = Players:GetPlayerFromCharacter(e.Inst)
            if plr then e.Label = (Cfg.PlayerNames == "Username") and plr.Name or plr.DisplayName end
        end

        if now - e.GeoT > 6 then
            e.GeoT = now
            e.NoGeo = not HasVisibleGeometry(e.Inst)
        end
        local useBox = e.NoGeo

        local hl, box, bb, tl = e.HL, e.Box, e.BB, e.TL

        if e.Col ~= color or e.Fill ~= fillT or e.Out ~= outT then
            e.Col, e.Fill, e.Out = color, fillT, outT
            hl.FillColor = color
            hl.OutlineColor = color
            hl.FillTransparency = fillT
            hl.OutlineTransparency = outT
            box.Color3 = color
            box.Transparency = math.max(0.55, fillT)
            tl.TextColor3 = color
            if e.Line then e.Line.BackgroundColor3 = color end
        end

        hl.Enabled = not useBox
        box.Visible = useBox
        if useBox then
            if cat == "entities" or cat == "players" or cat == "dupe" or now - (e.BoxT or 0) > 1.5 then
                e.BoxT = now
                if e.Inst:IsA("Model") then
                    local okb, cf, size = pcall(e.Inst.GetBoundingBox, e.Inst)
                    if okb then
                        box.CFrame = e.Part.CFrame:ToObjectSpace(cf)
                        box.Size = size
                    end
                else
                    box.CFrame = CFrame.new()
                    box.Size = e.Part.Size
                end
            end
        end

        local dtxt
        if showDist then
            local d = meters and (e.Dist * 0.28) or e.Dist
            dtxt = string.format(meters and "[%dm]" or "[%d]", math.floor(d + 0.5))
        end
        local text
        if showName then
            text = showDist and (e.Label .. "\n" .. dtxt) or e.Label
        else
            text = dtxt or ""
        end
        if e.Text ~= text then
            e.Text = text
            tl.Text = text
        end
        if e.TS ~= textSize or e.TF ~= fontEnum then
            e.TS, e.TF = textSize, fontEnum
            tl.TextSize = textSize
            tl.Font = fontEnum
            bb.Size = UDim2.fromOffset(300, bbHeight)
        end
        bb.Enabled = text ~= ""

        if cc.Tracer then
            if not e.Line then
                local line = Instance.new("Frame")
                line.BorderSizePixel = 0
                line.AnchorPoint = Vector2.new(0.5, 0.5)
                line.Visible = false
                line.BackgroundColor3 = color
                line.Parent = Gui
                e.Line = line
            end
            tn = tn + 1
            tracers[tn] = e
        elseif e.Line and e.Line.Visible then
            e.Line.Visible = false
        end
    end

    Mode.TracerList = tracers
end

task.spawn(function()
    while true do
        pcall(Refresh)
        task.wait(math.max(1 / math.max(Cfg.RefreshRate or 4, 1), Watch.PerfInterval or 0))
    end
end)

task.spawn(function()
    while true do
        pcall(WatchMode)
        pcall(UpdateOverlay)
        task.wait(2)
    end
end)

RunService.RenderStepped:Connect(function()
    local tracers = Mode.TracerList
    if not tracers or #tracers == 0 then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local vp = cam.ViewportSize
    local origin
    if Cfg.TracerOrigin == "Center" then
        origin = Vector2.new(vp.X / 2, vp.Y / 2)
    elseif Cfg.TracerOrigin == "Top" then
        origin = Vector2.new(vp.X / 2, 0)
    elseif Cfg.TracerOrigin == "Mouse" then
        origin = UserInputService:GetMouseLocation()
    else
        origin = Vector2.new(vp.X / 2, vp.Y)
    end

    for i = 1, #tracers do
        local e = tracers[i]
        local line = e.Line
        if line then
            if e.Shown and e.Part.Parent then
                local v = cam:WorldToViewportPoint(e.Part.Position)
                if v.Z > 0 then
                    local target = Vector2.new(v.X, v.Y)
                    local diff = target - origin
                    line.Size = UDim2.fromOffset(diff.Magnitude, Cfg.TracerThickness)
                    line.Position = UDim2.fromOffset((origin.X + target.X) / 2, (origin.Y + target.Y) / 2)
                    line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
                    line.Visible = true
                else
                    line.Visible = false
                end
            elseif line.Visible then
                line.Visible = false
            end
        end
    end
end)

print("[AMBUSH HUB] Loaded Rendering")
print("[AMBUSH HUB] Loading Visuals UI")
Setters.ItemFilter = function() end
Setters.EntityFilter = function() end
Setters.FillPercent = function() end

local function AddToggle(tab, id, title, desc, default, cb)
    R4N_KeyTab[id] = tab
    local el = tab:Toggle({ Title = title, Desc = desc, Value = default, Callback = cb })
    Setters[id] = function(v) pcall(function() el:Set(v) end) end
end

local function AddSlider(tab, id, title, desc, min, max, default, cb)
    R4N_KeyTab[id] = tab
    local el = tab:Slider({
        Title = title, Desc = desc, Step = 1,
        Value = { Min = min, Max = max, Default = default },
        Callback = cb
    })
    Setters[id] = function(v) pcall(function() el:Set(v) end) end
end

local function AddDropdown(tab, id, title, desc, values, default, cb)
    R4N_KeyTab[id] = tab
    local el = tab:Dropdown({ Title = title, Desc = desc, Values = values, Value = default, Callback = cb })
    Setters[id] = function(v) pcall(function() el:Select(v) end) end
end

local function AddColor(tab, id, title, desc, default, cb)
    R4N_KeyTab[id] = tab
    local el
    local ok = pcall(function()
        el = tab:Colorpicker({ Title = title, Desc = desc, Default = default, Callback = cb })
    end)
    if not ok then
        pcall(function()
            el = tab:ColorPicker({ Title = title, Desc = desc, Default = default, Callback = cb })
        end)
    end
    Setters[id] = function(v) pcall(function() el:Set(v) end) end
end

local CATEGORY_UI = {
    { id = "doors", section = "Navigation", title = "ESP Doors",
      desc = "Marks the exit door of every room ahead as 'Door N' (adds [Locked] when it needs a key). Doors of rooms you already passed are hidden." },
    { id = "dupe", section = "Navigation", title = "ESP Dupe (Fake Doors)",
      desc = "Marks only the trapped fake doors made by Dupe, labeled 'Dupe [Fake Door]'. Real doors are never tagged as Dupe. It only shows up in rooms where Dupe is active." },

    { id = "stairs", section = "Navigation", title = "ESP Stairs & Ladders",
      desc = "Marks the ladders and stairs of The Mines (climbable trusses and objects named Ladder or Stairs). Only available in that mode. Presets leave it off." },

    { id = "gold", section = "Loot", title = "ESP Gold",
      desc = "Gold piles on the floor. Shows the amount in brackets when the game exposes it." },
    { id = "keys", section = "Loot", title = "ESP Keys & Fuses",
      desc = "Keys, Electrical Room keys and Fuses needed to unlock doors or start machinery." },
    { id = "chests", section = "Loot", title = "ESP Chests",
      desc = "Regular, locked and vine-covered chests. Locked chests need a key or lockpicks." },
    { id = "drawers", section = "Loot", title = "ESP Drawers",
      desc = "Loot containers: drawers, desks, dressers, cabinets and makeshift drawers. Hidden after you open them (see Hide Looted Containers)." },
    { id = "lockers", section = "Loot", title = "ESP Lockers & Toolboxes",
      desc = "Item lockers, small lockers and toolboxes that contain loot. These are not hiding spots. Hidden after you open them." },
    { id = "items", section = "Loot", title = "ESP Items",
      desc = "Pickup items lying around (Flashlight, Lockpicks, Vitamins, Crucifix...). Choose which ones to show in the Item Filter below." },
    { id = "stardust", section = "Loot", title = "ESP Stardust",
      desc = "Stardust pickups (internally StardustPickup). They have their own ESP and never show in ESP Items." },
    { id = "glitch", section = "Loot", title = "ESP Glitch Fragment",
      desc = "The rare Glitch Fragment (internally GlitchCube). It has its own ESP and never shows in ESP Items. Glitched Rush, Ambush and Screech are handled by ESP Entities instead." },
    { id = "scanner", section = "Loot", title = "ESP Scanner Module",
      desc = "The module for the Scanner. It has its own ESP and never shows in ESP Items (the Scanner item itself is listed in ESP Items). Needs its Dex name in PENDING_DEX_NAMES to be detected." },
    { id = "lotus", section = "Loot", title = "ESP Lotus Petals",
      desc = "Lotus petals scattered around the Outdoors." },

    { id = "wardrobes", section = "Hiding & Objectives", title = "ESP Hiding Spots",
      desc = "Places you can hide in: closets, beds, lockers and tool sheds." },
    { id = "objectives", section = "Hiding & Objectives", title = "ESP Objectives",
      desc = "Room puzzle pieces: levers, timer levers, library books, breaker poles, Sally's toy (also when they are inside a drawer) and the Stairwell fire alarm lever." },

    { id = "exit", section = "Stairwell", title = "ESP Emergency Exit",
      desc = "Marks the emergency exit sign of the Stairwell rooms. Only available in The Stairwell." },
    { id = "cart", section = "Stairwell", title = "ESP Shopping Cart",
      desc = "Marks the shopping carts of the Stairwell (inside rooms or loose in the map). Only available in The Stairwell." },

    { id = "entities", section = "Entities", title = "ESP Entities",
      desc = "Monsters that belong to the detected game mode only. Entities from other modes are never shown. Pick which ones in the Entity Filter below." },

    { id = "players", section = "Players", title = "ESP Players",
      desc = "Marks the other players in your run with their name and distance. Choose display name or username in the Display section." },

    { id = "interactables", section = "Extras", title = "ESP Interactables",
      desc = "Any other object with an interaction prompt that does not fit another category (in The Stairwell it also marks the Depots). Can be noisy, so presets leave it off." },
}

local UICreated, SectionCreated = {}, {}

local function EnsureCategoryUI(id)
    if UICreated[id] or not Active[id] then return end
    for _, c in ipairs(CATEGORY_UI) do
        if c.id == id then
            UICreated[id] = true
            if not SectionCreated[c.section] then
                SectionCreated[c.section] = true
                VisualsTab:Section({ Title = c.section })
            end
            AddToggle(VisualsTab, "cat_" .. c.id, c.title, c.desc, Cfg.Categories[c.id].Enabled, function(v)
                Cfg.Categories[c.id].Enabled = v
            end)
            AddColor(VisualsTab, "col_" .. c.id, "Color: " .. (c.title:gsub("ESP ", "")),
                "Highlight, label and tracer color for this category.", Cfg.Categories[c.id].Color, function(color)
                    Cfg.Categories[c.id].Color = color
                end)
            AddToggle(VisualsTab, "tr_" .. c.id, "Tracer: " .. (c.title:gsub("ESP ", "")),
                "Draws a line from the tracer origin to every object of this category. Independent from the other categories.",
                Cfg.Categories[c.id].Tracer, function(v)
                    Cfg.Categories[c.id].Tracer = v
                end)
            return
        end
    end
end

ApplyPreset = function(modeName)
    local list = MODE_CATS[modeName]
    if not list then return false end
    for _, id in ipairs(list) do
        if id ~= "interactables" and id ~= "stairs" then
            Cfg.Categories[id].Enabled = true
            if Setters["cat_" .. id] then Setters["cat_" .. id](true) end
        end
    end
    return true
end

print("[AMBUSH HUB] Loaded Visuals UI")
print("[AMBUSH HUB] Loading Main Tab")
MainTab:Section({ Title = "What's New" })
do
    local NOTES_EN = "+ Added Fun tab: turn into Seek, Honcho, or Figure (client only).\n"
            .. "+ Added Community Scripts in the Fun tab: run another player's script from a link; always shows a notification with the author.\n"
            .. "+ Added Rainbow Highlight at the bottom of Visuals (smooth color shift).\n"
            .. "+ Added Smart Performance: adaptive limits, lightweight room loading, and FPS protection.\n"
            .. "+ Added highlight cap: ESP never exceeds Roblox limits.\n"
            .. "+- Highlight switched to the main style: real shape of every object, player, entity, gold, and door, with Fill 0.75 / Outline 0.\n"
            .. "+- Auto Interact moved to the main loop: fires every frame in range, with lock/key/tool checks, works even without fireproximityprompt.\n"
            .. "+- Auto Doors movement changed: the bot walks like real WASD / joystick (no mini-teleports).\n"
            .. "+- Bot speed: only applied when Anticheat Bypass is enabled.\n"
            .. "+- Auto-unstuck changed: the bot only jumps or crouches on a real obstacle.\n"
            .. "+- Double / single doors: highlight only the doors themselves.\n"
            .. "- Removed blocky ESP fallback: objects beyond the limit are hidden, not drawn as blocks.\n"
            .. "- Removed the old full-map rescan every 6 seconds (caused lag)."
    local WN = R4N_LANGPACK.WhatsNew or {}
-- Round-2 additions (Ambush Hub rebrand)
local AMBUSH_HUB_NOTES_EN = "\n"
    .. "+ Added a separate 'Infinite Items' tab (2026-10-20).\n"
    .. "+ Added a script icon next to the menu title (2026-10-20).\n"
    .. "+ Creators: VANTA & void, team: void script (2026-10-20).\n"
    .. "+ Auto Interact ported from rush.txt: HerbPrompt check and AutoCloset integration (2026-10-19).\n"
    .. "+ Every feature is tagged with the date it was added — today or yesterday (2026-10-20 / 2026-10-19)."

    local NOTES = WN.Notes or {}
    local TITLES = WN.Title or {}
    MainTab:Paragraph({ Title = TITLES[R4N_LANG] or TITLES.en or "Version 1.0.5", Desc = (NOTES[R4N_LANG] or NOTES.en or NOTES_EN) .. (AMBUSH_HUB_NOTES_EN or "") })
end
MainTab:Section({ Title = "Game Mode" })
ModeParagraph = MainTab:Paragraph({
    Title = "Detected on load: " .. Mode.Name,
    Desc = "The script detects the game mode on startup and loads only the ESP options and detectors this mode needs. "
        .. "If the mode changes mid-run, the script re-configures and adds new options at the bottom of the Visuals tab."
})
MainTab:Button({
    Title = "Re-detect Mode",
    Desc = "Re-reads the game data. Use if the mode was detected wrong on load.",
    Callback = function()
        local ok, name = pcall(ReadMode)
        if ok and name ~= Mode.Name and (name ~= "Unknown" or Force.Name == "Unknown") then
            ApplyMode(name)
        else
            WindUI:Notify({ Title = "Game Mode", Content = "Current mode: " .. Mode.Name .. " (unchanged).", Duration = 3 })
        end
    end
})

local FORCE_LABELS = {
    ["Auto (detect)"] = "Auto",
    ["Outdoors"] = "Outdoors",
    ["Backdoors"] = "Backdoor",
    ["Hotel"] = "Hotel",
    ["Mines"] = "Mines",
    ["Stairwells"] = "Stairwell",
    ["Super Hard Mode (Fools)"] = "Fools",
    ["Archives"] = "Archives",
    ["Rooms"] = "Rooms",
    ["Unknown"] = "Unknown",
    ["Test Mode (all ESP + entities)"] = "Test",
}
MainTab:Dropdown({
    Title = "Force Mode",
    Desc = "Forces the script to use a specific mode instead of auto-detection. Pick Auto (detect) to go back to normal detection (lobby is detected automatically).",
    Values = { "Auto (detect)", "Outdoors", "Backdoors", "Hotel", "Mines", "Stairwells", "Super Hard Mode (Fools)", "Archives", "Rooms", "Unknown", "Test Mode (all ESP + entities)" },
    Value = "Auto (detect)",
    Callback = function(label)
        local mode = FORCE_LABELS[label]
        if not mode then return end
        Force.Name = mode
        local ok, name = pcall(ReadMode)
        if ok and name and (name ~= Mode.Name) then
            ApplyMode(name)
        else
            WindUI:Notify({ Title = "Game Mode", Content = "Mode: " .. Mode.Name .. " (unchanged).", Duration = 3 })
        end
    end
})

print("[AMBUSH HUB] Loaded Main Tab")
print("[AMBUSH HUB] Loading Visuals Tab")
VisualsTab:Section({ Title = "Mode Presets" })
AddToggle(VisualsTab, "AutoPreset", "Auto-enable ESP for this mode",
    "Turns on all the ESP of a specific mode when the mode is detected or changes. Never disables anything.",
    Cfg.AutoPreset, function(v)
        Cfg.AutoPreset = v
        if v then ApplyPreset(Mode.Name) end
    end)
VisualsTab:Button({
    Title = "Enable all ESP for current mode",
    Desc = "One click: enables every ESP category that exists in the detected mode (Interactables stays off).",
    Callback = function()
        if ApplyPreset(Mode.Name) then
            WindUI:Notify({ Title = "Preset", Content = "Enabled ESP for " .. Mode.Name .. ".", Duration = 3 })
        else
            WindUI:Notify({ Title = "Preset", Content = "Mode not detected yet (" .. Mode.Name .. ").", Duration = 3 })
        end
    end
})

for _, c in ipairs(CATEGORY_UI) do EnsureCategoryUI(c.id) end

VisualsTab:Section({ Title = "Display" })
AddSlider(VisualsTab, "MaxDistance", "Max Distance",
    "Objects farther than this many studs are hidden. Entities always show, except in the \"Distance-limited entities\" list.",
    50, 2000, Cfg.MaxDistance, function(v) Cfg.MaxDistance = v end)
AddSlider(VisualsTab, "MaxObjects", "Max ESP Objects",
    "Maximum objects on-screen at once (closest wins; entities always take priority). Lower it if the game lags, especially in The Outdoors.",
    20, 400, Cfg.MaxObjects, function(v) Cfg.MaxObjects = v end)
AddToggle(VisualsTab, "HideLooted", "Hide Looted Containers",
    "Hides drawers, lockers and chests after they have been opened / looted.",
    Cfg.HideLooted, function(v) Cfg.HideLooted = v end)
AddToggle(VisualsTab, "ShowName", "Show Names", "Shows a name label above every marked object.",
    Cfg.ShowName, function(v) Cfg.ShowName = v end)
AddToggle(VisualsTab, "ShowDistance", "Show Distance", "Shows how far every marked object is from you.",
    Cfg.ShowDistance, function(v) Cfg.ShowDistance = v end)
AddDropdown(VisualsTab, "Unit", "Distance Unit", "Meters (studs x 0.28) or raw studs. Only the number is shown, never the word 'studs'.",
    { "Meters", "Studs" }, Cfg.Unit, function(v) Cfg.Unit = v end)
AddSlider(VisualsTab, "TextSize", "Text Size", "Size of the name and distance labels.",
    10, 40, Cfg.TextSize, function(v) Cfg.TextSize = v end)
AddDropdown(VisualsTab, "Font", "Text Font", "Font of ESP name and distance labels.",
    FONT_LIST, Cfg.Font, function(v)
        if FONT_MAP[v] then Cfg.Font = v end
    end)
AddSlider(VisualsTab, "FillPercent", "Fill Opacity (%)", "0 = outline only, 100 = fully filled highlight.",
    0, 100, math.floor((1 - Cfg.FillTransparency) * 100), function(v)
        Cfg.FillTransparency = 1 - (v / 100)
    end)
AddDropdown(VisualsTab, "PlayerNames", "Player Name Type", "Whether ESP Players shows display name or username.",
    { "Display Name", "Username" }, Cfg.PlayerNames, function(v) Cfg.PlayerNames = v end)

VisualsTab:Section({ Title = "Tracer Lines" })
VisualsTab:Paragraph({
    Title = "Per-category tracers",
    Desc = "Enable tracers only for the ESP you want via the 'Tracer: ...' toggle under each category above. The origin and thickness below apply to all of them."
})
AddDropdown(VisualsTab, "TracerOrigin", "Tracer Origin", "Where tracer lines start from.",
    { "Bottom", "Center", "Top", "Mouse" }, Cfg.TracerOrigin, function(v) Cfg.TracerOrigin = v end)
AddSlider(VisualsTab, "TracerThickness", "Tracer Thickness", "Line width in pixels.",
    1, 5, Cfg.TracerThickness, function(v) Cfg.TracerThickness = v end)

local ItemFilterCreated = false
local function EnsureItemFilterUI()
    if ItemFilterCreated or not Active.items then return end
    ItemFilterCreated = true
    VisualsTab:Section({ Title = "Item Filter" })

    local defaults = {}
    for _, n in ipairs(ITEM_NAMES) do
        if Cfg.ItemFilter[n] then defaults[#defaults + 1] = n end
    end

    local dd = VisualsTab:Dropdown({
        Title = "Show items",
        Desc = "Pick which items ESP Items marks. Unselected ones stay hidden.",
        Values = ITEM_NAMES,
        Value = defaults,
        Multi = true,
        AllowNone = true,
        Callback = function(selected)
            local map = {}
            for _, n in ipairs(selected or {}) do map[n] = true end
            Cfg.ItemFilter = map
        end
    })
    Setters.ItemFilter = function(list) pcall(function() dd:Select(list) end) end

    VisualsTab:Button({
        Title = "Select all items",
        Desc = "Show every item in the list.",
        Callback = function()
            for _, n in ipairs(ITEM_NAMES) do Cfg.ItemFilter[n] = true end
            Setters.ItemFilter(ITEM_NAMES)
        end
    })
    VisualsTab:Button({
        Title = "Clear all items",
        Desc = "Hide every item in the list (handy to then pick a few).",
        Callback = function()
            Cfg.ItemFilter = {}
            Setters.ItemFilter({})
        end
    })
    AddToggle(VisualsTab, "UnlistedItems", "Show Unlisted Items",
        "Also marks pickups that are not in the list above, using their in-game name.",
        Cfg.UnlistedItems, function(v) Cfg.UnlistedItems = v end)
end

local EntityFilterCreated = false
local EntityDD
local function EnsureEntityFilterUI()
    if not Active.entities then return end
    local list = CurrentEntityList()

    if EntityFilterCreated then
        pcall(function() EntityDD:Refresh(list) end)
        local selected = {}
        for _, n in ipairs(list) do
            if Cfg.EntityFilter[n] then selected[#selected + 1] = n end
        end
        Setters.EntityFilter(selected)
        return
    end
    EntityFilterCreated = true
    VisualsTab:Section({ Title = "Entity Filter" })

    EntityDD = VisualsTab:Dropdown({
        Title = "Show entities",
        Desc = "Show only entities of the detected mode. Unselected ones are not marked.",
        Values = list,
        Value = list,
        Multi = true,
        AllowNone = true,
        Callback = function(selected)
            local map = {}
            for _, n in ipairs(selected or {}) do map[n] = true end
            Cfg.EntityFilter = map
        end
    })
    Setters.EntityFilter = function(l) pcall(function() EntityDD:Select(l) end) end

    VisualsTab:Button({
        Title = "Select all entities",
        Desc = "Show every entity of this mode.",
        Callback = function()
            local l = CurrentEntityList()
            for _, n in ipairs(l) do Cfg.EntityFilter[n] = true end
            Setters.EntityFilter(l)
        end
    })
    VisualsTab:Button({
        Title = "Clear all entities",
        Desc = "Hide every entity (handy to then pick a few).",
        Callback = function()
            Cfg.EntityFilter = {}
            Setters.EntityFilter({})
        end
    })
    AddToggle(VisualsTab, "UnlistedEntities", "Show Unlisted Entities",
        "Also marks NEW models that appear in Workspace with an unknown name. Off by default because it can mark objects that are not entities.",
        Cfg.UnlistedEntities, function(v) Cfg.UnlistedEntities = v end)
    AddToggle(VisualsTab, "RoomEntities", "Scan Rooms for Entities",
        "Also finds entities that live inside rooms (Figure, Seek, Snare, Teller...). Only exact internal names are matched, so decorations are never marked.",
        Cfg.RoomEntities, function(v) Cfg.RoomEntities = v end)
end

EnsureItemFilterUI()
EnsureEntityFilterUI()

OnModeApplied = function()
    for _, c in ipairs(CATEGORY_UI) do EnsureCategoryUI(c.id) end
    EnsureItemFilterUI()
    EnsureEntityFilterUI()
end

pcall(function()
    WindUI:Notify({ Title = "Game Mode", Content = "Detected: " .. Mode.Name .. ". Only this mode's ESP options are loaded.", Duration = 4 })
end)

print("[AMBUSH HUB] Loaded Visuals Tab")
print("[AMBUSH HUB] Loading Debug Mode")
MiscTab:Section({ Title = "Debug Mode" })
AddToggle(MiscTab, "Debug", "Debug Mode", "Records anything the ESP does not recognize (item, entity or prompt) with its full path, so you can report the exact name and get it fixed.", false, function(v)
    Cfg.Debug = v
end)
AddToggle(MiscTab, "DebugVerbose", "Verbose Logging", "Also logs every object the ESP registers. Needs Debug Mode on and can print a lot.", false, function(v)
    Cfg.DebugVerbose = v
end)
MiscTab:Button({
    Title = "Print ESP summary",
    Desc = "Shows how many objects are tracked per category right now.",
    Callback = function()
        local counts = {}
        for _, e in pairs(Tracked) do counts[e.Cat] = (counts[e.Cat] or 0) + 1 end
        local parts = {}
        for cat, n in pairs(counts) do parts[#parts + 1] = cat .. "=" .. n end
        table.sort(parts)
        local msg = #parts > 0 and table.concat(parts, ", ") or "nothing tracked yet"
        print("[AMBUSH HUB] ESP summary: " .. msg)
        WindUI:Notify({ Title = "ESP Summary", Content = msg, Duration = 5 })
    end
})
MiscTab:Button({
    Title = "Copy debug log",
    Desc = "Copies everything recorded in the log to the clipboard.",
    Callback = function()
        local text = #DebugLog > 0 and table.concat(DebugLog, "\n") or "(empty)"
        if setclipboard then
            setclipboard(text)
            WindUI:Notify({ Title = "Debug", Content = "Copied entries: " .. #DebugLog .. ".", Duration = 3 })
        else
            print(text)
            WindUI:Notify({ Title = "Debug", Content = "No clipboard support; printed to the console.", Duration = 3 })
        end
    end
})
MiscTab:Button({
    Title = "Clear debug log",
    Callback = function()
        DebugLog, DebugSeen = {}, {}
        WindUI:Notify({ Title = "Debug", Content = "Log cleared.", Duration = 2 })
    end
})

AddToggle(MiscTab, "Overlay", "Debug Overlay", "On-screen panel: detected mode, room, GameData and tracked counts.", false, function(v)
    Cfg.Overlay = v
    UpdateOverlay()
end)
MiscTab:Button({
    Title = "Copy game info",
    Desc = "Copies the detected mode, GameData values, room names and Workspace contents. Send it when the mode was detected wrong.",
    Callback = function()
        pcall(ReadMode)
        local lines = {
            "PlaceId: " .. tostring(game.PlaceId),
            "Mode: " .. Mode.Name,
            "GameData: " .. (Mode.Raw ~= "" and Mode.Raw or "-"),
            "CurrentRoom attr: " .. tostring(LocalPlayer:GetAttribute("CurrentRoom")),
        }
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        if rooms then
            local names = {}
            for _, r in ipairs(rooms:GetChildren()) do names[#names + 1] = r.Name end
            lines[#lines + 1] = "CurrentRooms: " .. table.concat(names, ",")
        else
            lines[#lines + 1] = "CurrentRooms: missing"
        end
        local top = {}
        for _, c in ipairs(Workspace:GetChildren()) do top[#top + 1] = c.ClassName .. ":" .. c.Name end
        lines[#lines + 1] = "Workspace: " .. table.concat(top, ", ")
        local text = table.concat(lines, "\n")
        if setclipboard then
            setclipboard(text)
            WindUI:Notify({ Title = "Debug", Content = "Game info copied.", Duration = 3 })
        else
            print(text)
            WindUI:Notify({ Title = "Debug", Content = "No clipboard support; printed to the console.", Duration = 3 })
        end
    end
})

MiscTab:Button({
    Title = "Copy nearby objects (30 studs)",
    Desc = "Copies names / paths of models and prompts around you. Stand next to the thing that does not work and press it.",
    Callback = function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            WindUI:Notify({ Title = "Debug", Content = "Character not found.", Duration = 3 })
            return
        end
        local origin, out = root.Position, {}
        for _, d in ipairs(Workspace:GetDescendants()) do
            if #out >= 120 then break end
            local pos
            if d:IsA("ProximityPrompt") then
                local par = d.Parent
                pos = par and (par:IsA("BasePart") and par.Position or (par:IsA("Attachment") and par.WorldPosition))
            elseif d:IsA("Model") and not Players:GetPlayerFromCharacter(d) then
                local okp, cf = pcall(d.GetPivot, d)
                pos = okp and cf.Position
            end
            if pos and (pos - origin).Magnitude <= 30 then
                if d:IsA("ProximityPrompt") then
                    out[#out + 1] = string.format("Prompt | %s | ObjectText=%s | %s", d.Name, tostring(d.ObjectText), d:GetFullName())
                else
                    out[#out + 1] = string.format("Model | %s | %s", d.Name, d:GetFullName())
                end
            end
        end
        local text = "Mode: " .. Mode.Name .. "\n" .. (#out > 0 and table.concat(out, "\n") or "(nothing nearby)")
        if setclipboard then
            setclipboard(text)
            WindUI:Notify({ Title = "Debug", Content = "Copied objects: " .. #out .. ".", Duration = 3 })
        else
            print(text)
            WindUI:Notify({ Title = "Debug", Content = "No clipboard support; printed to the console.", Duration = 3 })
        end
    end
})

print("[AMBUSH HUB] Loaded Debug Mode")
print("[AMBUSH HUB] Loading Alerts")

;(function()
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local NOT_WORTH = {
    Timothy = true, Snare = true, Bob = true, ["El Goblino"] = true, Grampy = true,
    Portrait = true, Monument = true, Currents = true, Jeff = true, Crusher = true, ["Noise TV"] = true,
}

local ENTITY_TIPS = {
    Rush = "Hide in a closet now!",
    Ambush = "Hide in a closet. It can come back several times.",
    Blitz = "Hide in a closet!",
    Seek = "Run and follow the path. Avoid the hands.",
    Figure = "Stay quiet. Crouch and keep your distance.",
    Eyes = "Do not look at it.",
    Lookman = "Do not look at it.",
    Halt = "Turn around when you see it.",
    Dupe = "Fake doors are trapped. Do not open them.",
}

local Ex = {
    Notify = false, NotifyStyle = "Doors Achievement", NotifySound = true, NotifyVolume = 100,
    NotifyDuration = 5, NotifyCooldown = 4, NotifyTips = true, NotifySoundId = "", NotifyIconId = "",
    NotifyFilter = {},
    Speed = false, SpeedValue = 30, SpeedMethod = "Velocity",
    SpeedHack = false, SpeedHackValue = 30, DisableAnticheat = false, VelocityManipulationMode = "Velocity", PositionSpoof = false, CrouchSpoof = false, AutoHeartbeatMinigame = false,
    BypassGiggle = false, BypassDupe = false, BypassEyes = false, BypassLookman = false, BypassGloombatEggs = false, BypassSeekObstructions = false, BypassVacuum = false, BypassKillbricks = false, BypassSeekingWall = false, BypassSnare = false, BypassBanana = false, BypassJeff = false,
    RemoveScreech = false, RemoveHalt = false, RemoveA90 = false, RemoveDread = false, RemoveSurge = false, NoScreechDamage = false, NoHaltDamage = false, NoA90Damage = false, NoSurgeDamage = false,
    RemoveSeekTrigger = false, RemoveFigure = false, AutoRevive = false, FigureGodmode = false, RemoveBasementGate = false, RemovePaintingsDoor = false, RemoveSkeletonDoor = false,
    Key_PosSpoof = "H",
    Jump = false, JumpPower = 50, InfJump = false,
    Slide = false, SlideSpeed = 55,
    Fly = false, FlySpeed = 40,
    Noclip = false, Fullbright = false, FBBrightness = 2, FBAmbient = 70, NoFog = false,
    ACM = false, VoidGuard = false,
    FloatButtons = UserInputService.TouchEnabled, BtnACM = true, BtnFly = true, BtnSpeedHack = true,
    InstantPrompt = false,
    Key_ACM = "X", Key_Noclip = "N", Key_Fly = "G", Key_Speed = "B", Key_Slide = "Z", Key_SpeedHack = "C",
    Key_Hub = "RightShift",
}
for _, n in ipairs(ENTITY_LIST) do Ex.NotifyFilter[n] = not NOT_WORTH[n] end
Ex.NotifyFilter.Dupe = true

local FX = {}
local St = {
    Seen = setmetatable({}, { __mode = "k" }), Last = {},
    ReadyAt = os.clock() + 5,
    PhaseUntil = 0, LastLight = 0,
    Cur = 0, SpeedCap = 0, GlideScale = 1, Penalty = 0, LastSnap = 0, LastNote = 0, Snaps = 0,
    BoostT = 0, BoostKind = "", LastAttr = 0, LastPrompt = 0, GlideCd = 0,
    PromptOrig = setmetatable({}, { __mode = "k" }),
    BadgeSound = "rbxassetid://10469938989",
}

local function AssetUrl(v)
    v = tostring(v or ""):gsub("%s", "")
    if v == "" then return nil end
    if v:match("^%d+$") then return "rbxassetid://" .. v end
    return v
end

local function NotifyUI(title, content)
    pcall(function() WindUI:Notify({ Title = title, Content = content, Duration = 2 }) end)
end

local function PlayToastSound()
    if not Ex.NotifySound then return end
    local s = Instance.new("Sound")
    s.SoundId = AssetUrl(Ex.NotifySoundId) or St.BadgeSound
    s.Volume = Ex.NotifyVolume / 100
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 8)
end

local function NativeToast(title, desc, reason)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("MainUI")
    local holder = main and main:FindFirstChild("AchievementsHolder")
    local template = holder and holder:FindFirstChild("Achievement")
    if not template then return false end
    local okv, vis = pcall(function() return main.Enabled ~= false and holder.Visible ~= false end)
    if okv and not vis then return false end

    local a = template:Clone()
    local frame = a:FindFirstChild("Frame")
    local titleLabel = a:FindFirstChild("Title", true)
    if not frame or not titleLabel or not titleLabel:IsA("TextLabel") then
        a:Destroy()
        return false
    end

    a.Name = "RON_Alert"
    titleLabel.Text = title
    local d = a:FindFirstChild("Desc", true)
    if d and d:IsA("TextLabel") then d.Text = desc or "" end
    local r = a:FindFirstChild("Reason", true)
    if r and r:IsA("TextLabel") then r.Text = reason or "" end

    local icon = AssetUrl(Ex.NotifyIconId)
    local img = frame:FindFirstChild("ImageLabel")
    if icon and img and img:IsA("ImageLabel") then img.Image = icon end

    local glow = frame:FindFirstChild("Glow", true)
    local snd = a:FindFirstChildWhichIsA("Sound", true)
    if snd then
        snd.SoundId = AssetUrl(Ex.NotifySoundId) or St.BadgeSound
        snd.Volume = Ex.NotifySound and (Ex.NotifyVolume / 100) or 0
    end

    local target = template.Size
    if target.Y.Scale <= 0 then target = UDim2.new(1, 0, 0.2, 0) end

    a.Visible = true
    a.Size = UDim2.new(0, 0, 0, 0)
    frame.Position = UDim2.new(1.1, 0, 0, 0)
    a.Parent = holder

    if Ex.NotifySound then
        if snd then pcall(function() snd:Play() end) else PlayToastSound() end
    end

    TweenService:Create(a, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = target }):Play()
    task.spawn(function()
        task.wait(0.8)
        if not a.Parent then return end
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0, 0, 0, 0) }):Play()
        if glow and glow:IsA("ImageLabel") then
            TweenService:Create(glow, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ImageTransparency = 1 }):Play()
        end
        task.wait(Ex.NotifyDuration)
        if not a.Parent then return end
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1.1, 0, 0, 0) }):Play()
        task.wait(0.5)
        if not a.Parent then return end
        TweenService:Create(a, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(1, 0, -0.1, 0) }):Play()
        task.wait(0.5)
        a:Destroy()
    end)
    return true
end

local function GetToastHost()
    if St.Host and St.Host.Parent then return St.Host end
    local f = Instance.new("Frame")
    f.Name = "RON_Toasts"
    f.BackgroundTransparency = 1
    f.AnchorPoint = Vector2.new(1, 0)
    f.Position = UDim2.new(1, -12, 0, 64)
    f.Size = UDim2.fromOffset(300, 420)
    f.Parent = Gui
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 8)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = Enum.HorizontalAlignment.Right
    l.Parent = f
    St.Host = f
    return f
end

local function CustomToast(title, desc, accent)
    accent = accent or Color3.fromRGB(255, 0, 0)
    local wrap = Instance.new("Frame")
    wrap.BackgroundTransparency = 1
    wrap.ClipsDescendants = true
    wrap.Size = UDim2.fromOffset(300, 66)
    wrap.LayoutOrder = -math.floor(os.clock() * 100)
    wrap.Parent = GetToastHost()

    local card = Instance.new("Frame")
    card.Size = UDim2.fromScale(1, 1)
    card.Position = UDim2.fromOffset(320, 0)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0
    card.Parent = wrap
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 8); cc.Parent = card
    local cs = Instance.new("UIStroke"); cs.Thickness = 2; cs.Color = accent; cs.Parent = card

    local iconBox = Instance.new("Frame")
    iconBox.Size = UDim2.fromOffset(48, 48)
    iconBox.Position = UDim2.fromOffset(9, 9)
    iconBox.BackgroundColor3 = accent
    iconBox.BackgroundTransparency = 0.75
    iconBox.BorderSizePixel = 0
    iconBox.Parent = card
    local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(0, 8); ic.Parent = iconBox

    local iconId = AssetUrl(Ex.NotifyIconId)
    if iconId then
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Size = UDim2.fromScale(1, 1)
        img.Image = iconId
        img.Parent = iconBox
    else
        local bang = Instance.new("TextLabel")
        bang.BackgroundTransparency = 1
        bang.Size = UDim2.fromScale(1, 1)
        bang.Text = "!"
        bang.TextColor3 = accent
        bang.Font = Enum.Font.GothamBold
        bang.TextSize = 30
        bang.Parent = iconBox
    end

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.fromOffset(66, 8)
    t.Size = UDim2.new(1, -76, 0, 22)
    t.Text = title
    t.TextColor3 = Color3.new(1, 1, 1)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 17
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextTruncate = Enum.TextTruncate.AtEnd
    t.Parent = card

    local dsc = Instance.new("TextLabel")
    dsc.BackgroundTransparency = 1
    dsc.Position = UDim2.fromOffset(66, 31)
    dsc.Size = UDim2.new(1, -76, 0, 28)
    dsc.Text = desc or ""
    dsc.TextColor3 = Color3.fromRGB(190, 190, 190)
    dsc.Font = Enum.Font.Gotham
    dsc.TextSize = 13
    dsc.TextWrapped = true
    dsc.TextXAlignment = Enum.TextXAlignment.Left
    dsc.TextYAlignment = Enum.TextYAlignment.Top
    dsc.Parent = card

    PlayToastSound()
    TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(0, 0) }):Play()
    task.delay(Ex.NotifyDuration + 0.45, function()
        if not wrap.Parent then return end
        TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.fromOffset(320, 0) }):Play()
        task.wait(0.45)
        wrap:Destroy()
    end)
end

function FX.ShowToast(title, desc, reason, accent)
    if Ex.NotifyStyle == "Doors Achievement" then
        local ok, shown = pcall(NativeToast, title, desc, reason)
        if ok and shown then return end
    end
    pcall(CustomToast, title, desc, accent)
end

local function ShowEntityToast(label)
    local tip = ""
    if Ex.NotifyTips then tip = ENTITY_TIPS[label] or "Be careful!" end
    FX.ShowToast(label .. " has appeared!", tip, "Mode: " .. Mode.Name, Cfg.Categories.entities.Color)
end

OnEntitySeen = function(label, inst)
    if not Ex.Notify or os.clock() < St.ReadyAt then return end
    if St.Seen[inst] then return end
    St.Seen[inst] = true
    if not Ex.NotifyFilter[label] then return end
    local now = os.clock()
    local cd = Ex.NotifyCooldown
    if label:find("Glitch", 1, true) then cd = math.max(cd, 20) end
    if St.Last[label] and now - St.Last[label] < cd then return end
    St.Last[label] = now
    ShowEntityToast(label)
    if Ex.EntityChat then
        pcall(function()
            local msg = label .. " " .. (Ex.EntityChatMessage or "spawned!")
            local RS = game:GetService("ReplicatedStorage")
            local folder = RS:FindFirstChild("DefaultChatSystemEvents")
            local event = folder and folder:FindFirstChild("SayMessageRequest")
            if event then event:FireServer(msg, "All") end
        end)
    end
end

Workspace.ChildAdded:Connect(function(m)
    if not m:IsA("Model") or Players:GetPlayerFromCharacter(m) then return end
    local ok, label = pcall(EntityLabel, m.Name, false)
    if ok and label and label ~= "Mandrake" then pcall(OnEntitySeen, label, m) end
end)

print("[AMBUSH HUB] Loaded Alerts")
print("[AMBUSH HUB] Loading Player Tab")
local function GetParts()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if hum and root and hum.Health > 0 then return char, hum, root end
    return nil
end

local Hooks = {}
local NoclipParts = {}
local Saved = {}

local function RestoreCollide()
    for p, v in pairs(NoclipParts) do
        if p.Parent then p.CanCollide = v end
        NoclipParts[p] = nil
    end
end

local function Apply(id, v)
    Ex[id] = v
    local h = Hooks[id]
    if h then pcall(h, v) end
    if FX.UpdateButtons then FX.UpdateButtons() end
end

local function SetFeature(id, v)
    Apply(id, v)
    if Setters[id] then Setters[id](v) end
end

local function Flip(id, label)
    SetFeature(id, not Ex[id])
    NotifyUI(label, Ex[id] and "Enabled" or "Disabled")
end

Hooks.Speed = function(v)
    local _, hum = GetParts()
    St.Cur = 0
    if not hum then return end
    if v then
        Saved.WS = Saved.WS or hum.WalkSpeed
    elseif Saved.WS then
        if St.WSTouched then hum.WalkSpeed = Saved.WS end
        St.WSTouched, Saved.WS = nil, nil
    end
end

Hooks.SpeedHack = function(v)
    local _, hum = GetParts()
    if not hum then return end
    if v then
        Saved.HackWS = Saved.HackWS or hum.WalkSpeed
    elseif Saved.HackWS then
        hum.WalkSpeed = Saved.HackWS
        Saved.HackWS = nil
    end
end

function FX.GameAbility(kind, on)
    local char = LocalPlayer.Character
    if not char then return end
    St.Attr = St.Attr or {}
    local main = "Can" .. (kind == "jump" and "Jump" or "Slide")
    local targets = { [main] = (LocalPlayer:GetAttribute(main) ~= nil) and LocalPlayer or char }
    for _, holder in ipairs({ char, LocalPlayer }) do
        for name, val in pairs(holder:GetAttributes()) do
            local l = name:lower()
            if type(val) == "boolean" and l:find(kind, 1, true)
                and (l:find("can", 1, true) or l:find("enable", 1, true) or l:find("allow", 1, true)) then
                targets[name] = holder
            end
        end
    end
    for name, holder in pairs(targets) do
        local id = holder.Name .. ":" .. name
        if on then
            if St.Attr[id] == nil then St.Attr[id] = { holder, holder:GetAttribute(name) } end
            if holder:GetAttribute(name) ~= true then holder:SetAttribute(name, true) end
        elseif St.Attr[id] then
            local saved = St.Attr[id]
            pcall(function() saved[1]:SetAttribute(name, saved[2]) end)
            St.Attr[id] = nil
        end
    end
end

Hooks.Jump = function(v)
    FX.GameAbility("jump", v)
    local _, hum = GetParts()
    if not hum then return end
    if v then
        if Saved.JumpPower == nil then
            Saved.JumpPower, Saved.UseJP = hum.JumpPower, hum.UseJumpPower
        end
    elseif Saved.JumpPower ~= nil then
        hum.UseJumpPower = Saved.UseJP
        hum.JumpPower = Saved.JumpPower
        Saved.JumpPower, Saved.UseJP = nil, nil
    end
end

Hooks.Slide = function(v)
    FX.GameAbility("slide", v)
    if not v and FX.StopSlide then FX.StopSlide() end
end

print("[AMBUSH HUB] Loaded Player Tab")
print("[AMBUSH HUB] Loading Automation")
function FX.MakeInstant(pp)
    if not pp:IsA("ProximityPrompt") then return end
    if St.PromptOrig[pp] == nil then St.PromptOrig[pp] = pp.HoldDuration end
    pp.HoldDuration = 0
end

Hooks.InstantPrompt = function(v)
    if v then
        task.spawn(function()
            local n = 0
            for _, d in ipairs(Workspace:GetDescendants()) do
                if not Ex.InstantPrompt then return end
                if d:IsA("ProximityPrompt") then pcall(FX.MakeInstant, d) end
                n = n + 1
                if n % 400 == 0 then task.wait() end
            end
        end)
        if not St.PromptConn then
            St.PromptConn = Workspace.DescendantAdded:Connect(function(d)
                if Ex.InstantPrompt and d:IsA("ProximityPrompt") then task.defer(pcall, FX.MakeInstant, d) end
            end)
        end
    else
        if St.PromptConn then St.PromptConn:Disconnect(); St.PromptConn = nil end
        for pp, orig in pairs(St.PromptOrig) do
            if pp.Parent then pp.HoldDuration = orig end
            St.PromptOrig[pp] = nil
        end
    end
end

Hooks.Fly = function(v)
    local _, hum, root = GetParts()
    if not hum then return end
    hum.PlatformStand = v and true or false
    if not v then root.AssemblyLinearVelocity = Vector3.zero end
end

Hooks.Noclip = function(v)
    if not v and not Ex.ACM then RestoreCollide() end
end

Hooks.ACM = function(v)
    if not v and not Ex.Noclip then RestoreCollide() end
end

Hooks.Fullbright = function(v)
    if v then
        if not St.Light then
            St.Light = {
                Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
            }
        end
    elseif St.Light then
        for k, val in pairs(St.Light) do pcall(function() Lighting[k] = val end) end
        St.Light = nil
    end
end

St.AtmoOrig = setmetatable({}, { __mode = "k" })
Hooks.NoFog = function(v)
    if v then
        if not St.Fog then St.Fog = { FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart } end
        St.LastLight = 0
    else
        if St.Fog then
            for k, val in pairs(St.Fog) do pcall(function() Lighting[k] = val end) end
            St.Fog = nil
        end
        for a, o in pairs(St.AtmoOrig) do
            if a.Parent then pcall(function() a.Density, a.Haze = o[1], o[2] end) end
            St.AtmoOrig[a] = nil
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    NoclipParts, Saved = {}, {}
    St.PhaseUntil, St.LastSafe, St.Glide, St.LastFlat, St.Attr, St.Cur, St.WSTouched = 0, nil, nil, nil, nil, 0, nil
    if FX.StopSlide then pcall(FX.StopSlide) end
end)

print("[AMBUSH HUB] Loaded Automation")
print("[AMBUSH HUB] Loading Anticheat Tab")
local Slide = { t0 = 0, dur = 0.7, dir = nil, cd = 0 }

function FX.StopSlide()
    Slide.dir = nil
    if Slide.LV then pcall(function() Slide.LV:Destroy() end); Slide.LV = nil end
    if Slide.Att then pcall(function() Slide.Att:Destroy() end); Slide.Att = nil end
    local _, hum = GetParts()
    if hum then hum.CameraOffset = Vector3.zero end
end

local function DoSlide()
    if not Ex.Slide then
        NotifyUI("Slide", "Turn on Slide in the Player tab first.")
        return
    end
    local _, hum, root = GetParts()
    if not hum then return end
    local now = os.clock()
    if now < Slide.cd then return end
    local md = hum.MoveDirection
    local look = root.CFrame.LookVector
    local dir
    if md.Magnitude > 0.05 then
        dir = Vector3.new(md.X, 0, md.Z).Unit
    else
        dir = Vector3.new(look.X, 0, look.Z).Unit
    end
    FX.StopSlide()
    Slide.dir, Slide.t0, Slide.cd = dir, now, now + Slide.dur + 0.4
    St.BoostT, St.BoostKind = now, "slide"
    pcall(function()
        local att = Instance.new("Attachment")
        att.Name = "R4_SlideAtt"
        att.Parent = root
        Slide.Att = att
        local lv = Instance.new("LinearVelocity")
        lv.Name = "R4_Slide"
        lv.Attachment0 = att
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
        lv.PrimaryTangentAxis = Vector3.new(1, 0, 0)
        lv.SecondaryTangentAxis = Vector3.new(0, 0, 1)
        lv.ForceLimitsEnabled = false
        lv.PlaneVelocity = Vector2.new(dir.X * Ex.SlideSpeed * St.GlideScale, dir.Z * Ex.SlideSpeed * St.GlideScale)
        lv.Parent = root
        Slide.LV = lv
    end)
end

local RayP = RaycastParams.new()
RayP.FilterType = Enum.RaycastFilterType.Exclude
RayP.RespectCanCollide = true
local OverP = OverlapParams.new()
OverP.FilterType = Enum.RaycastFilterType.Exclude
OverP.RespectCanCollide = true

function FX.Speed(hum, root, dt, now)
    local base
    if Ex.SpeedMethod == "WalkSpeed" then
        if Saved.WS == nil then Saved.WS = hum.WalkSpeed end
        base = Saved.WS
    else
        if St.WSTouched and Saved.WS then hum.WalkSpeed = Saved.WS; St.WSTouched = nil end
        base = hum.WalkSpeed
    end
    local target = Ex.SpeedValue
    local md = hum.MoveDirection
    if md.Magnitude < 0.05 or target <= base then
        St.Cur = base
        if Ex.SpeedMethod == "WalkSpeed" and St.WSTouched then hum.WalkSpeed = base end
        return
    end
    St.Cur = math.min(target, math.max(St.Cur, base) + 45 * dt)
    St.BoostT, St.BoostKind = now, "speed"
    local f = Vector3.new(md.X, 0, md.Z).Unit
    if Ex.SpeedMethod == "WalkSpeed" then
        hum.WalkSpeed, St.WSTouched = St.Cur, true
    elseif Ex.SpeedMethod == "CFrame" then
        root.CFrame = root.CFrame + f * ((St.Cur - base) * dt)
    else
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(f.X * St.Cur, v.Y, f.Z * St.Cur)
    end
end

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local want = Ex.Noclip
    if want then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                if NoclipParts[p] == nil then NoclipParts[p] = p.CanCollide end
                p.CanCollide = false
            end
        end
    elseif next(NoclipParts) then
        RestoreCollide()
    end
end)

RunService.Heartbeat:Connect(function(dt)
    local now = os.clock()

    if (Ex.Fullbright or Ex.NoFog) and now - St.LastLight > 0.2 then
        St.LastLight = now
        pcall(function()
            if Ex.Fullbright then
                local amb = math.floor(math.clamp(Ex.FBAmbient or 70, 0, 100) / 100 * 255 + 0.5)
                local c = Color3.fromRGB(amb, amb, amb)
                Lighting.Brightness = math.clamp(Ex.FBBrightness or 2, 0, 10)
                Lighting.ClockTime = 14
                Lighting.GlobalShadows = false
                Lighting.Ambient = c
                Lighting.OutdoorAmbient = c
            end
            if Ex.NoFog then
                Lighting.FogEnd = 100000
                Lighting.FogStart = 100000
                for _, a in ipairs(Lighting:GetChildren()) do
                    if a:IsA("Atmosphere") then
                        if not St.AtmoOrig[a] then St.AtmoOrig[a] = { a.Density, a.Haze } end
                        a.Density, a.Haze = 0, 0
                    end
                end
            end
        end)
    end

    if Ex.InstantPrompt and now - St.LastPrompt > 0.5 then
        St.LastPrompt = now
        for pp in pairs(St.PromptOrig) do
            if pp.Parent and pp.HoldDuration ~= 0 then pp.HoldDuration = 0 end
        end
    end

    local char, hum, root = GetParts()
    if not char then return end

    if hum.FloorMaterial ~= Enum.Material.Air then St.LastSafe = root.CFrame end
    if Ex.VoidGuard and St.LastSafe and (Ex.Noclip or Ex.ACM or Ex.Fly)
        and root.Position.Y < St.LastSafe.Position.Y - 60 then
        root.CFrame = St.LastSafe + Vector3.new(0, 3, 0)
        root.AssemblyLinearVelocity = Vector3.zero
    end

    if Ex.Speed and not Ex.Fly and not Slide.dir and not St.Glide and not FX.LadderPause then
        FX.Speed(hum, root, dt, now)
    end

    if (Ex.SpeedHack or FX.BotSpeed) and not Ex.Fly and not FX.LadderPause then
        local want = FX.BotSpeed or Ex.SpeedHackValue
        if hum.WalkSpeed ~= want then hum.WalkSpeed = want end
    end

    if Ex.Jump and not FX.JumpLocked then
        if now - St.LastAttr > 0.25 then
            St.LastAttr = now
            pcall(FX.GameAbility, "jump", true)
        end
        pcall(function()
            hum.UseJumpPower = true
            hum.JumpPower = Ex.JumpPower
            hum.JumpHeight = Ex.JumpPower ^ 2 / (2 * Workspace.Gravity)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end)
    end
    if Ex.Slide and now - St.LastAttr > 0.25 then
        St.LastAttr = now
        pcall(FX.GameAbility, "slide", true)
    end

    if Slide.dir then
        local a = (now - Slide.t0) / Slide.dur
        local blockedAhead = false
        if not (Ex.Noclip or Ex.ACM) then
            RayP.FilterDescendantsInstances = { char }
            local hit = Workspace:Raycast(root.Position, Slide.dir * 2.6, RayP)
            blockedAhead = hit ~= nil and math.abs(hit.Normal.Y) < 0.6
        end
        if a >= 1 or blockedAhead then
            FX.StopSlide()
        else
            local sp = Ex.SlideSpeed * St.GlideScale * (1 - a) ^ 1.5
            St.BoostT, St.BoostKind = now, "slide"
            if Slide.LV and Slide.LV.Parent then
                Slide.LV.PlaneVelocity = Vector2.new(Slide.dir.X * sp, Slide.dir.Z * sp)
            else
                local v = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(Slide.dir.X * sp, v.Y, Slide.dir.Z * sp)
            end
            hum.CameraOffset = hum.CameraOffset:Lerp(Vector3.new(0, -1.4, 0), math.min(1, dt * 14))
        end
    end

    if Ex.Fly then
        local cam = Workspace.CurrentCamera
        local md = hum.MoveDirection
        local vert = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then vert = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vert = -1 end
        if vert == 0 and IS_MOBILE and cam and md.Magnitude > 0.05 then
            local pitch = cam.CFrame.LookVector.Y
            if math.abs(pitch) > 0.15 then vert = math.clamp(pitch * 1.5, -1, 1) end
        end
        root.AssemblyLinearVelocity = Vector3.new(md.X * Ex.FlySpeed, vert * Ex.FlySpeed, md.Z * Ex.FlySpeed)
        St.BoostT, St.BoostKind = now, "fly"
    end

end)

UserInputService.JumpRequest:Connect(function()
    local _, hum = GetParts()
    if not hum then return end
    if Ex.InfJump then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    elseif Ex.Jump and hum.FloorMaterial ~= Enum.Material.Air then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

print("[AMBUSH HUB] Loaded Anticheat Tab")
print("[AMBUSH HUB] Loading PC Keybinds")
FX.HubOpen = true
FX.ToggleHub = function()
    local ok = false
    if type(Window.Toggle) == "function" then
        ok = pcall(function() Window:Toggle() end)
    end
    if not ok then
        if FX.HubOpen then
            ok = pcall(function() Window:Close() end)
        else
            ok = pcall(function() Window:Open() end)
        end
    end
    if ok then FX.HubOpen = not FX.HubOpen end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local k = input.KeyCode.Name
    if k == Ex.Key_Hub then
        local pressed = os.clock()
        task.delay(0.08, function()
            if (FX.LastKeySet or 0) >= pressed - 0.05 then return end
            FX.ToggleHub()
        end)
    elseif k == Ex.Key_ACM then Flip("ACM", "Anticheat Manipulator")
    elseif k == Ex.Key_Noclip then Flip("Noclip", "Noclip")
    elseif k == Ex.Key_Fly then Flip("Fly", "Fly")
    elseif k == Ex.Key_Speed then Flip("Speed", "Speed")
    elseif k == Ex.Key_SpeedHack then Flip("SpeedHack", "Speed Hack")
    elseif k == Ex.Key_Slide then DoSlide()
    elseif k == Ex.Key_PosSpoof then Flip("PositionSpoof", "Position Spoof") end
end)

print("[AMBUSH HUB] Loaded PC Keybinds")
print("[AMBUSH HUB] Loading Mobile Floating Buttons")
local Floating = {}
local TweenService = game:GetService("TweenService")

-- Premium floating button: circular, gradient fill, glow ring on hover,
-- green accent when active. Smooth press animation.
local function MakeFloat(text, y, onTap, getOn, flag)
    -- Outer holder for glow + drag
    local holder = Instance.new("Frame")
    holder.Name = "RON_Float_" .. text
    holder.Size = UDim2.fromOffset(54, 54)
    holder.Position = UDim2.new(1, -72, 0.5, y)
    holder.BackgroundTransparency = 1
    holder.Visible = false
    holder.ZIndex = 50
    holder.Parent = Gui

    -- Glow ring (behind button, visible on hover / when active)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.fromScale(0.5, 0.5)
    glow.Size = UDim2.fromOffset(64, 64)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084" -- soft glow
    glow.ImageColor3 = Color3.fromRGB(0, 255, 120)
    glow.ImageTransparency = 1
    glow.ZIndex = 49
    glow.Parent = holder

    -- Button body (circle)
    local b = Instance.new("TextButton")
    b.Name = "Btn"
    b.AnchorPoint = Vector2.new(0.5, 0.5)
    b.Position = UDim2.fromScale(0.5, 0.5)
    b.Size = UDim2.fromOffset(44, 44)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    b.BackgroundTransparency = 0.1
    b.AutoButtonColor = false
    b.Text = text
    b.TextColor3 = Color3.fromRGB(235, 235, 245)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.ZIndex = 51
    b.Parent = holder
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0) -- full circle
    c.Parent = b

    -- Gradient fill (subtle)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 44)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 24)),
    })
    grad.Rotation = 45
    grad.Parent = b

    -- Accent stroke (changes color when active)
    local st = Instance.new("UIStroke")
    st.Name = "Stroke"
    st.Thickness = 1.5
    st.Color = Color3.fromRGB(90, 90, 110)
    st.Transparency = 0.2
    st.Parent = b

    -- Small status dot at bottom (green when active)
    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Position = UDim2.new(0.5, 0, 1, -4)
    dot.Size = UDim2.fromOffset(6, 6)
    dot.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    dot.BorderSizePixel = 0
    dot.ZIndex = 52
    dot.Parent = b
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    -- Hover / press animations
    local hovering = false
    local function refreshVisual()
        local on = getOn and getOn() or false
        local accent = on and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(90, 90, 110)
        st.Color = accent
        dot.BackgroundColor3 = on and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(70, 70, 80)
        -- glow shows when active OR hovering
        local targetGlow = (on or hovering) and 0.3 or 1
        TweenService:Create(glow, TweenInfo.new(0.2), { ImageTransparency = targetGlow, ImageColor3 = accent }):Play()
    end

    b.MouseEnter:Connect(function()
        hovering = true
        TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(48, 48) }):Play()
        refreshVisual()
    end)
    b.MouseLeave:Connect(function()
        hovering = false
        TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(44, 44) }):Play()
        refreshVisual()
    end)

    -- Drag logic (on the BUTTON itself so touches/mouse are caught directly)
    local dragging, moved = false, false
    local startPt, startPos = Vector2.zero, Vector2.zero
    b.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, moved = true, false
            startPt = Vector2.new(input.Position.X, input.Position.Y)
            startPos = holder.AbsolutePosition
            TweenService:Create(b, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(40, 40) }):Play()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = Vector2.new(input.Position.X, input.Position.Y) - startPt
            if d.Magnitude > 10 then moved = true end
            if moved then holder.Position = UDim2.fromOffset(startPos.X + d.X, startPos.Y + d.Y) end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
            TweenService:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(44, 44) }):Play()
            if not moved then pcall(onTap) end
        end
    end)

    Floating[#Floating + 1] = { Holder = holder, Btn = b, Stroke = st, Dot = dot, Glow = glow, GetOn = getOn, Flag = flag, Refresh = refreshVisual }
end

MakeFloat("ACM", -78, function() Flip("ACM", "Anticheat Manipulator") end, function() return Ex.ACM end, "BtnACM")
MakeFloat("FLY", -20, function() Flip("Fly", "Fly") end, function() return Ex.Fly end, "BtnFly")
MakeFloat("SPD", 38, function() Flip("SpeedHack", "Speed Hack") end, function() return Ex.SpeedHack end, "BtnSpeedHack")
-- New floating Auto Interact button (toggle + force-rescan so loop picks up)
if Ex.BtnAutoInteract == nil then Ex.BtnAutoInteract = true end
MakeFloat("INT", 96, function()
    Ex.AutoInteract = not Ex.AutoInteract
    -- kick the AI loop awake immediately so it reacts this frame
    if Ex.AutoInteract and AI and AI.Beat then
        AI.Beat = os.clock()
    end
    pcall(function() WindUI:Notify({ Title = "Auto Interact", Content = Ex.AutoInteract and "Enabled" or "Disabled", Duration = 2 }) end)
end, function() return Ex.AutoInteract == true end, "BtnAutoInteract")

function FX.UpdateButtons()
    for _, f in ipairs(Floating) do
        f.Holder.Visible = Ex.FloatButtons and (f.Flag == nil or Ex[f.Flag] ~= false)
        if f.Refresh then f.Refresh() end
    end
end

print("[AMBUSH HUB] Loaded Mobile Floating Buttons")
print("[AMBUSH HUB] Loading Extra UI Helpers")
local KEY_CHOICES = { "RightShift", "RightControl", "Insert", "Home", "X", "N", "G", "B", "Z", "V", "H", "J", "K", "L", "R", "T", "Y", "U", "M", "C", "F", "Q" }

local function AddKeybind(tab, id, title, desc, default)
    R4N_KeyTab[id] = tab
    local function set(v)
        local name = typeof(v) == "EnumItem" and v.Name or tostring(v)
        local ok = pcall(function() return Enum.KeyCode[name] end)
        if ok then Ex[id] = name end
        FX.LastKeySet = os.clock()
    end
    local el
    local ok = pcall(function()
        el = tab:Keybind({ Title = title, Desc = desc, Value = default, Callback = set })
    end)
    if ok and el then
        Setters[id] = function(v) pcall(function() el:Set(v) end) end
    else
        local dd = tab:Dropdown({ Title = title, Desc = desc, Values = KEY_CHOICES, Value = default, Callback = set })
        Setters[id] = function(v) pcall(function() dd:Select(v) end) end
    end
end

local function AddInput(tab, id, title, desc, placeholder, value)
    R4N_KeyTab[id] = tab
    local el = tab:Input({
        Title = title, Desc = desc, Placeholder = placeholder, Value = value,
        Callback = function(t) Ex[id] = tostring(t or "") end
    })
    Setters[id] = function(v) pcall(function() el:Set(v) end) end
end

print("[AMBUSH HUB] Loaded Extra UI Helpers")
print("[AMBUSH HUB] Loading Alerts Tab")
local function NotifyList()
    local list = {}
    for _, n in ipairs(CurrentEntityList()) do list[#list + 1] = n end
    if Active.dupe then list[#list + 1] = "Dupe" end
    return list
end

local function NotifySelected()
    local out = {}
    for _, n in ipairs(NotifyList()) do
        if Ex.NotifyFilter[n] then out[#out + 1] = n end
    end
    return out
end

AlertsTab:Section({ Title = "Entity Alerts" })
AddToggle(AlertsTab, "Notify", "Entity Notifier",
    "Shows a DOORS-style popup notification with sound when one of the selected entities spawns, e.g. \"Rush has spawned!\". Works even with ESP Entities off.",
    Ex.Notify, function(v) Ex.Notify = v end)

local NotifyDD = AlertsTab:Dropdown({
    Title = "Notify about",
    Desc = "The list contains only entities of the detected mode. Safe or minor ones (Timothy, Snare, Bob, Jeff...) start unselected, but you can enable them.",
    Values = NotifyList(),
    Value = NotifySelected(),
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        local set = {}
        for _, n in ipairs(selected or {}) do set[n] = true end
        for _, n in ipairs(NotifyList()) do Ex.NotifyFilter[n] = set[n] == true end
    end
})
Setters.NotifyFilter = function(list) pcall(function() NotifyDD:Select(list) end) end

function FX.RefreshNotify()
    pcall(function() NotifyDD:Refresh(NotifyList()) end)
    Setters.NotifyFilter(NotifySelected())
end

AlertsTab:Button({
    Title = "Select recommended",
    Desc = "Marks only the dangerous entities of this mode.",
    Callback = function()
        for _, n in ipairs(NotifyList()) do Ex.NotifyFilter[n] = not NOT_WORTH[n] end
        Setters.NotifyFilter(NotifySelected())
    end
})
AlertsTab:Button({
    Title = "Select all",
    Desc = "Notify about every entity of this mode.",
    Callback = function()
        for _, n in ipairs(NotifyList()) do Ex.NotifyFilter[n] = true end
        Setters.NotifyFilter(NotifySelected())
    end
})
AlertsTab:Button({
    Title = "Clear all",
    Desc = "Deselect every entity.",
    Callback = function()
        for _, n in ipairs(NotifyList()) do Ex.NotifyFilter[n] = false end
        Setters.NotifyFilter({})
    end
})

-- EntityChat toggle (ported from rush.txt)
Ex.EntityChat = false
Ex.EntityChatMessage = "spawned!"
AddToggle(AlertsTab, "EntityChat", "Notify in chat", "Sends a chat message when an entity spawns (uses SayMessageRequest).", Ex.EntityChat, function(v) Ex.EntityChat = v end)
AlertsTab:Input({ Title = "Chat message", Desc = "Text appended to the entity name.", Placeholder = "spawned!", Value = Ex.EntityChatMessage, Callback = function(v) Ex.EntityChatMessage = tostring(v or "") end })

AlertsTab:Section({ Title = "Notification settings" })
AddDropdown(AlertsTab, "NotifyStyle", "Notification style",
    "Doors Achievement clones the game's native badge popup with the same animation and sound. Custom Toast draws a simple popup when the native one is missing.",
    { "Doors Achievement", "Custom Toast" }, Ex.NotifyStyle, function(v) Ex.NotifyStyle = v end)
AddToggle(AlertsTab, "NotifySound", "Play sound", "Plays a sound with every notification.", Ex.NotifySound, function(v) Ex.NotifySound = v end)
AddSlider(AlertsTab, "NotifyVolume", "Volume (%)", "Notification sound volume.", 0, 100, Ex.NotifyVolume, function(v) Ex.NotifyVolume = v end)
AddSlider(AlertsTab, "NotifyDuration", "Duration (sec)", "How long the popup stays on screen.", 2, 12, Ex.NotifyDuration, function(v) Ex.NotifyDuration = v end)
AddSlider(AlertsTab, "NotifyCooldown", "Per-entity cooldown (sec)", "Avoids spam when one entity spawns several times in a row (glitch entities, Ambush returns...)", 0, 30, Ex.NotifyCooldown, function(v) Ex.NotifyCooldown = v end)
AddToggle(AlertsTab, "NotifyTips", "Show tips", "Adds a short survival tip below the message (Hide in a closet, Don't look at it...)", Ex.NotifyTips, function(v) Ex.NotifyTips = v end)
AddInput(AlertsTab, "NotifySoundId", "Custom sound ID (optional)", "Roblox audio asset ID instead of the default. Leave empty for default.", "e.g. 1234567890", Ex.NotifySoundId)
AddInput(AlertsTab, "NotifyIconId", "Custom icon ID (optional)", "Roblox image asset ID in the popup. Leave empty for default.", "e.g. 1234567890", Ex.NotifyIconId)
AlertsTab:Button({
    Title = "Test notification",
    Desc = "Shows an example \"Rush has spawned!\" popup with current settings.",
    Callback = function() ShowEntityToast("Rush") end
})

local prevApplied = OnModeApplied
OnModeApplied = function()
    if prevApplied then prevApplied() end
    FX.RefreshNotify()
end

print("[AMBUSH HUB] Loaded Alerts Tab")
PlayerTab:Section({ Title = "Speed" })
AddToggle(PlayerTab, "Speed", "Speed", "Makes you faster than normal (up to 90).", Ex.Speed, function(v) Apply("Speed", v) end)
AddSlider(PlayerTab, "SpeedValue", "Speed", "Target speed in studs/sec. Normal Doors walk is about 16.", 4, 100, Ex.SpeedValue, function(v) Ex.SpeedValue = v end)
AddDropdown(PlayerTab, "SpeedMethod", "Speed method",
    "Velocity (recommended): a smooth push the server tolerates better. CFrame: tiny position steps. WalkSpeed: changes the value directly (easiest to detect).",
    { "Velocity", "CFrame", "WalkSpeed" }, Ex.SpeedMethod, function(v) Ex.SpeedMethod = v end)
AddToggle(PlayerTab, "SpeedHack", "Speed Hack", "Changes real walk speed (1-100). Works together with Anticheat Bypass.", Ex.SpeedHack, function(v) Apply("SpeedHack", v) end)
AddSlider(PlayerTab, "SpeedHackValue", "Speed Hack value", "Walk speed in studs/sec.", 1, 100, Ex.SpeedHackValue, function(v) Ex.SpeedHackValue = v end)

PlayerTab:Section({ Title = "Jump" })
AddToggle(PlayerTab, "Jump", "Enable Jump", "Enables the game's native jump and lets you tune the power, even where the game disables it.", Ex.Jump, function(v) Apply("Jump", v) end)
AddSlider(PlayerTab, "JumpPower", "Jump Power", "Jump height.", 20, 120, Ex.JumpPower, function(v) Ex.JumpPower = v end)
AddToggle(PlayerTab, "InfJump", "Infinite Jump", "Jump in the air every time you press jump.", Ex.InfJump, function(v) Ex.InfJump = v end)

PlayerTab:Section({ Title = "Slide" })
AddToggle(PlayerTab, "Slide", "Enable Slide", "Enables the game's native slide and adds a forward slide with the camera lowered. Stops at walls. PC: hotkey, mobile: SLIDE button.", Ex.Slide, function(v) Apply("Slide", v) end)
AddSlider(PlayerTab, "SlideSpeed", "Slide Speed", "Initial slide speed. Fades smoothly.", 30, 90, Ex.SlideSpeed, function(v) Ex.SlideSpeed = v end)

PlayerTab:Section({ Title = "Fly & Noclip" })
AddToggle(PlayerTab, "Fly", "Fly", "Fly freely. PC: Space = up, Left Ctrl = down. Mobile: look up / down while moving.", Ex.Fly, function(v) Apply("Fly", v) end)
AddSlider(PlayerTab, "FlySpeed", "Fly Speed", "Fly speed in studs/sec.", 10, 90, Ex.FlySpeed, function(v) Ex.FlySpeed = v end)
AddToggle(PlayerTab, "Noclip", "Noclip", "Walk through walls and objects. Basic version: for careful use, also enable the Anticheat Manipulator.", Ex.Noclip, function(v) Apply("Noclip", v) end)

PlayerTab:Section({ Title = "Lighting" })
AddToggle(PlayerTab, "Fullbright", "Fullbright", "Removes darkness so you can see everything. Brightness and ambient are tuned below.", Ex.Fullbright, function(v) Apply("Fullbright", v) end)
AddSlider(PlayerTab, "FBBrightness", "Fullbright Brightness", "Lighting brightness while Fullbright is on (0 = dark, 10 = very bright). Game default is about 2.", 0, 10, Ex.FBBrightness, function(v) Ex.FBBrightness = v St.LastLight = 0 end)
AddSlider(PlayerTab, "FBAmbient", "Ambient Fullbright (%)", "Strength of the flat ambient light. Lower for a darker, more natural look; higher to see everything.", 0, 100, Ex.FBAmbient, function(v) Ex.FBAmbient = v St.LastLight = 0 end)
AddToggle(PlayerTab, "NoFog", "Remove Fog", "Removes fog and atmospheric haze. Works with or without Fullbright.", Ex.NoFog, function(v) Apply("NoFog", v) end)

print("[AMBUSH HUB] Loaded Player Tab")
print("[AMBUSH HUB] Loading Automation Tab")
Ex.AutoDoors = false
Ex.AD_Doors, Ex.AD_Gold, Ex.AD_Drawers, Ex.AD_Chests, Ex.AD_Keys = false, false, false, false, false
Ex.AD_Items, Ex.AD_Avoid, Ex.AD_Puzzles, Ex.AD_SkipSeek, Ex.AD_StopOnDeath = false, false, false, false, false
Ex.AD_Delay, Ex.AD_RoomTime, Ex.AD_StopRoom = 350, 30, 0
Ex.AD_Profile, Ex.AD_LootOrder = "Balanced", "Nearest First"
Ex.AD_Retries, Ex.AD_StuckTime, Ex.AD_MaxHide = 3, 15, 40
Ex.AD_StopMinutes, Ex.AD_LowHP = 0, 0
Ex.AD_Watchdog, Ex.AD_KeyWait, Ex.AD_ForceOpen, Ex.AD_Notify, Ex.AD_HUD = true, true, true, true, false
Ex.Bot_SpeedOn, Ex.Bot_Speed, Ex.Bot_Camera, Ex.Bot_CamSpeed = true, 22, true, 9
Ex.Bot_Jump, Ex.Bot_Crouch, Ex.Bot_HideMargin = true, true, 4
Ex.AD_Ladders, Ex.AD_KnobFarm, Ex.AD_TPFallback = true, false, false

AutomationTab:Section({ Title = "Auto Doors" })
AddToggle(AutomationTab, "AutoDoors", "Auto Doors",
    "The bot plays the floor for you. It walks (no teleports), jumps, crouches and moves the camera. It loots, grabs the key when a door is locked, opens doors and hides in a closet before Rush / Ambush / A-60 / A-120 reach you. Risky. If nothing below is selected, a recommended preset for the mode is applied.",
    Ex.AutoDoors, function(v) Apply("AutoDoors", v) end)
AddDropdown(AutomationTab, "AD_Profile", "Profile",
    "A preset of options, timings and bot speed. Click Apply profile (only enables what the current mode has).",
    { "Safe", "Balanced", "Fast", "Speedrun", "Max Loot" }, Ex.AD_Profile, function(v) Ex.AD_Profile = v end)
AutomationTab:Button({ Title = "Apply profile", Desc = "Applies the selected profile to the options and sliders below.",
    Callback = function() if R4N_AD then R4N_AD.ApplyProfile(Ex.AD_Profile, true) end end })
AutomationTab:Button({ Title = "Apply recommended settings", Desc = "Picks the best options below for the current mode.",
    Callback = function() if R4N_AD then R4N_AD.Recommended(true) end end })
AutomationTab:Button({ Title = "Show Auto Doors status", Desc = "Shows the detected mode, room, what the bot is doing and session stats.",
    Callback = function() if R4N_AD then R4N_AD.Status() end end })
AutomationTab:Button({ Title = "Force auto-fix", Desc = "Triggers an auto-fix right now (only while Auto Doors is on).",
    Callback = function()
        if R4N_AD and Ex.AutoDoors then
            R4N_AD.RecoverWhy = "manual"
        else
            pcall(function() WindUI:Notify({ Title = "Auto Doors", Content = "Turn on Auto Doors first.", Duration = 3 }) end)
        end
    end })
AutomationTab:Button({ Title = "Reset statistics", Desc = "Resets door / loot / hideout / auto-fix counters and the timer.",
    Callback = function() if R4N_AD then R4N_AD.ResetStats() end end })

AutomationTab:Section({ Title = "Auto Doors Bot" })
AddToggle(AutomationTab, "Bot_SpeedOn", "Use Bot Speed", "The bot walks with the Bot Speed below (a real walk speed hack). Turn it off to walk at your normal speed.", Ex.Bot_SpeedOn, function(v) Apply("Bot_SpeedOn", v) end)
AddSlider(AutomationTab, "Bot_Speed", "Bot Speed", "Walk speed of the bot in studs per second (4 - 100). Very high values can trigger the anticheat: use it with the Anticheat Bypass. It drops to a slow walk while sneaking past a Figure.", 4, 100, Ex.Bot_Speed, function(v) Ex.Bot_Speed = v end)
AddToggle(AutomationTab, "Bot_Camera", "Bot Moves The Camera", "The bot turns your camera towards where it walks and what it interacts with. Turn it off if you want to keep control of the camera.", Ex.Bot_Camera, function(v) Apply("Bot_Camera", v) end)
AddSlider(AutomationTab, "Bot_CamSpeed", "Camera Turn Speed", "How fast the camera turns (2 = slow and smooth, 30 = instant).", 2, 30, Ex.Bot_CamSpeed, function(v) Ex.Bot_CamSpeed = v end)
AddToggle(AutomationTab, "Bot_Jump", "Bot Can Jump", "Lets the bot jump over low obstacles and where the path asks for it. It never jumps while Strong Position Spoof has the jump locked.", Ex.Bot_Jump, function(v) Apply("Bot_Jump", v) end)
AddToggle(AutomationTab, "Bot_Crouch", "Bot Can Crouch", "Lets the bot crouch under low ceilings and sneak while a Figure is in the room.", Ex.Bot_Crouch, function(v) Apply("Bot_Crouch", v) end)
AddSlider(AutomationTab, "Bot_HideMargin", "Hide Early (seconds)", "Safety margin: the bot starts walking to a closet this many seconds before the entity would reach it.", 1, 12, Ex.Bot_HideMargin, function(v) Ex.Bot_HideMargin = v end)
AddToggle(AutomationTab, "AD_Ladders", "Use Ladders", "When the path is blocked the bot uses a ladder (never while an entity is close).", Ex.AD_Ladders, function(v) Apply("AD_Ladders", v) end)
AddToggle(AutomationTab, "AD_KnobFarm", "Knob Farm Mode", "Only works in Room 0. The bot collects all the gold and drawers of the first room, then starts the Knob Farm by itself.", Ex.AD_KnobFarm, function(v) Apply("AD_KnobFarm", v) end)
AddToggle(AutomationTab, "AD_TPFallback", "Teleport Fallback (last resort)", "Only after 5 failed auto-fixes in a row the bot may teleport next to the room entrance. Off = the bot never teleports.", Ex.AD_TPFallback, function(v) Apply("AD_TPFallback", v) end)

AutomationTab:Section({ Title = "Auto Doors Settings" })
AddToggle(AutomationTab, "AD_Doors", "Open Doors", "Walks to the next door and opens it when the room is done.", Ex.AD_Doors, function(v) Apply("AD_Doors", v) end)
AddToggle(AutomationTab, "AD_Gold", "Grab Gold & Stardust", "Collects every gold pile and stardust in the room.", Ex.AD_Gold, function(v) Apply("AD_Gold", v) end)
AddToggle(AutomationTab, "AD_Drawers", "Loot Drawers", "Opens every drawer and takes what is inside.", Ex.AD_Drawers, function(v) Apply("AD_Drawers", v) end)
AddToggle(AutomationTab, "AD_Chests", "Loot Chests & Lockers", "Opens chests, toolboxes and lockers (locked ones are skipped).", Ex.AD_Chests, function(v) Apply("AD_Chests", v) end)
AddToggle(AutomationTab, "AD_Keys", "Grab Keys & Unlock Doors", "Takes the door key and uses it on locked doors. If a door is locked and you have no key, the bot loots the room (drawers, chests, gold...) until it finds one.", Ex.AD_Keys, function(v) Apply("AD_Keys", v) end)
AddToggle(AutomationTab, "AD_KeyWait", "Keep Searching For Keys", "When a door is locked it keeps looking for the key even after the room time is over (library, puzzles...).", Ex.AD_KeyWait, function(v) Apply("AD_KeyWait", v) end)
AddToggle(AutomationTab, "AD_Items", "Grab Items", "Picks up items (uses the Auto Interact ignored items list).", Ex.AD_Items, function(v) Apply("AD_Items", v) end)
AddToggle(AutomationTab, "AD_Avoid", "Avoid Entities (Auto Hide)", "Predicts when Rush, Ambush, A-60, A-120 and similar reach you, walks to a closet and gets inside before they arrive, then leaves by itself. With no closet nearby it uses Position Spoof.", Ex.AD_Avoid, function(v) Apply("AD_Avoid", v) end)
AddToggle(AutomationTab, "AD_Puzzles", "Solve Puzzles (Library, Breakers, Anchors)", "Turns on Auto Library, Auto Padlock, Auto Breaker Room and Auto Anchors for the mode.", Ex.AD_Puzzles, function(v) Apply("AD_Puzzles", v) end)
AddToggle(AutomationTab, "AD_SkipSeek", "Skip Seek", "Skips the Seek sections (Hotel / Mines).", Ex.AD_SkipSeek, function(v) Apply("AD_SkipSeek", v) end)
AddToggle(AutomationTab, "AD_ForceOpen", "Force Open Fallback", "If a door does not open with its prompt, it asks the door to open directly.", Ex.AD_ForceOpen, function(v) Apply("AD_ForceOpen", v) end)

AutomationTab:Section({ Title = "Auto Doors Timings" })
AddSlider(AutomationTab, "AD_Delay", "Delay (ms)", "Wait between actions. Lower = faster, but riskier.", 100, 1500, Ex.AD_Delay, function(v) Ex.AD_Delay = v end)
AddSlider(AutomationTab, "AD_RoomTime", "Max Time Per Room (seconds)", "After this long it stops looting the room and moves on.", 5, 90, Ex.AD_RoomTime, function(v) Ex.AD_RoomTime = v end)
AddSlider(AutomationTab, "AD_Retries", "Max Retries Per Target", "How many times it tries an item, drawer or chest before giving up on it.", 1, 6, Ex.AD_Retries, function(v) Ex.AD_Retries = v end)
AddDropdown(AutomationTab, "AD_LootOrder", "Loot Order", "Nearest First goes to the closest target. Keys & Gold First takes keys, then gold, then everything else.",
    { "Nearest First", "Keys & Gold First" }, Ex.AD_LootOrder, function(v) Ex.AD_LootOrder = v end)

AutomationTab:Section({ Title = "Auto Doors Safety" })
AddToggle(AutomationTab, "AD_Watchdog", "Anti-Stuck Watchdog", "Detects when nothing advances and fixes it step by step: resets targets, leaves the closet, restarts helpers, forces the door and shakes the bot loose.", Ex.AD_Watchdog, function(v) Apply("AD_Watchdog", v) end)
AddSlider(AutomationTab, "AD_StuckTime", "Stuck Timeout (seconds)", "Seconds without progress before the watchdog acts.", 5, 60, Ex.AD_StuckTime, function(v) Ex.AD_StuckTime = v end)
AddSlider(AutomationTab, "AD_MaxHide", "Max Hide Time (seconds)", "Longest it waits inside a closet before it carries on anyway.", 10, 120, Ex.AD_MaxHide, function(v) Ex.AD_MaxHide = v end)
AddToggle(AutomationTab, "AD_StopOnDeath", "Stop On Death", "Turns Auto Doors off when you die.", Ex.AD_StopOnDeath, function(v) Apply("AD_StopOnDeath", v) end)
AddSlider(AutomationTab, "AD_StopRoom", "Stop At Room (0 = never)", "Turns Auto Doors off when this room is reached.", 0, 1000, Ex.AD_StopRoom, function(v) Ex.AD_StopRoom = v end)
AddSlider(AutomationTab, "AD_StopMinutes", "Stop After (minutes, 0 = never)", "Turns Auto Doors off after this much time running.", 0, 240, Ex.AD_StopMinutes, function(v) Ex.AD_StopMinutes = v end)
AddSlider(AutomationTab, "AD_LowHP", "Stop Below Health % (0 = off)", "Turns Auto Doors off if your health drops under this percentage.", 0, 90, Ex.AD_LowHP, function(v) Ex.AD_LowHP = v end)

AutomationTab:Section({ Title = "Auto Doors Display" })
AddToggle(AutomationTab, "AD_Notify", "Auto Doors Notifications", "Shows notifications for mode, auto-fixes and when it stops. Important warnings always show.", Ex.AD_Notify, function(v) Apply("AD_Notify", v) end)
AddToggle(AutomationTab, "AD_HUD", "Status HUD", "Small on-screen panel with the mode, room, current action and statistics.", Ex.AD_HUD, function(v) Apply("AD_HUD", v) end)

AutomationTab:Section({ Title = "Interaction" })
AddToggle(AutomationTab, "InstantPrompt", "Instant Proximity Prompt",
    "Removes the hold time of every interaction prompt (doors, drawers, levers, items...). Turning it off restores the original times.",
    Ex.InstantPrompt, function(v) Apply("InstantPrompt", v) end)

print("[AMBUSH HUB] Loaded Automation Tab")
print("[AMBUSH HUB] Loading Anticheat Tab")
AntiCheatTab:Section({ Title = "Anticheat Manipulator" })
AntiCheatTab:Paragraph({
    Title = "What it does",
    Desc = "The Anticheat Manipulator now uses Velocity manipulation: it moves the character very slowly forward (or pivots relative to the camera), "
        .. "which mitigates the game's anti-noclip, letting you walk through walls and doors. No guarantees: the server can still detect it, use at your own risk."
})
AddToggle(AntiCheatTab, "ACM", "Anticheat Manipulator", "Master toggle. PC: hotkey (Keybinds tab). Mobile: ACM floating button.", Ex.ACM, function(v) Apply("ACM", v) end)
AddDropdown(AntiCheatTab, "VelocityManipulationMode", "Manipulation method",
    "Velocity: a light forward push (recommended). Pivot: moves the character relative to the camera.",
    { "Velocity", "Pivot" }, Ex.VelocityManipulationMode, function(v) Ex.VelocityManipulationMode = v end)
AddToggle(AntiCheatTab, "VoidGuard", "Void Guard", "If you fall far below the last safe spot during phasing, noclip or fly, you are returned there.", Ex.VoidGuard, function(v) Ex.VoidGuard = v end)

;(function()
local Env = {
        hookmetamethod = hookmetamethod, newcclosure = newcclosure, getnamecallmethod = getnamecallmethod,
        firetouchinterest = firetouchinterest, isnetworkowner = isnetworkowner, cloneref = cloneref,
}

local function CloneReference(Object)
        if Env.cloneref then
                return Env.cloneref(Object)
        end
        return Object
end

local Services = setmetatable({}, {
        __index = function(Self, Name)
                return CloneReference(game:GetService(Name))
        end
})

local Globals = {}
FX.Globals = Globals
local Connections = {}
local Functions = {}
FX.Functions = Functions
FX.EntityDistances = EntityDistances
local Objects = { Entities = {}, SeekObstructions = {}, SeekBridges = {}, Obstructions = {} }

local ValueAliases = { NoclipToggle = "Noclip", VelocityManipulationToggle = "ACM" }
local function MakeProxy()
        return setmetatable({}, {
                __index = function(_, Key)
                        local Real = ValueAliases[Key] or Key
                        return setmetatable({}, {
                                __index = function(_, Field)
                                        if Field == "Value" then return Ex[Real] end
                                end
                        })
                end
        })
end
local Toggles = MakeProxy()
local Options = MakeProxy()

Functions.CheckCompatability = function(Array)
        for _, Name in Array do
                if not Env[Name] then
                        return false
                end
        end
        return true
end

Functions.Notify = function(Data)
        NotifyUI(Data.Title or "", Data.Body or "")
end

local LocalPlayer = Services.Players.LocalPlayer
local Character, Humanoid, RootPart, Camera
local Collision, CollisionClone, CollisionPart, CollisionPartClone
local RemotesFolder = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
local CurrentRooms = Services.Workspace:FindFirstChild("CurrentRooms")
local Floor = "Hotel"
local Ready = false
local FakeEvents = {}
local Modules = {}

Globals.AnticheatDisabled = false
Globals.SpoofOffset = 0
Globals.LastCrouchFire = tick()

local EntityDistances = {
        ["RushMoving"]    = 85,
        ["AmbushMoving"]  = 150,
        ["A60"]           = 125,
        ["A120"]          = 85,
        ["GlitchRush"]    = 90,
        ["GlitchAmbush"]  = 175,
        ["BackdoorRush"]  = 85,
        ["CustomEntity"]  = 85,
}

Functions.IsCrouching = function()
        if Floor == "Fools" or Floor == "OldHotel" then
                return Character:GetAttribute("Crouching")
        end
        return CollisionPart.CollisionGroup == "PlayerCrouching"
end

Functions.GetNearestEntity = function(CheckDisabled, List, UseRaycasting)
        local Nearest = { Distance = math.huge, Object = nil }

        for _, Entity in Services.Workspace:GetChildren() do
                if Entity and EntityDistances[Entity.Name] and Entity.PrimaryPart then
                        local Distance = LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position)
                        if Distance < EntityDistances[Entity.Name] and Distance < Nearest.Distance then
                                if not CheckDisabled or Entity:GetAttribute("Inactive") ~= true then
                                        Nearest.Distance = Distance
                                        Nearest.Object = Entity
                                end
                        end
                end
        end
        return Nearest.Object
end

Functions.GetNearestFigure = function()
        local Nearest = { Distance = math.huge, Object = nil }
        local FigureNames = { FigureRig = true, FigureRagdoll = true, Figure = true }

        for _, Object in Objects.Entities do
                if Object:IsA("Model") and Object.PrimaryPart and FigureNames[Object.Name] then
                        local Distance = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
                        if Distance < Nearest.Distance and Distance < 25 then
                                Nearest.Distance = Distance
                                Nearest.Object = Object
                        end
                end
        end
        return Nearest.Object
end

print("[AMBUSH HUB] Loaded Anticheat Tab")
print("[AMBUSH HUB] Loading Anti Functions")
local MainHook
if Functions.CheckCompatability({"hookmetamethod", "newcclosure", "getnamecallmethod"}) then
        MainHook = Env.hookmetamethod(game, "__namecall", Env.newcclosure(function(Self, ...)
                local Args = { ... }
                local ArgCount = select("#", ...)
                local Method = Env.getnamecallmethod()

                if Self.Name == "Crouch" and Method == "FireServer" then
                        if Toggles.CrouchSpoof.Value or Toggles.PositionSpoof.Value then
                                Args[1] = true
                        end
                        Args[2] = true
                end

                if Self.Name == "ClutchHeartbeat" and Method == "FireServer" and Toggles.AutoHeartbeatMinigame.Value or Self.Name == "HideMonster" and Method == "FireServer" and Toggles.AutoHeartbeatMinigame.Value then
                        return
                end

                if Self.Name == "MotorReplication" and Method == "FireServer" then
                        local DoBypass = (Toggles.BypassEyes.Value and Globals.IsEyes) or (Toggles.BypassLookman.Value and Globals.IsLookman)
                        if DoBypass then
                                if Floor == "Fools" or Floor == "OldHotel" then
                                        Args[1] = 0 Args[2] = (Globals.SpoofOffset == 200 and 65 or -65) Args[3] = 0 Args[4] = false
                                        ArgCount = math.max(ArgCount, 4)
                                else
                                        Args[1] = -650
                                        ArgCount = math.max(ArgCount, 1)
                                end
                        end
                end

                return MainHook(Self, table.unpack(Args, 1, ArgCount))
        end))
end

Hooks.DisableAnticheat = function(Value)
        if Globals.AnticheatDisabled == true and not Value then
                if RemotesFolder and RemotesFolder:FindFirstChild("ClimbLadder") then
                        RemotesFolder.ClimbLadder:FireServer()
                end
                Globals.AnticheatDisabled = false
        end
end

Hooks.PositionSpoof = function(Value)
        -- Position Spoof: shift the character underground so rush-like entities
        -- can't reach the real position, while the body stays visible above.
        -- This is the one-shot toggle handler; the per-frame position updates
        -- happen in the MainHandler RenderStepped loop below.
        if not (RootPart and Humanoid and RemotesFolder) then
                -- Character not ready yet — retry shortly
                task.delay(0.5, function()
                        if Ex.PositionSpoof == Value and RootPart and Humanoid and RemotesFolder then
                                if Floor ~= "Fools" and Floor ~= "OldHotel" then
                                        if Value then
                                                RootPart.CFrame = RootPart.CFrame * CFrame.new(0, -2.346, 0)
                                                Humanoid.HipHeight = 0.05
                                                RemotesFolder.Crouch:FireServer(true, true)
                                        else
                                                RootPart.CFrame = RootPart.CFrame * CFrame.new(0, 2.346, 0)
                                                Humanoid.HipHeight = 2.396
                                        end
                                end
                        end
                end)
                return
        end
        if Floor ~= "Fools" and Floor ~= "OldHotel" then
                if Value then
                        RootPart.CFrame = RootPart.CFrame * CFrame.new(0, -2.346, 0)
                        Humanoid.HipHeight = 0.05
                        RemotesFolder.Crouch:FireServer(true, true)
                else
                        RootPart.CFrame = RootPart.CFrame * CFrame.new(0, 2.346, 0)
                        Humanoid.HipHeight = 2.396
                end
        end
end

Hooks.CrouchSpoof = function(Value)
        if RemotesFolder and RemotesFolder:FindFirstChild("Crouch") then
                RemotesFolder.Crouch:FireServer(Value and true or Functions.IsCrouching(), true)
        end
end

Hooks.BypassGiggle = function(Value)
        for _, Object in Objects.Entities do
                if Object.Name == "GiggleCeiling" then
                        Object:WaitForChild("Hitbox").CanTouch = not Value
                end
        end
end
Hooks.BypassDupe = function(Value)
        for _, Object in Objects.Entities do
                if Object.Name == "DoorFake" or Object.Name == "FakeDoor" then
                        Object:WaitForChild("Hidden").CanTouch = not Value
                        if Object:FindFirstChild("Lock") then
                                Object.Lock.UnlockPrompt.Enabled = not Value
                        end
                end
        end
end
Hooks.BypassEyes = function(Value)
        if Value and Globals.IsEyes and RemotesFolder then
                if Floor == "Fools" or Floor == "OldHotel" then
                        RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
                else
                        RemotesFolder.MotorReplication:FireServer(-650)
                end
        end
end
Hooks.BypassLookman = function(Value)
        if Value and Globals.IsLookman and RemotesFolder then
                if Floor == "Fools" or Floor == "OldHotel" then
                        RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
                else
                        RemotesFolder.MotorReplication:FireServer(-650)
                end
        end
end
Hooks.BypassGloombatEggs = function(Value)
        for _, Object in Objects.Entities do
                for _, Part in Object:GetDescendants() do
                        if Part:IsA("BasePart") then
                                Part.CanTouch = not Value
                        end
                end
        end
end
Hooks.BypassSeekObstructions = function(Value)
        for _, Object in Objects.SeekObstructions do
                Object.CanTouch = not Value
                if Object.Name == "SeekFloodline" then
                        Object.CanCollide = Value
                end
        end
        for _, Object in Objects.SeekBridges do
                Object.CanCollide = Value
                Object.Transparency = Value and 0 or 1
        end
end
Hooks.BypassVacuum = function(Value)
        for _, Object in Objects.Entities do
                if Object.Name == "SideroomSpace" then
                        Object:WaitForChild("Collision").CanCollide = Value
                        Object:WaitForChild("Collision").CanTouch = not Value
                end
        end
end
Hooks.BypassKillbricks = function(Value)
        for _, Object in Objects.Obstructions do
                if Object.Name == "Lava" then Object.CanTouch = not Value end
        end
end
Hooks.BypassSeekingWall = function(Value)
        for _, Object in Objects.Obstructions do
                if Object.Name == "ScaryWall" then
                        for _, Part in Object:GetDescendants() do
                                if Part:IsA("BasePart") then
                                        Part.CanTouch = not Value
                                        Part.CanCollide = not Value
                                end
                        end
                end
        end
end
Hooks.BypassSnare = function(Value)
        for _, Object in Objects.Entities do
                if Object.Name == "Snare" then
                        for _, Part in Object:GetDescendants() do
                                if Part:IsA("BasePart") then Part.CanTouch = not Value end
                        end
                end
        end
end
Hooks.BypassBanana = function(Value)
        for _, Object in Objects.Entities do
                if Object.Name == "BananaPeel" then Object.CanTouch = not Value end
        end
end
Hooks.BypassJeff = function(Value)
        for _, Object in Objects.Entities do
                if Object.Name == "JeffTheKiller" then
                        for _, Part in Object:GetDescendants() do
                                if Part:IsA("BasePart") then
                                        Part.CanCollide = not Value
                                        Part.CanTouch = not Value
                                end
                        end
                        Object:WaitForChild("Humanoid").Health = 0
                end
        end
end

Hooks.NoScreechDamage = function(Value)
        if not (FakeEvents.Screech and FakeEvents.Screech_Real and RemotesFolder) then return end
        if Value then
                FakeEvents.Screech.Parent = RemotesFolder
                FakeEvents.Screech_Real.Parent = nil
        else
                FakeEvents.Screech_Real.Parent = RemotesFolder
                FakeEvents.Screech.Parent = nil
        end
end
Hooks.NoHaltDamage = function(Value)
        if not (FakeEvents.Shade and FakeEvents.Shade_Real and RemotesFolder) then return end
        if Value then
                FakeEvents.Shade.Parent = RemotesFolder
                FakeEvents.Shade_Real.Parent = nil
        else
                FakeEvents.Shade_Real.Parent = RemotesFolder
                FakeEvents.Shade.Parent = nil
        end
end
Hooks.NoA90Damage = function(Value)
        if RemotesFolder and RemotesFolder:FindFirstChild("A90") and FakeEvents.A90 and FakeEvents.A90_Real then
                if Value then
                        FakeEvents.A90.Parent = RemotesFolder
                        FakeEvents.A90_Real.Parent = nil
                else
                        FakeEvents.A90_Real.Parent = RemotesFolder
                        FakeEvents.A90.Parent = nil
                end
        end
end
Hooks.NoSurgeDamage = function(Value)
        if RemotesFolder and RemotesFolder:FindFirstChild("SurgeRemote") and FakeEvents.Surge and FakeEvents.Surge_Real then
                if Value then
                        FakeEvents.Surge.Parent = RemotesFolder
                        FakeEvents.Surge_Real.Parent = nil
                else
                        FakeEvents.Surge_Real.Parent = RemotesFolder
                        FakeEvents.Surge.Parent = nil
                end
        end
end

local function FindClientModule(Name)
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local mu = pg and pg:FindFirstChild("MainUI")
        local ini = mu and mu:FindFirstChild("Initiator")
        local mg = ini and ini:FindFirstChild("Main_Game")
        local rl = mg and mg:FindFirstChild("RemoteListener")
        local mods = rl and rl:FindFirstChild("Modules")
        if not mods then return nil end
        return mods:FindFirstChild(Name) or mods:FindFirstChild(Name .. "_Disabled")
end

local function KillLiveScreech()
        for _, Parent in { Services.Workspace, Services.Workspace.CurrentCamera } do
                if Parent then
                        for _, Obj in Parent:GetChildren() do
                                local L = Obj.Name:lower()
                                if (L == "screech" or L == "glitchscreech" or L:find("scjvereech", 1, true)) and Obj ~= LocalPlayer.Character then
                                        pcall(function() Obj:Destroy() end)
                                end
                        end
                end
        end
end

Functions.ApplyRemoveScreech = function()
        local Value = Ex.RemoveScreech
        if not (Modules.GlitchScreech and Modules.GlitchScreech.Parent) then
                local FR = Services.ReplicatedStorage:FindFirstChild("FloorReplicated")
                if FR then
                        for _, D in FR:GetDescendants() do
                                if D.Name == "GlitchScreech" or D.Name == "GlitchScreech_Disabled" then Modules.GlitchScreech = D break end
                        end
                end
        end
        local M = FindClientModule("Screech")
        if M then
                Modules.Screech = M
                M.Name = Value and "Screech_Disabled" or "Screech"
        end
        local GS = Modules.GlitchScreech
        if GS and GS.Parent then
                GS.Name = Value and "GlitchScreech_Disabled" or "GlitchScreech"
        end
        if Value then pcall(KillLiveScreech) end
end

Hooks.RemoveScreech = function(Value)
        Functions.ApplyRemoveScreech()
        if not Value then return end
        task.spawn(function()
                for _ = 1, 40 do
                        if not Ex.RemoveScreech then return end
                        if FindClientModule("Screech") then
                                Functions.ApplyRemoveScreech()
                                break
                        end
                        task.wait(0.5)
                end
        end)
end

task.spawn(function()
        while true do
                task.wait(0.5)
                if Ex.RemoveScreech then
                        pcall(Functions.ApplyRemoveScreech)
                end
        end
end)
Hooks.RemoveHalt = function(Value)
        if Modules.Shade then
                Modules.Shade.Name = Value and "Shade_Disabled" or "Shade"
        end
end
Hooks.RemoveA90 = function(Value)
        if Modules.A90 then
                Modules.A90.Name = Value and "A90_Disabled" or "A90"
        end
end
Hooks.RemoveDread = function(Value)
        if Modules.Dread then
                Modules.Dread.Name = Value and "Dread_Disabled" or "Dread"
        end
end
Hooks.RemoveSurge = function(Value)
        if Globals.SurgeFrame then
                Globals.SurgeFrame.Name = (Value and "SurgeVignette_Disabled" or "SurgeVignette")
        end
end

local ObstructionNames = { ThingToOpen = "RemoveBasementGate", MovingDoor = "RemovePaintingsDoor", Wax_Door = "RemoveSkeletonDoor" }
Functions.SetObstructionRemoved = function(Object, Value)
        if not Object or not Object.Parent then return end
        if Object:GetAttribute("OriginalPosition") == nil then
                local ok, Pivot = pcall(function() return Object:GetPivot() end)
                if ok then Object:SetAttribute("OriginalPosition", Pivot) end
        end
        local Original = Object:GetAttribute("OriginalPosition")
        if Value then
                local ok, Cur = pcall(function() return Object:GetPivot().Position end)
                if ok and Cur.Y > -9000 then
                        pcall(function() Object:PivotTo(CFrame.new(-10000, -10000, -10000)) end)
                end
                local Parts = Object:IsA("BasePart") and { Object } or Object:GetDescendants()
                for _, Part in Parts do
                        if Part:IsA("BasePart") then
                                if Part:GetAttribute("OrigCollide") == nil then
                                        Part:SetAttribute("OrigCollide", Part.CanCollide)
                                        Part:SetAttribute("OrigTouch", Part.CanTouch)
                                end
                                Part.CanCollide = false
                                Part.CanTouch = false
                        end
                end
        else
                if typeof(Original) == "CFrame" then
                        pcall(function() Object:PivotTo(Original) end)
                end
                local Parts = Object:IsA("BasePart") and { Object } or Object:GetDescendants()
                for _, Part in Parts do
                        if Part:IsA("BasePart") and Part:GetAttribute("OrigCollide") ~= nil then
                                Part.CanCollide = Part:GetAttribute("OrigCollide")
                                Part.CanTouch = Part:GetAttribute("OrigTouch")
                                Part:SetAttribute("OrigCollide", nil)
                                Part:SetAttribute("OrigTouch", nil)
                        end
                end
        end
end

for ObjName, ToggleName in ObstructionNames do
        Hooks[ToggleName] = function(Value)
                for _, Object in Services.Workspace:GetDescendants() do
                        if Object.Name == ObjName and (Object:IsA("Model") or Object:IsA("BasePart")) and not table.find(Objects.Obstructions, Object) then
                                table.insert(Objects.Obstructions, Object)
                        end
                end
                for _, Object in Objects.Obstructions do
                        if Object.Name == ObjName then
                                pcall(Functions.SetObstructionRemoved, Object, Value)
                        end
                end
        end
end

task.spawn(function()
        while true do
                task.wait(0.4)
                for ObjName, ToggleName in ObstructionNames do
                        if Ex[ToggleName] then
                                for _, Object in Objects.Obstructions do
                                        if Object.Name == ObjName and Object.Parent then
                                                pcall(Functions.SetObstructionRemoved, Object, true)
                                        end
                                end
                        end
                end
        end
end)

Functions.HandleObject = function(Object)
        local Name = Object.Name

        if Name == "Lava" then
                if Toggles.BypassKillbricks.Value then Object.CanTouch = false end
                table.insert(Objects.Obstructions, Object)
        elseif Name == "ScaryWall" then
                for _, Part in Object:GetDescendants() do
                        if Part:IsA("BasePart") then
                                Part.CanTouch = not Toggles.BypassSeekingWall.Value
                                Part.CanCollide = not Toggles.BypassSeekingWall.Value

                                local Connection1 = Part:GetPropertyChangedSignal("CanTouch"):Connect(function()
                                        if Part.CanTouch == Toggles.BypassSeekingWall.Value then
                                                Part.CanTouch = not Toggles.BypassSeekingWall.Value
                                        end
                                end)
                                local Connection2 = Part:GetPropertyChangedSignal("CanCollide"):Connect(function()
                                        if Part.CanCollide == Toggles.BypassSeekingWall.Value then
                                                Part.CanCollide = not Toggles.BypassSeekingWall.Value
                                        end
                                end)

                                table.insert(Connections, Connection1)
                                table.insert(Connections, Connection2)
                        end
                end
                table.insert(Objects.Obstructions, Object)
        elseif Name == "GiggleCeiling" then
                if Toggles.BypassGiggle.Value then Object:WaitForChild("Hitbox").CanTouch = false end
                table.insert(Objects.Entities, Object)
        elseif Name == "GloomPile" then
                if Toggles.BypassGloombatEggs.Value then
                        for _, Part in Object:GetDescendants() do
                                if Part:IsA("BasePart") then Part.CanTouch = false
                                end
                        end
                end
                local Connection = Object.DescendantAdded:Connect(function(Part)
                        if Part:IsA("BasePart") then Part.CanTouch = false end
                end)

                table.insert(Connections, Connection)
                table.insert(Objects.Entities, Object)
        elseif Name == "TriggerEventCollision" and Functions.CheckCompatability({"firetouchinterest"}) then
                if (Floor == "Fools" or Floor == "OldHotel") and Toggles.RemoveSeekTrigger.Value then
                        task.spawn(function()
                                while Object:IsDescendantOf(game) do
                                        for _, Part in Object:GetChildren() do
                                                if Part:IsA("BasePart") then
                                                        Env.firetouchinterest(RootPart, Part, 0)
                                                        task.wait()
                                                        Env.firetouchinterest(RootPart, Part, 1)
                                                end
                                        end
                                        task.wait()
                                end
                        end)
                end
        elseif Name == "DoorFake" or Name == "FakeDoor" then
                if Object.Parent and Object:FindFirstChild("Hidden") then
                        if Toggles.BypassDupe.Value then
                                Object:WaitForChild("Hidden").CanTouch = false
                                local Lock = Object:FindFirstChild("Lock")
                                if Lock and Lock:FindFirstChild("UnlockPrompt") then Lock.UnlockPrompt.Enabled = false end
                        end
                        table.insert(Objects.Entities, Object)
                end
        elseif Name == "SideroomSpace" then
                if Toggles.BypassVacuum.Value then
                        Object:WaitForChild("Collision").CanCollide = true
                        Object:WaitForChild("Collision").CanTouch = false
                end
                table.insert(Objects.Entities, Object)
        elseif Name == "Snare" then
                for _, Part in Object:GetDescendants() do
                        if Part:IsA("BasePart") then Part.CanTouch = not Toggles.BypassSnare.Value end
                end
                local Connection = Object.DescendantAdded:Connect(function(Part)
                        if Part:IsA("BasePart") then Part.CanTouch = not Toggles.BypassSnare.Value end
                end)
                table.insert(Connections, Connection)
                table.insert(Objects.Entities, Object)
        elseif Name == "Seek_Arm" or Name == "ChandelierObstruction" then
                for _, Part in Object:GetDescendants() do
                        if Part:IsA("BasePart") then
                                Part.CanTouch = not Toggles.BypassSeekObstructions.Value
                                table.insert(Objects.SeekObstructions, Part)
                        end
                end
        elseif Name == "SeekFloodline" then
                Object.CanCollide = Toggles.BypassSeekObstructions.Value
                local FloodConn = Object:GetPropertyChangedSignal("CanCollide"):Connect(function()
                        if Object.CanCollide ~= Toggles.BypassSeekObstructions.Value then
                                Object.CanCollide = Toggles.BypassSeekObstructions.Value
                        end
                end)
                Object.Destroying:Once(function() FloodConn:Disconnect() end)
                table.insert(Objects.SeekObstructions, Object)
        elseif Name == "Bridge" then
                for _, Child in Object:GetChildren() do
                        if Child.Name == "PlayerBarrier" and Child.Size.Y == 2.75 and (Child.Rotation.X == 0 or Child.Rotation.X == 180) then
                                local NewBridge = Child:Clone()
                                NewBridge.CFrame = NewBridge.CFrame * CFrame.new(0, 0, -5)
                                NewBridge.Name = tostring(math.random(100000, 999999))
                                NewBridge.Size = Vector3.new(NewBridge.Size.X, NewBridge.Size.Y, 11)
                                NewBridge.Parent = Object
                                NewBridge.CanCollide = Toggles.BypassSeekObstructions.Value
                                NewBridge.Color = Color3.fromRGB(0, 255, 255)
                                NewBridge.Transparency = Toggles.BypassSeekObstructions.Value and 0 or 1
                                NewBridge.Material = Enum.Material.ForceField
                                table.insert(Objects.SeekBridges, NewBridge)
                        end
                        task.wait()
                end
        elseif Object:GetAttribute("RawName") and Object:GetAttribute("RawName"):find("Halt") or Object:GetAttribute("Shade") == true then
                local HaltLogConn
                HaltLogConn = Services.LogService.MessageOut:Connect(function(Message)
                        if Message == "client teleporting" then
                                if Globals.AnticheatDisabled then
                                        Globals.AnticheatDisabled = false
                                        Functions.Notify({ Title = "Anticheat re-enabled.", Body = "Interact with a ladder to disable it again." })
                                end
                                HaltLogConn:Disconnect()
                        end
                end)
        elseif Name == "BananaPeel" then
                if Toggles.BypassBanana.Value then Object.CanTouch = false end
                table.insert(Objects.Entities, Object)
        elseif Name == "JeffTheKiller" then
                if Toggles.BypassJeff.Value then
                        for _, Part in Object:GetDescendants() do
                                if Part:IsA("BasePart") then Part.CanCollide = false Part.CanTouch = false end
                        end
                        Object:WaitForChild("Humanoid").Health = 0
                end
        elseif Name == "Figure" or Name == "FigureRig" or Name == "FigureRagdoll" then
                for _, Part in Object:GetDescendants() do
                        if Part:IsA("BasePart") then
                                Part.CanTouch = false
                        end
                end
                table.insert(Objects.Entities, Object)
                if Toggles.RemoveFigure.Value and Functions.CheckCompatability({"isnetworkowner"}) then
                        if Floor == "Mines" then
                                for _, Part in Object:GetDescendants() do
                                        if Part:IsA("BasePart") then
                                                task.spawn(function()
                                                        if Env.isnetworkowner(Part) then
                                                                Part.Position = Vector3.new(-49999, -49999, -49999)
                                                        end
                                                end)
                                        end
                                end
                        elseif Floor == "OldHotel" or Floor == "Fools" then
                                CurrentRooms.ChildAdded:Wait()
                                for _, Part in Object:GetDescendants() do
                                        if Part:IsA("BasePart") then
                                                Part.CanCollide = false
                                                task.spawn(function()
                                                        while Env.isnetworkowner(Part) do
                                                                Part.Position = Vector3.new(math.random(-29999,29999), math.random(-29999,29999), math.random(-29999,29999))
                                                                task.wait()
                                                        end
                                                end)
                                        end
                                end
                        end
                end
        elseif ObstructionNames[Name] and (Object:IsA("Model") or Object:IsA("BasePart")) then
                if not table.find(Objects.Obstructions, Object) then
                        pcall(function() Object:SetAttribute("OriginalPosition", Object:GetPivot()) end)
                        table.insert(Objects.Obstructions, Object)
                end
                if Ex[ObstructionNames[Name]] then
                        Functions.SetObstructionRemoved(Object, true)
                end
        end
end

Globals.ObjectQueue = {}
local AllowedInstances = {
        Lava = true, JeffTheKiller = true, Snare = true, FakeDoor = true, DoorFake = true, SideroomSpace = true,
        FigureRig = true, FigureRagdoll = true, Figure = true, Seek_Arm = true, ChandelierObstruction = true, ScaryWall = true,
        TriggerEventCollision = true, GiggleCeiling = true, GloomPile = true, SeekFloodline = true, Bridge = true,
        BananaPeel = true, Wax_Door = true, ThingToOpen = true, MovingDoor = true,
}
Functions.QueueObject = function(Object)
        if not AllowedInstances[Object.Name] and not (Object:GetAttribute("RawName") and Object:GetAttribute("RawName"):find("Halt")) and Object:GetAttribute("Shade") ~= true then
                return
        end
        table.insert(Globals.ObjectQueue, Object)
end

local CharacterOldConnectionKeys = {
        "MainHandler", "SHMFixer", "AnticheatDisabler", "AnticheatEnableDetector1", "AnticheatEnableDetector2", "AutoReviveHandler",
}

Functions.HandleCharacter = function(NewCharacter)
        for _, Key in CharacterOldConnectionKeys do
                if Connections[Key] then
                        Connections[Key]:Disconnect()
                        Connections[Key] = nil
                end
        end

        local NewHumanoid = NewCharacter:WaitForChild("Humanoid", 15)
        local NewCollision = NewCharacter:WaitForChild("Collision", 15)
        if not NewHumanoid or not NewCollision or not NewCharacter:FindFirstChild("HumanoidRootPart") then return end

        Character = NewCharacter
        Humanoid = NewHumanoid
        RootPart = NewCharacter:FindFirstChild("HumanoidRootPart")
        Camera   = Services.Workspace.CurrentCamera

        Collision = NewCollision
        CollisionPart  = NewCharacter:FindFirstChild("CollisionPart") or NewCharacter:FindFirstChild("Collision")
        CollisionClone = Collision:Clone()
        CollisionClone.Parent = NewCharacter
        CollisionClone.Name = "CollisionClone"
        CollisionClone.Massless = true

        CollisionPartClone = CollisionPart:Clone()
        CollisionPartClone.Parent = NewCharacter
        CollisionPartClone.Name = "CollisionPartClone"
        CollisionPartClone.CanCollide = false
        CollisionPartClone.Massless = true

        if CollisionPartClone:FindFirstChild("CollisionCrouch") then
                CollisionPartClone.CollisionCrouch:Destroy()
        end

        Connections.AutoReviveHandler = LocalPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
                if LocalPlayer:GetAttribute("Alive") == false and Toggles.AutoRevive.Value then
                        if Floor == "Fools" or Floor == "OldHotel" then
                                while LocalPlayer:GetAttribute("Alive") ~= true do
                                        RemotesFolder.Revive:FireServer()
                                        task.wait(0.5)
                                end
                        end
                end
        end)

        Connections.SHMFixer = RootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
                task.wait()
                if Floor == "Fools" and RootPart.Anchored and Character:GetAttribute("Hiding") ~= true then
                        RootPart.Anchored = false
                end
        end)

        Globals.AnticheatDisabled = false

        Connections.AnticheatDisabler = Character:GetAttributeChangedSignal("Climbing"):Connect(function()
                if Character:GetAttribute("Climbing") == true and Toggles.DisableAnticheat.Value and not Globals.AnticheatDisabled then
                        task.wait(0.25)
                        Character:SetAttribute("Climbing", false)
                        Functions.Notify({ Title = "Anticheat successfully disabled.", Body = "It will be re-enabled after a cutscene or halt room." })
                        Globals.AnticheatDisabled = true
                end
        end)

        local CutsceneRemote = RemotesFolder and RemotesFolder:WaitForChild("Cutscene", 10)
        if CutsceneRemote then
                Connections.AnticheatEnableDetector1 = CutsceneRemote.OnClientEvent:Connect(function(CutsceneName)
                        if Globals.AnticheatDisabled and not CutsceneName:find("SewerSeek") then
                                Globals.AnticheatDisabled = false
                                Functions.Notify({ Title = "Anticheat re-enabled.", Body = "Interact with a ladder to disable it again." })
                        end
                end)
        end

        local EnemyRemote = RemotesFolder and RemotesFolder:WaitForChild("UseEnemyModule", 10)
        if EnemyRemote then
                Connections.AnticheatEnableDetector2 = EnemyRemote.OnClientEvent:Connect(function(ModuleName)
                        if ModuleName == "Void" or ModuleName == "Glitch" then
                                if Globals.AnticheatDisabled then
                                        Globals.AnticheatDisabled = false
                                        Functions.Notify({ Title = "Anticheat re-enabled.", Body = "Interact with a ladder to disable it again." })
                                end
                                local LatestRoom = Services.ReplicatedStorage:FindFirstChild("GameData") and Services.ReplicatedStorage.GameData:FindFirstChild("LatestRoom")
                                if LatestRoom then LocalPlayer:SetAttribute("CurrentRoom", LatestRoom.Value) end
                        end
                end)
        end

        Globals.ManipulateBody = Instance.new("BodyVelocity")
        Globals.ManipulateBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        Globals.LastCrouchFire = tick()
        Globals.OriginalC1 = Character.LowerTorso.Root.C1

        local MainUI = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
        local MainFrame = MainUI and MainUI:FindFirstChild("MainFrame")
        if MainFrame and MainFrame:FindFirstChild("SurgeVignette") then
                Globals.SurgeFrame = MainFrame.SurgeVignette
                if Toggles.RemoveSurge.Value then
                        Globals.SurgeFrame.Name = "SurgeVignette_Disabled"
                end
        end

        local UIModules = MainUI and MainUI:FindFirstChild("Initiator") and MainUI.Initiator:FindFirstChild("Main_Game")
        UIModules = UIModules and UIModules:FindFirstChild("RemoteListener") and UIModules.RemoteListener:FindFirstChild("Modules")
        if UIModules then
                Modules.A90     = UIModules:FindFirstChild("A90")
                Modules.Screech = UIModules:FindFirstChild("Screech")
                Modules.Dread   = UIModules:FindFirstChild("Dread")
                if Toggles.RemoveScreech.Value and Modules.Screech then Modules.Screech.Name = "Screech_Disabled" end
                if Toggles.RemoveA90.Value and Modules.A90 then Modules.A90.Name = "A90_Disabled" end
                if Toggles.RemoveDread.Value and Modules.Dread then Modules.Dread.Name = "Dread_Disabled" end
        end

        Connections.MainHandler = Services.RunService.RenderStepped:Connect(function()
                if not (Character and Character.Parent and RootPart and RootPart.Parent and Collision and CollisionClone and CollisionPart) then return end

                if Services.Workspace:FindFirstChild("Camera") then
                        Camera = Services.Workspace:FindFirstChild("Camera")
                end

                Globals.IsEyes    = Services.Workspace:FindFirstChild("Eyes") ~= nil or Services.Workspace:FindFirstChild("Lookman") ~= nil
                Globals.IsLookman = Services.Workspace:FindFirstChild("BackdoorLookman") ~= nil

                Character:SetAttribute("Sliding", Globals.Sliding)
                if Character:GetAttribute("Crouching") ~= Functions.IsCrouching() then
                        Character:SetAttribute("Crouching", Functions.IsCrouching())
                end

                if (Toggles.CrouchSpoof.Value or Toggles.PositionSpoof.Value) and RemotesFolder:FindFirstChild("Crouch") then
                        RemotesFolder.Crouch:FireServer(true, true)
                end

                if Floor ~= "Fools" and Floor ~= "OldHotel" and not Camera:FindFirstChild("MinecartRig") then
                        RootPart.CanCollide = false
                end

                for _, Part in Character:GetChildren() do
                        if Part:IsA("BasePart") then Part.CanCollide = false end
                end

                if Floor == "OldHotel" or Floor == "Fools" then
                        local SpoofOffset = Toggles.PositionSpoof.Value and Functions.GetNearestEntity() and 200 or Toggles.FigureGodmode.Value and Functions.GetNearestFigure() and 200 or 0
                        Globals.SpoofOffset = SpoofOffset
                        Collision.Position = RootPart.Position + Vector3.new(0, SpoofOffset, 0)
                        Collision.CanCollide = false
                        if Floor == "Fools" then
                                Collision.CollisionCrouch.CanCollide = false
                                CollisionClone.CollisionCrouch.CanCollide = false
                        end
                        RootPart.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value)
                else
                        Collision.CanCollide = false
                        if Collision:FindFirstChild("CollisionCrouch") then Collision.CollisionCrouch.CanCollide = false end

                        if CollisionClone:FindFirstChild("CollisionCrouch") then
                                local IsCrouch = Functions.IsCrouching()
                                CollisionClone.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value or IsCrouch)
                                CollisionClone.CollisionCrouch.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value or not IsCrouch)
                        else
                                RootPart.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value)
                        end

                        if Character:FindFirstChild("LowerTorso") and Character.LowerTorso:FindFirstChild("Root") then
                                Character.LowerTorso.Root.C1 = Globals.OriginalC1 * CFrame.new(0, Toggles.PositionSpoof.Value and -2.346 or 0, 0)
                        end

                        local SpoofY = Toggles.PositionSpoof.Value and 2.328 or 0.18
                        Collision.Position     = RootPart.Position + Vector3.new(0, SpoofY, 0)
                        CollisionPart.Position = RootPart.Position + Vector3.new(0, SpoofY, 0)

                        if Collision:FindFirstChild("CollisionCrouch") and CollisionClone:FindFirstChild("CollisionCrouch") then
                                local CrouchY = Toggles.PositionSpoof.Value and 1.328 or -0.982
                                Collision.CollisionCrouch.Position = RootPart.Position + Vector3.new(0, CrouchY, 0)
                                CollisionClone.CollisionCrouch.CollisionGroup = Collision.CollisionCrouch.CollisionGroup
                        end
                        if CollisionClone:FindFirstChild("CollisionCrouch") then
                                CollisionClone.CollisionCrouch.Position = RootPart.Position + Vector3.new(0, Toggles.PositionSpoof.Value and 0.75 or -0.982, 0)
                        end
                end

                CollisionClone.CollisionGroup = Collision.CollisionGroup
                CollisionClone.Position = RootPart.Position + Vector3.new(0, Toggles.PositionSpoof.Value and 1.75 or 0.18, 0)

                if Toggles.VelocityManipulationToggle.Value and Options.VelocityManipulationMode.Value == "Velocity" then
                        Globals.ManipulateBody.Parent = RootPart
                        Globals.ManipulateBody.Velocity = RootPart.CFrame.LookVector * 2.25
                else
                        Globals.ManipulateBody.Parent = nil
                end

                if Toggles.VelocityManipulationToggle.Value and Options.VelocityManipulationMode.Value == "Pivot" and Floor ~= "Fools" and Floor ~= "OldHotel" then
                        Character:PivotTo(Camera:GetPivot() * CFrame.new(0, 0, 2560))
                end

                local DoEyesBypass = (Toggles.BypassEyes.Value and Globals.IsEyes) or (Toggles.BypassLookman.Value and Globals.IsLookman)
                if DoEyesBypass then
                        if Floor == "Fools" or Floor == "OldHotel" then
                                RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
                        else
                                RemotesFolder.MotorReplication:FireServer(-650)
                        end
                end

                if RemotesFolder:FindFirstChild("Crouch") and tick() - Globals.LastCrouchFire > 0.1 then
                        local IsCrouch = Functions.IsCrouching()
                        if Toggles.CrouchSpoof.Value or Toggles.PositionSpoof.Value then IsCrouch = true end
                        RemotesFolder.Crouch:FireServer(IsCrouch, true)
                        Globals.LastCrouchFire = tick()
                end
        end)
end

task.spawn(function()
        local GameData = Services.ReplicatedStorage:WaitForChild("GameData", 20)
        local FloorValue = GameData and GameData:WaitForChild("Floor", 10)
        if not (GameData and FloorValue) then return end
        Floor = FloorValue.Value

        if not RemotesFolder then
                if Services.ReplicatedStorage:FindFirstChild("EntityInfo") then
                        RemotesFolder = Services.ReplicatedStorage:FindFirstChild("EntityInfo")
                elseif Services.ReplicatedStorage:FindFirstChild("Bricks") then
                        RemotesFolder = Services.ReplicatedStorage:FindFirstChild("Bricks")
                end
        end
        if not RemotesFolder then return end
        if Floor == "Hotel" and RemotesFolder.Name == "Bricks" then
                Floor = "OldHotel"
        end
        CurrentRooms = CurrentRooms or Services.Workspace:WaitForChild("CurrentRooms", 20)

        FakeEvents.Screech = Instance.new("RemoteEvent")
        FakeEvents.Shade   = Instance.new("RemoteEvent")
        FakeEvents.A90     = Instance.new("RemoteEvent")
        FakeEvents.Surge   = Instance.new("RemoteEvent")
        FakeEvents.Screech.Name = "Screech"
        FakeEvents.Shade.Name   = "ShadeResult"
        FakeEvents.A90.Name     = "A90"
        FakeEvents.Surge.Name   = "SurgeRemote"
        FakeEvents.Screech_Real = RemotesFolder:FindFirstChild("Screech")
        FakeEvents.Shade_Real   = RemotesFolder:FindFirstChild("ShadeResult")
        FakeEvents.A90_Real     = RemotesFolder:FindFirstChild("A90")
        FakeEvents.Surge_Real   = RemotesFolder:FindFirstChild("SurgeRemote")

        if RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed") then
                local RealRemote = RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed")
                RealRemote:Destroy()

                local FakeRemote = Instance.new("RemoteEvent", RemotesFolder)
                FakeRemote.Name = "FootstepRemoteThatWeNeed"
        end

        local ClientModules = Services.ReplicatedStorage:FindFirstChild("ModulesClient") or Services.ReplicatedStorage:FindFirstChild("ClientModules")
        if ClientModules and ClientModules:FindFirstChild("EntityModules") then
                Modules.Glitch = ClientModules.EntityModules:FindFirstChild("Glitch")
                Modules.Shade  = ClientModules.EntityModules:FindFirstChild("Shade")
                Modules.Void   = ClientModules.EntityModules:FindFirstChild("Void")
                if Toggles.RemoveHalt.Value and Modules.Shade then Modules.Shade.Name = "Shade_Disabled" end
        end

        local FloorReplicated = Services.ReplicatedStorage:FindFirstChild("FloorReplicated")
        if FloorReplicated then
                Connections.FloorReplicatedHandler = FloorReplicated.DescendantAdded:Connect(function(Object)
                        if Object.Name == "GlitchScreech" then
                                Modules.GlitchScreech = Object
                                if Toggles.RemoveScreech.Value then Object.Name = "GlitchScreech_Disabled" end
                        end
                end)
        end

        Connections.QueueConnection = Services.RunService.RenderStepped:Connect(function()
                local Object = table.remove(Globals.ObjectQueue, 1)
                if Object and Object.Parent then
                        pcall(Functions.HandleObject, Object)
                end
        end)
        for _, Object in Services.Workspace:GetDescendants() do
                Functions.QueueObject(Object)
        end
        Connections.InstanceHandler = Services.Workspace.DescendantAdded:Connect(function(Object)
                Functions.QueueObject(Object)
        end)

        Ready = true

        if LocalPlayer.Character then
                task.spawn(function() Functions.HandleCharacter(LocalPlayer.Character) end)
        end
        LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
                if Connections.MainHandler then
                        Connections.MainHandler:Disconnect()
                        Connections.MainHandler = nil
                end
                task.wait(0.5)
                Functions.HandleCharacter(NewCharacter)
        end)
end)

print("[AMBUSH HUB] Loaded Anti Functions")
print("[AMBUSH HUB] Loading Anticheat and Anti UI")
AntiCheatTab:Section({ Title = "Bypass" })
AddToggle(AntiCheatTab, "DisableAnticheat", "Anticheat Bypass",
        "Fully disables the anticheat after interacting with a ladder. Re-enabled after a cutscene, halt room, Void or Glitch: use a ladder again.",
        Ex.DisableAnticheat, function(v) Apply("DisableAnticheat", v) end)
AddToggle(AntiCheatTab, "PositionSpoof", "Position Spoof",
        "Moves your real position underground while the body stays visible at floor level for other players — they see you standing normally. Protects against rush-like entities.",
        Ex.PositionSpoof, function(v) Apply("PositionSpoof", v) end)
AddToggle(AntiCheatTab, "CrouchSpoof", "Crouch Spoof",
        "Makes the game think you are always crouching.",
        Ex.CrouchSpoof, function(v) Apply("CrouchSpoof", v) end)
if Ex.PositionSpoofStrong == nil then Ex.PositionSpoofStrong = true end
if Ex.LadderSafe == nil then Ex.LadderSafe = true end
AddToggle(AntiCheatTab, "PositionSpoofStrong", "Strong Position Spoof",
        "Makes Position Spoof persistent: while an entity is in kill range, it locks jumping, pulls you back on step / jump / boost and blocks ladder prompts. Requires Position Spoof to be on.",
        Ex.PositionSpoofStrong, function(v) Apply("PositionSpoofStrong", v) end)
AddToggle(AntiCheatTab, "LadderSafe", "Ladder Safe Mode",
        "While using a ladder the anticheat bypass does its thing, and your speed hacks (Speed, Speed Hack, Velocity Manipulation, Noclip, Fly) are paused. They re-enable themselves when you finish climbing. Affects only ones that are on.",
        Ex.LadderSafe, function(v) Apply("LadderSafe", v) end)
AddToggle(AntiCheatTab, "AutoHeartbeatMinigame", "Auto Heartbeat Minigame",
        "Prevents the 'Figure' minigame from ever failing.",
        Ex.AutoHeartbeatMinigame, function(v) Ex.AutoHeartbeatMinigame = v end)

AntisTab:Section({ Title = "Bypass" })
for _, B in ipairs({
        { "BypassGiggle", "Bypass Giggle", "Prevents 'Giggle' from attacking you." },
        { "BypassDupe", "Bypass Dupe", "Prevents you from open 'Dupe' fake doors." },
        { "BypassEyes", "Bypass Eyes", "Prevents 'Eyes' from hurting you." },
        { "BypassLookman", "Bypass Lookman", "Prevents 'Lookman' from hurting you." },
        { "BypassGloombatEggs", "Bypass Gloombat Eggs", "Prevents taking damage from stepping on 'Gloombat' eggs." },
        { "BypassSeekObstructions", "Bypass Seek Obstructions", "Prevents obstacles in the 'Seek' chase from harming you." },
        { "BypassVacuum", "Bypass Vacuum", "Prevents you from falling into 'Vacuum' fake doors." },
        { "BypassKillbricks", "Bypass Killbricks", "Prevents 'Lava' from hurting you." },
        { "BypassSeekingWall", "Bypass Seeking Wall", "Prevents 'ScaryWall' from hurting you." },
        { "BypassSnare", "Bypass Snare", "Prevents 'Snare' from trapping you." },
        { "BypassBanana", "Bypass Banana", "Prevents 'Banana Peel' from slipping you up (sometimes doesn't work)." },
        { "BypassJeff", "Bypass Jeff", "Prevents 'Jeff the Killer' from stabbing you (sometimes doesn't work)." },
}) do
        AddToggle(AntisTab, B[1], B[2], B[3], Ex[B[1]], function(v) Apply(B[1], v) end)
end

AntisTab:Section({ Title = "Remove" })
for _, B in ipairs({
        { "RemoveScreech", "Remove Screech", "Prevents 'Screech' from spawning." },
        { "RemoveHalt", "Remove Halt", "Prevents 'Halt' from spawning." },
        { "RemoveA90", "Remove A-90", "Prevents 'A-90' from spawning." },
        { "RemoveDread", "Remove Dread", "Prevents 'Dread' from spawning." },
        { "RemoveSurge", "Remove Surge", "Prevents 'Surge' from spawning." },
        { "NoScreechDamage", "No Screech Damage", "Prevents 'Screech' from hurting you." },
        { "NoHaltDamage", "No Halt Damage", "Prevents 'Halt' from hurting you." },
        { "NoA90Damage", "No A-90 Damage", "Prevents 'A-90' from hurting you." },
        { "NoSurgeDamage", "No Surge Damage", "Prevents 'Surge' from hurting you." },
}) do
        AddToggle(AntisTab, B[1], B[2], B[3], Ex[B[1]], function(v) Apply(B[1], v) end)
end

AntisTab:Section({ Title = "Floor Bypass" })
AddToggle(AntisTab, "RemoveSeekTrigger", "Remove Seek Trigger", "Disables the 'Seek' chase trigger (Old Hotel / Fools).", Ex.RemoveSeekTrigger, function(v) Ex.RemoveSeekTrigger = v end)
AddToggle(AntisTab, "RemoveFigure", "Remove Figure", "Fully removes the 'Figure' entity (does not always work).", Ex.RemoveFigure, function(v) Ex.RemoveFigure = v end)
AddToggle(AntisTab, "AutoRevive", "Infinite Revives", "Auto-revives after dying, with infinite respawns (Old Hotel / Fools).", Ex.AutoRevive, function(v) Ex.AutoRevive = v end)
AddToggle(AntisTab, "FigureGodmode", "Figure Godmode", "Prevents 'Figure' from hurting you (all floors: underground spoof while Figure is near).", Ex.FigureGodmode, function(v) Ex.FigureGodmode = v end)
AddToggle(AntisTab, "RemoveBasementGate", "Remove Basement Gate", "Removes the gate from basement rooms.", Ex.RemoveBasementGate, function(v) Apply("RemoveBasementGate", v) end)
AddToggle(AntisTab, "RemovePaintingsDoor", "Remove Paintings Door", "Removes the fireplace doors from painting rooms.", Ex.RemovePaintingsDoor, function(v) Apply("RemovePaintingsDoor", v) end)
AddToggle(AntisTab, "RemoveSkeletonDoor", "Remove Skeleton Door", "Removes the skeleton door from the infirmary.", Ex.RemoveSkeletonDoor, function(v) Apply("RemoveSkeletonDoor", v) end)
end)()

print("[AMBUSH HUB] Loaded Anticheat and Anti UI")
;(function()
local PPS = game:GetService("ProximityPromptService")
local LG = {
    Paused = nil, Hold = 0, Quiet = nil, T0 = 0, ThreatAt = 0,
    Prompts = setmetatable({}, { __mode = "k" }),
    Disabled = {},
}
FX.LadderGuard = LG
local SG = { ref = nil, locked = false, jp = nil, jh = nil, ThreatAt = 0, Fixes = 0, Note = 0 }
FX.SpoofGuard = SG

local KILL = {
    RushMoving = 85, AmbushMoving = 150, A60 = 125, A120 = 85,
    GlitchRush = 90, GlitchAmbush = 175, BackdoorRush = 85,
}
local PAUSE_IDS = { "ACM", "Noclip", "Fly" }

local function Killer(root)
    local best, bd = nil, math.huge
    for _, c in ipairs(Workspace:GetChildren()) do
        local r = KILL[c.Name]
        if r and c:IsA("Model") and c:GetAttribute("Inactive") ~= true then
            local pp = c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart")
            if pp then
                local d = (pp.Position - root.Position).Magnitude
                if d < r * 1.15 + 10 and d < bd then best, bd = c, d end
            end
        end
    end
    return best
end

local function IsLadder(pp)
    local cur = pp.Parent
    for _ = 1, 5 do
        if not cur then break end
        local n = cur.Name:lower()
        if n:find("ladder", 1, true) or n:find("climb", 1, true) then return true end
        cur = cur.Parent
    end
    return pp.Name:lower():find("climb", 1, true) ~= nil
end

local function Pause()
    if LG.Paused or Ex.LadderSafe == false then return end
    LG.Paused = {}
    LG.T0 = os.clock()
    FX.LadderPause = true
    for _, id in ipairs(PAUSE_IDS) do
        if Ex[id] then
            LG.Paused[#LG.Paused + 1] = id
            pcall(Apply, id, false)
        end
    end
    local _, hum = GetParts()
    if hum and (Ex.SpeedHack or FX.BotSpeed) then
        pcall(function() hum.WalkSpeed = Saved.HackWS or FX.NormalWS or 16 end)
    end
    NotifyUI("Ladder Safe Mode", "Speed hacks paused while you use the ladder.")
end

local function Resume()
    if not LG.Paused then return end
    local list = LG.Paused
    LG.Paused, LG.Quiet = nil, nil
    FX.LadderPause = nil
    for _, id in ipairs(list) do pcall(Apply, id, true) end
    NotifyUI("Ladder Safe Mode", "Speed hacks are back on.")
end

PPS.PromptTriggered:Connect(function(pp, plr)
    if plr ~= LocalPlayer or Ex.LadderSafe == false then return end
    if IsLadder(pp) then
        LG.Hold = os.clock() + 2.5
        Pause()
    end
end)

local lastPoll = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastPoll < 0.1 then return end
    lastPoll = now
    local char, hum, root = GetParts()
    if Ex.LadderSafe == false then
        if LG.Paused then Resume() end
        return
    end
    local climbing = false
    if char then
        climbing = char:GetAttribute("Climbing") == true or LocalPlayer:GetAttribute("Climbing") == true
        if hum and hum:GetState() == Enum.HumanoidStateType.Climbing then climbing = true end
        if hum and root and hum.FloorMaterial == Enum.Material.Air and math.abs(root.AssemblyLinearVelocity.Y) > 1.5 then
            climbing = LG.Paused ~= nil and true or climbing
        end
    end
    if not LG.Paused then
        if climbing then
            LG.Hold = now + 1.5
            Pause()
        end
        return
    end
    if now < LG.Hold then climbing = true end
    if climbing then LG.Quiet = nil else LG.Quiet = LG.Quiet or now end
    if (LG.Quiet and now - LG.Quiet >= 1.0) or now - LG.T0 > 20 or not char then Resume() end
end)

task.spawn(function()
    local rooms = Workspace:WaitForChild("CurrentRooms", 60)
    if not rooms then return end
    local function Track(d)
        if d:IsA("ProximityPrompt") and IsLadder(d) then LG.Prompts[d] = true end
    end
    for _, d in ipairs(rooms:GetDescendants()) do Track(d) end
    rooms.DescendantAdded:Connect(Track)
end)

local GP = RaycastParams.new()
GP.FilterType = Enum.RaycastFilterType.Exclude
GP.RespectCanCollide = true

local function UnlockJump(hum)
    if not SG.locked then return end
    SG.locked = false
    FX.JumpLocked = nil
    if hum then
        pcall(function()
            if SG.jp then hum.JumpPower = SG.jp end
            if SG.jh then hum.JumpHeight = SG.jh end
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end)
    end
end

RunService.Stepped:Connect(function()
    local now = os.clock()
    local char, hum, root = GetParts()
    local on = Ex.PositionSpoof and Ex.PositionSpoofStrong ~= false and root ~= nil
    local th = on and Killer(root) or nil

    if th then
        LG.ThreatAt = now
        for pp in pairs(LG.Prompts) do
            if pp.Parent and pp.Enabled and not LG.Disabled[pp] then
                LG.Disabled[pp] = true
                pp.Enabled = false
            end
        end
    elseif next(LG.Disabled) and now - LG.ThreatAt > 0.8 then
        for pp in pairs(LG.Disabled) do
            if pp.Parent then pp.Enabled = true end
            LG.Disabled[pp] = nil
        end
    end

    if not on then
        if SG.locked then UnlockJump(hum) end
        SG.ref = nil
        return
    end

    GP.FilterDescendantsInstances = { char }
    local hit = Workspace:Raycast(root.Position + Vector3.new(0, 6, 0), Vector3.new(0, -40, 0), GP)
    if hit then
        local off = root.Position.Y - hit.Position.Y
        local vy = root.AssemblyLinearVelocity.Y
        if not th then
            if math.abs(vy) < 3 then SG.ref = SG.ref and (SG.ref + (off - SG.ref) * 0.25) or off end
        else
            SG.ref = SG.ref or off
            local excess = off - SG.ref
            if excess > 0.4 then
                root.CFrame = root.CFrame - Vector3.new(0, excess, 0)
                local v = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(v.X, math.min(v.Y, 0), v.Z)
                SG.Fixes = SG.Fixes + 1
            end
        end
    end

    if th and hum then
        SG.ThreatAt = now
        if not SG.locked then
            SG.locked = true
            FX.JumpLocked = true
            SG.jp, SG.jh = hum.JumpPower, hum.JumpHeight
            if now - SG.Note > 6 then
                SG.Note = now
                NotifyUI("Strong Position Spoof", "Entity in range: jump, step-ups and ladders locked.")
            end
        end
        hum.Jump = false
        pcall(function()
            hum.JumpPower = 0
            hum.JumpHeight = 0
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        end)
    elseif SG.locked and now - SG.ThreatAt > 0.8 then
        UnlockJump(hum)
    end
end)

-- Wrap PositionSpoof hook: add SpoofGuard cleanup on top of existing hook.
-- This preserves the chain: original hook (CFrame/HipHeight shift) →
-- SpoofGuard cleanup (reset ref, unlock jump) → Main Port listeners.
Hooks.PositionSpoof = (function(prev)
    return function(v)
        if prev then pcall(prev, v) end
        SG.ref = nil
        if not v and SG.locked then
            local _, hum = GetParts()
            UnlockJump(hum)
        end
    end
end)(Hooks.PositionSpoof)
end)()

print("[AMBUSH HUB] Loading Extra Functions")
;(function()
local RS = game:GetService("ReplicatedStorage")
local PPS = game:GetService("ProximityPromptService")
local Hui = (gethui and gethui()) or game:GetService("CoreGui")

local function RemotesFolder()
        return RS:FindFirstChild("RemotesFolder") or RS:FindFirstChild("EntityInfo") or RS:FindFirstChild("Bricks")
end
local function Rooms() return Workspace:FindFirstChild("CurrentRooms") end
local function Char() return LocalPlayer.Character end
local function HasItem(Name, OnlyCharacter)
        local c = Char()
        if not OnlyCharacter then
                local bp = LocalPlayer:FindFirstChild("Backpack")
                local it = bp and bp:FindFirstChild(Name)
                if it then return it end
        end
        return c and c:FindFirstChild(Name) or nil
end

Ex.AutoBreakerBox = false
Ex.InfiniteItems = false
Ex.InfiniteItemsList = { "Lockpicks", "Skeleton Key", "Shears", "Multitool" }
Ex.AutoInteract = false
Ex.PromptReach = 1
Ex.PromptClip = false
Ex.DisableIdleKick = false
Ex.MeldStopGrowth = false
Ex.MeldRemove = false

local Prompts = setmetatable({}, { __mode = "k" })

local function ApplyReach(pp)
        if not pp:IsA("ProximityPrompt") or pp:GetAttribute("FakePrompt") then return end
        local o = Prompts[pp]
        if not o then
                o = { Dist = pp.MaxActivationDistance, LOS = pp.RequiresLineOfSight }
                Prompts[pp] = o
        end
        pp.MaxActivationDistance = o.Dist * Ex.PromptReach
        pp.RequiresLineOfSight = Ex.PromptClip and false or o.LOS
end
local function ReapplyAllReach()
        for pp in pairs(Prompts) do
                if pp.Parent then
                        pcall(function()
                                local o = Prompts[pp]
                                pp.MaxActivationDistance = o.Dist * Ex.PromptReach
                                pp.RequiresLineOfSight = Ex.PromptClip and false or o.LOS
                        end)
                end
        end
end
local function ScanReach()
        task.spawn(function()
                local n = 0
                for _, d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then pcall(ApplyReach, d) end
                        n = n + 1
                        if n % 400 == 0 then task.wait() end
                end
                ReapplyAllReach()
        end)
end
Hooks.PromptReach = function() ScanReach() end
Hooks.PromptClip = function() ScanReach() end

local Breaker = { Interacted = false, Notified = false, Hooked = setmetatable({}, { __mode = "k" }) }
local function HookBreaker(obj)
        if Breaker.Hooked[obj] then return end
        Breaker.Hooked[obj] = true
        task.spawn(function()
                local sg = obj:WaitForChild("SurfaceGui", 15)
                local frame = sg and sg:WaitForChild("Frame", 5)
                local code = frame and frame:WaitForChild("Code", 5)
                if not code then return end
                if Ex.AutoBreakerBox and not Breaker.Notified then
                        Breaker.Notified = true
                        NotifyUI("Auto Breaker Box", "Interact with the breaker box once. It will be solved automatically.")
                end
                code:GetPropertyChangedSignal("Text"):Connect(function()
                        if Ex.AutoBreakerBox then
                                local rf = RemotesFolder()
                                local r = rf and rf:FindFirstChild("EBF")
                                if r then pcall(function() r:FireServer() end) end
                        end
                        Breaker.Interacted = true
                end)
        end)
end
Hooks.AutoBreakerBox = function(v)
        if not v then return end
        local rooms = Rooms()
        local br = rooms and rooms:FindFirstChild("ElevatorBreaker", true)
        if br then
                HookBreaker(br)
                if Breaker.Interacted then
                        local rf = RemotesFolder()
                        local r = rf and rf:FindFirstChild("EBF")
                        if r then pcall(function() r:FireServer() end) end
                else
                        NotifyUI("Auto Breaker Box", "Interact with the breaker box once. It will be solved automatically.")
                end
        end
end

local IF = { Fakes = {}, Real = setmetatable({}, { __mode = "k" }), Container = Instance.new("Folder") }
IF.Container.Name = "R4_PromptContainer"
pcall(function() IF.Container.Parent = Hui end)
local TOOL_DISPLAY = { Lockpick = "Lockpicks", SkeletonKey = "Skeleton Key", Shears = "Shears", Multitool = "Multitool" }
local LOCK_NAMES = { UnlockPrompt = true, SkullPrompt = true, LockPrompt = true, ThingToEnable = true, FusesPrompt = true }

local function IsLockPrompt(p)
        return LOCK_NAMES[p.Name]
                or (p.Parent and p.Parent:GetAttribute("Locked") == true)
                or (p.Parent and p.Parent.Parent and p.Parent.Parent.Name == "Locker_Small_Locked" and p.Name == "ActivateEventPrompt")
end

local function InfListHas(display)
        for _, n in ipairs(Ex.InfiniteItemsList or {}) do
                if n == display then return true end
        end
        return false
end

local function MakeFake(real)
        if IF.Real[real] or real:GetAttribute("FakePrompt") or not IsLockPrompt(real) or not fireproximityprompt then return end
        local parent = real.Parent
        if not parent then return end
        local fake = real:Clone()
        fake:SetAttribute("FakePrompt", true)
        fake.Parent = parent
        IF.Fakes[fake] = real
        IF.Real[real] = fake
        pcall(function() real.Parent = IF.Container end)
        local conn = real:GetPropertyChangedSignal("Enabled"):Connect(function() fake.Enabled = real.Enabled end)
        real:GetPropertyChangedSignal("ActionText"):Once(function()
                pcall(function() real.Parent = parent end)
                fake:Destroy()
                conn:Disconnect()
                IF.Real[real] = nil
        end)
        real.Destroying:Once(function() fake:Destroy(); conn:Disconnect(); IF.Real[real] = nil end)
        fake.Enabled = real.Enabled
end

local function RemoveFakes()
        for fake, real in pairs(IF.Fakes) do
                pcall(function()
                        if real and fake.Parent then real.Parent = fake.Parent end
                        fake:Destroy()
                end)
                IF.Fakes[fake] = nil
                if real then IF.Real[real] = nil end
        end
end

Hooks.InfiniteItems = function(v)
        if not fireproximityprompt then
                NotifyUI("Infinite Items", "Your executor has no fireproximityprompt. This feature is disabled.")
                return
        end
        if v then
                task.spawn(function()
                        local n = 0
                        for _, d in ipairs(Workspace:GetDescendants()) do
                                if not Ex.InfiniteItems then return end
                                if d:IsA("ProximityPrompt") then pcall(MakeFake, d) end
                                n = n + 1
                                if n % 400 == 0 then task.wait() end
                        end
                end)
        else
                RemoveFakes()
        end
end

PPS.PromptTriggered:Connect(function(Object)
        if not Object:GetAttribute("FakePrompt") then return end
        local real = IF.Fakes[Object]
        if not real then return end
        local char = Char()
        if not char then return end

        local Tool
        for _, N in { "Lockpick", "Shears", "SkeletonKey", "Key", "GeneratorFuse", "KeyElectrical", "KeyBackdoor", "KeyIron", "Multitool" } do
                Tool = char:FindFirstChild(N)
                if Tool then break end
        end
        local Parent = Object.Parent
        local PName = Parent and Parent.Name or ""
        local Lock = IsLockPrompt(Object)

        if Lock then
                local has = false
                for _, K in { "Key", "GeneratorFuse", "KeyBackdoor", "KeyElectrical", "KeyIron", "Lockpick", "SkeletonKey", "Shears", "Multitool" } do
                        if HasItem(K, true) then has = true break end
                end
                if not has then
                        for _, K in { "Key", "GeneratorFuse", "KeyElectrical", "KeyIron" } do
                                if HasItem(K) then has = true break end
                        end
                end
                if not has then return end
        end
        local vine = PName == "CuttableVines" or PName == "Chest_Vine" or PName == "Cellar"
        if vine and not HasItem("Shears", true) and not HasItem("Multitool", true) then return end
        if PName == "SkullLock" and not HasItem("SkeletonKey", true) then return end
        if (PName == "Lock1" or PName == "Lock2") and not HasItem("Lockpick", true) and not HasItem("Multitool", true) then return end
        if HasItem("Shears", true) and Lock and not vine then return end

        local AnyTool = char:FindFirstChildOfClass("Tool")
        local display = AnyTool and TOOL_DISPLAY[AnyTool.Name]
        local rf = RemotesFolder()
        local Drops = Workspace:FindFirstChild("Drops")
        if AnyTool and display and Ex.InfiniteItems and InfListHas(display) and rf and rf:FindFirstChild("DropItem") and Drops then
                Drops.ChildAdded:Once(function(NewTool)
                        local pickup = NewTool:FindFirstChild("ModulePrompt") or NewTool:WaitForChild("ModulePrompt", 3)
                        if pickup then pcall(fireproximityprompt, pickup) end
                        pcall(fireproximityprompt, real)
                end)
                rf.DropItem:FireServer(AnyTool)
        else
                pcall(fireproximityprompt, real)
        end
end)

local AI_BLACKLIST = {
        HidePrompt = true, RiftPrompt = true, StarRiftPrompt = true, InteractPrompt = true, ClimbPrompt = true,
        DonatePrompt = true, DialoguePrompt = true, RevivePrompt = true, EnterPrompt = true, AnimatePrompt = true,
        ToolEventPrompt = true, Prompt = true, PropPrompt = true,
        LongPushPrompt = true, BigPropPrompt = true, PushPrompt = true,
}
local AI = { Last = 0, Set = setmetatable({}, { __mode = "k" }), Static = setmetatable({}, { __mode = "k" }) }

local AI_SIT_WORDS = { "sit", "seat", "chair", "sofa", "couch", "bench", "stool", "throne", "armchair", "recliner" }
local AI_JEFF_WORDS = { "jeff", "shop", "purchase", "buy", "vendor", "merchant", "store", "cashier", "sell" }
local AI_JUNK_WORDS = { "donate", "tithe", "dialogue", "talk", "revive", "emote", "dance", "gift" }

local function AIHas(str, list)
        if type(str) ~= "string" or str == "" then return false end
        str = str:lower()
        for _, w in ipairs(list) do
                if str:find(w, 1, true) then return true end
        end
        return false
end

local function AIWord(str, list)
        if type(str) ~= "string" or str == "" then return false end
        str = str:gsub("(%l)(%u)", "%1 %2"):gsub("[^%a]+", " "):lower()
        for w in str:gmatch("%a+") do
                for _, k in ipairs(list) do
                        if w == k or w == k .. "s" then return true end
                end
        end
        return false
end

local function AIIsSeat(inst)
        return inst:IsA("Seat") or inst:IsA("VehicleSeat")
end

local function AIStaticSkip(pp)
        local at, ot = pp.ActionText, pp.ObjectText
        if AIWord(pp.Name, AI_SIT_WORDS) or AIWord(at, AI_SIT_WORDS) or AIWord(ot, AI_SIT_WORDS) then return true end
        if type(at) == "string" and (at:lower():find("sent", 1, true) or at:lower():find("siénta", 1, true)) then return true end
        if AIWord(pp.Name, AI_JEFF_WORDS) or AIWord(at, AI_JEFF_WORDS) or AIWord(ot, AI_JEFF_WORDS) then return true end
        if AIWord(pp.Name, AI_JUNK_WORDS) or AIWord(at, AI_JUNK_WORDS) then return true end

        local par = pp.Parent
        if not par then return false end
        if AIIsSeat(par) then return true end

        local cur, depth = par, 0
        while cur and cur ~= Workspace and depth < 6 do
                if AIIsSeat(cur) then return true end
                local n = cur.Name
                if AIWord(n, AI_SIT_WORDS) or AIWord(n, AI_JEFF_WORDS) then return true end
                if cur:GetAttribute("JeffShop") or cur:GetAttribute("Shop") or cur:GetAttribute("ShopItem") or cur:GetAttribute("Price") or cur:GetAttribute("Cost") then return true end
                if depth <= 1 and not cur:IsA("Folder") then
                        for _, c in ipairs(cur:GetChildren()) do
                                if AIIsSeat(c) then return true end
                        end
                end
                cur = cur.Parent
                depth = depth + 1
        end
        return false
end

task.spawn(function()
        while true do
                task.wait(0.15)
                if Ex.AutoInteract then
                        pcall(function()
                                local _, hum = GetParts()
                                if hum and hum.Sit and hum.SeatPart and (hum.SeatPart:IsA("Seat") or hum.SeatPart:IsA("VehicleSeat")) then
                                        hum.Sit = false
                                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                end
                        end)
                end
        end
end)

AI.Reason = setmetatable({}, { __mode = "k" })
AI.Fired = setmetatable({}, { __mode = "k" })
local AI_TTL = 2.5

local function AISkip(pp)
        local function skip(r) AI.Reason[pp] = r return true end
        if Ex.AIExtraSkip and Ex.AIExtraSkip(pp) then return skip("Ignore List (" .. tostring(Ex.AILastCat and Ex.AILastCat[pp] or "item/type") .. ")") end
        -- Ported from rush.txt: let HidePrompt/HidingPrompt through when
        -- AutoClosetToggle is on and an entity is within kill range, so the
        -- auto-closet feature can actually trigger from Auto Interact.
        if AI_BLACKLIST[pp.Name] then
                local isHide = (pp.Name == "HidePrompt" or pp.Name == "HidingPrompt")
                if isHide and Ex.AutoClosetToggle then
                        local F = FX.Functions
                        local ent = F and F.GetNearestEntity and F.GetNearestEntity(true, nil)
                        local _, _, root = GetParts()
                        if ent and ent.PrimaryPart and root then
                                local d = (ent.PrimaryPart.Position - root.Position).Magnitude
                                local lim = (FX.EntityDistances and FX.EntityDistances[ent.Name]) or 150
                                if d <= lim then
                                        -- allow the hide prompt through; do not skip
                                else
                                        return skip("auto-closet on but no entity in range")
                                end
                        else
                                return skip("auto-closet on but no entity / no root")
                        end
                else
                        return skip("built-in blacklist: " .. pp.Name)
                end
        end
        if pp:GetAttribute("FakePrompt") or pp:GetAttribute("AutoInteractIgnore") then return skip("fake / AutoInteractIgnore") end
        local par = pp.Parent
        if not par then return skip("no parent") end
        local now = os.clock()
        local ent = AI.Static[pp]
        if ent == nil or now - ent.t > AI_TTL then
                ent = { v = AIStaticSkip(pp) and true or false, t = now }
                AI.Static[pp] = ent
        end
        if ent.v then return skip("sit / Jeff-shop / junk filter") end
        local Drops = Workspace:FindFirstChild("Drops")
        if Drops and pp:IsDescendantOf(Drops) then return skip("dropped item") end
        local n = par.Name
        if n == "GlitchCube" or n == "TrackLever" or n == "Padlock" or n == "MinesAnchor" or n == "ElevatorBreaker"
                or n == "KeyObtainFake" or n == "TithingPlate" then return skip("special object: " .. n) end
        if par.Parent and (par.Parent.Name == "DoorFake" or par.Parent.Name == "FakeDoor" or par.Parent.Name == "IndustrialGate") then return skip("fake door / gate") end
        if par:GetAttribute("JeffShop") then return skip("Jeff shop") end
        if pp.Name == "ActivateEventPrompt" and pp.ActionText == "Close" then return skip("close action") end
        if n == "KeyObtain" and (HasItem("Key") or HasItem("KeyBackdoor")) then return skip("you already have the key") end
        if n == "ElectricalKeyObtain" and HasItem("KeyElectrical") then return skip("you already have the key") end
        if n == "AlarmClock" and HasItem("AlarmClock") then return skip("you already have it") end
        if n == "Bandage" then
                local _, hum = GetParts()
                if hum and hum.Health >= hum.MaxHealth and not HasItem("BandagePack") then return skip("full health") end
        end
        AI.Reason[pp] = nil
        return false
end

Ex.AIWhy = function(pp)
        if not pp.Enabled then return "prompt is disabled by the game" end
        if AISkip(pp) then return "SKIPPED: " .. tostring(AI.Reason[pp]) end
        local pr, cur = tonumber(pp:GetAttribute("ParentRoom")), tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
        if pr and cur and math.abs(pr - cur) > 1 then return "SKIPPED: belongs to room " .. pr .. " (you are in " .. cur .. ")" end
        return "allowed"
end

local function AIDist(pp, rp)
        local par = pp.Parent
        if par:IsA("BasePart") then return (par.Position - rp).Magnitude end
        if par:IsA("Attachment") then return (par.WorldPosition - rp).Magnitude end
        if par:IsA("Model") then
                local best = (par:GetPivot().Position - rp).Magnitude
                if best > 70 then return best end
                local k = 0
                for _, c in ipairs(par:GetChildren()) do
                        if c:IsA("BasePart") then
                                local d = (c.Position - rp).Magnitude
                                if d < best then best = d end
                                k = k + 1
                                if k >= 24 then break end
                        end
                end
                return best
        end
        return math.huge
end

AI.Beat = os.clock()
AI.LastRoom = nil
AI.Near, AI.NearT = {}, 0

AI.Rescan = function(onlyRooms)
        local function scan(root)
                local k = 0
                for _, d in ipairs(root:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then AI.Set[d] = true end
                        k = k + 1
                        if k % 500 == 0 then task.wait() end
                end
        end
        if onlyRooms then
                local rooms = Workspace:FindFirstChild("CurrentRooms")
                local cur = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
                if rooms and cur then
                        for n = cur - 1, cur + 1 do
                                local r = rooms:FindFirstChild(tostring(n))
                                if r then scan(r) end
                        end
                        return
                end
        end
        scan(Workspace)
end

local AI_LOCKNAMES = { UnlockPrompt = true, SkullPrompt = true, LockPrompt = true, ThingToEnable = true, FusesPrompt = true }
local AI_KEYS = { "Key", "GeneratorFuse", "KeyBackdoor", "KeyElectrical", "KeyIron", "Lockpick", "SkeletonKey", "Shears", "Multitool" }
local AI_OFFHAND = { "Key", "GeneratorFuse", "KeyElectrical", "KeyIron" }

local function AIMain(pp)
        local par = pp.Parent
        if not par then return false end
        local pn = par.Name
        local gp = par.Parent
        local gpn = gp and gp.Name or ""
        local pname = pp.Name

        local isLock = AI_LOCKNAMES[pname] or par:GetAttribute("Locked") == true
                or (gpn == "Locker_Small_Locked" and pname == "ActivateEventPrompt")
        if isLock then
                local has = false
                for _, k in ipairs(AI_KEYS) do
                        if HasItem(k, true) then has = true break end
                end
                if not has then
                        for _, k in ipairs(AI_OFFHAND) do
                                if HasItem(k) then has = true break end
                        end
                end
                if not has then return false end
        end

        local vine = pn == "CuttableVines" or pn == "Chest_Vine" or pn == "Cellar"
        if vine and not HasItem("Shears", true) and not HasItem("Multitool", true) then return false end
        if pn == "SkullLock" and not HasItem("SkeletonKey", true) then return false end
        if (pn == "Lock1" or pn == "Lock2") and not HasItem("Lockpick", true) and not HasItem("Multitool", true) then return false end
        if HasItem("Shears", true) and isLock and not vine then return false end

        if pn == "TrackLever" then return false end
        if pname == "ActivateEventPrompt" and (pp.ActionText == "Close" or pn == "ElevatorBreaker" or gpn == "IndustrialGate") then return false end
        if pname == "ActivateEventPrompt" and (pn == "Padlock" or pn == "MinesAnchor") then return false end
        if pn == "LeverForGate" and pp:GetAttribute("Interactions") then return false end
        if gpn == "DoorFake" or gpn == "FakeDoor" then return false end

        if pn == "Battery" then
                local char = LocalPlayer.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                local pack = HasItem("BatteryPack")
                if not tool and not pack then return false end
                if tool and tool:GetAttribute("LightSource") then
                        local du, dm = tool:GetAttribute("Durability"), tool:GetAttribute("DurabilityMax")
                        if du and dm and du > dm then return false end
                elseif not pack then
                        return false
                end
                if pack then
                        local du, dm = pack:GetAttribute("Durability"), pack:GetAttribute("DurabilityMax")
                        if du and dm and du >= dm then return false end
                end
        end
        if pn == "Bandage" then
                local pack = HasItem("BandagePack")
                if pack then
                        local du, dm = pack:GetAttribute("Durability"), pack:GetAttribute("DurabilityMax")
                        if du and dm and du >= dm then return false end
                end
        end
        if (pn == "LibraryHintPaper" or pn == "PickupItem") and (HasItem("LibraryHintPaper") or HasItem("LibraryHintPaperHard")) then return false end

        if pn == "StarBottle" or pn == "ArchivesStorageBox" or pname == "SinkPrompt" or pn == "Faucet" then return false end
        if pname == "ManualOpenPrompt" or pname == "EntryPrompt" or gpn == "ArchivesLargePrinter" then return false end
        if pname == "TrashcanPrompt" or pn == "Keyboard" or pname == "CartPrompt" or gpn == "ArchivesOfficeChair" then return false end
        if pn == "ArchivesTerminal" or pname == "VendorPrompt" or pn == "SeatPart" or pname == "SeatPrompt" then return false end
        if pn == "StairwellScrapper" or pname == "PortraitDupePrompt" or pn == "MirrorTool" then return false end
        if pname == "LaptopPrompt" or pn == "SecretLaptop" or pn == "StairwellFireAlarm" or gpn == "StairwellFireAlarm" then return false end
        if pn == "CobblerFriendly" or pn == "StairwellTerminal" or gpn == "MeldChord" then return false end
        -- Ported from rush.txt Auto Interact: skip HerbPrompt if the
        -- green herb effect is already active on the local player's HUD.
        if pname == "HerbPrompt" then
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                local mui = pgui and pgui:FindFirstChild("MainUI")
                local mf = mui and mui:FindFirstChild("MainFrame")
                local hb = mf and mf:FindFirstChild("Healthbar")
                local fx = hb and hb:FindFirstChild("Effects")
                if fx and fx:FindFirstChild("HerbGreenEffect") and fx.HerbGreenEffect.Visible then return false end
        end
        return true
end

local AIAlt = {}
local function AIFire(pp)
        if fireproximityprompt then
                fireproximityprompt(pp)
                return
        end
        if AIAlt[pp] then return end
        AIAlt[pp] = true
        task.spawn(function()
                local cam = Workspace.CurrentCamera
                local oldParent = pp.Parent
                if cam and oldParent then
                        local oD, oE, oH, oL = pp.MaxActivationDistance, pp.Enabled, pp.HoldDuration, pp.RequiresLineOfSight
                        pp.MaxActivationDistance, pp.Enabled, pp.HoldDuration, pp.RequiresLineOfSight = 99999, true, 0, false
                        local tmp = Instance.new("Part")
                        tmp.Anchored, tmp.CanCollide, tmp.CanQuery, tmp.CanTouch = true, false, false, false
                        tmp.Transparency = 1
                        tmp.Size = Vector3.new(0.001, 0.001, 0.001)
                        tmp.Position = cam.CFrame:ToWorldSpace(CFrame.new(0, 0, -0.1)).Position
                        tmp.Parent = Workspace
                        pcall(function() pp.Parent = tmp end)
                        local fired = false
                        local c1 = pp.Triggered:Connect(function() fired = true end)
                        local t = 0
                        while not fired and t < 6 do
                                pcall(function() pp:InputHoldBegin() pp:InputHoldEnd() end)
                                t = t + 1
                                task.wait()
                        end
                        c1:Disconnect()
                        pp.MaxActivationDistance, pp.Enabled, pp.HoldDuration, pp.RequiresLineOfSight = oD, oE, oH, oL
                        pcall(function() pp.Parent = oldParent end)
                        tmp:Destroy()
                end
                task.wait()
                AIAlt[pp] = nil
        end)
end

AI.Loop = function()
        local lastScan = os.clock()
        pcall(AI.Rescan)
        while true do
                RunService.Heartbeat:Wait()
                AI.Beat = os.clock()
                if Ex.AutoInteract then
                        local okp, _, _, root = pcall(GetParts)
                        if okp and root then
                                local now = os.clock()
                                local rp = root.Position
                                local cur = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
                                if now - AI.NearT > 0.2 then
                                        AI.NearT = now
                                        local near, k = {}, 0
                                        for pp in pairs(AI.Set) do
                                                if not pp.Parent then
                                                        AI.Set[pp] = nil
                                                elseif pp.Enabled then
                                                        local okd, d = pcall(AIDist, pp, rp)
                                                        if okd and d <= pp.MaxActivationDistance + 12 then
                                                                k = k + 1
                                                                near[k] = pp
                                                        end
                                                end
                                        end
                                        AI.Near = near
                                end
                                for _, pp in ipairs(AI.Near) do
                                        pcall(function()
                                                if pp.Parent and pp.Enabled and (not AI.Fired[pp] or now - AI.Fired[pp] > 0.12) then
                                                        if AIDist(pp, rp) <= pp.MaxActivationDistance + 0.5 and not AISkip(pp) then
                                                                local pr = tonumber(pp:GetAttribute("ParentRoom"))
                                                                if not (pr and cur and math.abs(pr - cur) > 1) and AIMain(pp) then
                                                                        AI.Fired[pp] = now
                                                                        AIFire(pp)
                                                                end
                                                        end
                                                end
                                        end)
                                end
                                if cur ~= AI.LastRoom or now - lastScan > 45 then
                                        lastScan = now
                                        AI.LastRoom = cur
                                        task.spawn(function() pcall(AI.Rescan, true) end)
                                end
                        end
                end
        end
end
AI.Thread = task.spawn(AI.Loop)
task.spawn(function()
        while true do
                task.wait(2)
                if os.clock() - AI.Beat > 4 then
                        pcall(task.cancel, AI.Thread)
                        AI.Beat = os.clock()
                        AI.Thread = task.spawn(AI.Loop)
                end
        end
end)

Ex.NotifyOxygen = false
Ex.NotifyHaste = false
Ex.NoClosetDelay = false
Ex.NoAcceleration = false
Ex.DoorReach = false
Ex.NoFootsteps = false
Ex.NoPromptSounds = false

local Cap = { Gui = nil, Label = nil, Token = 0 }
local function Caption(text)
        pcall(function()
                if not Cap.Gui or not Cap.Gui.Parent then
                        local g = Instance.new("ScreenGui")
                        g.Name = "R4_Caption"
                        g.ResetOnSpawn = false
                        g.IgnoreGuiInset = true
                        g.DisplayOrder = 50
                        local l = Instance.new("TextLabel")
                        l.BackgroundTransparency = 1
                        l.AnchorPoint = Vector2.new(0.5, 1)
                        l.Position = UDim2.new(0.5, 0, 0.82, 0)
                        l.Size = UDim2.new(0.6, 0, 0, 34)
                        l.Font = Enum.Font.GothamBold
                        l.TextSize = 24
                        l.TextColor3 = Color3.new(1, 1, 1)
                        l.Parent = g
                        g.Parent = Hui
                        Cap.Gui, Cap.Label = g, l
                end
                Cap.Token = Cap.Token + 1
                local tk = Cap.Token
                Cap.Label.Text = text
                Cap.Label.TextTransparency = 0
                Cap.Label.TextStrokeTransparency = 0.4
                task.delay(2.5, function()
                        if Cap.Token == tk and Cap.Label and Cap.Label.Parent then
                                TweenService:Create(Cap.Label, TweenInfo.new(1.2), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
                        end
                end)
        end)
end

local OxyConn, OxyLast
local function HookOxygen(char)
        if OxyConn then OxyConn:Disconnect(); OxyConn = nil end
        if not char then return end
        OxyLast = char:GetAttribute("Oxygen")
        OxyConn = char:GetAttributeChangedSignal("Oxygen"):Connect(function()
                local n = char:GetAttribute("Oxygen")
                if Ex.NotifyOxygen and type(n) == "number" and type(OxyLast) == "number" and n < OxyLast then
                        Caption("Oxygen: " .. (math.floor(n * 10) / 10) .. "%")
                end
                OxyLast = n
        end)
end
HookOxygen(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(HookOxygen)

local HasteTimer, HasteConn
task.spawn(function()
        while true do
                pcall(function()
                        local fr = RS:FindFirstChild("FloorReplicated")
                        local t = fr and fr:FindFirstChild("DigitalTimer")
                        if t and t ~= HasteTimer then
                                HasteTimer = t
                                if HasteConn then HasteConn:Disconnect() end
                                HasteConn = t:GetPropertyChangedSignal("Value"):Connect(function()
                                        if not Ex.NotifyHaste then return end
                                        local v = math.max(0, math.floor(tonumber(t.Value) or 0))
                                        Caption(string.format("%02d:%02d", math.floor(v / 60), v % 60))
                                end)
                        end
                end)
                task.wait(3)
        end
end)

local ClosetLast = 0
RunService.Heartbeat:Connect(function()
        if not Ex.NoClosetDelay then return end
        local now = os.clock()
        if now - ClosetLast < 0.1 then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local cp = char:FindFirstChild("CollisionPart") or char:FindFirstChild("Collision")
        if hum.MoveDirection ~= Vector3.zero
                and ((cp and cp:IsA("BasePart") and cp.Anchored) or root.Anchored)
                and char:GetAttribute("AnimatingClient") ~= true
                and char:GetAttribute("Hiding") == true then
                local rf = RemotesFolder()
                local r = rf and rf:FindFirstChild("CamLock")
                if r then
                        ClosetLast = now
                        pcall(function() r:FireServer() end)
                end
        end
end)

local AccelOrig = setmetatable({}, { __mode = "k" })
local function ApplyAccel(on)
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                        if on then
                                if AccelOrig[p] == nil then AccelOrig[p] = p.CustomPhysicalProperties or false end
                                local b = p.CustomPhysicalProperties
                                p.CustomPhysicalProperties = PhysicalProperties.new(100, b and b.Friction or 0.3, b and b.Elasticity or 0, b and b.FrictionWeight or 1, b and b.ElasticityWeight or 1)
                        elseif AccelOrig[p] ~= nil then
                                p.CustomPhysicalProperties = AccelOrig[p] or nil
                                AccelOrig[p] = nil
                        end
                end
        end
end
Hooks.NoAcceleration = function(v) ApplyAccel(v) end
LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.6)
        if Ex.NoAcceleration then ApplyAccel(true) end
end)

local DoorDone = setmetatable({}, { __mode = "k" })
local DoorHooked = setmetatable({}, { __mode = "k" })
local DoorLast = 0
RunService.Heartbeat:Connect(function()
        if not Ex.DoorReach then return end
        local now = os.clock()
        if now - DoorLast < 0.25 then return end
        DoorLast = now
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local rooms = Rooms()
        if not (root and rooms) then return end
        for _, room in ipairs(rooms:GetChildren()) do
                local model = room:FindFirstChild("Door")
                if model and not DoorDone[model] then
                        local part = model:FindFirstChild("Door")
                        local ce = model:FindFirstChild("ClientOpen")
                        if part and part:IsA("BasePart") and ce then
                                if not DoorHooked[model] then
                                        DoorHooked[model] = true
                                        local snd = part:FindFirstChild("Open")
                                        if snd and snd:IsA("Sound") then
                                                snd.Played:Once(function() DoorDone[model] = true end)
                                        end
                                end
                                if (part.Position - root.Position).Magnitude < 75 then
                                        pcall(function() ce:FireServer() end)
                                end
                        end
                end
        end
end)

local FootConn
local function HookFootsteps(char)
        if FootConn then FootConn:Disconnect(); FootConn = nil end
        if not char then return end
        FootConn = char.ChildAdded:Connect(function(o)
                if Ex.NoFootsteps and o:IsA("Sound") and o.Name == "Sound" then o.Volume = 0 end
        end)
end
HookFootsteps(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(HookFootsteps)

local function SetPromptSounds(mute)
        pcall(function()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local mg = pg and pg:FindFirstChild("MainUI") and pg.MainUI:FindFirstChild("Initiator")
                mg = mg and mg:FindFirstChild("Main_Game")
                local ps = mg and mg:FindFirstChild("PromptService")
                if ps then
                        if ps:FindFirstChild("Triggered") then ps.Triggered.Volume = mute and 0 or 0.04 end
                        if ps:FindFirstChild("Holding") then ps.Holding.Volume = mute and 0 or 0.1 end
                        if ps:FindFirstChild("Notification") then ps.Notification.Volume = mute and 0 or 0.03 end
                end
                local cap = mg and mg:FindFirstChild("Reminder") and mg.Reminder:FindFirstChild("Caption")
                if cap and cap:IsA("Sound") then cap.Volume = mute and 0 or 0.1 end
        end)
end
Hooks.NoPromptSounds = function(v) SetPromptSounds(v) end
task.spawn(function()
        while true do
                task.wait(1.5)
                if Ex.NoPromptSounds then SetPromptSounds(true) end
        end
end)

Hooks.DisableIdleKick = function(v)
        if getconnections then
                pcall(function()
                        for _, c in ipairs(getconnections(LocalPlayer.Idled)) do
                                if v then c:Disable() else c:Enable() end
                        end
                end)
        end
end
LocalPlayer.Idled:Connect(function()
        if Ex.DisableIdleKick then
                pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new())
                end)
        end
end)

print("[AMBUSH HUB] Loading Meld Scripts")
local MELD_KEEP = { "rope", "cord", "cable", "chain", "string", "wire", "door", "gate", "puerta", "cuerda" }
local Meld = { Orig = setmetatable({}, { __mode = "k" }), Scripts = setmetatable({}, { __mode = "k" }), Conn = nil, Loop = false }

local function IsMeldName(n) return type(n) == "string" and n:lower():find("meld", 1, true) ~= nil end
local function KeepName(n)
        n = n:lower()
        for _, w in ipairs(MELD_KEEP) do
                if n:find(w, 1, true) then return true end
        end
        return false
end
local function MeldRoot(inst)
        local p, i = inst, 0
        while p and p ~= Workspace and i < 12 do
                if IsMeldName(p.Name) and (p:IsA("Model") or p:IsA("Folder") or p:IsA("BasePart")) then return p end
                p, i = p.Parent, i + 1
        end
end
local function UnderKeep(part, root)
        local p, i = part, 0
        while p and i < 12 do
                if KeepName(p.Name) then return true end
                if p == root then break end
                p, i = p.Parent, i + 1
        end
        return false
end

local function MeldHidePart(part)
        if part:IsA("BasePart") then
                if not Meld.Orig[part] then Meld.Orig[part] = { T = part.Transparency, C = part.CanCollide, Touch = part.CanTouch } end
                part.Transparency, part.CanCollide, part.CanTouch = 1, false, false
        elseif part:IsA("ParticleEmitter") or part:IsA("Beam") or part:IsA("Trail") or part:IsA("Light") then
                if not Meld.Orig[part] then Meld.Orig[part] = { En = part.Enabled } end
                part.Enabled = false
        elseif part:IsA("Decal") or part:IsA("Texture") then
                if not Meld.Orig[part] then Meld.Orig[part] = { T = part.Transparency } end
                part.Transparency = 1
        end
end

local function MeldRestoreAll()
        for obj, o in pairs(Meld.Orig) do
                pcall(function()
                        if o.En ~= nil then obj.Enabled = o.En
                        elseif obj:IsA("BasePart") then obj.Transparency, obj.CanCollide, obj.CanTouch = o.T, o.C, o.Touch
                        else obj.Transparency = o.T end
                end)
                Meld.Orig[obj] = nil
        end
end

local function MeldHandle(d)
        if Ex.MeldStopGrowth then
                if (d:IsA("Script") or d:IsA("LocalScript")) and (IsMeldName(d.Name) or MeldRoot(d)) then
                        if Meld.Scripts[d] == nil then Meld.Scripts[d] = d.Disabled end
                        pcall(function() d.Disabled = true end)
                        if Cfg.Debug then print("[RON MELD] script disabled: " .. d:GetFullName()) end
                elseif d:IsA("ModuleScript") and IsMeldName(d.Name) and not d.Name:find("_Disabled", 1, true) then
                        Meld.Scripts[d] = d.Name
                        pcall(function() d.Name = d.Name .. "_Disabled" end)
                        if Cfg.Debug then print("[RON MELD] module disabled: " .. d:GetFullName()) end
                end
        end
        if Ex.MeldRemove and (d:IsA("BasePart") or d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Light") or d:IsA("Decal") or d:IsA("Texture")) then
                local root = MeldRoot(d)
                if root and not Players:GetPlayerFromCharacter(root) and not UnderKeep(d, root) then
                        MeldHidePart(d)
                end
        end
end

local function MeldScanAll()
        task.spawn(function()
                local n = 0
                local scopes = { Workspace, RS, LocalPlayer:FindFirstChild("PlayerGui") }
                for _, scope in ipairs(scopes) do
                        if scope then
                                for _, d in ipairs(scope:GetDescendants()) do
                                        if not (Ex.MeldStopGrowth or Ex.MeldRemove) then return end
                                        pcall(MeldHandle, d)
                                        n = n + 1
                                        if n % 300 == 0 then task.wait() end
                                end
                        end
                end
        end)
end

local function MeldRefresh()
        if Ex.MeldStopGrowth or Ex.MeldRemove then
                if not Meld.Conn then
                        Meld.Conn = Workspace.DescendantAdded:Connect(function(d) task.defer(pcall, MeldHandle, d) end)
                end
                MeldScanAll()
                if not Meld.Loop then
                        Meld.Loop = true
                        task.spawn(function()
                                while Ex.MeldStopGrowth or Ex.MeldRemove do
                                        task.wait(10)
                                        MeldScanAll()
                                end
                                Meld.Loop = false
                        end)
                end
        else
                if Meld.Conn then Meld.Conn:Disconnect(); Meld.Conn = nil end
        end
end

Hooks.MeldStopGrowth = function(v)
        if not v then
                for obj, old in pairs(Meld.Scripts) do
                        pcall(function()
                                if typeof(old) == "string" then obj.Name = old else obj.Disabled = old end
                        end)
                        Meld.Scripts[obj] = nil
                end
        end
        MeldRefresh()
end
Hooks.MeldRemove = function(v)
        if not v then MeldRestoreAll() end
        MeldRefresh()
end

print("[AMBUSH HUB] Loaded Meld Scripts")

Workspace.DescendantAdded:Connect(function(d)
        if d:IsA("ProximityPrompt") then
                AI.Set[d] = true
                if Ex.PromptReach ~= 1 or Ex.PromptClip then task.defer(pcall, ApplyReach, d) end
                if Ex.InfiniteItems then task.delay(0.3, function() pcall(MakeFake, d) end) end
        end
end)
task.spawn(function()
        for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") then AI.Set[d] = true end
        end
end)
Workspace.DescendantAdded:Connect(function(d)
        if d.Name == "ElevatorBreaker" then HookBreaker(d) end
end)

print("[AMBUSH HUB] Loaded Extra Functions")
print("[AMBUSH HUB] Loading more UI")
AutomationTab:Section({ Title = "Automation" })
AddToggle(AutomationTab, "AutoBreakerBox", "Auto Breaker Box",
        "Automatically solves the elevator breaker puzzle. Interact with it once, the rest is done for you.",
        Ex.AutoBreakerBox, function(v) Apply("AutoBreakerBox", v) end)
-- Auto Interact moved to InfiniteItemsTab (Russian)
-- ════════════════════════════════════════════════════════════════
-- INFINITE ITEMS TAB (separate tab, ported from Automation)
-- ════════════════════════════════════════════════════════════════
InfiniteItemsTab:Section({ Title = "Infinite Items" })
InfiniteItemsTab:Paragraph({
        Title = "How it works",
        Desc = "Lets selected items (lockpicks, skeleton key, shears, multitool) open locks, vines and chests without draining their uses. Requires fireproximityprompt. Hides the real lock prompt and replaces it with a fake one that does not reduce durability."
})
AddToggle(InfiniteItemsTab, "InfiniteItems", "Infinite Items",
        "Enable infinite uses for selected items (lockpicks, key, shears, multitool).",
        Ex.InfiniteItems, function(v) Apply("InfiniteItems", v) end)
do
        local dd = InfiniteItemsTab:Dropdown({
                Title = "Item List",
                Desc = "Items that will not be drained while the feature is on.",
                Values = { "Lockpicks", "Skeleton Key", "Shears", "Multitool" },
                Value = Ex.InfiniteItemsList,
                Multi = true,
                AllowNone = true,
                Callback = function(selected)
                        local out = {}
                        for _, n in ipairs(selected or {}) do out[#out + 1] = n end
                        Ex.InfiniteItemsList = out
                end
        })
        Setters.InfiniteItemsList = function(list) pcall(function() dd:Select(list) end) end
end
InfiniteItemsTab:Section({ Title = "Extra" })
InfiniteItemsTab:Paragraph({
        Title = "Tip",
        Desc = "This feature only works if your executor supports fireproximityprompt. If lock prompts stop showing up — turn the feature off and press P (Restore Prompts)."
})

-- Auto Interact (ported from rush.txt, moved here per dj's request)
-- Define Ex.AIIgnore BEFORE the UI uses it, otherwise the dropdown crashes
-- on nil and the rest of the tabs (Fun/Antis/Archives/Stairwell/Alerts/Misc/
-- Keybinds) never get built.
Ex.AIIgnore = {
        ["Jeff Items"] = true, ["Meld Chords"] = true, ["Share Gold Plate"] = true, ["Portraits"] = true,
        ["Terminals"] = true, ["Stems"] = true, ["Ladders"] = true, ["Locks (Key/Shears/Lockpick)"] = true,
        ["Chairs"] = true, ["Shopping Cart"] = true, ["Archives Box"] = true, ["Dropped Items"] = true,
        ["Cobbler Items"] = true, ["Stairwell Items/Salvage"] = true, ["Glitch Fragments"] = true,
        ["Forget Me Not"] = true, ["Sally's Toy"] = true,
}

InfiniteItemsTab:Section({ Title = "Auto Interact" })
AddToggle(InfiniteItemsTab, "AutoInteract", "Auto Interact",
        "Automatically triggers nearby prompts (items, gold, levers...). Skips closets, locks, dropped items, glitch fragments and fake doors.",
        Ex.AutoInteract, function(v) Ex.AutoInteract = v end)

-- Auto Interact ignore list (moved from AutomationTab)
InfiniteItemsTab:Section({ Title = "Ignore List" })
do
        local names = {}
        for k in pairs(Ex.AIIgnore) do names[#names + 1] = k end
        table.sort(names)
        local all = {}
        for _, k in ipairs(names) do all[#all + 1] = k end
        local dd = InfiniteItemsTab:Dropdown({
                Title = "Ignore list",
                Desc = "Object types Auto Interact will NOT touch (all selected by default). Matched by name / text. Specific items go in the separate list below.",
                Values = names,
                Value = all,
                Multi = true,
                AllowNone = true,
                Callback = function(selected)
                        local set = {}
                        for _, n in ipairs(selected or {}) do set[n] = true end
                        Ex.AIIgnore = set
                end,
        })
        local function SetAll(on)
                local set, list = {}, {}
                if on then
                        for _, n in ipairs(names) do set[n] = true list[#list + 1] = n end
                end
                Ex.AIIgnore = set
                pcall(function() dd:Select(list) end)
        end
        InfiniteItemsTab:Button({ Title = "Ignore all", Desc = "Selects every entry of the ignore list.", Callback = function() SetAll(true) end })
        InfiniteItemsTab:Button({ Title = "Ignore nothing", Desc = "Clears the list: Auto Interact will touch everything.", Callback = function() SetAll(false) end })
end

-- Ignored Items (Auto Interact skips these)
-- Define JUNK/ToSet here so the dropdown below has a valid default value
-- (otherwise WindUI crashes on nil and the rest of the UI never loads).
local JUNK = { "Paper Plane", "Fih Flakes", "Fih Food", "Paper Cup", "Mug", "Honcho Mug", "Lunch Box", "Leftovers", "Broken Monitor", "Broken Lamp", "Bottle Crate", "Coin Roll", "Large Screw", "Briefcase", "Nanner Peel", "Tip Jar", "Honey Pot" }
local function ToSet(list) local s = {} for _, n in ipairs(list) do s[n] = true end return s end
Ex.AIItemIgnore = ToSet(JUNK)

InfiniteItemsTab:Section({ Title = "Ignored Items" })
do
        local dd = InfiniteItemsTab:Dropdown({
                Title = "Ignored items",
                Desc = "Auto Interact will not pick up these items. Default: Paper Plane, Fih Flakes and other useless items.",
                Values = ITEM_NAMES,
                Value = JUNK,
                Multi = true,
                AllowNone = true,
                Callback = function(selected) Ex.AIItemIgnore = ToSet(selected or {}) end,
        })
        local function SetItems(list)
                Ex.AIItemIgnore = ToSet(list)
                pcall(function() dd:Select(list) end)
        end
        InfiniteItemsTab:Button({ Title = "Ignore all items", Desc = "Auto Interact will not pick up any item.", Callback = function()
                local all = {}
                for _, n in ipairs(ITEM_NAMES) do all[#all + 1] = n end
                SetItems(all)
        end })
        InfiniteItemsTab:Button({ Title = "Don't ignore items", Desc = "Auto Interact will pick up every item.", Callback = function() SetItems({}) end })
        InfiniteItemsTab:Button({ Title = "Restore default list", Desc = "Restores the list of useless items.", Callback = function() SetItems(JUNK) end })
end
AutomationTab:Section({ Title = "Prompts" })
AddSlider(AutomationTab, "PromptReach", "Prompt reach multiplier", "Multiplies the distance from which you can interact with prompts (1 = normal).", 1, 3, Ex.PromptReach, function(v) Apply("PromptReach", v) end)
AddToggle(AutomationTab, "PromptClip", "Prompts through walls", "Allows interacting with prompts through walls.", Ex.PromptClip, function(v) Apply("PromptClip", v) end)
AddToggle(AutomationTab, "DoorReach", "Door Reach", "Opens doors from farther away (up to 75 studs).", Ex.DoorReach, function(v) Apply("DoorReach", v) end)

AlertsTab:Section({ Title = "Environment" })
AddToggle(AlertsTab, "NotifyOxygen", "Notify oxygen level", "Shows how much oxygen is left every time it drops.", Ex.NotifyOxygen, function(v) Apply("NotifyOxygen", v) end)
AddToggle(AlertsTab, "NotifyHaste", "Notify Haste time", "Shows the time until 'Haste' spawns.", Ex.NotifyHaste, function(v) Apply("NotifyHaste", v) end)

PlayerTab:Section({ Title = "Movement" })
AddToggle(PlayerTab, "NoClosetDelay", "Remove Closet Delay", "Removes the short window where you can't exit a closet after the animation finishes.", Ex.NoClosetDelay, function(v) Apply("NoClosetDelay", v) end)
AddToggle(PlayerTab, "NoAcceleration", "Remove Acceleration", "The character stops immediately instead of sliding while moving.", Ex.NoAcceleration, function(v) Apply("NoAcceleration", v) end)

MiscTab:Section({ Title = "Sounds" })
AddToggle(MiscTab, "NoFootsteps", "Remove Footstep Sounds", "Mutes walking sound.", Ex.NoFootsteps, function(v) Apply("NoFootsteps", v) end)
AddToggle(MiscTab, "NoPromptSounds", "Remove Interacting Sounds", "Mutes prompt interaction sounds. Turning it off restores them.", Ex.NoPromptSounds, function(v) Apply("NoPromptSounds", v) end)

MiscTab:Section({ Title = "Misc" })
AddToggle(MiscTab, "DisableIdleKick", "Disable Idle Kick", "Prevents the 20-minute idle kick.", Ex.DisableIdleKick, function(v) Apply("DisableIdleKick", v) end)

StairwellTab:Section({ Title = "Meld" })
StairwellTab:Paragraph({
        Title = "How Meld removal works",
        Desc = "Both options work by name (anything called 'meld'). Stop Growth only disables Meld scripts / modules, leaving its ropes and doors intact. "
                .. "Remove Meld hides the remaining parts, but always keeps ropes, cables, chains and doors. Turn on Debug Mode to print what it finds in the console.",
})
AddToggle(StairwellTab, "MeldStopGrowth", "Stop Meld Growth", "Disables the scripts that make Meld grow. Ropes and doors are not removed.", Ex.MeldStopGrowth, function(v) Apply("MeldStopGrowth", v) end)
AddToggle(StairwellTab, "MeldRemove", "Remove Meld (no ropes / doors)", "Hides Meld and removes its collision / touch, except for ropes and doors.", Ex.MeldRemove, function(v) Apply("MeldRemove", v) end)
end)()

AntiCheatTab:Section({ Title = "Mobile Buttons" })
AddToggle(AntiCheatTab, "FloatButtons", "Floating buttons", "Small draggable buttons for ACM, SLIDE and FLY. Enabled by default on touch devices.", Ex.FloatButtons, function(v)
    Ex.FloatButtons = v
    FX.UpdateButtons()
end)
AddToggle(AntiCheatTab, "BtnACM", "ACM button", "Show the ACM floating button.", Ex.BtnACM, function(v) Ex.BtnACM = v; FX.UpdateButtons() end)
AddToggle(AntiCheatTab, "BtnFly", "FLY button", "Show the FLY floating button.", Ex.BtnFly, function(v) Ex.BtnFly = v; FX.UpdateButtons() end)
AddToggle(AntiCheatTab, "BtnSpeedHack", "SPD button", "Show the SPD (Speed Hack) floating button.", Ex.BtnSpeedHack, function(v) Ex.BtnSpeedHack = v; FX.UpdateButtons() end)

print("[AMBUSH HUB] Loading Batch 2")
;(function()
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local function Remotes() return RS:FindFirstChild("RemotesFolder") or RS:FindFirstChild("EntityInfo") or RS:FindFirstChild("Bricks") end
local function Rooms() return Workspace:FindFirstChild("CurrentRooms") end
local function Toast(t, d) pcall(FX.ShowToast, t, d or "", "", Color3.fromRGB(255, 200, 80)) end
local function CurRoom() return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0 end
local function FloorName()
        local gd = RS:FindFirstChild("GameData")
        local f = gd and gd:FindFirstChild("Floor")
        return f and f.Value or ""
end

Ex.NotifyLibraryCode = false
Ex.GuessLibraryCode = false
Ex.AutoSteerMinecart = false
-- Ex.AIIgnore is defined earlier (in InfiniteItemsTab section) so the
-- Ignore List dropdown has a valid table before WindUI renders it.

local AICache = setmetatable({}, { __mode = "k" })
local CHAIN_SKIP = { currentrooms = true, assets = true, interactables = true, misc = true, folder = true }
local function Chain(pp)
        local parts = { pp.Name, pp.ActionText, pp.ObjectText }
        local cur, d = pp.Parent, 0
        while cur and cur ~= Workspace and d < 6 do
                local n = cur.Name
                if not (CHAIN_SKIP[n:lower()] or tonumber(n)) then parts[#parts + 1] = n end
                cur = cur.Parent
                d = d + 1
        end
        return table.concat(parts, " "):lower(), parts
end
local function Words(str)
        local out = {}
        str = str:gsub("(%l)(%u)", "%1 %2"):gsub("[^%a]+", " "):lower()
        for w in str:gmatch("%a+") do out[w] = true end
        return out
end
local function Category(pp)
        local flat, parts = Chain(pp)
        local compact = flat:gsub("[^%a]", "")
        local raw = table.concat(parts, " ")
        local w = Words(raw)
        if compact:find("forgetmenot", 1, true) then return "Forget Me Not" end
        if compact:find("sally", 1, true) then return "Sally's Toy" end
        if w.jeff or w.shop or compact:find("jeffshop", 1, true) then return "Jeff Items" end
        if compact:find("meld", 1, true) and (compact:find("chord", 1, true) or w.chord or w.chords) then return "Meld Chords" end
        if compact:find("tithing", 1, true) or compact:find("sharegold", 1, true) or compact:find("goldplate", 1, true) then return "Share Gold Plate" end
        if w.portrait or w.portraits or w.painting then return "Portraits" end
        if w.terminal or w.terminals then return "Terminals" end
        if w.stem or w.stems then return "Stems" end
        if w.ladder or w.ladders then return "Ladders" end
        if compact:find("unlock", 1, true) or compact:find("skeletonkey", 1, true) or w.shears or w.lockpick or w.lockpicks then return "Locks (Key/Shears/Lockpick)" end
        if w.chair or w.chairs or w.sofa or w.couch or w.seat or w.armchair then return "Chairs" end
        if compact:find("shoppingcart", 1, true) then return "Shopping Cart" end
        if (compact:find("archive", 1, true) or compact:find("honcho", 1, true)) and (w.box or w.boxes) then return "Archives Box" end
        if w.cobbler or compact:find("cobbler", 1, true) then return "Cobbler Items" end
        if w.salvage or w.scrap or w.scrapper then return "Stairwell Items/Salvage" end
        if compact:find("glitchcube", 1, true) or compact:find("glitchfragment", 1, true) then return "Glitch Fragments" end
        return false
end
local AIItemCache = setmetatable({}, { __mode = "k" })
local function ItemOf(pp)
        local cands = { pp.ObjectText, pp.Parent and pp.Parent.Name, pp.Parent and pp.Parent.Parent and pp.Parent.Parent.Name }
        for _, c in ipairs(cands) do
                if type(c) == "string" and c ~= "" then
                        local canon = ITEM_LOOKUP[Norm(c)]
                        if canon then return canon end
                end
        end
        return false
end
local AICatT = setmetatable({}, { __mode = "k" })
local AIItemT = setmetatable({}, { __mode = "k" })
Ex.AILastCat = setmetatable({}, { __mode = "k" })
Ex.AIExtraSkip = function(pp)
        local now = os.clock()
        local c = AICache[pp]
        if c == nil or now - (AICatT[pp] or 0) > 2.5 then
                local ok, r = pcall(Category, pp)
                c = ok and r or false
                AICache[pp] = c
                AICatT[pp] = now
        end
        if c and Ex.AIIgnore[c] then Ex.AILastCat[pp] = c return true end
        local it = AIItemCache[pp]
        if it == nil or now - (AIItemT[pp] or 0) > 2.5 then
                local ok, r = pcall(ItemOf, pp)
                it = ok and r or false
                AIItemCache[pp] = it
                AIItemT[pp] = now
        end
        if it and Ex.AIItemIgnore and Ex.AIItemIgnore[it] then Ex.AILastCat[pp] = "item: " .. it return true end
        if Ex.AIIgnore["Dropped Items"] then
                local Drops = Workspace:FindFirstChild("Drops")
                if Drops and pp:IsDescendantOf(Drops) then Ex.AILastCat[pp] = "Dropped Items" return true end
        end
        return false
end
Ex.AIReset = function()
        AI.Static = setmetatable({}, { __mode = "k" })
        AICache = setmetatable({}, { __mode = "k" })
        AIItemCache = setmetatable({}, { __mode = "k" })
end

local function GetLibraryCode()
        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local paper = (char and (char:FindFirstChild("LibraryHintPaper") or char:FindFirstChild("LibraryHintPaperHard")))
                or (bp and (bp:FindFirstChild("LibraryHintPaper") or bp:FindFirstChild("LibraryHintPaperHard")))
        local fools = FloorName() == "Fools"
        local len = fools and 10 or 5
        if not (paper and paper:FindFirstChild("UI")) then return nil, string.rep("_", len), len end
        local perm = LocalPlayer.PlayerGui:FindFirstChild("PermUI")
        local hints = perm and perm:FindFirstChild("Hints")
        if not hints then return nil, string.rep("_", len), len end
        local code = {}
        for i = 1, len do code[i] = "_" end
        for _, hint in ipairs(hints:GetChildren()) do
                for _, ui in ipairs(paper.UI:GetChildren()) do
                        local idx = tonumber(ui.Name)
                        if hint:IsA("ImageLabel") and ui:IsA("ImageLabel") and idx and code[idx]
                                and hint.ImageRectOffset == ui.ImageRectOffset and hint:FindFirstChild("TextLabel") then
                                code[idx] = hint.TextLabel.Text
                        end
                end
        end
        local s = table.concat(code)
        return (not s:find("_", 1, true)) and s or nil, s, len
end

local codeGui, codeLabel
local function EnsureCodeLabel()
        if codeLabel and codeLabel.Parent then return codeLabel end
        local gui = Instance.new("ScreenGui")
        gui.Name = "RON_LibCode"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 50
        pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
        if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.AnchorPoint = Vector2.new(0.5, 1)
        l.Position = UDim2.new(0.5, 0, 1, -90)
        l.Size = UDim2.new(0.8, 0, 0, 34)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 24
        l.TextColor3 = Color3.new(1, 1, 1)
        l.TextStrokeTransparency = 0.3
        l.Visible = false
        l.Parent = gui
        codeGui, codeLabel = gui, l
        return l
end

local libNotified = false
task.spawn(function()
        local lastRoom = 0
        while true do
                task.wait(0.4)
                pcall(function()
                        local room = CurRoom()
                        if room < lastRoom - 5 then libNotified = false end
                        lastRoom = room
                        if not Ex.NotifyLibraryCode then
                                if codeLabel then codeLabel.Visible = false end
                                return
                        end
                        local full, shown = GetLibraryCode()
                        local l = EnsureCodeLabel()
                        l.Visible = room == 50
                        l.Text = "Library Code: " .. shown:gsub(".", "%0 ")
                        if full and not libNotified and room == 50 then
                                libNotified = true
                                Toast("Padlock code found!", "The code is: " .. full)
                        end
                end)
        end
end)

local Used, Tries = {}, 0
task.spawn(function()
        while true do
                task.wait(0.05)
                if Ex.GuessLibraryCode and CurRoom() == 50 then
                        pcall(function()
                                local rem = Remotes()
                                local pl = rem and rem:FindFirstChild("PL")
                                if not (pl and Workspace:FindFirstChild("Padlock", true)) then return end
                                local _, tpl = GetLibraryCode()
                                local code, n = nil, 0
                                repeat
                                        code = tpl:gsub("_", function() return tostring(math.random(0, 9)) end)
                                        n = n + 1
                                until not Used[code] or n >= 10
                                Used[code] = true
                                pl:FireServer(code)
                        end)
                elseif next(Used) and CurRoom() < 45 then
                        Used = {}
                end
        end
end)

local function DoRevive()
        local rem = Remotes()
        local r = rem and rem:FindFirstChild("Revive")
        if not r then Toast("Revive", "Remote not found.") return end
        pcall(function() r:FireServer() end)
        Toast("Revive", "Revive sent.")
end

local function CompleteCringle()
        local rooms = Rooms()
        local part = rooms and rooms:FindFirstChild("RippleExitDoor", true)
        local char = LocalPlayer.Character
        if part and char then
                if FX.B8 and FX.B8.SafeTP then FX.B8.SafeTP(part:GetPivot()) else char:PivotTo(part:GetPivot()) end
                Toast("Cringle", "Teleported to the exit.")
        else
                Toast("Cringle", "RippleExitDoor not found.")
        end
end

local damBusy = false
local function CompleteDam()
        if damBusy then return end
        local rooms = Rooms()
        local char = LocalPlayer.Character
        if not (rooms and char) then return end
        local pumps = {}
        for _, o in ipairs(rooms:GetDescendants()) do
                if o.Name == "WaterPump" and o:IsA("Model") then pumps[#pumps + 1] = o end
        end
        if #pumps == 0 then Toast("Dam Seek", "No water pumps found. Be in room 100.") return end
        damBusy = true
        task.spawn(function()
                local origin = char:GetPivot()
                local cutscene = false
                local rem = Remotes()
                local conn
                if rem and rem:FindFirstChild("Cutscene") then
                        conn = rem.Cutscene.OnClientEvent:Connect(function()
                                cutscene = true
                                task.wait(7)
                                cutscene = false
                        end)
                end
                Toast("Dam Seek", "Completing the valves, please wait.")
                local done = {}
                table.sort(pumps, function(a, b) return a:GetPivot().Y > b:GetPivot().Y end)
                for _, pump in ipairs(pumps) do
                        local t0 = os.clock()
                        local wheel = pump:FindFirstChild("Wheel")
                        local wsnd = wheel and wheel:FindFirstChild("Sound")
                        local pconn = wsnd and wsnd.Played:Connect(function() done[pump] = true end)
                        while pump.Parent and not done[pump] and os.clock() - t0 < 6 do
                                task.wait(0.1)
                                if not cutscene then
                                        pcall(function() char:PivotTo(pump:GetPivot()) end)
                                        local prompt = pump:FindFirstChild("ValvePrompt", true)
                                        if prompt and prompt.Enabled and fireproximityprompt then
                                                pcall(fireproximityprompt, prompt)
                                        elseif not prompt or not prompt.Enabled then
                                                done[pump] = true
                                        end
                                end
                        end
                        if pconn then pconn:Disconnect() end
                        done[pump] = true
                end
                if conn then conn:Disconnect() end
                pcall(function() char:PivotTo(origin) end)
                damBusy = false
                Toast("Dam Seek", "Valves completed.")
        end)
end

local Cart = { Nodes = {}, Ducks = {}, Seen = setmetatable({}, { __mode = "k" }), Ducked = false, Nearest = nil }
local TURN_DIST, DUCK_DIST = 30, 30

local function IsBehind(p1, p2)
        local a = (p1.CFrame + p1.CFrame.LookVector).Position
        local b = (p1.CFrame + p1.CFrame.LookVector * -1).Position
        return (a - p2.Position).Magnitude > (b - p2.Position).Magnitude
end
local function GetDirection(p1, p2)
        local r = p1.CFrame.RightVector:Dot(p1.Position - p2.Position)
        if r > 0.5 then return IsBehind(p1, p2) and "Right" or "Left" end
        if r < -0.5 then return IsBehind(p1, p2) and "Left" or "Right" end
        return "Straight"
end
local function NodeId(n) return tonumber(n.Name:split("MinecartNode")[2]) end

local function SetupRunnerNodes(folder)
        if Cart.Seen[folder] then return end
        Cart.Seen[folder] = true
        task.spawn(function()
                local function closest(node)
                        local best, bd = nil, math.huge
                        local id = NodeId(node)
                        for _, o in ipairs(folder:GetChildren()) do
                                local oid = NodeId(o)
                                if o ~= node and oid and id and oid > id then
                                        local d = (node.Position - o.Position).Magnitude
                                        if d < bd and o:GetAttribute("DistanceBlacklist") ~= true then bd, best = d, o end
                                end
                        end
                        return best
                end
                for _, node in ipairs(folder:GetChildren()) do
                        local id = NodeId(node)
                        if node:GetAttribute("DeathType") then node:SetAttribute("DistanceBlacklist", true) end
                        for i = 1, 20 do
                                local nx = id and folder:FindFirstChild("MinecartNode" .. id + i)
                                if nx and nx:GetAttribute("DeathType") ~= nil then node:SetAttribute("DistanceBlacklist", true) end
                        end
                        local pv = id and folder:FindFirstChild("MinecartNode" .. id - 1)
                        if pv and pv:GetAttribute("ForceConnect") then node:SetAttribute("DistanceBlacklist", nil) end
                        task.wait()
                end
                for _, node in ipairs(folder:GetChildren()) do
                        if node:GetAttribute("ForceConnect") then
                                local nx = closest(node)
                                if nx then
                                        node:SetAttribute("Turn", GetDirection(node, nx))
                                        Cart.Nodes[#Cart.Nodes + 1] = node
                                end
                        end
                        task.wait()
                end
        end)
end

local function ScanCart(o)
        if o.Name == "RunnerNodes" then SetupRunnerNodes(o)
        elseif o.Name == "DuckBoard" then Cart.Ducks[#Cart.Ducks + 1] = o end
end
local function HookRooms()
        local rooms = Rooms()
        if not rooms then return end
        for _, o in ipairs(rooms:GetDescendants()) do ScanCart(o) end
        rooms.DescendantAdded:Connect(ScanCart)
end
task.spawn(function()
        local rooms = Workspace:WaitForChild("CurrentRooms", 30)
        if rooms then HookRooms() end
end)

local function InCart() return workspace.CurrentCamera and workspace.CurrentCamera:FindFirstChild("MinecartRig") ~= nil end
local mainGame
local function MainGame()
        if mainGame then return mainGame end
        pcall(function()
                mainGame = require(LocalPlayer.PlayerGui:WaitForChild("MainUI").Initiator.Main_Game)
        end)
        return mainGame
end

pcall(function()
        if not require then return end
        local controls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
        local orig = controls.GetMoveVector
        controls.GetMoveVector = function(...)
                if Ex.AutoSteerMinecart and Cart.Nearest and InCart() then
                        local turn = Cart.Nearest:GetAttribute("Turn")
                        return turn == "Left" and Vector3.new(-1, 0, 0) or turn == "Right" and Vector3.new(1, 0, 0) or Vector3.zero
                end
                return orig(...)
        end
end)

local lastCart = 0
RunService.Heartbeat:Connect(function()
        if not Ex.AutoSteerMinecart or not InCart() or os.clock() - lastCart < 0.1 then return end
        lastCart = os.clock()
        local near, nd = nil, math.huge
        for _, n in ipairs(Cart.Nodes) do
                if n.Parent then
                        local d = LocalPlayer:DistanceFromCharacter(n.Position)
                        if d < TURN_DIST and d < nd then near, nd = n, d end
                end
        end
        Cart.Nearest = near
        local duck = false
        for _, b in ipairs(Cart.Ducks) do
                if b.Parent and b.PrimaryPart and LocalPlayer:DistanceFromCharacter(b.PrimaryPart.Position) < DUCK_DIST then duck = true break end
        end
        local mg = MainGame()
        if mg and mg.crouch then
                if duck and not Cart.Ducked then pcall(mg.crouch, true) Cart.Ducked = true
                elseif not duck and Cart.Ducked then pcall(mg.crouch, false) Cart.Ducked = false end
        end
end)

AutomationTab:Section({ Title = "Floors" })
AddToggle(AutomationTab, "AutoSteerMinecart", "Auto Steer Minecart", "Completes the Seek minecart chase (Mines 2): steers every turn and ducks under boards.", Ex.AutoSteerMinecart, function(v) Ex.AutoSteerMinecart = v end)
AutomationTab:Button({ Title = "Auto Complete Dam Seek", Desc = "Teleports to each water pump (highest first) and interacts with it, then returns you. Must be in room 100.", Callback = CompleteDam })
AutomationTab:Button({ Title = "Auto Complete Cringle", Desc = "Teleports you to the end of the quest.", Callback = CompleteCringle })

AutomationTab:Section({ Title = "Library" })
AddToggle(AutomationTab, "GuessLibraryCode", "Guess Library Code", "Tries random codes on the room-50 padlock, keeping the digits you already know. Still needs a few books collected.", Ex.GuessLibraryCode, function(v) Ex.GuessLibraryCode = v end)

-- Auto Interact Ignore List moved to InfiniteItemsTab (Russian)

AlertsTab:Section({ Title = "Library" })
AddToggle(AlertsTab, "NotifyLibraryCode", "Notify Library Code", "Shows 5 digits at the bottom of the screen (_ for unknown; needs the paper and matching books). Hides when door 51 opens, notifies on completion.", Ex.NotifyLibraryCode, function(v) Ex.NotifyLibraryCode = v if v then libNotified = false end end)

MiscTab:Section({ Title = "Revive" })
MiscTab:Button({ Title = "Revive", Desc = "Sends a revive request. Works even after a timeout (needs a revive available).", Callback = DoRevive })
end)()

print("[AMBUSH HUB] Loading Batch 3")
;(function()
local PathfindingService = game:GetService("PathfindingService")
local function Toast(t, d) pcall(FX.ShowToast, t, d or "", "", Color3.fromRGB(255, 200, 80)) end

Ex.ShowSeekPath = false
Ex.ShowEyestalkPath = false
Ex.PathMode = "Lines"
Ex.NotifyItems = false
Ex.NotifyUnlistedItems = false
Ex.NotifyItemFilter = {}
local ESSENTIAL_ITEMS = { "Crucifix", "Gold Gun", "Lockpicks", "Skeleton Key", "Holy Hand Grenade", "Shears", "Multitool", "Big Bomb", "Knockbomb", "Laser Pointer" }
for _, n in ipairs(ESSENTIAL_ITEMS) do Ex.NotifyItemFilter[n] = true end

do
        local lastBtn
        local function DoJump()
                if not Ex.InfJump then return end
                local _, hum = GetParts()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
        task.spawn(function()
                while true do
                        task.wait(1)
                        pcall(function()
                                local ui = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
                                local mf = ui and ui:FindFirstChild("MainFrame")
                                local mb = mf and mf:FindFirstChild("MobileButtons")
                                local jb = mb and mb:FindFirstChild("JumpButton")
                                if jb and jb ~= lastBtn then
                                        lastBtn = jb
                                        jb.MouseButton1Click:Connect(DoJump)
                                        jb.Activated:Connect(DoJump)
                                end
                        end)
                end
        end)
end

local PathRoot = Instance.new("Folder")
PathRoot.Name = "RON_Paths"
PathRoot.Parent = Workspace
local Paths = {}

local function PathColor(kind) return kind == "seek" and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 255, 255) end
local function Enabled(kind) return kind == "seek" and Ex.ShowSeekPath or Ex.ShowEyestalkPath end

local function Erase(p)
        if p.folder then pcall(function() p.folder:Destroy() end) p.folder = nil end
end
local function Segment(parent, a, b, color)
        local dist = (b - a).Magnitude
        if dist < 0.05 then return end
        local seg = Instance.new("Part")
        seg.Name = "Seg"
        seg.Anchored = true
        seg.CanCollide = false
        seg.CanQuery = false
        seg.CanTouch = false
        seg.CastShadow = false
        seg.Material = Enum.Material.Neon
        seg.Color = color
        seg.Transparency = 0.2
        seg.Size = Vector3.new(0.3, 0.3, dist)
        seg.CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, -dist / 2)
        seg.Parent = parent
        local ad = Instance.new("BoxHandleAdornment")
        ad.Adornee = seg
        ad.AlwaysOnTop = true
        ad.ZIndex = 5
        ad.Size = seg.Size
        ad.Color3 = color
        ad.Transparency = 0.35
        ad.Parent = seg
end
local function Render(p)
        Erase(p)
        if not Enabled(p.kind) or not p.points or #p.points == 0 then return end
        local f = Instance.new("Folder")
        f.Name = "P"
        f.Parent = PathRoot
        p.folder = f
        local color = PathColor(p.kind)
        if Ex.PathMode == "Nodes" then
                for _, pos in ipairs(p.points) do
                        local part = Instance.new("Part")
                        part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch, part.CastShadow = true, false, false, false, false
                        part.Shape = Enum.PartType.Ball
                        part.Size = Vector3.one * 1.5
                        part.Material = Enum.Material.Neon
                        part.Color = color
                        part.Transparency = 0.15
                        part.Position = pos
                        part.Parent = f
                        local ad = Instance.new("SphereHandleAdornment")
                        ad.Adornee = part
                        ad.AlwaysOnTop = true
                        ad.ZIndex = 5
                        ad.Radius = 0.75
                        ad.Color3 = color
                        ad.Transparency = 0.3
                        ad.Parent = part
                end
        else
                for i = 2, #p.points do Segment(f, p.points[i - 1], p.points[i], color) end
                if #p.points == 1 then Segment(f, p.points[1], p.points[1] + Vector3.new(0, 1, 0), color) end
        end
end
local function SetPath(key, kind, points)
        local p = Paths[key]
        if not p then p = { kind = kind } Paths[key] = p end
        p.points = points
        Render(p)
end
local function RedrawAll() for _, p in pairs(Paths) do pcall(Render, p) end end
local seekLights = {}
local seekToken = {}
Ex.ClearSeekPaths = function()
        for k, p in pairs(Paths) do
                if p.kind == "seek" then Erase(p) Paths[k] = nil end
        end
        seekLights = {}
end

local function RoomOf(inst)
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        local cur = inst
        while cur and cur.Parent ~= rooms do cur = cur.Parent end
        return cur
end
local function OnSeekLight(d)
        if d.Name ~= "SeekGuidingLight" then return end
        local room = RoomOf(d)
        if not room then return end
        local pos
        if d:IsA("BasePart") then pos = d.Position
        elseif d:IsA("Model") then pos = d:GetPivot().Position end
        if not pos then return end
        local rec = seekLights[room]
        if not rec then rec = { list = {}, seen = setmetatable({}, { __mode = "k" }) } seekLights[room] = rec end
        if rec.seen[d] then return end
        rec.seen[d] = true
        rec.list[#rec.list + 1] = pos
        seekToken[room] = (seekToken[room] or 0) + 1
        local tok = seekToken[room]
        task.delay(0.3, function()
                if seekToken[room] == tok and room.Parent then
                        SetPath("seek:" .. room.Name, "seek", table.clone(rec.list))
                end
        end)
end

local eyeBusy = setmetatable({}, { __mode = "k" })
local function SetupEyestalk(room)
        if eyeBusy[room] then return end
        local raw = room:GetAttribute("RawName")
        if not (type(raw) == "string" and raw:find("Eyestalk", 1, true)) then return end
        eyeBusy[room] = true
        task.spawn(function()
                local exitPart = room:WaitForChild("RoomExit", 60)
                room:WaitForChild("RoomEntrance", 60)
                local fails = 0
                while room.Parent and not room:GetAttribute("PathFoundR4N") do
                        if Ex.ShowEyestalkPath and exitPart and exitPart.Parent then
                                local char = LocalPlayer.Character
                                local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Collision") or char.PrimaryPart)
                                if root then
                                        local path = PathfindingService:CreatePath({
                                                AgentCanJump = false, AgentCanClimb = false, WaypointSpacing = 2, AgentRadius = 1, AgentHeight = 1,
                                        })
                                        local ok = pcall(function() path:ComputeAsync(root.Position, exitPart.Position) end)
                                        local pts = {}
                                        if ok and path.Status == Enum.PathStatus.Success then
                                                for _, w in ipairs(path:GetWaypoints()) do pts[#pts + 1] = w.Position end
                                        else
                                                fails = fails + 1
                                                if fails >= 6 then pts = { root.Position, exitPart.Position } end
                                        end
                                        if #pts > 0 then
                                                room:SetAttribute("PathFoundR4N", true)
                                                SetPath("eye:" .. room.Name, "eye", pts)
                                                break
                                        end
                                end
                        end
                        task.wait(0.4)
                end
        end)
end

task.spawn(function()
        local rooms = Workspace:WaitForChild("CurrentRooms", 60)
        if not rooms then return end
        for _, d in ipairs(rooms:GetDescendants()) do OnSeekLight(d) end
        for _, r in ipairs(rooms:GetChildren()) do SetupEyestalk(r) end
        rooms.DescendantAdded:Connect(OnSeekLight)
        rooms.ChildAdded:Connect(function(r)
                task.wait(0.3)
                SetupEyestalk(r)
        end)
        rooms.ChildRemoved:Connect(function(r)
                seekLights[r] = nil
                for _, pre in ipairs({ "seek:", "eye:" }) do
                        local p = Paths[pre .. r.Name]
                        if p then Erase(p) Paths[pre .. r.Name] = nil end
                end
        end)
end)

task.spawn(function()
        local le = Workspace:WaitForChild("LiveEntities", 120)
        if not le then return end
        local function try(d)
                if d:IsA("Model") and d.Name:lower():find("stem", 1, true) then
                        task.defer(function()
                                if Active.entities then pcall(RegisterEntityWhenReady, d, "Stem", true) end
                        end)
                end
        end
        for _, d in ipairs(le:GetChildren()) do try(d) end
        le.ChildAdded:Connect(try)
end)

local itemReady = os.clock() + 5
local itemSeen = setmetatable({}, { __mode = "k" })
Watch.OnItem = function(label, inst, known, key)
        if not Ex.NotifyItems or os.clock() < itemReady or itemSeen[inst] then return end
        itemSeen[inst] = true
        if known then
                if not Ex.NotifyItemFilter[key or label] then return end
        elseif not Ex.NotifyUnlistedItems then
                return
        end
        local desc = ""
        pcall(function()
                local part = Tracked[inst] and Tracked[inst].Part
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if part and root then desc = math.floor((part.Position - root.Position).Magnitude + 0.5) .. " studs away" end
        end)
        Toast(label .. " spawned", desc)
end

VisualsTab:Section({ Title = "Chase Paths" })
AddToggle(VisualsTab, "ShowSeekPath", "Show Seek Path", "Draws the correct path during the Seek chase.", Ex.ShowSeekPath, function(v) Ex.ShowSeekPath = v RedrawAll() end)
AddToggle(VisualsTab, "ShowEyestalkPath", "Show Eyestalk Path", "Draws a safe path to the exit in Eyestalk rooms (calculated from your position).", Ex.ShowEyestalkPath, function(v) Ex.ShowEyestalkPath = v RedrawAll() end)
AddDropdown(VisualsTab, "PathMode", "Path Style", "Lines draws a continuous line; Nodes draws a ball per waypoint.", { "Lines", "Nodes" }, Ex.PathMode, function(v)
        if type(v) == "table" then v = v[1] end
        Ex.PathMode = v or "Lines"
        RedrawAll()
end)

AlertsTab:Section({ Title = "Items" })
AddToggle(AlertsTab, "NotifyItems", "Notify Items", "Shows a notification when a selected item spawns on the floor.", Ex.NotifyItems, function(v) Ex.NotifyItems = v end)
AddToggle(AlertsTab, "NotifyUnlistedItems", "Notify unlisted items", "Also notifies about items not in the list below.", Ex.NotifyUnlistedItems, function(v) Ex.NotifyUnlistedItems = v end)
do
        local ddItems = AlertsTab:Dropdown({
                Title = "Items to notify about",
                Desc = "Every item is in the list, but only the important ones are selected by default (Crucifix, Gold Gun, Lockpicks, Skeleton Key...).",
                Values = ITEM_NAMES,
                Value = ESSENTIAL_ITEMS,
                Multi = true,
                AllowNone = true,
                Callback = function(selected)
                        local map = {}
                        for _, n in ipairs(selected or {}) do map[n] = true end
                        Ex.NotifyItemFilter = map
                end,
        })
        local function SetItems(list)
                local map = {}
                for _, n in ipairs(list) do map[n] = true end
                Ex.NotifyItemFilter = map
                pcall(function() ddItems:Select(list) end)
        end
        AlertsTab:Button({ Title = "Notify all items", Desc = "Selects every item in the list.", Callback = function()
                local all = {}
                for _, n in ipairs(ITEM_NAMES) do all[#all + 1] = n end
                SetItems(all)
        end })
        AlertsTab:Button({ Title = "Essentials only", Desc = "Restores the default selection.", Callback = function() SetItems(ESSENTIAL_ITEMS) end })
        AlertsTab:Button({ Title = "Notify nothing", Desc = "Clears the selection.", Callback = function() SetItems({}) end })
end
end)()

print("[AMBUSH HUB] Loading Batch 4")
;(function()
local hooked = setmetatable({}, { __mode = "k" })
local used = setmetatable({}, { __mode = "k" })

task.spawn(function()
        while true do
                task.wait(0.5)
                pcall(function()
                        for inst, e in pairs(Tracked) do
                                local n = inst.Name
                                if n == "TimerLever" then
                                        if not hooked[inst] then
                                                hooked[inst] = true
                                                local main = inst:FindFirstChild("Main")
                                                local snd = main and main:FindFirstChild("SoundToPlay")
                                                if snd then snd.Played:Once(function() used[inst] = true end) end
                                        end
                                        local label = "??:??"
                                        if used[inst] then
                                                label = "00:00"
                                        else
                                                local tt = inst:FindFirstChild("TakeTimer")
                                                local tl = tt and tt:FindFirstChild("TextLabel")
                                                local txt = tl and tl.Text
                                                if type(txt) == "string" and txt:match("^%d%d:%d%d$") then label = txt end
                                        end
                                        e.Label = "Time Lever [" .. label .. "]"
                                elseif n == "WaterPump" then
                                        if not hooked[inst] then
                                                hooked[inst] = true
                                                local wheel = inst:FindFirstChild("Wheel")
                                                local snd = wheel and wheel:FindFirstChild("Sound")
                                                if snd then snd.Played:Once(function() used[inst] = true end) end
                                        end
                                        e.Label = used[inst] and "Water Pump [Done]" or "Water Pump"
                                end
                        end
                end)
        end
end)

Workspace.DescendantAdded:Connect(function(d)
        if d.Name == "SeekMovingNewClone" then
                d.Destroying:Once(function()
                        if Ex.ClearSeekPaths then pcall(Ex.ClearSeekPaths) end
                end)
        end
end)
end)()

print("[AMBUSH HUB] Loading Batch 6")
;(function()
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

Ex.InfCrucifix = false
Ex.RemoveCutscenes = false
Ex.DisableEntityJumpscares = false
Ex.DisableFiredamp = false

local function MainGame()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local mu = pg and pg:FindFirstChild("MainUI")
        local ini = mu and mu:FindFirstChild("Initiator")
        return ini and ini:FindFirstChild("Main_Game")
end
local function Listener()
        local mg = MainGame()
        return mg and mg:FindFirstChild("RemoteListener")
end

local DROP_DIST = { RushMoving = 54, AmbushMoving = 67, A60 = 70, GlitchRush = 120, GlitchAmbush = 155, A120 = 75 }
local crucBusy = false
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
-- Ported from RushHub: RenderStepped + iterate ALL workspace children
-- (handles duplicate entities, e.g. two RushMoving clones) and force
-- PrimaryPart.CanCollide/CanQuery = true so the ray can actually hit
-- the entity hitbox instead of passing through it.
RunService.RenderStepped:Connect(function()
        if not Ex.InfCrucifix or crucBusy then return end
        local char = LocalPlayer.Character
        if not char then return end
        local body = char:FindFirstChild("Collision") or char:FindFirstChild("CollisionPart") or char:FindFirstChild("HumanoidRootPart")
        if not body then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or tool.Name ~= "Crucifix" then return end
        rayParams.FilterDescendantsInstances = { char }
        for _, ent in ipairs(Workspace:GetChildren()) do
                local maxDist = DROP_DIST[ent.Name]
                if not maxDist or not ent.PrimaryPart then continue end
                -- force the entity's primary part to be raycastable
                -- (RushHub does this every frame; without it the ray
                -- passes through CanQuery=false parts and the crucifix
                -- never triggers)
                ent.PrimaryPart.CanCollide = true
                ent.PrimaryPart.CanQuery = true
                local dir = ent.PrimaryPart.Position - body.Position
                local dist = dir.Magnitude
                if dist >= maxDist then continue end
                local hit = Workspace:Raycast(body.Position, dir, rayParams)
                if not hit or not hit.Instance:IsDescendantOf(ent) then continue end
                crucBusy = true
                task.spawn(function()
                        pcall(function()
                                local remotes = RS:FindFirstChild("RemotesFolder")
                                local drop = remotes and remotes:FindFirstChild("DropItem")
                                if drop then drop:FireServer(tool) end
                                task.wait(0.54)
                                local drops = Workspace:FindFirstChild("Drops")
                                local dropped = drops and drops:FindFirstChild("Crucifix")
                                local prompt = dropped and dropped:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                        end)
                        task.wait(0.6)
                        crucBusy = false
                end)
                return
        end
end)

local CUTSCENES = {
        Figure = true, FigureEnd = true, FigureHotelEnd = true, FigureHotelFire = true,
        SeekIntroFools = true, SeekIntroHotel = true, SeekIntroMines = true, SeekIntroMines2 = true,
        SerewSeekDrain = true, SewerSeekLower = true, GrumbleNestEnd = true, EyestalkIntro = true,
}
local function Toggle(obj, base, on)
        if not obj or not obj.Parent then return end
        if obj:GetAttribute("R4N_Orig") == nil then obj:SetAttribute("R4N_Orig", base) end
        local want = on and (base .. "_Disabled") or base
        if obj.Name ~= want then obj.Name = want end
end
local function BaseName(obj)
        local o = obj:GetAttribute("R4N_Orig")
        if o then return o end
        return (obj.Name:gsub("_Disabled$", ""))
end
local function ApplyCutscenes()
        local on = Ex.RemoveCutscenes
        local rl = Listener()
        local c1, c2 = rl and rl:FindFirstChild("Cutscenes"), RS:FindFirstChild("FloorReplicated")
        for i = 1, 2 do
                local folder = i == 1 and c1 or c2
                if folder then for _, o in ipairs(folder:GetChildren()) do
                        if o:IsA("ModuleScript") then
                                local base = BaseName(o)
                                if CUTSCENES[base] then Toggle(o, base, on) end
                        end
                end end
        end
end
local function IsJumpscareModule(o)
        if not o:IsA("ModuleScript") then return false end
        local b = BaseName(o)
        return b:find("Jumpscare", 1, true) and not b:find("Eyestalk", 1, true) and not b:find("Groundskeeper", 1, true) and not b:find("Monument", 1, true)
end
local function ApplyJumpscares()
        local on = Ex.DisableEntityJumpscares
        local rl = Listener()
        local js = rl and (rl:FindFirstChild("Jumpscares") or rl:FindFirstChild("Jumpscares_Disabled"))
        if js then Toggle(js, "Jumpscares", on) end
        local fr = RS:FindFirstChild("FloorReplicated")
        if fr then
                for _, o in ipairs(fr:GetDescendants()) do
                        if IsJumpscareModule(o) then Toggle(o, BaseName(o), on) end
                end
        end
end

local function ApplyFiredamp()
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        if not rooms then return end
        local on = Ex.DisableFiredamp
        for _, r in ipairs(rooms:GetChildren()) do
                if on then
                        if r:GetAttribute("Firedamp_Old_R4N") == nil then
                                local v = r:GetAttribute("Firedamp")
                                r:SetAttribute("Firedamp_Old_R4N", v ~= nil and v or false)
                        end
                        if r:GetAttribute("Firedamp") ~= false then r:SetAttribute("Firedamp", false) end
                else
                        local old = r:GetAttribute("Firedamp_Old_R4N")
                        if old ~= nil then
                                r:SetAttribute("Firedamp", old)
                                r:SetAttribute("Firedamp_Old_R4N", nil)
                        end
                end
        end
        if on then
                local cam = Workspace.CurrentCamera
                if cam then
                        for _, o in ipairs(cam:GetChildren()) do
                                if o.Name == "LiveFiredamp" then pcall(function() o:Destroy() end) end
                        end
                end
        end
end

local function Safe(f) return function() pcall(f) end end
local function Kick(f, flag)
        task.spawn(function()
                for _ = 1, 20 do
                        pcall(f)
                        task.wait(0.5)
                end
        end)
end
Hooks.RemoveCutscenes = function() Kick(ApplyCutscenes) end
Hooks.DisableEntityJumpscares = function() Kick(ApplyJumpscares) end
Hooks.DisableFiredamp = function()
        pcall(ApplyFiredamp)
        if Ex.DisableFiredamp then
                pcall(function()
                        local old = LocalPlayer:GetAttribute("CurrentRoom")
                        if old then
                                LocalPlayer:SetAttribute("CurrentRoom", 0)
                                task.wait()
                                LocalPlayer:SetAttribute("CurrentRoom", old)
                        end
                end)
        end
end
task.spawn(function()
        while true do
                task.wait(1)
                if Ex.RemoveCutscenes then pcall(ApplyCutscenes) end
                if Ex.DisableEntityJumpscares then pcall(ApplyJumpscares) end
                if Ex.DisableFiredamp then pcall(ApplyFiredamp) end
        end
end)

AntisTab:Section({ Title = "Extra" })
AddToggle(AntisTab, "InfCrucifix", "Infinite Crucifix", "Risky! Drops and picks the Crucifix back up when an entity is near so it does not break. You can die or lose it; low ping recommended.", Ex.InfCrucifix, function(v) Ex.InfCrucifix = v end)
AddToggle(AntisTab, "RemoveCutscenes", "Remove Cutscenes", "Skips Figure, Seek and Eyestalk cutscenes.", Ex.RemoveCutscenes, function(v) Apply("RemoveCutscenes", v) end)
AddToggle(AntisTab, "DisableEntityJumpscares", "Disable Entity Jumpscares", "Disables jumpscares from entities like Rush and Ambush.", Ex.DisableEntityJumpscares, function(v) Apply("DisableEntityJumpscares", v) end)
VisualsTab:Section({ Title = "Effects" })
AddToggle(VisualsTab, "DisableFiredamp", "Disable Firedamp Effect", "Removes the firedamp screen effect.", Ex.DisableFiredamp, function(v) Apply("DisableFiredamp", v) end)
end)()

print("[AMBUSH HUB] Loading Batch 5")
;(function()
local RS = game:GetService("ReplicatedStorage")
local function Toast(t, d) pcall(FX.ShowToast, t, d or "", "", Color3.fromRGB(255, 200, 80)) end

Ex.BypassSeek = false
Ex.BypassFigure = false
Ex.NotifyRansom = false
Ex.AutoPositionSpoof = false

local RUSHLIKE = { "RushMoving", "AmbushMoving", "A60", "A120", "GlitchRush", "GlitchAmbush", "BackdoorRush", "FrozenAmbush" }
local function RushPresent()
        for _, name in ipairs(RUSHLIKE) do
                local m = Workspace:FindFirstChild(name)
                if m and m:GetAttribute("Inactive") ~= true then return true end
        end
        return false
end

local ransomSeen = setmetatable({}, { __mode = "k" })
local function CheckRansom(c)
        if not Ex.NotifyRansom or ransomSeen[c] then return end
        local n = c.Name:lower()
        if n:find("ransom", 1, true) or n == "a90" or n == "a-90" then
                ransomSeen[c] = true
                Toast("Ransom has spawned", "It appeared in the Workspace. Get ready before it reaches you.")
        end
end
Workspace.ChildAdded:Connect(CheckRansom)

local savedState = {}
local function Combo(tag, ids, on)
        for _, id in ipairs(ids) do
                local key = tag .. id
                if on then
                        if savedState[key] == nil then savedState[key] = Ex[id] and true or false end
                        if not Ex[id] then SetFeature(id, true) end
                else
                        if savedState[key] == false then SetFeature(id, false) end
                        savedState[key] = nil
                end
        end
end

local function SeekJumpscareModules(on)
        local roots = {}
        local fr = RS:FindFirstChild("FloorReplicated")
        if fr then roots[#roots + 1] = fr end
        pcall(function()
                local rl = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener
                roots[#roots + 1] = rl
        end)
        for _, r in ipairs(roots) do
                for _, d in ipairs(r:GetDescendants()) do
                        if d:IsA("ModuleScript") then
                                local l = d.Name:lower()
                                if on then
                                        if l:find("seek", 1, true) and l:find("jumpscare", 1, true) and not l:find("_disabled", 1, true) then
                                                d:SetAttribute("R4NOrig", d.Name)
                                                d.Name = d.Name .. "_Disabled"
                                        end
                                elseif d:GetAttribute("R4NOrig") then
                                        d.Name = d:GetAttribute("R4NOrig")
                                        d:SetAttribute("R4NOrig", nil)
                                end
                        end
                end
        end
end
do
        local fr = RS:FindFirstChild("FloorReplicated")
        if fr then
                fr.DescendantAdded:Connect(function(d)
                        if Ex.BypassSeek and d:IsA("ModuleScript") then
                                task.defer(SeekJumpscareModules, true)
                        end
                end)
        end
end

local SEEK_IDS = { "BypassSeekObstructions", "RemoveSeekTrigger" }
local FIGURE_IDS = { "CrouchSpoof", "AutoHeartbeatMinigame", "FigureGodmode" }

local chase = false
Workspace.DescendantAdded:Connect(function(d)
        if d.Name == "SeekMovingNewClone" or d.Name == "SeekMoving" then
                chase = true
                d.Destroying:Once(function() task.delay(1, function() chase = false end) end)
        end
end)

FX.SpoofVotes = FX.SpoofVotes or {}
function FX.SpoofVote(tag, want)
        FX.SpoofVotes[tag] = want and true or nil
end
local autoSpoof = false
local lastWanted = 0
task.spawn(function()
        while true do
                task.wait(0.25)
                pcall(function()
                        local votes = FX.SpoofVotes
                        votes.rush = (Ex.AutoPositionSpoof and RushPresent()) or nil
                        votes.seek = (Ex.BypassSeek and chase) or nil
                        local fig = nil
                        if Ex.BypassFigure and FX.Functions and FX.Functions.GetNearestFigure then
                                local ok, f = pcall(FX.Functions.GetNearestFigure)
                                if ok and f then fig = true end
                        end
                        votes.figure = fig
                        if next(votes) ~= nil then
                                lastWanted = os.clock()
                                if not Ex.PositionSpoof then
                                        autoSpoof = true
                                        SetFeature("PositionSpoof", true)
                                end
                        elseif autoSpoof and os.clock() - lastWanted > 1.5 then
                                autoSpoof = false
                                if Ex.PositionSpoof then SetFeature("PositionSpoof", false) end
                        end
                end)
        end
end)

AntisTab:Section({ Title = "Bypass Combos" })
AddToggle(AntisTab, "BypassSeek", "Bypass Seek",
        "Experimental. Disables the Seek jumpscare, bypasses its obstacles, deletes the trigger where supported (Old Hotel / Fools) and moves you underground automatically while the chase is running.",
        Ex.BypassSeek, function(v)
                Ex.BypassSeek = v
                Combo("seek:", SEEK_IDS, v)
                SeekJumpscareModules(v)
        end)
AddToggle(AntisTab, "BypassFigure", "Bypass Figure",
        "Experimental. Crouch Spoof + Auto Heartbeat Minigame + Figure Godmode, and moves you underground automatically while a Figure is near.",
        Ex.BypassFigure, function(v)
                Ex.BypassFigure = v
                Combo("fig:", FIGURE_IDS, v)
        end)

AddToggle(AntiCheatTab, "AutoPositionSpoof", "Auto Position Spoof",
        "Turns Position Spoof on only while a Rush-like entity (Rush, Ambush, A-60, A-120, Glitch...) exists, and returns you to normal as soon as it despawns. Leave the manual Position Spoof off to use it.",
        Ex.AutoPositionSpoof, function(v) Ex.AutoPositionSpoof = v end)

AlertsTab:Section({ Title = "Entities" })
AddToggle(AlertsTab, "NotifyRansom", "Notify Ransom", "Notifies you as soon as Ransom enters the Workspace, before the jumpscare reaches you.", Ex.NotifyRansom, function(v) Ex.NotifyRansom = v end)
end)()

print("[AMBUSH HUB] Loading Batch 6")
;(function()
local Players = game:GetService("Players")
local RunSvc = game:GetService("RunService")
local function Toast(t, d) pcall(FX.ShowToast, t, d or "", "", Color3.fromRGB(255, 200, 80)) end

Ex.PerfMode = false
Ex.AutoPerf = false
Ex.NotifyDespawn = false
Cfg.RefreshRate = Cfg.RefreshRate or 4

local MAXHL    = { 26, 16, 10, 6 }
local INTERVAL = { 0, 0.15, 0.3, 0.6 }
local CAP      = { math.huge, 100, 60, 35 }
local perfLevel = 0
local function ApplyPerf()
        local eff = perfLevel
        if Ex.PerfMode then eff = math.max(eff, 2) end
        Watch.MaxHL = math.min(MAXHL[eff + 1], Watch.GuardHL or 99)
        Watch.PerfInterval = math.max(INTERVAL[eff + 1], Watch.GuardInterval or 0)
        Watch.PerfCap = math.min(CAP[eff + 1], Watch.GuardCap or math.huge)
end
ApplyPerf()
do
        local frames, last = 0, os.clock()
        RunSvc.RenderStepped:Connect(function() frames = frames + 1 end)
        task.spawn(function()
                while true do
                        task.wait(1)
                        local now = os.clock()
                        local fps = frames / math.max(now - last, 0.001)
                        frames, last = 0, now
                        if Ex.AutoPerf then
                                if fps < 22 and perfLevel < 3 then perfLevel = perfLevel + 1
                                elseif fps > 40 and perfLevel > 0 then perfLevel = perfLevel - 1 end
                        elseif perfLevel ~= 0 then
                                perfLevel = 0
                        end
                        ApplyPerf()
                end
        end)
end

local live = setmetatable({}, { __mode = "k" })
local function Track(m)
        if not m:IsA("Model") or Players:GetPlayerFromCharacter(m) then return end
        local ok, label = pcall(EntityLabel, m.Name, false)
        if ok and label and label ~= "Mandrake" then live[m] = label end
end
for _, c in ipairs(Workspace:GetChildren()) do Track(c) end
Workspace.ChildAdded:Connect(Track)
local lastDespawn = {}
Workspace.ChildRemoved:Connect(function(m)
        local label = live[m]
        if not label then return end
        live[m] = nil
        if not Ex.NotifyDespawn then return end
        if not (Ex.NotifyFilter and Ex.NotifyFilter[label]) then return end
        local now = os.clock()
        if lastDespawn[label] and now - lastDespawn[label] < 3 then return end
        lastDespawn[label] = now
        Toast(label .. " has despawned", "You are safe from it now.")
end)

VisualsTab:Section({ Title = "ESP Performance" })
AddToggle(VisualsTab, "PerfMode", "ESP Performance Mode", "Draws fewer highlights (closest wins), fewer objects and updates less often. Turn on when you lag.", Ex.PerfMode, function(v) Ex.PerfMode = v ApplyPerf() end)
AddToggle(VisualsTab, "AutoPerf", "Auto Performance", "Lightens the ESP on its own when FPS drops, and restores when it rises.", Ex.AutoPerf, function(v) Ex.AutoPerf = v end)
AddSlider(VisualsTab, "RefreshRate", "ESP Refresh Rate", "How many times per second the ESP updates (lower = less lag).", 2, 10, Cfg.RefreshRate, function(v) Cfg.RefreshRate = v end)

VisualsTab:Section({ Title = "Entity Distance Limit" })
do
        local names = {}
        for k in pairs(ENTITY_MODES) do names[#names + 1] = k end
        table.sort(names)
        local sel = {}
        for k in pairs(Watch.Limited) do sel[#sel + 1] = k end
        table.sort(sel)
        VisualsTab:Dropdown({
                Title = "Distance-limited entities",
                Desc = "These entities obey the Max Distance limit and are hidden when far. Remove an entity from the list to restore normal behavior (always visible).",
                Values = names,
                Value = sel,
                Multi = true,
                AllowNone = true,
                Callback = function(selected)
                        local set = {}
                        for _, n in ipairs(selected or {}) do set[n] = true end
                        Watch.Limited = set
                end,
        })
end

AlertsTab:Section({ Title = "Entity Despawn" })
AddToggle(AlertsTab, "NotifyDespawn", "Notify despawn", "Tells you when an entity you were notified about has despawned. Uses the same selection as spawn alerts.", Ex.NotifyDespawn, function(v) Ex.NotifyDespawn = v end)

-- JUNK and ToSet are defined earlier (in InfiniteItemsTab section) so the
-- dropdown has a valid default before WindUI tries to render it.

-- Ignored Items moved to InfiniteItemsTab (Russian)

end)()

print("[AMBUSH HUB] Loading Batch 7")
;(function()
local UIS = game:GetService("UserInputService")
local RunSvc = game:GetService("RunService")
local HttpSvc = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local function Toast(t, d) pcall(FX.ShowToast, t, d or "", "", Color3.fromRGB(255, 200, 80)) end

Ex.TimerShow = false
Ex.TimerPosition = "Top Right"
Ex.TimerScale = 100
Ex.TimerOpacity = 80
Ex.TimerSplits = true
Ex.TimerButtons = true
Ex.TimerAutoStart = false
Ex.TimerAutoSplit = false
Ex.TimerStopRoom = 0
Ex.Key_TimerToggle = "K"
Ex.Key_TimerStop = "O"
Ex.Key_TimerReset = "L"

local FILE = "RON_Speedrun.json"
local PB = {}
pcall(function()
        if isfile and isfile(FILE) then PB = HttpSvc:JSONDecode(readfile(FILE)) end
end)
local function SavePB() pcall(function() if writefile then writefile(FILE, HttpSvc:JSONEncode(PB)) end end) end

local T = { state = "ready", acc = 0, t0 = 0, list = {}, highest = 0, delta = nil, newPB = false }
local function Elapsed() return T.state == "running" and (T.acc + os.clock() - T.t0) or T.acc end
local function CurRoom() return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0 end
local function FloorName()
        local gd = RS:FindFirstChild("GameData")
        local f = gd and gd:FindFirstChild("Floor")
        local v = f and tostring(f.Value) or ""
        return v ~= "" and v or "Lobby"
end

local function Fmt(t)
        if t < 0 then t = 0 end
        local ms = math.floor((t % 1) * 1000)
        local total = math.floor(t)
        local s, m, h = total % 60, math.floor(total / 60) % 60, math.floor(total / 3600)
        local main = h > 0 and string.format("%d:%02d:%02d", h, m, s) or string.format("%02d:%02d", m, s)
        return main, string.format(".%03d", ms)
end
local function FmtFull(t) local a, b = Fmt(t) return a .. b end
local function FmtDelta(d)
        local sign = d < 0 and "-" or "+"
        d = math.abs(d)
        if d >= 60 then return sign .. string.format("%d:%04.1f", math.floor(d / 60), d % 60) end
        return sign .. string.format("%.2f", d)
end

local C = {
        ready = Color3.fromRGB(170, 170, 180), run = Color3.fromRGB(80, 255, 120), behind = Color3.fromRGB(255, 90, 90),
        pause = Color3.fromRGB(255, 210, 80), done = Color3.fromRGB(110, 175, 255), gold = Color3.fromRGB(255, 215, 0),
        dim = Color3.fromRGB(150, 150, 160), text = Color3.fromRGB(230, 230, 235),
}

local gui = Instance.new("ScreenGui")
gui.Name = "RON_Timer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 60
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local W = 230
local function S(n) return math.max(1, math.floor(n * (Ex.TimerScale or 100) / 100 + 0.5)) end

local function Label(parent, name)
        local l = Instance.new("TextLabel")
        l.Name = name
        l.BackgroundTransparency = 1
        l.TextColor3 = C.text
        l.Font = Enum.Font.GothamBold
        l.TextStrokeTransparency = 0.6
        l.Parent = parent
        return l
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
panel.BorderSizePixel = 0
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.Parent = gui
local corner = Instance.new("UICorner", panel)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(70, 70, 82)
stroke.Thickness = 1
local pad = Instance.new("UIPadding", panel)
local list = Instance.new("UIListLayout", panel)
list.SortOrder = Enum.SortOrder.LayoutOrder

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.LayoutOrder = 1
header.Parent = panel
local title = Label(header, "Title")
title.Text = "RON  SPEEDRUN"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = C.dim
title.Size = UDim2.fromScale(0.6, 1)
local info = Label(header, "Info")
info.Font = Enum.Font.Gotham
info.TextXAlignment = Enum.TextXAlignment.Right
info.TextColor3 = C.dim
info.Position = UDim2.fromScale(0.5, 0)
info.Size = UDim2.fromScale(0.5, 1)

local splitsFrame = Instance.new("Frame")
splitsFrame.Name = "Splits"
splitsFrame.BackgroundTransparency = 1
splitsFrame.AutomaticSize = Enum.AutomaticSize.Y
splitsFrame.LayoutOrder = 2
splitsFrame.Parent = panel
local sl = Instance.new("UIListLayout", splitsFrame)
sl.SortOrder = Enum.SortOrder.LayoutOrder
local rows = {}
for i = 1, 5 do
        local f = Instance.new("Frame")
        f.BackgroundTransparency = 1
        f.LayoutOrder = i
        f.Visible = false
        f.Parent = splitsFrame
        local n = Label(f, "N") n.TextXAlignment = Enum.TextXAlignment.Left n.Size = UDim2.fromScale(0.34, 1) n.TextColor3 = C.dim
        local d = Label(f, "D") d.Font = Enum.Font.RobotoMono d.TextXAlignment = Enum.TextXAlignment.Right d.Position = UDim2.fromScale(0.34, 0) d.Size = UDim2.fromScale(0.28, 1)
        local t = Label(f, "T") t.Font = Enum.Font.RobotoMono t.TextXAlignment = Enum.TextXAlignment.Right t.Position = UDim2.fromScale(0.62, 0) t.Size = UDim2.fromScale(0.38, 1)
        rows[i] = { f = f, n = n, d = d, t = t }
end

local timerFrame = Instance.new("Frame")
timerFrame.Name = "TimerFrame"
timerFrame.BackgroundTransparency = 1
timerFrame.LayoutOrder = 3
timerFrame.Parent = panel
local big = Label(timerFrame, "Big")
big.Font = Enum.Font.RobotoMono
big.RichText = true
big.TextXAlignment = Enum.TextXAlignment.Right
big.Size = UDim2.fromScale(1, 1)

local sub = Instance.new("Frame")
sub.Name = "Sub"
sub.BackgroundTransparency = 1
sub.LayoutOrder = 4
sub.Parent = panel
local pbLabel = Label(sub, "PB") pbLabel.Font = Enum.Font.RobotoMono pbLabel.TextXAlignment = Enum.TextXAlignment.Left pbLabel.TextColor3 = C.dim pbLabel.Size = UDim2.fromScale(0.6, 1)
local deltaLabel = Label(sub, "Delta") deltaLabel.Font = Enum.Font.RobotoMono deltaLabel.TextXAlignment = Enum.TextXAlignment.Right deltaLabel.Position = UDim2.fromScale(0.5, 0) deltaLabel.Size = UDim2.fromScale(0.5, 1)

local btnFrame = Instance.new("Frame")
btnFrame.Name = "Buttons"
btnFrame.BackgroundTransparency = 1
btnFrame.LayoutOrder = 5
btnFrame.Parent = panel
local bl = Instance.new("UIListLayout", btnFrame)
bl.FillDirection = Enum.FillDirection.Horizontal
bl.SortOrder = Enum.SortOrder.LayoutOrder
local function Button(text, order)
        local b = Instance.new("TextButton")
        b.LayoutOrder = order
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = true
        b.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
        b.TextColor3 = C.text
        b.BorderSizePixel = 0
        b.Parent = btnFrame
        Instance.new("UICorner", b)
        return b
end
local btnMain = Button("Start", 1)
local btnStop = Button("Stop", 2)
local btnReset = Button("Reset", 3)

local PRESETS = {
        ["Top Left"]      = { Vector2.new(0, 0),   UDim2.new(0, 12, 0, 64) },
        ["Top Center"]    = { Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 64) },
        ["Top Right"]     = { Vector2.new(1, 0),   UDim2.new(1, -12, 0, 64) },
        ["Middle Left"]   = { Vector2.new(0, 0.5), UDim2.new(0, 12, 0.5, 0) },
        ["Middle Right"]  = { Vector2.new(1, 0.5), UDim2.new(1, -12, 0.5, 0) },
        ["Bottom Left"]   = { Vector2.new(0, 1),   UDim2.new(0, 12, 1, -16) },
        ["Bottom Center"] = { Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -16) },
        ["Bottom Right"]  = { Vector2.new(1, 1),   UDim2.new(1, -12, 1, -16) },
}
local PRESET_NAMES = { "Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right" }
local function Place(name)
        local p = PRESETS[name]
        if not p then return end
        panel.AnchorPoint, panel.Position = p[1], p[2]
end

local RenderAll
local function Layout()
        local inner = S(W) - S(12)
        panel.Size = UDim2.fromOffset(S(W), 0)
        corner.CornerRadius = UDim.new(0, S(6))
        pad.PaddingTop, pad.PaddingBottom = UDim.new(0, S(5)), UDim.new(0, S(6))
        pad.PaddingLeft, pad.PaddingRight = UDim.new(0, S(6)), UDim.new(0, S(6))
        list.Padding = UDim.new(0, S(2))
        panel.BackgroundTransparency = 1 - (Ex.TimerOpacity or 80) / 100
        stroke.Transparency = math.clamp(panel.BackgroundTransparency + 0.2, 0, 1)

        header.Size = UDim2.fromOffset(inner, S(16))
        title.TextSize, info.TextSize = S(10), S(10)
        splitsFrame.Size = UDim2.fromOffset(inner, 0)
        splitsFrame.Visible = Ex.TimerSplits
        for _, r in ipairs(rows) do
                r.f.Size = UDim2.fromOffset(inner, S(16))
                r.n.TextSize, r.d.TextSize, r.t.TextSize = S(11), S(11), S(11)
        end
        timerFrame.Size = UDim2.fromOffset(inner, S(46))
        big.TextSize = S(38)
        sub.Size = UDim2.fromOffset(inner, S(16))
        pbLabel.TextSize, deltaLabel.TextSize = S(11), S(11)
        btnFrame.Visible = Ex.TimerButtons
        btnFrame.Size = UDim2.fromOffset(inner, S(26))
        bl.Padding = UDim.new(0, S(4))
        for _, b in ipairs({ btnMain, btnStop, btnReset }) do
                b.Size = UDim2.new(1 / 3, -S(3), 1, 0)
                b.TextSize = S(11)
        end
        gui.Enabled = Ex.TimerShow
        if RenderAll then RenderAll() end
end

local lastBig = ""
local function Colour()
        if T.state == "ready" then return C.ready end
        if T.state == "paused" then return C.pause end
        if T.state == "finished" then return T.newPB and C.gold or C.done end
        if T.delta and T.delta > 0 then return C.behind end
        return C.run
end
local function DrawBig()
        local main, ms = Fmt(Elapsed())
        local txt = string.format('%s<font size="%d">%s</font>', main, S(22), ms)
        if txt ~= lastBig then lastBig = txt big.Text = txt end
        big.TextColor3 = Colour()
end
local function DrawInfo()
        local fl = FloorName()
        info.Text = fl .. "  -  Room " .. CurRoom()
        local pb = PB[fl]
        pbLabel.Text = pb and ("PB " .. FmtFull(pb.pb)) or "PB --:--.---"
        if T.delta then
                deltaLabel.Text = FmtDelta(T.delta)
                deltaLabel.TextColor3 = T.delta > 0 and C.behind or C.run
        else
                deltaLabel.Text = ""
        end
        local labels = { ready = "Start", running = "Pause", paused = "Resume", finished = "Restart" }
        btnMain.Text = labels[T.state]
end
local function DrawSplits()
        local n = #T.list
        local first = math.max(1, n - 4)
        for i = 1, 5 do
                local rec, r = T.list[first + i - 1], rows[i]
                if rec then
                        r.f.Visible = true
                        r.n.Text = "Room " .. rec.room
                        r.t.Text = FmtFull(rec.t)
                        if rec.delta then
                                r.d.Text = FmtDelta(rec.delta)
                                r.d.TextColor3 = rec.delta > 0 and C.behind or C.run
                        else
                                r.d.Text = "-"
                                r.d.TextColor3 = C.dim
                        end
                else
                        r.f.Visible = false
                end
        end
end
RenderAll = function() DrawBig() DrawInfo() DrawSplits() end

local function Reset()
        T.state, T.acc, T.t0, T.list, T.highest, T.delta, T.newPB = "ready", 0, 0, {}, 0, nil, false
        RenderAll()
end
local function Start()
        if T.state ~= "ready" then return end
        T.acc, T.t0, T.list, T.highest, T.delta, T.newPB = 0, os.clock(), {}, CurRoom(), nil, false
        T.state = "running"
        RenderAll()
end
local function Pause()
        if T.state ~= "running" then return end
        T.acc = Elapsed()
        T.state = "paused"
        RenderAll()
end
local function Resume()
        if T.state ~= "paused" then return end
        T.t0 = os.clock()
        T.state = "running"
        RenderAll()
end
local function Finish()
        if T.state ~= "running" and T.state ~= "paused" then return end
        T.acc = Elapsed()
        T.state = "finished"
        local fl = FloorName()
        if fl ~= "Lobby" and #T.list >= 10 and (not PB[fl] or T.acc < PB[fl].pb) then
                local splits = {}
                for _, rec in ipairs(T.list) do splits[tostring(rec.room)] = rec.t end
                PB[fl] = { pb = T.acc, splits = splits }
                SavePB()
                T.newPB = true
                Toast("New personal best!", FmtFull(T.acc) .. "  -  " .. fl)
        else
                Toast("Run finished", FmtFull(T.acc))
        end
        RenderAll()
end
local function Toggle()
        if T.state == "ready" then Start()
        elseif T.state == "running" then Pause()
        elseif T.state == "paused" then Resume()
        else Reset() Start() end
end
Ex.TimerToggle, Ex.TimerFinish, Ex.TimerReset = Toggle, Finish, Reset

btnMain.Activated:Connect(Toggle)
btnStop.Activated:Connect(Finish)
btnReset.Activated:Connect(Reset)

LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
        local room = CurRoom()
        if T.state == "running" and Ex.TimerAutoSplit and room > T.highest then
                T.highest = room
                local t = Elapsed()
                local pb = PB[FloorName()]
                local ref = pb and pb.splits and pb.splits[tostring(room)]
                local delta = ref and (t - ref) or nil
                T.list[#T.list + 1] = { room = room, t = t, delta = delta }
                T.delta = delta or T.delta
                if Ex.TimerStopRoom and Ex.TimerStopRoom > 0 and room >= Ex.TimerStopRoom then
                        Finish()
                        return
                end
        end
        RenderAll()
end)

local START_KEYS = {
        W = true, A = true, S = true, D = true, Up = true, Down = true, Left = true, Right = true,
        Space = true, LeftControl = true, C = true, ButtonA = true, ButtonB = true,
}
local function AutoStart() if Ex.TimerAutoStart and T.state == "ready" then Start() end end

UIS.InputBegan:Connect(function(input)
        if UIS:GetFocusedTextBox() then return end
        local name = input.KeyCode.Name
        if name == Ex.Key_TimerToggle then Toggle() return end
        if name == Ex.Key_TimerStop then Finish() return end
        if name == Ex.Key_TimerReset then Reset() return end
        if START_KEYS[name] then AutoStart() end
end)
UIS.InputChanged:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Thumbstick1 and input.Position.Magnitude > 0.25 then AutoStart() end
end)

do
        local hooked = setmetatable({}, { __mode = "k" })
        task.spawn(function()
                while true do
                        task.wait(1)
                        pcall(function()
                                local ui = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
                                local mf = ui and ui:FindFirstChild("MainFrame")
                                local mb = mf and mf:FindFirstChild("MobileButtons")
                                if not mb then return end
                                for _, b in ipairs(mb:GetChildren()) do
                                        local n = b.Name:lower()
                                        if b:IsA("GuiButton") and not hooked[b] and (n:find("jump", 1, true) or n:find("crouch", 1, true) or n:find("duck", 1, true)) then
                                                hooked[b] = true
                                                b.MouseButton1Down:Connect(AutoStart)
                                        end
                                end
                        end)
                end
        end)
end

task.spawn(function()
        while true do
                task.wait(0.1)
                if T.state == "ready" and Ex.TimerAutoStart then
                        pcall(function()
                                local _, hum = GetParts()
                                if (hum and hum.MoveDirection.Magnitude > 0.1) or Ex.ACM then Start() end
                        end)
                end
        end
end)

do
        local acc = 0
        RunSvc.RenderStepped:Connect(function(dt)
                if T.state ~= "running" or not Ex.TimerShow then return end
                acc = acc + dt
                if acc >= 1 / 30 then
                        acc = 0
                        DrawBig()
                end
        end)
end
task.spawn(function()
        while true do
                task.wait(1)
                if Ex.TimerShow then pcall(DrawInfo) end
        end
end)

do
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = Vector2.new(i.Position.X, i.Position.Y)
                        local ap = panel.AbsolutePosition
                        panel.AnchorPoint = Vector2.zero
                        panel.Position = UDim2.fromOffset(ap.X, ap.Y)
                        startPos = Vector2.new(ap.X, ap.Y)
                        i.Changed:Connect(function()
                                if i.UserInputState == Enum.UserInputState.End then dragging = false end
                        end)
                end
        end)
        UIS.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        local d = Vector2.new(i.Position.X, i.Position.Y) - dragStart
                        local vp = gui.AbsoluteSize
                        local sz = panel.AbsoluteSize
                        panel.Position = UDim2.fromOffset(
                                math.clamp(startPos.X + d.X, 0, math.max(vp.X - sz.X, 0)),
                                math.clamp(startPos.Y + d.Y, 0, math.max(vp.Y - sz.Y, 0))
                        )
                end
        end)
end

Place(Ex.TimerPosition)
Layout()

Ex.TimerAutoEnd = false
Ex.TimerStopOnDeath = true
do
        local FINAL_ROOM = { Hotel = 100, Mines = 200 }
        local END_WORDS = { "ending", "finale", "final", "credits", "outro", "escape", "tobecontinued", "theend", "gameend" }
        local END_UI = { "tobecontinued", "endscreen", "victory" }
        local UIState = setmetatable({}, { __mode = "k" })
        local function Cmp(s) return (tostring(s or ""):lower():gsub("[^%a]", "")) end

        local function AutoFinish(reason)
                if not Ex.TimerAutoEnd then return end
                if T.state ~= "running" and T.state ~= "paused" then return end
                if Elapsed() < 20 then return end
                print("[AMBUSH HUB] Speedrun timer stopped: " .. reason)
                Finish()
        end

        task.spawn(function()
                local rf = RS:WaitForChild("RemotesFolder", 30) or RS:FindFirstChild("EntityInfo") or RS:FindFirstChild("Bricks")
                local cs = rf and rf:WaitForChild("Cutscene", 20)
                if not cs then return end
                cs.OnClientEvent:Connect(function(name)
                        print("[AMBUSH HUB] Cutscene: " .. tostring(name))
                        local fin = FINAL_ROOM[FloorName()]
                        if fin and CurRoom() >= fin then AutoFinish("final cutscene (" .. tostring(name) .. ")") return end
                        local c = Cmp(name)
                        for _, w in ipairs(END_WORDS) do
                                if c:find(w, 1, true) then AutoFinish("end cutscene (" .. tostring(name) .. ")") return end
                        end
                end)
        end)

        pcall(function()
                LocalPlayer.OnTeleport:Connect(function(state)
                        if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
                                AutoFinish("leaving the run")
                        end
                end)
        end)

        task.spawn(function()
                local gd = RS:WaitForChild("GameData", 30)
                if not gd then return end
                for _, nm in ipairs({ "FinalCutscene", "RunHasBeenEnded", "WinnerDecided" }) do
                        local v = gd:FindFirstChild(nm)
                        if v and v:IsA("ValueBase") then
                                v.Changed:Connect(function(val) if val == true then AutoFinish("game ended (" .. nm .. ")") end end)
                        end
                        if gd:GetAttribute(nm) ~= nil then
                                gd:GetAttributeChangedSignal(nm):Connect(function()
                                        if gd:GetAttribute(nm) == true then AutoFinish("game ended (" .. nm .. ")") end
                                end)
                        end
                end
        end)

        task.spawn(function()
                local deadSince
                while true do
                        task.wait(0.5)
                        if T.state == "running" or T.state == "paused" then
                                if Ex.TimerStopOnDeath and LocalPlayer:GetAttribute("Alive") == false then
                                        deadSince = deadSince or os.clock()
                                        if os.clock() - deadSince > 3 then deadSince = nil AutoFinish("death") end
                                else
                                        deadSince = nil
                                end
                                if Ex.TimerAutoEnd then
                                        pcall(function()
                                                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                                                if not pg then return end
                                                local ui = pg:FindFirstChild("MainUI")
                                                for _, root in ipairs({ pg, ui, ui and ui:FindFirstChild("MainFrame") }) do
                                                        if root then
                                                                for _, c in ipairs(root:GetChildren()) do
                                                                        local nm = Cmp(c.Name)
                                                                        for _, w in ipairs(END_UI) do
                                                                                if nm:find(w, 1, true) then
                                                                                        local vis = (c:IsA("ScreenGui") and c.Enabled) or (c:IsA("GuiObject") and c.Visible and c.AbsoluteSize.X > 0)
                                                                                        local was = UIState[c]
                                                                                        UIState[c] = vis and true or false
                                                                                        if vis and was == false then AutoFinish("end screen (" .. c.Name .. ")") return end
                                                                                end
                                                                        end
                                                                end
                                                        end
                                                end
                                        end)
                                end
                        else
                                deadSince = nil
                        end
                end
        end)
end


-- ════════════════════════════════════════════════════════════════
-- GRANULAR ANTI-LAG (ported from rush.txt)
-- ════════════════════════════════════════════════════════════════
MiscTab:Section({ Title = "Granular Anti-Lag" })
Ex.AntiLagParticles = false
Ex.AntiLagTrails    = false
Ex.AntiLagLights    = false
Ex.AntiLagTextures  = false
Ex.AntiLagMaterials = false
Ex.AntiLagEffects   = false
Ex.AntiLagShadows   = false

local function ApplyGranularLag()
    local Lighting = game:GetService("Lighting")
    local function applyObj(o)
        if o:IsA("ParticleEmitter") then
            if Ex.AntiLagParticles then o.Enabled = false end
        elseif o:IsA("Trail") or o:IsA("Beam") then
            if Ex.AntiLagTrails then o.Enabled = false end
        elseif o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then
            if Ex.AntiLagLights then o.Enabled = false end
        elseif o:IsA("Decal") or o:IsA("Texture") then
            if Ex.AntiLagTextures then o.Transparency = 1 end
        elseif o:IsA("BasePart") then
            if Ex.AntiLagMaterials then
                o.Material = Enum.Material.SmoothPlastic
                o.Reflectance = 0
            end
        elseif o:IsA("PostEffect") then
            if Ex.AntiLagEffects then o.Enabled = false end
        end
    end
    task.spawn(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            pcall(applyObj, d)
            if _ % 500 == 0 then task.wait() end
        end
    end)
    if Ex.AntiLagShadows then
        Lighting.GlobalShadows = false
    end
end

AddToggle(MiscTab, "AntiLagParticles", "Disable Particles", "Disables all particle emitters locally.", Ex.AntiLagParticles, function(v) Ex.AntiLagParticles = v ApplyGranularLag() end)
AddToggle(MiscTab, "AntiLagTrails",    "Disable Trails / Beams", "Disables Trails and Beams locally.",    Ex.AntiLagTrails,    function(v) Ex.AntiLagTrails = v ApplyGranularLag() end)
AddToggle(MiscTab, "AntiLagLights",    "Disable Lights", "Disables PointLight, SpotLight and SurfaceLight locally.", Ex.AntiLagLights, function(v) Ex.AntiLagLights = v ApplyGranularLag() end)
AddToggle(MiscTab, "AntiLagTextures",  "Hide Textures", "Hides Decals and Textures locally.",        Ex.AntiLagTextures,  function(v) Ex.AntiLagTextures = v ApplyGranularLag() end)
AddToggle(MiscTab, "AntiLagMaterials", "Reduce Materials", "Changes BaseParts to SmoothPlastic locally.", Ex.AntiLagMaterials, function(v) Ex.AntiLagMaterials = v ApplyGranularLag() end)
AddToggle(MiscTab, "AntiLagEffects",   "Disable Post Effects", "Disables post-processing locally.",      Ex.AntiLagEffects,   function(v) Ex.AntiLagEffects = v ApplyGranularLag() end)
AddToggle(MiscTab, "AntiLagShadows",   "Disable Shadows", "Disables global lighting shadows locally.", Ex.AntiLagShadows,   function(v) Ex.AntiLagShadows = v ApplyGranularLag() end)

-- Death Farm (ported from rush.txt)
MiscTab:Section({ Title = "Death Farm" })
MiscTab:Button({
    Title = "Start Death Farm",
    Desc = "Automatically farms deaths by joining new runs. Needs fireproximityprompt and firesignal.",
    DoubleClick = true,
    Callback = function()
        if not (fireproximityprompt and firesignal) then
            pcall(function() WindUI:Notify({ Title = "Death Farm", Content = "Requires fireproximityprompt and firesignal.", Duration = 3 }) end)
            return
        end
        pcall(function() WindUI:Notify({ Title = "Death Farm", Content = "Starting death farm...", Duration = 3 }) end)
        task.spawn(function()
            while true do
                pcall(function()
                    local RS = game:GetService("ReplicatedStorage")
                    local rf = RS:FindFirstChild("RemotesFolder") or RS:FindFirstChild("EntityInfo") or RS:FindFirstChild("Bricks")
                    local pl = LocalPlayer
                    if not (rf and pl) then return end
                    -- kill the character
                    local kill = pl:FindFirstChild("Kill")
                    if kill and replicatesignal then
                        pcall(replicatesignal, kill)
                    elseif rf:FindFirstChild("Underwater") then
                        pcall(function() rf.Underwater:FireServer(true) end)
                    end
                end)
                task.wait(2)
                -- wait for respawn
                local t0 = os.clock()
                while not LocalPlayer:GetAttribute("Alive") and os.clock() - t0 < 10 do
                    task.wait(0.3)
                end
                task.wait(0.5)
                pcall(function()
                    local RS = game:GetService("ReplicatedStorage")
                    local rf = RS:FindFirstChild("RemotesFolder") or RS:FindFirstChild("EntityInfo")
                    if rf and rf:FindFirstChild("PlayAgain") then
                        rf.PlayAgain:FireServer()
                    end
                end)
                task.wait(3)
            end
        end)
    end
})
MiscTab:Section({ Title = "Speedrun Timer" })
AddToggle(MiscTab, "TimerShow", "Show Speedrun Timer", "Shows the timer on screen. Drag the header to move it.", Ex.TimerShow, function(v) Ex.TimerShow = v Layout() end)
MiscTab:Button({ Title = "Start / Pause / Resume", Desc = "Starts, pauses or resumes the timer (Restart after a finished run).", Callback = Toggle })
MiscTab:Button({ Title = "Stop (finish run)", Desc = "Finishes the run. If at least 10 rooms were cleared and the time is better than your best, it is saved as your personal best for this floor.", Callback = Finish })
MiscTab:Button({ Title = "Reset", Desc = "Clears the timer and splits to start over.", Callback = Reset })
AddDropdown(MiscTab, "TimerPosition", "Timer Position", "Corner and edge presets. Dragging the header overrides it.", PRESET_NAMES, Ex.TimerPosition, function(v)
        if type(v) == "table" then v = v[1] end
        if v then Ex.TimerPosition = v Place(v) end
end)
AddSlider(MiscTab, "TimerScale", "Timer Scale (%)", "Scales the entire timer.", 50, 150, Ex.TimerScale, function(v) Ex.TimerScale = v Layout() end)
AddSlider(MiscTab, "TimerOpacity", "Timer Background (%)", "How solid the timer background is.", 0, 100, Ex.TimerOpacity, function(v) Ex.TimerOpacity = v Layout() end)
AddToggle(MiscTab, "TimerSplits", "Show Splits", "Shows the latest room splits with the difference from your best.", Ex.TimerSplits, function(v) Ex.TimerSplits = v Layout() end)
AddToggle(MiscTab, "TimerButtons", "Show Buttons", "Shows Start / Stop / Reset buttons on the timer (handy on mobile).", Ex.TimerButtons, function(v) Ex.TimerButtons = v Layout() end)
AddToggle(MiscTab, "TimerAutoStart", "Auto-start on movement", "Starts itself on the first movement: joystick, WASD / arrows, jump, crouch or Anticheat Manipulator. Camera movement does not count.", Ex.TimerAutoStart, function(v) Ex.TimerAutoStart = v end)
AddToggle(MiscTab, "TimerAutoSplit", "Auto-split rooms", "Records a split every time you enter a new room.", Ex.TimerAutoSplit, function(v) Ex.TimerAutoSplit = v end)
AddToggle(MiscTab, "TimerAutoEnd", "Auto-stop at game end", "Stops the timer automatically when the game ends: final cutscene (Hotel door 100, Mines door 200), end screen or returning to the lobby.", Ex.TimerAutoEnd, function(v) Ex.TimerAutoEnd = v end)
AddToggle(MiscTab, "TimerStopOnDeath", "Stop on death", "Also stops the timer if you stay dead for 3 seconds (reviving resumes the count).", Ex.TimerStopOnDeath, function(v) Ex.TimerStopOnDeath = v end)
AddSlider(MiscTab, "TimerStopRoom", "Auto-stop at room", "Finishes the run when this room is reached (0 = off).", 0, 300, Ex.TimerStopRoom, function(v) Ex.TimerStopRoom = v end)
end)()

print("[AMBUSH HUB] Loading Batch 8")
;(function()
local B = {}
FX.B8 = B
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local PPS = game:GetService("ProximityPromptService")

function B.Toast(t, d) pcall(FX.ShowToast, t, d or "", "", Color3.fromRGB(255, 200, 80)) end
function B.Rooms() return Workspace:FindFirstChild("CurrentRooms") end
function B.CurRoom() return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0 end
function B.FloorName()
        local gd = RS:FindFirstChild("GameData")
        local f = gd and gd:FindFirstChild("Floor")
        return f and f.Value or ""
end
do
        local cache, n = {}, 0
        function B.Compact(s)
                s = tostring(s or "")
                local v = cache[s]
                if v == nil then
                        if n > 6000 then cache, n = {}, 0 end
                        v = s:lower():gsub("[^%a]", "")
                        cache[s] = v
                        n = n + 1
                end
                return v
        end
end
function B.Has(s, token) return B.Compact(s):find(token, 1, true) ~= nil end
function B.InMode(name) return Mode.Name == name or (Mode.All and Mode.All()) or false end

function B.RoomOf(inst)
        local rooms = B.Rooms()
        local p = inst
        while p and p.Parent and p.Parent ~= rooms do p = p.Parent end
        if rooms and p and p.Parent == rooms then return tonumber(p.Name), p end
        return nil, nil
end

function B.PosOf(inst)
        if not inst then return nil end
        if inst:IsA("BasePart") then return inst.Position end
        if inst:IsA("Attachment") then return inst.WorldPosition end
        if inst:IsA("Model") then
                local ok, cf = pcall(inst.GetPivot, inst)
                if ok and cf then return cf.Position end
        end
        local part = GetPart(inst)
        return part and part.Position or nil
end

function B.Dist(inst)
        local _, _, root = GetParts()
        local p = B.PosOf(inst)
        if root and p then return (p - root.Position).Magnitude end
        return math.huge
end

local tpToken, tpHint = 0, false
function B.SafeTP(target, hold)
        local char, _, root = GetParts()
        if not (char and root) then return false end
        local goal = typeof(target) == "CFrame" and target or CFrame.new(target)
        local G = FX.Globals
        local acOff = G and G.AnticheatDisabled == true
        if not acOff and not tpHint then
                tpHint = true
                B.Toast("Teleport", "Tip: turn on Anticheat Bypass and use a ladder once so teleports never snap back.")
        end
        tpToken = tpToken + 1
        local my = tpToken
        hold = hold or (acOff and 0.6 or 1.6)

        local saved = {}
        for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                        saved[p] = true
                        p.CanCollide = false
                end
        end

        local function snap()
                local c2, _, r2 = GetParts()
                if not (c2 and r2) then return false end
                c2:PivotTo(goal)
                r2.AssemblyLinearVelocity = Vector3.zero
                r2.AssemblyAngularVelocity = Vector3.zero
                return true
        end
        for _ = 1, 3 do snap() end

        task.spawn(function()
                local t0 = os.clock()
                local conn
                conn = RunService.Heartbeat:Connect(function()
                        if my ~= tpToken or os.clock() - t0 >= hold then
                                conn:Disconnect()
                                if not (Ex.Noclip or Ex.ACM) then
                                        for p in pairs(saved) do
                                                if p.Parent then p.CanCollide = true end
                                        end
                                end
                                return
                        end
                        local _, _, r2 = GetParts()
                        if r2 and (r2.Position - goal.Position).Magnitude > 3.5 then snap() end
                end)
        end)
        return true
end

function B.Teleport(pos)
        local char, _, root = GetParts()
        if not (char and root) then return false end
        local dir = root.Position - pos
        dir = Vector3.new(dir.X, 0, dir.Z)
        local off = dir.Magnitude > 0.1 and dir.Unit * 3 or Vector3.new(0, 0, 3)
        local p = pos + off
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { char }
        local hit = Workspace:Raycast(p + Vector3.new(0, 4, 0), Vector3.new(0, -14, 0), params)
        local y = hit and (hit.Position.Y + 3.2) or (pos.Y + 3)
        return B.SafeTP(CFrame.new(p.X, y, p.Z))
end

function B.Find(pred, root)
        local out = {}
        root = root or B.Rooms()
        if not root then return out end
        local n = 0
        for _, d in ipairs(root:GetDescendants()) do
                local ok, hit = pcall(pred, d)
                if ok and hit then out[#out + 1] = d end
                n = n + 1
                if n % 600 == 0 then task.wait() end
        end
        return out
end

function B.Click(btn)
        if not btn then return false end
        local done = false
        pcall(function()
                if firesignal then
                        firesignal(btn.MouseButton1Click)
                        firesignal(btn.Activated)
                        done = true
                end
        end)
        if not done and getconnections then
                pcall(function()
                        for _, sig in ipairs({ btn.MouseButton1Click, btn.Activated, btn.MouseButton1Down }) do
                                for _, c in ipairs(getconnections(sig)) do
                                        pcall(c.Fire, c)
                                        done = true
                                end
                        end
                end)
        end
        return done
end

local huds = {}
function B.SetHud(id, y, text)
        if text and text ~= "" then
                local h = huds[id]
                if not (h and h.Label.Parent) then
                        local g = Instance.new("ScreenGui")
                        g.Name = "RON_Hud_" .. id
                        g.ResetOnSpawn = false
                        g.IgnoreGuiInset = true
                        g.DisplayOrder = 50
                        local l = Instance.new("TextLabel")
                        l.BackgroundTransparency = 1
                        l.AnchorPoint = Vector2.new(0.5, 1)
                        l.Position = UDim2.new(0.5, 0, y, 0)
                        l.Size = UDim2.new(0.8, 0, 0, 34)
                        l.Font = Enum.Font.GothamBold
                        l.TextSize = 24
                        l.TextColor3 = Color3.new(1, 1, 1)
                        l.TextStrokeTransparency = 0.3
                        l.Visible = false
                        l.Parent = g
                        pcall(function() g.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
                        if not g.Parent then g.Parent = LocalPlayer:WaitForChild("PlayerGui") end
                        h = { Gui = g, Label = l }
                        huds[id] = h
                end
                h.Label.Text = text
                h.Label.Visible = true
        elseif huds[id] then
                huds[id].Label.Visible = false
        end
end

function B.Out(title, lines)
        local text = "[AMBUSH HUB] " .. title .. "\n" .. table.concat(lines, "\n")
        print(text)
        pcall(function() if setclipboard then setclipboard(text) end end)
        B.Toast(title, #lines .. " lines printed to the console" .. (setclipboard and " and copied." or "."))
end

function B.Describe(inst)
        local s = inst:GetFullName() .. " [" .. inst.ClassName .. "]"
        local ok, attrs = pcall(inst.GetAttributes, inst)
        if ok and attrs then
                local bits = {}
                for k, v in pairs(attrs) do bits[#bits + 1] = k .. "=" .. tostring(v) end
                if #bits > 0 then s = s .. " {" .. table.concat(bits, ", ") .. "}" end
        end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") then s = s .. ' text="' .. tostring(inst.Text) .. '"' end
        if inst:IsA("ValueBase") then s = s .. " value=" .. tostring(inst.Value) end
        if inst:IsA("ProximityPrompt") then s = s .. ' action="' .. inst.ActionText .. '" object="' .. inst.ObjectText .. '"' end
        return s
end

function B.PickCat(list)
        for _, c in ipairs(list) do
                if Active[c] then return c end
        end
        return nil
end

function B.Reg(inst, cats, label, key)
        local cat = B.PickCat(cats)
        if not cat or Tracked[inst] then return Tracked[inst] ~= nil end
        local part = GetPart(inst)
        if not part then return false end
        Register(inst, cat, label, { Known = key ~= nil, Key = key })
        return Tracked[inst] ~= nil
end
end)()

;(function()
local B = FX.B8
local Players = game:GetService("Players")

Ex.BypassDrones = false
Ex.AntiNoise = false
Ex.BypassAlma = false
Ex.NoScribblesDamage = false

local KINDS = {
        { id = "BypassDrones", name = "Drone", collide = true,
                test = function(c) return c:find("drone", 1, true) ~= nil end },
        { id = "BypassAlma", name = "Alma", collide = true,
                test = function(c) return c:find("^alma") ~= nil and not c:find("almanac", 1, true) end },
        { id = "NoScribblesDamage", name = "Scribbles", spoof = true,
                test = function(c) return c:find("^scribbles") ~= nil end },
        { id = "AntiNoise", name = "Noise", mute = true, hide = true,
                test = function(c) return c == "noisemodel" or c == "noise" or c == "tvstand" end },
}

local Reg = {}

local function HandleObj(e, d, on)
        local k = e.k
        if d:IsA("BasePart") then
                if on then
                        if not e.Orig[d] then e.Orig[d] = { d.CanTouch, d.CanCollide, d.Transparency } end
                        d.CanTouch = false
                        if k.collide then d.CanCollide = false end
                        if k.hide then d.Transparency = 1 end
                else
                        local o = e.Orig[d]
                        if o and d.Parent then d.CanTouch, d.CanCollide, d.Transparency = o[1], o[2], o[3] end
                        e.Orig[d] = nil
                end
        elseif k.mute and d:IsA("Sound") then
                if on then
                        if e.Sounds[d] == nil then e.Sounds[d] = d.Volume end
                        d.Volume = 0
                else
                        if e.Sounds[d] ~= nil and d.Parent then d.Volume = e.Sounds[d] end
                        e.Sounds[d] = nil
                end
        end
end

local function ApplyEntry(m, e)
        local on = Ex[e.k.id] == true
        pcall(HandleObj, e, m, on)
        for _, d in ipairs(m:GetDescendants()) do pcall(HandleObj, e, d, on) end
        if on and not e.Conn then
                e.Conn = m.DescendantAdded:Connect(function(d)
                        if Ex[e.k.id] then task.defer(pcall, HandleObj, e, d, true) end
                end)
        elseif not on and e.Conn then
                e.Conn:Disconnect()
                e.Conn = nil
        end
end

local KindByName, KindN = {}, 0
local function KindOf(name)
        local v = KindByName[name]
        if v == nil then
                if KindN > 6000 then KindByName, KindN = {}, 0 end
                v = false
                if #name <= 40 then
                        local c = B.Compact(name)
                        if c ~= "" then
                                for _, k in ipairs(KINDS) do
                                        if k.test(c) then v = k break end
                                end
                        end
                end
                KindByName[name] = v
                KindN = KindN + 1
        end
        return v
end

local function Consider(d)
        if Reg[d] then return end
        local k = KindOf(d.Name)
        if not k then return end
        if not (d:IsA("Model") or (d:IsA("BasePart") and not d.Parent:IsA("Model"))) then return end
        local char = LocalPlayer.Character
        if char and d:IsDescendantOf(char) then return end
        if Players:GetPlayerFromCharacter(d) then return end
        do
                if true then
                        local e = { k = k, Orig = {}, Sounds = {} }
                        Reg[d] = e
                        d.AncestryChanged:Connect(function(_, p) if not p then Reg[d] = nil end end)
                        if Ex[k.id] then ApplyEntry(d, e) end
                        return
                end
        end
end

Workspace.DescendantAdded:Connect(function(d) pcall(Consider, d) end)
task.spawn(function()
        local n = 0
        for _, d in ipairs(Workspace:GetDescendants()) do
                pcall(Consider, d)
                n = n + 1
                if n % 500 == 0 then task.wait() end
        end
end)

for _, k in ipairs(KINDS) do
        Hooks[k.id] = function()
                for m, e in pairs(Reg) do
                        if e.k == k and m.Parent then pcall(ApplyEntry, m, e) end
                end
        end
end

local function Nearest(id)
        local best = math.huge
        for m, e in pairs(Reg) do
                if e.k.id == id and m.Parent and m:GetAttribute("Inactive") ~= true then
                        local d = B.Dist(m)
                        if d < best then best = d end
                end
        end
        return best
end
B.NearestKind = Nearest

local ragOff = false
task.spawn(function()
        while true do
                task.wait(0.12)
                pcall(function()
                        local char, hum = GetParts()
                        if not (char and hum) then return end

                        local near = Ex.BypassDrones and Nearest("BypassDrones") < 45 and not Ex.Fly
                        if near then
                                ragOff = true
                                pcall(hum.SetStateEnabled, hum, Enum.HumanoidStateType.Ragdoll, false)
                                pcall(hum.SetStateEnabled, hum, Enum.HumanoidStateType.FallingDown, false)
                                local s = hum:GetState()
                                if s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown then
                                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                                end
                                if hum.PlatformStand then hum.PlatformStand = false end
                                for _, a in ipairs({ "Ragdoll", "Ragdolled", "IsRagdoll" }) do
                                        if char:GetAttribute(a) == true then char:SetAttribute(a, false) end
                                end
                        elseif ragOff then
                                ragOff = false
                                pcall(hum.SetStateEnabled, hum, Enum.HumanoidStateType.Ragdoll, true)
                                pcall(hum.SetStateEnabled, hum, Enum.HumanoidStateType.FallingDown, true)
                        end
                end)
        end
end)

task.spawn(function()
        while true do
                task.wait(0.2)
                pcall(function()
                        local floor = B.FloorName()
                        local want = false
                        if Ex.FigureGodmode and floor ~= "Fools" and floor ~= "OldHotel" then
                                local F = FX.Functions
                                if F and F.GetNearestFigure then
                                        local ok, fig = pcall(F.GetNearestFigure)
                                        want = ok and fig ~= nil
                                end
                        end
                        if FX.SpoofVote then FX.SpoofVote("figgod", want) end
                end)
        end
end)

end)()

;(function()
local B = FX.B8
local PPS = game:GetService("ProximityPromptService")
local UIS = game:GetService("UserInputService")
Ex.Key_RestorePrompts = "P"
local busy = false

function B.RestorePrompts()
        if busy then return end
        busy = true
        task.spawn(function()
                pcall(function() PPS.Enabled = true end)
                local hadInf = Ex.InfiniteItems
                if Hooks.InfiniteItems then pcall(Hooks.InfiniteItems, false) end

                local _, _, root = GetParts()
                local list, n = {}, 0
                for _, d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                                if d:GetAttribute("FakePrompt") then
                                        pcall(d.Destroy, d)
                                else
                                        list[#list + 1] = d
                                end
                        end
                        n = n + 1
                        if n % 500 == 0 then task.wait() end
                end

                local toggled = {}
                for _, pp in ipairs(list) do
                        if pp.Parent and pp.Enabled and root then
                                local pos = B.PosOf(pp.Parent)
                                if pos and (pos - root.Position).Magnitude < 70 then
                                        pp.Enabled = false
                                        toggled[#toggled + 1] = pp
                                end
                        end
                end
                task.wait(0.2)
                for _, pp in ipairs(toggled) do
                        if pp.Parent then pp.Enabled = true end
                end

                if hadInf and Hooks.InfiniteItems then pcall(Hooks.InfiniteItems, true) end
                if Hooks.PromptReach then pcall(Hooks.PromptReach) end
                if Ex.AIReset then pcall(Ex.AIReset) end
                B.Toast("Prompts restored", #toggled .. " nearby prompts were refreshed.")
                busy = false
        end)
end

UIS.InputBegan:Connect(function(input, gpe)
        if gpe or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode.Name == Ex.Key_RestorePrompts then B.RestorePrompts() end
end)

AutomationTab:Section({ Title = "Prompt Tools" })
AutomationTab:Button({ Title = "Restore prompts", Desc = "Use if prompts stopped showing up: restores the real prompts, removes the fakes and refreshes nearby ones.", Callback = function() B.RestorePrompts() end })
AutomationTab:Button({ Title = "Auto interact: why skipped?", Desc = "Prints (and copies) every prompt within 20 studs with the Auto Interact skip reason, or says it is allowed.", Callback = function()
        local _, _, root = GetParts()
        if not root then return end
        local lines = {}
        for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Parent then
                        local pos = B.PosOf(d.Parent)
                        if pos and (pos - root.Position).Magnitude <= 20 then
                                local why = Ex.AIWhy and Ex.AIWhy(d) or "?"
                                lines[#lines + 1] = B.Describe(d) .. "  ->  " .. why
                        end
                end
        end
        B.Out("Auto Interact prompts nearby", lines)
end })
end)()

;(function()
local B = FX.B8
Ex.StairwellExtraESP = false

task.spawn(function()
        while true do
                task.wait(0.4)
                pcall(function()
                        local char = LocalPlayer.Character
                        local bp = LocalPlayer:FindFirstChild("Backpack")
                        for inst, e in pairs(Tracked) do
                                if e.Cat == "glitch" or e.Cat == "items" or e.Cat == "lotus" or e.Cat == "scanner" or e.Cat == "stardust" then
                                        local mine = (char and inst:IsDescendantOf(char)) or (bp and inst:IsDescendantOf(bp)) or inst:IsA("Tool")
                                        local drop = false
                                        if e.Cat == "glitch" then
                                                local pp = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
                                                if pp then e.B8Had = true end
                                                drop = e.B8Had and (not pp or not pp.Enabled)
                                        end
                                        if mine or drop then RemoveEntry(inst) end
                                end
                        end
                end)
        end
end)

local PROMPT_SKIP = {
        HidePrompt = true, ClimbPrompt = true, RiftPrompt = true, StarRiftPrompt = true, InteractPrompt = true,
        EnterPrompt = true, ActivateEventPrompt = true, LootPrompt = true, UnlockPrompt = true, SkullPrompt = true,
        LockPrompt = true, DonatePrompt = true, DialoguePrompt = true, RevivePrompt = true, AnimatePrompt = true,
        PropPrompt = true, ModulePrompt = true, HerbPrompt = true,
}
local seenExtra = setmetatable({}, { __mode = "k" })

local function Owner(pp)
        local rooms = B.Rooms()
        local cur, depth = pp.Parent, 0
        while cur and cur ~= Workspace and depth < 5 do
                if cur:IsA("Model") and cur.Parent ~= rooms and cur.Name ~= "Assets" then return cur end
                cur = cur.Parent
                depth = depth + 1
        end
        return pp.Parent
end

task.spawn(function()
        while true do
                task.wait(4)
                if Ex.StairwellExtraESP and B.InMode("Stairwell")
                        and ((Cfg.Categories.doors.Enabled and Active.doors) or (Cfg.Categories.items.Enabled and Active.items)) then
                        pcall(function()
                                local rooms = B.Rooms()
                                if not rooms then return end
                                local n, t0 = 0, os.clock()
                                local cur = B.CurRoom()
                                local scan = {}
                                for _, r in ipairs({ cur - 1, cur, cur + 1, cur + 2 }) do
                                        local room = rooms:FindFirstChild(tostring(r))
                                        if room then scan[#scan + 1] = room end
                                end
                                local all = {}
                                for _, room in ipairs(scan) do
                                        for _, d in ipairs(room:GetDescendants()) do all[#all + 1] = d end
                                end
                                for _, d in ipairs(all) do
                                        n = n + 1
                                        if n % 100 == 0 and os.clock() - t0 > 0.004 then task.wait() t0 = os.clock() end
                                        if not d.Parent then continue end
                                        if d:IsA("Model") and not Tracked[d] and not seenExtra[d] then
                                                local c = B.Compact(d.Name)
                                                if (c == "door" or c:find("stairwelldoor", 1, true) or c:find("cubbydoor", 1, true) or c:find("exitdoor", 1, true) or c:find("creakdoor", 1, true))
                                                        and not c:find("fake", 1, true) and Active.doors and not HasTrackedAncestor(d) then
                                                        seenExtra[d] = true
                                                        local num = B.RoomOf(d)
                                                        local label = c:find("cubby", 1, true) and "Cubby Door" or (c:find("creakdoor", 1, true) and "Creak Door") or ("Door" .. (num and (" " .. (num + 1)) or ""))
                                                        Register(d, "doors", label, { Part = GetPart(d), RoomNum = num })
                                                end
                                        elseif d:IsA("ProximityPrompt") and d.Enabled and not PROMPT_SKIP[d.Name] and not seenExtra[d] and d.Parent then
                                                seenExtra[d] = true
                                                local own = Owner(d)
                                                local oc = B.Compact(own and own.Name or "")
                                                if own and not Tracked[own] and not HasTrackedAncestor(own) and not own:IsA("Seat")
                                                        and not oc:find("stem", 1, true) and not oc:find("door", 1, true) and not oc:find("ladder", 1, true)
                                                        and not oc:find("chair", 1, true) and not oc:find("jeff", 1, true) and Active.items then
                                                        local ok, display = pcall(ResolveItem, { own.Name, d.ObjectText })
                                                        if ok and display then
                                                                Register(own, "items", display, { Known = true, Key = display })
                                                        else
                                                                local lbl = (d.ObjectText ~= "" and d.ObjectText) or CleanName(own.Name)
                                                                Register(own, "items", lbl, { Known = false })
                                                        end
                                                end
                                        end
                                end
                        end)
                end
        end
end)

AutomationTab:Section({ Title = "ESP Fixes" })
AddToggle(AutomationTab, "StairwellExtraESP", "Stairwell Extra ESP", "Also marks Stairwell doors and items that the normal scan missed (needs ESP Doors / Items on).", Ex.StairwellExtraESP, function(v) Ex.StairwellExtraESP = v end)
end)()

;(function()
local UIS = game:GetService("UserInputService")
local lastBtn, lastJump = nil, 0
local function DoJump()
        if not Ex.InfJump or os.clock() - lastJump < 0.12 then return end
        lastJump = os.clock()
        local _, hum = GetParts()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end
local function JumpButton()
        local ui = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
        local mf = ui and ui:FindFirstChild("MainFrame")
        local mb = mf and mf:FindFirstChild("MobileButtons")
        return mb and mb:FindFirstChild("JumpButton")
end
task.spawn(function()
        while true do
                task.wait(1)
                pcall(function()
                        local jb = JumpButton()
                        if jb and jb ~= lastBtn then
                                lastBtn = jb
                                if jb:IsA("GuiButton") then
                                        jb.Activated:Connect(DoJump)
                                        jb.MouseButton1Down:Connect(DoJump)
                                end
                                jb.InputBegan:Connect(function(i)
                                        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then DoJump() end
                                end)
                        end
                end)
        end
end)
UIS.TouchStarted:Connect(function(touch)
        if not Ex.InfJump then return end
        local jb = lastBtn
        if jb and jb.Parent and jb:IsA("GuiObject") and jb.Visible then
                local p, s, t = jb.AbsolutePosition, jb.AbsoluteSize, touch.Position
                local sg = jb:FindFirstAncestorOfClass("ScreenGui")
                local inset = (sg and not sg.IgnoreGuiInset) and game:GetService("GuiService"):GetGuiInset().Y or 0
                local ty = t.Y - inset
                if t.X >= p.X and t.X <= p.X + s.X and ty >= p.Y and ty <= p.Y + s.Y then DoJump() end
        end
end)
end)()

;(function()
local B = FX.B8
local RS = game:GetService("ReplicatedStorage")

Ex.CreakText = false
Ex.CreakRange = 60
Ex.NoiseTVBreaker = false
Ex.DropCounter = false
Ex.DropAutoBring = false
Ex.DropAutoGrinder = false
Ex.DropIntervalSecs = 1
Ex.DropOrbit = false
Ex.OrbitHeight = 2
Ex.OrbitDistance = 5
Ex.OrbitSpeed = 2
Ex.CrusherOff = false
Ex.CrusherDelete = false
Ex.MeldWallRemove = false
Ex.TrashLoop = false
Ex.CartsOnCreak = false

function B.Words(str)
        local out = {}
        str = tostring(str or ""):gsub("(%l)(%u)", "%1 %2"):gsub("[^%a]+", " "):lower()
        for w in str:gmatch("%a+") do out[w] = true end
        return out
end

local function NearestOf(list)
        local best, bd
        for _, d in ipairs(list) do
                local dist = B.Dist(d)
                if not bd or dist < bd then best, bd = d, dist end
        end
        return best
end

local Gen = {}
local function Loop(flag, fn, interval)
        Gen[flag] = (Gen[flag] or 0) + 1
        local my = Gen[flag]
        task.spawn(function()
                while Ex[flag] and Gen[flag] == my do
                        pcall(fn)
                        task.wait(interval)
                end
        end)
end

local function MoveObj(obj, cf)
        if obj:IsA("Model") then
                obj:PivotTo(cf)
        elseif obj:IsA("BasePart") then
                obj.CFrame = cf
        end
end

local function DropsFolder() return Workspace:FindFirstChild("Drops") end
local function MiscFolder() return Workspace:FindFirstChild("Misc") end

local function Carts()
        local out = {}
        local misc = MiscFolder()
        if misc then
                for _, m in ipairs(misc:GetChildren()) do
                        if m.Name == "ShoppingCart" and m:IsA("Model") then out[#out + 1] = m end
                end
        end
        return out
end

local function GetCreak()
        local live = Workspace:FindFirstChild("LiveEntities")
        return live and live:FindFirstChild("Creak")
end

local function GoTo(names, label, extraRoots)
        task.spawn(function()
                local function pred(d)
                        return (d:IsA("Model") or d:IsA("BasePart")) and (names[d.Name] == true or (names.__fuzzy and B.Has(d.Name, names.__fuzzy)) or false)
                end
                local list = B.Find(pred)
                for _, r in ipairs(extraRoots or {}) do
                        local root = r()
                        if root then
                                for _, d in ipairs(B.Find(pred, root)) do list[#list + 1] = d end
                        end
                end
                local t = NearestOf(list)
                local pos = t and B.PosOf(t)
                if pos and B.Teleport(pos) then
                        B.Toast(label, "Teleported.")
                else
                        B.Toast(label, "Not found in the loaded rooms. Move closer to the area and try again.")
                end
        end)
end

StairwellTab:Section({ Title = "Teleports" })
StairwellTab:Button({ Title = "Tp to fire alarm", Desc = "Teleports you to the nearest fire alarm on the Stairwell.", Callback = function()
        GoTo({ StairwellFireAlarm = true, __fuzzy = "firealarm" }, "Fire Alarm")
end })
StairwellTab:Button({ Title = "Tp to emergency exit", Desc = "Teleports you to the nearest Emergency Exit sign.", Callback = function()
        GoTo({ ExitSignStairwell = true, __fuzzy = "exitsign" }, "Emergency Exit")
end })
StairwellTab:Button({ Title = "Tp to Depot (Scrapper)", Desc = "Teleports you to the nearest Depot / Scrapper.", Callback = function()
        GoTo({ StairwellScrapper = true, __fuzzy = "scrapper" }, "Depot")
end })
StairwellTab:Button({ Title = "Tp to shopping cart", Desc = "Teleports you to the nearest cart (in a room or loose on the map).", Callback = function()
        GoTo({ ShoppingCart = true }, "Shopping Cart", { MiscFolder })
end })

local ITEM_PROMPTS = { ModulePrompt = true, HerbPrompt = true, PickupPrompt = true, SalvagePrompt = true }

local function StairItems()
        return B.Find(function(d)
                if not d:IsA("ProximityPrompt") or not d.Enabled or not d.Parent then return false end
                local w = B.Words(d.Name .. " " .. d.ObjectText .. " " .. d.Parent.Name .. " " .. (d.Parent.Parent and d.Parent.Parent.Name or ""))
                if w.stem or w.stems or w.jeff or w.shop or w.fake then return false end
                if ITEM_PROMPTS[d.Name] then return true end
                return (w.drive or w.drives or w.salvage or w.scrap) and true or false
        end)
end

local grabBusy = false
StairwellTab:Section({ Title = "Items" })
StairwellTab:Button({ Title = "Grab all items (real pickup)", Desc = "Walks (teleports) to each item on the Stairwell and picks it up on the server, then returns you. Unlike moving items, it really goes into your inventory.", Callback = function()
        if grabBusy then return end
        if not fireproximityprompt then B.Toast("Grab Items", "Your executor has no fireproximityprompt.") return end
        grabBusy = true
        task.spawn(function()
                local char, _, root = GetParts()
                if not (char and root) then grabBusy = false return end
                local origin = root.CFrame
                local list = StairItems()
                local seen, n = {}, 0
                table.sort(list, function(a, b) return B.Dist(a.Parent) < B.Dist(b.Parent) end)
                for _, pp in ipairs(list) do
                        if pp.Parent and pp.Enabled and not seen[pp] then
                                seen[pp] = true
                                local pos = B.PosOf(pp.Parent)
                                local _, _, r2 = GetParts()
                                if not (pos and r2) then break end
                                if (pos - r2.Position).Magnitude > math.max(pp.MaxActivationDistance - 3, 3) then
                                        B.SafeTP(CFrame.new(pos + Vector3.new(0, 3, 0)), 0.5)
                                        task.wait(0.25)
                                end
                                for _ = 1, 3 do
                                        pcall(fireproximityprompt, pp)
                                        task.wait(0.08)
                                end
                                n = n + 1
                        end
                end
                B.SafeTP(origin, 0.8)
                B.Toast("Grab Items", n > 0 and (n .. " items picked up.") or "No loaded items were found.")
                grabBusy = false
        end)
end })

local function BringDrops()
        local drops = DropsFolder()
        local _, _, root = GetParts()
        if not (drops and root) then return 0 end
        local n = 0
        for _, it in ipairs(drops:GetChildren()) do
                if it:IsA("Model") or it:IsA("BasePart") then
                        MoveObj(it, root.CFrame)
                        n = n + 1
                end
        end
        return n
end

StairwellTab:Button({ Title = "Bring dropped items", Desc = "Moves all dropped items (Workspace.Drops) to you. They are physical, so the server and other players see them too.", Callback = function()
        local n = BringDrops()
        B.Toast("Bring Dropped Items", n > 0 and (n .. " items moved to you.") or "There are no dropped items.")
end })
AddToggle(StairwellTab, "DropAutoBring", "Auto bring dropped items", "Brings the dropped items to you every X seconds (interval below).", Ex.DropAutoBring, function(v)
        Ex.DropAutoBring = v
        if v then Loop("DropAutoBring", BringDrops, math.max(Ex.DropIntervalSecs, 0.05)) end
end)
AddSlider(StairwellTab, "DropIntervalSecs", "Interval (seconds)", "How often the automatic bring / scrap runs (0 = every frame-ish).", 0, 60, Ex.DropIntervalSecs, function(v)
        Ex.DropIntervalSecs = v
        if Ex.DropAutoBring then Loop("DropAutoBring", BringDrops, math.max(v, 0.05)) end
        if Ex.DropAutoGrinder then Loop("DropAutoGrinder", function() B.DropsToGrinder() end, math.max(v, 0.05)) end
end)

function B.DropsToGrinder()
        local drops, rooms = DropsFolder(), B.Rooms()
        local _, _, root = GetParts()
        if not (drops and rooms and root) then return false end
        local best, bd
        for _, room in ipairs(rooms:GetChildren()) do
                local scr = room:FindFirstChild("StairwellScrapper", true)
                if scr then
                        for _, o in ipairs(scr:GetDescendants()) do
                                if o.Name == "Grinder1" and (o:IsA("Model") or o:IsA("BasePart")) then
                                        local d = (root.Position - o:GetPivot().Position).Magnitude
                                        if not bd or d < bd then best, bd = o, d end
                                end
                        end
                end
        end
        if not best then return false end
        local cf = best:GetPivot()
        for _, it in ipairs(drops:GetChildren()) do MoveObj(it, cf) end
        return true
end

StairwellTab:Section({ Title = "Scrap" })
StairwellTab:Button({ Title = "Tp all drops to nearest Grinder", Desc = "Sends all dropped items to the Grinder nearest to you.", Callback = function()
        B.Toast("Scrap", B.DropsToGrinder() and "Drops sent to the Grinder." or "No Grinder found (get closer to a Depot).")
end })
AddToggle(StairwellTab, "DropAutoGrinder", "Auto scrap drops", "Keeps sending dropped items to the nearest Grinder (uses the interval above).", Ex.DropAutoGrinder, function(v)
        Ex.DropAutoGrinder = v
        if v then Loop("DropAutoGrinder", function() B.DropsToGrinder() end, math.max(Ex.DropIntervalSecs, 0.05)) end
end)

local function DropCount()
        local drops = DropsFolder()
        if not drops then return 0 end
        local n = 0
        for _, d in ipairs(drops:GetChildren()) do
                if d:IsA("Model") or d:IsA("BasePart") then n = n + 1 end
        end
        return n
end
task.spawn(function()
        while true do
                task.wait(0.5)
                pcall(function()
                        if Ex.DropCounter then B.SetHud("dropcount", 0.64, "Items: " .. DropCount()) else B.SetHud("dropcount", 0.64, nil) end
                end)
        end
end)
AddToggle(StairwellTab, "DropCounter", "Dropped items counter", "Shows how many dropped items there are on the screen.", Ex.DropCounter, function(v) Ex.DropCounter = v end)

local orbitConn, orbitAngle, orbitLast, orbitPause = nil, 0, 0, 0
AddToggle(StairwellTab, "DropOrbit", "Dropped items orbit", "Orbits the dropped items around you. Every 10s they are brought to you so they do not despawn.", Ex.DropOrbit, function(v)
        Ex.DropOrbit = v
        if orbitConn then orbitConn:Disconnect() orbitConn = nil end
        if not v then return end
        orbitAngle, orbitLast, orbitPause = 0, os.clock(), 0
        orbitConn = RunService.Heartbeat:Connect(function(dt)
                local _, _, root = GetParts()
                local drops = DropsFolder()
                if not (root and drops) then return end
                local list = {}
                for _, it in ipairs(drops:GetChildren()) do
                        if it:IsA("Model") or it:IsA("BasePart") then list[#list + 1] = it end
                end
                local count = #list
                if count == 0 then return end
                local now = os.clock()
                if now - orbitLast >= 10 then
                        orbitLast = now
                        orbitPause = now + 2
                        for _, it in ipairs(list) do MoveObj(it, CFrame.new(root.Position)) end
                end
                if now < orbitPause then return end
                orbitAngle = orbitAngle + dt * Ex.OrbitSpeed
                for i, it in ipairs(list) do
                        local a = orbitAngle + ((i - 1) / count) * math.pi * 2
                        local off = Vector3.new(math.cos(a) * Ex.OrbitDistance, Ex.OrbitHeight, math.sin(a) * Ex.OrbitDistance)
                        MoveObj(it, CFrame.new(root.Position + off))
                end
        end)
end)
AddSlider(StairwellTab, "OrbitHeight", "Orbit Height", "Height of the orbit.", -20, 20, Ex.OrbitHeight, function(v) Ex.OrbitHeight = v end)
AddSlider(StairwellTab, "OrbitDistance", "Orbit Distance", "Distance of the orbit.", 0, 50, Ex.OrbitDistance, function(v) Ex.OrbitDistance = v end)
AddSlider(StairwellTab, "OrbitSpeed", "Orbit Speed", "Speed of the orbit.", 0, 20, Ex.OrbitSpeed, function(v) Ex.OrbitSpeed = v end)

local function DropHeld()
        local char = LocalPlayer.Character
        local rf = RS:FindFirstChild("RemotesFolder")
        local drop = rf and rf:FindFirstChild("DropItem")
        if not (char and drop) then return false end
        local did = false
        for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then
                        pcall(function() drop:FireServer(t) end)
                        did = true
                end
        end
        return did
end

local trashGen = 0
AddToggle(StairwellTab, "TrashLoop", "Tp to trash and drop", "Goes to every landing trash item, picks it up and drops it so it becomes a dropped item. Combine with Orbit / Auto Scrap / Bring Dropped Items.", Ex.TrashLoop, function(v)
        Ex.TrashLoop = v
        trashGen = trashGen + 1
        if not v then return end
        local my = trashGen
        task.spawn(function()
                local origin
                do
                        local _, _, r = GetParts()
                        origin = r and r.CFrame
                end
                while Ex.TrashLoop and trashGen == my do
                        local models = {}
                        local rooms = B.Rooms()
                        if rooms then
                                for _, room in ipairs(rooms:GetChildren()) do
                                        local logic = room:FindFirstChild("StairwellLandingLogic")
                                        if logic then
                                                for _, m in ipairs(logic:GetChildren()) do
                                                        if m:IsA("Model") then
                                                                local prompts = {}
                                                                for _, o in ipairs(m:GetDescendants()) do
                                                                        if o:IsA("ProximityPrompt") then prompts[#prompts + 1] = o end
                                                                end
                                                                if #prompts > 0 then models[#models + 1] = { Model = m, Prompts = prompts, N = tonumber(room.Name) or math.huge } end
                                                        end
                                                end
                                        end
                                end
                        end
                        table.sort(models, function(a, b) return a.N < b.N end)
                        for _, data in ipairs(models) do
                                if not (Ex.TrashLoop and trashGen == my) then break end
                                local t0 = os.clock()
                                while data.Model.Parent and data.Model:IsDescendantOf(Workspace) and Ex.TrashLoop and trashGen == my and os.clock() - t0 < 6 do
                                        local char, _, root = GetParts()
                                        if root then
                                                char:PivotTo(data.Model:GetPivot() + Vector3.new(0, 5, 0))
                                                for _, p in ipairs(data.Prompts) do
                                                        if p.Parent and p.Enabled and fireproximityprompt then pcall(fireproximityprompt, p) end
                                                end
                                                if not DropHeld() and keypress and keyrelease then
                                                        keypress(0x58)
                                                        task.wait(0.03)
                                                        keyrelease(0x58)
                                                end
                                        end
                                        RunService.Heartbeat:Wait()
                                end
                        end
                        RunService.Heartbeat:Wait()
                end
                if origin then B.SafeTP(origin, 0.8) end
        end)
end)

local function CrusherPass(deleteMode)
        local rooms = B.Rooms()
        if not rooms then return end
        for _, room in ipairs(rooms:GetChildren()) do
                local assets = room:FindFirstChild("Assets")
                if assets then
                        for _, cont in ipairs(assets:GetChildren()) do
                                if cont.Name:find("^StairwellCrusherContainer") then
                                        local function underWall(d)
                                                local p = d.Parent
                                                while p and p ~= cont do
                                                        if p.Name == "BasicWall" then return true end
                                                        p = p.Parent
                                                end
                                                return false
                                        end
                                        if deleteMode then
                                                local kill = {}
                                                for _, d in ipairs(cont:GetDescendants()) do
                                                        if d.Name ~= "BasicWall" and not underWall(d) then kill[#kill + 1] = d end
                                                end
                                                for _, d in ipairs(kill) do
                                                        if d.Parent then d:Destroy() end
                                                end
                                        else
                                                for _, d in ipairs(cont:GetDescendants()) do
                                                        if d:IsA("BasePart") and d.CanCollide and not underWall(d) then d.CanCollide = false end
                                                end
                                                local crusher = cont:FindFirstChild("StairwellCrusher")
                                                if crusher then
                                                        for _, n in ipairs({ "OuterTrigger", "CoreTrigger" }) do
                                                                local t = crusher:FindFirstChild(n)
                                                                if t then t:Destroy() end
                                                        end
                                                end
                                        end
                                end
                        end
                end
        end
end

local function MeldPass()
        local rooms = B.Rooms()
        if not rooms then return end
        for _, room in ipairs(rooms:GetChildren()) do
                for _, folderName in ipairs({ "Assets", "Parts" }) do
                        local folder = room:FindFirstChild(folderName)
                        if folder then
                                for _, c in ipairs(folder:GetChildren()) do
                                        if c.Name == "MeldWall" or c.Name == "Boleahghth29tdgfhy2thuy2htuu259uhh3u" then c:Destroy() end
                                end
                        end
                end
                for _, name in ipairs({ "MeldData", "MeldPads", "Meldview", "Meld" }) do
                        local o = room:FindFirstChild(name)
                        if o and o:IsA("Folder") then o:Destroy() end
                end
        end
end

StairwellTab:Section({ Title = "Crushers and Meld" })
AddToggle(StairwellTab, "CrusherOff", "Disable crushers", "Disables collision and kill triggers of crushers (the base wall stays).", Ex.CrusherOff, function(v)
        Ex.CrusherOff = v
        if v then Loop("CrusherOff", function() CrusherPass(false) end, 0.5) end
end)
AddToggle(StairwellTab, "CrusherDelete", "Delete crushers", "Fully deletes crushers (except the base wall).", Ex.CrusherDelete, function(v)
        Ex.CrusherDelete = v
        if v then Loop("CrusherDelete", function() CrusherPass(true) end, 0.5) end
end)
AddToggle(StairwellTab, "MeldWallRemove", "Remove Meld walls and data", "Removes Meld walls, pads and data folders in every loaded room.", Ex.MeldWallRemove, function(v)
        Ex.MeldWallRemove = v
        if v then Loop("MeldWallRemove", MeldPass, 0.5) end
end)

StairwellTab:Section({ Title = "Noise TV & Carts" })
AddToggle(StairwellTab, "NoiseTVBreaker", "Break Noise TV", "Sends the Noise TV underground while you hold it (it breaks for everyone, the server sees it).", Ex.NoiseTVBreaker, function(v)
        Ex.NoiseTVBreaker = v
        if v then
                Loop("NoiseTVBreaker", function()
                        local misc = MiscFolder()
                        if not misc then return end
                        for _, m in ipairs(misc:GetChildren()) do
                                if m:IsA("Model") and m.Name == "TV_Stand" then
                                        local cf = m:GetPivot()
                                        if cf.Position.Y > -119 then m:PivotTo(CFrame.new(cf.Position.X, -120, cf.Position.Z)) end
                                end
                        end
                end, 0.25)
        end
end)
StairwellTab:Button({ Title = "Tp carts to me", Desc = "Bring all carts to you. They are physical, so everyone sees the movement. Don't stand where they land.", Callback = function()
        local _, _, root = GetParts()
        if not root then return end
        local n = 0
        for _, c in ipairs(Carts()) do
                c:PivotTo(root.CFrame * CFrame.new(0, 0, -6))
                n = n + 1
        end
        B.Toast("Carts", n > 0 and (n .. " carts moved.") or "No shopping carts are loaded.")
end })
AddToggle(StairwellTab, "CartsOnCreak", "Break Creak (needs 5+ carts)", "Keeps every cart on top of Creak so it glitches out. DO NOT touch the carts yourself.", Ex.CartsOnCreak, function(v)
        Ex.CartsOnCreak = v
        if v then
                Loop("CartsOnCreak", function()
                        local creak = GetCreak()
                        if not creak then return end
                        local cf = creak:GetPivot()
                        for _, c in ipairs(Carts()) do c:PivotTo(cf) end
                end, 0.1)
        end
end)

StairwellTab:Section({ Title = "Doors" })
StairwellTab:Button({ Title = "Open all Cubby doors", Desc = "Triggers the open prompt on every loaded Cubby door.", Callback = function()
        if not fireproximityprompt then B.Toast("Cubby Doors", "Your executor has no fireproximityprompt.") return end
        task.spawn(function()
                local list = B.Find(function(d)
                        if not d:IsA("ProximityPrompt") or not d.Enabled or not d.Parent then return false end
                        local cur, depth, hit = d.Parent, 0, false
                        while cur and cur ~= Workspace and depth < 6 do
                                if B.Has(cur.Name, "cubby") then hit = true break end
                                cur, depth = cur.Parent, depth + 1
                        end
                        if not hit then return false end
                        local at = (d.ActionText or ""):lower()
                        if at:find("close", 1, true) then return false end
                        return at:find("open", 1, true) ~= nil or B.Has(d.Parent.Name, "door") or B.Has(d.Name, "door") or d.Name == "ActivateEventPrompt"
                end)
                for _, pp in ipairs(list) do
                        pcall(fireproximityprompt, pp)
                        task.wait(0.06)
                end
                B.Toast("Cubby Doors", #list > 0 and (#list .. " prompts triggered.") or "No Cubby doors found in the loaded rooms.")
        end)
end })

local AGG = { "aggress", "aggro", "anger", "angry", "agitat", "rage", "hostil", "fury", "wrath" }
local Creaks = {}

local CreakName = {}
local function IsCreak(d)
        if not d:IsA("Model") then return false end
        local nm = d.Name
        local v = CreakName[nm]
        if v == nil then
                v = #nm < 30 and B.Has(nm, "creak") or false
                CreakName[nm] = v
        end
        return v
end
Workspace.DescendantAdded:Connect(function(d)
        if IsCreak(d) then
                Creaks[d] = true
                d.AncestryChanged:Connect(function(_, p) if not p then Creaks[d] = nil end end)
        end
end)
task.spawn(function()
        local n = 0
        for _, d in ipairs(Workspace:GetDescendants()) do
                if IsCreak(d) then Creaks[d] = true end
                n = n + 1
                if n % 500 == 0 then task.wait() end
        end
end)

local function ToPercent(v)
        if v >= 0 and v <= 1 then v = v * 100 end
        return math.floor(v + 0.5)
end

local function ReadGraph(m)
        local animator = m:FindFirstChildWhichIsA("Animator", true)
        if not animator then return nil end
        for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
                if tr.Name == "CreakGraph" or (tr.Animation and tr.Animation.Name == "CreakGraph") then
                        local ok, val = pcall(tr.GetParameter, tr, "Aggression")
                        if ok and typeof(val) == "number" then return math.clamp(val, 0, 1) * 100 end
                end
        end
        return nil
end

local function ReadAggro(m)
        local okG, g = pcall(ReadGraph, m)
        if okG and g then return math.floor(g + 0.5) end
        local function scan(inst)
                for k, v in pairs(inst:GetAttributes()) do
                        if type(v) == "number" then
                                local lk = k:lower()
                                for _, w in ipairs(AGG) do
                                        if lk:find(w, 1, true) then return ToPercent(v) end
                                end
                        end
                end
                if inst:IsA("NumberValue") or inst:IsA("IntValue") then
                        local lk = inst.Name:lower()
                        for _, w in ipairs(AGG) do
                                if lk:find(w, 1, true) then return ToPercent(inst.Value) end
                        end
                end
        end
        local r = scan(m)
        if r then return r end
        local i = 0
        for _, d in ipairs(m:GetDescendants()) do
                r = scan(d)
                if r then return r end
                i = i + 1
                if i > 300 then break end
        end
        return nil
end

task.spawn(function()
        while true do
                task.wait(0.2)
                pcall(function()
                        if not Ex.CreakText then B.SetHud("creak", 0.70, nil) return end
                        local best, bd
                        for m in pairs(Creaks) do
                                if m.Parent then
                                        local d = B.Dist(m)
                                        if d <= Ex.CreakRange and (not bd or d < bd) then best, bd = m, d end
                                end
                        end
                        if not best then B.SetHud("creak", 0.70, nil) return end
                        local pct = ReadAggro(best)
                        B.SetHud("creak", 0.70, "Creak aggression: " .. (pct and (pct .. "%") or "??%"))
                end)
        end
end)

StairwellTab:Section({ Title = "Creak" })
AddToggle(StairwellTab, "CreakText", "Creak aggression text", "Shows the Creak aggression percentage at the bottom of the screen while it is near.", Ex.CreakText, function(v) Ex.CreakText = v end)
AddSlider(StairwellTab, "CreakRange", "Creak Text Range", "How close (in studs) Creak must be for the text to appear.", 10, 300, Ex.CreakRange, function(v) Ex.CreakRange = v end)
end)()

;(function()
local B = FX.B8

Ex.FMNAnomalyESP = false
Ex.FMNAnomalyNotify = false
Ex.AutoAlmaMinigame = false
Ex.TellerNumber = false
Ex.TellerNotify = false

local RS = game:GetService("ReplicatedStorage")
local lastFire = setmetatable({}, { __mode = "k" })

Ex.HonchoESP = false
Ex.HonchoAutoDeposit = false
Ex.HonchoAutoFull = false
Ex.FMNSkipper = false
Ex.BypassWater = false
Ex.TimeShower = false
Ex.StopTimeStampede = false
Ex.AntiRansom = false
Ex.AntiClosetTrash = false

local Gen = {}
local function Loop(flag, fn, interval)
        Gen[flag] = (Gen[flag] or 0) + 1
        local my = Gen[flag]
        task.spawn(function()
                while Ex[flag] and Gen[flag] == my do
                        pcall(fn)
                        task.wait(interval)
                end
        end)
end

local function LatestRoomValue()
        local gd = RS:FindFirstChild("GameData")
        return gd and gd:FindFirstChild("LatestRoom")
end

local Hon = { Deposits = {}, Boxes = {}, Drops = {} }

local function IsBoxName(n) return n == "ArchivesStorageBox" or n == "ArchivesStorageBoxCorrect" end

local function ScanHoncho()
        local rooms = B.Rooms()
        if not rooms then return end
        local cur = B.CurRoom()
        for n = cur - 1, cur + 3 do
                local room = rooms:FindFirstChild(tostring(n))
                local honchoRoom = room and room:FindFirstChild("ArchivesHonchoRoom", true)
                if honchoRoom then
                        local ids = {}
                        for _, d in ipairs(room:GetDescendants()) do
                                if d.Name:find("^ArchivesPackageDeposit") then
                                        local id = d:GetAttribute("BoxID")
                                        if id ~= nil then
                                                ids[tostring(id)] = true
                                                Hon.Deposits[tostring(id)] = d
                                        end
                                end
                        end
                        if next(ids) then
                                for _, c in ipairs(honchoRoom:GetDescendants()) do
                                        if IsBoxName(c.Name) then
                                                local tid = c:GetAttribute("Tool_BoxID")
                                                if tid ~= nil and ids[tostring(tid)] then Hon.Boxes[c] = tostring(tid) end
                                        end
                                end
                        end
                end
        end
        local drops = Workspace:FindFirstChild("Drops")
        if drops then
                for _, c in ipairs(drops:GetChildren()) do
                        if IsBoxName(c.Name) then
                                local id = c:GetAttribute("Tool_BoxID") or c:GetAttribute("BoxID")
                                if id ~= nil and Hon.Deposits[tostring(id)] then Hon.Drops[c] = tostring(id) end
                        end
                end
        end
        for id, d in pairs(Hon.Deposits) do
                if not d.Parent then Hon.Deposits[id] = nil end
        end
        for c in pairs(Hon.Boxes) do
                if not c.Parent then Hon.Boxes[c] = nil end
        end
        for c in pairs(Hon.Drops) do
                if not c.Parent then Hon.Drops[c] = nil end
        end
end

local function HonchoESPPass()
        for id, d in pairs(Hon.Deposits) do
                if d.Parent then B.Reg(d, { "items", "interactables" }, "Deposit (" .. id .. ")", nil) end
        end
        for c, id in pairs(Hon.Boxes) do
                if c.Parent then B.Reg(c, { "items", "interactables" }, "Correct Box (" .. id .. ")", nil) end
        end
        for c, id in pairs(Hon.Drops) do
                if c.Parent then B.Reg(c, { "items", "interactables" }, "Correct Box (" .. id .. ")", nil) end
        end
end

local function HonchoESPClear()
        for _, set in ipairs({ Hon.Boxes, Hon.Drops }) do
                for c in pairs(set) do
                        if Tracked[c] then pcall(RemoveEntry, c) end
                end
        end
        for _, d in pairs(Hon.Deposits) do
                if Tracked[d] then pcall(RemoveEntry, d) end
        end
end

task.spawn(function()
        while true do
                task.wait(1.5)
                if (Ex.HonchoESP or Ex.HonchoAutoDeposit or Ex.HonchoAutoFull) and B.InMode("Archives") then
                        pcall(ScanHoncho)
                        if Ex.HonchoESP then pcall(HonchoESPPass) end
                end
        end
end)

local function HeldBoxes()
        local out = {}
        local char = LocalPlayer.Character
        if char then
                for _, o in ipairs(char:GetChildren()) do
                        if (o:IsA("Tool") or o:IsA("Model")) and IsBoxName(o.Name) then out[#out + 1] = o end
                end
        end
        return out
end

local function DepositFor(box)
        local id = box:GetAttribute("Tool_BoxID") or box:GetAttribute("BoxID")
        if id == nil then return nil, nil end
        local dep = Hon.Deposits[tostring(id)]
        if dep and dep.Parent then return dep, tostring(id) end
        return nil, tostring(id)
end

local function DepositPart(dep)
        return dep:IsA("BasePart") and dep or dep:FindFirstChildWhichIsA("BasePart", true)
end

RunService.Heartbeat:Connect(function()
        if not Ex.HonchoAutoDeposit then return end
        local now = os.clock()
        if Hon.LastCheck and now - Hon.LastCheck < 0.1 then return end
        Hon.LastCheck = now
        pcall(function()
                local _, _, root = GetParts()
                if not (root and fireproximityprompt) then return end
                for _, box in ipairs(HeldBoxes()) do
                        local dep = DepositFor(box)
                        if dep then
                                local part = DepositPart(dep)
                                if part and (root.Position - part.Position).Magnitude <= 10 then
                                        local prompt = dep:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt then fireproximityprompt(prompt) end
                                end
                        end
                end
        end)
end)

local honchoGen = 0
local function HonchoFullRun(my)
        local origin
        do
                local _, _, r = GetParts()
                origin = r and r.CFrame
        end
        local idle = 0
        while Ex.HonchoAutoFull and honchoGen == my do
                pcall(ScanHoncho)
                local held = HeldBoxes()
                if #held > 0 then
                        idle = 0
                        local dep = DepositFor(held[1])
                        local part = dep and DepositPart(dep)
                        if part then
                                B.SafeTP(CFrame.new(part.Position + Vector3.new(0, 4, 0)), 0.6)
                                task.wait(0.4)
                                local prompt = dep:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt and fireproximityprompt then
                                        for _ = 1, 3 do
                                                pcall(fireproximityprompt, prompt)
                                                task.wait(0.1)
                                        end
                                end
                                task.wait(0.4)
                        else
                                task.wait(0.5)
                        end
                else
                        local target
                        local _, _, root = GetParts()
                        local bd
                        for _, set in ipairs({ Hon.Boxes, Hon.Drops }) do
                                for c in pairs(set) do
                                        if c.Parent and c:IsDescendantOf(Workspace) then
                                                local p = B.PosOf(c)
                                                local d = (root and p) and (root.Position - p).Magnitude or math.huge
                                                if not bd or d < bd then target, bd = c, d end
                                        end
                                end
                        end
                        if target then
                                idle = 0
                                local pos = B.PosOf(target)
                                local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if pos then
                                        B.SafeTP(CFrame.new(pos + Vector3.new(0, 3, 0)), 0.6)
                                        task.wait(0.4)
                                        if prompt and fireproximityprompt then
                                                for _ = 1, 3 do
                                                        pcall(fireproximityprompt, prompt)
                                                        task.wait(0.1)
                                                end
                                        end
                                        task.wait(0.4)
                                end
                        else
                                idle = idle + 1
                                if idle > 20 then break end
                                task.wait(0.5)
                        end
                end
        end
        if origin then B.SafeTP(origin, 0.8) end
        if Ex.HonchoAutoFull and honchoGen == my then SetFeature("HonchoAutoFull", false) end
end

local clockLabel
local function ClockLabelOf(room)
        local assets = room and room:FindFirstChild("Assets", true)
        local clock = assets and assets:FindFirstChild("ArchivesClock", true)
        local tm = clock and clock:FindFirstChild("Time", true)
        local lbl = tm and tm:FindFirstChild("TextLabel")
        return (lbl and lbl:IsA("TextLabel")) and lbl or nil
end

local function ResolveClockLabel()
        if clockLabel and clockLabel.Parent and clockLabel:IsDescendantOf(game) then return clockLabel end
        local rooms = B.Rooms()
        if not rooms then return nil end
        local list = {}
        for _, room in ipairs(rooms:GetChildren()) do
                local n = tonumber(room.Name)
                if n then list[#list + 1] = { room = room, n = n } end
        end
        table.sort(list, function(a, b) return a.n > b.n end)
        for i = 1, math.min(6, #list) do
                local lbl = ClockLabelOf(list[i].room)
                if lbl then
                        clockLabel = lbl
                        return lbl
                end
        end
        return nil
end

local function ResolveClockRemote()
        local lbl = ResolveClockLabel()
        if not lbl then return nil end
        local clock = lbl:FindFirstAncestor("ArchivesClock")
        local remote = clock and clock:FindFirstChild("LookedAtRemote", true)
        return (remote and remote:IsA("RemoteEvent")) and remote or nil
end

task.spawn(function()
        while true do
                task.wait(0.2)
                pcall(function()
                        if not Ex.TimeShower then B.SetHud("archtime", 0.82, nil) return end
                        local lbl = ResolveClockLabel()
                        B.SetHud("archtime", 0.82, lbl and ("Time: " .. lbl.Text) or "Time: --:--")
                end)
        end
end)

local ransomConn, trashConn
local function SetRansom(v)
        if ransomConn then ransomConn:Disconnect() ransomConn = nil end
        if not v then return end
        for _, c in ipairs(Workspace:GetChildren()) do
                if c.Name == "Ransom" then c:Destroy() end
        end
        ransomConn = Workspace.ChildAdded:Connect(function(c)
                if c.Name == "Ransom" and Ex.AntiRansom then c:Destroy() end
        end)
end
local function SetTrash(v)
        if trashConn then trashConn:Disconnect() trashConn = nil end
        if not v then return end
        trashConn = Workspace.ChildAdded:Connect(function(c)
                if not Ex.AntiClosetTrash then return end
                local n = c.Name
                if n:sub(1, 6) == "Binder" or n:sub(1, 4) == "Shoe" or n:sub(1, 5) == "Shelf" then c:Destroy() end
        end)
end

local fmnProcessing = {}
local fmnConn
local fmnGen = 0

local function GetChar() return LocalPlayer.Character end

local function SetFMNSkipper(v)
        if fmnConn then fmnConn:Disconnect() fmnConn = nil end
        fmnGen = fmnGen + 1
        table.clear(fmnProcessing)
        if not v then return end
        local my = fmnGen
        local rooms = B.Rooms()
        if not rooms then return end

        local function alive() return Ex.FMNSkipper and fmnGen == my end

        local function NextRoomOf(number)
                while alive() do
                        for rn = number + 1, number + 5 do
                                local r = rooms:FindFirstChild(tostring(rn))
                                if r then return r end
                        end
                        task.wait(0.1)
                end
                return nil
        end

        local function FireLookAts(room)
                for i = 1, 6 do
                        local o = room:FindFirstChild(tostring(i))
                        local la = o and o:FindFirstChild("LookAt")
                        if la then pcall(function() la:FireServer() end) end
                end
        end

        local function VoidChar()
                local char = GetChar()
                if not char then return end
                local t0 = os.clock()
                while alive() and os.clock() - t0 < 2 do
                        char:PivotTo(CFrame.new(0, -120, 0))
                        task.wait(0.1)
                end
        end

        local function PivotToObj(char, obj, up)
                up = up or Vector3.zero
                if obj:IsA("BasePart") then
                        char:PivotTo(obj.CFrame + up)
                elseif obj:IsA("Model") then
                        char:PivotTo(obj:GetPivot() + up)
                end
        end

        local function Run(room)
                local rn = tonumber(room.Name)
                if not rn or not alive() or fmnProcessing[rn] then return end
                if not room:FindFirstChild("ForgetMeNotVineDoors", true) then return end
                fmnProcessing[rn] = true

                while alive() and room.Parent do
                        FireLookAts(room)
                        local nextRoom = NextRoomOf(rn)
                        if not nextRoom then
                                task.wait(0.4)
                                continue
                        end
                        local door = nextRoom:FindFirstChild("Door")
                        if not door then
                                local char = GetChar()
                                if char then
                                        local target = nextRoom:FindFirstChildWhichIsA("BasePart") or nextRoom
                                        if target:IsA("BasePart") or target:IsA("Model") then
                                                PivotToObj(char, target, Vector3.new(0, 3, 0))
                                        else
                                                char:PivotTo(CFrame.new(nextRoom:GetPivot().Position + Vector3.new(0, 5, 0)))
                                        end
                                end
                                break
                        end
                        if door:GetAttribute("Opened") == true then
                                VoidChar()
                                break
                        end
                        local hidden = door:FindFirstChild("Hidden") or door:WaitForChild("Hidden", 2)
                        if not hidden then
                                task.wait(0.3)
                                continue
                        end
                        while alive() and room.Parent and nextRoom.Parent and door.Parent and door:GetAttribute("Opened") ~= true do
                                local char = GetChar()
                                if char then PivotToObj(char, hidden) end
                                pcall(function() door.ClientOpen:Fire() end)
                                pcall(function() door.ClientOpen:FireServer() end)
                                task.wait()
                        end
                        if alive() and door.Parent and door:GetAttribute("Opened") == true then VoidChar() end
                        break
                end
                fmnProcessing[rn] = nil
        end

        local function CheckRooms()
                local lv = LatestRoomValue()
                local latest = tonumber(lv and lv.Value) or 0
                for rn = math.max(0, latest - 3), latest do
                        if not alive() then return end
                        local room = rooms:FindFirstChild(tostring(rn))
                        if room and not fmnProcessing[rn] then task.spawn(Run, room) end
                end
        end

        fmnConn = rooms.ChildAdded:Connect(function(room)
                if not tonumber(room.Name) then return end
                task.spawn(function()
                        task.wait(1)
                        if alive() and room.Parent then task.spawn(Run, room) end
                end)
        end)
        task.spawn(function()
                while alive() do
                        CheckRooms()
                        task.wait(1)
                end
        end)
        CheckRooms()
end

local waterParts, waterConn = {}, nil
local function SetWater(v)
        if waterConn then waterConn:Disconnect() waterConn = nil end
        if not v then
                for _, p in pairs(waterParts) do
                        if p then p:Destroy() end
                end
                table.clear(waterParts)
                return
        end
        local rooms = B.Rooms()
        if not rooms then return end

        local function ProcessRoom(room)
                if not tonumber(room.Name) then return end
                task.wait(3)
                if not Ex.BypassWater then return end
                local water = room:FindFirstChild("Water")
                if not water or waterParts[water] then return end
                local part = Instance.new("Part")
                part.Name = "WaterBypass"
                part.Anchored = true
                part.CanCollide = true
                part.CanTouch = false
                part.CanQuery = false
                part.Transparency = 0.25
                part.Color = Color3.fromRGB(0, 150, 255)
                part.Material = Enum.Material.ForceField
                local size, cf
                if water:IsA("BasePart") then
                        size, cf = water.Size, water.CFrame
                elseif water:IsA("Model") then
                        cf, size = water:GetBoundingBox()
                else
                        size, cf = Vector3.new(10, 1.5, 10), water:GetPivot()
                end
                part.Size = size + Vector3.new(0, 0.5, 0)
                part.CFrame = cf * CFrame.new(0, 0.25, 0)
                if part.Size.Y > 3 then
                        part:Destroy()
                        B.Toast("Electric Water", "Skipped one room: the water is too deep (would softlock you).")
                        return
                end
                part.Parent = room
                waterParts[water] = part
        end

        local lv = LatestRoomValue()
        local latest = tonumber(lv and lv.Value) or 0
        for rn = math.max(0, latest - 4), latest do
                local room = rooms:FindFirstChild(tostring(rn))
                if room then task.spawn(ProcessRoom, room) end
        end
        waterConn = rooms.ChildAdded:Connect(function(room) task.spawn(ProcessRoom, room) end)
end

local droneConn, droneParents = nil, {}
local prevDrones = Hooks.BypassDrones
Hooks.BypassDrones = function(v)
        if prevDrones then pcall(prevDrones, v) end
        local function Process(drones)
                local w = drones:FindFirstChild("WalkedInto") or drones:WaitForChild("WalkedInto", 3)
                if w and not droneParents[w] then
                        droneParents[w] = drones
                        w.Parent = RS
                end
        end
        if droneConn then droneConn:Disconnect() droneConn = nil end
        if v then
                for _, c in ipairs(Workspace:GetChildren()) do
                        if c.Name == "Drones" then task.spawn(Process, c) end
                end
                droneConn = Workspace.ChildAdded:Connect(function(c)
                        if c.Name == "Drones" then task.spawn(Process, c) end
                end)
        else
                for w, parent in pairs(droneParents) do
                        if w and w.Parent and parent and parent.Parent then w.Parent = parent end
                end
                table.clear(droneParents)
        end
end

local almaConn
local prevAlma = Hooks.BypassAlma
Hooks.BypassAlma = function(v)
        if prevAlma then pcall(prevAlma, v) end
        if almaConn then almaConn:Disconnect() almaConn = nil end
        if not v then return end
        for _, c in ipairs(Workspace:GetChildren()) do
                if c.Name == "Alma" then c:Destroy() end
        end
        almaConn = Workspace.ChildAdded:Connect(function(c)
                if c.Name == "Alma" then c:Destroy() end
        end)
end

local scribConn
local prevScrib = Hooks.NoScribblesDamage
Hooks.NoScribblesDamage = function(v)
        if prevScrib then pcall(prevScrib, v) end
        if scribConn then scribConn:Disconnect() scribConn = nil end
        if not v then return end
        scribConn = Workspace.ChildAdded:Connect(function(c)
                if c.Name == "Scribbles" and Ex.NoScribblesDamage then
                        local w = c:FindFirstChild("IfYoureExploitingDeleteThis")
                        if w then w:Destroy() end
                end
        end)
end

local fmnSeen = setmetatable({}, { __mode = "k" })
task.spawn(function()
        while true do
                task.wait(2.5)
                if (Ex.FMNAnomalyESP or Ex.FMNAnomalyNotify) and B.InMode("Archives") then
                        pcall(function()
                                local rooms = B.Rooms()
                                if not rooms then return end
                                local cur = B.CurRoom()
                                for _, n in ipairs({ cur - 1, cur, cur + 1 }) do
                                        local room = rooms:FindFirstChild(tostring(n))
                                        if room then
                                                for _, d in ipairs(room:GetDescendants()) do
                                                        if (d:IsA("Model") or d:IsA("BasePart")) and (d:GetAttribute("Anomaly") == true or (#d.Name < 40 and B.Has(d.Name, "anomal"))) then
                                                                if Ex.FMNAnomalyESP then
                                                                        B.Reg(d, { "entities", "objectives", "interactables" }, "FMN Anomaly", "Forget-Me-Nots")
                                                                end
                                                                if Ex.FMNAnomalyNotify and not fmnSeen[d] then
                                                                        fmnSeen[d] = true
                                                                        local r = B.RoomOf(d) or n
                                                                        local diff = r - B.CurRoom()
                                                                        local msg
                                                                        if diff < 0 then msg = "Go back " .. -diff .. " room" .. (diff == -1 and "" or "s")
                                                                        elseif diff > 0 then msg = "Go forward " .. diff .. " room" .. (diff == 1 and "" or "s")
                                                                        else msg = "It is in this room." end
                                                                        B.Toast("Forget-Me-Not anomaly", msg)
                                                                end
                                                        end
                                                end
                                        end
                                end
                        end)
                end
        end
end)

local STOP = { "close", "exit", "cancel", "quit", "leave", "back" }
task.spawn(function()
        while true do
                task.wait(0.25)
                if Ex.AutoAlmaMinigame then
                        pcall(function()
                                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                                if not pg then return end
                                local now = os.clock()
                                for _, g in ipairs(pg:GetDescendants()) do
                                        if (g:IsA("ScreenGui") or g:IsA("Frame")) and B.Has(g.Name, "alma") and (g:IsA("Frame") and g.Visible or g:IsA("ScreenGui") and g.Enabled) then
                                                for _, b in ipairs(g:GetDescendants()) do
                                                        if b:IsA("GuiButton") and b.Visible and (not lastFire[b] or now - lastFire[b] > 0.35) then
                                                                local t = (b:IsA("TextButton") and b.Text or b.Name):lower()
                                                                local skip = false
                                                                for _, w in ipairs(STOP) do
                                                                        if t:find(w, 1, true) then skip = true break end
                                                                end
                                                                if not skip then
                                                                        lastFire[b] = now
                                                                        B.Click(b)
                                                                end
                                                        end
                                                end
                                        end
                                end
                        end)
                end
        end
end)

local TICKET_ATTRS = { "Number", "Current", "Serving", "CurrentNumber", "Ticket", "Count", "TicketNumber" }

local function MyTicket()
        local function look(container)
                if not container then return nil end
                for _, t in ipairs(container:GetChildren()) do
                        if t:IsA("Tool") and B.Has(t.Name, "ticket") then
                                for _, k in ipairs(TICKET_ATTRS) do
                                        local v = t:GetAttribute(k)
                                        if type(v) == "number" then return v end
                                        if type(v) == "string" and tonumber(v) then return tonumber(v) end
                                end
                                local num = t.Name:match("%d+")
                                if num then return tonumber(num) end
                                local i = 0
                                for _, d in ipairs(t:GetDescendants()) do
                                        if d:IsA("TextLabel") then
                                                local n = tostring(d.Text):match("%d+")
                                                if n then return tonumber(n) end
                                        end
                                        i = i + 1
                                        if i > 60 then break end
                                end
                        end
                end
                return nil
        end
        return look(LocalPlayer.Character) or look(LocalPlayer:FindFirstChild("Backpack"))
end

local function TellerNow(m)
        for _, k in ipairs(TICKET_ATTRS) do
                local v = m:GetAttribute(k)
                if type(v) == "number" then return v end
        end
        local i = 0
        for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("NumberValue") or d:IsA("IntValue") then
                        local lk = d.Name:lower()
                        if lk:find("number", 1, true) or lk:find("current", 1, true) or lk:find("serving", 1, true) or lk:find("ticket", 1, true) then return d.Value end
                elseif d:IsA("TextLabel") then
                        local t = tostring(d.Text)
                        if t:find("^%s*%d+%s*$") then return tonumber(t) end
                end
                i = i + 1
                if i > 150 then break end
        end
        return nil
end

local lastNow = setmetatable({}, { __mode = "k" })
task.spawn(function()
        while true do
                task.wait(0.5)
                pcall(function()
                        for inst, e in pairs(Tracked) do
                                if e.Cat == "entities" and #inst.Name < 30 and B.Has(inst.Name, "teller") then
                                        if Ex.TellerNumber or Ex.TellerNotify then
                                                e.B8Label = e.B8Label or e.Label
                                                local now, mine = TellerNow(inst), MyTicket()
                                                if Ex.TellerNumber then
                                                        e.Label = (e.B8Label or "Teller") .. " [" .. (now and tostring(now) or "?") .. "/" .. (mine and tostring(mine) or "?") .. "]"
                                                end
                                                if Ex.TellerNotify and now and mine and now == mine and lastNow[inst] ~= now then
                                                        B.Toast("Teller", "Teller is on YOUR ticket (" .. mine .. ").")
                                                end
                                                lastNow[inst] = now
                                        end
                                        if not Ex.TellerNumber and e.B8Label then e.Label = e.B8Label end
                                end
                        end
                end)
        end
end)

ArchivesTab:Section({ Title = "Honcho" })
AddToggle(ArchivesTab, "HonchoESP", "ESP correct boxes", "Marks the boxes of the Honcho room that match a deposit, and the deposits themselves (needs ESP Items on). Also marks matching boxes that were dropped.", Ex.HonchoESP, function(v)
        Ex.HonchoESP = v
        if not v then pcall(HonchoESPClear) end
end)
AddToggle(ArchivesTab, "HonchoAutoDeposit", "Auto deposit", "When you hold a correct box and are within 10 studs of its deposit, the deposit prompt is triggered for you.", Ex.HonchoAutoDeposit, function(v) Ex.HonchoAutoDeposit = v end)
AddToggle(ArchivesTab, "HonchoAutoFull", "Auto Complete Honcho (experimental)", "Teleports to each correct box, picks it up and delivers it to its deposit, then returns you. Stops by itself when no box is left.", Ex.HonchoAutoFull, function(v)
        Ex.HonchoAutoFull = v
        honchoGen = honchoGen + 1
        if v then task.spawn(HonchoFullRun, honchoGen) end
end)

ArchivesTab:Section({ Title = "Exploits / Anti" })
AddToggle(ArchivesTab, "StopTimeStampede", "Stop Time / Anti-Stampede", "Keeps telling the clock that you looked at it, which stops the Drones Stampede from attacking you.", Ex.StopTimeStampede, function(v)
        Ex.StopTimeStampede = v
        if v then
                Loop("StopTimeStampede", function()
                        local remote = ResolveClockRemote()
                        if remote then remote:FireServer() end
                end, 0.5)
        end
end)
AddToggle(ArchivesTab, "TimeShower", "Time Shower", "Shows the Archives clock time at the bottom of the screen.", Ex.TimeShower, function(v) Ex.TimeShower = v end)
AddToggle(ArchivesTab, "AntiRansom", "Anti Ransom", "Deletes Ransom immediately when it spawns.", Ex.AntiRansom, function(v)
        Ex.AntiRansom = v
        SetRansom(v)
end)
AddToggle(ArchivesTab, "AntiClosetTrash", "Anti Closet Trash", "Deletes the trash that falls out of closets (binders, shoes, shelves).", Ex.AntiClosetTrash, function(v)
        Ex.AntiClosetTrash = v
        SetTrash(v)
end)
AddToggle(ArchivesTab, "BypassWater", "Bypass Electric Water", "Lays a safe platform over the electric water of every room. Position Spoof breaks this — keep it off.", Ex.BypassWater, function(v)
        Ex.BypassWater = v
        SetWater(v)
end)
AddToggle(ArchivesTab, "FMNSkipper", "Forget Me Not Skipper", "Triggers the Forget-Me-Not looks and opens the hidden door of the next room, then sends you to the void while it solves. Use with Anticheat Bypass.", Ex.FMNSkipper, function(v)
        Ex.FMNSkipper = v
        SetFMNSkipper(v)
end)

ArchivesTab:Section({ Title = "Forget-Me-Not" })
AddToggle(ArchivesTab, "FMNAnomalyESP", "Anomaly ESP", "Marks Forget-Me-Not anomalies (needs ESP Entities on).", Ex.FMNAnomalyESP, function(v) Ex.FMNAnomalyESP = v end)
AddToggle(ArchivesTab, "FMNAnomalyNotify", "Anomaly Notify", "Tells you to go back or forward (and how many rooms) when an anomaly is found.", Ex.FMNAnomalyNotify, function(v) Ex.FMNAnomalyNotify = v end)

ArchivesTab:Section({ Title = "Bypasses" })
AddToggle(ArchivesTab, "BypassDrones", "Bypass Drones", "Prevents 'Drones' from attacking you (removes their hit detector, disables touch parts and blocks ragdoll).", Ex.BypassDrones, function(v) Apply("BypassDrones", v) end)
AddToggle(ArchivesTab, "BypassAlma", "Bypass Alma", "Prevents 'Alma' from spawning (deletes it immediately when it appears).", Ex.BypassAlma, function(v) Apply("BypassAlma", v) end)
AddToggle(ArchivesTab, "NoScribblesDamage", "No Scribbles Damage", "Disables 'Scribbles' touch parts and removes the anti-exploit check. Use with Scribbles Bypass.", Ex.NoScribblesDamage, function(v) Apply("NoScribblesDamage", v) end)

StairwellTab:Section({ Title = "Protection" })
AddToggle(StairwellTab, "AntiNoise", "Anti Noise", "Mutes and hides 'Noise' and its TV, disables their touch parts so it cannot hurt you.", Ex.AntiNoise, function(v) Apply("AntiNoise", v) end)

ArchivesTab:Section({ Title = "Alma" })
AddToggle(ArchivesTab, "AutoAlmaMinigame", "Auto Alma Minigame", "Clicks the buttons on the Alma minigame screen automatically (when possible).", Ex.AutoAlmaMinigame, function(v) Ex.AutoAlmaMinigame = v end)

ArchivesTab:Section({ Title = "Teller" })
AddToggle(ArchivesTab, "TellerNumber", "Teller Number ESP", "Adds [current/your ticket] to the Teller ESP, e.g. [2/37].", Ex.TellerNumber, function(v) Ex.TellerNumber = v end)
AddToggle(ArchivesTab, "TellerNotify", "Notify Teller on my ticket", "Notifies you when Teller reaches your ticket number.", Ex.TellerNotify, function(v) Ex.TellerNotify = v end)

end)()

;(function()
local Lighting = game:GetService("Lighting")
local B = FX.B8

Ex.AntiLag = false
Ex.AntiLagLevel = "Balanced"

local LEVEL = {
        Balanced = { shadow = 45, fx = 90, extra = false, quality = nil },
        Strong   = { shadow = 25, fx = 50, extra = true,  quality = 6 },
}
local function Lv() return LEVEL[Ex.AntiLagLevel] or LEVEL.Balanced end

local Items = {}
local Off = setmetatable({}, { __mode = "k" })
local PostOff = setmetatable({}, { __mode = "k" })
local origQuality, conn = nil, nil
local gen = 0

local function Classify(d)
        if d:IsA("Light") then return "light" end
        if d:IsA("ParticleEmitter") then return "fx" end
        if d:IsA("Trail") or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then return "extra" end
        return nil
end

local function Track(d)
        local k = Classify(d)
        if not k then return end
        local ch = LocalPlayer.Character
        if ch and d:IsDescendantOf(ch) then return end
        Items[d] = k
end

local function PosOf(d)
        local p = d.Parent
        if not p then return nil end
        if p:IsA("BasePart") then return p.Position end
        if p:IsA("Attachment") then return p.WorldPosition end
        if p:IsA("Model") then
                local ok, cf = pcall(p.GetPivot, p)
                if ok and cf then return cf.Position end
        end
        return nil
end

local function SetFar(d, k, far)
        local prop = (k == "light") and "Shadows" or "Enabled"
        if far then
                if d[prop] then Off[d] = true d[prop] = false end
        elseif Off[d] then
                Off[d] = nil
                d[prop] = true
        end
end

local function SetPost(on)
        for _, p in ipairs(Lighting:GetChildren()) do
                if p:IsA("SunRaysEffect") or p:IsA("DepthOfFieldEffect") then
                        if on then
                                if p.Enabled then PostOff[p] = true p.Enabled = false end
                        elseif PostOff[p] then
                                PostOff[p] = nil
                                p.Enabled = true
                        end
                end
        end
end

local function SetQuality(on)
        pcall(function()
                local r = settings().Rendering
                local q = on and Lv().quality
                if q then
                        if origQuality == nil then origQuality = r.QualityLevel end
                        r.QualityLevel = Enum.QualityLevel["Level0" .. q]
                elseif origQuality ~= nil then
                        r.QualityLevel = origQuality
                        origQuality = nil
                end
        end)
end

local function Cycle()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local cp = cam.CFrame.Position
        local L = Lv()
        SetPost(L.extra)
        local arr = {}
        for d in pairs(Items) do arr[#arr + 1] = d end
        for i, d in ipairs(arr) do
                if not Ex.AntiLag then return end
                local k = Items[d]
                if not d.Parent then
                        Items[d] = nil
                        Off[d] = nil
                else
                        local pos = PosOf(d)
                        if pos then
                                local limit = (k == "light") and L.shadow or L.fx
                                if k == "extra" and not L.extra then limit = math.huge end
                                SetFar(d, k, (pos - cp).Magnitude > limit)
                        end
                end
                if i % 200 == 0 then task.wait() end
        end
end

local function ApplyLevel()
        if not Ex.AntiLag then return end
        SetQuality(true)
        SetPost(Lv().extra)
end

Hooks.AntiLag = function(v)
        gen = gen + 1
        local my = gen
        if v then
                task.spawn(function()
                        local n = 0
                        for _, d in ipairs(Workspace:GetDescendants()) do
                                if gen ~= my then return end
                                Track(d)
                                n = n + 1
                                if n % 600 == 0 then task.wait() end
                        end
                end)
                if not conn then
                        conn = Workspace.DescendantAdded:Connect(function(d) if Ex.AntiLag then Track(d) end end)
                end
                ApplyLevel()
                task.spawn(function()
                        while gen == my and Ex.AntiLag do
                                pcall(Cycle)
                                task.wait(0.4)
                        end
                end)
        else
                if conn then conn:Disconnect() conn = nil end
                local snap = {}
                for d in pairs(Off) do snap[#snap + 1] = d end
                for _, d in ipairs(snap) do
                        if d.Parent then
                                pcall(function()
                                        if d:IsA("Light") then d.Shadows = true else d.Enabled = true end
                                end)
                        end
                        Off[d] = nil
                end
                Items = {}
                SetPost(false)
                SetQuality(false)
        end
end

MiscTab:Section({ Title = "Performance" })
AddToggle(MiscTab, "AntiLag", "Anti-Lag", "Boosts FPS without removing textures and without changing the look up close: shadows of distant light sources and particles are paused and restored as you approach. Turning it off restores everything.", Ex.AntiLag, function(v) Apply("AntiLag", v) end)
AddDropdown(MiscTab, "AntiLagLevel", "Anti-Lag Level", "Balanced: only distant shadows and particles. Strong: closer limits, also pauses distant trails / beams / smoke, disables sun rays and depth of field, slightly lowers render quality.", { "Balanced", "Strong" }, Ex.AntiLagLevel, function(v)
        if type(v) == "table" then v = v[1] end
        if v and LEVEL[v] then Ex.AntiLagLevel = v ApplyLevel() end
end)

local RS = game:GetService("ReplicatedStorage")
local ANTI = {
        BypassDrones        = { tokens = { "drone" },              module = true },
        BypassAlma          = { tokens = { "alma" },               module = false },
        NoScribblesDamage   = { tokens = { "scribble", "a120" },   module = true },
        AntiNoise           = { tokens = { "noise" },              module = true },
}
local function Cmp(s) return (tostring(s or ""):lower():gsub("[^%w]", "")) end
local function Match(name, tokens)
        local c = Cmp(name)
        for _, t in ipairs(tokens) do
                if c:find(t, 1, true) then return true end
        end
        return false
end
local function ModulesFolder()
        local cm = RS:FindFirstChild("ModulesClient") or RS:FindFirstChild("ClientModules")
        return cm and cm:FindFirstChild("EntityModules")
end
local function Rem() return RS:FindFirstChild("RemotesFolder") or RS:FindFirstChild("EntityInfo") or RS:FindFirstChild("Bricks") end

local Saved = {}
local function Engage(id, on)
        local cfg = ANTI[id]
        local s = Saved[id]
        if not s then s = { mods = {}, rems = {} } Saved[id] = s end
        if on then
                if cfg.module then
                        local f = ModulesFolder()
                        if f then
                                for _, m in ipairs(f:GetChildren()) do
                                        if not s.mods[m] and not m.Name:find("_Disabled", 1, true) and Match(m.Name, cfg.tokens) then
                                                s.mods[m] = m.Name
                                                m.Name = m.Name .. "_Disabled"
                                        end
                                end
                        end
                end
                local rf = Rem()
                if rf then
                        for _, r in ipairs(rf:GetChildren()) do
                                if (r:IsA("BaseRemoteEvent") or r:IsA("RemoteFunction")) and not s.rems[r] and not Cmp(r.Name):find("exploiter", 1, true) and Match(r.Name, cfg.tokens) then
                                        local fake = Instance.new(r.ClassName)
                                        fake.Name = r.Name
                                        s.rems[r] = fake
                                        fake.Parent = rf
                                        r.Parent = nil
                                end
                        end
                end
        else
                for m, orig in pairs(s.mods) do
                        if m.Parent then m.Name = orig end
                        s.mods[m] = nil
                end
                for r, fake in pairs(s.rems) do
                        r.Parent = fake.Parent or Rem()
                        fake:Destroy()
                        s.rems[r] = nil
                end
        end
end

for id in pairs(ANTI) do
        local prev = Hooks[id]
        Hooks[id] = function(v)
                if prev then pcall(prev, v) end
                pcall(Engage, id, v == true)
        end
end
task.spawn(function()
        while true do
                task.wait(3)
                for id in pairs(ANTI) do
                        if Ex[id] then pcall(Engage, id, true) end
                end
        end
end)

end)()

print("[AMBUSH HUB] Loading Batch 12")
;(function()
local RS = game:GetService("ReplicatedStorage")
local RunSvc = game:GetService("RunService")
local function Toast(t, d) pcall(FX.ShowToast, t, d or "", "", Color3.fromRGB(255, 200, 80)) end

Ex.CustomFOV = false
Ex.FOVValue = 70
Ex.ThirdPerson = false
Ex.TPOffsetX = 2
Ex.TPOffsetY = 1
Ex.TPOffsetZ = 5
Ex.NoCamShake = false
Ex.NoCamBob = false
Ex.TransHide = false
Ex.TransHideValue = 50
Ex.NoHideVignette = false
Ex.NoGlitchJumpscare = false
Ex.NoTimothyJumpscare = false
Ex.NoVoidJumpscare = false
Ex.NoJamMusic = false
Ex.NoPromptSounds = false
Ex.AutoTpNextDoor = false

local function MainUI()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        return pg and pg:FindFirstChild("MainUI")
end
local function MainGameScript()
        local ui = MainUI()
        local ini = ui and ui:FindFirstChild("Initiator")
        return ini and ini:FindFirstChild("Main_Game")
end

local mgCache, mgScript
local function MainGame()
        local sc = MainGameScript()
        if not sc then return nil end
        if mgCache and mgScript == sc then return mgCache end
        mgScript = sc
        mgCache = nil
        if require then
                local ok, m = pcall(require, sc)
                if ok and type(m) == "table" then mgCache = m end
        end
        return mgCache
end

local function Remote(name)
        local rf = RS:FindFirstChild("RemotesFolder")
        return rf and rf:FindFirstChild(name)
end

local confirmAt = {}
local function Confirm(key, label)
        local now = os.clock()
        if confirmAt[key] and now - confirmAt[key] < 3 then
                confirmAt[key] = nil
                return true
        end
        confirmAt[key] = now
        Toast(label, "Press the button again within 3 seconds to confirm.")
        return false
end

local tpParts, tpChar, tpWasOn = {}, nil, false
local function RefreshTPParts(char)
        table.clear(tpParts)
        tpChar = char
        if not char then return end
        for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("Accessory") then
                        local h = d:FindFirstChild("Handle")
                        if h and h:IsA("BasePart") then tpParts[#tpParts + 1] = h end
                end
        end
        local head = char:FindFirstChild("Head")
        if head then tpParts[#tpParts + 1] = head end
end

RunSvc.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        if Ex.NoCamShake or Ex.NoCamBob or Ex.CustomFOV then
                local usedModule = false
                pcall(function()
                        local m = MainGame()
                        if not m then return end
                        usedModule = true
                        if Ex.NoCamShake then m.csgo = CFrame.new() end
                        if Ex.NoCamBob and m.spring and m.spring.Speed ~= 9e9 then m.spring.Speed = 9e9 end
                        if Ex.CustomFOV then m.fovtarget = Ex.FOVValue end
                end)
                if Ex.CustomFOV and not usedModule then cam.FieldOfView = Ex.FOVValue end
        end
        pcall(function()
                if Ex.ThirdPerson then
                        local char = LocalPlayer.Character
                        if char ~= tpChar then RefreshTPParts(char) end
                        cam.CFrame = cam.CFrame * CFrame.new(Ex.TPOffsetX, Ex.TPOffsetY, Ex.TPOffsetZ)
                        for _, p in ipairs(tpParts) do
                                if p.Parent then
                                        p.Transparency = 0
                                        p.LocalTransparencyModifier = 0
                                end
                        end
                        tpWasOn = true
                elseif tpWasOn then
                        tpWasOn = false
                        for _, p in ipairs(tpParts) do
                                if p.Parent then
                                        p.Transparency = 1
                                        p.LocalTransparencyModifier = 1
                                end
                        end
                end
        end)
end)

local thSpot, thOrig, thLastScan = nil, {}, 0
local function THRestore()
        for p, t in pairs(thOrig) do
                if p.Parent then p.Transparency = t end
        end
        table.clear(thOrig)
        thSpot = nil
end
local function THFind(char)
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        if not rooms then return nil end
        local cur = rooms:FindFirstChild(tostring(LocalPlayer:GetAttribute("CurrentRoom")))
        local roots = cur and { cur } or rooms:GetChildren()
        for _, root in ipairs(roots) do
                for _, d in ipairs(root:GetDescendants()) do
                        if d.Name == "HiddenPlayer" and d:IsA("ObjectValue") and d.Value == char then
                                return d.Parent
                        end
                end
        end
        return nil
end
task.spawn(function()
        while true do
                task.wait(0.25)
                pcall(function()
                        local char = LocalPlayer.Character
                        local hiding = Ex.TransHide and char ~= nil and char:GetAttribute("Hiding") == true
                        if hiding then
                                if not (thSpot and thSpot.Parent) and os.clock() - thLastScan > 1.5 then
                                        thLastScan = os.clock()
                                        thSpot = THFind(char)
                                end
                                if thSpot and thSpot.Parent then
                                        local a = Ex.TransHideValue / 100
                                        for _, d in ipairs(thSpot:GetDescendants()) do
                                                if d:IsA("BasePart") then
                                                        if thOrig[d] == nil then thOrig[d] = d.Transparency end
                                                        if thOrig[d] < 1 then d.Transparency = math.max(thOrig[d], a) end
                                                end
                                        end
                                end
                        elseif thSpot or next(thOrig) ~= nil then
                                THRestore()
                        end
                end)
        end
end)

local vigOrig = {}
local function FindVignette()
        local ui = MainUI()
        if not ui then return nil end
        local v = ui:FindFirstChild("HideVignette")
        if not v then
                local mf = ui:FindFirstChild("MainFrame")
                v = mf and mf:FindFirstChild("HideVignette")
        end
        if v and v:IsA("GuiObject") then return v end
        return nil
end
local function VignetteStep()
        if Ex.NoHideVignette then
                local v = FindVignette()
                if v then
                        if vigOrig[v] == nil then vigOrig[v] = v.Visible end
                        v.Visible = false
                end
        elseif next(vigOrig) ~= nil then
                for v, o in pairs(vigOrig) do
                        if v.Parent then v.Visible = o end
                end
                table.clear(vigOrig)
        end
end

local function EntityModules()
        local cm = RS:FindFirstChild("ModulesClient") or RS:FindFirstChild("ClientModules")
        return cm and cm:FindFirstChild("EntityModules")
end
local function SetModules(names, on)
        local f = EntityModules()
        if not f then
                Toast("Jumpscares", "Entity modules were not found.")
                return
        end
        for _, m in ipairs(f:GetChildren()) do
                if m:IsA("ModuleScript") then
                        local orig = m:GetAttribute("R4NOrig12") or m.Name
                        for _, n in ipairs(names) do
                                if orig == n then
                                        if on then
                                                m:SetAttribute("R4NOrig12", orig)
                                                m.Name = orig .. "_Disabled"
                                        else
                                                m.Name = orig
                                                m:SetAttribute("R4NOrig12", nil)
                                        end
                                        break
                                end
                        end
                end
        end
end

local audioOrig = setmetatable({}, { __mode = "k" })
local function SetVol(snd, on)
        if not (snd and snd:IsA("Sound")) then return end
        if on then
                if audioOrig[snd] == nil then audioOrig[snd] = snd.Volume end
                snd.Volume = 0
        elseif audioOrig[snd] ~= nil then
                snd.Volume = audioOrig[snd]
                audioOrig[snd] = nil
        end
end
local function ApplyAudio()
        local sc = MainGameScript()
        if not sc then return end
        local health = sc:FindFirstChild("Health")
        SetVol(health and health:FindFirstChild("Jam"), Ex.NoJamMusic)
        local ps = sc:FindFirstChild("PromptService")
        if ps then
                SetVol(ps:FindFirstChild("Triggered"), Ex.NoPromptSounds)
                SetVol(ps:FindFirstChild("Holding"), Ex.NoPromptSounds)
                SetVol(ps:FindFirstChild("Notification"), Ex.NoPromptSounds)
        end
        local rem = sc:FindFirstChild("Reminder")
        SetVol(rem and rem:FindFirstChild("Caption"), Ex.NoPromptSounds)
end

task.spawn(function()
        while true do
                task.wait(0.5)
                pcall(function()
                        if Ex.NoJamMusic or Ex.NoPromptSounds then ApplyAudio() end
                        if Ex.NoHideVignette then VignetteStep() end
                end)
        end
end)

local function NextClosedDoor()
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        local gd = RS:FindFirstChild("GameData")
        local lv = gd and gd:FindFirstChild("LatestRoom")
        if not (rooms and lv) then return nil end
        local best, bestN = nil, math.huge
        for _, room in ipairs(rooms:GetChildren()) do
                local n = tonumber(room.Name)
                if n and n >= lv.Value and n < bestN then
                        local door = room:FindFirstChild("Door")
                        if door and door:GetAttribute("Opened") ~= true and door:GetAttribute("Open") ~= true then
                                best, bestN = door, n
                        end
                end
        end
        return best
end
local function TpNextDoor()
        local door = NextClosedDoor()
        if not door then return false end
        local cf = door:GetPivot() * CFrame.new(0, -1, 0)
        local B8 = FX.B8
        if B8 and B8.SafeTP then return B8.SafeTP(cf) end
        local char = LocalPlayer.Character
        if char then
                char:PivotTo(cf)
                return true
        end
        return false
end
local doorGen = 0
local function SetAutoDoor(v)
        doorGen = doorGen + 1
        local my = doorGen
        if not v then return end
        task.spawn(function()
                while Ex.AutoTpNextDoor and doorGen == my do
                        pcall(TpNextDoor)
                        task.wait(0.6)
                end
        end)
end

VisualsTab:Section({ Title = "Camera" })
AddToggle(VisualsTab, "CustomFOV", "Custom FOV", "Applies the Field of View slider below. Turn off to go back to normal FOV.", Ex.CustomFOV, function(v) Ex.CustomFOV = v end)
AddSlider(VisualsTab, "FOVValue", "Field of View", "Camera field of view (1 - 120).", 1, 120, Ex.FOVValue, function(v) Ex.FOVValue = v end)
AddToggle(VisualsTab, "ThirdPerson", "Third Person", "Moves the camera behind the character so you can see yourself. Offsets below.", Ex.ThirdPerson, function(v) Ex.ThirdPerson = v end)
AddSlider(VisualsTab, "TPOffsetX", "Third Person X Offset", "Left / right.", -10, 10, Ex.TPOffsetX, function(v) Ex.TPOffsetX = v end)
AddSlider(VisualsTab, "TPOffsetY", "Third Person Y Offset", "Up / down.", -10, 10, Ex.TPOffsetY, function(v) Ex.TPOffsetY = v end)
AddSlider(VisualsTab, "TPOffsetZ", "Third Person Z Offset", "Distance behind you.", -10, 10, Ex.TPOffsetZ, function(v) Ex.TPOffsetZ = v end)
AddToggle(VisualsTab, "NoCamShake", "Remove Camera Shake", "Stops the camera from shaking.", Ex.NoCamShake, function(v) Ex.NoCamShake = v end)
AddToggle(VisualsTab, "NoCamBob", "Remove Camera Bobbing", "Stops the camera from bobbing while moving.", Ex.NoCamBob, function(v)
        Ex.NoCamBob = v
        pcall(function()
                local m = MainGame()
                if m and m.spring then m.spring.Speed = v and 9e9 or 8 end
        end)
end)

VisualsTab:Section({ Title = "Effects" })
AddToggle(VisualsTab, "TransHide", "Transparent Hiding Spots", "Makes the hideout you are in transparent.", Ex.TransHide, function(v) Ex.TransHide = v end)
AddSlider(VisualsTab, "TransHideValue", "Hideout transparency (%)", "How transparent the hideout becomes (0 - 100).", 0, 100, Ex.TransHideValue, function(v) Ex.TransHideValue = v end)
AddToggle(VisualsTab, "NoHideVignette", "Disable Hide Vignette", "Removes the dark screen effect while hiding.", Ex.NoHideVignette, function(v)
        Ex.NoHideVignette = v
        pcall(VignetteStep)
end)
AddToggle(VisualsTab, "NoGlitchJumpscare", "Disable Glitch Jumpscare", "Disables the Glitch jumpscare.", Ex.NoGlitchJumpscare, function(v)
        Ex.NoGlitchJumpscare = v
        pcall(SetModules, { "Glitch" }, v)
end)
AddToggle(VisualsTab, "NoTimothyJumpscare", "Disable Timothy Jumpscare", "Disables the Timothy jumpscare.", Ex.NoTimothyJumpscare, function(v)
        Ex.NoTimothyJumpscare = v
        pcall(SetModules, { "SpiderJumpscare" }, v)
end)
AddToggle(VisualsTab, "NoVoidJumpscare", "Disable Void Jumpscare", "Disables the Void jumpscare.", Ex.NoVoidJumpscare, function(v)
        Ex.NoVoidJumpscare = v
        pcall(SetModules, { "Void" }, v)
end)

MiscTab:Section({ Title = "Audio" })
AddToggle(MiscTab, "NoJamMusic", "Remove Jammin Music", "Mutes the music of the Jammin modifier.", Ex.NoJamMusic, function(v)
        Ex.NoJamMusic = v
        pcall(ApplyAudio)
end)
AddToggle(MiscTab, "NoPromptSounds", "Remove Interacting Sounds", "Mutes the sounds of proximity prompts.", Ex.NoPromptSounds, function(v)
        Ex.NoPromptSounds = v
        pcall(ApplyAudio)
end)

MiscTab:Section({ Title = "Run" })
MiscTab:Button({ Title = "Play Again", Desc = "Starts a new run. Click twice to confirm.", Callback = function()
        if not Confirm("again", "Play Again") then return end
        local r = Remote("PlayAgain")
        if r then pcall(function() r:FireServer() end) else Toast("Play Again", "Remote not found.") end
end })
MiscTab:Button({ Title = "Return to Lobby", Desc = "Returns you to the lobby. Click twice to confirm.", Callback = function()
        if not Confirm("lobby", "Return to Lobby") then return end
        local r = Remote("Lobby")
        if r then pcall(function() r:FireServer() end) else Toast("Return to Lobby", "Remote not found.") end
end })
MiscTab:Button({ Title = "Exit Closet", Desc = "Lets you out of the closet / hideout you are in.", Callback = function()
        local r = Remote("CamLock")
        if r then pcall(function() r:FireServer() end) else Toast("Exit Closet", "Remote not found.") end
end })
MiscTab:Button({ Title = "Tp to next door", Desc = "Teleports you to the next closed door.", Callback = function()
        if not TpNextDoor() then Toast("Tp Next Door", "No closed door found.") end
end })
AddToggle(MiscTab, "AutoTpNextDoor", "Auto Tp Next Door", "Keeps teleporting you to the next closed door. Can trigger the anticheat: use it with the Anticheat Bypass.", Ex.AutoTpNextDoor, function(v)
        Ex.AutoTpNextDoor = v
        SetAutoDoor(v)
end)
end)()

print("[AMBUSH HUB] Loaded more UI")
print("[AMBUSH HUB] Loading Keybinds Tab")
KeybindsTab:Section({ Title = "Menu" })
AddKeybind(KeybindsTab, "Key_Hub", "Open / close menu", "Shows or hides this menu with one key (default: Right Shift).", Ex.Key_Hub)
KeybindsTab:Section({ Title = "Movement & Anticheat Manipulator" })
AddKeybind(KeybindsTab, "Key_ACM", "Anticheat Manipulator", "Toggles the Anticheat Manipulator (Velocity manipulation).", Ex.Key_ACM)
AddKeybind(KeybindsTab, "Key_Noclip", "Noclip", "Toggles Noclip.", Ex.Key_Noclip)
AddKeybind(KeybindsTab, "Key_Fly", "Fly", "Toggles fly.", Ex.Key_Fly)
AddKeybind(KeybindsTab, "Key_Speed", "Speed", "Toggles speed.", Ex.Key_Speed)
AddKeybind(KeybindsTab, "Key_SpeedHack", "Speed Hack", "Toggles Speed Hack (real walk speed). Mobile has a floating SPD button.", Ex.Key_SpeedHack)
AddKeybind(KeybindsTab, "Key_TimerToggle", "Timer: Start / Pause", "Starts, pauses or resumes the speedrun timer.", Ex.Key_TimerToggle)
AddKeybind(KeybindsTab, "Key_TimerStop", "Timer: Stop", "Finishes the speedrun timer run.", Ex.Key_TimerStop)
AddKeybind(KeybindsTab, "Key_TimerReset", "Timer: Reset", "Resets the speedrun timer.", Ex.Key_TimerReset)
AddKeybind(KeybindsTab, "Key_Slide", "Slide", "Performs a slide (Slide must be on in the Player tab).", Ex.Key_Slide)
AddKeybind(KeybindsTab, "Key_PosSpoof", "Position Spoof", "Toggles position spoof.", Ex.Key_PosSpoof)
AddKeybind(KeybindsTab, "Key_RestorePrompts", "Restore prompts", "Restores prompts that stopped showing up.", Ex.Key_RestorePrompts)

MiscTab:Section({ Title = "Movement Diagnostics" })
MiscTab:Button({
    Title = "Copy character info",
    Desc = "Copies character attributes, Humanoid values and any remotes with jump/slide/crouch/speed in their names. Send it if Jump or Slide misbehave in your mode.",
    Callback = function()
        local out = {}
        local char = LocalPlayer.Character
        for _, pair in ipairs({ { "Character", char }, { "Player", LocalPlayer } }) do
            if pair[2] then
                for k, v in pairs(pair[2]:GetAttributes()) do
                    out[#out + 1] = string.format("%s attr %s = %s", pair[1], k, tostring(v))
                end
            end
        end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            out[#out + 1] = string.format("Humanoid WalkSpeed=%s JumpPower=%s JumpHeight=%s UseJumpPower=%s",
                tostring(hum.WalkSpeed), tostring(hum.JumpPower), tostring(hum.JumpHeight), tostring(hum.UseJumpPower))
        end
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("BindableEvent") then
                local l = d.Name:lower()
                if l:find("jump", 1, true) or l:find("slide", 1, true) or l:find("crouch", 1, true) or l:find("speed", 1, true) then
                    out[#out + 1] = d.ClassName .. " " .. d:GetFullName()
                end
            end
        end
        local text = #out > 0 and table.concat(out, "\n") or "(nothing found)"
        if setclipboard then
            setclipboard(text)
            WindUI:Notify({ Title = "Debug", Content = "Copied lines: " .. #out .. ".", Duration = 3 })
        else
            print(text)
            WindUI:Notify({ Title = "Debug", Content = "No clipboard support; printed to the console.", Duration = 3 })
        end
    end
})

FX.UpdateButtons()

print("[AMBUSH HUB] Loaded Keybinds Tab")
;(function()
local PathSvc = game:GetService("PathfindingService")
local RSv = game:GetService("ReplicatedStorage")
local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)

local function NewTries() return setmetatable({}, { __mode = "k" }) end
local AD = {
    Gen = 0, Turned = {}, Tries = NewTries(), Info = "Off", Room = nil, RoomT = 0,
    Progress = os.clock(), Beat = os.clock(), Stuck = 0, Errors = 0, RecoverWhy = nil,
    WantKey = false, KeyWaitSince = nil, KeyReset = 0, NoLootUntil = 0,
    DoorFails = 0, WasDead = false, Running = false, Active = false,
    Look = nil, CamRot = nil, Crouching = false, Sneak = false, LastExit = 0, LastLatest = nil,
    KnobDone = false, OrigWS = nil, FigureT = 0, FigureNear = false, SpoofVoted = false,
    Ent = setmetatable({}, { __mode = "k" }),
    Spots = setmetatable({}, { __mode = "k" }),
    BadSpot = setmetatable({}, { __mode = "k" }),
    Stats = { Doors = 0, Loot = 0, Fixes = 0, Hides = 0, Start = os.clock() },
}
R4N_AD = AD

local OPTS = { "AD_Doors", "AD_Gold", "AD_Drawers", "AD_Chests", "AD_Keys", "AD_Items", "AD_Avoid", "AD_Puzzles", "AD_SkipSeek" }
local REC = {
    Hotel     = { "AD_Doors", "AD_Gold", "AD_Drawers", "AD_Chests", "AD_Keys", "AD_Items", "AD_Avoid", "AD_Puzzles", "AD_SkipSeek" },
    Mines     = { "AD_Doors", "AD_Gold", "AD_Drawers", "AD_Chests", "AD_Keys", "AD_Items", "AD_Avoid", "AD_Puzzles", "AD_SkipSeek" },
    Backdoor  = { "AD_Doors", "AD_Gold", "AD_Keys", "AD_Items", "AD_Avoid" },
    Outdoors  = { "AD_Doors", "AD_Gold", "AD_Items", "AD_Avoid" },
    Rooms     = { "AD_Doors", "AD_Avoid" },
    Stairwell = { "AD_Doors", "AD_Gold", "AD_Items", "AD_Avoid" },
    Archives  = { "AD_Doors", "AD_Gold", "AD_Keys", "AD_Items", "AD_Avoid" },
}
local PROFILES = {
    ["Safe"]     = { opts = { "AD_Doors", "AD_Gold", "AD_Keys", "AD_Avoid", "AD_Puzzles", "AD_SkipSeek" },
                     AD_Delay = 600, AD_RoomTime = 20, AD_Retries = 2, AD_StuckTime = 20, AD_MaxHide = 60, Bot_Speed = 18 },
    ["Balanced"] = { opts = OPTS, AD_Delay = 350, AD_RoomTime = 30, AD_Retries = 3, AD_StuckTime = 15, AD_MaxHide = 40, Bot_Speed = 22 },
    ["Fast"]     = { opts = { "AD_Doors", "AD_Gold", "AD_Keys", "AD_Avoid", "AD_Puzzles", "AD_SkipSeek" },
                     AD_Delay = 150, AD_RoomTime = 12, AD_Retries = 2, AD_StuckTime = 12, AD_MaxHide = 40, Bot_Speed = 32 },
    ["Speedrun"] = { opts = { "AD_Doors", "AD_Keys", "AD_Avoid", "AD_Puzzles", "AD_SkipSeek" },
                     AD_Delay = 100, AD_RoomTime = 5, AD_Retries = 1, AD_StuckTime = 10, AD_MaxHide = 40, Bot_Speed = 45 },
    ["Max Loot"] = { opts = OPTS, AD_Delay = 400, AD_RoomTime = 60, AD_Retries = 4, AD_StuckTime = 20, AD_MaxHide = 40, Bot_Speed = 22 },
}
local NUMS = { "AD_Delay", "AD_RoomTime", "AD_Retries", "AD_StuckTime", "AD_MaxHide", "Bot_Speed" }

local DANGER = {
    RushMoving = true, AmbushMoving = true, A60 = true, A120 = true, GlitchRush = true,
    GlitchAmbush = true, BackdoorRush = true,
}
local BASE_SPEED = {
    RushMoving = 75, AmbushMoving = 95, A60 = 95, A120 = 95, GlitchRush = 80, GlitchAmbush = 100, BackdoorRush = 75,
}
local REBOUND = { AmbushMoving = true, GlitchAmbush = true }
local KIND = {
    gold = "AD_Gold", stardust = "AD_Gold", keys = "AD_Keys", drawers = "AD_Drawers",
    chests = "AD_Chests", lockers = "AD_Chests", items = "AD_Items",
}
local KNOB = { gold = true, stardust = true, drawers = true, chests = true, lockers = true }
local PRIO = { keys = 0, gold = 1, stardust = 1 }
local PRIO_LABEL = "Keys & Gold First"

local function Say(text, force)
    if not force and Ex.AD_Notify == false then return end
    pcall(function() WindUI:Notify({ Title = "Auto Doors", Content = text, Duration = 4 }) end)
end
local function Clock(s)
    s = math.max(0, math.floor(s))
    return string.format("%02d:%02d", math.floor(s / 60), s % 60)
end
local function StatsLine()
    local s = AD.Stats
    return string.format("Doors %d | Looted %d | Hides %d | Fixes %d | Time %s", s.Doors, s.Loot, s.Hides, s.Fixes, Clock(os.clock() - s.Start))
end
local function Mark() AD.Progress = os.clock() AD.Stuck = 0 end
local function Idle() AD.Progress = os.clock() end
local function Alive(g) return Ex.AutoDoors == true and AD.Gen == g end

local function ModeNm()
    local n = Mode.Name
    if n == "Fools" then n = "Hotel" end
    return n
end
local function CurRoom() return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) end
local function Latest()
    local gd = RSv:FindFirstChild("GameData")
    local lv = gd and gd:FindFirstChild("LatestRoom")
    return lv and lv.Value
end
local function RoomsFolder() return Workspace:FindFirstChild("CurrentRooms") end
local function RoomOf(inst)
    local rooms = RoomsFolder()
    local cur = inst
    while cur and cur.Parent do
        if cur.Parent == rooms then return tonumber(cur.Name) end
        cur = cur.Parent
    end
    return nil
end
local function HasItem(name)
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    return (char and char:FindFirstChild(name)) or (bp and bp:FindFirstChild(name)) or nil
end
local function NextClosedDoor()
    local rooms = RoomsFolder()
    local lv = Latest()
    if not (rooms and lv) then return nil end
    local best, bestN = nil, math.huge
    for _, room in ipairs(rooms:GetChildren()) do
        local n = tonumber(room.Name)
        if n and n >= lv and n < bestN then
            local door = room:FindFirstChild("Door")
            if door and door:GetAttribute("Opened") ~= true and door:GetAttribute("Open") ~= true then
                best, bestN = door, n
            end
        end
    end
    return best
end
local function ExitCloset()
    local rf = RSv:FindFirstChild("RemotesFolder")
    local cl = rf and rf:FindFirstChild("CamLock")
    if cl and cl:IsA("RemoteEvent") then pcall(function() cl:FireServer() end) end
end
local function Gold()
    local ok, v = pcall(function()
        return LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Gold.GoldVal.Value
    end)
    return ok and v or nil
end

local function Need(id)
    if Ex[id] ~= true then
        AD.Turned[id] = true
        SetFeature(id, true)
    end
end
local function Release()
    for id in pairs(AD.Turned) do pcall(SetFeature, id, false) end
    AD.Turned = {}
end

local function Sync()
    local m = ModeNm()
    if m == "Rooms" then
        Need("RoomsAutoWalk")
        return true
    end
    if Ex.Bot_Jump ~= false then Need("Jump") end
    if Ex.AD_Avoid and m == "Hotel" then Need("AutoHeartbeatMinigame") end
    if Ex.AD_SkipSeek then
        if m == "Hotel" then Need("SkipSeekHotel") elseif m == "Mines" then Need("SkipSeekMines") end
    end
    if Ex.AD_Puzzles then
        if m == "Hotel" then
            Need("AutoLibrary")
            Need("AutoUnlockPadlockToggle")
            Need("AutoBreakerRoom")
        elseif m == "Mines" then
            Need("AutoSolveAnchors")
        end
    end
    return false
end

AD.Recommended = function(announce)
    local m = ModeNm()
    local list = REC[m] or REC.Hotel
    local want = {}
    for _, k in ipairs(list) do want[k] = true end
    for _, k in ipairs(OPTS) do SetFeature(k, want[k] == true) end
    if announce then Say("Recommended setup for " .. m .. " applied.", true) end
end

AD.ApplyProfile = function(name, announce)
    local p = PROFILES[name]
    if not p then return end
    local allowed = {}
    for _, k in ipairs(REC[ModeNm()] or REC.Hotel) do allowed[k] = true end
    local want = {}
    for _, k in ipairs(p.opts) do want[k] = true end
    for _, k in ipairs(OPTS) do SetFeature(k, want[k] == true and allowed[k] == true) end
    for _, k in ipairs(NUMS) do
        Ex[k] = p[k]
        if Setters[k] then Setters[k](p[k]) end
    end
    if announce then Say("Profile '" .. name .. "' applied for " .. ModeNm() .. ".", true) end
end

AD.Status = function()
    Say(string.format("Mode: %s | Room: %s | %s\n%s", ModeNm(), tostring(CurRoom() or "?"),
        tostring(AD.Info or (Ex.AutoDoors and "Running" or "Off")), StatsLine()), true)
end

AD.ResetStats = function()
    AD.Stats = { Doors = 0, Loot = 0, Fixes = 0, Hides = 0, Start = os.clock() }
    Say("Statistics reset.", true)
end

local HUD
AD.UpdateHUD = function()
    local show = Ex.AD_HUD == true and Ex.AutoDoors == true
    if not show then
        if HUD then HUD.Visible = false end
        return
    end
    if not (HUD and HUD.Parent) then
        local l = Instance.new("TextLabel")
        l.Name = "RON_AutoDoorsHUD"
        l.BackgroundColor3 = Color3.new(0, 0, 0)
        l.BackgroundTransparency = 0.35
        l.BorderSizePixel = 0
        l.TextColor3 = Color3.fromRGB(235, 235, 235)
        l.Font = Enum.Font.Code
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.TextWrapped = true
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.Size = UDim2.fromOffset(250, 10)
        l.AnchorPoint = Vector2.new(1, 0)
        l.Position = UDim2.new(1, -8, 0, 70)
        local pad = Instance.new("UIPadding")
        pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
        pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
        pad.Parent = l
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = l
        l.Parent = Gui
        HUD = l
    end
    HUD.Visible = true
    HUD.Text = string.format("AUTO DOORS BOT  [ON]\nMode:  %s\nRoom:  %s\nState: %s\n%s",
        ModeNm(), tostring(CurRoom() or "?"), tostring(AD.Info or "-"), StatsLine())
end

pcall(function() RunService:UnbindFromRenderStep("R4N_BotCam") end)
RunService:BindToRenderStep("R4N_BotCam", Enum.RenderPriority.Camera.Value + 2, function(dt)
    if not (AD.Active and Ex.Bot_Camera ~= false and AD.Look) then AD.CamRot = nil return end
    local char = LocalPlayer.Character
    local cam = Workspace.CurrentCamera
    if not char or not cam or char:GetAttribute("Hiding") then AD.CamRot = nil return end
    local pos = cam.CFrame.Position
    local dir = AD.Look - pos
    if dir.Magnitude < 0.6 then return end
    local goal = CFrame.lookAt(pos, pos + dir).Rotation
    local cur = AD.CamRot or cam.CFrame.Rotation
    cur = cur:Lerp(goal, 1 - math.exp(-dt * (Ex.Bot_CamSpeed or 9)))
    AD.CamRot = cur
    cam.CFrame = CFrame.new(pos) * cur
end)

local RayP = RaycastParams.new()
RayP.FilterType = Enum.RaycastFilterType.Exclude
RayP.RespectCanCollide = true

AD.MoveDir = nil
pcall(function() RunService:UnbindFromRenderStep("R4N_BotMove") end)
RunService:BindToRenderStep("R4N_BotMove", Enum.RenderPriority.Input.Value + 2, function()
    local d = AD.MoveDir
    if not d or Ex.AutoDoors ~= true then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 and not char:GetAttribute("Hiding") then
        hum:Move(d, false)
    end
end)

local function Ground(pos)
    RayP.FilterDescendantsInstances = { LocalPlayer.Character }
    local hit = Workspace:Raycast(pos + Vector3.new(0, 5, 0), Vector3.new(0, -22, 0), RayP)
    if hit then return hit.Position end
    return pos - Vector3.new(0, 3, 0)
end

local function SetCrouch(on)
    if Ex.Bot_Crouch == false then on = false end
    if AD.Crouching == on then return end
    AD.Crouching = on
    if VIM then
        pcall(function() VIM:SendKeyEvent(on, Enum.KeyCode.LeftControl, false, game) end)
    end
end

local function ApplySpeed()
    if Ex.Bot_SpeedOn == false then FX.BotSpeed = nil return end
    if not Ex.DisableAnticheat then
        FX.BotSpeed = nil
        if not AD.SpeedNoted then
            AD.SpeedNoted = true
            Say("Bot Speed needs the Anticheat Bypass. Walking at normal speed so the game does not pull you back.", true)
        end
        return
    end
    local v = tonumber(Ex.Bot_Speed) or 22
    if AD.Sneak then v = math.min(v, 9) end
    FX.BotSpeed = v
end

local function CanJump()
    if Ex.Bot_Jump == false then return false end
    if FX.JumpLocked then return false end
    return true
end

local function StopMove()
    AD.MoveDir = nil
    local _, hum, root = GetParts()
    if hum and root then pcall(function() hum:Move(Vector3.zero, false) hum:MoveTo(root.Position) end) end
end

local function Fire(pp, times)
    pcall(function()
        pp.HoldDuration = 0
        pp.RequiresLineOfSight = false
    end)
    for _ = 1, times or 3 do
        if not pp.Parent or not pp.Enabled then break end
        pcall(fireproximityprompt, pp)
        task.wait(0.12)
    end
end

local function Face(pos, maxWait)
    AD.Look = pos
    if Ex.Bot_Camera == false then return end
    local t0 = os.clock()
    while os.clock() - t0 < (maxWait or 0.5) do
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local dir = pos - cam.CFrame.Position
        if dir.Magnitude < 0.1 or cam.CFrame.LookVector:Dot(dir.Unit) > 0.96 then return end
        task.wait(0.05)
    end
end

local function Probe(root, dir)
    RayP.FilterDescendantsInstances = { LocalPlayer.Character }
    local o = root.Position
    local d = dir * 3.2
    local low = Workspace:Raycast(o - Vector3.new(0, 1.6, 0), d, RayP)
    local head = Workspace:Raycast(o + Vector3.new(0, 1.2, 0), d, RayP)
    return low ~= nil, head ~= nil
end

local function Arrived(root, dest, o)
    local near = o.near
    if near and near.part and near.part.Parent then
        if (root.Position - near.part.Position).Magnitude <= near.range then return true end
    end
    local p = root.Position
    local flat = Vector3.new(p.X - dest.X, 0, p.Z - dest.Z).Magnitude
    return flat <= (o.radius or 3) and math.abs(p.Y - dest.Y) <= 8
end

local function Follow(wp, dest, o, g, t0, timeout)
    local lastP, lastT = nil, os.clock()
    local hits, lastAbort, wt0 = 0, 0, os.clock()
    while true do
        if not Alive(g) then return "stopped" end
        local char, hum, root = GetParts()
        if not root then return "dead" end
        local now = os.clock()
        if now - t0 > timeout then return "timeout" end
        if Arrived(root, dest, o) then return "arrived" end
        if o.abort and now - lastAbort > 0.2 then
            lastAbort = now
            if o.abort() then return "aborted" end
        end
        local wpos, rp = wp.Position, root.Position
        local dv = Vector3.new(wpos.X - rp.X, 0, wpos.Z - rp.Z)
        AD.MoveDir = dv.Magnitude > 0.05 and dv.Unit or nil
        hum:MoveTo(wpos)
        AD.Look = Vector3.new(wpos.X, rp.Y + 1.2, wpos.Z)
        local flat = Vector3.new(rp.X - wpos.X, 0, rp.Z - wpos.Z).Magnitude
        if flat < math.clamp(hum.WalkSpeed * 0.1, 2.2, 5) then return "ok" end
        if wp.Action == Enum.PathWaypointAction.Jump and CanJump() then hum.Jump = true end
        if now - wt0 > 4.5 then SetCrouch(AD.Sneak) return "stuck" end
        lastP = lastP or rp
        if now - lastT >= 0.5 then
            local moved = Vector3.new(rp.X - lastP.X, 0, rp.Z - lastP.Z).Magnitude
            local expect = math.max(hum.WalkSpeed, 8) * 0.5
            lastP, lastT = rp, now
            if moved < expect * 0.15 then
                hits = hits + 1
                local dir = Vector3.new(wpos.X - rp.X, 0, wpos.Z - rp.Z)
                if dir.Magnitude > 0.1 then
                    local low, head = Probe(root, dir.Unit)
                    if head and not low then
                        SetCrouch(true)
                    elseif low and not head and CanJump() then
                        hum.Jump = true
                    end
                end
                if hits >= 3 then SetCrouch(AD.Sneak) return "stuck" end
            else
                hits = 0
                Idle()
                if not AD.Sneak then SetCrouch(false) end
            end
        end
        RunService.Heartbeat:Wait()
    end
end

local function Walk(dest, o)
    o = o or {}
    local g = AD.Gen
    local t0 = os.clock()
    local timeout = o.timeout or 25
    local fails, stucks = 0, 0
    while true do
        if not Alive(g) then return "stopped" end
        local _, hum, root = GetParts()
        if not root then return "dead" end
        if os.clock() - t0 > timeout then StopMove() return "timeout" end
        if Arrived(root, dest, o) then StopMove() return "arrived" end
        if o.abort and o.abort() then StopMove() return "aborted" end
        local path = PathSvc:CreatePath({
            AgentRadius = 2, AgentHeight = 5, AgentCanJump = Ex.Bot_Jump ~= false,
            AgentCanClimb = false, WaypointSpacing = 5,
        })
        local ok = pcall(function() path:ComputeAsync(Ground(root.Position) + Vector3.new(0, 0.5, 0), dest) end)
        local wps = (ok and path.Status == Enum.PathStatus.Success) and path:GetWaypoints() or nil
        if not wps or #wps < 2 then
            fails = fails + 1
            if fails >= 3 then
                local res = Follow({ Position = dest, Action = Enum.PathWaypointAction.Walk }, dest, o, g, os.clock(), 4)
                StopMove()
                if res == "arrived" or res == "stopped" or res == "dead" or res == "aborted" then return res end
                return "nopath"
            end
            task.wait(0.25)
        else
            local blocked = false
            local conn = path.Blocked:Connect(function() blocked = true end)
            local res = "ok"
            for i = 2, #wps do
                res = Follow(wps[i], dest, o, g, t0, timeout)
                if res ~= "ok" or blocked then break end
            end
            conn:Disconnect()
            if res == "arrived" or res == "stopped" or res == "dead" or res == "timeout" or res == "aborted" then
                StopMove()
                return res
            end
            if res == "stuck" then
                stucks = stucks + 1
                if stucks >= 4 then StopMove() return "stuck" end
            end
        end
    end
end

local function Threat()
    local _, _, root = GetParts()
    if not root then return nil end
    local best
    local now = os.clock()
    for _, c in ipairs(Workspace:GetChildren()) do
        if DANGER[c.Name] and c:IsA("Model") and c:GetAttribute("Inactive") ~= true then
            local pp = c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart")
            if pp then
                local d = (pp.Position - root.Position).Magnitude
                local rec = AD.Ent[c]
                if not rec then
                    rec = { d = d, t = now, spd = 0 }
                    AD.Ent[c] = rec
                elseif now - rec.t > 0.15 then
                    local closing = (rec.d - d) / (now - rec.t)
                    rec.spd = rec.spd * 0.6 + math.max(closing, 0) * 0.4
                    rec.d, rec.t = d, now
                end
                local sp = math.max(rec.spd, (BASE_SPEED[c.Name] or 80) * 0.6)
                local eta = d / sp
                if not best or eta < best.eta then best = { model = c, name = c.Name, dist = d, eta = eta } end
            end
        end
    end
    return best
end

local function ScanRoom(room)
    local now = os.clock()
    local c = AD.Spots[room]
    if c and now - c.t < 6 then return c.list end
    local list = {}
    for _, d in ipairs(room:GetDescendants()) do
        if d:IsA("ProximityPrompt") and (d.Name == "HidePrompt" or d.Name == "HidingPrompt") then
            local model = d:FindFirstAncestorOfClass("Model")
            local part = d.Parent
            if not (part and part:IsA("BasePart")) then
                part = model and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true))
            end
            if model and part then list[#list + 1] = { prompt = d, model = model, part = part } end
        end
    end
    AD.Spots[room] = { t = now, list = list }
    return list
end

local function BestSpot(pos)
    local rooms = RoomsFolder()
    if not rooms then return nil end
    local cur = CurRoom()
    local best, bestD = nil, math.huge
    local now = os.clock()
    for _, room in ipairs(rooms:GetChildren()) do
        local n = tonumber(room.Name)
        if n and (not cur or math.abs(n - cur) <= 1) then
            for _, s in ipairs(ScanRoom(room)) do
                local p = s.prompt
                if p.Parent and s.part.Parent and p.Enabled and (AD.BadSpot[s.model] or 0) < now then
                    local sp = s.part.Position
                    if sp.Y > -10 and math.abs(sp.Y - pos.Y) < 9 then
                        local hp = s.model:FindFirstChild("HiddenPlayer", true)
                        if not (hp and hp.Value) then
                            local d = (sp - pos).Magnitude
                            if d < bestD then best, bestD = s, d end
                        end
                    end
                end
            end
        end
    end
    return best, bestD
end

local function HideLead(root, hum)
    local spot, d = BestSpot(root.Position)
    if not spot then return nil, nil end
    return d * 1.4 / math.max(hum.WalkSpeed, 10) + (Ex.Bot_HideMargin or 4), spot
end

local function DangerAbort()
    if not Ex.AD_Avoid then return false end
    local th = Threat()
    if not th then return false end
    local _, hum, root = GetParts()
    if not root then return false end
    local lead = HideLead(root, hum)
    if not lead then return false end
    return th.eta <= lead + 0.5
end

local function HideFrom(th)
    local g = AD.Gen
    local attempts = 0
    while Alive(g) and attempts < 3 do
        attempts = attempts + 1
        local char, hum, root = GetParts()
        if not root then return false end
        local spot = BestSpot(root.Position)
        if not spot then return false end
        AD.Info = "Going to hide from " .. th.name
        local rng = math.clamp((spot.prompt.MaxActivationDistance or 8) - 1.2, 3, 8)
        Walk(Ground(spot.part.Position), { radius = 2.5, timeout = 14, near = { part = spot.part, range = rng } })
        if not Alive(g) then return false end
        char = LocalPlayer.Character
        if not char then return false end
        Face(spot.part.Position, 0.35)
        for _ = 1, 8 do
            if char:GetAttribute("Hiding") then break end
            Fire(spot.prompt, 1)
            task.wait(0.15)
        end
        if char:GetAttribute("Hiding") then
            AD.Stats.Hides = AD.Stats.Hides + 1
            local t0, calmFrom, lastName = os.clock(), nil, th.name
            while Alive(g) do
                if not (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Hiding")) then return true end
                local t = Threat()
                if t then
                    calmFrom, lastName = nil, t.name
                    AD.Info = string.format("Hidden: %s is coming (~%.0fs)", t.name, t.eta)
                else
                    calmFrom = calmFrom or os.clock()
                    AD.Info = "Hidden: waiting for it to be gone"
                    if os.clock() - calmFrom >= (REBOUND[lastName] and 4 or 2.2) then break end
                end
                if os.clock() - t0 > (Ex.AD_MaxHide or 40) then break end
                Idle()
                task.wait(0.15)
            end
            for _ = 1, 6 do
                if not (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Hiding")) then break end
                ExitCloset()
                task.wait(0.5)
            end
            Mark()
            return true
        end
        AD.BadSpot[spot.model] = os.clock() + 30
    end
    return false
end

local function IsLadderPrompt(pp)
    local cur = pp.Parent
    for _ = 1, 5 do
        if not cur then break end
        local n = cur.Name:lower()
        if n:find("ladder", 1, true) or n:find("climb", 1, true) then return true end
        cur = cur.Parent
    end
    return pp.Name:lower():find("climb", 1, true) ~= nil
end

local function TryLadder()
    if Ex.AD_Ladders == false then return false end
    local rooms, cur = RoomsFolder(), CurRoom()
    local _, _, root = GetParts()
    if not (rooms and cur and root) then return false end
    local best, bd
    for _, room in ipairs(rooms:GetChildren()) do
        local n = tonumber(room.Name)
        if n and math.abs(n - cur) <= 1 then
            for _, d in ipairs(room:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled and d.Parent and d.Parent:IsA("BasePart") and IsLadderPrompt(d) then
                    local dist = (d.Parent.Position - root.Position).Magnitude
                    if not bd or dist < bd then best, bd = d, dist end
                end
            end
        end
    end
    if not best then return false end
    local th = Ex.AD_Avoid and Threat() or nil
    if th and th.eta < 25 then return false end
    local part = best.Parent
    AD.Info = "Using a ladder"
    local r = Walk(Ground(part.Position), {
        radius = 3, timeout = 15, abort = DangerAbort,
        near = { part = part, range = math.max(3, (best.MaxActivationDistance or 8) - 1) },
    })
    if r ~= "arrived" then return false end
    Face(part.Position, 0.4)
    Fire(best, 2)
    local t0 = os.clock()
    task.wait(1)
    local char = LocalPlayer.Character
    while char and os.clock() - t0 < 12 and char:GetAttribute("Climbing") do
        Idle()
        task.wait(0.2)
    end
    Mark()
    return true
end

local function PromptOf(e)
    local p = e.Prompt
    if p and p.Parent and p:IsA("ProximityPrompt") then return p end
    local inst = e.Inst
    if inst and inst.Parent then
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled and d.Name ~= "HidePrompt" then return d end
        end
    end
    return nil
end

local function NextTarget(cur, rp, mode)
    local best, bestPrompt, bestScore = nil, nil, math.huge
    local maxTry = Ex.AD_Retries or 3
    local prio = Ex.AD_LootOrder == PRIO_LABEL
    for inst, e in pairs(Tracked) do
        local opt = KIND[e.Cat]
        local on = opt and (Ex[opt] or ((mode == "knob" or mode == "search") and KNOB[e.Cat]))
        if on and inst.Parent and (AD.Tries[inst] or 0) < maxTry
            and (mode ~= "keys" or e.Cat == "keys") and (mode == "keys" or RoomOf(inst) == cur) then
            local skip = e.Cat == "items" and Ex.AIItemIgnore and Ex.AIItemIgnore[e.Label]
            if (e.Cat == "chests" or e.Cat == "lockers") and inst:GetAttribute("Locked") == true then skip = true end
            if not skip then
                local pp = PromptOf(e)
                if pp and pp.Enabled and e.Part and e.Part.Parent then
                    local score = (e.Part.Position - rp).Magnitude
                    if prio then score = score + (PRIO[e.Cat] or 2) * 100000 end
                    if score < bestScore then best, bestPrompt, bestScore = e, pp, score end
                end
            end
        end
    end
    return best, bestPrompt
end

local function Visit(e, pp)
    local inst, part = e.Inst, e.Part
    AD.Tries[inst] = (AD.Tries[inst] or 0) + 1
    if not (part and part.Parent) then return false end
    local rng = math.clamp((pp.MaxActivationDistance or 8) - 1.2, 3, 9)
    local res = Walk(Ground(part.Position), { radius = 2.5, timeout = 22, abort = DangerAbort, near = { part = part, range = rng } })
    if res == "nopath" then TryLadder() return false end
    if res ~= "arrived" then return false end
    Face(part.Position, 0.5)
    task.wait(0.05 + (Ex.AD_Delay or 350) / 4000)
    Fire(pp, 3)
    if not pp.Parent or not pp.Enabled or not inst.Parent then
        AD.Tries[inst] = 99
        AD.Stats.Loot = AD.Stats.Loot + 1
        Mark()
        return true
    end
    return false
end

local function IsOpen(door, lv0)
    return (Latest() or 0) > lv0 or door:GetAttribute("Opened") == true or door:GetAttribute("Open") == true
end
local function WaitOpen(door, lv0, secs)
    local t0 = os.clock()
    while os.clock() - t0 < secs and Ex.AutoDoors do
        if IsOpen(door, lv0) then return true end
        task.wait(0.15)
    end
    return IsOpen(door, lv0)
end
local function DoorFront(door, rootPos)
    local cf = door:GetPivot()
    local a, b = (cf * CFrame.new(0, 0, 6)).Position, (cf * CFrame.new(0, 0, -6)).Position
    local p = ((a - rootPos).Magnitude <= (b - rootPos).Magnitude) and a or b
    return Ground(p)
end

local function DoorStep(startRoom)
    local _, _, root = GetParts()
    if not root then return false end
    local door = NextClosedDoor()
    if not door then
        AD.Info = "Waiting for the next room to load"
        task.wait(0.4)
        return false
    end
    local lv0 = Latest() or 0
    local locked = door:FindFirstChild("Lock") ~= nil
    if locked then
        if not Ex.AD_Keys then
            AD.Info = "Locked door: turn on Grab Keys & Unlock Doors"
            Idle()
            return false
        end
        if not (HasItem("Key") or HasItem("KeyBackdoor")) then
            AD.WantKey = true
            AD.KeyWaitSince = AD.KeyWaitSince or os.clock()
            if os.clock() - AD.KeyReset > 15 then
                AD.KeyReset = os.clock()
                AD.Tries = NewTries()
            end
            local waited = os.clock() - AD.KeyWaitSince
            AD.Info = string.format("Locked door: searching for a key (%ds)", math.floor(waited))
            if Ex.AD_KeyWait ~= false or waited < 30 then
                if waited < 180 then Idle() end
            end
            return false
        end
        AD.WantKey, AD.KeyWaitSince = false, nil
    end

    local dpart = door.PrimaryPart or door:FindFirstChildWhichIsA("BasePart", true)
    AD.Info = "Walking to the door"
    local res = Walk(DoorFront(door, root.Position), {
        radius = 3, timeout = 45,
        near = dpart and { part = dpart, range = 8 } or nil,
        abort = function() return DangerAbort() or CurRoom() ~= startRoom end,
    })
    if res == "nopath" then TryLadder() end
    if res ~= "arrived" then return false end

    if dpart then Face(dpart.Position, 0.6) end
    if locked then
        for _, d in ipairs(door:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Name == "UnlockPrompt" then Fire(d, 2) end
        end
        task.wait(0.3)
    end
    local n = 0
    for _, d in ipairs(door:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled and d.Name ~= "UnlockPrompt" and d.Name ~= "HidePrompt" then
            Fire(d, 2)
            n = n + 1
            if n >= 4 then break end
        end
    end
    local opened = WaitOpen(door, lv0, 4)
    if not opened and Ex.AD_ForceOpen then
        local co = door:FindFirstChild("ClientOpen")
        if co and co:IsA("RemoteEvent") then
            AD.Info = "Door stuck: forcing it open"
            pcall(function() co:FireServer() end)
            opened = WaitOpen(door, lv0, 2.5)
        end
    end
    if opened then
        AD.DoorFails = 0
        AD.Stats.Doors = AD.Stats.Doors + 1
        Mark()
    else
        AD.DoorFails = AD.DoorFails + 1
        AD.Info = "Door did not open (try " .. AD.DoorFails .. ")"
    end
    return opened
end

local function TP(cf)
    local B8 = FX.B8
    if B8 and B8.SafeTP then return B8.SafeTP(cf, 0.6) end
    local char = LocalPlayer.Character
    if char then char:PivotTo(cf) return true end
    return false
end

AD.Recover = function(why)
    AD.Stuck = AD.Stuck + 1
    AD.Stats.Fixes = AD.Stats.Fixes + 1
    local lvl = AD.Stuck
    AD.Tries = NewTries()
    AD.Room, AD.WantKey, AD.KeyWaitSince = nil, false, nil
    AD.DoorFails = 0
    AD.BadSpot = setmetatable({}, { __mode = "k" })
    AD.Spots = setmetatable({}, { __mode = "k" })
    StopMove()
    if lvl >= 2 then
        AD.NoLootUntil = os.clock() + 40
        ExitCloset()
        SetCrouch(false)
    end
    if lvl >= 3 then
        Release()
        task.wait(0.4)
        pcall(Sync)
        local door = NextClosedDoor()
        local co = door and door:FindFirstChild("ClientOpen")
        if Ex.AD_ForceOpen and co and co:IsA("RemoteEvent") then pcall(function() co:FireServer() end) end
    end
    if lvl >= 4 then
        local _, hum = GetParts()
        if hum then
            local rv = Vector3.new(math.random(-10, 10) / 10, 0, math.random(-10, 10) / 10)
            if rv.Magnitude < 0.2 then rv = Vector3.new(1, 0, 0) end
            AD.MoveDir = rv.Unit
            task.wait(0.5)
            AD.MoveDir = nil
        end
    end
    if lvl >= 5 and Ex.AD_TPFallback then
        local rooms = RoomsFolder()
        local latest = Latest()
        local room = rooms and latest and rooms:FindFirstChild(tostring(latest))
        local anchor = room and (room:FindFirstChild("RoomEntrance") or room:FindFirstChild("Door"))
        if anchor then TP(anchor:GetPivot() * CFrame.new(0, 3, 0)) end
    end
    AD.Progress = os.clock()
    if lvl == 8 then
        Say("Still stuck after 8 auto-fixes. Check the room manually (puzzle / locked door?).", true)
    else
        Say("Auto-fix #" .. lvl .. " (" .. tostring(why) .. ")")
    end
end

local function UpdateFigure(cur)
    if os.clock() - AD.FigureT < 1 then return end
    AD.FigureT = os.clock()
    local rooms = RoomsFolder()
    local room = rooms and cur and rooms:FindFirstChild(tostring(cur))
    AD.FigureNear = room ~= nil and (room:FindFirstChild("FigureRig", true) ~= nil or room:FindFirstChild("FigureRagdoll", true) ~= nil)
end

local function KnobFarmStep(cur, root)
    if AD.KnobDone then
        AD.Info = "Knob Farm running"
        Idle()
        return true
    end
    if (Latest() or 0) ~= 0 or cur ~= 0 then
        SetFeature("AD_KnobFarm", false)
        Say("Knob Farm Mode needs you in Room 0. Turned off.", true)
        return true
    end
    local e, pp
    if os.clock() - AD.RoomT < math.max(Ex.AD_RoomTime or 30, 20) then e, pp = NextTarget(cur, root.Position, "knob") end
    if e then
        AD.Info = "Knob Farm: collecting " .. tostring(e.Label)
        Visit(e, pp)
        task.wait((Ex.AD_Delay or 350) / 1000)
        return true
    end
    local gold = Gold()
    if gold and gold > 0 and FX.StartKnobFarm then
        AD.KnobDone = true
        SetFeature("KnobFarm", true)
        FX.StartKnobFarm()
        Say("Knob Farm started with " .. tostring(gold) .. " gold.", true)
    else
        SetFeature("AD_KnobFarm", false)
        Say("Knob Farm: no gold found in Room 0, nothing to farm.", true)
    end
    return true
end

local function Step()
    if IsLobby() then AD.Info = "In the lobby" Idle() return end
    local char, hum, root = GetParts()
    if not (char and hum and root) then AD.Info = "Waiting for your character" Idle() return end
    if hum.Health <= 0 then
        AD.WasDead = true
        if Ex.AD_StopOnDeath then
            SetFeature("AutoDoors", false)
            Say("You died: Auto Doors turned off.", true)
            return
        end
        AD.Info = "Dead: waiting to respawn"
        Idle()
        return
    end
    if AD.WasDead then
        AD.WasDead = false
        AD.Room, AD.Tries, AD.WantKey = nil, NewTries(), false
        AD.Crouching = false
        Say("Back alive: Auto Doors resumed.")
        Mark()
    end
    if (Ex.AD_LowHP or 0) > 0 and hum.MaxHealth > 0 and (hum.Health / hum.MaxHealth) * 100 < Ex.AD_LowHP then
        SetFeature("AutoDoors", false)
        Say("Health below " .. Ex.AD_LowHP .. "%: Auto Doors turned off.", true)
        return
    end
    if (Ex.AD_StopMinutes or 0) > 0 and os.clock() - AD.Stats.Start >= Ex.AD_StopMinutes * 60 then
        SetFeature("AutoDoors", false)
        Say("Time limit reached: Auto Doors turned off.", true)
        return
    end
    if Sync() then AD.Info = "Rooms: Auto Rooms is driving" Idle() return end

    local cur, latest = CurRoom(), Latest()
    if not (cur and latest) then AD.Info = "Waiting for game data" return end

    UpdateFigure(cur)
    AD.Sneak = AD.FigureNear and Ex.Bot_Crouch ~= false
    SetCrouch(AD.Sneak)
    ApplySpeed()

    local th = Ex.AD_Avoid and Threat() or nil
    if th then
        local lead = HideLead(root, hum)
        if lead then
            if AD.SpoofVoted then AD.SpoofVoted = false if FX.SpoofVote then FX.SpoofVote("bot", false) end end
            if th.eta <= lead then
                HideFrom(th)
                return
            end
            AD.Info = string.format("%s in ~%.0fs: working near a closet", th.name, th.eta)
        else
            AD.Info = th.name .. " is coming and there is no closet: using Position Spoof"
            if not AD.SpoofVoted then AD.SpoofVoted = true if FX.SpoofVote then FX.SpoofVote("bot", true) end end
        end
    elseif AD.SpoofVoted then
        AD.SpoofVoted = false
        if FX.SpoofVote then FX.SpoofVote("bot", false) end
    end
    if char:GetAttribute("Hiding") then
        if os.clock() - AD.LastExit > 1 then
            AD.LastExit = os.clock()
            ExitCloset()
        end
        AD.Info = "Leaving the closet"
        return
    end

    if latest ~= AD.LastLatest then
        AD.LastLatest = latest
        Mark()
    end
    if Ex.AD_StopRoom > 0 and latest >= Ex.AD_StopRoom then
        SetFeature("AutoDoors", false)
        Say("Reached room " .. latest .. ": Auto Doors turned off.", true)
        return
    end
    local now = os.clock()
    if cur ~= AD.Room then
        AD.Room, AD.RoomT, AD.WantKey, AD.DoorFails = cur, now, false, 0
    end

    if Ex.AD_KnobFarm then
        KnobFarmStep(cur, root)
        return
    end

    if now >= AD.NoLootUntil then
        local e, pp
        if now - AD.RoomT < Ex.AD_RoomTime then e, pp = NextTarget(cur, root.Position, nil) end
        if not e and AD.WantKey then
            e, pp = NextTarget(cur, root.Position, "keys")
            if not e then e, pp = NextTarget(cur, root.Position, "search") end
        end
        if e then
            AD.Info = "Looting " .. tostring(e.Label)
            Visit(e, pp)
            task.wait(Ex.AD_Delay / 1000)
            return
        end
    end

    if Ex.AD_Doors then
        DoorStep(cur)
        task.wait(Ex.AD_Delay / 1000)
    else
        AD.Info = "Idle (Open Doors is off)"
        Idle()
    end
end

local function Cleanup()
    AD.Active = false
    AD.MoveDir = nil
    AD.SpeedNoted = false
    FX.BotSpeed = nil
    FX.NormalWS = nil
    SetCrouch(false)
    AD.Look, AD.CamRot = nil, nil
    if AD.SpoofVoted then
        AD.SpoofVoted = false
        if FX.SpoofVote then FX.SpoofVote("bot", false) end
    end
    local _, hum = GetParts()
    if hum then
        StopMove()
        if not Ex.SpeedHack and AD.OrigWS then pcall(function() hum.WalkSpeed = AD.OrigWS end) end
    end
    Release()
end

local function StartLoop()
    AD.Gen = AD.Gen + 1
    local my = AD.Gen
    AD.Beat = os.clock()
    task.spawn(function()
        while Alive(my) do
            AD.Beat = os.clock()
            if AD.RecoverWhy then
                local why = AD.RecoverWhy
                AD.RecoverWhy = nil
                pcall(AD.Recover, why)
            end
            local ok, err = pcall(Step)
            if ok then
                AD.Errors = 0
                task.wait(0.2)
            else
                AD.Errors = AD.Errors + 1
                AD.Info = "Error: " .. tostring(err)
                if AD.Errors % 5 == 0 then AD.RecoverWhy = "errors" end
                task.wait(math.min(0.5 + AD.Errors * 0.25, 3))
            end
        end
    end)
    task.spawn(function()
        while Alive(my) do
            task.wait(0.5)
            if not Alive(my) then return end
            pcall(AD.UpdateHUD)
            if os.clock() - AD.Beat > 60 then
                AD.Stats.Fixes = AD.Stats.Fixes + 1
                AD.Progress = os.clock()
                Say("The loop froze: restarting Auto Doors.", true)
                StartLoop()
                return
            end
            if Ex.AD_Watchdog and not AD.RecoverWhy and os.clock() - AD.Progress > (Ex.AD_StuckTime or 15) then
                AD.RecoverWhy = "no progress for " .. tostring(Ex.AD_StuckTime) .. "s"
            end
        end
    end)
end

Hooks.AD_HUD = function() pcall(AD.UpdateHUD) end

Hooks.AutoDoors = function(v)
    AD.Gen = AD.Gen + 1
    if v then
        local any = false
        for _, k in ipairs(OPTS) do
            if Ex[k] then any = true break end
        end
        if not any then AD.Recommended(false) end
        AD.Tries = NewTries()
        AD.Room, AD.Info = nil, "Starting"
        AD.Stuck, AD.Errors, AD.RecoverWhy = 0, 0, nil
        AD.WantKey, AD.KeyWaitSince, AD.KeyReset, AD.NoLootUntil = false, nil, 0, 0
        AD.DoorFails, AD.WasDead, AD.KnobDone, AD.Crouching = 0, false, false, false
        AD.LastLatest = Latest()
        AD.Progress = os.clock()
        AD.Stats = { Doors = 0, Loot = 0, Fixes = 0, Hides = 0, Start = os.clock() }
        local _, hum = GetParts()
        AD.OrigWS = hum and (Saved.HackWS or hum.WalkSpeed) or 16
        FX.NormalWS = AD.OrigWS
        AD.Running, AD.Active = true, true
        Say("Mode: " .. ModeNm() .. ". The bot is running.")
        StartLoop()
    else
        Cleanup()
        AD.Info = "Off"
        if AD.Running then
            AD.Running = false
            Say("Stopped. " .. StatsLine())
        end
        pcall(AD.UpdateHUD)
    end
end
end)()

print("[AMBUSH HUB] Loading Config presets")
local EXTRA_KEYS = {
    "Notify", "NotifyStyle", "NotifySound", "NotifyVolume", "NotifyDuration", "NotifyCooldown", "NotifyTips",
    "NotifySoundId", "NotifyIconId",
    "Speed", "SpeedValue", "SpeedMethod", "SpeedHack", "SpeedHackValue", "DisableAnticheat", "VelocityManipulationMode", "PositionSpoof", "CrouchSpoof", "AutoHeartbeatMinigame", "BypassGiggle", "BypassDupe", "BypassEyes", "BypassLookman", "BypassGloombatEggs", "BypassSeekObstructions", "BypassVacuum", "BypassKillbricks", "BypassSeekingWall", "BypassSnare", "BypassBanana", "BypassJeff", "RemoveScreech", "RemoveHalt", "RemoveA90", "RemoveDread", "RemoveSurge", "NoScreechDamage", "NoHaltDamage", "NoA90Damage", "NoSurgeDamage", "RemoveSeekTrigger", "RemoveFigure", "AutoRevive", "FigureGodmode", "RemoveBasementGate", "RemovePaintingsDoor", "RemoveSkeletonDoor", "Key_PosSpoof", "NotifyLibraryCode", "GuessLibraryCode", "AutoSteerMinecart", "BypassSeek", "BypassFigure", "NotifyRansom", "TimerShow", "TimerPosition", "TimerScale", "TimerOpacity", "TimerSplits", "TimerButtons", "TimerAutoStart", "TimerAutoSplit", "TimerStopRoom", "AutoPositionSpoof", "NotifyDespawn", "PerfMode", "AutoPerf", "ShowSeekPath", "ShowEyestalkPath", "PathMode", "InfCrucifix", "RemoveCutscenes", "DisableEntityJumpscares", "DisableFiredamp", "NotifyItems", "NotifyUnlistedItems", "BtnSpeedHack", "Jump", "JumpPower", "InfJump", "Slide", "SlideSpeed", "FlySpeed",
    "Fullbright", "VoidGuard", "AutoBreakerBox", "InfiniteItems", "InfiniteItemsList", "AutoInteract", "PromptReach", "PromptClip", "DisableIdleKick", "MeldStopGrowth", "MeldRemove", "FloatButtons", "BtnACM", "BtnFly", "InstantPrompt",
    "NotifyOxygen", "NotifyHaste", "NoClosetDelay", "NoAcceleration", "DoorReach", "NoFootsteps", "NoPromptSounds",
    "Key_ACM", "Key_Noclip", "Key_Fly", "Key_Speed", "Key_SpeedHack", "Key_TimerToggle", "Key_TimerStop", "Key_TimerReset", "Key_Slide", "Key_Hub", "Key_RestorePrompts",
    "BypassDrones", "AntiNoise", "BypassAlma", "NoScribblesDamage", "StairwellExtraESP", "CustomFOV", "FOVValue", "ThirdPerson", "TPOffsetX", "TPOffsetY", "TPOffsetZ", "NoCamShake", "NoCamBob", "TransHide", "TransHideValue", "NoHideVignette", "NoGlitchJumpscare", "NoTimothyJumpscare", "NoVoidJumpscare", "NoJamMusic", "NoPromptSounds",
    "SkipSeekHotel", "SkipSeekMines", "AutoLibrary", "AutoBreakerRoom", "AutoHotel", "AutoHotelIgnoreEntities", "AutoHotelRoomProcess", "KnobFarm", "AutoClosetToggle", "SpectateEntityToggle", "SpecateEntityMode", "AutoSolveAnchors", "AutoUnlockPadlockToggle", "AutoUnlockPadlockSlider", "RoomsAutoWalk", "RoomsAutoWalkIgnoreA60", "RoomsAutoWalkShowPathToggle", "RoomsAutoWalkSpoofFootsteps", "RoomsAutoWalkPathfindTimeout", "AntiScribbles", "ViewmodelOffsetToggle", "ViewmodelOffsetX", "ViewmodelOffsetY", "ViewmodelOffsetZ",
    "FBBrightness", "FBAmbient", "NoFog", "AntiLag", "AntiLagLevel", "TimerAutoEnd", "TimerStopOnDeath",
    "CreakText", "CreakRange", "HonchoESP", "HonchoAutoDeposit", "TimeShower", "StopTimeStampede", "AntiRansom", "AntiClosetTrash", "DropCounter", "DropIntervalSecs", "OrbitHeight", "OrbitDistance", "OrbitSpeed", "CrusherOff", "MeldWallRemove", "NoiseTVBreaker", "FMNAnomalyESP", "FMNAnomalyNotify", "AutoAlmaMinigame", "TellerNumber", "TellerNotify",
}

function R4N_ExKeys()
    local never = { ACM = true, Fly = true, Noclip = true, KnobFarm = true, AD_KnobFarm = true, Fun_Active = true, ESPRainbow = true }
    local seen, list = {}, {}
    for _, k in ipairs(EXTRA_KEYS) do
        if not seen[k] then seen[k] = true list[#list + 1] = k end
    end
    for k in pairs(Setters) do
        local t = type(Ex[k])
        if type(k) == "string" and not seen[k] and not never[k] and (t == "boolean" or t == "number" or t == "string") then
            seen[k] = true
            list[#list + 1] = k
        end
    end
    return list
end

ExtraSerialize = function()
    local out = { NotifyFilter = Ex.NotifyFilter }
    for _, k in ipairs(R4N_ExKeys()) do out[k] = Ex[k] end
    return out
end

ExtraApply = function(data)
    if type(data) ~= "table" then return end
    for _, k in ipairs(R4N_ExKeys()) do
        local v = data[k]
        if v ~= nil and type(v) == type(Ex[k]) and (not R4N_SCOPE or (R4N_GroupOf and R4N_SCOPE[R4N_GroupOf(k)])) then
            Ex[k] = v
            if Setters[k] then Setters[k](v) end
        end
    end
    if type(data.NotifyFilter) == "table" and (not R4N_SCOPE or R4N_SCOPE.Alerts) then
        for name, on in pairs(data.NotifyFilter) do
            if type(on) == "boolean" then Ex.NotifyFilter[name] = on end
        end
        Setters.NotifyFilter(NotifySelected())
    end
    FX.UpdateButtons()
end
R4N_SHARED = { Ex = Ex, Hooks = Hooks, SetFeature = SetFeature, Apply = Apply, NotifyUI = NotifyUI, FX = FX, GetParts = GetParts }
end)()

local SCALAR_KEYS = {
    "MaxDistance", "MaxObjects", "RefreshRate", "TextSize", "Font", "ShowName", "ShowDistance", "Unit",
    "TracerOrigin", "TracerThickness", "PlayerNames", "UnlistedItems", "UnlistedEntities", "RoomEntities", "HideLooted", "AutoPreset",
}

local function VisualsSerialize()
    local out = { Cats = {}, ItemFilter = Cfg.ItemFilter, EntityFilter = Cfg.EntityFilter, FillTransparency = Cfg.FillTransparency }
    for _, k in ipairs(SCALAR_KEYS) do out[k] = Cfg[k] end
    if ExtraSerialize then out.Extra = ExtraSerialize() end
    for id, c in pairs(Cfg.Categories) do
        out.Cats[id] = { Enabled = c.Enabled, Tracer = c.Tracer, Color = { c.Color.R, c.Color.G, c.Color.B } }
    end
    return out
end

local function VisualsApply(data)
    if type(data) ~= "table" then return end
    if ExtraApply then pcall(ExtraApply, data.Extra) end
    if R4N_SCOPE and not R4N_SCOPE.Visuals then return end

    for _, k in ipairs(SCALAR_KEYS) do
        if data[k] ~= nil and (k ~= "Font" or FONT_MAP[data[k]]) then
            Cfg[k] = data[k]
            if Setters[k] then Setters[k](data[k]) end
        end
    end

    if type(data.FillTransparency) == "number" then
        Cfg.FillTransparency = data.FillTransparency
        Setters.FillPercent(math.floor((1 - data.FillTransparency) * 100))
    end

    if type(data.Cats) == "table" then
        for id, c in pairs(data.Cats) do
            local cat = Cfg.Categories[id]
            if cat and type(c) == "table" then
                if c.Enabled ~= nil then
                    cat.Enabled = c.Enabled
                    if Setters["cat_" .. id] then Setters["cat_" .. id](c.Enabled) end
                end
                if c.Tracer ~= nil then
                    cat.Tracer = c.Tracer == true
                    if Setters["tr_" .. id] then Setters["tr_" .. id](cat.Tracer) end
                end
                if type(c.Color) == "table" and #c.Color == 3 then
                    cat.Color = Color3.new(c.Color[1], c.Color[2], c.Color[3])
                    if Setters["col_" .. id] then Setters["col_" .. id](cat.Color) end
                end
            end
        end
    end

    local function MergeFilter(saved, names, setter)
        if type(saved) ~= "table" then return nil end
        local map, list = {}, {}
        for _, n in ipairs(names) do
            local on = saved[n]
            if on == nil then on = true end
            map[n] = on
            if on then list[#list + 1] = n end
        end
        setter(list)
        return map
    end
    local im = MergeFilter(data.ItemFilter, ITEM_NAMES, function(l) Setters.ItemFilter(l) end)
    if im then Cfg.ItemFilter = im end
    local em = MergeFilter(data.EntityFilter, ENTITY_LIST, function(l) Setters.EntityFilter(l) end)
    if em then Cfg.EntityFilter = em end
end

print("[AMBUSH HUB] Loaded Config presets")
print("[AMBUSH HUB] Loading Config System")
;(function()
local L = R4N_LANG
local function Msg(en)
    local d = R4N_LANGPACK.Msg
    d = type(d) == "table" and d[L] or nil
    return (d and d[en]) or en
end

local function Notify(title, content, dur)
    pcall(function() WindUI:Notify({ Title = title, Content = content, Duration = dur or 3 }) end)
end

local configFolder = "RON_Configs"
local autoloadFile = configFolder .. "/_autoload.txt"
if makefolder then
    if isfolder then
        if not isfolder(configFolder) then pcall(makefolder, configFolder) end
    else
        pcall(makefolder, configFolder)
    end
end

local selectedConfig = ""
local newConfigName = ""
local renameTo = ""
local importCode = ""
local importName = ""
local scopeName = "Everything"
local pendingDelete = nil

local GROUPS = {
    [MainTab] = "Main", [InfoTab] = "Info", [VisualsTab] = "Visuals", [PlayerTab] = "Player",
    [AutomationTab] = "Automation", [AntiCheatTab] = "Anticheat", [AntisTab] = "Antis",
    [AlertsTab] = "Alerts", [MiscTab] = "Misc", [KeybindsTab] = "Keybinds",
}
if ArchivesTab then GROUPS[ArchivesTab] = "Archives" end
if StairwellTab then GROUPS[StairwellTab] = "Stairwell" end
R4N_GroupOf = function(k)
    local t = R4N_KeyTab[k]
    return t and GROUPS[t] or "Other"
end
local SCOPE_NAMES = { "Everything", "Visuals / ESP", "Player", "Automation", "Anticheat & Antis", "Alerts", "Misc", "Archives & Stairwell", "Keybinds" }
local SCOPES = {
    ["Visuals / ESP"] = { Visuals = true },
    ["Player"] = { Player = true },
    ["Automation"] = { Automation = true },
    ["Anticheat & Antis"] = { Anticheat = true, Antis = true },
    ["Alerts"] = { Alerts = true },
    ["Misc"] = { Misc = true },
    ["Archives & Stairwell"] = { Archives = true, Stairwell = true },
    ["Keybinds"] = { Keybinds = true },
}

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local B64R = {}
for i = 1, 64 do B64R[B64:sub(i, i)] = i - 1 end

local function b64enc(s)
    local out = {}
    for i = 1, #s, 3 do
        local a, b, c = s:byte(i, i + 2)
        local v = a * 65536 + (b or 0) * 256 + (c or 0)
        local c1 = math.floor(v / 262144) % 64
        local c2 = math.floor(v / 4096) % 64
        local c3 = math.floor(v / 64) % 64
        local c4 = v % 64
        out[#out + 1] = B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1)
            .. (b and B64:sub(c3 + 1, c3 + 1) or "") .. (c and B64:sub(c4 + 1, c4 + 1) or "")
    end
    return table.concat(out)
end

local function b64dec(s)
    s = s:gsub("[^%w%-_]", "")
    local out = {}
    for i = 1, #s, 4 do
        local c1, c2 = B64R[s:sub(i, i)], B64R[s:sub(i + 1, i + 1)]
        local c3, c4 = B64R[s:sub(i + 2, i + 2)], B64R[s:sub(i + 3, i + 3)]
        if not (c1 and c2) then return nil end
        local v = c1 * 262144 + c2 * 4096 + (c3 or 0) * 64 + (c4 or 0)
        out[#out + 1] = string.char(math.floor(v / 65536) % 256)
        if c3 then out[#out + 1] = string.char(math.floor(v / 256) % 256) end
        if c4 then out[#out + 1] = string.char(v % 256) end
    end
    return table.concat(out)
end

local function lzwEncode(s)
    local dict, size = {}, 256
    for i = 0, 255 do dict[string.char(i)] = i end
    local w, out = "", {}
    for i = 1, #s do
        local c = s:sub(i, i)
        local wc = w .. c
        if dict[wc] then
            w = wc
        else
            out[#out + 1] = dict[w]
            if size < 65535 then
                dict[wc] = size
                size = size + 1
            end
            w = c
        end
    end
    if w ~= "" then out[#out + 1] = dict[w] end
    return out
end

local function lzwDecode(codes)
    local dict, size = {}, 256
    for i = 0, 255 do dict[i] = string.char(i) end
    local w = dict[codes[1]]
    if not w then return nil end
    local out = { w }
    for i = 2, #codes do
        local k = codes[i]
        local entry
        if dict[k] then
            entry = dict[k]
        elseif k == size then
            entry = w .. w:sub(1, 1)
        else
            return nil
        end
        out[#out + 1] = entry
        if size < 65535 then
            dict[size] = w .. entry:sub(1, 1)
            size = size + 1
        end
        w = entry
    end
    return table.concat(out)
end

local function PackCode(json)
    local codes = lzwEncode(json)
    local bytes = {}
    for i, c in ipairs(codes) do
        bytes[i] = string.char(math.floor(c / 256), c % 256)
    end
    return "R4N2-" .. b64enc(table.concat(bytes))
end

local function UnpackCode(code)
    local body = tostring(code or ""):gsub("%s+", ""):match("^R4N2%-(.+)$")
    if not body then return nil end
    local raw = b64dec(body)
    if not raw or #raw < 2 or #raw % 2 ~= 0 then return nil end
    local codes = {}
    for i = 1, #raw, 2 do
        local a, b = raw:byte(i, i + 1)
        codes[#codes + 1] = a * 256 + b
    end
    return lzwDecode(codes)
end

local function HttpReq(opts)
    local f = (syn and syn.request) or request or http_request or (http and http.request) or (fluxus and fluxus.request)
    if not f then return nil end
    local ok, res = pcall(f, opts)
    if ok and type(res) == "table" then return res end
    return nil
end

local function UploadOnline(code)
    local r = HttpReq({ Url = "https://paste.rs/", Method = "POST", Headers = { ["Content-Type"] = "text/plain" }, Body = code })
    if r and type(r.Body) == "string" and (r.StatusCode == 200 or r.StatusCode == 201) then
        local id = r.Body:match("paste%.rs/(%w+)")
        if id then return "R4N2P-" .. id end
    end
    local r2 = HttpReq({
        Url = "https://dpaste.org/api/", Method = "POST",
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        Body = "content=" .. HttpService:UrlEncode(code) .. "&expiry_days=30",
    })
    if r2 and type(r2.Body) == "string" then
        local id = r2.Body:match("dpaste%.org/(%w+)")
        if id then return "R4N2D-" .. id end
    end
    return nil
end

local function ResolveCode(raw)
    raw = tostring(raw or ""):gsub("%s+", "")
    local pid = raw:match("^R4N2P%-(%w+)$")
    if pid then
        local r = HttpReq({ Url = "https://paste.rs/" .. pid, Method = "GET" })
        if r and type(r.Body) == "string" and (r.StatusCode or 200) == 200 then
            return (r.Body:gsub("%s+", ""))
        end
        return nil
    end
    local did = raw:match("^R4N2D%-(%w+)$")
    if did then
        local r = HttpReq({ Url = "https://dpaste.org/" .. did .. "/raw", Method = "GET" })
        if r and type(r.Body) == "string" and (r.StatusCode or 200) == 200 then
            return (r.Body:gsub("%s+", ""))
        end
        return nil
    end
    return raw
end

local function Clip(text)
    local f = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if not f then return false end
    return (pcall(f, text))
end

local function CfgPath(name) return configFolder .. "/" .. name .. ".json" end

local function Sanitize(name)
    return (tostring(name or ""):gsub("[^%w_%- ]", ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function BuildData(name)
    return { Version = "CD-2", Name = name, Visuals = VisualsSerialize() }
end

local function GetConfigList()
    local files = {}
    if listfiles and isfolder and isfolder(configFolder) then
        local okl, list = pcall(listfiles, configFolder)
        if okl and type(list) == "table" then
            for _, file in ipairs(list) do
                local fileName = file:match("([^/\\]+)%.json$")
                if fileName and fileName:sub(1, 1) ~= "_" then table.insert(files, fileName) end
            end
        end
    end
    table.sort(files)
    if #files == 0 then table.insert(files, "No configs found") end
    return files
end

local function RefreshDropdown(dropdown, values)
    if dropdown.Refresh then
        dropdown:Refresh(values)
    elseif dropdown.SetValues then
        dropdown:SetValues(values)
    end
end

local function ReadJson(path)
    return pcall(function() return HttpService:JSONDecode(readfile(path)) end)
end

local function ApplyData(data, scopeNm)
    if type(data) ~= "table" then return false end
    R4N_SCOPE = SCOPES[scopeNm or "Everything"]
    local ok = pcall(VisualsApply, data.Visuals)
    R4N_SCOPE = nil
    return ok
end

local function CanFiles()
    return (writefile and readfile and isfile) and true or false
end

local function Valid()
    return selectedConfig ~= "" and selectedConfig ~= "No configs found"
end

ConfigsTab:Section({ Title = "Config Selection" })

local initialList = GetConfigList()
if initialList[1] ~= "No configs found" then selectedConfig = initialList[1] end

local ConfigDropdown = ConfigsTab:Dropdown({
    Title = "Pick saved config",
    Values = initialList,
    Value = initialList[1],
    Callback = function(option)
        if option and option ~= "No configs found" then selectedConfig = option else selectedConfig = "" end
    end
})

local function Reload(pickName)
    local list = GetConfigList()
    RefreshDropdown(ConfigDropdown, list)
    local pick = pickName
    if not pick or not table.find(list, pick) then pick = list[1] end
    selectedConfig = (pick ~= "No configs found") and pick or ""
    pcall(function() ConfigDropdown:Select(pick) end)
end

ConfigsTab:Button({
    Title = "Refresh config list",
    Callback = function()
        Reload(selectedConfig)
        Notify("Configs", Msg("Config list refreshed."), 2)
    end
})

ConfigsTab:Dropdown({
    Title = "Load scope",
    Desc = "What 'Load selected config' and import apply to: everything or only one tab's options.",
    Values = SCOPE_NAMES,
    Value = "Everything",
    Callback = function(option) if option then scopeName = option end end
})

ConfigsTab:Button({
    Title = "Load selected config",
    Callback = function()
        if not Valid() then
            Notify("Error", Msg("Please select a valid config first."))
            return
        end
        if not (isfile and readfile and isfile(CfgPath(selectedConfig))) then
            Notify("Error", Msg("Config file not found."))
            return
        end
        local ok, data = ReadJson(CfgPath(selectedConfig))
        if ok and type(data) == "table" and ApplyData(data, scopeName) then
            Notify("Configs", Msg("Loaded '") .. selectedConfig .. "' (" .. scopeName .. ")")
        else
            Notify("Error", Msg("Failed to load configuration file."))
        end
    end
})

ConfigsTab:Button({
    Title = "Overwrite selected config",
    Desc = "Overwrites the selected config with your current settings.",
    Callback = function()
        if not Valid() then
            Notify("Error", Msg("Select a config from the dropdown to overwrite."))
            return
        end
        if not writefile then
            Notify("Error", Msg("Your executor does not support file writing."))
            return
        end
        writefile(CfgPath(selectedConfig), HttpService:JSONEncode(BuildData(selectedConfig)))
        Notify("Configs", Msg("Overwrote '") .. selectedConfig .. "'")
    end
})

ConfigsTab:Section({ Title = "Create New Config" })

ConfigsTab:Input({
    Title = "New config name",
    Placeholder = "My config",
    Value = "",
    Callback = function(text) newConfigName = Sanitize(text) end
})

ConfigsTab:Button({
    Title = "Save new config",
    Callback = function()
        if newConfigName == "" or newConfigName:sub(1, 1) == "_" then
            Notify("Error", Msg("Type a valid name first (letters, numbers, spaces, _ and -)."))
            return
        end
        if not CanFiles() then
            Notify("Error", Msg("Your executor does not support file writing."))
            return
        end
        if isfile(CfgPath(newConfigName)) then
            Notify("Error", Msg("A config with that name already exists."))
            return
        end
        writefile(CfgPath(newConfigName), HttpService:JSONEncode(BuildData(newConfigName)))
        Reload(newConfigName)
        Notify("Configs", Msg("Saved '") .. newConfigName .. "'")
    end
})

ConfigsTab:Section({ Title = "Manage Configs" })

ConfigsTab:Input({
    Title = "Rename to",
    Placeholder = "New name",
    Value = "",
    Callback = function(text) renameTo = Sanitize(text) end
})

ConfigsTab:Button({
    Title = "Rename selected config",
    Desc = "Type the new name above, then press this.",
    Callback = function()
        if not Valid() then
            Notify("Error", Msg("Select a config first."))
            return
        end
        if renameTo == "" or renameTo:sub(1, 1) == "_" then
            Notify("Error", Msg("Type the new name first."))
            return
        end
        if renameTo == selectedConfig then return end
        if not CanFiles() then
            Notify("Error", Msg("Your executor does not support file writing."))
            return
        end
        if isfile(CfgPath(renameTo)) then
            Notify("Error", Msg("A config with that name already exists."))
            return
        end
        local okr, content = pcall(readfile, CfgPath(selectedConfig))
        if not okr or type(content) ~= "string" then
            Notify("Error", Msg("Could not read the config."))
            return
        end
        local okj, data = pcall(function() return HttpService:JSONDecode(content) end)
        if okj and type(data) == "table" then
            data.Name = renameTo
            content = HttpService:JSONEncode(data)
        end
        writefile(CfgPath(renameTo), content)
        if delfile then pcall(delfile, CfgPath(selectedConfig)) end
        if isfile(autoloadFile) then
            local okA, cur = pcall(readfile, autoloadFile)
            if okA and Sanitize(cur) == selectedConfig then pcall(writefile, autoloadFile, renameTo) end
        end
        local old = selectedConfig
        Reload(renameTo)
        Notify("Configs", "'" .. old .. "' -> '" .. renameTo .. "'")
    end
})

ConfigsTab:Button({
    Title = "Duplicate selected config",
    Callback = function()
        if not Valid() then
            Notify("Error", Msg("Select a config first."))
            return
        end
        if not CanFiles() then return end
        local okr, content = pcall(readfile, CfgPath(selectedConfig))
        if not okr then return end
        local nm = selectedConfig .. " copy"
        local n = 2
        while isfile(CfgPath(nm)) do
            nm = selectedConfig .. " copy " .. n
            n = n + 1
        end
        local okj, data = pcall(function() return HttpService:JSONDecode(content) end)
        if okj and type(data) == "table" then
            data.Name = nm
            content = HttpService:JSONEncode(data)
        end
        writefile(CfgPath(nm), content)
        Reload(nm)
        Notify("Configs", Msg("Created '") .. nm .. "'")
    end
})

ConfigsTab:Button({
    Title = "Delete selected config",
    Desc = "Press twice within 5 seconds to confirm.",
    Callback = function()
        if not Valid() then
            Notify("Error", Msg("Select a config first."))
            return
        end
        if pendingDelete ~= selectedConfig then
            pendingDelete = selectedConfig
            local mine = selectedConfig
            Notify("Configs", Msg("Press again to delete '") .. mine .. "'", 5)
            task.delay(5, function() if pendingDelete == mine then pendingDelete = nil end end)
            return
        end
        pendingDelete = nil
        if not delfile then
            Notify("Error", Msg("Your executor cannot delete files."))
            return
        end
        local gone = selectedConfig
        pcall(delfile, CfgPath(gone))
        Reload(nil)
        Notify("Configs", Msg("Deleted '") .. gone .. "'")
    end
})

ConfigsTab:Button({
    Title = "Make auto-loaded",
    Desc = "This config is loaded automatically every time the script starts.",
    Callback = function()
        if not Valid() or not writefile then
            Notify("Error", Msg("Select a config first."))
            return
        end
        pcall(writefile, autoloadFile, selectedConfig)
        Notify("Configs", Msg("Auto-load: ") .. selectedConfig)
    end
})

ConfigsTab:Button({
    Title = "Clear auto-load",
    Callback = function()
        if isfile and isfile(autoloadFile) and delfile then pcall(delfile, autoloadFile) end
        if writefile then pcall(writefile, autoloadFile, "") end
        Notify("Configs", Msg("Auto-load cleared."))
    end
})

ConfigsTab:Section({ Title = "Share / Import" })

local OutInput = ConfigsTab:Input({
    Title = "Generated code",
    Desc = "The share code appears here (also copied to the clipboard if the executor supports it).",
    Placeholder = "R4N2-...",
    Value = "",
    Callback = function() end
})

local function Deliver(code, kind)
    local copied = Clip(code)
    if #code < 30000 then pcall(function() OutInput:Set(code) end) end
    if not copied then
        print("[AMBUSH HUB] Share code: " .. code)
    end
    Notify("Configs", (copied
        and Msg("Code copied to clipboard (")
        or Msg("Code created, see the console / the field above ("))
        .. kind .. ", " .. #code .. " chars)", 5)
end

local function MakeCode(name)
    local json
    if name then
        if not (isfile and readfile and isfile(CfgPath(name))) then
            Notify("Error", Msg("Config file not found."))
            return nil
        end
        local okr, content = pcall(readfile, CfgPath(name))
        if not okr then return nil end
        json = content
    else
        json = HttpService:JSONEncode(BuildData("Shared"))
    end
    return PackCode(json)
end

local function ShareFlow(name, online)
    local code = MakeCode(name)
    if not code then return end
    if online then
        local short = UploadOnline(code)
        if short then
            Deliver(short, "online")
        else
            Notify("Error", Msg("Online upload failed (no internet access from the executor?). Sharing the normal code instead."), 5)
            Deliver(code, "portable")
        end
    else
        Deliver(code, "portable")
    end
end

ConfigsTab:Button({
    Title = "Share selected config",
    Desc = "Creates a code with the entire selected config. Anyone can import it, no files needed.",
    Callback = function()
        if not Valid() then
            Notify("Error", Msg("Select a config first."))
            return
        end
        ShareFlow(selectedConfig, false)
    end
})

ConfigsTab:Button({
    Title = "Share current settings",
    Desc = "Creates a code with what is on right now (no need to save first).",
    Callback = function() ShareFlow(nil, false) end
})

ConfigsTab:Button({
    Title = "Upload selected (short online code)",
    Desc = "Uploads the selected config and gives a short code. Needs internet from the executor.",
    Callback = function()
        if not Valid() then
            Notify("Error", Msg("Select a config first."))
            return
        end
        ShareFlow(selectedConfig, true)
    end
})

ConfigsTab:Button({
    Title = "Upload current (short online code)",
    Callback = function() ShareFlow(nil, true) end
})

ConfigsTab:Input({
    Title = "Code import",
    Desc = "Paste a share code here (portable R4N2-... or a short online code).",
    Placeholder = "R4N2-...",
    Value = "",
    Callback = function(text) importCode = tostring(text or "") end
})

ConfigsTab:Input({
    Title = "Save imported as",
    Placeholder = "Name for the imported config",
    Value = "",
    Callback = function(text) importName = Sanitize(text) end
})

local function ImportFlow(raw, saveAs, apply)
    raw = tostring(raw or "")
    if raw:gsub("%s+", "") == "" then
        Notify("Error", Msg("Paste a code first."))
        return
    end
    local resolved = ResolveCode(raw)
    if not resolved then
        Notify("Error", Msg("Could not download that short code (internet?)."), 4)
        return
    end
    local json = UnpackCode(resolved)
    local okj, data = false, nil
    if json then okj, data = pcall(function() return HttpService:JSONDecode(json) end) end
    if not okj or type(data) ~= "table" or type(data.Visuals) ~= "table" then
        Notify("Error", Msg("Invalid or corrupted code."))
        return
    end
    if saveAs then
        if not CanFiles() then
            Notify("Error", Msg("Your executor does not support file writing."))
            return
        end
        local nm = (saveAs ~= "" and saveAs:sub(1, 1) ~= "_") and saveAs or ("Imported " .. os.date("%H%M%S"))
        local base, n = nm, 2
        while isfile(CfgPath(nm)) do
            nm = base .. " " .. n
            n = n + 1
        end
        data.Name = nm
        writefile(CfgPath(nm), HttpService:JSONEncode(data))
        Reload(nm)
        Notify("Configs", Msg("Imported and saved as '") .. nm .. "'")
    end
    if apply then
        ApplyData(data, scopeName)
        Notify("Configs", Msg("Config applied (") .. scopeName .. ")")
    end
end

ConfigsTab:Button({
    Title = "Import and apply",
    Callback = function() ImportFlow(importCode, nil, true) end
})

ConfigsTab:Button({
    Title = "Import and save as new",
    Callback = function() ImportFlow(importCode, importName, false) end
})

if getclipboard then
    ConfigsTab:Button({
        Title = "Import from clipboard (apply)",
        Callback = function()
            local okc, text = pcall(getclipboard)
            ImportFlow(okc and text or "", nil, true)
        end
    })
end

ConfigsTab:Section({ Title = "Language" })

local LANG_NAMES = type(R4N_LANGPACK.Names) == "table" and R4N_LANGPACK.Names or {}
LANG_NAMES.en = LANG_NAMES.en or "English"
local LANG_CODES, LANG_VALUES = {}, {}
do
    local order = type(R4N_LANGPACK.Order) == "table" and R4N_LANGPACK.Order or { "en" }
    local seen = {}
    local function add(code)
        local nm = LANG_NAMES[code]
        if nm and not seen[code] then
            seen[code] = true
            LANG_CODES[nm] = code
            table.insert(LANG_VALUES, nm)
        end
    end
    add("en")
    for _, code in ipairs(order) do add(code) end
end
ConfigsTab:Dropdown({
    Title = "Language",
    Desc = table.concat(LANG_VALUES, ", ") .. ". Titles are translated; re-execute the script to apply.",
    Values = LANG_VALUES,
    Value = LANG_NAMES[R4N_LANG] or "English",
    Callback = function(option)
        local code = LANG_CODES[option] or "en"
        if code == R4N_LANG then return end
        if writefile then pcall(writefile, "RON_Lang.txt", code) end
        local sv = R4N_LANGPACK.Saved
        Notify("Language", (type(sv) == "table" and sv[code]) or "Language saved. Re-execute the script to apply it.", 5)
    end
})

ConfigsTab:Section({ Title = "Auto-Execute" })

local ae = { on = false }
pcall(function()
    if isfile and readfile and isfile("RON_AutoExec.json") then
        local d = HttpService:JSONDecode(readfile("RON_AutoExec.json"))
        if type(d) == "table" then ae.on = d.on == true end
    end
end)

ConfigsTab:Toggle({
    Title = "Auto-execute on teleport",
    Desc = "Re-runs this script automatically on teleport (lobby <-> run). It re-runs the exact code you executed, no link needed.",
    Value = ae.on,
    Callback = function(v)
        ae.on = v == true
        if writefile then pcall(writefile, "RON_AutoExec.json", HttpService:JSONEncode({ on = ae.on })) end
        R4N_QueueAutoExec()
        if not ae.on then
            Notify("Auto Execute", Msg("Disabled."), 2)
            return
        end
        local st = R4N_AE_STATUS
        if st == "noqueue" then
            Notify("Auto Execute", Msg("Your executor does not support queue_on_teleport."), 5)
        elseif st == "nosource" then
            Notify("Auto Execute", Msg("Your executor does not expose the executed code. Save the script as RON-HUB-FINAL.lua in your workspace folder."), 7)
        else
            Notify("Auto Execute", Msg("Enabled. The script will run again after you teleport."), 3)
        end
    end
})

task.delay(6, function()
    pcall(function()
        if not (isfile and readfile and isfile(autoloadFile)) then return end
        local name = Sanitize(readfile(autoloadFile))
        if name == "" or not isfile(CfgPath(name)) then return end
        local ok, data = ReadJson(CfgPath(name))
        if ok and type(data) == "table" then
            ApplyData(data, "Everything")
            Notify("Configs", Msg("Auto-loaded '") .. name .. "'")
        end
    end)
end)
end)()

print("[AMBUSH HUB] Loading Main Port (bypass / automation)")
;(function()
local Ex, Hooks, SetFeature, Apply, NotifyUI, FX, GetParts = R4N_SHARED.Ex, R4N_SHARED.Hooks, R4N_SHARED.SetFeature, R4N_SHARED.Apply, R4N_SHARED.NotifyUI, R4N_SHARED.FX, R4N_SHARED.GetParts
local Env = {
        fireproximityprompt = fireproximityprompt, replicatesignal = replicatesignal,
        hookmetamethod = hookmetamethod, newcclosure = newcclosure, getnamecallmethod = getnamecallmethod,
        cloneref = cloneref, require = require,
}
local function CloneReference(Object)
        if Env.cloneref then return Env.cloneref(Object) end
        return Object
end
local Services = setmetatable({}, {
        __index = function(_, Name) return CloneReference(game:GetService(Name)) end
})
local Workspace = Services.Workspace
local LocalPlayer = Services.Players.LocalPlayer

local Globals, Connections, Functions, Objects = {}, {}, {}, { HidingSpots = {} }
local Floor = "Hotel"
local Character, Humanoid, RootPart, Collision, CollisionPart
local RemotesFolder = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
local CurrentRooms = Workspace:FindFirstChild("CurrentRooms")
local LatestRoom = { Value = 0 }

Functions.CheckCompatability = function(Array)
        for _, Name in ipairs(Array) do
                if not Env[Name] then return false end
        end
        return true
end
Functions.Notify = function(Data)
        NotifyUI(Data.Title or "", Data.Body or "")
end

local function SetChar(NewCharacter)
        task.spawn(function()
                local Hum = NewCharacter:WaitForChild("Humanoid", 15)
                local Root = NewCharacter:WaitForChild("HumanoidRootPart", 15)
                if not Hum or not Root then return end
                Character, Humanoid, RootPart = NewCharacter, Hum, Root
                Collision = NewCharacter:FindFirstChild("Collision")
                CollisionPart = NewCharacter:FindFirstChild("CollisionPart") or Collision
        end)
end
if LocalPlayer.Character then SetChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetChar)

task.spawn(function()
        local GameData = Services.ReplicatedStorage:WaitForChild("GameData", 30)
        if not GameData then return end
        local FloorValue = GameData:WaitForChild("Floor", 10)
        local LatestValue = GameData:WaitForChild("LatestRoom", 10)
        if LatestValue then LatestRoom = LatestValue end
        RemotesFolder = RemotesFolder or Services.ReplicatedStorage:FindFirstChild("EntityInfo") or Services.ReplicatedStorage:FindFirstChild("Bricks")
        if FloorValue then
                Floor = FloorValue.Value
                if Floor == "Hotel" and RemotesFolder and RemotesFolder.Name == "Bricks" then Floor = "OldHotel" end
        end
        CurrentRooms = CurrentRooms or Workspace:WaitForChild("CurrentRooms", 20)
end)

local Listeners = {}
-- Proxy tables: Toggles["Anything"] / Options["Anything"] return a fake
-- object whose .Value reads from Ex[] live, and :OnChanged / :SetValue wire
-- into Hooks so the Main Port code works even for toggles defined in the
-- earlier UI section (AutoBreakerBox, AutoLibrary, etc.).
local Toggles = setmetatable({}, { __index = function(_, id)
    return setmetatable({}, { __index = function(_, k)
        if k == "Value" then return Ex[id] end
    end })
end })
local Options = setmetatable({}, { __index = function(_, id)
    return setmetatable({}, { __index = function(_, k)
        if k == "Value" then return Ex[id] end
    end })
end })
local function MakeObj(id, default)
        if Ex[id] == nil then Ex[id] = default end
        local o = setmetatable({}, { __index = function(_, k) if k == "Value" then return Ex[id] end end })
        rawset(o, "OnChanged", function(_, f)
                Listeners[id] = Listeners[id] or {}
                Listeners[id][#Listeners[id] + 1] = f
        end)
        rawset(o, "SetValue", function(_, v) SetFeature(id, v) end)
        local prev = Hooks[id]
        Hooks[id] = function(v)
                if prev then pcall(prev, v) end
                for _, f in ipairs(Listeners[id] or {}) do task.spawn(f, v) end
        end
        return o
end
local function Tog(id, default) Toggles[id] = MakeObj(id, default or false) end
local function Opt(id, default) Options[id] = MakeObj(id, default) end

for _, id in ipairs({
        "SkipSeekHotel", "SkipSeekMines", "AutoLibrary", "AutoBreakerBox", "AutoBreakerRoom", "AutoHotel", "AutoHotelIgnoreEntities",
        "KnobFarm", "AutoClosetToggle", "SpectateEntityToggle", "AutoSolveAnchors", "AutoUnlockPadlockToggle", "GuessLibraryCode",
        "RoomsAutoWalk", "RoomsAutoWalkIgnoreA60", "RoomsAutoWalkShowPathToggle", "RoomsAutoWalkSpoofFootsteps",
        "AntiScribbles", "ViewmodelOffsetToggle", "NotifyLibraryCode",
}) do Tog(id) end
Toggles.PositionSpoof = MakeObj("PositionSpoof", false)
Opt("AutoClosetEntityList", {})
Opt("SpecateEntityMode", "Player to Entity")
Opt("RoomsAutoWalkPathfindTimeout", 1)
Opt("AutoHotelRoomProcess", 0.5)
Opt("AutoUnlockPadlockSlider", 10)
Opt("ViewmodelOffsetX", 0)
Opt("ViewmodelOffsetY", 0)
Opt("ViewmodelOffsetZ", 0)
Options.RoomsAutoWalkShowPathColor = { Value = Color3.fromRGB(0, 255, 0), OnChanged = function() end }

local EntityDistances = {
        ["RushMoving"] = 85, ["Scribbles"] = 100, ["BashMoving"] = 150, ["DronesStampede"] = 100,
        ["AmbushMoving"] = 150, ["A60"] = 125, ["A120"] = 85, ["GlitchRush"] = 90,
        ["GlitchAmbush"] = 175, ["BackdoorRush"] = 85, ["CustomEntity"] = 85,
}
local EntityAlias = {
        RushMoving = "Rush", BackdoorRush = "Rush", AmbushMoving = "Ambush", A60 = "A-60", A120 = "A-120",
        GlitchRush = "RNIUSHCG==", GlitchAmbush = "AR0xMBUSH", DronesStampede = "DronesStampede",
        Scribbles = "Scribbles", BlitzMoving = "Blitz",
}
Functions.GetNearestEntity = function(CheckDisabled, List)
        local Nearest = { Distance = math.huge, Object = nil }
        for _, Entity in ipairs(Workspace:GetChildren()) do
                if Entity:IsA("Model") and EntityDistances[Entity.Name] and Entity.PrimaryPart then
                        if not (List and List[EntityAlias[Entity.Name] or Entity.Name]) then
                                local Distance = LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position)
                                if Distance < EntityDistances[Entity.Name] and Distance < Nearest.Distance then
                                        if not CheckDisabled or Entity:GetAttribute("Inactive") ~= true then
                                                Nearest.Distance = Distance
                                                Nearest.Object = Entity
                                        end
                                end
                        end
                end
        end
        return Nearest.Object
end

local function TrackHidingSpot(Prompt)
        if Prompt:IsA("ProximityPrompt") and (Prompt.Name == "HidePrompt" or Prompt.Name == "HidingPrompt") then
                local Model = Prompt.Parent
                if Model and Model:IsA("Model") and not table.find(Objects.HidingSpots, Model) then
                        table.insert(Objects.HidingSpots, Model)
                        Model.Destroying:Once(function()
                                local pos = table.find(Objects.HidingSpots, Model)
                                if pos then table.remove(Objects.HidingSpots, pos) end
                        end)
                end
        end
end
task.spawn(function()
        local Rooms = Workspace:WaitForChild("CurrentRooms", 60)
        if not Rooms then return end
        for _, d in ipairs(Rooms:GetDescendants()) do TrackHidingSpot(d) end
        Rooms.DescendantAdded:Connect(TrackHidingSpot)
end)

local function GetHidePrompt(Spot)
        local Prompt = Spot:FindFirstChild("HidePrompt") or Spot:FindFirstChild("HidingPrompt")
                or Spot:FindFirstChild("HidePrompt", true) or Spot:FindFirstChild("HidingPrompt", true)
        if Prompt and Prompt:IsA("ProximityPrompt") then return Prompt end
        return nil
end
local function FindNearestHidingSpot()
        local Nearest, NearestDistance = nil, math.huge
        for _, Spot in ipairs(Objects.HidingSpots) do
                if Spot.Parent and Spot.PrimaryPart and Spot.PrimaryPart.Position.Y > -10 and GetHidePrompt(Spot) then
                        local Hidden = Spot:FindFirstChild("HiddenPlayer", true)
                        if not (Hidden and Hidden.Value) then
                                local Distance = LocalPlayer:DistanceFromCharacter(Spot.PrimaryPart.Position)
                                if Distance < NearestDistance then NearestDistance, Nearest = Distance, Spot end
                        end
                end
        end
        return Nearest
end
local function FirePromptSafe(Prompt)
        if Env.fireproximityprompt and Prompt then pcall(Env.fireproximityprompt, Prompt) end
end
Functions.ForceFirePrompt = FirePromptSafe

Toggles.SkipSeekHotel:OnChanged(function(Value)
        if not Value then return end
        if Floor ~= "Hotel" then return end

        task.spawn(function()
                print("started")

                local currentRooms

                repeat
                        if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
                                return
                        end
                        currentRooms = workspace:FindFirstChild("CurrentRooms")
                        task.wait()
                until currentRooms

                print("got currentrooms")

                local lastTriggerRoom = nil

                while Toggles.SkipSeekHotel.Value and Floor == "Hotel" do
                        local triggerRoom = nil

                        print("waiting for trigger")

                        repeat
                                if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
                                        return
                                end

                                currentRooms = workspace:FindFirstChild("CurrentRooms")
                                local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))

                                if currentRoomNum and currentRoomNum ~= lastTriggerRoom then
                                        local room = currentRooms and currentRooms:FindFirstChild(tostring(currentRoomNum))
                                        if room then
                                                local trigger = room:WaitForChild("TriggerEventCollision", 0.5)
                                                if trigger then
                                                        triggerRoom = currentRoomNum
                                                        print("found trigger in", triggerRoom)
                                                end
                                        end
                                end

                                task.wait()
                        until triggerRoom

                        lastTriggerRoom = triggerRoom

                        local roomNum = triggerRoom

                        while Toggles.SkipSeekHotel.Value and Floor == "Hotel" do
                                roomNum += 1
                                print("looking for room", roomNum)

                                local room
                                repeat
                                        if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
                                                return
                                        end
                                        currentRooms = workspace:FindFirstChild("CurrentRooms")
                                        room = currentRooms and currentRooms:FindFirstChild(tostring(roomNum))
                                        task.wait()
                                until room

                                print("found room", roomNum)

                                local hasSeekArm = false
                                local assets = room:FindFirstChild("Assets")
                                if assets then
                                        for _, child in ipairs(assets:GetChildren()) do
                                                if child.Name == "Seek_Arm" then
                                                        hasSeekArm = true
                                                        print("found seek arm")
                                                        break
                                                end
                                        end
                                end

                                local door
                                repeat
                                        if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
                                                return
                                        end
                                        door = room:FindFirstChild("Door", true)
                                        task.wait()
                                until door

                                print("found door, teleporting")

                                repeat
                                        if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
                                                return
                                        end
                                        if Character then
                                                Character:PivotTo(door:GetPivot())
                                        end
                                        task.wait()
                                until door:GetAttribute("Opened") == true

                                print("door opened")

                                if hasSeekArm then
                                        if not Character then
                                                return
                                        end

                                        print("voiding")

                                        local voidCFrame = Character:GetPivot() + Vector3.new(0, -2500, 0)

                                        task.wait(0.25)

                                        for _ = 1, 20 do
                                                Character:PivotTo(voidCFrame)
                                                task.wait()
                                        end

                                        task.wait(0.3)

                                        for _ = 1, 15 do
                                                Character:PivotTo(voidCFrame)
                                                task.wait()
                                        end

                                        task.wait(0.2)

                                        for _ = 1, 10 do
                                                Character:PivotTo(voidCFrame)
                                                task.wait()
                                        end

                                        print("done voiding")
                                        break
                                end
                        end
                end
        end)
end)

Toggles.AutoLibrary:OnChanged(function(AutoLibraryEnabled)
        if AutoLibraryConnection then
                task.cancel(AutoLibraryConnection)
                AutoLibraryConnection = nil
        end

        if AutoLibraryRoomConnection then
                AutoLibraryRoomConnection:Disconnect()
                AutoLibraryRoomConnection = nil
        end

        if not AutoLibraryEnabled then
                return
        end

        AutoLibraryConnection = task.spawn(function()
                local AutoLibraryPlayers = game:GetService("Players")
                local AutoLibraryLocalPlayer = AutoLibraryPlayers.LocalPlayer
                local AutoLibraryCharacter = AutoLibraryLocalPlayer.Character or AutoLibraryLocalPlayer.CharacterAdded:Wait()
                local AutoLibraryHumanoidRootPart = AutoLibraryCharacter:WaitForChild("HumanoidRootPart")

                local AutoLibraryCurrentRooms = workspace:WaitForChild("CurrentRooms")
                local AutoLibraryRoom50 = AutoLibraryCurrentRooms:WaitForChild("50")
                local AutoLibraryLiveHintBooks = {}
                local AutoLibraryHintPaperObtained = false

                local function AutoLibraryIsInRoom50(AutoLibraryObject)
                        return AutoLibraryObject
                                and AutoLibraryObject:IsDescendantOf(AutoLibraryRoom50)
                                and AutoLibraryObject:IsDescendantOf(AutoLibraryCurrentRooms)
                                and AutoLibraryObject:IsDescendantOf(workspace)
                end

                local function AutoLibraryIsActuallyInRoom50()
                        return tonumber(AutoLibraryLocalPlayer:GetAttribute("CurrentRoom")) == 50
                end

                while AutoLibraryEnabled and not AutoLibraryIsActuallyInRoom50() do
                        task.wait(0.05)
                end

                if not AutoLibraryEnabled then
                        return
                end

                local function AutoLibraryHasHintPaper()
                        AutoLibraryCharacter = AutoLibraryLocalPlayer.Character

                        if not AutoLibraryCharacter then
                                return false
                        end

                        local AutoLibraryBackpackPaper = AutoLibraryLocalPlayer.Backpack:FindFirstChild("LibraryHintPaper", true)
                        local AutoLibraryCharacterPaper = AutoLibraryCharacter:FindFirstChild("LibraryHintPaper", true)

                        return AutoLibraryBackpackPaper ~= nil or AutoLibraryCharacterPaper ~= nil
                end

                local function AutoLibraryGetObjectCFrame(AutoLibraryObject)
                        if not AutoLibraryIsActuallyInRoom50() then
                                return nil
                        end

                        if not AutoLibraryIsInRoom50(AutoLibraryObject) then
                                return nil
                        end

                        if AutoLibraryObject:IsA("Model") then
                                return AutoLibraryObject:GetPivot()
                        elseif AutoLibraryObject:IsA("BasePart") then
                                return AutoLibraryObject.CFrame
                        end

                        local AutoLibraryObjectPart = AutoLibraryObject:FindFirstChildWhichIsA("BasePart", true)

                        if AutoLibraryObjectPart then
                                return AutoLibraryObjectPart.CFrame
                        end

                        return nil
                end

                local function AutoLibraryFindBooks(AutoLibraryObject)
                        if not AutoLibraryIsActuallyInRoom50() then
                                return
                        end

                        if not AutoLibraryIsInRoom50(AutoLibraryObject) then
                                return
                        end

                        if AutoLibraryObject.Name == "LiveHintBook" then
                                if not table.find(AutoLibraryLiveHintBooks, AutoLibraryObject) then
                                        table.insert(AutoLibraryLiveHintBooks, AutoLibraryObject)
                                end
                        end

                        for _, AutoLibraryDescendant in ipairs(AutoLibraryObject:GetDescendants()) do
                                if AutoLibraryDescendant.Name == "LiveHintBook"
                                        and AutoLibraryIsInRoom50(AutoLibraryDescendant) then

                                        if not table.find(AutoLibraryLiveHintBooks, AutoLibraryDescendant) then
                                                table.insert(AutoLibraryLiveHintBooks, AutoLibraryDescendant)
                                        end
                                end
                        end
                end

                for _, AutoLibraryDescendant in ipairs(AutoLibraryRoom50:GetDescendants()) do
                        if not AutoLibraryEnabled or not AutoLibraryIsActuallyInRoom50() then
                                return
                        end

                        if AutoLibraryDescendant.Name == "LiveHintBook"
                                and AutoLibraryIsInRoom50(AutoLibraryDescendant) then

                                if not table.find(AutoLibraryLiveHintBooks, AutoLibraryDescendant) then
                                        table.insert(AutoLibraryLiveHintBooks, AutoLibraryDescendant)
                                end
                        end
                end

                AutoLibraryRoomConnection = AutoLibraryRoom50.DescendantAdded:Connect(function(AutoLibraryAddedObject)
                        if not AutoLibraryEnabled then
                                return
                        end

                        if not AutoLibraryIsActuallyInRoom50() then
                                return
                        end

                        if not AutoLibraryIsInRoom50(AutoLibraryAddedObject) then
                                return
                        end

                        AutoLibraryFindBooks(AutoLibraryAddedObject)
                end)

                while AutoLibraryEnabled
                        and AutoLibraryIsActuallyInRoom50()
                        and #AutoLibraryLiveHintBooks < 3 do

                        for _, AutoLibraryDescendant in ipairs(AutoLibraryRoom50:GetDescendants()) do
                                if not AutoLibraryEnabled or not AutoLibraryIsActuallyInRoom50() then
                                        return
                                end

                                if AutoLibraryDescendant.Name == "LiveHintBook"
                                        and AutoLibraryIsInRoom50(AutoLibraryDescendant)
                                        and not table.find(AutoLibraryLiveHintBooks, AutoLibraryDescendant) then

                                        table.insert(AutoLibraryLiveHintBooks, AutoLibraryDescendant)
                                end
                        end

                        if #AutoLibraryLiveHintBooks >= 3 then
                                break
                        end

                        task.wait(0.05)
                end

                while AutoLibraryEnabled
                        and AutoLibraryIsActuallyInRoom50()
                        and not AutoLibraryHintPaperObtained do

                        if AutoLibraryHasHintPaper() then
                                AutoLibraryHintPaperObtained = true
                                break
                        end

                        for AutoLibraryIndex = #AutoLibraryLiveHintBooks, 1, -1 do
                                if not AutoLibraryIsActuallyInRoom50() then
                                        return
                                end

                                local AutoLibraryLiveHintBook = AutoLibraryLiveHintBooks[AutoLibraryIndex]

                                if not AutoLibraryIsInRoom50(AutoLibraryLiveHintBook) then
                                        table.remove(AutoLibraryLiveHintBooks, AutoLibraryIndex)
                                        continue
                                end

                                while AutoLibraryEnabled
                                        and AutoLibraryIsActuallyInRoom50()
                                        and not AutoLibraryHintPaperObtained
                                        and AutoLibraryLiveHintBook.Parent
                                        and AutoLibraryIsInRoom50(AutoLibraryLiveHintBook) do

                                        if AutoLibraryHasHintPaper() then
                                                AutoLibraryHintPaperObtained = true
                                                break
                                        end

                                        AutoLibraryCharacter = AutoLibraryLocalPlayer.Character or AutoLibraryLocalPlayer.CharacterAdded:Wait()
                                        AutoLibraryHumanoidRootPart = AutoLibraryCharacter:FindFirstChild("HumanoidRootPart")

                                        if not AutoLibraryHumanoidRootPart then
                                                task.wait()
                                                continue
                                        end

                                        local AutoLibraryBookCFrame = AutoLibraryGetObjectCFrame(AutoLibraryLiveHintBook)

                                        if AutoLibraryBookCFrame
                                                and AutoLibraryIsActuallyInRoom50()
                                                and AutoLibraryIsInRoom50(AutoLibraryLiveHintBook) then

                                                AutoLibraryHumanoidRootPart.CFrame = AutoLibraryBookCFrame
                                        end

                                        for _, AutoLibraryPromptDescendant in ipairs(AutoLibraryLiveHintBook:GetDescendants()) do
                                                if AutoLibraryPromptDescendant:IsA("ProximityPrompt")
                                                        and AutoLibraryIsInRoom50(AutoLibraryPromptDescendant)
                                                        and AutoLibraryIsActuallyInRoom50() then

                                                        fireproximityprompt(AutoLibraryPromptDescendant)
                                                end
                                        end

                                        task.wait(0.05)
                                end

                                if AutoLibraryHintPaperObtained then
                                        break
                                end
                        end

                        if AutoLibraryHasHintPaper() then
                                AutoLibraryHintPaperObtained = true
                                break
                        end

                        local AutoLibraryHintPaper = AutoLibraryRoom50:FindFirstChild("LibraryHintPaper", true)

                        if AutoLibraryHintPaper
                                and AutoLibraryIsInRoom50(AutoLibraryHintPaper)
                                and AutoLibraryIsActuallyInRoom50() then

                                while AutoLibraryEnabled
                                        and AutoLibraryIsActuallyInRoom50()
                                        and not AutoLibraryHintPaperObtained
                                        and AutoLibraryHintPaper.Parent
                                        and AutoLibraryIsInRoom50(AutoLibraryHintPaper) do

                                        if AutoLibraryHasHintPaper() then
                                                AutoLibraryHintPaperObtained = true
                                                break
                                        end

                                        AutoLibraryCharacter = AutoLibraryLocalPlayer.Character or AutoLibraryLocalPlayer.CharacterAdded:Wait()
                                        AutoLibraryHumanoidRootPart = AutoLibraryCharacter:FindFirstChild("HumanoidRootPart")

                                        if not AutoLibraryHumanoidRootPart then
                                                task.wait()
                                                continue
                                        end

                                        local AutoLibraryPaperCFrame = AutoLibraryGetObjectCFrame(AutoLibraryHintPaper)

                                        if AutoLibraryPaperCFrame
                                                and AutoLibraryIsActuallyInRoom50()
                                                and AutoLibraryIsInRoom50(AutoLibraryHintPaper) then

                                                AutoLibraryHumanoidRootPart.CFrame = AutoLibraryPaperCFrame * CFrame.new(0, 5, 0)
                                        end

                                        for _, AutoLibraryPromptDescendant in ipairs(AutoLibraryHintPaper:GetDescendants()) do
                                                if AutoLibraryPromptDescendant:IsA("ProximityPrompt")
                                                        and AutoLibraryIsInRoom50(AutoLibraryPromptDescendant)
                                                        and AutoLibraryIsActuallyInRoom50() then

                                                        fireproximityprompt(AutoLibraryPromptDescendant)
                                                end
                                        end

                                        task.wait(0.05)
                                end
                        end

                        task.wait(0.05)
                end
        end)
end)

Toggles.AutoBreakerRoom:OnChanged(function(AutoBreakerRoomEnabled)
        if AutoBreakerRoomConnection then
                task.cancel(AutoBreakerRoomConnection)
                AutoBreakerRoomConnection = nil
        end

        if AutoBreakerRoomRoomConnection then
                AutoBreakerRoomRoomConnection:Disconnect()
                AutoBreakerRoomRoomConnection = nil
        end

        if not AutoBreakerRoomEnabled then
                return
        end

        local AutoBreakerRoomGateFireTime = 5
        local AutoBreakerRoomWaitAfterLever = 5
        local AutoBreakerRoomBreakerSecondTime = 10
        local AutoBreakerRoomWaitBeforeWeb = 4
        local AutoBreakerRoomWebDuration = 20

        AutoBreakerRoomConnection = task.spawn(function()
                local AutoBreakerRoomPlayers = game:GetService("Players")
                local AutoBreakerRoomCurrentRooms = workspace:WaitForChild("CurrentRooms")
                local AutoBreakerRoom100 = AutoBreakerRoomCurrentRooms:WaitForChild("100")

                local function AutoBreakerRoomIsActuallyInRoom100()
                        return tonumber(AutoBreakerRoomPlayers.LocalPlayer:GetAttribute("CurrentRoom")) == 100
                end

                local function AutoBreakerRoomIsInRoom100(AutoBreakerRoomObject)
                        return AutoBreakerRoomObject
                                and AutoBreakerRoomObject.Parent
                                and AutoBreakerRoomObject:IsDescendantOf(AutoBreakerRoom100)
                                and AutoBreakerRoomObject:IsDescendantOf(AutoBreakerRoomCurrentRooms)
                end

                local function AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomObject)
                        if not AutoBreakerRoomIsActuallyInRoom100() or not AutoBreakerRoomIsInRoom100(AutoBreakerRoomObject) then
                                return nil
                        end

                        if AutoBreakerRoomObject:IsA("Model") then
                                return AutoBreakerRoomObject:GetPivot()
                        elseif AutoBreakerRoomObject:IsA("BasePart") then
                                return AutoBreakerRoomObject.CFrame
                        end

                        local AutoBreakerRoomPart = AutoBreakerRoomObject:FindFirstChildWhichIsA("BasePart", true)
                        return AutoBreakerRoomPart and AutoBreakerRoomPart.CFrame
                end

                local function AutoBreakerRoomGetHRP()
                        local AutoBreakerRoomCharacter = AutoBreakerRoomPlayers.LocalPlayer.Character
                        return AutoBreakerRoomCharacter and AutoBreakerRoomCharacter:FindFirstChild("HumanoidRootPart")
                end

                local function AutoBreakerRoomActivate(AutoBreakerRoomObject)
                        if not AutoBreakerRoomObject then
                                return
                        end

                        if AutoBreakerRoomObject:IsA("ProximityPrompt") then
                                fireproximityprompt(AutoBreakerRoomObject)
                                return
                        end

                        for _, AutoBreakerRoomDescendant in ipairs(AutoBreakerRoomObject:GetDescendants()) do
                                if AutoBreakerRoomDescendant:IsA("ProximityPrompt") then
                                        fireproximityprompt(AutoBreakerRoomDescendant)
                                end
                        end
                end

                local function AutoBreakerRoomConstantTPAndActivate(AutoBreakerRoomTarget, AutoBreakerRoomDuration, AutoBreakerRoomInterval, AutoBreakerRoomOffset)
                        AutoBreakerRoomInterval = AutoBreakerRoomInterval or 0.04
                        AutoBreakerRoomOffset = AutoBreakerRoomOffset or CFrame.new()
                        local AutoBreakerRoomEndTime = os.clock() + (AutoBreakerRoomDuration or 3)

                        while AutoBreakerRoomEnabled
                                and AutoBreakerRoomIsActuallyInRoom100()
                                and AutoBreakerRoomIsInRoom100(AutoBreakerRoomTarget)
                                and os.clock() < AutoBreakerRoomEndTime do

                                local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
                                local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomTarget)

                                if AutoBreakerRoomHRP and AutoBreakerRoomCF then
                                        AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF * AutoBreakerRoomOffset
                                end

                                AutoBreakerRoomActivate(AutoBreakerRoomTarget)
                                task.wait(AutoBreakerRoomInterval)
                        end
                end

                while AutoBreakerRoomEnabled do
                        while AutoBreakerRoomEnabled and not AutoBreakerRoomIsActuallyInRoom100() do
                                task.wait(0.1)
                        end

                        if not AutoBreakerRoomEnabled then
                                return
                        end

                        local AutoBreakerRoomPoles = {}

                        while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() do
                                AutoBreakerRoomPoles = {}

                                for _, AutoBreakerRoomDescendant in ipairs(AutoBreakerRoom100:GetDescendants()) do
                                        if AutoBreakerRoomDescendant.Name == "LiveBreakerPolePickup" and AutoBreakerRoomIsInRoom100(AutoBreakerRoomDescendant) then
                                                if not table.find(AutoBreakerRoomPoles, AutoBreakerRoomDescendant) then
                                                        table.insert(AutoBreakerRoomPoles, AutoBreakerRoomDescendant)
                                                end
                                        end
                                end

                                if #AutoBreakerRoomPoles == 0 then
                                        break
                                end

                                for _, AutoBreakerRoomPole in ipairs(AutoBreakerRoomPoles) do
                                        if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
                                                break
                                        end

                                        if AutoBreakerRoomIsInRoom100(AutoBreakerRoomPole) then
                                                AutoBreakerRoomConstantTPAndActivate(AutoBreakerRoomPole, 2.8, 0.03)
                                                task.wait(0.12)
                                        end
                                end

                                task.wait(0.05)
                        end

                        if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
                                continue
                        end

                        local AutoBreakerRoomIndustrialGate = AutoBreakerRoom100:FindFirstChild("IndustrialGate")
                        local AutoBreakerRoomBox = AutoBreakerRoomIndustrialGate and AutoBreakerRoomIndustrialGate:FindFirstChild("Box")
                        local AutoBreakerRoomLever = AutoBreakerRoomBox and AutoBreakerRoomBox:FindFirstChild("Lever")
                        local AutoBreakerRoomActivateEventPrompt = AutoBreakerRoomBox and AutoBreakerRoomBox:FindFirstChild("ActivateEventPrompt")

                        if AutoBreakerRoomActivateEventPrompt and AutoBreakerRoomLever then
                                local function AutoBreakerRoomGetLeverCFrame()
                                        if AutoBreakerRoomLever:IsA("Model") then
                                                return AutoBreakerRoomLever:GetPivot()
                                        elseif AutoBreakerRoomLever:IsA("BasePart") then
                                                return AutoBreakerRoomLever.CFrame
                                        end
                                        local AutoBreakerRoomPart = AutoBreakerRoomLever:FindFirstChildWhichIsA("BasePart", true)
                                        return AutoBreakerRoomPart and AutoBreakerRoomPart.CFrame
                                end

                                local AutoBreakerRoomInitialLeverCFrame = AutoBreakerRoomGetLeverCFrame()
                                local AutoBreakerRoomLeverEndTime = os.clock() + 10

                                while AutoBreakerRoomEnabled
                                        and AutoBreakerRoomIsActuallyInRoom100()
                                        and AutoBreakerRoomIsInRoom100(AutoBreakerRoomLever)
                                        and os.clock() < AutoBreakerRoomLeverEndTime do

                                        local AutoBreakerRoomCurrentLeverCFrame = AutoBreakerRoomGetLeverCFrame()

                                        if AutoBreakerRoomCurrentLeverCFrame and AutoBreakerRoomInitialLeverCFrame
                                                and AutoBreakerRoomCurrentLeverCFrame ~= AutoBreakerRoomInitialLeverCFrame then
                                                break
                                        end

                                        local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
                                        local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomBox)

                                        if AutoBreakerRoomHRP and AutoBreakerRoomCF then
                                                AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF
                                        end

                                        AutoBreakerRoomActivate(AutoBreakerRoomActivateEventPrompt)
                                        task.wait(0.04)
                                end
                        end

                        if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
                                continue
                        end

                        task.wait(AutoBreakerRoomWaitAfterLever)

                        if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
                                continue
                        end

                        local AutoBreakerRoomElevatorBreakerEmpty = AutoBreakerRoom100:FindFirstChild("ElevatorBreakerEmpty")
                        if not AutoBreakerRoomElevatorBreakerEmpty then
                                continue
                        end

                        local AutoBreakerRoomBreakerPrompt = AutoBreakerRoomElevatorBreakerEmpty:FindFirstChild("Prompt")
                        if not AutoBreakerRoomBreakerPrompt then
                                continue
                        end

                        local AutoBreakerRoomBreakerOffset = CFrame.new(0, -1.8, 0)

                        while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() do
                                if AutoBreakerRoomElevatorBreakerEmpty:FindFirstChild("BreakerSwitchInBox") then
                                        break
                                end

                                local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
                                local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomElevatorBreakerEmpty)

                                if AutoBreakerRoomHRP and AutoBreakerRoomCF then
                                        AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF * AutoBreakerRoomBreakerOffset
                                end

                                AutoBreakerRoomActivate(AutoBreakerRoomBreakerPrompt)
                                task.wait(0.04)
                        end

                        if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
                                continue
                        end

                        task.wait(10)

                        AutoBreakerRoomConstantTPAndActivate(
                                AutoBreakerRoomElevatorBreakerEmpty,
                                AutoBreakerRoomBreakerSecondTime,
                                0.04,
                                AutoBreakerRoomBreakerOffset
                        )

                        task.wait(AutoBreakerRoomWaitBeforeWeb)

                        if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
                                continue
                        end

                        local AutoBreakerRoomElevatorCar = AutoBreakerRoom100:FindFirstChild("ElevatorCar")
                        local AutoBreakerRoomWeb = AutoBreakerRoomElevatorCar and AutoBreakerRoomElevatorCar:FindFirstChild("Web", true)

                        if AutoBreakerRoomWeb then
                                local AutoBreakerRoomEndTime = os.clock() + AutoBreakerRoomWebDuration

                                while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() and os.clock() < AutoBreakerRoomEndTime do
                                        local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
                                        local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomWeb)

                                        if AutoBreakerRoomHRP and AutoBreakerRoomCF then
                                                AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF
                                        end

                                        task.wait(0.04)
                                end
                        end

                        while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() do
                                task.wait(0.5)
                        end
                end
        end)
end)

local AutoHotelConnection
local AutoHotelLibraryConnection
local AutoHotelLibraryRoomConnection
local AutoHotelSeekConnection
local AutoHotelEntityPause = false
local AutoHotelRoomProcessTime = 0.5
local AutoHotelProcessedRooms = {}

local AutoHotelEntityNames = {
        ["RushMoving"] = true,
        ["Scribbles"] = true,
        ["BashMoving"] = true,
        ["DronesStampede"] = true,
        ["AmbushMoving"] = true,
        ["A60"] = true,
        ["A120"] = true,
        ["GlitchRush"] = true,
        ["GlitchAmbush"] = true,
        ["BackdoorRush"] = true,
        ["CustomEntity"] = true,
}

local function AutoHotelIsEntityPresent()
        if Toggles.AutoHotelIgnoreEntities and Toggles.AutoHotelIgnoreEntities.Value then
                return false
        end
        for _, AutoHotelChild in ipairs(workspace:GetChildren()) do
                if AutoHotelEntityNames[AutoHotelChild.Name] then
                        return true
                end
        end
        return false
end

local function AutoHotelWaitForEntities(AutoHotelSeconds)
        if Toggles.AutoHotelIgnoreEntities and Toggles.AutoHotelIgnoreEntities.Value then
                return
        end

        task.wait(AutoHotelSeconds or 5)

        while AutoHotelIsEntityPresent() do
                task.wait(0.15)
        end
end

local function AutoHotelGetNextClosedDoor()
        if not Character then return nil, nil end

        local AutoHotelGameData = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
        if not AutoHotelGameData then return nil, nil end

        local AutoHotelLatestRoom = AutoHotelGameData:FindFirstChild("LatestRoom")
        if not AutoHotelLatestRoom then return nil, nil end

        local AutoHotelStartRoom = AutoHotelLatestRoom.Value
        local AutoHotelBestDoor, AutoHotelBestNumber = nil, math.huge
        local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")

        if AutoHotelCurrentRooms then
                for _, AutoHotelRoom in ipairs(AutoHotelCurrentRooms:GetChildren()) do
                        local AutoHotelRoomNum = tonumber(AutoHotelRoom.Name)
                        if AutoHotelRoomNum and AutoHotelRoomNum ~= 100 and AutoHotelRoomNum >= AutoHotelStartRoom and AutoHotelRoomNum < AutoHotelBestNumber then
                                local AutoHotelDoor = AutoHotelRoom:FindFirstChild("Door")
                                if AutoHotelDoor and AutoHotelDoor:IsA("Model") then
                                        local AutoHotelOpenAttr = AutoHotelDoor:GetAttribute("Open")
                                        if AutoHotelOpenAttr == false or AutoHotelOpenAttr == nil then
                                                AutoHotelBestNumber = AutoHotelRoomNum
                                                AutoHotelBestDoor = AutoHotelDoor
                                        end
                                end
                        end
                end
        end

        return AutoHotelBestDoor, AutoHotelBestNumber
end

local function AutoHotelFindKeyObtain(AutoHotelRoom)
        local AutoHotelFound = nil
        local function AutoHotelScan(AutoHotelParent)
                if AutoHotelFound then return end
                for _, AutoHotelChild in ipairs(AutoHotelParent:GetChildren()) do
                        if AutoHotelChild.Name == "KeyObtain" then
                                AutoHotelFound = AutoHotelChild
                                return
                        end
                        AutoHotelScan(AutoHotelChild)
                        if AutoHotelFound then return end
                end
        end
        AutoHotelScan(AutoHotelRoom)
        return AutoHotelFound
end

local function AutoHotelHandleKey(AutoHotelRoomNum)
        local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")
        if not AutoHotelCurrentRooms then return false end

        local AutoHotelRoom = AutoHotelCurrentRooms:FindFirstChild(tostring(AutoHotelRoomNum))
        if not AutoHotelRoom then return false end

        local AutoHotelDoor = AutoHotelRoom:FindFirstChild("Door")
        if not AutoHotelDoor or not AutoHotelDoor:FindFirstChild("Lock") then
                return false
        end

        local AutoHotelKeyObtain = AutoHotelFindKeyObtain(AutoHotelRoom)
        if not AutoHotelKeyObtain then return false end

        local AutoHotelStart = tick()
        while tick() - AutoHotelStart < 12 do
                if LocalPlayer.Backpack:FindFirstChild("Key") or (Character and Character:FindFirstChild("Key")) then
                        return true
                end

                if Character then
                        Character:PivotTo(AutoHotelKeyObtain:GetPivot())
                end

                for _, AutoHotelDesc in ipairs(AutoHotelKeyObtain:GetDescendants()) do
                        if AutoHotelDesc:IsA("ProximityPrompt") then
                                fireproximityprompt(AutoHotelDesc)
                        end
                end

                task.wait(0.12)
        end
        return false
end

local function AutoHotelProcessRoom(AutoHotelRoomNum)
        if AutoHotelProcessedRooms[AutoHotelRoomNum] then
                return
        end
        task.wait(AutoHotelRoomProcessTime)
        AutoHotelProcessedRooms[AutoHotelRoomNum] = true
end

local function AutoHotelRunLibrary()
        local AutoHotelCurrentRooms = workspace:WaitForChild("CurrentRooms")
        local AutoHotelRoom50 = AutoHotelCurrentRooms:WaitForChild("50")
        local AutoHotelLiveHintBooks = {}
        local AutoHotelHintPaperObtained = false

        local function AutoHotelIsInRoom50(AutoHotelObj)
                return AutoHotelObj and AutoHotelObj:IsDescendantOf(AutoHotelRoom50)
        end

        local function AutoHotelIsActuallyInRoom50()
                return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) == 50
        end

        while Toggles.AutoHotel.Value and not AutoHotelIsActuallyInRoom50() do
                task.wait(0.1)
        end
        if not Toggles.AutoHotel.Value then return end

        AutoHotelWaitForEntities(5)

        local function AutoHotelHasHintPaper()
                local AutoHotelChar = LocalPlayer.Character
                if not AutoHotelChar then return false end
                return LocalPlayer.Backpack:FindFirstChild("LibraryHintPaper", true) or AutoHotelChar:FindFirstChild("LibraryHintPaper", true)
        end

        local function AutoHotelGetCFrame(AutoHotelObj)
                if not AutoHotelIsActuallyInRoom50() or not AutoHotelIsInRoom50(AutoHotelObj) then return nil end
                if AutoHotelObj:IsA("Model") then return AutoHotelObj:GetPivot() end
                if AutoHotelObj:IsA("BasePart") then return AutoHotelObj.CFrame end
                local AutoHotelPart = AutoHotelObj:FindFirstChildWhichIsA("BasePart", true)
                return AutoHotelPart and AutoHotelPart.CFrame
        end

        local function AutoHotelCollectBooks()
                for _, AutoHotelDesc in ipairs(AutoHotelRoom50:GetDescendants()) do
                        if AutoHotelDesc.Name == "LiveHintBook" and AutoHotelIsInRoom50(AutoHotelDesc) and not table.find(AutoHotelLiveHintBooks, AutoHotelDesc) then
                                table.insert(AutoHotelLiveHintBooks, AutoHotelDesc)
                        end
                end
        end

        AutoHotelCollectBooks()

        AutoHotelLibraryRoomConnection = AutoHotelRoom50.DescendantAdded:Connect(function(AutoHotelAdded)
                if Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and AutoHotelIsInRoom50(AutoHotelAdded) then
                        if AutoHotelAdded.Name == "LiveHintBook" and not table.find(AutoHotelLiveHintBooks, AutoHotelAdded) then
                                table.insert(AutoHotelLiveHintBooks, AutoHotelAdded)
                        end
                end
        end)

        while Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and #AutoHotelLiveHintBooks < 3 do
                AutoHotelCollectBooks()
                if #AutoHotelLiveHintBooks >= 3 then break end
                task.wait(0.1)
        end

        while Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and not AutoHotelHintPaperObtained do
                if AutoHotelHasHintPaper() then
                        AutoHotelHintPaperObtained = true
                        break
                end

                for AutoHotelIndex = #AutoHotelLiveHintBooks, 1, -1 do
                        local AutoHotelBook = AutoHotelLiveHintBooks[AutoHotelIndex]
                        if not AutoHotelIsInRoom50(AutoHotelBook) then
                                table.remove(AutoHotelLiveHintBooks, AutoHotelIndex)
                                continue
                        end

                        while Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and not AutoHotelHintPaperObtained and AutoHotelBook.Parent and AutoHotelIsInRoom50(AutoHotelBook) do
                                if AutoHotelHasHintPaper() then
                                        AutoHotelHintPaperObtained = true
                                        break
                                end

                                local AutoHotelChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                                local AutoHotelHRP = AutoHotelChar:FindFirstChild("HumanoidRootPart")
                                if not AutoHotelHRP then
                                        task.wait()
                                        continue
                                end

                                local AutoHotelCF = AutoHotelGetCFrame(AutoHotelBook)
                                if AutoHotelCF then
                                        AutoHotelHRP.CFrame = AutoHotelCF
                                end

                                for _, AutoHotelPrompt in ipairs(AutoHotelBook:GetDescendants()) do
                                        if AutoHotelPrompt:IsA("ProximityPrompt") then
                                                fireproximityprompt(AutoHotelPrompt)
                                        end
                                end
                                task.wait(0.08)
                        end
                        if AutoHotelHintPaperObtained then break end
                end

                if AutoHotelHasHintPaper() then
                        AutoHotelHintPaperObtained = true
                        break
                end

                local AutoHotelPaper = AutoHotelRoom50:FindFirstChild("LibraryHintPaper", true)
                if AutoHotelPaper and AutoHotelIsInRoom50(AutoHotelPaper) then
                        while Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and not AutoHotelHintPaperObtained and AutoHotelPaper.Parent do
                                if AutoHotelHasHintPaper() then
                                        AutoHotelHintPaperObtained = true
                                        break
                                end

                                local AutoHotelChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                                local AutoHotelHRP = AutoHotelChar:FindFirstChild("HumanoidRootPart")
                                if AutoHotelHRP then
                                        local AutoHotelCF = AutoHotelGetCFrame(AutoHotelPaper)
                                        if AutoHotelCF then
                                                AutoHotelHRP.CFrame = AutoHotelCF * CFrame.new(0, 5, 0)
                                        end
                                end

                                for _, AutoHotelPrompt in ipairs(AutoHotelPaper:GetDescendants()) do
                                        if AutoHotelPrompt:IsA("ProximityPrompt") then
                                                fireproximityprompt(AutoHotelPrompt)
                                        end
                                end
                                task.wait(0.08)
                        end
                end
                task.wait(0.1)
        end
end

local function AutoHotelHandleSeek()
        local AutoHotelLastTriggerRoom = nil

        while Toggles.AutoHotel.Value do
                local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")
                if not AutoHotelCurrentRooms then
                        task.wait(0.2)
                        continue
                end

                local TriggerRoomNum = nil

                for _, Room in ipairs(AutoHotelCurrentRooms:GetChildren()) do
                        local Num = tonumber(Room.Name)
                        if Num and Num ~= AutoHotelLastTriggerRoom then
                                local Trigger = Room:FindFirstChild("TriggerEventCollision")
                                        or Room:FindFirstChild("TriggerEventCollision", true)

                                if Trigger then
                                        TriggerRoomNum = Num
                                        break
                                end
                        end
                end

                if not TriggerRoomNum then
                        task.wait(0.15)
                        continue
                end

                AutoHotelLastTriggerRoom = TriggerRoomNum

                AutoHotelEntityPause = true
                AutoHotelWaitForEntities(10)
                AutoHotelEntityPause = false
        end
end

Toggles.AutoHotel:OnChanged(function(AutoHotelEnabled)
        if AutoHotelConnection then
                task.cancel(AutoHotelConnection)
                AutoHotelConnection = nil
        end
        if AutoHotelLibraryConnection then
                task.cancel(AutoHotelLibraryConnection)
                AutoHotelLibraryConnection = nil
        end
        if AutoHotelLibraryRoomConnection then
                AutoHotelLibraryRoomConnection:Disconnect()
                AutoHotelLibraryRoomConnection = nil
        end
        if AutoHotelSeekConnection then
                task.cancel(AutoHotelSeekConnection)
                AutoHotelSeekConnection = nil
        end

        AutoHotelEntityPause = false
        table.clear(AutoHotelProcessedRooms)

        if not AutoHotelEnabled then return end

        if Options.AutoHotelRoomProcess then
                AutoHotelRoomProcessTime = Options.AutoHotelRoomProcess.Value
                Options.AutoHotelRoomProcess:OnChanged(function(Value)
                        AutoHotelRoomProcessTime = Value
                end)
        end

        local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")
        if AutoHotelCurrentRooms then
                AutoHotelCurrentRooms.ChildAdded:Connect(function(AutoHotelChild)
                        local AutoHotelNum = tonumber(AutoHotelChild.Name)
                        if AutoHotelNum then
                                AutoHotelProcessRoom(AutoHotelNum)
                        end
                end)
        end

        AutoHotelSeekConnection = task.spawn(AutoHotelHandleSeek)

        task.spawn(function()
                while Toggles.AutoHotel.Value do
                        if AutoHotelIsEntityPresent() then
                                AutoHotelEntityPause = true
                                while AutoHotelIsEntityPresent() and Toggles.AutoHotel.Value do
                                        task.wait(0.15)
                                end
                                AutoHotelEntityPause = false
                        end
                        task.wait(0.2)
                end
        end)

        AutoHotelConnection = task.spawn(function()
                while Toggles.AutoHotel.Value do
                        if AutoHotelEntityPause then
                                task.wait(0.1)
                                continue
                        end

                        local AutoHotelDoor, AutoHotelRoomNum = AutoHotelGetNextClosedDoor()

                        if AutoHotelDoor and AutoHotelRoomNum and Character then
                                if AutoHotelRoomNum == 50 then
                                        if not AutoHotelLibraryConnection then
                                                AutoHotelLibraryConnection = task.spawn(function()
                                                        AutoHotelRunLibrary()
                                                        AutoHotelLibraryConnection = nil
                                                end)
                                        end
                                        task.wait(0.4)
                                else
                                        AutoHotelProcessRoom(AutoHotelRoomNum)
                                        AutoHotelHandleKey(AutoHotelRoomNum)
                                        if Character and not AutoHotelEntityPause then
                                                Character:PivotTo(AutoHotelDoor:GetPivot() * CFrame.new(0, -1, 0))
                                        end
                                end
                        end
                        task.wait(0.15)
                end
        end)
end)

Toggles.SkipSeekMines:OnChanged(function(Value)
        if Value then
                if Floor ~= "Mines" then
                        return
                end
                task.spawn(function()
                        local MinesSkipSeekCurrentRooms

                        repeat
                                if not Toggles.SkipSeekMines.Value then
                                        return
                                end

                                MinesSkipSeekCurrentRooms = workspace:FindFirstChild("CurrentRooms")
                                task.wait()
                        until MinesSkipSeekCurrentRooms

                        local MinesSkipSeekStartRoom

                        repeat
                                if not Toggles.SkipSeekMines.Value then
                                        return
                                end

                                MinesSkipSeekCurrentRooms = workspace:FindFirstChild("CurrentRooms")

                                if MinesSkipSeekCurrentRooms then
                                        MinesSkipSeekStartRoom = MinesSkipSeekCurrentRooms:FindFirstChild("42")
                                end

                                task.wait()
                        until MinesSkipSeekStartRoom

                        local MinesSkipSeekStartDoor

                        repeat
                                if not Toggles.SkipSeekMines.Value then
                                        return
                                end

                                MinesSkipSeekStartDoor = MinesSkipSeekStartRoom:FindFirstChild("Door", true)
                                task.wait()
                        until MinesSkipSeekStartDoor

                        repeat
                                if not Toggles.SkipSeekMines.Value then
                                        return
                                end

                                task.wait()
                        until MinesSkipSeekStartDoor:GetAttribute("Opened") == true

                        if Character and Character:GetAttribute("Minecarting") == true then
                                Character:SetAttribute("Minecarting", false)
                        end

                        for _, MinesSkipSeekRoomNumber in ipairs({
                                43, 44, 45, 46, 47, 48, 49,
                                78, 79, 80, 81, 82, 83
                        }) do
                                if not Toggles.SkipSeekMines.Value then
                                        return
                                end

                                local MinesSkipSeekRoom

                                repeat
                                        if not Toggles.SkipSeekMines.Value then
                                                return
                                        end

                                        MinesSkipSeekCurrentRooms = workspace:FindFirstChild("CurrentRooms")

                                        if MinesSkipSeekCurrentRooms then
                                                MinesSkipSeekRoom = MinesSkipSeekCurrentRooms:FindFirstChild(
                                                        tostring(MinesSkipSeekRoomNumber)
                                                )
                                        end

                                        task.wait()
                                until MinesSkipSeekRoom

                                local MinesSkipSeekDoor

                                repeat
                                        if not Toggles.SkipSeekMines.Value then
                                                return
                                        end

                                        MinesSkipSeekDoor = MinesSkipSeekRoom:FindFirstChild("Door", true)
                                        task.wait()
                                until MinesSkipSeekDoor

                                repeat
                                        if not Toggles.SkipSeekMines.Value then
                                                return
                                        end

                                        if Character then
                                                Character:PivotTo(MinesSkipSeekDoor:GetPivot())
                                        end

                                        task.wait()
                                until MinesSkipSeekDoor:GetAttribute("Opened") == true

                                if MinesSkipSeekRoomNumber == 49 or MinesSkipSeekRoomNumber == 83 then
                                        if not Character then
                                                return
                                        end

                                        local MinesSkipSeekVoidPivot = Character:GetPivot()
                                        MinesSkipSeekVoidPivot = MinesSkipSeekVoidPivot + Vector3.new(0, -1000, 0)

                                        task.wait(0.3)

                                        for MinesSkipSeekVoidCount = 1, 12 do
                                                Character:PivotTo(MinesSkipSeekVoidPivot)
                                        end

                                        for MinesSkipSeekVoidCount = 1, 12 do
                                                Character:PivotTo(MinesSkipSeekVoidPivot)
                                        end

                                        for MinesSkipSeekVoidCount = 1, 12 do
                                                Character:PivotTo(MinesSkipSeekVoidPivot)
                                        end

                                        task.wait(0.3)

                                        for MinesSkipSeekVoidCount = 1, 6 do
                                                Character:PivotTo(MinesSkipSeekVoidPivot)
                                        end
                                end

                                if MinesSkipSeekRoomNumber == 83 then
                                        return
                                end
                        end
                end)
        end
end)

Globals.KnobFarmActive = false
Globals.KnobFarmStarted = false
Toggles.KnobFarm:OnChanged(function(Value)
        if Value then
                Functions.Notify({ Title = "Collect some gold to earn knobs.", Body = "Click 'Start Knob Farm' when you're ready." })
        else
                Globals.KnobFarmStarted = false
        end
end)
local function StartKnobFarm()
        if LatestRoom.Value ~= 0 then
                Functions.Notify({ Title = "You must be in Room 0 to use this." })
                return
        end
        if LocalPlayer.PlayerGui:FindFirstChild("TopbarUI") then
                local Ok, GoldCount = pcall(function()
                        return LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Gold.GoldVal
                end)
                if Ok and GoldCount and GoldCount.Value <= 0 then
                        Functions.Notify({ Title = "You must have gold to do this." })
                        return
                end
        end
        Globals.KnobFarmStarted = true
end
FX.StartKnobFarm = StartKnobFarm
if Ex.KnobFarmAuto == nil then Ex.KnobFarmAuto = true end
Toggles.KnobFarm:OnChanged(function(Value)
        if not (Value and Ex.KnobFarmAuto) then return end
        task.spawn(function()
                local t0 = tick()
                while Toggles.KnobFarm.Value and not Globals.KnobFarmStarted and tick() - t0 < 120 do
                        if LatestRoom.Value == 0 then
                                local Ok, Gold = pcall(function()
                                        return LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Gold.GoldVal.Value
                                end)
                                if Ok and Gold and Gold > 0 then StartKnobFarm() break end
                        end
                        task.wait(1)
                end
        end)
end)
Connections.KnobFarm = Services.RunService.Heartbeat:Connect(function()
        if Toggles.KnobFarm.Value and Globals.KnobFarmStarted then
                if not Globals.KnobFarmActive then
                        Globals.KnobFarmActive = true
                        if Functions.CheckCompatability({"replicatesignal"}) then
                                Env.replicatesignal(LocalPlayer.Kill)
                        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                LocalPlayer.Character.Humanoid.Health = 0
                        end
                        while task.wait() do
                                if LocalPlayer:GetAttribute("Alive") then break end
                        end
                        if RemotesFolder and RemotesFolder:FindFirstChild("Statistics") then
                                RemotesFolder.Statistics:FireServer()
                        end
                        task.wait(0.25)
                        Globals.KnobFarmActive = false
                end
        end
end)

Globals.LastAutoHide = tick()
Connections.AutoHideConnection = Services.RunService.Heartbeat:Connect(function()
        if not Toggles.AutoClosetToggle.Value or tick() - Globals.LastAutoHide <= 0.1 or not (Character and RemotesFolder) then
                Globals.AutoClosetActive = false
                return
        end
        local Entity = Functions.GetNearestEntity(true, Options.AutoClosetEntityList.Value)
        local EntityNearby = Entity and LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position) <= (EntityDistances[Entity.Name] or 150)
        if Character:GetAttribute("Hiding") == true then
                Globals.AutoClosetActive = false
                Globals.SpectateEntity = nil
                if not EntityNearby and RemotesFolder:FindFirstChild("CamLock") then
                        RemotesFolder.CamLock:FireServer()
                end
                if EntityNearby and Toggles.SpectateEntityToggle.Value and Entity.PrimaryPart then
                        Globals.SpectateEntity = Entity
                end
                Globals.LastAutoHide = tick()
                return
        end
        if not Entity or not EntityNearby then
                Globals.SpectateEntity = nil
                Globals.AutoClosetActive = false
                Globals.LastAutoHide = tick()
                return
        end
        local Closet = FindNearestHidingSpot()
        if Closet then
                local Prompt = GetHidePrompt(Closet)
                if Prompt then
                        Globals.AutoClosetActive = true
                        FirePromptSafe(Prompt)
                end
        end
        Globals.LastAutoHide = tick()
end)

Connections.SpectateEntityConnection = Services.RunService.RenderStepped:Connect(function()
        if Globals.SpectateEntity and Toggles.AutoClosetToggle.Value and Toggles.SpectateEntityToggle.Value and Character then
                local Cam = Workspace.CurrentCamera
                local Entity = Globals.SpectateEntity
                if not (Cam and Entity.Parent and Entity.PrimaryPart and Character:FindFirstChild("Head")) then return end
                if Options.SpecateEntityMode.Value == "Player to Entity" then
                        Cam.CFrame = CFrame.lookAt(Character.Head.Position, Entity.PrimaryPart.Position)
                else
                        Cam.CFrame = CFrame.lookAt(Entity.PrimaryPart.Position, Character.Head.Position)
                end
        end
end)

Globals.LastAutoAnchor = tick()
Connections.AutoSolveAnchorsConnection = Services.RunService.Heartbeat:Connect(function()
        if not Toggles.AutoSolveAnchors.Value or not Character or not CurrentRooms then return end
        local MainUI = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
        local Hint = MainUI and MainUI:FindFirstChild("AnchorHintFrame")
        if not Hint or tick() - Globals.LastAutoAnchor <= 0.1 then return end
        Globals.LastAutoAnchor = tick()
        local CodeLabel = Hint:FindFirstChild("AnchorCode")
        local EnteredLabel = Hint:FindFirstChild("Code")
        if not (CodeLabel and EnteredLabel) then return end
        for _, Room in ipairs(CurrentRooms:GetChildren()) do
                local Anchor = Room:FindFirstChild("MinesAnchor", true)
                if Anchor and Anchor:FindFirstChild("Sign") and Anchor.PrimaryPart then
                        local Sign = Anchor.Sign:FindFirstChild("TextLabel")
                        local Prompt = Anchor:FindFirstChild("ActivateEventPrompt")
                        if Sign and Sign.Text == CodeLabel.Text and Prompt and not Anchor:GetAttribute("Activated")
                                and LocalPlayer:DistanceFromCharacter(Anchor.PrimaryPart.Position) < Prompt.MaxActivationDistance then
                                local Remote = Anchor:FindFirstChild("AnchorRemote")
                                if Remote then
                                        pcall(function() Remote:InvokeServer(EnteredLabel.Text) end)
                                end
                        end
                end
        end
end)

Functions.GetLibraryCode = function()
        if not Character then return nil end
        local Paper = Character:FindFirstChild("LibraryHintPaper")
                or Character:FindFirstChild("LibraryHintPaperHard")
                or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaper")
                or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaperHard")
        if Paper and Paper:FindFirstChild("UI") then
                local Code = {}
                local CodeLength = Floor == "Fools" and 10 or 5
                for I = 1, CodeLength do Code[I] = "_" end
                local HintsFolder = LocalPlayer.PlayerGui:FindFirstChild("PermUI") and LocalPlayer.PlayerGui.PermUI:FindFirstChild("Hints")
                if not HintsFolder then return nil end
                for _, Hint in HintsFolder:GetChildren() do
                        for _, UIChild in Paper.UI:GetChildren() do
                                if Hint:IsA("ImageLabel") and UIChild:IsA("ImageLabel")
                                        and Hint.ImageRectOffset == UIChild.ImageRectOffset
                                        and Code[tonumber(UIChild.Name)]
                                then
                                        Code[tonumber(UIChild.Name)] = Hint.TextLabel.Text
                                end
                        end
                end
                return table.concat(Code)
        end
        return nil
end
task.spawn(function()
        while true do
                task.wait(0.25)
                if Toggles.AutoUnlockPadlockToggle.Value and RemotesFolder and RemotesFolder:FindFirstChild("PL") then
                        pcall(function()
                                local Padlock = Workspace:FindFirstChild("Padlock", true)
                                if Padlock and Padlock.PrimaryPart then
                                        local Code = Functions.GetLibraryCode()
                                        local Distance = LocalPlayer:DistanceFromCharacter(Padlock.PrimaryPart.Position)
                                        if Code and tonumber(Code) and Distance < Options.AutoUnlockPadlockSlider.Value then
                                                RemotesFolder.PL:FireServer(Code)
                                        end
                                end
                        end)
                end
        end
end)

local AntiScribblesConnection
Toggles.AntiScribbles:OnChanged(function(Value)
        if AntiScribblesConnection then
                AntiScribblesConnection:Disconnect()
                AntiScribblesConnection = nil
        end
        if not Value then return end
        AntiScribblesConnection = Workspace.ChildAdded:Connect(function(Child)
                if Child.Name == "Scribbles" and Toggles.AntiScribbles.Value then
                        local Warning = Child:FindFirstChild("IfYoureExploitingDeleteThis")
                        if Warning then Warning:Destroy() end
                end
        end)
end)

local MainGameModule
task.spawn(function()
        while true do
                task.wait(1)
                if not MainGameModule and Env.require then
                        pcall(function()
                                local MainUI = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
                                local Module = MainUI and MainUI:FindFirstChild("Initiator") and MainUI.Initiator:FindFirstChild("Main_Game")
                                if Module then MainGameModule = Env.require(Module) end
                        end)
                end
        end
end)
Services.RunService.RenderStepped:Connect(function()
        if MainGameModule then
                pcall(function()
                        if Toggles.ViewmodelOffsetToggle.Value then
                                MainGameModule.tooloffset = Vector3.new(Options.ViewmodelOffsetX.Value, Options.ViewmodelOffsetY.Value, Options.ViewmodelOffsetZ.Value)
                        elseif Globals.ViewmodelWasOn then
                                MainGameModule.tooloffset = Vector3.zero
                        end
                        Globals.ViewmodelWasOn = Toggles.ViewmodelOffsetToggle.Value
                end)
        end
end)

Globals.RoomsNodesFolder = Workspace:FindFirstChild("RON_RoomsNodes") or Instance.new("Folder")
Globals.RoomsNodesFolder.Name = "RON_RoomsNodes"
Globals.RoomsNodesFolder.Parent = Workspace
Toggles.RoomsAutoWalk:OnChanged(function()
        for _, Object in Globals.RoomsNodesFolder:GetChildren() do
                if Object.Name == "PathNode" then Object:Destroy() end
        end
end)
Toggles.RoomsAutoWalkShowPathToggle:OnChanged(function(Value)
        for _, Object in Globals.RoomsNodesFolder:GetChildren() do
                if Object.Name == "PathNode" then Object.Transparency = Value and 0.5 or 1 end
        end
end)

if Functions.CheckCompatability({"hookmetamethod", "newcclosure"}) then
        local OtherHook
        OtherHook = Env.hookmetamethod(game, "__index", Env.newcclosure(function(Self, Property)
                local Real = OtherHook(Self, Property)
                if Property == "MoveDirection" and Humanoid and Self == Humanoid and Globals.RoomsAutoWalkActive
                        and Toggles.RoomsAutoWalkSpoofFootsteps.Value and Floor == "Rooms"
                        and Character and RootPart and not Character:GetAttribute("Hiding") then
                        return RootPart.CFrame.LookVector
                end
                return Real
        end))
end

Functions.RoomsAutoWalk = {}
Functions.RoomsAutoWalk.GetNearestHidingSpot = function()
        local Nearest = { Distance = math.huge, Object = nil }
        for _, Object in Objects.HidingSpots do
                if Object.PrimaryPart and Object:FindFirstChild("HidePrompt") then
                        local Distance = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
                        if Distance < Nearest.Distance and Object.PrimaryPart.Position.Y > -10 then
                                local HiddenPlayer = Object:FindFirstChild("HiddenPlayer", true)
                                if HiddenPlayer and not HiddenPlayer.Value then
                                        Nearest.Distance = Distance
                                        Nearest.Object = Object
                                end
                        end
                end
        end
        return Nearest.Object
end

local RoomsEntityList = { "RushMoving","AmbushMoving","BackdoorRush","A60","A120","CustomEntity","GlitchRush","GlitchAmbush" }
Functions.RoomsAutoWalk.GetPathfindTarget = function()
        for _, Object in Services.Workspace:GetChildren() do
                if table.find(RoomsEntityList, Object.Name) and Object.PrimaryPart then
                        local Y = Object.PrimaryPart.Position.Y
                        if Y > -10 and Y < 150 then
                                if Object.Name == "A60" and not Toggles.RoomsAutoWalkIgnoreA60.Value or Object.Name ~= "A60" then
                                        return Functions.RoomsAutoWalk.GetNearestHidingSpot() or CurrentRooms[tostring(LatestRoom.Value)]:FindFirstChild("RoomExit")
                                end
                        end
                end
        end
        return CurrentRooms[tostring(LatestRoom.Value)]:FindFirstChild("RoomExit")
end

Connections.RoomsAutoWalkHandler = Services.RunService.Heartbeat:Connect(function()
        if Floor ~= "Rooms" or not Toggles.RoomsAutoWalk.Value or Globals.RoomsAutoWalkActive or not CollisionPart or LatestRoom.Value >= 1000 then return end
        Globals.RoomsAutoWalkActive = true

        local Path = Services.PathfindingService:CreatePath({
                AgentCanJump = true, AgentCanClimb = false, WaypointSpacing = 4,
                AgentRadius = 1.5, AgentHeight = 1.5, Costs = { StuckPart = 8 }
        })

        if Toggles.RoomsAutoWalkIgnoreA60.Value and not Toggles.PositionSpoof.Value then
                Toggles.PositionSpoof:SetValue(true)
        end

        local TargetPart = Functions.RoomsAutoWalk.GetPathfindTarget()
        if not TargetPart then
                Globals.RoomsAutoWalkActive = false
                return
        end

        local TargetPosition
        if TargetPart.Name == "RoomExit" then
                TargetPosition = TargetPart.Position
        elseif TargetPart:FindFirstChild("HidePrompt") then
                for _, Part in TargetPart:GetDescendants() do
                        if Part:IsA("BasePart") then Part.CanCollide = false end
                end
                TargetPosition = TargetPart.PrimaryPart.Position
        end

        if CollisionPart.Anchored and not TargetPart:FindFirstChild("HidePrompt") then
                Character:SetAttribute("Hiding", true)
                RemotesFolder.CamLock:FireServer()
                Character:SetAttribute("Hiding", false)
        end

        local CurrentRoom = CurrentRooms[tostring(LatestRoom.Value)]
        if CurrentRoom:FindFirstChild("Door") then
                CurrentRoom.Door.Door.CanCollide = false
        end

        if not TargetPosition or LocalPlayer:DistanceFromCharacter(TargetPosition) >= 750 then
                Globals.RoomsAutoWalkActive = false
                return
        end

        Path:ComputeAsync(CollisionPart.Position, TargetPosition)
        local Waypoints = Path:GetWaypoints()

        if #Waypoints == 0 then
                local RoomExit = CurrentRoom:FindFirstChild("RoomExit")
                if RoomExit then Humanoid:MoveTo(RoomExit.Position) end
                Globals.RoomsAutoWalkActive = false
                return
        end

        for _, Node in Globals.RoomsNodesFolder:GetChildren() do
                if Node.Name == "PathNode" then Node:Destroy() end
        end

        for _, Waypoint in Waypoints do
                local Block = Instance.new("Part", Globals.RoomsNodesFolder)
                Block.Transparency = Toggles.RoomsAutoWalkShowPathToggle.Value and 0.5 or 1
                Block.Size = Vector3.one
                Block.Position = Waypoint.Position
                Block.Shape = Enum.PartType.Ball
                Block.CanCollide = false
                Block.Anchored = true
                Block.Name = "PathNode"
                Block.Color = Options.RoomsAutoWalkShowPathColor.Value
                Block.Material = Enum.Material.Neon
        end

        local Stuck = false
        for _, Waypoint in Waypoints do
                if Stuck or not Toggles.RoomsAutoWalk.Value then break end

                local Finished = false
                local Start = tick()

                local StepConnection = Services.RunService.RenderStepped:Connect(function()
                        if Stuck or not Toggles.RoomsAutoWalk.Value then Finished = true return end

                        local NewTarget = Functions.RoomsAutoWalk.GetPathfindTarget()
                        if NewTarget and NewTarget:FindFirstChild("HidePrompt") and not TargetPart:FindFirstChild("HidePrompt") then
                                Finished = true return
                        end
                        if TargetPart:FindFirstChild("HidePrompt") then
                                local HidePrompt = TargetPart:FindFirstChild("HidePrompt")
                                if LocalPlayer:DistanceFromCharacter(TargetPosition) < HidePrompt.MaxActivationDistance
                                        and Character:GetAttribute("Hiding") ~= true
                                then
                                        Functions.ForceFirePrompt(HidePrompt)
                                end
                        end
                        local FlatPos = Vector3.new(Waypoint.Position.X, RootPart.Position.Y, Waypoint.Position.Z)
                        if LocalPlayer:DistanceFromCharacter(FlatPos) < 5 then Finished = true end
                        Humanoid:MoveTo(Waypoint.Position)
                end)

                while not Finished do
                        if tick() - Start > Options.RoomsAutoWalkPathfindTimeout.Value then
                                local StuckBlock = Instance.new("Part", Globals.RoomsNodesFolder)
                                StuckBlock.Transparency = 1
                                StuckBlock.Size = Vector3.one
                                StuckBlock.CFrame = Collision.CFrame
                                StuckBlock.Shape = Enum.PartType.Ball
                                StuckBlock.CanCollide = false
                                StuckBlock.Anchored = true
                                StuckBlock.Name = "StuckPart"
                                local Modifier = Instance.new("PathfindingModifier", StuckBlock)
                                Modifier.Label = "StuckPart"
                                Stuck = true
                                break
                        end
                        task.wait()
                end
                StepConnection:Disconnect()
                Humanoid:MoveTo(RootPart.Position)
        end

        Globals.RoomsAutoWalkActive = false
end)

local function PTog(tab, id, title, desc)
        AddToggle(tab, id, title, desc, Ex[id], function(v) Apply(id, v) end)
end
local function PSlider(tab, id, title, desc, min, max, step)
        R4N_KeyTab[id] = tab
        local el = tab:Slider({
                Title = title, Desc = desc, Step = step or 1,
                Value = { Min = min, Max = max, Default = Ex[id] },
                Callback = function(v) Apply(id, v) end,
        })
        Setters[id] = function(v) pcall(function() el:Set(v) end) end
end

AutomationTab:Section({ Title = "Hotel" })
PTog(AutomationTab, "SkipSeekHotel", "Skip Seek (Hotel)", "Skips the entire Seek sections.")
PTog(AutomationTab, "AutoLibrary", "Auto Library", "Automatically gets the books and the hint paper in room 50.")
PTog(AutomationTab, "AutoBreakerRoom", "Auto Breaker Room", "Automatically completes the breaker sequence in Hotel Room 100.")
PTog(AutomationTab, "AutoUnlockPadlockToggle", "Auto Unlock Padlock", "Automatically enters the code into the library padlock.")
PSlider(AutomationTab, "AutoUnlockPadlockSlider", "Unlock Distance", "How close you must be to the padlock.", 1, 50)
PTog(AutomationTab, "AutoHotel", "Auto Hotel", "Automatically progresses through the hotel floor. Risky.")
PTog(AutomationTab, "AutoHotelIgnoreEntities", "Ignore Entities", "Skip all entity waits and pauses.")
PSlider(AutomationTab, "AutoHotelRoomProcess", "Room Process Time", "Seconds Auto Hotel waits before processing each room.", 0.1, 2, 0.1)

AutomationTab:Section({ Title = "Hiding & Anchors" })
PTog(AutomationTab, "AutoClosetToggle", "Auto Closet", "Automatically hides in a nearby closet when an entity is near.")
AutomationTab:Dropdown({
        Title = "Auto-closet ignore list",
        Desc = "Entities Auto-Closet will NOT hide from.",
        Values = { "Rush", "Ambush", "Blitz", "DronesStampede", "Scribbles", "A-60", "A-120", "AR0xMBUSH", "RNIUSHCG==" },
        Value = {}, Multi = true, AllowNone = true,
        Callback = function(selected)
                local set = {}
                for _, n in ipairs(selected or {}) do set[n] = true end
                Ex.AutoClosetEntityList = set
        end,
})
PTog(AutomationTab, "SpectateEntityToggle", "Spectate Entity", "Spectates the entity while auto hiding.")
AutomationTab:Dropdown({
        Title = "Spectate mode", Desc = "Where the camera looks from.",
        Values = { "Player to Entity", "Entity to Player" }, Value = "Player to Entity",
        Callback = function(v) Ex.SpecateEntityMode = v end,
})
PTog(AutomationTab, "AutoSolveAnchors", "Auto Solve Anchors", "Automatically enters the correct code into anchors when you are near them.")

AutomationTab:Section({ Title = "Mines & Rooms" })
PTog(AutomationTab, "SkipSeekMines", "Skip Seek (Mines)", "Skips the entire Seek sections. Risky outside Mines.")
PTog(AutomationTab, "RoomsAutoWalk", "Auto Rooms", "Automatically moves and hides from entities in The Rooms.")
PSlider(AutomationTab, "RoomsAutoWalkPathfindTimeout", "Pathfind Timeout", "Seconds before a path step counts as stuck.", 0.5, 3, 0.1)
PTog(AutomationTab, "RoomsAutoWalkIgnoreA60", "Ignore A-60", "Keeps walking if A-60 is present, enables position spoof automatically.")
PTog(AutomationTab, "RoomsAutoWalkShowPathToggle", "Show Path", "Shows the current path of Auto Rooms.")
PTog(AutomationTab, "RoomsAutoWalkSpoofFootsteps", "Spoof Footsteps", "Makes it appear as if your character is walking normally.")

AutomationTab:Section({ Title = "Farming" })
PTog(AutomationTab, "KnobFarm", "Knob Farm", "Automatically gains knobs for you, dies and revives repeatedly. Risky.")
PTog(AutomationTab, "KnobFarmAuto", "Knob Farm Auto Start", "When Knob Farm is on, it starts by itself as soon as you are in Room 0 and have gold (no need to press Start).")
AutomationTab:Button({ Title = "Start Knob Farm", Desc = "Starts farming knobs; click when you have enough gold.", Callback = StartKnobFarm })

ArchivesTab:Section({ Title = "Scribbles" })
PTog(ArchivesTab, "AntiScribbles", "Bypass Scribbles", "Prevents 'Scribbles' from attacking you.")

VisualsTab:Section({ Title = "Viewmodel" })
PTog(VisualsTab, "ViewmodelOffsetToggle", "Viewmodel Offset", "Changes the offset of your viewmodel while holding an item.")
PSlider(VisualsTab, "ViewmodelOffsetX", "X Offset", "", -10, 10)
PSlider(VisualsTab, "ViewmodelOffsetY", "Y Offset", "", -10, 10)
PSlider(VisualsTab, "ViewmodelOffsetZ", "Z Offset", "", -10, 10)

MiscTab:Section({ Title = "Debug Tools" })
MiscTab:Button({ Title = "Fix ladder softlock", Desc = "Fixes getting stuck after a ladder.", Callback = function()
        LocalPlayer:SetAttribute("Climbing", false)
        if Character then Character:SetAttribute("Climbing", false) end
end })
MiscTab:Button({ Title = "Print current floor", Desc = "Prints the current floor to the console.", Callback = function()
        local gd = Services.ReplicatedStorage:FindFirstChild("GameData")
        local fv = gd and gd:FindFirstChild("Floor")
        print("Current Floor:", fv and fv.Value)
        NotifyUI("Current Floor", tostring(fv and fv.Value))
end })
MiscTab:Button({ Title = "Print current room", Desc = "Prints the current room number to the console.", Callback = function()
        print("Current Room:", LocalPlayer:GetAttribute("CurrentRoom"))
        NotifyUI("Current Room", tostring(LocalPlayer:GetAttribute("CurrentRoom")))
end })
MiscTab:Button({ Title = "Void", Desc = "Teleports the character to Y -120.", Callback = function()
        if not Character then return end
        local Pivot = Character:GetPivot()
        for _ = 1, 22 do
                Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
        end
end })
MiscTab:Button({ Title = "Die", Desc = "Kills the character.", Callback = function()
        Globals.Deathing = true
        if Humanoid then Humanoid.Health = 0 end
end })
MiscTab:Button({ Title = "Reset character", Desc = "Kills the character on the server (may take ~20s without replicatesignal).", Callback = function()
        Globals.SelfKilled = true
        if Functions.CheckCompatability({"replicatesignal"}) then
                Env.replicatesignal(LocalPlayer.Kill)
        elseif RemotesFolder and RemotesFolder:FindFirstChild("Underwater") then
                RemotesFolder.Underwater:FireServer(true)
        elseif Humanoid then
                Humanoid.Health = 0
        end
end })

;(function()
local RS = game:GetService("ReplicatedStorage")
local RunSvc = game:GetService("RunService")

local FUN = { T = {}, Model = nil, Root = nil, Fallback = false, Kind = nil, Drop = 3, Base = 1, PrevTP = nil, Cap = {}, CapT = 0, Bob = 0 }
R4N_FUN = FUN
Ex.Fun_Kind, Ex.Fun_Active, Ex.Fun_Size, Ex.Fun_YOff, Ex.Fun_Face = "Seek", false, 100, 0, "Forward"
Ex.Fun_Hide, Ex.Fun_TP, Ex.Fun_Anim = true, true, true

local holder = Instance.new("Folder")
holder.Name = "R4N_FunHolder"
holder.Parent = Workspace
R4N_FunHolder = holder

local SEARCH = {
        Seek   = { "SeekMovingNewClone", "SeekMoving", "SeekRig", "SeekModel", "Seek" },
        Figure = { "FigureRig", "FigureRagdoll", "Figure" },
        Honcho = { "HonchoRig", "HonchoNPC", "HonchoModel", "Honcho" },
}
local EXACT = {}
for kind, list in pairs(SEARCH) do
        for _, n in ipairs(list) do EXACT[n:lower()] = kind end
end
local BAD = { "arm", "light", "trigger", "obstruction", "wall", "room", "box", "deposit", "terminal", "mug", "door", "sign", "path", "setup", "chase", "gui", "sound", "hand", "eye" }

local function NameOk(kind, n)
        local l = n:lower()
        if EXACT[l] == kind then return true end
        if kind == "Honcho" or kind == "Seek" then
                if l:find(kind:lower(), 1, true) then
                        for _, b in ipairs(BAD) do
                                if l:find(b, 1, true) then return false end
                        end
                        return true
                end
        end
        return false
end

local function Valid(kind, m)
        if not m or not m:IsA("Model") or not m.Parent then return false end
        if m:IsDescendantOf(holder) or Players:GetPlayerFromCharacter(m) then return false end
        local parts = 0
        for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("BasePart") then
                        parts = parts + 1
                        if parts >= 3 then break end
                end
        end
        if parts < 3 then return false end
        local ok, size = pcall(m.GetExtentsSize, m)
        if not ok or size.Magnitude > 70 then return false end
        return true
end

local function Capture(kind, m)
        local ok, c = pcall(function() return m:Clone() end)
        if not ok or not c then return false end
        local old = FUN.T[kind]
        FUN.T[kind] = c
        if old then pcall(old.Destroy, old) end
        NotifyUI("Fun", kind .. " model captured.")
        if Ex.Fun_Active and Ex.Fun_Kind == kind and FUN.Fallback and FUN.Attach then
                task.defer(FUN.Attach)
        end
        return true
end

function FUN.Find(kind, deep)
        for _, root in ipairs({ Workspace, RS }) do
                for _, nm in ipairs(SEARCH[kind]) do
                        local c = root:FindFirstChild(nm, true)
                        if c and Valid(kind, c) then return c end
                end
        end
        if deep then
                local n = 0
                for _, root in ipairs({ RS, Workspace:FindFirstChild("LiveEntities"), Workspace:FindFirstChild("CurrentRooms") }) do
                        if root then
                                for _, d in ipairs(root:GetDescendants()) do
                                        if d:IsA("Model") and NameOk(kind, d.Name) and Valid(kind, d) then return d end
                                        n = n + 1
                                        if n % 800 == 0 then task.wait() end
                                end
                        end
                end
        end
        return nil
end

function FUN.Rescan(deep)
        task.spawn(function()
                local got = {}
                for kind in pairs(SEARCH) do
                        if not FUN.T[kind] then
                                local m = FUN.Find(kind, deep)
                                if m and Capture(kind, m) then got[#got + 1] = kind end
                        end
                end
                if deep then
                        NotifyUI("Fun", #got > 0 and ("Found: " .. table.concat(got, ", ")) or "No new models found. They are captured when the entity appears.")
                end
        end)
end

Workspace.DescendantAdded:Connect(function(d)
        if not d:IsA("Model") then return end
        local l = d.Name:lower()
        local kind = EXACT[l]
        if not kind then
                if l:find("honcho", 1, true) then kind = "Honcho" elseif l:find("seek", 1, true) then kind = "Seek" end
        end
        if not kind or FUN.T[kind] and FUN.Cap[kind] then return end
        if d:IsDescendantOf(holder) then return end
        task.delay(1.5, function()
                if d.Parent and NameOk(kind, d.Name) and Valid(kind, d) then
                        FUN.Cap[kind] = true
                        Capture(kind, d)
                end
        end)
end)

local function Fallback(kind)
        local m = Instance.new("Model")
        m.Name = "R4N_FunModel"
        local root = Instance.new("Part")
        root.Name = "HumanoidRootPart"
        root.Size = Vector3.new(2, 2, 1)
        root.Transparency = 1
        root.Anchored = true
        root.CanCollide = false
        root.Parent = m
        m.PrimaryPart = root
        local function P(name, size, off, color, shape, mat)
                local p = Instance.new("Part")
                p.Name = name
                p.Size = size
                p.CFrame = CFrame.new(off)
                p.Color = color
                p.Material = mat or Enum.Material.SmoothPlastic
                if shape then p.Shape = shape end
                p.CanCollide = false
                p.Massless = true
                p.Parent = m
                return p
        end
        local V, C = Vector3.new, Color3.fromRGB
        local Ball = Enum.PartType.Ball
        if kind == "Seek" then
                local black = C(14, 14, 14)
                P("Torso", V(2.4, 4, 1.4), V(0, 2, 0), black)
                P("Head", V(3.2, 3.2, 3.2), V(0, 5.2, 0), black, Ball)
                P("Eye", V(1.9, 1.9, 1.9), V(0, 5.3, -1.25), C(255, 255, 255), Ball, Enum.Material.Neon)
                P("Pupil", V(0.8, 0.8, 0.8), V(0, 5.3, -2.1), black, Ball)
                P("ArmL", V(0.8, 6, 0.8), V(-1.9, 1.5, -0.4), black)
                P("ArmR", V(0.8, 6, 0.8), V(1.9, 1.5, -0.4), black)
                P("LegL", V(1, 4, 1), V(-0.7, -2, 0), black)
                P("LegR", V(1, 4, 1), V(0.7, -2, 0), black)
        elseif kind == "Figure" then
                local body = C(74, 58, 48)
                P("Torso", V(2.2, 4.8, 1.2), V(0, 2.4, 0), body)
                P("Head", V(1.8, 2.2, 1.8), V(0, 6.1, 0), C(214, 196, 160))
                P("Wrap", V(1.9, 0.7, 1.9), V(0, 6.2, 0), C(235, 230, 215))
                P("ArmL", V(0.7, 5.5, 0.7), V(-1.6, 2.4, 0), body)
                P("ArmR", V(0.7, 5.5, 0.7), V(1.6, 2.4, 0), body)
                P("LegL", V(0.9, 4.8, 0.9), V(-0.6, -2.4, 0), body)
                P("LegR", V(0.9, 4.8, 0.9), V(0.6, -2.4, 0), body)
        else
                local suit = C(28, 36, 64)
                P("Torso", V(2.2, 3, 1.2), V(0, 1.5, 0), suit)
                P("Shirt", V(0.9, 2.6, 0.1), V(0, 1.6, -0.65), C(240, 240, 240))
                P("Tie", V(0.35, 1.8, 0.1), V(0, 1.3, -0.72), C(190, 25, 35))
                P("Head", V(1.8, 1.8, 1.8), V(0, 4, 0), C(224, 172, 105), Ball)
                P("Glasses", V(1.7, 0.35, 0.15), V(0, 4.1, -0.85), C(10, 10, 10))
                P("ArmL", V(0.8, 3, 0.8), V(-1.6, 1.6, 0), suit)
                P("ArmR", V(0.8, 3, 0.8), V(1.6, 1.6, 0), suit)
                P("LegL", V(0.9, 3.2, 0.9), V(-0.6, -1.6, 0), C(40, 40, 46))
                P("LegR", V(0.9, 3.2, 0.9), V(0.6, -1.6, 0), C(40, 40, 46))
        end
        return m
end

local Hidden = { Parts = {}, Decals = {}, T = 0 }
local function RefreshChar()
        Hidden.Parts, Hidden.T = {}, os.clock()
        local char = LocalPlayer.Character
        if not char then return end
        for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") then
                        Hidden.Parts[#Hidden.Parts + 1] = d
                elseif (d:IsA("Decal") or d:IsA("Texture")) and Hidden.Decals[d] == nil then
                        Hidden.Decals[d] = d.Transparency
                end
        end
end
local function ShowChar()
        for _, p in ipairs(Hidden.Parts) do
                if p.Parent then p.LocalTransparencyModifier = 0 end
        end
        for d, t in pairs(Hidden.Decals) do
                if d.Parent then d.Transparency = t end
        end
        Hidden.Parts, Hidden.Decals = {}, {}
end

local FACE = { Forward = 0, Backward = math.pi, Left = math.pi / 2, Right = -math.pi / 2 }

local function Prep(model)
        for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("ProximityPrompt") or d:IsA("ClickDetector") or d:IsA("Highlight") then
                        pcall(d.Destroy, d)
                elseif d:IsA("BasePart") then
                        d.Anchored = false
                        d.CanCollide = false
                        d.CanQuery = false
                        d.CanTouch = false
                        d.Massless = true
                        d.CastShadow = false
                elseif d:IsA("Humanoid") then
                        pcall(function()
                                d.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                                d.PlatformStand = true
                                d.WalkSpeed = 0
                        end)
                end
        end
end

local function PickRoot(model)
        local r = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("RootPart")
        if r and r:IsA("BasePart") then return r end
        local best, bs = nil, -1
        for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") then
                        local s = d.Size.X * d.Size.Y * d.Size.Z
                        if s > bs then best, bs = d, s end
                end
        end
        return best
end

local function Measure()
        local m, root = FUN.Model, FUN.Root
        if not m or not root then return end
        local ok, cf, size = pcall(m.GetBoundingBox, m)
        if ok then FUN.Drop = math.max(root.Position.Y - (cf.Position.Y - size.Y / 2), 0.5) end
end

local function SetupAnims(model)
        FUN.Idle, FUN.Walk, FUN.Playing = nil, nil, nil
        local animator = model:FindFirstChildWhichIsA("Animator", true)
        if not animator then return end
        local idle, walk, any
        for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("Animation") and d.AnimationId ~= "" then
                        local l = d.Name:lower()
                        any = any or d
                        if l:find("idle", 1, true) or l:find("stand", 1, true) then idle = idle or d end
                        if l:find("walk", 1, true) or l:find("run", 1, true) or l:find("chase", 1, true) or l:find("move", 1, true) then walk = walk or d end
                end
        end
        pcall(function()
                if idle then FUN.Idle = animator:LoadAnimation(idle) FUN.Idle.Looped = true end
                if walk then FUN.Walk = animator:LoadAnimation(walk) FUN.Walk.Looped = true end
                if not FUN.Idle and not FUN.Walk and any then FUN.Walk = animator:LoadAnimation(any) FUN.Walk.Looped = true end
        end)
end

local function Detach()
        if FUN.Model then pcall(FUN.Model.Destroy, FUN.Model) end
        FUN.Model, FUN.Root, FUN.Idle, FUN.Walk, FUN.Playing = nil, nil, nil, nil, nil
        ShowChar()
        if FUN.PrevTP ~= nil then
                local prev = FUN.PrevTP
                FUN.PrevTP = nil
                if Ex.ThirdPerson ~= prev then pcall(SetFeature, "ThirdPerson", prev) end
        end
end

function FUN.Attach()
        if FUN.Model then pcall(FUN.Model.Destroy, FUN.Model) end
        FUN.Model, FUN.Root = nil, nil
        local kind = Ex.Fun_Kind
        FUN.Kind = kind
        local tpl = FUN.T[kind]
        local model
        if tpl then
                local ok, c = pcall(function() return tpl:Clone() end)
                if ok and c then model = c end
        end
        FUN.Fallback = model == nil
        if not model then
                model = Fallback(kind)
                NotifyUI("Fun", "The real " .. kind .. " model has not been found yet: using an approximate one. It changes by itself when the real one is captured.")
                FUN.Rescan(false)
        end
        model.Name = "R4N_FunModel"
        Prep(model)
        local root = PickRoot(model)
        if not root then model:Destroy() return end
        model.PrimaryPart = root
        model.Parent = holder
        local okc, conn = pcall(root.GetConnectedParts, root, true)
        local linked = {}
        if okc then for _, p in ipairs(conn) do linked[p] = true end end
        for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") and d ~= root and not linked[d] then
                        local w = Instance.new("WeldConstraint")
                        w.Part0, w.Part1 = root, d
                        w.Parent = d
                end
        end
        root.Anchored = true
        FUN.Model, FUN.Root = model, root
        FUN.Base = 1
        pcall(function() FUN.Base = model:GetScale() end)
        pcall(function() model:ScaleTo(FUN.Base * (Ex.Fun_Size or 100) / 100) end)
        Measure()
        if Ex.Fun_Anim then SetupAnims(model) end
        if Ex.Fun_TP and FUN.PrevTP == nil then
                FUN.PrevTP = Ex.ThirdPerson == true
                if not Ex.ThirdPerson then pcall(SetFeature, "ThirdPerson", true) end
        end
        RefreshChar()
end

pcall(function() RunSvc:UnbindFromRenderStep("R4N_FunFollow") end)
RunSvc:BindToRenderStep("R4N_FunFollow", Enum.RenderPriority.Camera.Value + 3, function(dt)
        if not Ex.Fun_Active then return end
        local m, rootPart = FUN.Model, FUN.Root
        if not m or not m.Parent or not rootPart or not rootPart.Parent then return end
        local _, hum, root = GetParts()
        if not root then return end

        local now = os.clock()
        if Ex.Fun_Hide then
                if now - Hidden.T > 1.5 then RefreshChar() end
                for _, p in ipairs(Hidden.Parts) do
                        if p.Parent then p.LocalTransparencyModifier = 1 end
                end
                for d in pairs(Hidden.Decals) do
                        if d.Parent then d.Transparency = 1 end
                end
        end

        local pos = root.Position
        local look = root.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude < 0.05 then flat = Vector3.new(0, 0, -1) end
        local vel = root.AssemblyLinearVelocity
        local moving = Vector3.new(vel.X, 0, vel.Z).Magnitude > 2
        FUN.Bob = FUN.Bob + (moving and dt * 9 or 0)
        local bob = FUN.Fallback and moving and math.sin(FUN.Bob) * 0.18 or 0
        local feet = pos.Y - ((hum and hum.HipHeight or 2) + root.Size.Y / 2)
        local scale = (Ex.Fun_Size or 100) / 100
        local y = feet + FUN.Drop * (scale / math.max(FUN.LastScale or scale, 0.01)) + (Ex.Fun_YOff or 0) + bob
        local origin = Vector3.new(pos.X, y, pos.Z)
        local cf = CFrame.lookAt(origin, origin + flat.Unit) * CFrame.Angles(0, FACE[Ex.Fun_Face] or 0, 0)
        m:PivotTo(cf)

        if FUN.Idle or FUN.Walk then
                local want = (moving and FUN.Walk) or FUN.Idle or FUN.Walk
                if want and FUN.Playing ~= want then
                        if FUN.Playing then pcall(function() FUN.Playing:Stop(0.2) end) end
                        FUN.Playing = want
                        pcall(function() want:Play(0.2) end)
                end
        end
end)

local function Resize()
        local m = FUN.Model
        if not m then return end
        pcall(function() m:ScaleTo(FUN.Base * (Ex.Fun_Size or 100) / 100) end)
        Measure()
        FUN.LastScale = nil
end

LocalPlayer.CharacterAdded:Connect(function()
        if Ex.Fun_Active then
                task.wait(0.5)
                RefreshChar()
        end
end)

local function SetActive(v)
        Ex.Fun_Active = v
        if v then
                FUN.Attach()
        else
                Detach()
        end
end
-- Expose Detach + SetActive so the Fun tab UI can clean up properly
-- (restore character transparency, restore third-person mode, stop anims)
-- when the user turns the transform off. Without this the body stays
-- hidden and the camera stays locked in third person.
FUN.Detach = Detach
FUN.SetActive = SetActive

-- Close the Fun logic IIFE here. The Fun tab UI below is built in the
-- main scope so a silent crash inside the IIFE can never prevent it.
end)()

-- Fun tab UI — built directly in main scope (NOT inside an IIFE)
-- so a crash in the FUN logic above cannot prevent the UI from building.
FunTab:Section({ Title = "Transform" })
FunTab:Paragraph({
        Title = "How it works",
        Desc = "Client only: you see yourself as the model, other players don't. Pick one, toggle it on and the camera will switch to third person. "
                .. "The real model is saved every time that entity appears in the game (Seek chase, Figure in the Library, Honcho in Archives); "
                .. "until then an approximate model is used and it is swapped by itself.",
})
AddDropdown(FunTab, "Fun_Kind", "Transform Into", "Seek, Honcho or Figure.", { "Seek", "Honcho", "Figure" }, Ex.Fun_Kind, function(v)
        Ex.Fun_Kind = v
        if Ex.Fun_Active and R4N_FUN and R4N_FUN.Attach then R4N_FUN.Attach() end
end)
AddToggle(FunTab, "Fun_Active", "Transform Active", "Turns the transformation on / off. It always starts off.", Ex.Fun_Active, function(v)
        if R4N_FUN and R4N_FUN.SetActive then
                -- proper path: updates Ex, calls Attach or Detach
                -- Detach restores character transparency + third-person mode + stops anims
                R4N_FUN.SetActive(v)
        else
                -- fallback if Fun logic never loaded
                Ex.Fun_Active = v
                if v then
                        if R4N_FUN and R4N_FUN.Attach then R4N_FUN.Attach() end
                else
                        if R4N_FUN and R4N_FUN.Model then pcall(R4N_FUN.Model.Destroy, R4N_FUN.Model) end
                        if R4N_FUN then R4N_FUN.Model, R4N_FUN.Root = nil, nil end
                end
        end
end)
AddSlider(FunTab, "Fun_Size", "Transform Size", "Size of the model in percent (10 - 300).", 10, 300, Ex.Fun_Size, function(v)
        Ex.Fun_Size = v
        if R4N_FUN and R4N_FUN.Model then pcall(function() R4N_FUN.Model:ScaleTo((R4N_FUN.Base or 1) * v / 100) end) end
end)
AddSlider(FunTab, "Fun_YOff", "Transform Height Offset", "Moves the model up or down if it floats or sinks.", -10, 10, Ex.Fun_YOff, function(v) Ex.Fun_YOff = v end)
AddDropdown(FunTab, "Fun_Face", "Model Facing", "If the model walks sideways or backwards, change where it looks.", { "Forward", "Backward", "Left", "Right" }, Ex.Fun_Face, function(v) Ex.Fun_Face = v end)
AddToggle(FunTab, "Fun_Hide", "Hide My Character", "Hides your own body (only for you) while transformed.", Ex.Fun_Hide, function(v)
        Ex.Fun_Hide = v
        if not v and R4N_FUN then
            -- show character parts back
            for _, p in ipairs(R4N_FUN.HiddenParts or {}) do
                if p.Parent then p.LocalTransparencyModifier = 0 end
            end
        end
end)
AddToggle(FunTab, "Fun_TP", "Force Third Person While Transformed", "Moves the camera behind you so you can see the model. Your old camera mode comes back when you revert.", Ex.Fun_TP, function(v) Ex.Fun_TP = v end)
AddToggle(FunTab, "Fun_Anim", "Play Model Animations", "Plays the idle / walk animations of the model when it has them.", Ex.Fun_Anim, function(v)
        Ex.Fun_Anim = v
        if Ex.Fun_Active and R4N_FUN and R4N_FUN.Attach then R4N_FUN.Attach() end
end)
FunTab:Button({ Title = "Rescan models", Desc = "Re-scans the game for real Seek, Honcho and Figure models.", Callback = function()
    if R4N_FUN and R4N_FUN.Rescan then R4N_FUN.Rescan(true) end
end })
FunTab:Button({ Title = "Cancel transform", Desc = "Restores your normal character.", Callback = function()
        if R4N_FUN and R4N_FUN.SetActive then
                R4N_FUN.SetActive(false)
        end
        if Ex.Fun_Active then SetFeature("Fun_Active", false) end
end })

FunTab:Section({ Title = "Community Scripts" })
FunTab:Paragraph({
        Title = "Scripts from other players",
        Desc = "Paste a link to a script or module from another player (e.g. a DOORS add-on) and press Run. It only runs on click and always shows a notification with the author. "
                .. "You take full responsibility for what the script does."
})
local CS = { Name = "", Creator = "", Url = "" }
FunTab:Input({ Title = "Script name", Desc = "Name shown in the notification.", Placeholder = "Name", Callback = function(v) CS.Name = tostring(v or "") end })
FunTab:Input({ Title = "Author", Desc = "Script author (required, shown as credits).", Placeholder = "Author", Callback = function(v) CS.Creator = tostring(v or "") end })
FunTab:Input({ Title = "Script URL", Desc = "Direct URL (https://) to the script.", Placeholder = "https://", Callback = function(v) CS.Url = tostring(v or "") end })
FunTab:Button({ Title = "Run community script", Desc = "Runs the script from the URL and shows the author.", Callback = function()
    pcall(function()
        if CS.Url == "" then NotifyUI("Community Scripts", "Enter a URL first.") return end
        if CS.Creator == "" then NotifyUI("Community Scripts", "Enter the author (required).") return end
        local ok, src = pcall(function() return game:HttpGet(CS.Url) end)
        if not ok or type(src) ~= "string" or #src < 50 then
            NotifyUI("Community Scripts", "Could not download the script. Check the URL.")
            return
        end
        local fn = (loadstring or load)(src, CS.Name or "CommunityScript")
        if type(fn) ~= "function" then
            NotifyUI("Community Scripts", "Could not compile the script.")
            return
        end
        local name = CS.Name ~= "" and CS.Name or "Community script"
        NotifyUI("Community Scripts", "Running: " .. name .. " by " .. CS.Creator)
        task.spawn(function() pcall(fn) end)
    end)
end })

task.delay(3, function() if R4N_FUN and R4N_FUN.Rescan then R4N_FUN.Rescan(false) end end)
-- (Fun IIFE ends here — UI was already built above in main scope)

;(function()
local RunSvc = game:GetService("RunService")
Ex.ESPRainbow, Ex.ESPRainbowSpeed = false, 3
VisualsTab:Section({ Title = "Rainbow Highlight" })
AddToggle(VisualsTab, "ESPRainbow", "Rainbow ESP", "Every ESP (objects, entities, players, doors, gold...) cycles through the rainbow colors. Turn it off to go back to your colors.", Ex.ESPRainbow, function(v)
        Ex.ESPRainbow = v
        Cfg.Rainbow = v
        if not v then Cfg.RainbowColor = nil end
end)
AddSlider(VisualsTab, "ESPRainbowSpeed", "Rainbow Speed", "How fast the colors change (1 slow - 10 fast).", 1, 10, Ex.ESPRainbowSpeed, function(v) Ex.ESPRainbowSpeed = v end)
local acc, hue = 0, 0
RunSvc.Heartbeat:Connect(function(dt)
        if not Cfg.Rainbow or Cfg.RainbowPause then return end
        acc = acc + dt
        if acc < 1 / 30 then return end
        hue = (hue + acc * (Ex.ESPRainbowSpeed or 3) * 0.05) % 1
        acc = 0
        local c = Color3.fromHSV(hue, 1, 1)
        Cfg.RainbowColor = c
        for _, e in pairs(Tracked) do
                if e.Shown and e.HL then
                        e.HL.FillColor = c
                        e.HL.OutlineColor = c
                        if e.TL then e.TL.TextColor3 = c end
                        if e.Box then e.Box.Color3 = c end
                        if e.Line then e.Line.BackgroundColor3 = c end
                        e.Col = c
                end
        end
end)
end)()

;(function()
local RunSvc = game:GetService("RunService")
Ex.SmartPerf, Ex.FPSGuard = true, true
local P = { fps = 60, level = 0, low = 0, high = 0 }
RunSvc.Heartbeat:Connect(function(dt)
        if dt > 0 then P.fps = P.fps + (1 / dt - P.fps) * 0.05 end
end)
local G_CAP = { math.huge, 70, 40, 24 }
local G_HL = { 99, 20, 12, 8 }
local G_INT = { 0, 0.15, 0.3, 0.5 }
task.spawn(function()
        while true do
                task.wait(1)
                local f = P.fps
                if Ex.SmartPerf then
                        Watch.Budget = f >= 50 and 0.0025 or (f >= 35 and 0.0016 or (f >= 22 and 0.001 or 0.0006))
                        Watch.Budget2 = f >= 50 and 0.004 or (f >= 35 and 0.0025 or (f >= 22 and 0.0015 or 0.001))
                else
                        Watch.Budget, Watch.Budget2 = nil, nil
                end
                if Ex.SmartPerf and Ex.FPSGuard then
                        if f < 18 then P.low = P.low + 1 P.high = 0
                        elseif f > 40 then P.high = P.high + 1 P.low = 0
                        else P.low, P.high = 0, 0 end
                        if P.low >= 3 and P.level < 3 then P.level = P.level + 1 P.low = 0 end
                        if P.high >= 5 and P.level > 0 then P.level = P.level - 1 P.high = 0 end
                else
                        P.level = 0
                end
                Watch.GuardCap, Watch.GuardHL, Watch.GuardInterval = G_CAP[P.level + 1], G_HL[P.level + 1], G_INT[P.level + 1]
                Cfg.RainbowPause = P.level >= 2
        end
end)
pcall(SetFeature, "AutoPerf", true)
MiscTab:Section({ Title = "Performance" })
AddToggle(MiscTab, "SmartPerf", "Smart Performance", "Adapts how much work the script does per frame to your FPS (room loading, ESP updates). Always recommended.", Ex.SmartPerf, function(v) Ex.SmartPerf = v end)
AddToggle(MiscTab, "FPSGuard", "FPS Guard", "If your FPS stay very low it lightens the ESP (fewer Highlights, slower refresh, rainbow paused) and restores it when they recover.", Ex.FPSGuard, function(v) Ex.FPSGuard = v end)
end)()

-- (Removed duplicate Community Scripts IIFE that was here. The Community
-- Scripts section is already built earlier in the Fun tab — having it
-- twice created two identical sections with two sets of inputs/buttons.)
end)()
-- ════════════════════════════════════════════════════════════════
-- AMBUSH HUB — msdoors floor port
-- Injects floor detection (Hotel Minus / The Hollow / Ripple / Retro /
-- Ranked / Rush Mode / Super Hard Mode / Halloween25), floor-specific
-- anti-entity toggles, Haste clock, minecart teleport, Beat Door 200,
-- Auto Depot Candys, Auto Vault Minigame, Auto Skip Cutscenes, Auto
-- Forget-Me-Not family, Auto Archives Terminal, Auto Win Cringle,
-- Ranked aim/auto-block/powerups, Delete Seek/Figure (FE), No Puzzle
-- Door, Auto Revive, Death/Knob Farm, structures ESP.
-- All hooked into the existing Ex / Hooks / Apply / AddToggle core.
-- ════════════════════════════════════════════════════════════════
;(function()
local RS       = game:GetService("ReplicatedStorage")
local RunSvc   = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundSvc = game:GetService("SoundService")
local Players  = game:GetService("Players")
local Pathfind = game:GetService("PathfindingService")
local Collection = game:GetService("CollectionService")
local Hui = (gethui and gethui()) or game:GetService("CoreGui")

local function Remotes()
    return RS:FindFirstChild("RemotesFolder") or RS:FindFirstChild("EntityInfo") or RS:FindFirstChild("Bricks")
end
local function Rooms() return Workspace:FindFirstChild("CurrentRooms") end
local function Toast(t, d) pcall(FX.ShowToast, t, d or "", "", Color3.fromRGB(255, 200, 80)) end
local function CurRoom() return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0 end
local function FloorRaw()
    local gd = RS:FindFirstChild("GameData")
    local f = gd and gd:FindFirstChild("Floor")
    return f and f.Value or ""
end
local FLOOR_NICK = {
    Fools = "Super Hard Mode",
    Fools26 = "Rush Mode",
    Halloween26 = "The Hollow",
    Party = "Ranked",
    Retro = "Retro Mode",
    ["Hotel Minus"] = "Hotel Minus",
}
local function FloorNick()
    local raw = FloorRaw()
    return FLOOR_NICK[raw] or raw or ""
end

local IsHardcore = (game.PlaceId == 137519142947486 or game.PlaceId == 104289811284920 or game.PlaceId == 92934548952604 or game.PlaceId == 131351567799504)
local IsReignited = (game.PlaceId == 131351567799504)
local IsOldFloor = (FloorNick() == "Super Hard Mode" or FloorNick() == "Hotel Minus")
local IsCringleWorkshop = (Rooms() and Rooms():FindFirstChild("1") and Rooms()["1"]:FindFirstChild("FigureSetup")) and true or false

local STRUCTURES = {
    ["Stairwell"]      = { Obj = "StairwellEntrance",     Text = "Stairwell",  Img = "rbxassetid://118386530095242" },
    ["Archives"]       = { Obj = "ArchivesDoorEntrance",  Text = "Archives",   Img = "rbxassetid://106350666704258" },
    ["Mirror"]         = { Obj = "Mirror",                Text = "Mirror",     Img = "rbxassetid://91308450142221" },
    ["Rift: Jeff Shop"]      = { Obj = "RiftRoom_JeffShop",      Text = "Rift", Img = "rbxassetid://110347941622250" },
    ["Rift: Broom Closet"]   = { Obj = "RiftRoom_BroomCloset",   Text = "Rift", Img = "rbxassetid://110347941622250" },
    ["Rift: Cafe"]           = { Obj = "RiftRoom_Cafe",          Text = "Rift", Img = "rbxassetid://120828460096807" },
    ["Rift: Mines Furnace"]  = { Obj = "RiftRoom_MinesFurnace",  Text = "Rift", Img = "rbxassetid://110347941622250" },
    ["Rift: Mines Elevator"] = { Obj = "RiftRoom_MinesElevator", Text = "Rift", Img = "rbxassetid://110347941622250" },
    ["Rift: Sewer"]          = { Obj = "RiftRoom_Sewer",         Text = "Rift", Img = "rbxassetid://110347941622250" },
}

local function SetEntityHitbox(name, on, hitboxName)
    hitboxName = hitboxName or "Hitbox"
    local function apply(m)
        if not m or not m.Parent then return end
        local hb = m:FindFirstChild(hitboxName, true)
        if hb and hb:IsA("BasePart") then hb.CanTouch = on end
    end
    for _, c in ipairs(Workspace:GetChildren()) do
        if c.Name == name then apply(c) end
    end
    local rooms = Rooms()
    if rooms then
        for _, r in ipairs(rooms:GetChildren()) do
            for _, d in ipairs(r:GetDescendants()) do
                if d.Name == name then apply(d) end
            end
        end
    end
end

local function DeleteNamed(name)
    for _, c in ipairs(Workspace:GetChildren()) do
        if c.Name == name then pcall(function() c:Destroy() end) end
    end
end

local function ToggleClientModule(name, disabled)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local mu = pg and pg:FindFirstChild("MainUI")
    local ini = mu and mu:FindFirstChild("Initiator")
    local mg = ini and ini:FindFirstChild("Main_Game")
    local rl = mg and mg:FindFirstChild("RemoteListener")
    local mods = rl and rl:FindFirstChild("Modules")
    if not mods then return end
    local m = mods:FindFirstChild(name) or mods:FindFirstChild(name .. "_Disabled")
    if m then m.Name = disabled and (name .. "_Disabled") or name end
end

-- ════════════════════════════════════════════════════════════════
-- NEW TAB: Floor Antis
-- ════════════════════════════════════════════════════════════════
local FloorTab = Window:Tab({ Title = "Floors", Icon = "layers" })
FloorTab:Paragraph({
    Title = "Detected Floor",
    Desc = "GameData.Floor -> " .. (FloorNick() ~= "" and FloorNick() or "Lobby") .. "  |  Hardcore: " .. (IsHardcore and "yes" or "no") .. "  |  Reignited: " .. (IsReignited and "yes" or "no") .. "  |  Old: " .. (IsOldFloor and "yes" or "no") .. "  |  Cringle: " .. (IsCringleWorkshop and "yes" or "no"),
})

FloorTab:Section({ Title = "Anti-Entities (generic)" })

Ex.AntiGiggle = false
Hooks.AntiGiggle = function(v)
    local rooms = Rooms()
    if rooms then
        for _, r in ipairs(rooms:GetChildren()) do
            for _, g in ipairs(r:GetDescendants()) do
                if g.Name == "GiggleCeiling" then
                    local hb = g:FindFirstChild("Hitbox")
                    if hb then hb.CanTouch = not v end
                end
            end
        end
    end
end
AddToggle(FloorTab, "AntiGiggle", "Anti-Giggle", "Disables the GiggleCeiling hitbox so Giggle cannot grab you.", Ex.AntiGiggle, function(v) Apply("AntiGiggle", v) end)

Ex.AntiGloomEgg = false
Hooks.AntiGloomEgg = function(v)
    local rooms = Rooms()
    if rooms then
        for _, r in ipairs(rooms:GetChildren()) do
            for _, pile in ipairs(r:GetChildren()) do
                if pile.Name == "GloomPile" then
                    for _, e in ipairs(pile:GetDescendants()) do
                        if e.Name == "Egg" then e.CanTouch = not v end
                    end
                end
            end
        end
    end
end
AddToggle(FloorTab, "AntiGloomEgg", "Anti Gloom Egg", "Disables every GloomPile egg hitbox (Mines / Garden).", Ex.AntiGloomEgg, function(v) Apply("AntiGloomEgg", v) end)

Ex.AntiA90Module = false
Hooks.AntiA90Module = function(v) ToggleClientModule("A90", v) end
AddToggle(FloorTab, "AntiA90Module", "Anti-A90 (module)", "Renames the A90 client module so it never fires.", Ex.AntiA90Module, function(v) Apply("AntiA90Module", v) end)

Ex.AntiRansomMS = false
Hooks.AntiRansomMS = function(v)
    if not v then return end
    DeleteNamed("Ransom")
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local mu = pg and pg:FindFirstChild("MainUI")
    if mu then
        local v1 = mu:FindFirstChild("RansomVignette")
        if v1 then v1:Destroy() end
        local js = mu:FindFirstChild("Jumpscare")
        if js then
            for _, c in ipairs(js:GetChildren()) do
                if c.Name == "SkillCheck" then c:Destroy() end
            end
        end
    end
    local behind = pg and pg:FindFirstChild("BehindUI")
    if behind then
        for _, c in ipairs(behind:GetChildren()) do
            if c.Name == "RansomFrame" then c:Destroy() end
        end
    end
    local perm = pg and pg:FindFirstChild("PermUI")
    if perm then
        for _, c in ipairs(perm:GetChildren()) do
            if c.Name == "RansomGoldLive" then c:Destroy() end
        end
    end
    local fr = RS:FindFirstChild("FloorReplicated")
    local cr = fr and fr:FindFirstChild("ClientRemote")
    local rmod = cr and (cr:FindFirstChild("RansomInfect") or cr:FindFirstChild("RansomInfect_MSDOORS_DISABLE"))
    if rmod then
        for _, s in ipairs(rmod:GetDescendants()) do
            if s:IsA("Sound") and s.IsPlaying then s:Stop() end
        end
    end
    for _, screen in ipairs(Collection:GetTagged("RansomScreen")) do
        for _, fx in ipairs(screen:GetChildren()) do
            if fx:HasTag("RansomFX") then fx:Destroy() end
        end
    end
    local main = SoundSvc:FindFirstChild("Main")
    if main then main.Volume = 1 end
end
AddToggle(FloorTab, "AntiRansomMS", "Anti-Ransom (full)", "Destroys the Ransom model, vignette, jumpscare skillcheck, frame, gold live UI and stops its sounds.", Ex.AntiRansomMS, function(v) Apply("AntiRansomMS", v) end)

Ex.AntiJamMS = false
Hooks.AntiJamMS = function(v)
    local lm = RS:FindFirstChild("LiveModifiers")
    if not lm or not lm:FindFirstChild("Jammin") then return end
    local main = SoundSvc:FindFirstChild("Main")
    if main and main:FindFirstChild("Jamming") then main.Jamming.Enabled = not v end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local mu = pg and pg:FindFirstChild("MainUI")
    local ini = mu and mu:FindFirstChild("Initiator")
    local mg = ini and ini:FindFirstChild("Main_Game")
    local jam = mg and mg:FindFirstChild("Health") and mg.Health:FindFirstChild("Jam")
    if jam and jam:IsA("Sound") then jam.Playing = not v end
end
AddToggle(FloorTab, "AntiJamMS", "Anti-Jam (Jammin modifier)", "Mutes and disables the Jammin modifier music + heartbeat sound.", Ex.AntiJamMS, function(v) Apply("AntiJamMS", v) end)

Ex.AntiSnareMS = false
Hooks.AntiSnareMS = function(v)
    for _, s in ipairs(Workspace:GetDescendants()) do
        if s.Name == "Snare" then
            local hb = s:FindFirstChild("Hitbox")
            if hb then
                hb.CanTouch = not v
                hb.CanCollide = not v
                if v then
                    local ti = hb:FindFirstChildWhichIsA("TouchTransmitter")
                    if ti then ti:Destroy() end
                end
            end
        end
    end
end
AddToggle(FloorTab, "AntiSnareMS", "Anti-Snare", "Disables every Snare hitbox (and removes its TouchTransmitter).", Ex.AntiSnareMS, function(v) Apply("AntiSnareMS", v) end)

Ex.AntiBananaMS = false
Hooks.AntiBananaMS = function(v)
    local function apply(b)
        if not b or not b.Parent then return end
        b.CanTouch = not v
        b.CanCollide = not v
        for _, d in ipairs(b:GetDescendants()) do
            if d:IsA("TouchTransmitter") and v then d:Destroy() end
        end
    end
    for _, c in ipairs(Workspace:GetChildren()) do
        if c.Name == "BananaPeel" or c.Name == "NannerPeel" then apply(c) end
    end
end
AddToggle(FloorTab, "AntiBananaMS", "Anti-Banana", "Disables BananaPeel / NannerPeel (Super Hard Mode + Ranked).", Ex.AntiBananaMS, function(v) Apply("AntiBananaMS", v) end)

Ex.AntiDreadMS = false
Hooks.AntiDreadMS = function(v)
    if not v then return end
    DeleteNamed("DreadHC")
    DeleteNamed("Dread")
end
AddToggle(FloorTab, "AntiDreadMS", "Anti-Dread", "Deletes the Dread model when toggled on.", Ex.AntiDreadMS, function(v) Apply("AntiDreadMS", v) end)

Ex.AntiWhisperer = false
Hooks.AntiWhisperer = function(v)
    if not v then return end
    for _, c in ipairs(Workspace:GetChildren()) do
        if c.Name:sub(1, 9) == "Whisperer" then c:Destroy() end
    end
end
AddToggle(FloorTab, "AntiWhisperer", "Anti-Whisperer", "Deletes the Whisperer model (Hotel hardcore).", Ex.AntiWhisperer, function(v) Apply("AntiWhisperer", v) end)

Ex.AntiLimbo = false
Hooks.AntiLimbo = function(v)
    if not v then return end
    for _, e in ipairs(Lighting:GetChildren()) do
        if e.Name == "LimboBlur" or e.Name == "LimboSickness" then e:Destroy() end
    end
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    for _, g in ipairs(SoundSvc:GetChildren()) do
        for _, s in ipairs(g:GetDescendants()) do
            if s:IsA("Sound") and (s.Name == "Ambience" or (s.SoundId or ""):find("79981254132880")) then s:Destroy() end
        end
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui.Name == "LimboBar" then gui:Destroy() end
        end
    end
    local rooms = Rooms()
    if rooms then
        for _, r in ipairs(rooms:GetChildren()) do
            for _, l in ipairs(r:GetDescendants()) do
                if l:IsA("PointLight") or l:IsA("SpotLight") or l:IsA("SurfaceLight") then l.Enabled = true end
                if l:IsA("BasePart") and l.Name == "Skybox" then l.Color = Color3.fromRGB(33, 5, 35) end
            end
        end
    end
end
AddToggle(FloorTab, "AntiLimbo", "Anti-Limbo (Reignited)", "Removes the Limbo blur, sickness, ambience, bar UI and re-enables lights.", Ex.AntiLimbo, function(v) Apply("AntiLimbo", v) end)

Ex.AntiSpecimen = false
Hooks.AntiSpecimen = function(v)
    if not v then return end
    DeleteNamed("Specimen 8 Chase")
    DeleteNamed("Specimen8Chase")
end
AddToggle(FloorTab, "AntiSpecimen", "Anti-Specimen (Deer God)", "Deletes the Specimen 8 Chase model (Reignited).", Ex.AntiSpecimen, function(v) Apply("AntiSpecimen", v) end)

Ex.AntiAlmaMS = false
Hooks.AntiAlmaMS = function(v)
    DeleteNamed("Alma")
    local le = Workspace:FindFirstChild("LiveEntities")
    if le then
        for _, c in ipairs(le:GetChildren()) do
            if c.Name == "Alma" then c:Destroy() end
        end
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local mu = pg and pg:FindFirstChild("MainUI")
    if mu then
        local mf = mu:FindFirstChild("MainFrame")
        if mf then
            local es = mf:FindFirstChild("EyeStaringGame")
            if es then es:Destroy() end
        end
    end
    local behind = pg and pg:FindFirstChild("BehindUI")
    if behind then
        for _, c in ipairs(behind:GetChildren()) do
            if c.Name == "AlmaVignette" or c.Name == "AlmaCloseUp" then c:Destroy() end
        end
    end
    local perm = pg and pg:FindFirstChild("PermUI")
    if perm then
        for _, c in ipairs(perm:GetChildren()) do
            if c.Name == "AlmaAngerMeter" or c.Name == "AlmaUI" then c:Destroy() end
        end
    end
end
AddToggle(FloorTab, "AntiAlmaMS", "Anti-Alma", "Deletes the Alma model and its UI (vignette, close-up, anger meter).", Ex.AntiAlmaMS, function(v) Apply("AntiAlmaMS", v) end)

Ex.AntiCrusherMS = false
Hooks.AntiCrusherMS = function(v)
    local rooms = Rooms()
    if not rooms then return end
    for _, r in ipairs(rooms:GetChildren()) do
        local assets = r:FindFirstChild("Assets")
        if assets then
            local cont = assets:FindFirstChild("StairwellCrusherContainer1")
            if cont then
                local cr = cont:FindFirstChild("StairwellCrusher")
                if cr then
                    for _, pn in ipairs({ "Base", "CoreTrigger", "OuterTrigger" }) do
                        local p = cr:FindFirstChild(pn)
                        if p and p:IsA("BasePart") then
                            p.CanCollide = false
                            p.CanTouch = false
                            if v then p:Destroy() end
                        end
                    end
                end
            end
        end
    end
end
AddToggle(FloorTab, "AntiCrusherMS", "Anti-Crusher (Stairwell)", "Disables collision + touch of every Stairwell crusher trigger.", Ex.AntiCrusherMS, function(v) Apply("AntiCrusherMS", v) end)

Ex.AntiKickdoorMS = false
Hooks.AntiKickdoorMS = function(v)
    local rooms = Rooms()
    if not rooms then return end
    for _, p in ipairs(rooms:GetDescendants()) do
        if p.Name == "SewerRingBreakable" then
            for _, c in ipairs(p:GetDescendants()) do
                if c:IsA("BasePart") then c.CanCollide = not v end
            end
        end
    end
end
AddToggle(FloorTab, "AntiKickdoorMS", "Anti-Kickdoor (Mines)", "Disables collision on SewerRingBreakable parts (Mines Seek kickdoor).", Ex.AntiKickdoorMS, function(v) Apply("AntiKickdoorMS", v) end)

Ex.AntiBridgeFallMS = false
Hooks.AntiBridgeFallMS = function(v)
    if v then
        getgenv().AmbushHub_Bridges = getgenv().AmbushHub_Bridges or {}
        local rooms = Rooms()
        if rooms then
            for _, r in ipairs(rooms:GetChildren()) do
                local parts = r:FindFirstChild("Parts")
                if parts then
                    for _, b in ipairs(parts:GetChildren()) do
                        if b.Name == "Bridge" then
                            for _, bar in ipairs(b:GetChildren()) do
                                if bar.Name == "PlayerBarrier" and bar.Size.Y == 2.75 and (bar.Rotation.X == 0 or bar.Rotation.X == 180) then
                                    local clone = bar:Clone()
                                    clone.CFrame = bar.CFrame * CFrame.new(0, 0, -5)
                                    clone.Color = Color3.fromRGB(255, 255, 255)
                                    clone.Name = "AmbushHubBridgeGuard"
                                    clone.Size = Vector3.new(clone.Size.X, clone.Size.Y, 11)
                                    clone.Transparency = 0
                                    clone.Parent = b
                                    table.insert(getgenv().AmbushHub_Bridges, clone)
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        if getgenv().AmbushHub_Bridges then
            for _, b in ipairs(getgenv().AmbushHub_Bridges) do
                if b and b.Parent then b:Destroy() end
            end
        end
        getgenv().AmbushHub_Bridges = {}
    end
end
AddToggle(FloorTab, "AntiBridgeFallMS", "Anti-Bridge Fall (Mines)", "Spawns a solid barrier on Mines bridges so you cannot fall off during Seek.", Ex.AntiBridgeFallMS, function(v) Apply("AntiBridgeFallMS", v) end)

Ex.AntiFloodMS = false
Hooks.AntiFloodMS = function(v)
    getgenv().AmbushHub_Flood = getgenv().AmbushHub_Flood or {}
    local rooms = Rooms()
    if not rooms then return end
    for _, r in ipairs(rooms:GetChildren()) do
        local dam = r:FindFirstChild("_DamHandler")
        if dam then
            for _, inst in ipairs(dam:GetDescendants()) do
                if inst:IsA("BasePart") and inst.Name == "SeekFloodline" then
                    if v then
                        if getgenv().AmbushHub_Flood[inst] == nil then getgenv().AmbushHub_Flood[inst] = inst.CanCollide end
                        inst.CanCollide = true
                    else
                        if getgenv().AmbushHub_Flood[inst] ~= nil then inst.CanCollide = getgenv().AmbushHub_Flood[inst] end
                    end
                end
            end
        end
    end
    if not v then getgenv().AmbushHub_Flood = {} end
end
AddToggle(FloorTab, "AntiFloodMS", "Anti-Flood (Dam Seek)", "Toggles SeekFloodline collision so you don't sink during Dam Seek (room 100).", Ex.AntiFloodMS, function(v) Apply("AntiFloodMS", v) end)

Ex.AntiHasteEffects = false
Hooks.AntiHasteEffects = function(v)
    if getgenv().AmbushHub_HasteConn then getgenv().AmbushHub_HasteConn:Disconnect() getgenv().AmbushHub_HasteConn = nil end
    if not v then return end
    local fr = RS:FindFirstChild("FloorReplicated")
    local cr = fr and fr:FindFirstChild("ClientRemote")
    local h = cr and cr:FindFirstChild("Haste")
    if not h then return end
    local amb = h:FindFirstChild("Ambience")
    if not amb then return end
    getgenv().AmbushHub_HasteConn = amb:GetPropertyChangedSignal("Playing"):Connect(function()
        if Ex.AntiHasteEffects then amb.Playing = false end
    end)
    amb.Playing = false
    for _, c in ipairs(Workspace.CurrentCamera:GetChildren()) do
        if c.Name == "LiveSanity" and Workspace:FindFirstChild("EntityModel") then c.Enabled = false end
    end
end
AddToggle(FloorTab, "AntiHasteEffects", "Anti-Haste Effects", "Mutes the Haste ambience and disables the LiveSanity effect.", Ex.AntiHasteEffects, function(v) Apply("AntiHasteEffects", v) end)

Ex.AntiDronesStampede = false
Hooks.AntiDronesStampede = function(v)
    getgenv().AmbushHub_Stampede = getgenv().AmbushHub_Stampede or {}
    if getgenv().AmbushHub_Stampede.thread then pcall(task.cancel, getgenv().AmbushHub_Stampede.thread) getgenv().AmbushHub_Stampede.thread = nil end
    if not v then return end
    getgenv().AmbushHub_Stampede.list = {}
    local rooms = Rooms()
    if rooms then
        for _, r in ipairs(rooms:GetChildren()) do
            local clock = r:FindFirstChild("ArchivesClock", true)
            if clock then
                local rem = clock:FindFirstChild("LookedAtRemote", true)
                if rem and rem:IsA("RemoteEvent") then
                    table.insert(getgenv().AmbushHub_Stampede.list, rem)
                end
            end
        end
    end
    getgenv().AmbushHub_Stampede.thread = task.spawn(function()
        while Ex.AntiDronesStampede do
            for _, rem in ipairs(getgenv().AmbushHub_Stampede.list) do
                if rem and rem.Parent then pcall(function() rem:FireServer() end) end
            end
            task.wait(1)
        end
    end)
end
AddToggle(FloorTab, "AntiDronesStampede", "Anti-Drones Stampede (Archives)", "Keeps telling every Archives clock that you looked at it, blocking the Drones Stampede.", Ex.AntiDronesStampede, function(v) Apply("AntiDronesStampede", v) end)

Ex.NoPuzzleDoor = false
Hooks.NoPuzzleDoor = function(v)
    for _, door in ipairs(Workspace:GetDescendants()) do
        if door.Name == "MovingDoor" then
            for _, col in ipairs(door:GetDescendants()) do
                if col.Name == "Collision" and col:IsA("BasePart") then col.CanCollide = not v end
            end
            for _, part in ipairs(door:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = (v and 1 or 0)
                    if part.Name == "Collision" then part.Transparency = 1 end
                end
            end
        end
    end
end
AddToggle(FloorTab, "NoPuzzleDoor", "No Puzzle Door", "Removes collision + hides the MovingDoor puzzle doors (Super Hard Mode / Rush Mode).", Ex.NoPuzzleDoor, function(v) Apply("NoPuzzleDoor", v) end)

Ex.AntiSeekObsMS = false
Hooks.AntiSeekObsMS = function(v)
    local rooms = Rooms()
    if not rooms then return end
    for _, inst in ipairs(rooms:GetDescendants()) do
        if inst.Name == "ChandelierObstruction" or inst.Name == "Seek_Arm" then
            for _, obj in ipairs(inst:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CanTouch = not v
                    obj.CanCollide = not v
                end
            end
        end
    end
end
AddToggle(FloorTab, "AntiSeekObsMS", "Anti-Seek Obstructions", "Disables ChandelierObstruction + Seek_Arm touch/collision during Seek chases.", Ex.AntiSeekObsMS, function(v) Apply("AntiSeekObsMS", v) end)

Ex.DeleteSeekMS = false
Hooks.DeleteSeekMS = function(v)
    if not v then return end
    local trig = Workspace:FindFirstChild("TriggerSeek", true)
    if trig then trig:Destroy() end
    local col = Workspace:FindFirstChild("TriggerEventCollision", true)
    if col then col:ClearAllChildren() end
end
AddToggle(FloorTab, "DeleteSeekMS", "Delete Seek (FE)", "Deletes the Seek trigger + trigger collision.", Ex.DeleteSeekMS, function(v) Apply("DeleteSeekMS", v) end)

Ex.DeleteFigureMS = false
Hooks.DeleteFigureMS = function(v)
    if not v then
        if getgenv().AmbushHub_DelFig then getgenv().AmbushHub_DelFig:Disconnect() getgenv().AmbushHub_DelFig = nil end
        return
    end
    if not isnetworkowner then Toast("Delete Figure", "Your executor has no isnetworkowner.") return end
    for _, fig in ipairs(Workspace:GetChildren()) do
        if fig:IsA("Model") and (fig.Name == "FigureRig" or fig.Name == "FigureRagdoll") and fig:FindFirstChild("Root") then
            task.spawn(function()
                if not isnetworkowner(fig.Root) then
                    local ok = pcall(function()
                        if setOwnerPart then setOwnerPart(fig.Root, LocalPlayer) end
                    end)
                    if not ok then
                        for i = 1, 30 do
                            if not fig.Parent or not fig:FindFirstChild("Root") then return end
                            local cf = fig.Root.CFrame
                            fig.Root.CFrame = cf * CFrame.new(0, 0.01, 0)
                            fig.Root.CFrame = cf
                            if isnetworkowner(fig.Root) then break end
                            task.wait()
                        end
                    end
                end
                Toast("Delete Figure", "Pivoting figure away...")
                if getgenv().AmbushHub_DelFig then getgenv().AmbushHub_DelFig:Disconnect() end
                getgenv().AmbushHub_DelFig = RunSvc.Heartbeat:Connect(function()
                    if fig.Parent and fig:FindFirstChild("Root") then
                        fig:PivotTo(CFrame.new(-49999, -49999, -49999))
                        fig.Root.Size = Vector3.new(0.4, 2000, 0.4)
                        fig.Root.CanCollide = false
                        local hb = fig:FindFirstChild("Hitbox")
                        if hb then hb.CanCollide = false end
                    else
                        if getgenv().AmbushHub_DelFig then getgenv().AmbushHub_DelFig:Disconnect() getgenv().AmbushHub_DelFig = nil end
                        Toast("Delete Figure", "Figure deleted.")
                    end
                end)
            end)
        end
    end
end
AddToggle(FloorTab, "DeleteFigureMS", "Delete Figure (FE)", "Pivots the FigureRig / FigureRagdoll far away and disables collision. Needs isnetworkowner.", Ex.DeleteFigureMS, function(v) Apply("DeleteFigureMS", v) end)

Ex.AntiJeffClientMS = false
Hooks.AntiJeffClientMS = function(v)
    getgenv().AmbushHub_JeffOrig = getgenv().AmbushHub_JeffOrig or {}
    if not v then
        for part, orig in pairs(getgenv().AmbushHub_JeffOrig) do
            if part and part.Parent then part.CanTouch = orig end
        end
        getgenv().AmbushHub_JeffOrig = {}
        return
    end
    for _, j in ipairs(Workspace:GetChildren()) do
        if j:IsA("Model") and j.Name == "JeffTheKiller" then
            for _, p in ipairs(j:GetDescendants()) do
                if p:IsA("BasePart") then
                    if getgenv().AmbushHub_JeffOrig[p] == nil then getgenv().AmbushHub_JeffOrig[p] = p.CanTouch end
                    p.CanTouch = false
                end
            end
        end
    end
end
AddToggle(FloorTab, "AntiJeffClientMS", "Anti-Jeff (client)", "Disables touch on every JeffTheKiller part so it cannot stab you.", Ex.AntiJeffClientMS, function(v) Apply("AntiJeffClientMS", v) end)

Ex.AntiMandrakeMS = false
Hooks.AntiMandrakeMS = function(v)
    if not v then return end
    for _, m in ipairs(Workspace:GetChildren()) do
        if m.Name == "MandrakeLive" and m:FindFirstChild("Mandrake") and m.Mandrake:FindFirstChild("Root") then
            local root = m.Mandrake.Root
            if root and root.Parent then
                pcall(function() root.AssemblyLinearVelocity = Vector3.new(-99999999, -99999999, -99999) end)
                local bf = root:FindFirstChild("BodyForce")
                if not bf then
                    bf = Instance.new("BodyForce")
                    bf.Name = "BodyForce"
                    bf.Parent = root
                end
                bf.Force = Vector3.new(-99999999, -9999999, -99999)
            end
        end
    end
end
AddToggle(FloorTab, "AntiMandrakeMS", "Anti-Mandrake (Garden)", "Flings the Mandrake root away with a BodyForce (Garden).", Ex.AntiMandrakeMS, function(v) Apply("AntiMandrakeMS", v) end)

Ex.AntiSurgeMS = false
Ex.AntiSurgeMethod = (hookmetamethod and "HookMethod") or "RemoteSwap"
Hooks.AntiSurgeMS = function(v)
    -- swap method
    if getgenv().AmbushHub_SurgeFake and getgenv().AmbushHub_SurgeOrig then
        pcall(function()
            getgenv().AmbushHub_SurgeFake:Destroy()
            local rf = Remotes()
            if rf then getgenv().AmbushHub_SurgeOrig.Parent = rf end
        end)
        getgenv().AmbushHub_SurgeFake = nil
        getgenv().AmbushHub_SurgeOrig = nil
    end
    if not v then return end
    if Ex.AntiSurgeMethod == "RemoteSwap" then
        local rf = Remotes()
        if not rf then return end
        local orig = rf:FindFirstChild("SurgeRemote")
        if orig then
            getgenv().AmbushHub_SurgeOrig = orig
            orig.Parent = RS
            local fake = Instance.new("RemoteEvent")
            fake.Name = "SurgeRemote"
            fake.Parent = rf
            getgenv().AmbushHub_SurgeFake = fake
        end
    elseif Ex.AntiSurgeMethod == "HookMethod" and hookmetamethod and newcclosure and getnamecallmethod then
        if getgenv().AmbushHub_SurgeHooked then return end
        getgenv().AmbushHub_SurgeHooked = true
        local old
        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            if Ex.AntiSurgeMS and getnamecallmethod() == "FireServer" and self.Name == "SurgeRemote" then
                return
            end
            return old(self, ...)
        end))
    end
end
AddToggle(FloorTab, "AntiSurgeMS", "Anti-Surge (Garden)", "Blocks SurgeRemote FireServer via namecall hook (recommended) or remote-swap.", Ex.AntiSurgeMS, function(v) Apply("AntiSurgeMS", v) end)
FloorTab:Dropdown({
    Title = "Anti-Surge Method",
    Desc = "HookMethod needs hookmetamethod. RemoteSwap works on every executor but is more visible.",
    Values = (hookmetamethod and { "HookMethod", "RemoteSwap" }) or { "RemoteSwap" },
    Value = Ex.AntiSurgeMethod,
    Callback = function(v)
        Ex.AntiSurgeMethod = v
        if Ex.AntiSurgeMS and Hooks.AntiSurgeMS then
            Hooks.AntiSurgeMS(false)
            task.wait(0.1)
            Hooks.AntiSurgeMS(true)
        end
    end,
})

FloorTab:Section({ Title = "Haste Clock" })
Ex.HasteClockMS = false
local hasteGui, hasteLabel, hasteStroke, hasteBarFill
local hasteConns = {}
Hooks.HasteClockMS = function(v)
    if hasteGui then hasteGui:Destroy() hasteGui = nil hasteLabel = nil hasteStroke = nil hasteBarFill = nil end
    for _, c in pairs(hasteConns) do if c then c:Disconnect() end end
    hasteConns = {}
    if not v then return end
    local fr = RS:FindFirstChild("FloorReplicated")
    if not fr then return end
    local dt = fr:FindFirstChild("DigitalTimer")
    local ss = fr:FindFirstChild("ScaryStartsNow")
    if not (dt and ss) then Toast("Haste Clock", "DigitalTimer / ScaryStartsNow not found on this floor.") return end

    local sg = Instance.new("ScreenGui")
    sg.Name = "AmbushHubHasteClock"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 100
    pcall(function() sg.Parent = Hui end)
    if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -20, 0, 20)
    frame.Size = UDim2.fromOffset(200, 60)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 1
    local label = Instance.new("TextLabel", frame)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, -12)
    label.Font = Enum.Font.RobotoMono
    label.TextSize = 24
    label.TextColor3 = Color3.fromRGB(0, 200, 255)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Text = "00:00"
    local bar = Instance.new("Frame", frame)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(1, -12, 0, 4)
    bar.Position = UDim2.new(0, 6, 1, -8)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(1, 0, 1, 0)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    hasteGui, hasteLabel, hasteStroke, hasteBarFill = sg, label, stroke, fill

    local state = { last = tick(), val = dt.Value, max = 300, scary = false }
    hasteConns[1] = dt:GetPropertyChangedSignal("Value"):Connect(function()
        state.last = tick()
        state.val = dt.Value
    end)
    hasteConns[2] = ss:GetPropertyChangedSignal("Value"):Connect(function()
        state.scary = ss.Value
        sg.Enabled = state.scary
    end)
    state.scary = ss.Value
    sg.Enabled = state.scary
    hasteConns[3] = RunSvc.RenderStepped:Connect(function()
        if not (Ex.HasteClockMS and state.scary) then return end
        local cur = math.max(0, (state.last + state.val) - tick())
        local ratio = math.clamp(cur / state.max, 0, 1)
        local col = Color3.fromRGB(0, 200, 255)
        if ratio <= 0.2 then col = Color3.fromRGB(255, 80, 100)
        elseif ratio <= 0.5 then col = Color3.fromRGB(255, 193, 7) end
        label.Text = string.format("%02d:%02d", math.floor(cur / 60), math.floor(cur % 60))
        label.TextColor3 = col
        stroke.Color = col
        fill.BackgroundColor3 = col
        fill.Size = UDim2.new(ratio, 0, 1, 0)
    end)
end
AddToggle(FloorTab, "HasteClockMS", "Haste Clock", "Shows a live Haste countdown timer (Backdoor / Mines / Hotel hardcore).", Ex.HasteClockMS, function(v) Apply("HasteClockMS", v) end)

FloorTab:Section({ Title = "Hollow / Cutscenes" })
Ex.InfiniteStaminaMS = false
Hooks.InfiniteStaminaMS = function(v)
    local char = LocalPlayer.Character
    if char then
        if v then char:SetAttribute("Perk_StamFree", 1)
        else char:SetAttribute("Perk_StamFree", nil) end
    end
end
AddToggle(FloorTab, "InfiniteStaminaMS", "Infinite Stamina (The Hollow)", "Sets the Perk_StamFree attribute on your character.", Ex.InfiniteStaminaMS, function(v) Apply("InfiniteStaminaMS", v) end)

Ex.AutoSkipCutscenesMS = false
Hooks.AutoSkipCutscenesMS = function(v)
    if getgenv().AmbushHub_SkipConn then getgenv().AmbushHub_SkipConn:Disconnect() getgenv().AmbushHub_SkipConn = nil end
    if not v then return end
    task.spawn(function()
        local fr = RS:WaitForChild("FloorReplicated", 5)
        if not fr then return end
        local cr = fr:WaitForChild("ClientRemote", 5)
        if not cr then return end
        local sk = cr:WaitForChild("SkipCutscene", 5)
        if not sk then return end
        local rem = sk:WaitForChild("Remote", 5)
        if not rem or not rem:IsA("RemoteEvent") then return end
        getgenv().AmbushHub_SkipConn = rem.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] == "Open" and args[2] then
                task.wait(0.2)
                pcall(function() rem:FireServer(args[2], true) end)
            end
        end)
    end)
end
AddToggle(FloorTab, "AutoSkipCutscenesMS", "Auto Skip Cutscenes", "Auto-fires the SkipCutscene remote when a cutscene opens.", Ex.AutoSkipCutscenesMS, function(v) Apply("AutoSkipCutscenesMS", v) end)

FloorTab:Section({ Title = "Mines" })
FloorTab:Button({
    Title = "Beat Door 200 (Mines)",
    Desc = "Teleports to each water pump, interacts with it, then to the generator lever. Must be in room 100.",
    DoubleClick = true,
    Callback = function()
        local cur = CurRoom()
        if not cur or cur < 99 then Toast("Beat Door 200", "You haven't reached room 100 yet.") return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local startPos = hrp.CFrame
        local room = Rooms():FindFirstChild(tostring(cur))
        local dam = room and room:FindFirstChild("_DamHandler")
        local function firePrompt(p, times)
            for _ = 1, times or 5 do
                if fireproximityprompt then pcall(fireproximityprompt, p) end
                task.wait(0.1)
            end
        end
        if dam then
            for _, b in ipairs({ "PlayerBarriers1", "PlayerBarriers2", "PlayerBarriers3" }) do
                if dam:FindFirstChild(b) then
                    local fld = b:find("1") and dam:FindFirstChild("Flood1") or (b:find("2") and dam:FindFirstChild("Flood2") or dam:FindFirstChild("Flood3"))
                    if fld and fld:FindFirstChild("Pumps") then
                        for _, pump in ipairs(fld.Pumps:GetChildren()) do
                            char:PivotTo(pump.Wheel.CFrame)
                            task.wait(0.3)
                            local vp = pump.Wheel:FindFirstChild("ValvePrompt")
                            if vp then firePrompt(vp) end
                        end
                        task.wait(8)
                    end
                end
            end
        end
        local gen = room and room:FindFirstChild("MinesGenerator", true)
        if gen then
            char:PivotTo(gen.PrimaryPart and gen.PrimaryPart.CFrame or gen:GetPivot())
            task.wait(0.3)
            local lp = gen:FindFirstChild("Lever")
            if lp then
                local pp = lp:FindFirstChild("LeverPrompt")
                if pp then firePrompt(pp) end
            end
        end
        char:PivotTo(startPos)
        Toast("Beat Door 200", "Done.")
    end,
})

Ex.MinecartTeleportMS = false
local mcTeleConns = {}
Hooks.MinecartTeleportMS = function(v)
    for _, c in ipairs(mcTeleConns) do if c then c:Disconnect() end end
    mcTeleConns = {}
    getgenv().AmbushHub_McHooked = false
    if not v then return end
    if not hookmetamethod then Toast("Minecart Teleport", "Needs hookmetamethod.") return end
    local rem = Remotes()
    if not rem then return end
    local MinecartPos = rem:FindFirstChild("MinecartPos")
    local UpdateNodes = rem:FindFirstChild("UpdateMinecartNodes")
    if not (MinecartPos and UpdateNodes) then Toast("Minecart Teleport", "Minecart remotes not found (must be on Mines).") return end

    local state = { roomNodes = {}, array = nil, idx = 1, active = false, progressing = false, done = false, firing = false }
    local function rigOf() return Workspace.CurrentCamera and Workspace.CurrentCamera:FindFirstChild("MinecartRig") end
    local function moveTo(node)
        if not (node and node._part) then return end
        local cf = node._part.CFrame
        local r = rigOf()
        if r then r:PivotTo(cf) end
        local char = LocalPlayer.Character
        if char and char.PrimaryPart then char:PivotTo(cf) end
    end
    local function linearize(arr)
        if not arr or #arr == 0 then return end
        for i = 1, #arr - 1 do
            local a, b = arr[i], arr[i + 1]
            pcall(function()
                if a._setRightNode then a:_setRightNode(b) end
                if a._setStraightNode then a:_setStraightNode(b) end
                if a._setLeftNode then a:_setLeftNode(b) end
                if a._setToEndNode then a:_setToEndNode(b) end
                if a._part then a._part:SetAttribute("MinecartNodeEvent", nil) end
            end)
        end
        local last = arr[#arr]
        pcall(function() if last._part then last._part:SetAttribute("MinecartNodeEvent", nil) end end)
    end
    local function deleteFalse(startNode, arr)
        if not (startNode and startNode._part and arr) then return end
        local real = {}
        for _, n in ipairs(arr) do if n._part then real[n._part] = true end end
        local folder = startNode._part.Parent
        if not folder then return end
        for _, c in ipairs(folder:GetChildren()) do
            if not real[c] and c:IsA("BasePart") then pcall(function() c:Destroy() end) end
        end
    end
    local function saveNodes(buf, folder, startID)
        local ok, mod = pcall(require, RS:WaitForChild("NodeObject", 5):WaitForChild("MinecartNodes", 5))
        if not (ok and mod) then return nil end
        local sn = mod.Decode(buf, folder, startID)
        if not sn then return nil end
        local arr = sn:getArrayOfNodeObjectsToTheEnd()
        if not arr or #arr == 0 then return nil end
        deleteFalse(sn, arr)
        linearize(arr)
        state.roomNodes[folder:GetFullName()] = arr
        return arr
    end
    local function startProg(arr)
        if state.progressing then state.progressing = false task.wait(0.05) end
        if not arr or #arr == 0 then return end
        state.array = arr
        state.idx = 1
        state.progressing = true
        state.done = false
        Toast("Minecart Teleport", "Teleporting...")
        task.spawn(function()
            while state.progressing and Ex.MinecartTeleportMS and state.idx <= #state.array do
                local n = state.array[state.idx]
                if n and n._part then
                    moveTo(n)
                    state.firing = true
                    pcall(function() MinecartPos:FireServer(n._part.CFrame) end)
                    state.firing = false
                end
                state.idx = state.idx + 1
                task.wait(0.02)
            end
            state.progressing = false
            state.done = true
        end)
    end

    mcTeleConns[1] = UpdateNodes.OnClientEvent:Connect(function(buf, folder, startID)
        task.defer(function()
            if not Ex.MinecartTeleportMS then return end
            local arr = saveNodes(buf, folder, startID)
            if arr and state.active and not state.done then startProg(arr) end
        end)
    end)

    if not getgenv().AmbushHub_McHooked then
        getgenv().AmbushHub_McHooked = true
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local args = { ... }
            local m = getnamecallmethod and getnamecallmethod() or ""
            if m == "FireServer" and self == MinecartPos and Ex.MinecartTeleportMS and not state.firing then
                if not state.array or state.done then
                    return old(self, unpack(args))
                end
                if state.progressing then
                    local n = state.array[state.idx]
                    if n and n._part then
                        args[1] = n._part.CFrame
                        moveTo(n)
                    end
                end
                return old(self, unpack(args))
            end
            return old(self, ...)
        end)
    end

    local function trySaved()
        local rn = tostring(CurRoom())
        for key, arr in pairs(state.roomNodes) do
            if key:find(rn, 1, true) then
                deleteFalse(arr[1], arr)
                linearize(arr)
                startProg(arr)
                return true
            end
        end
        return false
    end
    local function onRig(child)
        if child.Name ~= "MinecartRig" then return end
        if state.active then return end
        state.active = true
        state.done = false
        if not trySaved() then Toast("Minecart Teleport", "Waiting for node data...") end
    end
    local cam = Workspace.CurrentCamera
    if cam then
        if cam:FindFirstChild("MinecartRig") then onRig(cam:FindFirstChild("MinecartRig")) end
        mcTeleConns[2] = cam.ChildAdded:Connect(function(c) if Ex.MinecartTeleportMS then onRig(c) end end)
        mcTeleConns[3] = cam.ChildRemoved:Connect(function(c)
            if c.Name ~= "MinecartRig" then return end
            state.progressing = false
            state.active = false
            state.done = false
        end)
    end
    mcTeleConns[4] = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
        if not Ex.MinecartTeleportMS then return end
        local rn = CurRoom()
        if rn >= 50 then
            Toast("Minecart Teleport", "Reached room 50+ — disabling.")
            for _, c in ipairs(mcTeleConns) do if c then c:Disconnect() end end
            mcTeleConns = {}
            getgenv().AmbushHub_McHooked = false
            if Setters.MinecartTeleportMS then Setters.MinecartTeleportMS(false) end
        end
    end)
end
AddToggle(FloorTab, "MinecartTeleportMS", "Minecart Teleport (Mines)", "Walks the minecart node graph by teleporting to each node (Mines Seek chase). Needs hookmetamethod.", Ex.MinecartTeleportMS, function(v) Apply("MinecartTeleportMS", v) end)

FloorTab:Section({ Title = "Hollow: Candys + Vault" })
Ex.AutoDepotCandys = false
local candyConns = {}
Hooks.AutoDepotCandys = function(v)
    for _, c in pairs(candyConns) do if c then if typeof(c) == "RBXScriptConnection" then c:Disconnect() else pcall(task.cancel, c) end end end
    candyConns = {}
    if not v then return end
    getgenv().AmbushHub_CandyQueue = {}
    getgenv().AmbushHub_CandyDropping = false
    local CANDY = "Candy"
    local FARM = { "BrokenHeadstone", "ChocolateCrate", "Haybale", "SmallCauldron", "CandyBucket", "WizardHat", "GiantGummyworm", "LargeCandyBag", "CandyBasket" }
    local DEPOT = "DepotHalloween"
    local function isFarm(t)
        if not t:IsA("Tool") then return false end
        if t.Name == CANDY then return true end
        for _, n in ipairs(FARM) do if t.Name == n then return true end end
        return false
    end
    local function posOf(o)
        if not o then return nil end
        if o:IsA("BasePart") then return o.Position end
        if o:IsA("Model") then return o:GetPivot().Position end
    end
    local function nearestDepot()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local best, bd = nil, math.huge
        local rooms = Rooms()
        if not rooms then return nil end
        for _, r in ipairs(rooms:GetChildren()) do
            local a = r:FindFirstChild("Assets")
            local d = a and a:FindFirstChild(DEPOT)
            local p = posOf(d)
            if p then
                local dist = (p - hrp.Position).Magnitude
                if dist < bd then best, bd = d, dist end
            end
        end
        return best
    end
    local function dropTool(t)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or not t.Parent then return nil end
        if t.Parent ~= char then hum:EquipTool(t) task.wait(0.1) end
        local drops = Workspace:FindFirstChild("Drops")
        local known = {}
        if drops then for _, c in ipairs(drops:GetChildren()) do known[c] = true end end
        local rf = Remotes()
        local dr = rf and rf:FindFirstChild("DropItem")
        if not dr then return nil end
        pcall(function() dr:FireServer(t) end)
        local t0 = tick()
        while tick() - t0 < 3 do
            drops = Workspace:FindFirstChild("Drops")
            if drops then
                for _, c in ipairs(drops:GetChildren()) do
                    if not known[c] then return c end
                end
            end
            task.wait(0.05)
        end
        return nil
    end
    local function process(t)
        if getgenv().AmbushHub_CandyDropping or not Ex.AutoDepotCandys or not t or not t.Parent then return end
        if not isFarm(t) then return end
        getgenv().AmbushHub_CandyDropping = true
        task.spawn(function()
            local depot = nil
            local t0 = tick()
            while Ex.AutoDepotCandys and tick() - t0 < 10 do
                depot = nearestDepot()
                if depot then break end
                task.wait(0.5)
            end
            if depot and t.Parent then
                local dropped = dropTool(t)
                if dropped then
                    table.insert(getgenv().AmbushHub_CandyQueue, { obj = dropped, depot = depot, t = tick() })
                end
            end
            task.wait(0.1)
            getgenv().AmbushHub_CandyDropping = false
        end)
    end
    candyConns.heart = RunSvc.Heartbeat:Connect(function()
        if not Ex.AutoDepotCandys then return end
        local q = getgenv().AmbushHub_CandyQueue
        local i = 1
        while i <= #q do
            local e = q[i]
            local dp = posOf(e.depot)
            if not e.obj.Parent or not e.depot.Parent or not dp or tick() - e.t > 6 then
                table.remove(q, i)
            else
                pcall(function()
                    if sethiddenproperty then sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end
                end)
                local target = dp + Vector3.new(0, 3, 0)
                for _, p in ipairs(e.obj:GetDescendants()) do
                    if p:IsA("BasePart") and not p.Anchored then
                        p.CanCollide = false
                        p.AssemblyLinearVelocity = (target - p.Position) * 30
                    end
                end
                i = i + 1
            end
        end
    end)
    local function hookChar(char)
        if candyConns.charChild then candyConns.charChild:Disconnect() end
        candyConns.charChild = char.ChildAdded:Connect(function(c) if Ex.AutoDepotCandys then process(c) end end)
        for _, t in ipairs(char:GetChildren()) do if isFarm(t) then process(t) end end
    end
    if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
    candyConns.charAdded = LocalPlayer.CharacterAdded:Connect(function(c) if Ex.AutoDepotCandys then hookChar(c) end end)
    candyConns.bp = LocalPlayer.Backpack.ChildAdded:Connect(function(c) if Ex.AutoDepotCandys then process(c) end end)
    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do if isFarm(t) then process(t) end end
end
AddToggle(FloorTab, "AutoDepotCandys", "Auto Depot Candys (The Hollow)", "Drops farmable candy tools and pulls them to the nearest Halloween depot.", Ex.AutoDepotCandys, function(v) Apply("AutoDepotCandys", v) end)

Ex.AutoVaultMinigame = false
local vaultConns = {}
Hooks.AutoVaultMinigame = function(v)
    for _, c in pairs(vaultConns) do if c then if typeof(c) == "RBXScriptConnection" then c:Disconnect() else pcall(task.cancel, c) end end end
    vaultConns = {}
    if not v then return end
    local FILLED = Color3.fromRGB(255, 222, 189)
    local rf = Remotes()
    if not rf then return end
    local engage = rf:FindFirstChild("EngageMinigame")
    if not engage then return end
    local function fireGui(btn, isDown)
        if not btn then return end
        local sig = isDown and btn.MouseButton1Down or btn.MouseButton1Up
        if firesignal then pcall(firesignal, sig) return end
        if getconnections then
            for _, c in ipairs(getconnections(sig)) do if c.Function then pcall(c.Function) end end
            return
        end
        local vp = Workspace.CurrentCamera.ViewportSize
        local p = btn.AbsolutePosition
        local s = btn.AbsoluteSize
        local x, y = p.X + s.X / 2, p.Y + s.Y / 2
        if x > 0 and x < vp.X and y > 0 and y < vp.Y then
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(0, x, y, isDown and 0 or 1, game, 0)
            end)
            task.wait()
        end
    end
    local function findFrame(mu)
        if not mu then return nil end
        for _, c in ipairs(mu:GetChildren()) do
            if c:IsA("GuiObject") and c:FindFirstChild("Guide") and c:FindFirstChild("Next") and c:FindFirstChild("Previous") and c:FindFirstChild("Progress") then
                return c
            end
        end
    end
    local function findVault()
        local cur = LocalPlayer:GetAttribute("CurrentRoom")
        if not cur then return nil end
        local r = Rooms():FindFirstChild(tostring(cur))
        if not r then return nil end
        local a = r:FindFirstChild("Assets")
        return a and a:FindFirstChild("CandyVault")
    end
    local function complete(vault)
        if getgenv().AmbushHub_VaultBusy then return false end
        getgenv().AmbushHub_VaultBusy = true
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local mu = pg and pg:FindFirstChild("MainUI")
        local frame = nil
        local t0 = tick()
        while Ex.AutoVaultMinigame and tick() - t0 < 5 do
            frame = findFrame(mu)
            if frame then break end
            task.wait(0.1)
        end
        if not frame then getgenv().AmbushHub_VaultBusy = false return false end
        local pressed, lastRe = 0, 0
        local started = tick()
        while Ex.AutoVaultMinigame and frame and tick() - started < 180 do
            local dt = RunSvc.RenderStepped:Wait()
            if vault and vault.Parent and vault:GetAttribute("Activated") then break end
            frame = findFrame(mu)
            if not frame then break end
            local guide = frame:FindFirstChild("Guide")
            local prog = frame:FindFirstChild("Progress")
            local gp = guide and guide:FindFirstChild("Progress")
            local corr = guide and guide:FindFirstChild("Correct")
            if not (gp and corr and prog) then continue end
            local filled, total = 0, 0
            for _, c in ipairs(prog:GetChildren()) do
                if c:IsA("GuiObject") and c:FindFirstChildOfClass("UIScale") then
                    total = total + 1
                    if c.BackgroundColor3 == FILLED then filled = filled + 1 end
                end
            end
            if filled >= total and total > 0 then
                if pressed ~= 0 then fireGui(frame.Next, false) fireGui(frame.Previous, false) pressed = 0 end
                break
            end
            if tick() - lastRe > 0.15 and pressed == 0 then
                local scale = corr.Size.X.Scale
                if scale > 0 then
                    local remaining = (2 / scale) * (1 - gp.Size.X.Scale) - 14
                    local dir = (filled % 2 == 0) and 1 or -1
                    local stop = math.clamp(25.6 * dt, 0.15, 0.9)
                    if remaining > stop then
                        local btn = dir == 1 and frame.Next or frame.Previous
                        fireGui(btn, true)
                        pressed = dir
                        lastRe = tick()
                    end
                end
            elseif tick() - lastRe > 0.15 and pressed ~= 0 then
                fireGui(pressed == 1 and frame.Next or frame.Previous, true)
                lastRe = tick()
            end
        end
        if frame and frame.Parent then fireGui(frame.Next, false) fireGui(frame.Previous, false) end
        getgenv().AmbushHub_VaultBusy = false
    end
    vaultConns.engage = engage.OnClientEvent:Connect(function(name, vaultArg)
        if not Ex.AutoVaultMinigame then return end
        if name ~= "CrackableVault" then return end
        local vault = (typeof(vaultArg) == "Instance" and vaultArg.Name == "CandyVault") and vaultArg or findVault()
        task.wait(0.6)
        task.spawn(function() complete(vault) end)
    end)
    vaultConns.loop = task.spawn(function()
        while Ex.AutoVaultMinigame do
            if not getgenv().AmbushHub_VaultBusy then
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local mu = pg and pg:FindFirstChild("MainUI")
                if findFrame(mu) then
                    local v = findVault()
                    if not v or not v:GetAttribute("Activated") then complete(v) end
                end
            end
            task.wait(0.3)
        end
    end)
end
AddToggle(FloorTab, "AutoVaultMinigame", "Auto Vault Minigame (The Hollow)", "Auto-solves the CandyVault crackable minigame by pressing Next/Previous at the right time.", Ex.AutoVaultMinigame, function(v) Apply("AutoVaultMinigame", v) end)

FloorTab:Section({ Title = "Archives: Forget-Me-Not" })
Ex.AutoForgetMeNot = false
local fmnLoop
Hooks.AutoForgetMeNot = function(v)
    if fmnLoop then pcall(task.cancel, fmnLoop) fmnLoop = nil end
    if not v then return end
    getgenv().AmbushHub_Flowers = {}
    local rooms = Rooms()
    if rooms then
        for _, r in ipairs(rooms:GetChildren()) do
            for _, d in ipairs(r:GetDescendants()) do
                if d.Name == "FlowerBase" and d.Parent and d.Parent:FindFirstChild("LookAt") then
                    if not table.find(getgenv().AmbushHub_Flowers, d.Parent) then
                        table.insert(getgenv().AmbushHub_Flowers, d.Parent)
                    end
                end
            end
        end
    end
    fmnLoop = task.spawn(function()
        while Ex.AutoForgetMeNot and #getgenv().AmbushHub_Flowers > 0 do
            for i = #getgenv().AmbushHub_Flowers, 1, -1 do
                local f = getgenv().AmbushHub_Flowers[i]
                if f and f.Parent and f:FindFirstChild("LookAt") then
                    pcall(function() f.LookAt:FireServer() end)
                else
                    table.remove(getgenv().AmbushHub_Flowers, i)
                end
            end
            task.wait(2)
        end
    end)
end
AddToggle(FloorTab, "AutoForgetMeNot", "Auto Forget-Me-Not", "Fires LookAt on every FlowerBase in the loaded rooms (Archives).", Ex.AutoForgetMeNot, function(v) Apply("AutoForgetMeNot", v) end)

Ex.SkipForgetMeNot = false
local skipConns = {}
Hooks.SkipForgetMeNot = function(v)
    for _, c in pairs(skipConns) do if c then if typeof(c) == "RBXScriptConnection" then c:Disconnect() else pcall(task.cancel, c) end end end
    skipConns = {}
    if not v then return end
    local rooms = Rooms()
    if not rooms then return end
    skipConns[1] = rooms.ChildAdded:Connect(function(room)
        if room:GetAttribute("RawName") ~= "Archives_ForgetMeNotRoom" then return end
        local rn = tonumber(room.Name)
        if not rn then return end
        local target = rn + 1
        skipConns[2] = room.ChildAdded:Connect(function(child)
            if child.Name ~= LocalPlayer.Name then return end
            if skipConns[2] then skipConns[2]:Disconnect() skipConns[2] = nil end
            if skipConns[3] then pcall(task.cancel, skipConns[3]) end
            skipConns[3] = task.spawn(function()
                local started, holdStart, dur = false, 0, 4
                while Ex.SkipForgetMeNot do
                    local tr = rooms:FindFirstChild(tostring(target))
                    if not tr then task.wait(0.1) continue end
                    local door = tr:FindFirstChild("Door")
                    if not door or not door:FindFirstChild("Door") then task.wait(0.1) continue end
                    local dp = door.Door
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then task.wait(0.1) continue end
                    local hrp = char.HumanoidRootPart
                    local cf = CFrame.new(dp.Position + dp.CFrame.LookVector * -2)
                    if door:GetAttribute("Opened") and not started then
                        started = true
                        holdStart = tick()
                        dur = 4
                    end
                    if not started then
                        hrp.CFrame = cf
                        local lock = door:FindFirstChild("Lock")
                        if lock then
                            local pp = lock:FindFirstChildOfClass("ProximityPrompt")
                            if pp and (hrp.Position - lock.Position).Magnitude < 5.5 and fireproximityprompt then
                                pcall(fireproximityprompt, pp)
                            end
                        end
                        if door:GetAttribute("Opened") then started = true holdStart = tick() dur = 0 end
                    else
                        hrp.CFrame = cf
                        if tick() - holdStart >= dur then break end
                    end
                    task.wait(0.1)
                end
            end)
        end)
    end)
end
AddToggle(FloorTab, "SkipForgetMeNot", "Skip Forget-Me-Not", "Teleports you to the next room's door, opens the lock and holds until you pass through.", Ex.SkipForgetMeNot, function(v) Apply("SkipForgetMeNot", v) end)

Ex.AutoArchivesTerminal = false
local termConn
Hooks.AutoArchivesTerminal = function(v)
    if termConn then termConn:Disconnect() termConn = nil end
    if not v then return end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local mu = pg and pg:FindFirstChild("MainUI")
    if not mu then return end
    local function hookBackout(b)
        b:GetPropertyChangedSignal("Visible"):Connect(function()
            if b.Visible and Ex.AutoArchivesTerminal then
                task.wait(0.5)
                local cur = LocalPlayer:GetAttribute("CurrentRoom")
                if not cur then return end
                local r = Rooms():FindFirstChild(tostring(cur))
                if not r then return end
                local tr = r:FindFirstChild("TerminalRemote", true)
                if tr and tr:IsA("RemoteFunction") then
                    task.spawn(function()
                        pcall(function() tr:InvokeServer("Buy") task.wait(0.2) tr:InvokeServer("Submit", 1) end)
                    end)
                end
            end
        end)
    end
    if mu:FindFirstChild("MinigameBackout") then hookBackout(mu.MinigameBackout) end
    termConn = mu.ChildAdded:Connect(function(c) if c.Name == "MinigameBackout" then hookBackout(c) end end)
end
AddToggle(FloorTab, "AutoArchivesTerminal", "Auto Archives Terminal", "Auto-buys and submits on the Archives terminal minigame.", Ex.AutoArchivesTerminal, function(v) Apply("AutoArchivesTerminal", v) end)

FloorTab:Section({ Title = "Ripple" })
FloorTab:Button({
    Title = "Auto Win Cringle (Ripple)",
    Desc = "Teleports you to the RippleExitDoor hidden part (Cringle's Workshop).",
    DoubleClick = true,
    Callback = function()
        local rooms = Rooms()
        if not rooms then return end
        local door = rooms:FindFirstChild("2")
        local exit = door and door:FindFirstChild("RippleExitDoor", true)
        local hidden = exit and exit:FindFirstChild("Hidden")
        if hidden then
            local char = LocalPlayer.Character
            if char then
                char:PivotTo(hidden.CFrame)
                Toast("Cringle", "Teleported to the exit.")
            end
        else
            Toast("Cringle", "RippleExitDoor.Hidden not found (must be in Cringle's Workshop).")
        end
    end,
})

FloorTab:Section({ Title = "Ranked" })
Ex.AimProjectiles = false
local aimConn
Hooks.AimProjectiles = function(v)
    if aimConn then aimConn:Disconnect() aimConn = nil end
    if not v then return end
    aimConn = RunSvc.RenderStepped:Connect(function()
        if not Ex.AimProjectiles then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, child in ipairs(char:GetChildren()) do
            if child:GetAttribute("ProjectileType") then
                local bestD, bestR = math.huge, nil
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local r = plr.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local d = (r.Position - root.Position).Magnitude
                            if d < bestD then bestD, bestR = d, r end
                        end
                    end
                end
                if bestR then
                    local dir = (bestR.Position - root.Position).Unit
                    local id = tostring(math.random(9e9, 9999999999)) .. "_" .. tostring(tick())
                    local function vec(v)
                        if vector and vector.create then return vector.create(v.X, v.Y, v.Z) end
                        return v
                    end
                    local rf = Remotes()
                    local fp = rf and rf:FindFirstChild("FireProjectile")
                    local ph = rf and rf:FindFirstChild("ProjectileHit")
                    if fp then
                        pcall(function()
                            fp:FireServer(id, vec(root.Position), vec(dir), vec(bestR.Position), "BigProp", child.Name, { Workspace:FindFirstChild("Props"), char })
                        end)
                    end
                    task.wait(0.1)
                    if ph then
                        pcall(function()
                            ph:FireServer(id, {
                                Normal = vec(Vector3.new(0, 1, 0)),
                                Material = Enum.Material.Plastic,
                                Instance = bestR,
                                Position = vec(bestR.Position),
                            }, vec(bestR.Position))
                        end)
                    end
                end
                break
            end
        end
    end)
end
AddToggle(FloorTab, "AimProjectiles", "Auto Aim Projectiles (Ranked)", "Fires your held projectile at the nearest opponent and registers a hit.", Ex.AimProjectiles, function(v) Apply("AimProjectiles", v) end)

Ex.AutoBlockedDoors = false
local bdConns = {}
Hooks.AutoBlockedDoors = function(v)
    for _, c in ipairs(bdConns) do if c then c:Disconnect() end end
    bdConns = {}
    if not v then return end
    local function handle(pp)
        if pp.Name == "PartyDoorPrompt" and pp:IsA("ProximityPrompt") then
            local isDoor = false
            local p = pp.Parent
            while p do
                if p.Name == "Door" then isDoor = true break end
                p = p.Parent
            end
            if isDoor then
                task.spawn(function()
                    local n = 0
                    while Ex.AutoBlockedDoors and pp.Parent and n < 30 do
                        if fireproximityprompt then pcall(fireproximityprompt, pp) end
                        n = n + 1
                        task.wait(0.1)
                    end
                end)
            end
        end
    end
    local function checkRoom()
        local cur = LocalPlayer:GetAttribute("CurrentRoom")
        if not cur then return end
        local r = Rooms():FindFirstChild(tostring(cur))
        if not r then return end
        local door = r:FindFirstChild("Door")
        if door then
            for _, d in ipairs(door:GetDescendants()) do
                if d.Name == "PartyDoorPrompt" then handle(d) end
            end
            bdConns[1] = door.DescendantAdded:Connect(function(d) if Ex.AutoBlockedDoors then handle(d) end end)
        end
    end
    checkRoom()
    bdConns[2] = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function() if Ex.AutoBlockedDoors then checkRoom() end end)
end
AddToggle(FloorTab, "AutoBlockedDoors", "Auto Blocked Doors (Ranked)", "Spams the PartyDoorPrompt to kick open blocked doors.", Ex.AutoBlockedDoors, function(v) Apply("AutoBlockedDoors", v) end)

Ex.PowerupPad = false
local puConn
Hooks.PowerupPad = function(v)
    if puConn then pcall(task.cancel, puConn) puConn = nil end
    if not v then return end
    local function fireAll()
        local cur = LocalPlayer:GetAttribute("CurrentRoom")
        if not cur then return end
        local r = Rooms():FindFirstChild(tostring(cur))
        if not r then return end
        local pads = r:FindFirstChild("ItemPads")
        if not pads then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        for _, item in ipairs(pads:GetChildren()) do
            local hb = item:FindFirstChild("Hitbox")
            if hb and root and firetouchinterest then
                hb.Size = Vector3.new(600, 600, 600)
                pcall(function() firetouchinterest(root, hb, 0) firetouchinterest(root, hb, 1) end)
            end
            if item:IsA("ClickDetector") then pcall(fireclickdetector, item)
            elseif item:IsA("ProximityPrompt") and fireproximityprompt then pcall(fireproximityprompt, item) end
        end
    end
    puConn = task.spawn(function()
        while Ex.PowerupPad do
            pcall(fireAll)
            RunSvc.Heartbeat:Wait()
        end
    end)
end
AddToggle(FloorTab, "PowerupPad", "Auto Collect Powerups (Ranked)", "Enlarges ItemPad hitboxes and fires touch/click on every powerup pad in the room.", Ex.PowerupPad, function(v) Apply("PowerupPad", v) end)

FloorTab:Section({ Title = "Revive & Run" })
Ex.AutoReviveMS = false
Hooks.AutoReviveMS = function(v)
    if getgenv().AmbushHub_ReviveConn then getgenv().AmbushHub_ReviveConn:Disconnect() getgenv().AmbushHub_ReviveConn = nil end
    if not v then return end
    getgenv().AmbushHub_ReviveConn = LocalPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
        if LocalPlayer:GetAttribute("Alive") == false and Ex.AutoReviveMS then
            local rf = Remotes()
            local r = rf and rf:FindFirstChild("Revive")
            if r then
                task.spawn(function()
                    while LocalPlayer:GetAttribute("Alive") ~= true and Ex.AutoReviveMS do
                        pcall(function() r:FireServer() end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    end)
end
AddToggle(FloorTab, "AutoReviveMS", "Auto Revive", "Auto-fires the Revive remote while you are dead (Old Hotel / Fools / Hotel Minus).", Ex.AutoReviveMS, function(v) Apply("AutoReviveMS", v) end)

FloorTab:Button({
    Title = "Revive",
    Desc = "Fires the Revive remote once.",
    DoubleClick = true,
    Callback = function()
        local rf = Remotes()
        local r = rf and rf:FindFirstChild("Revive") or (RS:FindFirstChild("EntityInfo") and RS.EntityInfo:FindFirstChild("Revive")) or (RS:FindFirstChild("Bricks") and RS.Bricks:FindFirstChild("Revive"))
        if r then pcall(function() r:FireServer() end) else Toast("Revive", "Remote not found.") end
    end,
})

FloorTab:Button({
    Title = "Revive Friends (toggle gift UI)",
    Desc = "Toggles the GiftRevive UI so you can revive a friend.",
    Callback = function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local mu = pg and pg:FindFirstChild("MainUI")
        local gr = mu and mu:FindFirstChild("GiftRevive")
        if gr then gr.Visible = not gr.Visible end
    end,
})

FloorTab:Button({
    Title = "Play Again",
    Desc = "Starts a new run. Double-click.",
    DoubleClick = true,
    Callback = function()
        local rf = Remotes()
        local r = rf and rf:FindFirstChild("PlayAgain") or (RS:FindFirstChild("EntityInfo") and RS.EntityInfo:FindFirstChild("PlayAgain")) or (RS:FindFirstChild("Bricks") and RS.Bricks:FindFirstChild("PlayAgain"))
        if r then pcall(function() r:FireServer() end) else Toast("Play Again", "Remote not found.") end
    end,
})

FloorTab:Button({
    Title = "Return to Lobby",
    Desc = "Returns you to the lobby. Double-click.",
    DoubleClick = true,
    Callback = function()
        local rf = Remotes()
        local r = rf and rf:FindFirstChild("Lobby") or (RS:FindFirstChild("EntityInfo") and RS.EntityInfo:FindFirstChild("Lobby"))
        if r then pcall(function() r:FireServer() end) else Toast("Lobby", "Remote not found.") end
    end,
})

FloorTab:Button({
    Title = "Reset character",
    Desc = "Kills your character (replicatesignal if available).",
    DoubleClick = true,
    Callback = function()
        if replicatesignal and LocalPlayer:FindFirstChild("Kill") then
            pcall(replicatesignal, LocalPlayer.Kill)
        else
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end,
})

FloorTab:Button({
    Title = "Death Farm (toggle)",
    Desc = "Loops: kill -> wait respawn -> PlayAgain. Needs replicatesignal.",
    DoubleClick = true,
    Callback = function()
        if not replicatesignal then
            Toast("Death Farm", "Needs replicatesignal.")
            return
        end
        if getgenv().AmbushHub_DeathFarm then
            getgenv().AmbushHub_DeathFarm = false
            Toast("Death Farm", "Stopped.")
            return
        end
        getgenv().AmbushHub_DeathFarm = true
        Toast("Death Farm", "Starting...")
        task.spawn(function()
            while getgenv().AmbushHub_DeathFarm do
                pcall(function()
                    local pl = LocalPlayer
                    local kill = pl:FindFirstChild("Kill")
                    if kill then pcall(replicatesignal, kill) end
                end)
                task.wait(2)
                local t0 = tick()
                while not LocalPlayer:GetAttribute("Alive") and tick() - t0 < 10 do task.wait(0.3) end
                task.wait(0.5)
                pcall(function()
                    local rf = Remotes()
                    if rf and rf:FindFirstChild("PlayAgain") then rf.PlayAgain:FireServer() end
                end)
                task.wait(3)
            end
        end)
    end,
})

FloorTab:Button({
    Title = "Knob Farm",
    Desc = "Loads the msdoors knob farm loader (msdoors-content.pages.dev).",
    DoubleClick = true,
    Callback = function()
        local cur = LocalPlayer:GetAttribute("CurrentRoom")
        local alive = LocalPlayer:GetAttribute("Alive")
        if cur and cur >= 1 and alive then
            if replicatesignal and LocalPlayer:FindFirstChild("Kill") then
                pcall(replicatesignal, LocalPlayer.Kill)
            end
            if queue_on_teleport then
                queue_on_teleport('loadstring(game:HttpGet("https://msdoors-content.pages.dev/knobsfarm"))()')
            end
            task.wait(0.1)
            local rf = Remotes()
            if rf and rf:FindFirstChild("PlayAgain") then rf.PlayAgain:FireServer() end
        else
            pcall(function() loadstring(game:HttpGet("https://msdoors-content.pages.dev/knobsfarm"))() end)
        end
    end,
})

FloorTab:Section({ Title = "Structures ESP" })
Ex.StructuresESP = false
Ex.StructuresTargets = {}
for name in pairs(STRUCTURES) do Ex.StructuresTargets[name] = true end
local structConns = {}
Hooks.StructuresESP = function(v)
    for _, c in ipairs(structConns) do if c then c:Disconnect() end end
    structConns = {}
    if getgenv().AmbushHub_StructHL then
        for _, h in pairs(getgenv().AmbushHub_StructHL) do if h and h.Parent then h:Destroy() end end
    end
    getgenv().AmbushHub_StructHL = {}
    if not v then return end
    local function StructOK(inst, cfg)
        if cfg.Obj == "Mirror" then
            if not (inst.Parent and inst.Parent.Name == "Assets") then return false end
            local anc = inst.Parent
            while anc and anc ~= Rooms() do
                if string.find(anc.Name, "Sideroom_HotelRoom") then return false end
                anc = anc.Parent
            end
            return true
        end
        if cfg.Obj == "RiftRoom_BroomCloset" then
            local anc = inst.Parent
            while anc and anc ~= Rooms() do
                if anc.Name == "100" then return false end
                anc = anc.Parent
            end
            return true
        end
        return true
    end
    local function addHl(part)
        if not part then return end
        if getgenv().AmbushHub_StructHL[part] then return end
        local h = Instance.new("Highlight")
        h.Adornee = part
        h.FillColor = Color3.fromRGB(0, 200, 255)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = 0.6
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = part
        getgenv().AmbushHub_StructHL[part] = h
    end
    local function scanAll()
        local rooms = Rooms()
        if not rooms then return end
        for _, d in ipairs(rooms:GetDescendants()) do
            for dispName, cfg in pairs(STRUCTURES) do
                if d.Name == cfg.Obj and Ex.StructuresTargets[dispName] and StructOK(d, cfg) then
                    local part = d:IsA("BasePart") and d or (d:FindFirstChildWhichIsA("BasePart", true) or d.PrimaryPart)
                    addHl(part)
                end
            end
        end
    end
    scanAll()
    structConns[1] = Workspace.DescendantAdded:Connect(function(d)
        if not Ex.StructuresESP then return end
        for dispName, cfg in pairs(STRUCTURES) do
            if d.Name == cfg.Obj and Ex.StructuresTargets[dispName] and StructOK(d, cfg) then
                local part = d:IsA("BasePart") and d or (d:FindFirstChildWhichIsA("BasePart", true))
                addHl(part)
            end
        end
    end)
end
AddToggle(FloorTab, "StructuresESP", "Structures ESP", "Highlights Stairwell / Archives entrances, Mirrors and Rift rooms.", Ex.StructuresESP, function(v) Apply("StructuresESP", v) end)
do
    local names = {}
    for n in pairs(STRUCTURES) do names[#names + 1] = n end
    table.sort(names)
    local sel = {}
    for _, n in ipairs(names) do if Ex.StructuresTargets[n] then sel[#sel + 1] = n end end
    FloorTab:Dropdown({
        Title = "Structures to show",
        Desc = "Pick which structures the ESP marks.",
        Values = names,
        Value = sel,
        Multi = true,
        AllowNone = true,
        Callback = function(selected)
            local set = {}
            for _, n in ipairs(selected or {}) do set[n] = true end
            Ex.StructuresTargets = set
            if Ex.StructuresESP and Hooks.StructuresESP then Hooks.StructuresESP(false) Hooks.StructuresESP(true) end
        end,
    })
end

FloorTab:Section({ Title = "Stairwell Extras" })
Ex.DeleteCreakMS = false
Hooks.DeleteCreakMS = function(v)
    if getgenv().AmbushHub_CreakConn then getgenv().AmbushHub_CreakConn:Disconnect() getgenv().AmbushHub_CreakConn = nil end
    getgenv().AmbushHub_CreakCarts = {}
    if not v then
        for _, obj in ipairs(getgenv().AmbushHub_CreakCarts or {}) do
            if obj and obj.Parent then
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
        return
    end
    if gethiddenproperty and sethiddenproperty then
        pcall(function()
            settings().Physics.AllowSleep = false
            LocalPlayer.ReplicationFocus = Workspace
            sethiddenproperty(LocalPlayer, "MaximumSimulationRadius", math.huge)
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        end)
    end
    getgenv().AmbushHub_CreakConn = RunSvc.Heartbeat:Connect(function()
        local le = Workspace:FindFirstChild("LiveEntities")
        local creak = le and (le:FindFirstChild("Creak") or le:FindFirstChild("Creak-HALLOWEEN26"))
        if not creak then return end
        local hrp = creak:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local target = hrp.Position
        local rooms = Rooms()
        if not rooms then return end
        for _, r in ipairs(rooms:GetChildren()) do
            local a = r:FindFirstChild("Assets")
            if a then
                for _, cart in ipairs(a:GetChildren()) do
                    if cart.Name == "ShoppingCart" and cart:GetAttribute("LastPusherId") == LocalPlayer.UserId then
                        local base = cart:FindFirstChild("Base")
                        if base and base:IsA("BasePart") and base.CollisionGroup == "CartLoose" then
                            if not table.find(getgenv().AmbushHub_CreakCarts, cart) then
                                table.insert(getgenv().AmbushHub_CreakCarts, cart)
                            end
                        end
                    end
                end
            end
        end
        for i = #getgenv().AmbushHub_CreakCarts, 1, -1 do
            local cart = getgenv().AmbushHub_CreakCarts[i]
            if not cart or not cart.Parent then
                table.remove(getgenv().AmbushHub_CreakCarts, i)
            else
                for _, p in ipairs(cart:GetDescendants()) do
                    if p:IsA("BasePart") and not p.Anchored then
                        local bp = p:FindFirstChild("AmbushHubCreakBP")
                        if not bp then
                            for _, c in ipairs(p:GetChildren()) do
                                if c:IsA("BodyPosition") or c:IsA("BodyGyro") or c:IsA("BodyAngularVelocity") then c:Destroy() end
                            end
                            bp = Instance.new("BodyPosition")
                            bp.Name = "AmbushHubCreakBP"
                            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bp.Position = p.Position
                            bp.Parent = p
                        end
                        pcall(function()
                            p.CanCollide = false
                            bp.Position = target + Vector3.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
                            p.AssemblyLinearVelocity = Vector3.new(math.random(-5000, 5000), math.random(-5000, 5000), math.random(-5000, 5000))
                            p.AssemblyAngularVelocity = Vector3.new(math.random(-90000, 90000), math.random(-90000, 90000), math.random(-90000, 90000))
                        end)
                    end
                end
            end
        end
    end)
end
AddToggle(FloorTab, "DeleteCreakMS", "Delete Creak (Stairwell)", "Flings every cart you pushed onto Creak at high velocity so it glitches out.", Ex.DeleteCreakMS, function(v) Apply("DeleteCreakMS", v) end)

FloorTab:Section({ Title = "Entity Notify (msdoors style)" })
Ex.EntityNotifyMS = false
Ex.EntityNotifyChat = false
local ENTITY_IMAGES = {
    RushMoving = "11102256553", AmbushMoving = "10938726652", BackdoorRush = "140595207306444",
    A60 = "12350986086", A120 = "12351008553", Eyes = "10865377903", JeffTheKiller = "98993343",
    GlitchRush = "73859273102919", GlitchAmbush = "88369678433359", FrozenAmbush = "10938726652",
    BackdoorLookman = "16764872677", SurgeSpawn = "71834136597896", MonumentEntity = "88933556873017",
    SallyMoving = "10840888070", CustomEntity = "11102256553",
}
local seenEnt = setmetatable({}, { __mode = "k" })
Workspace.ChildAdded:Connect(function(m)
    if not (Ex.EntityNotifyMS and m:IsA("Model")) then return end
    if Players:GetPlayerFromCharacter(m) then return end
    if not ENTITY_IMAGES[m.Name] then return end
    if seenEnt[m] then return end
    seenEnt[m] = true
    pcall(function()
        FX.ShowToast(m.Name .. " spawned!", "Mode: " .. FloorNick(), "", Color3.fromRGB(255, 0, 0))
    end)
    if Ex.EntityNotifyChat then
        pcall(function()
            local rf = RS:FindFirstChild("DefaultChatSystemChatEvents")
            local ev = rf and rf:FindFirstChild("SayMessageRequest")
            if ev then ev:FireServer(m.Name .. " spawned!", "All") end
        end)
    end
end)
AddToggle(FloorTab, "EntityNotifyMS", "Entity Notify (toast)", "Shows a toast when a known entity spawns (Rush, Ambush, A-60, A-120, Eyes, Jeff...).", Ex.EntityNotifyMS, function(v) Ex.EntityNotifyMS = v end)
AddToggle(FloorTab, "EntityNotifyChat", "Also notify in chat", "Sends a chat message when an entity spawns.", Ex.EntityNotifyChat, function(v) Ex.EntityNotifyChat = v end)

-- Live floor badge in InfoTab
InfoTab:Section({ Title = "msdoors Floor Info" })
local floorPara = InfoTab:Paragraph({
    Title = "Floor (msdoors detection)",
    Desc = "Reading GameData.Floor...",
})
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local nick = FloorNick()
            local raw = FloorRaw()
            local txt = string.format(
                "Raw: %s\nNick: %s\nHardcore: %s\nReignited: %s\nOld floor: %s\nCringle Workshop: %s\nPlaceId: %d",
                raw ~= "" and raw or "(empty)", nick ~= "" and nick or "Lobby",
                IsHardcore and "yes" or "no", IsReignited and "yes" or "no",
                IsOldFloor and "yes" or "no", IsCringleWorkshop and "yes" or "no",
                game.PlaceId
            )
            floorPara:SetDesc(txt)
        end)
    end
end)

print("[AMBUSH HUB] Loaded msdoors floor port")
end)()

print("[AMBUSH HUB] Loaded Main Port")

Window:SelectTab(1)
print("[AMBUSH HUB] Loaded Config System")
warn("--- [AMBUSH HUB] RUNNING SCRIPT ---")
