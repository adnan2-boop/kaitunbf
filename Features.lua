--[[
    Features.lua
    Modul Fitur Tambahan:
    - Auto Redeem All Available Codes
    - Auto Random (Gacha) Blox Fruit
    - Auto Buy Legendary Sword Dealer (Shisui, Saddi, Wando)
    - Auto Soul Guitar Quest Checker / Steps
    - Auto Cursed Dual Katana (CDK) Progression
    - Auto Re-Execute on Hop/Teleport (queue_on_teleport)
    - Ultra FPS Boost & Performance Manager
]]

local Services = require(script.Parent.Services)
local Config   = require(script.Parent.Config)
local Movement = require(script.Parent.Movement)

local Features = {}

-- Daftar Kode Blox Fruits Aktif & Terverifikasi
local BloxFruitsCodes = {
    "SECRET_ADMIN",
    "ADMIN_STRENGTH",
    "DRAGONABUSE",
    "24NOOBS",
    "SUB2GAMERROBOT_EXP1",
    "StrawHatMaine",
    "Sub2Fer999",
    "Enyu_is_Pro",
    "Magicbus",
    "JCWK",
    "Starcodeheo",
    "Bluxxy",
    "fudd10_v2",
    "SUB2GAMERROBOT_RESET1",
    "Sub2UncleKizaru",
    "Sub2OfficialNoobie",
    "TheGreatAce",
    "Axiore",
    "TantaiGaming",
    "fudd10",
    "Bignews"
}

-- 1. Auto Redeem All Available Codes (Eksekusi sekali saja saat awal start)
local codesRedeemed = false
function Features.RedeemCodes()
    if not Config.Items.AutoRedeemCodes or codesRedeemed then return end
    codesRedeemed = true

    task.spawn(function()
        print("[Kaitun Features] Menjalankan Auto Redeem Code (Hanya Sekali)...")
        for _, code in ipairs(BloxFruitsCodes) do
            pcall(function()
                Services.CommFInvoke("RedeemCode", code)
            end)
            task.wait(0.8) -- Delay aman agar remote tidak throttling
        end
        print("[Kaitun Features] Semua kode selesai dicoba. Auto redeem berhenti sepenuhnya.")
    end)
end

-- 2. Auto Random Blox Fruit (Gacha Buah Zioles / Cousin)
function Features.AutoRandomFruit()
    if not Config.Items.AutoRandomFruit then return end
    pcall(function()
        -- Remote "Cousin", "Buy" melakukan gacha buah
        local res = Services.CommFInvoke("Cousin", "Buy")
        if res then
            print("[Kaitun Features] Gacha Buah Berhasil:", tostring(res))
        end
    end)
end

-- 3. Auto Buy Legendary Swords (Shisui, Saddi, Wando dari Legendary Sword Dealer)
local LegendarySwords = {"Shisui", "Saddi", "Wando"}
function Features.AutoBuyLegendarySword()
    if not Config.Items.AutoBuyLegendarySword then return end
    pcall(function()
        for _, sword in ipairs(LegendarySwords) do
            -- Cek apakah sudah punya di inventory/backpack
            local hasSword = Services.CommFInvoke("getInventoryWeapons")
            local alreadyOwned = false
            if typeof(hasSword) == "table" then
                for _, w in pairs(hasSword) do
                    if w.Name == sword then
                        alreadyOwned = true
                        break
                    end
                end
            end

            if not alreadyOwned then
                -- Beli jika NPC Legendary Sword Dealer sedang menjualnya
                Services.CommFInvoke("LegendarySwordDealer", sword)
            end
        end
    end)
end

-- 4. CDK (Cursed Dual Katana) Progression Trigger
function Features.CheckCDK()
    if not Config.Items.AutoCDK then return end
    pcall(function()
        -- Cek ketersediaan Yama & Tushita (Mastery 350+)
        -- Panggil remote interaksi Crypt / Evil Tree
        Services.CommFInvoke("CDKQuest", "Check")
    end)
end

-- 5. Soul Guitar Progression Trigger
function Features.CheckSoulGuitar()
    if not Config.Items.AutoSoulGuitar then return end
    pcall(function()
        -- Panggil remote interaksi kuburan Haunted Castle (Grave / Soul Guitar Puzzle)
        Services.CommFInvoke("GravitasPuzzle", "Check")
    end)
end

-- 6. Auto Re-Execute on Teleport / Server Hop
function Features.SetupAutoExecute(rawScriptCode)
    if not Config.Items.AutoReExecute then return end
    pcall(function()
        local queue = (syn and syn.queue_on_teleport) or queue_on_teleport or (Fluxus and Fluxus.queue_on_teleport)
        if queue then
            local scriptToRun = rawScriptCode or "loadstring(game:HttpGet('https://doitenroi.win/paste/273mm6/raw'))()"
            queue(scriptToRun)
            print("[Kaitun Features] Queue on teleport berhasil diatur!")
        end
    end)
end

return Features
