local lolz = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Emergency stop flag
if getgenv().emergency_stop == nil then
    getgenv().emergency_stop = false
end

-- Convert studs to power (multiplier)
local function StudsIntoPower(studs)
    return studs * 6
end

-- Extend hitbox with stop/move logic
function lolz:ExtendHitbox(studs, duration)
    local distance = StudsIntoPower(studs)
    local startTime = tick()

    -- Wait until character and HumanoidRootPart exist
    while not (LocalPlayer.Character and LocalPlayer.Character.Parent and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) do
        RunService.Heartbeat:Wait()
    end

    local character = LocalPlayer.Character
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Save original WalkSpeed
    local originalSpeed = humanoid.WalkSpeed

    -- Stop running
    humanoid.WalkSpeed = 0

    local originalVelocity = hrp.Velocity

    repeat
        RunService.Heartbeat:Wait()

        -- Check for emergency stop
        if getgenv().emergency_stop then
            break
        end

        -- Calculate new velocity
        local lookVector = hrp.CFrame.LookVector
        local newVelocity = originalVelocity + (lookVector * distance)
        hrp.Velocity = newVelocity

        RunService.RenderStepped:Wait()
    until tick() - startTime > duration or getgenv().emergency_stop

    -- Reset velocity
    hrp.Velocity = originalVelocity

    -- Restore WalkSpeed
    humanoid.WalkSpeed = originalSpeed

    -- Reset emergency stop flag if needed
    if getgenv().emergency_stop then
        getgenv().emergency_stop = false
    end
end

-- Stop extension
function lolz:StopExtendingHitbox()
    getgenv().emergency_stop = true
end

-- Bind Q key to trigger the hitbox extension
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        -- Trigger extension with desired studs and duration
        lolz:ExtendHitbox(11.23, 0.56)
    end
end)

return lolz
