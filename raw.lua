local lolz = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create UI for adjustable distance
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DistanceControlUI"
    screenGui.Parent = game:GetService("StarterGui")

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 200, 0, 50)
    sliderLabel.Position = UDim2.new(0, 10, 0, 10)
    sliderLabel.Text = "Distance: 11.23"
    sliderLabel.TextColor3 = Color3.new(1, 1, 1)
    sliderLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    sliderLabel.Parent = screenGui

    local distanceSlider = Instance.new("Slider")
    distanceSlider.Size = UDim2.new(0, 200, 0, 20)
    distanceSlider.Position = UDim2.new(0, 10, 0, 70)
    distanceSlider.Min = 1
    distanceSlider.Max = 14
    distanceSlider.Value = 11.23
    distanceSlider.Parent = screenGui

    -- Update label as slider moves
    distanceSlider:GetPropertyChangedSignal("Value"):Connect(function()
        sliderLabel.Text = ("Distance: %.2f"):format(distanceSlider.Value)
    end)

    return distanceSlider
end

local distanceSlider = createUI()

-- Configurable parameters
local MAX_LOCK_DISTANCE = 50 -- maximum distance to lock
local MOVE_DURATION = 0.5 -- seconds to lerp to position

-- Helper: convert studs to power
local function StudsIntoPower(studs)
    return studs * 6
end

-- Get the closest target within range
function lolz:GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local dist = (targetHRP.Position - myHRP.Position).magnitude
            if dist < shortestDistance and dist <= MAX_LOCK_DISTANCE then
                shortestDistance = dist
                closestPlayer = player
            end
        end
    end
    print("Locked onto:", closestPlayer and closestPlayer.Name or "None")
    return closestPlayer
end

-- Make your character look at the back of the target
local function lookAtBackOfTarget(targetHRP)
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and targetHRP then
        local lookVector = targetHRP.CFrame.LookVector
        -- set your character's look rotation to face the back
        local targetPosition = targetHRP.CFrame.Position - (lookVector * 2) -- look slightly behind target
        local direction = (targetPosition - myHRP.Position).unit
        local newCF = CFrame.new(myHRP.Position, myHRP.Position + direction)
        myHRP.CFrame = newCF
    end
end

-- Move smoothly to behind target with animation and look
function lolz:MoveToBehindTarget(targetPlayer, distance, duration)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("Invalid target.")
        return
    end
    local targetHRP = targetPlayer.Character.HumanoidRootPart
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

    -- Make character face the back of the target
    local targetPos = targetHRP.CFrame.Position
    local backPosition = targetPos - (lookVector * 5)
    local lookDir = (backPosition - hrp.Position).unit
    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDir)

    -- Tween to behind position
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {Position = behindPosition})
    tween:Play()

    tween.Completed:Wait()

    -- Stop walking animation
    walkTrack:Stop()
    walkAnim:Destroy()
end

-- Main extension with lock and move
function lolz:ExtendBehindTarget()
    local targetPlayer = self:GetClosestTarget()
    if not targetPlayer then return end

    local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end

    local dist = (targetHRP.Position - myHRP.Position).magnitude
    local currentMaxDistance = distanceSlider.Value

    if dist > currentMaxDistance then
        print("Target too far to lock.")
        return
    end

    -- Call move to behind with current slider value
    self:MoveToBehindTarget(targetPlayer, currentMaxDistance, MOVE_DURATION)
end

-- Keybind Q
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        print("Q pressed. Locking on and moving behind target...")
        lolz:ExtendBehindTarget()
    end
end)
