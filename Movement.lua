--[[
    Movement.lua
    Sistem Gerak Halus (Tweening) dengan Anti-Rubberband dan NoClip Otomatis
]]

local Services = require(script.Parent.Services)
local Config   = require(script.Parent.Config)

local Movement = {}
local activeTween = nil
local isNoClipping = false

-- NoClip Handler
Services.RunService.Stepped:Connect(function()
    if not Config.Movement.NoClip and not isNoClipping then return end
    local char = Services.LocalPlayer.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

-- Batalkan tween yang sedang berjalan
function Movement.Cancel()
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
    isNoClipping = false
end

-- Teleport instan jika dekat (< 15 studs)
local function TryInstantSnap(targetCFrame)
    local _, hrp = Services.GetCharacter()
    if not hrp then return false end
    if Services.GetDistance(hrp.Position, targetCFrame.Position) <= 20 then
        hrp.CFrame = targetCFrame
        return true
    end
    return false
end

-- Smooth Tween ke CFrame tujuan
function Movement.To(targetCFrame, speedOverride)
    local char, hrp, hum = Services.GetCharacter()
    if not hrp or not hum then return false end

    if TryInstantSnap(targetCFrame) then
        Movement.Cancel()
        return true
    end

    local speed = speedOverride or Config.Movement.TweenSpeed
    local distance = Services.GetDistance(hrp.Position, targetCFrame.Position)
    local tweenDuration = math.max(distance / speed, 0.05)

    -- Bypass bypass jika jarak jauh (misal antar pulau)
    if distance > 1500 and Config.Movement.BypassBorders then
        -- Naikkan ketinggian dulu untuk menghindari collision pulau tengah
        local highCFrame = CFrame.new(hrp.Position.X, math.max(hrp.Position.Y, 500), hrp.Position.Z)
        hrp.CFrame = highCFrame
    end

    Movement.Cancel()
    isNoClipping = true

    -- Nonaktifkan gravitasi selama terbang
    hrp.Velocity = Vector3.new(0, 0, 0)
    hum.PlatformStand = true

    local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear)
    activeTween = Services.TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})

    local completed = false
    activeTween.Completed:Connect(function(playbackState)
        hum.PlatformStand = false
        isNoClipping = false
        if playbackState == Enum.PlaybackState.Completed then
            completed = true
        end
    end)

    activeTween:Play()
    return activeTween
end

-- Tunggu sampai Tween selesai
function Movement.WaitUntilReached(targetCFrame, maxWaitTime)
    local tween = Movement.To(targetCFrame)
    if not tween then return false end

    local start = tick()
    maxWaitTime = maxWaitTime or 15

    while tick() - start < maxWaitTime do
        local _, hrp = Services.GetCharacter()
        if not hrp then break end
        if Services.GetDistance(hrp.Position, targetCFrame.Position) <= 15 then
            Movement.Cancel()
            return true
        end
        task.wait(0.1)
    end

    Movement.Cancel()
    return false
end

return Movement
