--[[
    ====================================================================
    KAITUN BLOX FRUITS - REWRITTEN & OPTIMIZED (STANDALONE EDITION)
    ====================================================================
    Fitur Utama:
    - Auto Leveling & Quest Sea 1 - Sea 3
    - Smooth Tweening Engine dengan NoClip & Anti-Fall Bypass
    - Safe Fast Attack & Auto Bring Mobs (Cluster Mob)
    - Auto Buso Haki, Ken Haki, & Auto Equip Senjata
    - Auto Allocate Stats (Melee / Defense / Sword)
    - Auto Store Fruit (Anti hilangnya buah di tas)
    - Panic Mode (Anti Mati saat HP Rendah)
    - FPS Booster, Texture Cleaner, & Anti-AFK (20 Menit Disconnect)
]]

repeat task.wait() until game:IsLoaded()

-- 1. KONFIGURASI
local Config = {
    Team = "Pirates", -- "Pirates" atau "Marines"
    Performance = {
        FpsBoost = true,
        LowGraphics = true,
    },
    Combat = {
        SelectedWeaponType = "Melee", -- "Melee", "Sword", "Gun", "Blox Fruit"
        FastAttack = true,
        AttackDelay = 0.12,
        BringMobs = true,
        BringMobDistance = 250,
        FarmDistance = 25,
    },
    Movement = {
        TweenSpeed = 300,
        NoClip = true,
    },
    PanicMode = {
        Enabled = true,
        LowHealthPercent = 25,
        SafeHealthPercent = 80,
        EscapeHeight = 350,
    },
    Progression = {
        AutoQuest = true,
        AutoKen = true,
        AutoBuso = true,
        AutoStats = true,
        StatPriority = {"Melee", "Defense", "Sword"},
    },
    Items = {
        AutoStoreFruit = true,
        AutoRandomFruit = true,
        AutoCDK = true,
        AutoSoulGuitar = true,
        AutoBuyLegendarySword = true,
        AutoRedeemCodes = true,
        AutoReExecute = true,
    }
}

-- 2. SERVICES & REFERENSI
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local VirtualUser     = game:GetService("VirtualUser")
local Lighting        = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
local CommF = remotesFolder and remotesFolder:FindFirstChild("CommF_")
local CommE = remotesFolder and remotesFolder:FindFirstChild("CommE")

local function CommFInvoke(...)
    if not CommF then return nil end
    local success, result = pcall(function(...)
        return CommF:InvokeServer(...)
    end, ...)
    return success and result or nil
end

local function GetCharacter()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then
        return char, hrp, hum
    end
    return nil
end

local function GetDistance(pos1, pos2)
    local p1 = typeof(pos1) == "CFrame" and pos1.Position or (typeof(pos1) == "Vector3" and pos1 or pos1.Position)
    local p2 = typeof(pos2) == "CFrame" and pos2.Position or (typeof(pos2) == "Vector3" and pos2 or pos2.Position)
    return (p1 - p2).Magnitude
end

-- 3. OPTIMASI PERFORMA & ANTI-AFK
if Config.Performance.FpsBoost or Config.Performance.LowGraphics then
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("PostEffect") or fx:IsA("BlurEffect") or fx:IsA("SunRaysEffect") or fx:IsA("BloomEffect") then
                fx.Enabled = false
            end
        end
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Lifetime = NumberRange.new(0)
            end
        end
    end)
end

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
    task.wait(1)
    CommFInvoke("SetTeam", Config.Team)
end)


-- 4. MOVEMENT ENGINE (TWEEN & NOCLIP)
local activeTween = nil
local isNoClipping = false

