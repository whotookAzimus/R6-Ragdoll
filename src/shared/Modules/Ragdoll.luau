--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local Blink = isServer and require(ReplicatedStorage.Network.Server)

local attachmentCFrames = {
	["Neck"] = { CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1) },
	["Left Shoulder"] = {
		CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
		CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
	},
	["Right Shoulder"] = {
		CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	["Left Hip"] = { CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1) },
	["Right Hip"] = { CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1) },
}

local ragdollInstanceNames = {
	["RagdollAttachment"] = true,
	["RagdollConstraint"] = true,
	["ColliderPart"] = true,
}

local ragdolled = {} :: { [Model]: boolean }

local function createColliderPart(part: BasePart)
	if not part then
		return
	end

	local ragdollPart = Instance.new("Part")
	ragdollPart.Name = "ColliderPart"
	ragdollPart.Size = part.Size / 1.7
	ragdollPart.Massless = true
	ragdollPart.CFrame = part.CFrame
	ragdollPart.Transparency = 1

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = ragdollPart
	weldConstraint.Part1 = part

	weldConstraint.Parent = ragdollPart
	ragdollPart.Parent = part
end

local function push(character: Model)
	local torso = character:FindFirstChild("Torso") :: BasePart
	torso:ApplyImpulse(torso.CFrame.LookVector * 100)
end

local Ragdoll = {}

function Ragdoll.Ragdoll(character: Model)
	if ragdolled[character] then
		warn("Character is already ragdolled")
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid

	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false

	for _, motor in character:GetDescendants() do
		if not motor:IsA("Motor6D") or not attachmentCFrames[motor.Name] then
			continue
		end

		motor.Enabled = false

		local attachment0, attachment1 = Instance.new("Attachment"), Instance.new("Attachment")
		attachment0.CFrame = attachmentCFrames[motor.Name][1]
		attachment1.CFrame = attachmentCFrames[motor.Name][2]

		attachment0.Name = "RagdollAttachment"
		attachment1.Name = "RagdollAttachment"

		createColliderPart(motor.Part1 :: BasePart)

		local ballSocketConstraint = Instance.new("BallSocketConstraint")
		ballSocketConstraint.Attachment0 = attachment0
		ballSocketConstraint.Attachment1 = attachment1
		ballSocketConstraint.Name = "RagdollConstraint"

		ballSocketConstraint.Radius = 0.15
		ballSocketConstraint.LimitsEnabled = true
		ballSocketConstraint.TwistLimitsEnabled = false
		ballSocketConstraint.MaxFrictionTorque = 0
		ballSocketConstraint.Restitution = 0
		ballSocketConstraint.UpperAngle = 90
		ballSocketConstraint.TwistLowerAngle = -45
		ballSocketConstraint.TwistUpperAngle = 45

		if motor.Name == "Neck" then
			ballSocketConstraint.TwistLimitsEnabled = true
			ballSocketConstraint.UpperAngle = 45
			ballSocketConstraint.TwistLowerAngle = -70
			ballSocketConstraint.TwistUpperAngle = 70
		end

		attachment0.Parent = motor.Part0
		attachment1.Parent = motor.Part1
		ballSocketConstraint.Parent = motor.Parent
	end

	if player and isServer then
		Blink.Ragdolled.Fire(player, true)
		Blink.PlayerWasRagdolled.FireExcept(player, {
			Player = player,
			Ragdolled = true,
		})
	end

	if not isServer then
		if humanoid.Health == 0 then -- Prevents OOF sound from playing twice thanks to @robloxdestroyer1035
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			push(character)
			return
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		push(character)
	end

	humanoid.AutoRotate = false --> Disabling AutoRotate prevents the Character rotating in first person or Shift-Lock
	ragdolled[character] = true
end

function Ragdoll.Unragdoll(character: Model)
	if not ragdolled[character] then
		warn("Character is not ragdolled")
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid

	if humanoid.Health <= 0 then
		return
	end

	for _, instance in character:GetDescendants() do
		if ragdollInstanceNames[instance.Name] then
			instance:Destroy()
		end

		if instance:IsA("Motor6D") then
			instance.Enabled = true
		end
	end

	if player and isServer then
		Blink.Ragdolled.Fire(player, false)
		Blink.PlayerWasRagdolled.FireExcept(player, {
			Player = player,
			Ragdolled = false,
		})
	end

    if not isServer then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
	humanoid.AutoRotate = true
	ragdolled[character] = false
end

function Ragdoll.IsRagdolled(character: Model): boolean
	return ragdolled[character] == true
end

if isServer then
	Blink.Ragdoll.On(function(player: Player)
		local character = player.Character

		if not character then
			return
		end

		local isRagdolled = ragdolled[character]

		if isRagdolled then
			Ragdoll.Unragdoll(character)
		else
			Ragdoll.Ragdoll(character)
		end
	end)
end

return Ragdoll
