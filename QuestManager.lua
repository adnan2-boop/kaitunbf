--[[
    QuestManager.lua
    Sistem Pengambilan Quest Otomatis Berdasarkan Level dan Sea
]]

local Services = require(script.Parent.Services)

local QuestManager = {}

-- Database Quest Sea 1 (Contoh inti level 1-700)
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

-- Ambil Level Pemain saat ini dari PlayerGui atau Data
function QuestManager.GetPlayerLevel()
    local player = Services.LocalPlayer
    local data = player:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    -- Fallback ke UI jika data tersembunyi
    local gui = player:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("Main") and gui.Main:FindFirstChild("Level") then
        local rawText = gui.Main.Level.Text
        local num = string.match(rawText, "%d+")
        if num then return tonumber(num) end
    end
    return 1
end

-- Cari Quest terbaik sesuai Level
function QuestManager.GetCurrentQuestData()
    local myLevel = QuestManager.GetPlayerLevel()
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

-- Cek apakah saat ini sedang memiliki Quest aktif
function QuestManager.HasActiveQuest()
    local player = Services.LocalPlayer
    local gui = player:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("Main") and gui.Main:FindFirstChild("Quest") then
        return gui.Main.Quest.Visible
    end
    return false
end

-- Ambil Quest dari NPC
function QuestManager.ClaimQuest(questData)
    if QuestManager.HasActiveQuest() then return true end
    if not questData then return false end

    -- Panggil remote resmi StartQuest
    local res = Services.CommFInvoke("StartQuest", questData.Quest, 1)
    return res ~= nil
end

-- Batalkan Quest (jika salah target)
function QuestManager.AbandonQuest()
    Services.CommFInvoke("AbandonQuest")
end

return QuestManager
