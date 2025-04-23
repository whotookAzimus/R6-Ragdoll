-- Ripped from Roblox Battle Royale experience game, and adapted
-- Then my goat @Taz gave it to me ❤️‍🔥
local RigTypes = {}

type Limits = {
	UpperAngle: number,
	TwistLowerAngle: number,
	TwistUpperAngle: number,
}

local HEAD_LIMITS: Limits = {
	UpperAngle = 30,
	TwistLowerAngle = -60,
	TwistUpperAngle = 60,
}

local SHOULDER_LIMITS: Limits = {
	UpperAngle = 90,
	TwistLowerAngle = -30,
	TwistUpperAngle = 175,
}

local HIP_LIMITS: Limits = {
	UpperAngle = 60,
	TwistLowerAngle = -5,
	TwistUpperAngle = 120,
}

local function attachment(name: string, parent: string, position: Vector3?)
	return function(model: Instance, scale: number): Attachment?
		local part = model:FindFirstChild(parent)
		if not part then
			return
		end

		local existing = part:FindFirstChild(name)
		if existing then
			assert(existing:IsA("Attachment"))
			if position then
				existing.Position = position * scale -- for smaller/bigger races
			end
			return existing
		end

		local new = Instance.new("Attachment")
		if position then
			new.Position = position * scale -- for smaller/bigger races
		end
		new.Name = name
		new.Parent = part

		return new
	end
end

local ATTACHMENTS = {
	rightLeg = attachment("RagdollRightLegAttachment", "Right Leg", Vector3.new(0, 1, 0)),
	leftLeg = attachment("RagdollLeftLegAttachment", "Left Leg", Vector3.new(0, 1, 0)),
	torsoLeft = attachment("RagdollTorsoLeftAttachment", "Torso", Vector3.new(-0.5, -1, 0)),
	torsoRight = attachment("RagdollTorsoRightAttachment", "Torso", Vector3.new(0.5, -1, 0)),
	head = attachment("RagdollHeadAttachment", "Head", Vector3.new(0, -0.5, 0)),
	leftArm = attachment("RagdollLeftArmAttachment", "Left Arm", Vector3.new(0.5, 1, 0)),
	rightArm = attachment("RagdollRightArmAttachment", "Right Arm", Vector3.new(-0.5, 1, 0)),
	neck = attachment("NeckAttachment", "Torso"),
	leftCollar = attachment("LeftCollarAttachment", "Torso"),
	rightCollar = attachment("RightCollarAttachment", "Torso"),
}

function RigTypes.GetAttachments(skeletonParent: Instance, scale: number)
	local function ballSocket(a0: Attachment?, a1: Attachment?, limits: Limits)
		if a0 and a1 then
			return {
				a0 = a0,
				a1 = a1,
				limits = limits,
			} or nil -- infer optional return
		end

		return nil
	end

	return {
		Head = ballSocket(
			ATTACHMENTS.neck(skeletonParent, scale),
			ATTACHMENTS.head(skeletonParent, scale),
			HEAD_LIMITS
		),
		["Left Arm"] = ballSocket(
			ATTACHMENTS.leftCollar(skeletonParent, scale),
			ATTACHMENTS.leftArm(skeletonParent, scale),
			SHOULDER_LIMITS
		),
		["Right Arm"] = ballSocket(
			ATTACHMENTS.rightCollar(skeletonParent, scale),
			ATTACHMENTS.rightArm(skeletonParent, scale),
			SHOULDER_LIMITS
		),
		["Left Leg"] = ballSocket(
			ATTACHMENTS.torsoLeft(skeletonParent, scale),
			ATTACHMENTS.leftLeg(skeletonParent, scale),
			HIP_LIMITS
		),
		["Right Leg"] = ballSocket(
			ATTACHMENTS.torsoRight(skeletonParent, scale),
			ATTACHMENTS.rightLeg(skeletonParent, scale),
			HIP_LIMITS
		),
	}
end

function RigTypes.GetNoCollisions(skeletonFolder: Instance)
	local list = {}

	local function addPair(name1: string, name2: string)
		local part1 = skeletonFolder:FindFirstChild(name1)
		local part2 = skeletonFolder:FindFirstChild(name2)

		if part1 and part2 and part1:IsA("BasePart") and part2:IsA("BasePart") then
			table.insert(list, { part1 = part1, part2 = part2 })
		end
	end

	addPair("Head", "Torso")
	addPair("Left Arm", "Torso")
	addPair("Right Arm", "Torso")
	addPair("Left Leg", "Torso")
	addPair("Right Leg", "Torso")
	addPair("Left Leg", "Right Leg")

	return list
end

return RigTypes