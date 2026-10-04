--[[
    Services.lua
    Pengelola Services Roblox, Utilities, dan Remote Invoker yang Aman
]]

local Services = {}

-- Roblox Services Cache
Services.Players         = game:GetService("Players")
Services.RunService      = game:GetService("RunService")
Services.TweenService    = game:GetService("TweenService")
Services.HttpService     = game:GetService("HttpService")
Services.TeleportService = game:GetService("TeleportService")
Services.Lighting        = game:GetService("Lighting")
Services.VirtualUser     = game:GetService("VirtualUser")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local Player References
Services.LocalPlayer = Services.Players.LocalPlayer
Services.Mouse = Services.LocalPlayer:GetMouse()

-- Cache Remotes
local remotesFolder = Services.ReplicatedStorage:WaitForChild("Remotes", 5)
Services.CommF = remotesFolder and remotesFolder:FindFirstChild("CommF_")
Services.CommE = remotesFolder and remotesFolder:FindFirstChild("CommE")

-- Helper: Ambil Karakter & HumanoidRootPart secara aman
function Services.GetCharacter()
    local char = Services.LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then
        return char, hrp, hum
    end
    return nil
end

-- Safe Remote Invoker (Mencegah crashing & disconnect karena remote spam)
local lastCallTimes = {}
function Services.FireServerSafe(remote, minInterval, ...)
    if not remote then return nil end
    local remoteName = remote.Name .. tostring((...))
    local now = tick()
    if lastCallTimes[remoteName] and (now - lastCallTimes[remoteName] < (minInterval or 0.1)) then
        return nil
    end
    lastCallTimes[remoteName] = now

    local success, result
    if remote:IsA("RemoteFunction") then
        success, result = pcall(function(...)
            return remote:InvokeServer(...)
        end, ...)
    elseif remote:IsA("RemoteEvent") then
        success, result = pcall(function(...)
            remote:FireServer(...)
        end, ...)
    end
    return success and result or nil
end

-- Safe CommF_ caller
function Services.CommFInvoke(...)
    if not Services.CommF then return nil end
    local success, result = pcall(function(...)
        return Services.CommF:InvokeServer(...)
    end, ...)
    return success and result or nil
end

-- Math / Distance Utility
function Services.GetDistance(pos1, pos2)
    local p1 = typeof(pos1) == "CFrame" and pos1.Position or (typeof(pos1) == "Vector3" and pos1 or pos1.Position)
    local p2 = typeof(pos2) == "CFrame" and pos2.Position or (typeof(pos2) == "Vector3" and pos2 or pos2.Position)
    return (p1 - p2).Magnitude
end

return Services
