local lolz = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Configurable parameters
local MAX_LOCK_DISTANCE = 14 -- maximum distance to lock
local MOVE_DURATION = 0.5 -- seconds to lerp to position
local STUDS = 10.21 -- extension distance

-- Helper: convert studs to power
local function StudsIntoPower(studs)
    return studs * 6
end

local function getKillersFolder()
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    return playersFolder:FindFirstChild("Killers")
end

local function isValidKillerModel(model)
    if not model then return false end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChildWhichIsA("Humanoid")
    return hrp and humanoid and humanoid.Health and humanoid.Health > 0
end

-- Get the closest killer within range
function lolz:GetClosestKiller()
    local killersFolder = getKillersFolder()
    if not killersFolder then
        print("No Killers folder found.")
        return nil
    end

    local closestKiller = nil
    local shortestDistance = math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, killer in pairs(killersFolder:GetChildren()) do
        if isValidKillerModel(killer) then
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myHRP.Position).magnitude
                if dist < shortestDistance and dist <= MAX_LOCK_DISTANCE then
                    shortestDistance = dist
                    closestKiller = killer
                end
            end
        end
    end

    if closestKiller then
        print("Locked onto killer:", closestKiller.Name)
    else
        print("No valid killers in range.")
    end
    return closestKiller
end

-- Move smoothly to target behind position with animation
function lolz:MoveToBehindTarget(targetModel, studs, duration)
    if not targetModel or not targetModel:FindFirstChild("HumanoidRootPart") then
        print("Invalid target.")
        return
    end
    local targetHRP = targetModel.HumanoidRootPart
    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    -- Play walk animation
    local walkAnim = Instance.new("Animation")
    walkAnim.AnimationId = "rbxassetid://2554305229" -- Example walk animation
    local walkTrack = humanoid:LoadAnimation(walkAnim)
    walkTrack:Play()

    -- Calculate behind position
    local lookVector = targetHRP.CFrame.LookVector
    local behindPosition = targetHRP.CFrame.Position - (lookVector * 5)

    -- Tween to behind position
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {Position = behindPosition})
    tween:Play()

    -- Wait for tween to complete
    tween.Completed:Wait()

    -- Stop walking animation
    walkTrack:Stop()
    walkAnim:Destroy()
end

-- Main extension function
function lolz:ExtendBehindTarget()
    local targetModel = self:GetClosestKiller()
    if not targetModel then return end
    -- Lock only if within range
    local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end

    local dist = (targetHRP.Position - myHRP.Position).magnitude
    if dist > MAX_LOCK_DISTANCE then
        print("Target too far to lock.")
        return
    end

    -- Move to behind target with animation
    self:MoveToBehindTarget(targetModel, STUDS, MOVE_DURATION)
end

-- Bind Q to trigger the lock and move
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        print("Q pressed. Locking on and moving behind target...")
        lolz:ExtendBehindTarget()
    end
end)

return lolz
