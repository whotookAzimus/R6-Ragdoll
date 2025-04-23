--!strict
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RigTypes = require(script.RigTypes)

local SKELETON_FOLDER_NAME = "RAGDOLL_SKELETON"
local SHOULD_RAGDOLL_TAG = "Should_Ragdoll"
local BODY_PARTS = { "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg" }

local isClient = RunService:IsClient()

local camera = workspace.CurrentCamera

local function CloneBodyPart(part: BasePart): BasePart
	local newPart = (Instance :: any).fromExisting(part)
	newPart.Transparency = 1
	newPart.CollisionGroup = "Ragdoll"
	newPart.CanCollide = true
	newPart.CanTouch = false
	newPart.CanQuery = false

	-- some ragdoll constraints use the default attachments
	for _, child in part:GetChildren() do
		if child:IsA("Attachment") then
			child:Clone().Parent = newPart
		end
	end
	return newPart
end

local function ragdoll(character: Model)
	if not character:IsA("Model") then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local realTorso = character:FindFirstChild("Torso")
	local isLocalCharacter = isClient and character == Players.LocalPlayer.Character

	if not humanoid or not realTorso or not rootPart or not rootPart:IsA("BasePart") then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	local rootAttachment = rootPart:FindFirstChild("RootAttachment") :: Attachment
	local rootJoint = rootPart:FindFirstChild("RootJoint")

	if not rootAttachment or not animator or not rootJoint or not rootJoint:IsA("Motor6D") then
		return
	end

	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false

	rootJoint.Enabled = false
	rootPart.CanCollide = true
	rootPart.CollisionGroup = "RagdollRootPart"

	local savedTracks = {}

	for _, track in animator:GetPlayingAnimationTracks() do
		if not track.Looped then
			table.insert(savedTracks, {
				track = track,
				savedTime = os.clock(),
			})
			track:Stop()
		end
	end

	local animatorConnection = animator.AnimationPlayed:Connect(function(track)
		table.insert(savedTracks, {
			track = track,
			savedTime = os.clock() - track.TimePosition,
		})
		track:Stop()
	end)

	for _, motor in realTorso:GetChildren() do
		if motor:IsA("Motor6D") then
			motor.Enabled = false
		end
	end

	local skeletonFolder = Instance.new("Folder")
	skeletonFolder.Name = SKELETON_FOLDER_NAME

	if isLocalCharacter then
		local head = character:FindFirstChild("Head")

		if head and head:IsA("BasePart") then
			camera.CameraSubject = head
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end

	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Enabled = true
	alignPosition.Attachment1 = rootAttachment
	alignPosition.MaxForce = 10000
	alignPosition.Responsiveness = 100
	alignPosition.ApplyAtCenterOfMass = true
	alignPosition.Parent = skeletonFolder

	local partMap = {}

	for _, partName in BODY_PARTS do
		local realPart = character:FindFirstChild(partName)
		if not realPart or not realPart:IsA("BasePart") then
			continue
		end

		local skeletonPart = CloneBodyPart(realPart)
		partMap[skeletonPart] = realPart

		if partName == "Torso" then
			local attachment = Instance.new("Attachment")
			attachment.Parent = skeletonPart
			alignPosition.Attachment0 = attachment
		end

		skeletonPart.Parent = skeletonFolder
	end

	-- Instantiate BallSocketConstraints:
	local attachments = RigTypes.GetAttachments(skeletonFolder, character:GetScale())
	for skeletonPart, realPart in partMap do
		local data = attachments[realPart.Name]
		if not data then
			continue
		end

		local constraint = Instance.new("BallSocketConstraint")
		constraint.Name = "RagdollBallSocketConstraint"
		constraint.LimitsEnabled = true
		constraint.TwistLimitsEnabled = true
		constraint.UpperAngle = data.limits.UpperAngle
		constraint.TwistLowerAngle = data.limits.TwistLowerAngle
		constraint.TwistUpperAngle = data.limits.TwistUpperAngle
		constraint.Attachment0 = data.a0
		constraint.Attachment1 = data.a1
		constraint.Parent = skeletonPart
	end

	local moveConnection = RunService.Heartbeat:Connect(function()
		for skeletonPart, realPart in partMap do
			if not skeletonPart or not realPart or not skeletonPart.Parent or not realPart.Parent then
				continue
			end

			realPart.CFrame = skeletonPart.CFrame
		end
	end)

	skeletonFolder.Destroying:Once(function()
		moveConnection:Disconnect()

		for _, track in savedTracks do
			local currentTrackTime = os.clock() - track.savedTime
			if currentTrackTime < track.track.Length then
				track.track:Play()
				track.track.TimePosition = currentTrackTime
			end
		end
		animatorConnection:Disconnect()
	end)

	skeletonFolder.Parent = character
end

local function unragdoll(character: Model)
	if not character:IsA("Model") then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local torso = character:FindFirstChild("Torso")
	local skeletonFolder = character:FindFirstChild(SKELETON_FOLDER_NAME)
	local isLocalCharacter = isClient and character == Players.LocalPlayer.Character

	if not humanoid or not torso or not skeletonFolder or not rootPart or not rootPart:IsA("BasePart") then
		return
	end

	skeletonFolder:Destroy()

	local rootJoint = rootPart:FindFirstChild("RootJoint")
	if rootJoint and rootJoint:IsA("Motor6D") then
		rootJoint.Enabled = true
	end
	rootPart.CanCollide = false

	if isLocalCharacter then
		camera.CameraSubject = humanoid
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	for _, motor in torso:GetChildren() do
		if motor:IsA("Motor6D") then
			motor.Enabled = true
		end
	end
end

if isClient then
	CollectionService:GetInstanceAddedSignal(SHOULD_RAGDOLL_TAG):Connect(ragdoll)
	CollectionService:GetInstanceRemovedSignal(SHOULD_RAGDOLL_TAG):Connect(unragdoll)
end

local Ragdoll = {}

function Ragdoll.Ragdoll(character: Model)
	character:AddTag(SHOULD_RAGDOLL_TAG)

	-- will primarily be for NPCs. clients will control their own humanoid state
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end
end

function Ragdoll.Unragdoll(character: Model)
	character:RemoveTag(SHOULD_RAGDOLL_TAG)

	-- will primarily be for NPCs. clients will control their own humanoid state
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

function Ragdoll.IsRagdolled(character: Model)
	return character:HasTag(SHOULD_RAGDOLL_TAG)
end

return Ragdoll