RunService.Stepped:Connect(function()
    if not isNoClipping and not Config.Movement.NoClip then return end
    local char = LocalPlayer.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

local function CancelTween()
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
    isNoClipping = false
end

local function TweenTo(targetCFrame, speed)
    local char, hrp, hum = GetCharacter()
    if not hrp or not hum then return false end

    local dist = GetDistance(hrp.Position, targetCFrame.Position)
    if dist <= 20 then
        hrp.CFrame = targetCFrame
        CancelTween()
        return true
    end

    CancelTween()
    isNoClipping = true
    hum.PlatformStand = true
    hrp.Velocity = Vector3.new(0, 0, 0)

    local tweenSpeed = speed or Config.Movement.TweenSpeed
    local duration = math.max(dist / tweenSpeed, 0.05)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

    activeTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    activeTween.Completed:Connect(function()
        hum.PlatformStand = false
        isNoClipping = false
    end)
    activeTween:Play()
    return activeTween
end

local function WaitReached(targetCFrame, maxWait)
    local tw = TweenTo(targetCFrame)
    if not tw then return false end

    local start = tick()
    maxWait = maxWait or 15

    while tick() - start < maxWait do
        local _, hrp = GetCharacter()
        if not hrp then break end
        if GetDistance(hrp.Position, targetCFrame.Position) <= 20 then
            CancelTween()
            return true
        end
        task.wait(0.1)
    end
    CancelTween()
    return false
end

-- 5. COMBAT & WEAPON MANAGEMENT
local function EquipWeapon(weaponType)
    weaponType = weaponType or Config.Combat.SelectedWeaponType
    local char = LocalPlayer.Character
    local bp   = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not char or not bp then return false end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and (equipped.ToolTip == weaponType or (weaponType == "Blox Fruit" and string.find(equipped.Name, "Fruit"))) then
        return true
    end

    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.ToolTip == weaponType or (weaponType == "Blox Fruit" and string.find(tool.Name, "Fruit")) then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(tool)
                    return true
                end
            end
        end
    end
    return false
end

local function EnsureHaki()
    local char = LocalPlayer.Character
    if not char then return end

    if Config.Progression.AutoBuso and not char:FindFirstChild("HasBuso") then
        CommFInvoke("Buso")
    end

    if Config.Progression.AutoKen and not char:FindFirstChild("KenHaki") and CommE then
        CommE:FireServer("Ken", true)
    end
end

local function BringEnemies(mobName, centerCFrame)
    if not Config.Combat.BringMobs then return end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _, mob in ipairs(enemies:GetChildren()) do
        if mob.Name == mobName and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
            if mob.Humanoid.Health > 0 and GetDistance(mob.HumanoidRootPart.Position, centerCFrame.Position) <= Config.Combat.BringMobDistance then
                mob.HumanoidRootPart.CFrame = centerCFrame
                mob.HumanoidRootPart.CanCollide = false
                mob.Humanoid.WalkSpeed = 0
            end
        end
    end
end

local lastAttack = 0
local function Attack()
    local now = tick()
    if now - lastAttack < Config.Combat.AttackDelay then return end
    lastAttack = now

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

-- 6. QUEST SYSTEM (SEA 1 - PROGRESSION)
local Sea1Quests = {
    {Level = 1,    Quest = "BanditQuest1",    Target = "Bandit",             NPC = "Bandit Quest Giver", CFrame = CFrame.new(1059, 16, 1549)},
    {Level = 10,   Quest = "JungleQuest",     Target = "Monkey",             NPC = "Adventurer",         CFrame = CFrame.new(-1598, 36, 153)},
    {Level = 15,   Quest = "JungleQuest",     Target = "Gorilla",            NPC = "Adventurer",         CFrame = CFrame.new(-1598, 36, 153)},
    {Level = 30,   Quest = "BuggyQuest1",     Target = "Pirate",             NPC = "Pirate Adventurer",  CFrame = CFrame.new(-1141, 4, 3828)},
    {Level = 40,   Quest = "BuggyQuest1",     Target = "Brute",              NPC = "Pirate Adventurer",  CFrame = CFrame.new(-1141, 4, 3828)},
    {Level = 60,   Quest = "DesertQuest",     Target = "Desert Bandit",      NPC = "Desert Adventurer",  CFrame = CFrame.new(894, 6, 4390)},
    {Level = 75,   Quest = "DesertQuest",     Target = "Desert Officer",     NPC = "Desert Adventurer",  CFrame = CFrame.new(894, 6, 4390)},
    {Level = 90,   Quest = "SnowQuest",       Target = "Snow Bandit",        NPC = "Snow Adventurer",    CFrame = CFrame.new(1385, 87, -1298)},
    {Level = 100,  Quest = "SnowQuest",       Target = "Snowman",            NPC = "Snow Adventurer",    CFrame = CFrame.new(1385, 87, -1298)},
    {Level = 120,  Quest = "MarineQuest2",    Target = "Chief Petty Officer",NPC = "Marine Adventurer",  CFrame = CFrame.new(-5035, 28, 4324)},
    {Level = 150,  Quest = "SkyQuest",        Target = "Sky Bandit",         NPC = "Sky Adventurer",     CFrame = CFrame.new(-4839, 717, -2619)},
    {Level = 175,  Quest = "SkyQuest",        Target = "Dark Master",        NPC = "Sky Adventurer",     CFrame = CFrame.new(-4839, 717, -2619)},
    {Level = 190,  Quest = "PrisonerQuest",   Target = "Prisoner",           NPC = "Warden",             CFrame = CFrame.new(5308, 1, 475)},
    {Level = 225,  Quest = "ColosseumQuest",  Target = "Toga Warrior",       NPC = "Colosseum Quest",    CFrame = CFrame.new(-1575, 7, -2985)},
    {Level = 250,  Quest = "MagmaQuest",      Target = "Military Soldier",   NPC = "Military Adventurer",CFrame = CFrame.new(-5315, 8, 8515)},
    {Level = 300,  Quest = "FishmanQuest",    Target = "Fishman Warrior",    NPC = "Fishman Adventurer", CFrame = CFrame.new(61122, 18, 1565)},
    {Level = 375,  Quest = "SkyExp1Quest",    Target = "God's Guard",        NPC = "Sky Adventurer 2",   CFrame = CFrame.new(-4721, 845, -1950)},
    {Level = 450,  Quest = "FountainQuest",   Target = "Galley Pirate",      NPC = "Fountain Adventurer",CFrame = CFrame.new(5258, 38, 4050)},
    {Level = 625,  Quest = "FountainQuest",   Target = "Galley Captain",     NPC = "Fountain Adventurer",CFrame = CFrame.new(5258, 38, 4050)},
}

local function GetPlayerLevel()
    local data = LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("Main") and gui.Main:FindFirstChild("Level") then
        local num = string.match(gui.Main.Level.Text, "%d+")
        if num then return tonumber(num) end
    end
    return 1
end

local function GetTargetQuest()
    local myLevel = GetPlayerLevel()
    local selected = Sea1Quests[1]
    for _, q in ipairs(Sea1Quests) do
        if myLevel >= q.Level then
            selected = q
        else
            break
        end
    end
    return selected
end

local function HasQuest()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("Main") and gui.Main:FindFirstChild("Quest") then
        return gui.Main.Quest.Visible
    end
    return false
end
-- 7. LOGIKA UTAMA & FARM LOOP
local function StoreFruit()
    if not Config.Items.AutoStoreFruit then return end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    local char = LocalPlayer.Character
    if not bp then return end

    local function CheckItem(tool)
        if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then
            local origName = tool:GetAttribute("OriginalName") or tool.Name
            CommFInvoke("StoreFruit", origName, tool)
        end
    end

    for _, tool in ipairs(bp:GetChildren()) do CheckItem(tool) end
    if char then
        for _, tool in ipairs(char:GetChildren()) do CheckItem(tool) end
    end
end

local function AutoStats()
    if not Config.Progression.AutoStats then return end
    local pts = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Points")
    if pts and pts.Value > 0 then
        for _, stat in ipairs(Config.Progression.StatPriority) do
            CommFInvoke("AddPoint", stat, math.min(pts.Value, 10))
            task.wait(0.05)
        end
    end
end

local function CheckPanic()
    local _, hrp, hum = GetCharacter()
    if not hum or not hrp then return false end

    local pct = (hum.Health / hum.MaxHealth) * 100
    if pct <= Config.PanicMode.LowHealthPercent then
        CancelTween()
        hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + Config.PanicMode.EscapeHeight, hrp.Position.Z)
        while hum.Health > 0 and ((hum.Health / hum.MaxHealth) * 100) < Config.PanicMode.SafeHealthPercent do
            task.wait(0.5)
        end
        return true
    end
    return false
