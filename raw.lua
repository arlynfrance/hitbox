-- Executable Script for Roblox Executors
-- Lock onto nearest target within range, move behind, face them, with UI slider control

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Create UI slider for distance control
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DistanceControlUI"
    screenGui.Parent = game:GetService("StarterGui")
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 50)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.Text = "Distance: 11.23"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.Parent = screenGui
    
    local slider = Instance.new("Slider")
    slider.Size = UDim2.new(0, 200, 0, 20)
    slider.Position = UDim2.new(0, 10, 0, 70)
    slider.Min = 1
    slider.Max = 50
    slider.Value = 11.23
    slider.Parent = screenGui
    
    -- Update label as slider moves
    slider:GetPropertyChangedSignal("Value"):Connect(function()
        label.Text = ("Distance: %.2f"):format(slider.Value)
    end)
    return slider
end

local distanceSlider = createUI()

-- Parameters
local MAX_LOCK_DISTANCE = 50 -- max lock distance
local MOVE_DURATION = 0.5 -- seconds to move behind
local EXTEND_STUDS = 11.23 -- default extension distance

-- Helper: convert studs to power
local function StudsIntoPower(studs)
    return studs * 6
end

-- Find closest target within range
function GetClosestTarget()
    local closest, minDist = nil, math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = p.Character.HumanoidRootPart
            local dist = (targetHRP.Position - myHRP.Position).magnitude
            if dist < minDist and dist <= MAX_LOCK_DISTANCE then
                minDist = dist
                closest = p
            end
        end
    end
    return closest
end

-- Make your character face the back of the target
local function faceBackOfTarget(targetHRP)
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and targetHRP then
        local lookVector = targetHRP.CFrame.LookVector
        local backPos = targetHRP.CFrame.Position - (lookVector * 2)
        local direction = (backPos - myHRP.Position).unit
        myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + direction)
    end
end

-- Move behind target with animation and face them
local function moveBehindTarget(targetPlayer, distance, duration)
    local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not humanoid or not hrp then return end

    -- Play walk animation
    local walkAnim = Instance.new("Animation")
    walkAnim.AnimationId = "rbxassetid://2554305229" -- You can change this
    local walkTrack = humanoid:LoadAnimation(walkAnim)
    walkTrack:Play()

    -- Calculate behind position
    local lookVector = targetHRP.CFrame.LookVector
    local behindPos = targetHRP.CFrame.Position - (lookVector * 5)

    -- Face the back of the target
    local backPos = targetHRP.CFrame.Position - (lookVector * 2)
    local lookDir = (backPos - hrp.Position).unit
    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDir)

    -- Tween to behind position
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {Position = behindPos})
    tween:Play()
    tween.Completed:Wait()

    -- Stop animation
    walkTrack:Stop()
    walkAnim:Destroy()
end

-- Main function: lock, face, move
local function lockAndMove()
    local targetPlayer = GetClosestTarget()
    if not targetPlayer then
        print("No target in range")
        return
    end
    local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end

    local dist = (targetHRP.Position - myHRP.Position).magnitude
    local currentDistance = distanceSlider and distanceSlider.Value or EXTEND_STUDS
    if dist > currentDistance then
        print("Target too far to lock.")
        return
    end

    -- Move behind target with animation
    moveBehindTarget(targetPlayer, currentDistance, MOVE_DURATION)

    -- Face the back of target after movement
    faceBackOfTarget(targetHRP)
end

-- Bind Q key to trigger the action
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        print("Q pressed - locking and moving behind target")
        lockAndMove()
    end
end)
