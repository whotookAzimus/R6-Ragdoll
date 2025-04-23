--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blink = require(ReplicatedStorage.Network.Client)

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

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.R then
		Blink.Ragdoll.Fire()
	end
end)
