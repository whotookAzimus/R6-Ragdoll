local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blink = require(ReplicatedStorage.Network.Client)

local player = Players.LocalPlayer
local character
local humanoid
local rootPart
local head

local function characterAdded(char: Model)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	head = character:WaitForChild("Head")

	head.Size = Vector3.one

	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
end

if player.Character then
	characterAdded(player.Character)
end

player.CharacterAdded:Connect(characterAdded)

Blink.Ragdolled.On(function(isRagdolled: boolean)
	if not humanoid or not rootPart then
		return
	end

	if isRagdolled then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		rootPart:ApplyAngularImpulse(Vector3.new(-90, 0, 0))
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

return {}