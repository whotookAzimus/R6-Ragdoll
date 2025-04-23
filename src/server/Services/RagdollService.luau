--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)

local RagdollService = {}

RagdollService.Ragdoll = Ragdoll.Ragdoll
RagdollService.Unragdoll = Ragdoll.Unragdoll
RagdollService.IsRagdolled = Ragdoll.IsRagdolled

return RagdollService
