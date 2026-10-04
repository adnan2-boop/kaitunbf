--[[
    Performance.lua
    Optimasi Kinerja (FPS Boost, Pembersihan Tekstur & Efek Visual)
]]

local Services = require(script.Parent.Services)
local Config   = require(script.Parent.Config)

local Performance = {}

function Performance.ApplyBoost()
    if not Config.Performance.LowGraphics and not Config.Performance.FpsBoost then return end

    -- Matikan Post-Processing Lighting
    pcall(function()
        Services.Lighting.GlobalShadows = false
        Services.Lighting.FogEnd = 9e9
        Services.Lighting.Brightness = 1

        for _, fx in ipairs(Services.Lighting:GetChildren()) do
            if fx:IsA("PostEffect") or fx:IsA("BlurEffect") or fx:IsA("SunRaysEffect") or fx:IsA("BloomEffect") then
                fx.Enabled = false
            end
        end
    end)

    -- Kurangi kualitas Terrain & Mesh
    pcall(function()
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

-- Black Screen Toggle untuk menghemat CPU & GPU saat AFK semalaman
function Performance.ToggleBlackScreen(enable)
    local coreGui = game:GetService("CoreGui")
    local screenGui = coreGui:FindFirstChild("KaitunBlackScreen")
    if enable then
        if not screenGui then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "KaitunBlackScreen"
            screenGui.IgnoreGuiInset = true
            screenGui.ResetOnSpawn = false

            local frame = Instance.new("Frame", screenGui)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 0, 50)
            label.Position = UDim2.new(0, 0, 0.45, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 22
            label.Text = "Kaitun Modulo - AFK Mode (GPU Saver Active)"

            screenGui.Parent = coreGui
        end
    else
        if screenGui then screenGui:Destroy() end
    end
end

return Performance
