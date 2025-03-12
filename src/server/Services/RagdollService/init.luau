local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blink = require(ReplicatedStorage.Network.Server)

local ragdollParts = require(script.GetRagdollParts)():GetChildren()

local ragdolled = {}

local RagdollService = {}

function RagdollService.Setup(character: Model)
	if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then
		warn("Invalid character provided")
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	for _, v: BasePart in character:GetDescendants() do
		if v:IsA("BasePart") then
			v:SetNetworkOwner(nil)
		end
	end

	character.Head.Size = Vector3.one
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false

	local clones = {}

	for _, v in ragdollParts do
		clones[v.Name] = v:Clone()
	end

	local folder1 = Instance.new("Folder")
	folder1.Name = "RagdollConstraints"

	for _, v in clones do
		if v:IsA("Attachment") then
			v.Parent = character[v:GetAttribute("Parent")]
		elseif v:IsA("BallSocketConstraint") then
			v.Attachment0 = clones[v:GetAttribute("0")]
			v.Attachment1 = clones[v:GetAttribute("1")]
			v.Parent = folder1
		end
	end

	folder1.Parent = character

	local folder2 = Instance.new("Folder")
	folder2.Name = "Motors"

	local value

	for _, v in character.Torso:GetChildren() do
		if v:IsA("Motor6D") then
			value = Instance.new("ObjectValue")
			value.Value = v
			value.Parent = folder2
		end
	end

	folder2.Parent = folder1
end

function RagdollService.Ragdoll(character: Model)
    if not character:FindFirstChild("RagdollConstraints") then
        RagdollService.Setup(character)
    end

	character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	character.Humanoid.AutoRotate = false

	for _, v in character.RagdollConstraints.Motors:GetChildren() do
		v.Value.Enabled = false
	end

	for _, v in character:GetChildren() do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Ragdoll"
		end
	end

	character.HumanoidRootPart:ApplyAngularImpulse(Vector3.new(-90, 0, 0))

	local player = Players:GetPlayerFromCharacter(character)

	if player then
		Blink.Ragdolled.Fire(player, true)
	end

	ragdolled[character] = true
end

function RagdollService.Unragdoll(character: Model)
	character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	for _, v in character.RagdollConstraints.Motors:GetChildren() do
		v.Value.Enabled = true
	end

	for _, v in character:GetChildren() do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Default"
		end
	end

	character.Humanoid.AutoRotate = true

	local player = Players:GetPlayerFromCharacter(character)

	if player then
		Blink.Ragdolled.Fire(player, false)
	end

	ragdolled[character] = false
end

Blink.Ragdoll.On(function(player: Player)
	local character = player.Character

	if not character then
		return
	end

	local isRagdolled = ragdolled[character]

	if isRagdolled then
		RagdollService.Unragdoll(character)
	else
		RagdollService.Ragdoll(character)
	end
end)

PhysicsService:RegisterCollisionGroup("Ragdoll")

return RagdollService