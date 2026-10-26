-- FE PP (Rectangle Block Fling)
-- Creates a block welded to the player's legs that spins and flings.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local FLING_POWER = 5
local BLOCK_SIZE = Vector3.new(4, 1, 15)
local SPIN_SPEED = 50

local block = nil
local weld = nil

local function createBlock()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local leg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Right Leg")
    if not root or not leg then return end

    if block then block:Destroy() end

    -- Create the block
    block = Instance.new("Part")
    block.Name = "FEPP_Block"
    block.Size = BLOCK_SIZE
    block.Transparency = 0.5
    block.Color = Color3.fromRGB(255, 0, 0)
    block.Material = Enum.Material.Neon
    block.CanCollide = false
    block.Massless = true
    block.Anchored = false
    block.Parent = char

    -- Position in middle of legs
    block.CFrame = leg.CFrame * CFrame.new(0, -1, 0)

    -- Weld it to the leg
    weld = Instance.new("Weld")
    weld.Part0 = leg
    weld.Part1 = block
    weld.C0 = leg.CFrame:Inverse() * block.CFrame
    weld.Parent = block

    -- Spin and fling loop
    local spin = 0
    RunService.Heartbeat:Connect(function()
        if not block or not block.Parent then return end
        spin = spin + math.rad(SPIN_SPEED)
        block.CFrame = block.CFrame * CFrame.Angles(0, spin, 0)
        
        -- Fling nearby players
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and (tRoot.Position - block.Position).Magnitude < 10 then
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                    bv.Velocity = Vector3.new(math.random(-100, 100), 100, math.random(-100, 100)) * FLING_POWER
                    bv.Parent = tRoot
                    game:GetService("Debris"):AddItem(bv, 0.2)
                end
            end
        end
    end)
end

-- Press "E" to attach
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        if block and block.Parent then
            block:Destroy()
            block = nil
        else
            createBlock()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    block = nil
    task.wait(1)
    createBlock()
end)
