local lolz = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Emergency stop flag
if getgenv().emergency_stop == nil then
    getgenv().emergency_stop = false
end

-- Helper: Convert studs to power
local function StudsIntoPower(studs)
    return studs * 6
end

-- Get the closest target
function lolz:GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local dist = (targetHRP.Position - myHRP.Position).magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closestPlayer = player
            end
        end
    end
    print("Locked onto:", closestPlayer and closestPlayer.Name or "None")
    return closestPlayer
end

-- The main function to extend behind target
function lolz:ExtendHitboxBehindTarget(studs, duration)
    local targetPlayer = self:GetClosestTarget()
    if not targetPlayer then
        print("No target found.")
        return
    end
    local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then
        print("Target HRP not found.")
        return
    end

    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then
        print("Player HRP or Humanoid not found.")
        return
    end

    -- Save original speed and stop movement
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = 0

    local distance = StudsIntoPower(studs)

    local startTime = tick()
    local endTime = startTime + duration

    print("Extension started. Moving behind target...")

    -- Loop for continuous tracking
    while tick() < endTime and not getgenv().emergency_stop do
        -- Recalculate behind position
        local lookVector = targetHRP.CFrame.LookVector
        local behindPosition = targetHRP.CFrame.Position - (lookVector * 5)

        -- Direction towards behind position
        local direction = (behindPosition - hrp.Position).unit
        local moveSpeed = distance / duration

        -- Set velocity toward behind position
        hrp.Velocity = direction * moveSpeed

        RunService.Heartbeat:Wait()
    end

    -- Stop movement
    hrp.Velocity = Vector3.new(0,0,0)
    -- Restore speed
    humanoid.WalkSpeed = originalSpeed

    print("Extension ended.")
end

-- Bind Q key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        print("Q pressed, extending behind target.")
        lolz:ExtendHitboxBehindTarget(11.23, 0.56)
    end
end)

return lolz
