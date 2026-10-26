-- FE PP (Exact Block Model)
-- Replicates the rigid "L" shape fling welded to the leg.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local FLING_POWER = 10
local SPIN_SPEED = 100

local blockModel = nil
local spinConnection = nil

local function createBlock()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local leg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Right Leg")
    if not root or not leg then return end

    if blockModel then blockModel:Destroy() end

    -- Create the main model container
    blockModel = Instance.new("Model")
    blockModel.Name = "FEPP_Model"
    blockModel.Parent = char

    -- Main vertical block (attached to leg)
    local part1 = Instance.new("Part")
    part1.Name = "BaseBlock"
    part1.Size = Vector3.new(2, 4, 2)
    part1.Color = Color3.fromRGB(200, 200, 200)
    part1.Material = Enum.Material.SmoothPlastic
    part1.CanCollide = false
    part1.Massless = true
    part1.Anchored = false
    part1.Parent = blockModel
    part1.CFrame = leg.CFrame * CFrame.new(0, -1.5, 0)

    -- Extended horizontal block (the fling arm)
    local part2 = Instance.new("Part")
    part2.Name = "ExtenderBlock"
    part2.Size = Vector3.new(2, 2, 12)
    part2.Color = Color3.fromRGB(200, 200, 200)
    part2.Material = Enum.Material.SmoothPlastic
    part2.CanCollide = false
    part2.Massless = true
    part2.Anchored = false
    part2.Parent = blockModel
    part2.CFrame = part1.CFrame * CFrame.new(0, 0, -6)

    -- Weld part1 to the leg
    local weld1 = Instance.new("Weld")
    weld1.Part0 = leg
    weld1.Part1 = part1
    weld1.C0 = leg.CFrame:Inverse() * part1.CFrame
    weld1.Parent = part1

    -- Weld part2 to part1
    local weld2 = Instance.new("Weld")
    weld2.Part0 = part1
    weld2.Part1 = part2
    weld2.C0 = part1.CFrame:Inverse() * part2.CFrame
    weld2.Parent = part2

    -- Spin and fling loop
    local spin = 0
    if spinConnection then spinConnection:Disconnect() end
    spinConnection = RunService.Heartbeat:Connect(function()
        if not blockModel or not blockModel.Parent then return end
        
        spin = spin + math.rad(SPIN_SPEED)
        -- Spin the base, which rotates the whole model
        part1.CFrame = part1.CFrame * CFrame.Angles(0, spin, 0)
        
        -- Fling logic
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and (tRoot.Position - part1.Position).Magnitude < 15 then
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                    bv.Velocity = Vector3.new(math.random(-100, 100), 150, math.random(-100, 100)) * FLING_POWER
                    bv.Parent = tRoot
                    game:GetService("Debris"):AddItem(bv, 0.2)
                end
            end
        end
    end)
end

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        if blockModel and blockModel.Parent then
            blockModel:Destroy()
            blockModel = nil
            if spinConnection then spinConnection:Disconnect() end
        else
            createBlock()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    blockModel = nil
    if spinConnection then spinConnection:Disconnect() end
    task.wait(1)
    createBlock()
end)

task.wait(1)
createBlock()
