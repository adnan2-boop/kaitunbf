--[[
    Config.lua
    Konfigurasi Terpusat untuk Kaitun Blox Fruits Bot
]]

local Config = {
    -- Team Selection
    Team = "Pirates", -- "Pirates" atau "Marines"

    -- General Performance & Client
    Performance = {
        FpsBoost = true,
        LowGraphics = true,
        BlackScreen = false,
        AutoHopWhenIdle = true,
        IdleTimeout = 120, -- detik sebelum server hop jika stuck
        ServerHopDelay = 3600, -- 1 jam interval server hop
    },

    -- Combat & Farming Settings
    Combat = {
        SelectedWeaponType = "Melee", -- "Melee", "Sword", "Gun", "Blox Fruit"
        FastAttack = true,
        AttackDelay = 0.12, -- Delay aman untuk mencegah remote throttle/ban
        SkillSpam = true,
        BringMobs = true,
        BringMobDistance = 250,
        FarmDistance = 25, -- Jarak ketinggian/posisi di atas mob saat memukul
    },

    -- Movement / Tween Settings
    Movement = {
        TweenSpeed = 300, -- Kecepatan tween aman
        BypassBorders = true,
        NoClip = true,
    },

    -- Health & Panic Protection
    PanicMode = {
        Enabled = true,
        LowHealthPercent = 25,
        SafeHealthPercent = 80,
        EscapeHeight = 350, -- Ketinggian aman saat HP sekarat
        CheckInterval = 0.5,
    },

    -- Automation Targets
    Progression = {
        AutoQuest = true,
        AutoSea2 = true,
        AutoSea3 = true,
        AutoKen = true,
        AutoBuso = true,
        AutoStats = true,
        StatPriority = {"Melee", "Defense", "Sword"}, -- Urutan alokasi stat
    },

    -- Melee & Mastery Progression
    Melee = {
        AutoBuy = true,
        AutoMastery = true,
        MasteryCapV1 = 400,
        MasteryCapV2 = 500,
        TargetMelees = {
            "Black Leg",
            "Electro",
            "Water Kung Fu",
            "Dragon Breath",
            "Superhuman",
            "Death Step",
            "Sharkman Karate",
            "Electric Claw",
            "Dragon Talon",
            "Godhuman"
        }
    },

    -- Fruit & Item Collector
    Items = {
        AutoStoreFruit = true,
        AutoRandomFruit = true,
        AutoSaber = true,
        AutoCDK = true,
        AutoSoulGuitar = true,
        AutoBuyLegendarySword = true, -- Shisui, Saddi, Wando (True Triple Katana material)
        AutoRedeemCodes = true,
        AutoReExecute = true, -- Auto execute script kembali saat reconnect / server hop
    }
}

return Config
