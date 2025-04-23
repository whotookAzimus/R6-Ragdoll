--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Blink = require(ReplicatedStorage.Network.Client)
require(ReplicatedStorage.Shared.Modules.Ragdoll)

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.R then
		Blink.Ragdoll.Fire()
		-- Ragdoll.Ragdoll(character)
	end
end)