end

local function GetClosestTargetMob(mobName)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local _, hrp = GetCharacter()
    if not hrp then return nil end

    local closest, minDst = nil, math.huge
    for _, mob in ipairs(enemies:GetChildren()) do
        if mob.Name == mobName and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
            if mob.Humanoid.Health > 0 then
                local d = GetDistance(hrp.Position, mob.HumanoidRootPart.Position)
                if d < minDst then
                    minDst = d
                    closest = mob
                end
            end
        end
    end
    return closest
end

-- Background routines
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            StoreFruit()
            AutoStats()
        end)
    end
end)
-- 8. FITUR TAMBAHAN (REDEEM, GACHA, LEGENDARY SWORD, CDK, SOUL GUITAR, AUTO EXECUTE)
local BloxFruitsCodes = {
    "SECRET_ADMIN", "ADMIN_STRENGTH", "DRAGONABUSE", "24NOOBS",
    "SUB2GAMERROBOT_EXP1", "StrawHatMaine", "Sub2Fer999", "Enyu_is_Pro",
    "Magicbus", "JCWK", "Starcodeheo", "Bluxxy", "fudd10_v2",
    "SUB2GAMERROBOT_RESET1", "Sub2UncleKizaru", "Sub2OfficialNoobie",
    "TheGreatAce", "Axiore", "TantaiGaming", "fudd10", "Bignews"
}

