--[[
    Combat.lua
    Sistem Auto-Equip, Haki Otomatis, Bring Mobs, dan Fast Attack Bersih
]]

local Services = require(script.Parent.Services)
local Config   = require(script.Parent.Config)

local Combat = {}
local currentTool = nil

-- Auto Equip Senjata berdasarkan tipe yang dipilih di Config
function Combat.EquipWeapon(weaponType)
    weaponType = weaponType or Config.Combat.SelectedWeaponType
    local char = Services.LocalPlayer.Character
    local bp   = Services.LocalPlayer:FindFirstChildOfClass("Backpack")
    if not char or not bp then return false end

    -- Cek jika sudah memegang senjata bertipe benar
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and (equipped.ToolTip == weaponType or (weaponType == "Blox Fruit" and string.find(equipped.Name, "Fruit"))) then
        currentTool = equipped
        return true
    end

    -- Cari di Backpack
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.ToolTip == weaponType or (weaponType == "Blox Fruit" and string.find(tool.Name, "Fruit")) then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(tool)
                    currentTool = tool
                    return true
                end
            end
        end
    end
    return false
end

-- Otomatis aktifkan Buso Haki jika belum aktif
function Combat.EnsureBuso()
    if not Config.Progression.AutoBuso then return end
    local char = Services.LocalPlayer.Character
    if char and not char:FindFirstChild("HasBuso") then
        Services.CommFInvoke("Buso")
    end
end

-- Otomatis aktifkan Ken Haki jika belum aktif
function Combat.EnsureKen()
    if not Config.Progression.AutoKen then return end
    local char = Services.LocalPlayer.Character
    if char and not char:FindFirstChild("KenHaki") then
        Services.CommE:FireServer("Ken", true)
    end
end

-- Kumpulkan (Bring) monster ke satu titik pusat
function Combat.BringEnemies(mobName, targetCFrame)
    if not Config.Combat.BringMobs then return end
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return end

    local maxDist = Config.Combat.BringMobDistance

    for _, mob in ipairs(enemiesFolder:GetChildren()) do
        if mob.Name == mobName and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
            local mobHrp = mob.HumanoidRootPart
            local mobHum = mob.Humanoid

            if mobHum.Health > 0 and Services.GetDistance(mobHrp.Position, targetCFrame.Position) <= maxDist then
                mobHrp.CFrame = targetCFrame
                mobHrp.CanCollide = false
                mobHum.WalkSpeed = 0
                mobHum.JumpPower = 0
            end
        end
    end
end

-- Fast Attack Bersih & Aman
local lastAttackTick = 0
function Combat.Attack()
    local now = tick()
    if now - lastAttackTick < Config.Combat.AttackDelay then return end
    lastAttackTick = now

    pcall(function()
        Services.VirtualUser:CaptureController()
        Services.VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

return Combat
