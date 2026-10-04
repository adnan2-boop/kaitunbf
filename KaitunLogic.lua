--[[
    KaitunLogic.lua
    Logika Inti Kaitun Blox Fruits (State Machine, Farming, Storing, Panic Mode)
]]

local Services     = require(script.Parent.Services)
local Config       = require(script.Parent.Config)
local Movement     = require(script.Parent.Movement)
local Combat       = require(script.Parent.Combat)
local QuestManager = require(script.Parent.QuestManager)

local KaitunLogic = {}
local isPanicking = false

-- Auto Stat Allocator
function KaitunLogic.AutoStats()
    if not Config.Progression.AutoStats then return end
    local points = Services.LocalPlayer:FindFirstChild("Data") and Services.LocalPlayer.Data:FindFirstChild("Points")
    if points and points.Value > 0 then
        for _, statName in ipairs(Config.Progression.StatPriority) do
            Services.CommFInvoke("AddPoint", statName, math.min(points.Value, 10))
            task.wait(0.1)
        end
    end
end

-- Simpan Buah Otomatis (Anti-Lost Fruit)
function KaitunLogic.AutoStoreFruit()
    if not Config.Items.AutoStoreFruit then return end
    local bp = Services.LocalPlayer:FindFirstChildOfClass("Backpack")
    local char = Services.LocalPlayer.Character
    if not bp then return end

    local function CheckFruit(tool)
        if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then
            local fruitName = tool:GetAttribute("OriginalName") or tool.Name
            Services.CommFInvoke("StoreFruit", fruitName, tool)
        end
    end

    for _, tool in ipairs(bp:GetChildren()) do CheckFruit(tool) end
    if char then
        for _, tool in ipairs(char:GetChildren()) do CheckFruit(tool) end
    end
end

-- Mode Panik saat HP Rendah
function KaitunLogic.CheckPanic()
    local _, hrp, hum = Services.GetCharacter()
    if not hum or not hrp then return false end

    local healthPct = (hum.Health / hum.MaxHealth) * 100

    if healthPct <= Config.PanicMode.LowHealthPercent then
        isPanicking = true
        Movement.Cancel()
        -- Naik ke atas untuk regen
        local safePos = CFrame.new(hrp.Position.X, hrp.Position.Y + Config.PanicMode.EscapeHeight, hrp.Position.Z)
        hrp.CFrame = safePos

        while hum.Health > 0 and ((hum.Health / hum.MaxHealth) * 100) < Config.PanicMode.SafeHealthPercent do
            task.wait(0.5)
        end
        isPanicking = false
        return true
    end

    return false
end

-- Cari Mob Terdekat yang sesuai Target Quest
function KaitunLogic.FindTargetMob(mobName)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    local _, hrp = Services.GetCharacter()
    if not hrp then return nil end

    local closestMob = nil
    local minDistance = math.huge

    for _, mob in ipairs(enemies:GetChildren()) do
        if mob.Name == mobName and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
            if mob.Humanoid.Health > 0 then
                local dist = Services.GetDistance(hrp.Position, mob.HumanoidRootPart.Position)
                if dist < minDistance then
                    minDistance = dist
                    closestMob = mob
                end
            end
        end
    end

    return closestMob
end

-- Siklus Utama Farming 1 Putaran
function KaitunLogic.FarmCycle()
    if KaitunLogic.CheckPanic() then return end

    local questData = QuestManager.GetCurrentQuestData()
    if not questData then return end

    -- 1. Ambil Quest jika belum ada
    if not QuestManager.HasActiveQuest() then
        local _, hrp = Services.GetCharacter()
        if not hrp then return end

        if Services.GetDistance(hrp.Position, questData.CFrame.Position) > 25 then
            Movement.WaitUntilReached(questData.CFrame, 15)
        end

        QuestManager.ClaimQuest(questData)
        task.wait(0.5)
        return
    end

    -- 2. Cari target mob
    local targetMob = KaitunLogic.FindTargetMob(questData.Target)

    if not targetMob then
        -- Jika mob belum spawn, pergi ke area spawn quest
        Movement.To(questData.CFrame + Vector3.new(0, 30, 0))
        task.wait(0.5)
        return
    end

    local mobHrp = targetMob:FindFirstChild("HumanoidRootPart")
    local mobHum = targetMob:FindFirstChild("Humanoid")
    if not mobHrp or not mobHum or mobHum.Health <= 0 then return end

    -- 3. Posisikan pemain di atas mob (posisi aman farming)
    local farmCFrame = mobHrp.CFrame * CFrame.new(0, Config.Combat.FarmDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    Movement.To(farmCFrame)

    -- 4. Kumpulkan mob sekitar
    Combat.BringEnemies(questData.Target, mobHrp.CFrame)

    -- 5. Serang
    Combat.EquipWeapon()
    Combat.EnsureBuso()
    Combat.EnsureKen()
    Combat.Attack()
end

return KaitunLogic
