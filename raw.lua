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

-- Get the closest target (lock-on)
function lolz:GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local distance = (targetHRP.Position - myHRP.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

-- Extend hitbox behind target with continuous tracking
function lolz:ExtendHitboxBehindTarget(studs, duration)
    local targetPlayer = self:GetClosestTarget()
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("No valid target found.")
        return
    end

    local targetHRP = targetPlayer.Character.HumanoidRootPart
    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    -- Save original WalkSpeed
    local originalSpeed = humanoid.WalkSpeed
    -- Stop movement
    humanoid.WalkSpeed = 0

    -- Calculate total extension distance
    local distance = StudsIntoPower(studs)

    local startTime = tick()
    local endTime = startTime + duration

    -- Loop for continuous target tracking
    while tick() < endTime and not getgenv().emergency_stop do
        -- Recalculate behind position based on current target position and look vector
        local lookVector = targetHRP.CFrame.LookVector
        local behindPosition = targetHRP.CFrame.Position - (lookVector * 5)

        -- Calculate direction towards behind position
        local direction = (behindPosition - hrp.Position).unit
        local moveSpeed = distance / duration

        -- Set velocity towards behind position
        hrp.Velocity = direction * moveSpeed

        RunService.Heartbeat:Wait()
    end

    -- Stop movement after extension
    hrp.Velocity = Vector3.new(0, 0, 0)
    -- Restore original WalkSpeed
    humanoid.WalkSpeed = originalSpeed
end

-- Stop extension
function lolz:StopExtendingHitbox()
    getgenv().emergency_stop = true
end

-- Bind Q key to trigger the targeting and extension
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        -- Trigger the behind target extension
        lolz:ExtendHitboxBehindTarget(11.23, 0.56)
    end
end)

return lolz