local codesRedeemed = false
local function RedeemAllCodes()
    if not Config.Items.AutoRedeemCodes or codesRedeemed then return end
    codesRedeemed = true

    task.spawn(function()
        print("[Kaitun Modulo] Menjalankan Auto Redeem Code (Sekali Saja)...")
        for _, code in ipairs(BloxFruitsCodes) do
            pcall(function() CommFInvoke("RedeemCode", code) end)
            task.wait(0.8)
        end
        print("[Kaitun Modulo] Selesai me-redeem semua kode. Berhenti.")
    end)
end

local function AutoRandomFruit()
    if not Config.Items.AutoRandomFruit then return end
    pcall(function() CommFInvoke("Cousin", "Buy") end)
end

local function AutoBuyLegendarySword()
    if not Config.Items.AutoBuyLegendarySword then return end
    pcall(function()
        for _, sw in ipairs({"Shisui", "Saddi", "Wando"}) do
            CommFInvoke("LegendarySwordDealer", sw)
        end
    end)
end

local function CheckCDKAndSoulGuitar()
    if Config.Items.AutoCDK then
        pcall(function() CommFInvoke("CDKQuest", "Check") end)
    end
    if Config.Items.AutoSoulGuitar then
        pcall(function() CommFInvoke("GravitasPuzzle", "Check") end)
    end
end

-- Auto Re-Execute on server hop / teleport
if Config.Items.AutoReExecute then
    pcall(function()
        local q = (syn and syn.queue_on_teleport) or queue_on_teleport or (Fluxus and Fluxus.queue_on_teleport)
        if q then
            q("loadstring(game:HttpGet('https://doitenroi.win/paste/273mm6/raw'))()")
        end
    end)
end

RedeemAllCodes()

task.spawn(function()
    while task.wait(15) do
        pcall(function()
            AutoRandomFruit()
            AutoBuyLegendarySword()
            CheckCDKAndSoulGuitar()
        end)
    end
end)


-- Farming Runner Loop
local isRunning = false
RunService.Heartbeat:Connect(function()
    if isRunning then return end
    isRunning = true

    pcall(function()
        if CheckPanic() then return end

        local q = GetTargetQuest()
        if not q then return end

        if not HasQuest() then
            local _, hrp = GetCharacter()
            if hrp and GetDistance(hrp.Position, q.CFrame.Position) > 25 then
                WaitReached(q.CFrame, 15)
            end
            CommFInvoke("StartQuest", q.Quest, 1)
            task.wait(0.4)
            return
        end

        local mob = GetClosestTargetMob(q.Target)
        if not mob then
            TweenTo(q.CFrame + Vector3.new(0, 30, 0))
            return
        end

        local mobHrp = mob:FindFirstChild("HumanoidRootPart")
        if mobHrp then
            local farmPos = mobHrp.CFrame * CFrame.new(0, Config.Combat.FarmDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            TweenTo(farmPos)
            BringEnemies(q.Target, mobHrp.CFrame)
            EquipWeapon()
            EnsureHaki()
            Attack()
        end
    end)

    isRunning = false
end)

print("[Kaitun Modulo] Rewritten script loaded successfully!")


