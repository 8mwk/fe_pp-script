-- FE PP (Dih Model - Toggleable with E)
-- Builds the model, anchors the player, and spins. Press E to toggle on/off.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local FLING_POWER = 15
local SPIN_SPEED = 120
local DIH_LENGTH = 12
local DIH_THICKNESS = 1.5

local dihModel = nil
local spinConnection = nil
local rootAnchor = nil
local isToggled = false

local function destroyDih()
    if dihModel then dihModel:Destroy() dihModel = nil end
    if rootAnchor then rootAnchor:Destroy() rootAnchor = nil end
    if spinConnection then spinConnection:Disconnect() spinConnection = nil end
    isToggled = false
end

local function createDih()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local leg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Right Leg")
    if not root or not leg then return end

    destroyDih()
    isToggled = true

    -- Anchor the player
    rootAnchor = Instance.new("Part")
    rootAnchor.Name = "FEPP_Anchor"
    rootAnchor.Size = Vector3.new(1, 1, 1)
    rootAnchor.Transparency = 1
    rootAnchor.CanCollide = false
    rootAnchor.Anchored = true
    rootAnchor.Parent = char
    rootAnchor.CFrame = root.CFrame

    local anchorWeld = Instance.new("Weld")
    anchorWeld.Part0 = rootAnchor
    anchorWeld.Part1 = root
    anchorWeld.Parent = rootAnchor

    -- Create model
    dihModel = Instance.new("Model")
    dihModel.Name = "FEPP_Dih"
    dihModel.Parent = char

    -- Base
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Shape = Enum.PartType.Ball
    base.Size = Vector3.new(DIH_THICKNESS * 1.8, DIH_THICKNESS * 1.8, DIH_THICKNESS * 1.8)
    base.Color = Color3.fromRGB(220, 220, 220)
    base.Material = Enum.Material.SmoothPlastic
    base.CanCollide = false
    base.Massless = true
    base.Anchored = false
    base.Parent = dihModel
    base.CFrame = leg.CFrame * CFrame.new(0, -1, 0)

    -- Shaft
    local shaft = Instance.new("Part")
    shaft.Name = "Shaft"
    shaft.Size = Vector3.new(DIH_THICKNESS, DIH_THICKNESS, DIH_LENGTH)
    shaft.Color = Color3.fromRGB(220, 220, 220)
    shaft.Material = Enum.Material.SmoothPlastic
    shaft.CanCollide = false
    shaft.Massless = true
    shaft.Anchored = false
    shaft.Parent = dihModel
    shaft.CFrame = base.CFrame * CFrame.new(0, 0, -DIH_LENGTH / 2)

    -- Tip
    local tip = Instance.new("Part")
    tip.Name = "Tip"
    tip.Shape = Enum.PartType.Ball
    tip.Size = Vector3.new(DIH_THICKNESS * 1.2, DIH_THICKNESS * 1.2, DIH_THICKNESS * 1.2)
    tip.Color = Color3.fromRGB(220, 220, 220)
    tip.Material = Enum.Material.SmoothPlastic
    tip.CanCollide = false
    tip.Massless = true
    tip.Anchored = false
    tip.Parent = dihModel
    tip.CFrame = shaft.CFrame * CFrame.new(0, 0, -DIH_LENGTH / 2)

    -- Welds
    local weldBase = Instance.new("Weld")
    weldBase.Part0 = leg
    weldBase.Part1 = base
    weldBase.C0 = leg.CFrame:Inverse() * base.CFrame
    weldBase.Parent = base

    local weldShaft = Instance.new("Weld")
    weldShaft.Part0 = base
    weldShaft.Part1 = shaft
    weldShaft.C0 = base.CFrame:Inverse() * shaft.CFrame
    weldShaft.Parent = shaft

    local weldTip = Instance.new("Weld")
    weldTip.Part0 = shaft
    weldTip.Part1 = tip
    weldTip.C0 = shaft.CFrame:Inverse() * tip.CFrame
    weldTip.Parent = tip

    -- Spin
    local spin = 0
    spinConnection = RunService.Heartbeat:Connect(function()
        if not dihModel or not dihModel.Parent or not isToggled then return end
        
        spin = spin + math.rad(SPIN_SPEED)
        base.CFrame = base.CFrame * CFrame.Angles(0, spin, 0)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and (tRoot.Position - base.Position).Magnitude < (DIH_LENGTH + 5) then
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

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        if isToggled then
            destroyDih()
        else
            createDih()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    destroyDih()
end)
