--[[
    main.lua
    Entry Point Utama untuk Kaitun Blox Fruits Bot
]]

print("[Kaitun Modulo] Memuat modul-modul sistem...")

local Config       = require(script.Parent.Config)
local Services     = require(script.Parent.Services)
local Performance  = require(script.Parent.Performance)
local KaitunLogic  = require(script.Parent.KaitunLogic)
local Features     = require(script.Parent.Features)


-- 1. Inisialisasi Game
repeat task.wait() until game:IsLoaded()

-- Pilih Tim Otomatis (Pirates / Marines)
task.spawn(function()
    pcall(function()
        Services.CommFInvoke("SetTeam", Config.Team)
    end)
end)

-- 2. Terapkan Optimasi Performa
Performance.ApplyBoost()
if Config.Performance.BlackScreen then
    Performance.ToggleBlackScreen(true)
end

-- 3. Anti-AFK Handler (Mencegah Disconnect 20 Menit Roblox)
Services.LocalPlayer.Idled:Connect(function()
    Services.VirtualUser:CaptureController()
    Services.VirtualUser:ClickButton2(Vector2.new())
end)

-- 4. Background Routine (Simpan Buah & Alokasi Stat)
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            KaitunLogic.AutoStoreFruit()
            KaitunLogic.AutoStats()
        end)
    end
end)
-- 5. Fitur Otomatis Tambahan (Redeem Codes, Gacha Buah, Legendary Swords, CDK, Soul Guitar, Auto-Execute)
Features.SetupAutoExecute()
Features.RedeemCodes()

task.spawn(function()
    while task.wait(15) do
        pcall(function()
            Features.AutoRandomFruit()
            Features.AutoBuyLegendarySword()
            Features.CheckCDK()
            Features.CheckSoulGuitar()
        end)
    end
end)


-- 5. Main Loop Farming
print("[Kaitun Modulo] Bot aktif dan berjalan!")

Services.RunService.Heartbeat:Connect(function()
    pcall(function()
        KaitunLogic.FarmCycle()
    end)
end)

