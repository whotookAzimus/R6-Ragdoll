--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blink = require(ReplicatedStorage.Network.Client)
local BodyMoverUtils = require(ReplicatedStorage.Shared.Modules.BodyMoverUtils)

local function onKnockback(data: {
	TargetCharacter: Model,
	Direction: Vector3,
	Rotation: Vector3?,
	KnockbackPower: number,
	RotationPower: number?,
	Duration: number,
})
	local targetCharacter = data.TargetCharacter
	local direction = data.Direction
	local rotation = data.Rotation
	local knockbackPower = data.KnockbackPower
	local rotationPower = data.RotationPower
	local duration = data.Duration

	local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart

	local originalCustomPhysicalProperties = targetRootPart.CurrentPhysicalProperties
	targetRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.1, 2, 0.5, 100, 0)

	local linearVelocity = BodyMoverUtils.CreateLinearVelocity({
		Lifetime = duration,
		MaxForce = 1e6,
		Attachment = targetRootPart:FindFirstChild("RootAttachment") :: Attachment,
	})

	linearVelocity.VectorVelocity = direction * knockbackPower

	task.delay(duration, function()
		targetRootPart.CustomPhysicalProperties = originalCustomPhysicalProperties
	end)

	if rotation and rotationPower then
		local angularVelocity = BodyMoverUtils.CreateAngularVelocity({
			Lifetime = duration,
			MaxTorque = 1e6,
			Attachment = targetRootPart:FindFirstChild("RootAttachment") :: Attachment,
		})

		angularVelocity.AngularVelocity = rotation * rotationPower
	end
end

Blink.Knockback.On(onKnockback)

local UserInputService = game:GetService("UserInputService")

local camera = workspace.CurrentCamera

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    local mouseLocation = UserInputService:GetMouseLocation()
    local unitRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

    local rayLength = 100
    local rayDirection = unitRay.Direction * rayLength
    local rayOrigin = unitRay.Origin

    local raycastResult = workspace:Raycast(rayOrigin, rayDirection)

    if not raycastResult then
        return
    end

    local hitPart = raycastResult.Instance
    local hitCharacter = hitPart.Parent :: Model

    local hitHumanoid = hitCharacter:FindFirstChildOfClass("Humanoid") :: Humanoid

    if not hitHumanoid then
        return
    end

    Blink.AttemptKnockback.Fire(hitCharacter)
end)