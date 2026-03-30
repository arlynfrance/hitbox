local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lolz = {}
local extensionConnection = nil
local isExtending = false

-- Convert studs to power multiplier
local function StudsIntoPower(studs)
    return studs * 6
end

-- Extend hitbox while Q is held
local function extendHitbox(studs)
    -- Wait for character and HumanoidRootPart
    while not (LocalPlayer.Character and LocalPlayer.Character.Parent and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) do
        game:GetService("RunService").Heartbeat:Wait()
    end

    local hrp = LocalPlayer.Character.HumanoidRootPart
    local originalVelocity = hrp.Velocity
    local distance = StudsIntoPower(studs)

    -- Create a connection to continuously update velocity
    extensionConnection = RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent then
            -- Character might have died
            if extensionConnection then
                extensionConnection:Disconnect()
                extensionConnection = nil
            end
            return
        end
        local lookVector = hrp.CFrame.LookVector
        hrp.Velocity = originalVelocity + (lookVector * distance)
    end)
end

local function stopHitboxExtension()
    if extensionConnection then
        extensionConnection:Disconnect()
        extensionConnection = nil
    end
    -- Reset velocity to normal
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        -- Reset to original velocity (if needed, else keep it as is)
        -- Here, you might want to store the original velocity before extension
        -- For simplicity, this resets to zero
        hrp.Velocity = Vector3.new(0,0,0)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        -- Start extending hitbox (e.g., 10 studs)
        isExtending = true
        extendHitbox(10)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        -- Stop extending hitbox when Q is released
        isExtending = false
        stopHitboxExtension()
    end
end)

return lolz
