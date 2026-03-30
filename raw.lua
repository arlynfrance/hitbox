local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lolz = {}
local extensionActive = false
local extensionConnection = nil

-- Convert studs to power multiplier
local function StudsIntoPower(studs)
    return studs * 6
end

-- Extend hitbox while Q is held down
function lolz:ExtendHitbox(studs, duration)
    if extensionActive then return end -- Prevent multiple runs
    extensionActive = true

    local distance = StudsIntoPower(studs)
    local startTime = tick()

    -- Wait for character and HumanoidRootPart
    while not (LocalPlayer.Character and LocalPlayer.Character.Parent and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) do
        game:GetService("RunService").Heartbeat:Wait()
        if getgenv().emergency_stop then break
    end

    local hrp = LocalPlayer.Character.HumanoidRootPart
    local originalVelocity = hrp.Velocity

    -- Create a connection for heartbeat updates
    extensionConnection = RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent then
            -- Character might have died
            self:StopExtendingHitbox()
            return
        end

        -- Apply the velocity boost
        local lookVector = hrp.CFrame.LookVector
        local newVelocity = originalVelocity + (lookVector * distance)
        hrp.Velocity = newVelocity
    end)

    -- Wait for the specified duration
    repeat
        game:GetService("RunService").Heartbeat:Wait()
        if getgenv().emergency_stop then break
    until tick() - startTime > duration or getgenv().emergency_stop

    -- Reset velocity and cleanup
    if hrp and hrp.Parent then
        hrp.Velocity = originalVelocity
    end
    self:StopExtendingHitbox()
end

function lolz:StopExtendingHitbox()
    getgenv().emergency_stop = false
    if extensionConnection then
        extensionConnection:Disconnect()
        extensionConnection = nil
    end
    extensionActive = false
end

-- Monitor key press and release
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        -- Start extending hitbox when Q is pressed
        lolz:ExtendHitbox(10, 0.5) -- Example: extend 10 studs for 0.5 seconds
    end
end)

return lolz
