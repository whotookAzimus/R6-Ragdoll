--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)
local Blink = require(ReplicatedStorage.Network.Server)

local RagdollService = {}

RagdollService.Ragdoll = Ragdoll.Ragdoll
RagdollService.Unragdoll = Ragdoll.Unragdoll
RagdollService.IsRagdolled = Ragdoll.IsRagdolled

Blink.Ragdoll.On(function(player)
	local character = player.Character

	if not character then
		return
	end

	local IsRagdolled = RagdollService.IsRagdolled(character)

	if IsRagdolled then
		RagdollService.Unragdoll(character)
	else
		RagdollService.Ragdoll(character)
	end
end)

return RagdollService
