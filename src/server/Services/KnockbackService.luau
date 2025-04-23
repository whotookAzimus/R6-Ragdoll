--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blink = require(ReplicatedStorage.Network.Server)

local KnockbackService = {}

function KnockbackService.Knockback(data: {
	AttackerCharacter: Model,
	TargetCharacter: Model,
	Direction: Vector3,
	Rotation: Vector3?,
	KnockbackPower: number,
	RotationPower: number?,
	Duration: number,
})
	local attackerCharacter = data.AttackerCharacter
	local targetCharacter = data.TargetCharacter
	local direction = data.Direction
	local rotation = data.Rotation
	local knockbackPower = data.KnockbackPower
	local rotationPower = data.RotationPower
	local duration = data.Duration

	local attackerPlayer = Players:GetPlayerFromCharacter(attackerCharacter)
	local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)

	local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart

	if targetPlayer then
        Blink.Knockback.Fire(targetPlayer, {
			TargetCharacter = targetCharacter,
			Direction = direction,
			Rotation = rotation,
			KnockbackPower = knockbackPower,
			RotationPower = rotationPower,
			Duration = duration,
		})
	else
		targetRootPart:SetNetworkOwner(attackerPlayer)

		task.delay(duration + 0.1, function()
			targetRootPart:SetNetworkOwnershipAuto()
		end)

		Blink.Knockback.Fire(attackerPlayer, {
			TargetCharacter = targetCharacter,
			Direction = direction,
			Rotation = rotation,
			KnockbackPower = knockbackPower,
			RotationPower = rotationPower,
			Duration = duration,
		})
	end
end

Blink.AttemptKnockback.On(function(attackingPlayer: Player, targetCharacter: Model)
	local attackerCharacter = attackingPlayer.Character

	if not attackerCharacter or not targetCharacter then
		return
	end

	local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
	local attackerRootPart = attackerCharacter:FindFirstChild("HumanoidRootPart") :: BasePart

	local direction = (targetRootPart.Position - attackerRootPart.Position).Unit
	-- local rotation = Vector3.new(1, 1, 1)
	local knockbackPower = 25
	-- local rotationPower = 0
	local duration = 0.1

	KnockbackService.Knockback({
		AttackerCharacter = attackerCharacter,
		TargetCharacter = targetCharacter,
		Direction = direction,
		-- Rotation = rotation,
		KnockbackPower = knockbackPower,
		-- RotationPower = rotationPower,
		Duration = duration,
	})
end)

return KnockbackService
