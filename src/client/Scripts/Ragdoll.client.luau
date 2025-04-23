--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Blink = require(ReplicatedStorage.Network.Client)
local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)

local player = Players.LocalPlayer
local character
local humanoid
local torso: BasePart

local function push()
	torso:ApplyImpulse(torso.CFrame.LookVector * 100)
end

local function characterAdded(char: Model)
	character = char
	humanoid = character:WaitForChild("Humanoid") :: Humanoid
	torso = character:WaitForChild("Torso") :: BasePart

	humanoid.Died:Connect(push)
end

if player.Character then
	characterAdded(player.Character)
end

player.CharacterAdded:Connect(characterAdded)

Blink.Ragdolled.On(function(isRagdolled: boolean)
	if not humanoid then
		return
	end

	if humanoid.Health == 0 then -- Prevents OOF sound from playing twice thanks to @robloxdestroyer1035
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		push()
		return
	end

	if isRagdolled then
		humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		push()
	else
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

local cloneCharacters = {} :: { [Player]: Model }

Blink.PlayerWasRagdolled.On(function(data: {
	Player: Player,
	Ragdolled: boolean,
})
	local targetPlayer = data.Player
	local isRagdolled = data.Ragdolled

	local targetCharacter = targetPlayer.Character

	if not targetCharacter then
		warn("Character not found for player: " .. targetPlayer.Name)
		return
	end

	if isRagdolled then
		targetCharacter.Archivable = true
		local cloneCharacter = targetCharacter:Clone()
		targetCharacter.Archivable = false

		-- local weld = Instance.new("WeldConstraint")
		-- weld.Part0 = targetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
		-- weld.Part1 = cloneCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
		-- weld.Parent = cloneCharacter:FindFirstChild("HumanoidRootPart") :: BasePart

		local connection
		connection = RunService.PostSimulation:Connect(function()
			if targetCharacter and targetCharacter.Parent and cloneCharacter and cloneCharacter.Parent then
				cloneCharacter.HumanoidRootPart.CFrame = targetCharacter.HumanoidRootPart.CFrame
			else
				connection:Disconnect()
			end
		end)

		for _, descendant in cloneCharacter:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.CollisionGroup = "Ragdoll"
			end
		end

		-- cloneCharacter.Humanoid.PlatformStand = true

		cloneCharacter.Parent = workspace
		cloneCharacters[targetPlayer] = cloneCharacter

		for _, descendant in targetCharacter:GetDescendants() do
			if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
				descendant.Transparency = 1
			end
		end

		-- Ragdoll.Ragdoll(cloneCharacter)
	else
		local cloneCharacter = cloneCharacters[targetPlayer]

		if not cloneCharacter then
			warn("Clone character not found for player: " .. targetPlayer.Name)
			return
		end

		cloneCharacter:Destroy()
		cloneCharacters[targetPlayer] = nil

		for _, descendant in targetCharacter:GetDescendants() do
			if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
				descendant.Transparency = 0
			end
		end
	end
end)

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.R then
		Blink.Ragdoll.Fire()
		-- Ragdoll.Ragdoll(character)
	end
end)
