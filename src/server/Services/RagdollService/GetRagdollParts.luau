return function()
	local RagdollParts = Instance.new("Part")
	RagdollParts.Name = "RagdollParts"
	RagdollParts.Anchored = true
	RagdollParts.BottomSurface = Enum.SurfaceType.Smooth
	RagdollParts.CanCollide = false
	RagdollParts.CanTouch = false
	RagdollParts.CastShadow = false
	RagdollParts.Locked = true
	RagdollParts.Size = Vector3.new(4, 1, 2)
	RagdollParts.TopSurface = Enum.SurfaceType.Smooth

	local LA0 = Instance.new("Attachment")
	LA0.Name = "LA0"
	LA0.Axis = Vector3.new(-1, 0, 0)
	LA0.CFrame = CFrame.new(-1, 1, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
	LA0.WorldAxis = Vector3.new(-1, 0, 0)
	LA0.WorldCFrame = CFrame.new(-1, 1, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
	LA0:SetAttribute("Parent", "Torso")
	LA0.Parent = RagdollParts

	local LAS = Instance.new("BallSocketConstraint")
	LAS.Name = "LAS"
	LAS.LimitsEnabled = true
	LAS.MaxFrictionTorque = 50
	LAS.TwistLimitsEnabled = true
	LAS.TwistLowerAngle = -90
	LAS.TwistUpperAngle = 90
	LAS.UpperAngle = 90
	LAS:SetAttribute(0, "LA0")
	LAS:SetAttribute(1, "LA1")
	LAS.Parent = RagdollParts

	local LL0 = Instance.new("Attachment")
	LL0.Name = "LL0"
	LL0.Axis = Vector3.new(0, -1, 0)
	LL0.CFrame = CFrame.new(-0.5, -1, 0, 0, 0, 1, -1, 0, 0, 0, -1, 0)
	LL0.SecondaryAxis = Vector3.new(0, 0, -1)
	LL0.WorldAxis = Vector3.new(0, -1, 0)
	LL0.WorldCFrame = CFrame.new(-0.5, -1, 0, 0, 0, 1, -1, 0, 0, 0, -1, 0)
	LL0.WorldSecondaryAxis = Vector3.new(0, 0, -1)
	LL0:SetAttribute("Parent", "Torso")
	LL0.Parent = RagdollParts

	local LLS = Instance.new("BallSocketConstraint")
	LLS.Name = "LLS"
	LLS.LimitsEnabled = true
	LLS.MaxFrictionTorque = 50
	LLS.TwistLimitsEnabled = true
	LLS.UpperAngle = 90
	LLS:SetAttribute(0, "LL0")
	LLS:SetAttribute(1, "LL1")
	LLS.Parent = RagdollParts

	local N0 = Instance.new("Attachment")
	N0.Name = "N0"
	N0.Axis = Vector3.new(0, 1, 0)
	N0.CFrame = CFrame.new(0, 1, 0, 0, 0, -1, 1, 0, 0, 0, -1, 0)
	N0.SecondaryAxis = Vector3.new(0, 0, -1)
	N0.WorldAxis = Vector3.new(0, 1, 0)
	N0.WorldCFrame = CFrame.new(0, 1, 0, 0, 0, -1, 1, 0, 0, 0, -1, 0)
	N0.WorldSecondaryAxis = Vector3.new(0, 0, -1)
	N0:SetAttribute("Parent", "Torso")
	N0.Parent = RagdollParts

	local NS = Instance.new("BallSocketConstraint")
	NS.Name = "NS"
	NS.LimitsEnabled = true
	NS.MaxFrictionTorque = 50
	NS.TwistLimitsEnabled = true
	NS.UpperAngle = 60
	NS:SetAttribute(0, "N0")
	NS:SetAttribute(1, "N1")
	NS.Parent = RagdollParts

	local RA0 = Instance.new("Attachment")
	RA0.Name = "RA0"
	RA0.CFrame = CFrame.new(1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	RA0.WorldCFrame = CFrame.new(1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	RA0:SetAttribute("Parent", "Torso")
	RA0.Parent = RagdollParts

	local RAS = Instance.new("BallSocketConstraint")
	RAS.Name = "RAS"
	RAS.LimitsEnabled = true
	RAS.MaxFrictionTorque = 50
	RAS.TwistLimitsEnabled = true
	RAS.TwistLowerAngle = -90
	RAS.TwistUpperAngle = 90
	RAS.UpperAngle = 90
	RAS:SetAttribute(0, "RA0")
	RAS:SetAttribute(1, "RA1")
	RAS.Parent = RagdollParts

	local RL0 = Instance.new("Attachment")
	RL0.Name = "RL0"
	RL0.Axis = Vector3.new(0, -1, 0)
	RL0.CFrame = CFrame.new(0.5, -1, 0, 0, 0, 1, -1, 0, 0, 0, -1, 0)
	RL0.SecondaryAxis = Vector3.new(0, 0, -1)
	RL0.WorldAxis = Vector3.new(0, -1, 0)
	RL0.WorldCFrame = CFrame.new(0.5, -1, 0, 0, 0, 1, -1, 0, 0, 0, -1, 0)
	RL0.WorldSecondaryAxis = Vector3.new(0, 0, -1)
	RL0:SetAttribute("Parent", "Torso")
	RL0.Parent = RagdollParts

	local RLS = Instance.new("BallSocketConstraint")
	RLS.Name = "RLS"
	RLS.LimitsEnabled = true
	RLS.MaxFrictionTorque = 50
	RLS.TwistLimitsEnabled = true
	RLS.UpperAngle = 90
	RLS:SetAttribute(0, "RL0")
	RLS:SetAttribute(1, "RL1")
	RLS.Parent = RagdollParts

	local RL1 = Instance.new("Attachment")
	RL1.Name = "RL1"
	RL1.Axis = Vector3.new(1.91e-15, -1, 4.37e-08)
	RL1.CFrame =
		CFrame.new(0, 1, 0, 1.91068547e-15, -4.37113883e-08, 1, -1, -4.37113883e-08, 0, 4.37113883e-08, -1, -4.37113883e-08)
	RL1.SecondaryAxis = Vector3.new(-4.37e-08, -4.37e-08, -1)
	RL1.WorldAxis = Vector3.new(1.91e-15, -1, 4.37e-08)
	RL1.WorldCFrame =
		CFrame.new(0, 1, 0, 1.91068547e-15, -4.37113883e-08, 1, -1, -4.37113883e-08, 0, 4.37113883e-08, -1, -4.37113883e-08)
	RL1.WorldSecondaryAxis = Vector3.new(-4.37e-08, -4.37e-08, -1)
	RL1:SetAttribute("Parent", "Right Leg")
	RL1.Parent = RagdollParts

	local RA1 = Instance.new("Attachment")
	RA1.Name = "RA1"
	RA1.Axis = Vector3.new(0, -1, 0)
	RA1.CFrame = CFrame.new(-0.5, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)
	RA1.SecondaryAxis = Vector3.new(1, 0, 0)
	RA1.WorldAxis = Vector3.new(0, -1, 0)
	RA1.WorldCFrame = CFrame.new(-0.5, 1, 0, 0, 1, 0, -1, 0, 0, 0, 0, 1)
	RA1.WorldSecondaryAxis = Vector3.new(1, 0, 0)
	RA1:SetAttribute("Parent", "Right Arm")
	RA1.Parent = RagdollParts

	local LL1 = Instance.new("Attachment")
	LL1.Name = "LL1"
	LL1.Axis = Vector3.new(1.91e-15, -1, 4.37e-08)
	LL1.CFrame =
		CFrame.new(0, 1, 0, 1.91068547e-15, -4.37113883e-08, 1, -1, -4.37113883e-08, 0, 4.37113883e-08, -1, -4.37113883e-08)
	LL1.SecondaryAxis = Vector3.new(-4.37e-08, -4.37e-08, -1)
	LL1.WorldAxis = Vector3.new(1.91e-15, -1, 4.37e-08)
	LL1.WorldCFrame =
		CFrame.new(0, 1, 0, 1.91068547e-15, -4.37113883e-08, 1, -1, -4.37113883e-08, 0, 4.37113883e-08, -1, -4.37113883e-08)
	LL1.WorldSecondaryAxis = Vector3.new(-4.37e-08, -4.37e-08, -1)
	LL1:SetAttribute("Parent", "Left Leg")
	LL1.Parent = RagdollParts

	local LA1 = Instance.new("Attachment")
	LA1.Name = "LA1"
	LA1.Axis = Vector3.new(0, -1, 0)
	LA1.CFrame = CFrame.new(0.5, 1, 0, 0, -1, -0, -1, 0, -0, 0, 0, -1)
	LA1.SecondaryAxis = Vector3.new(-1, 0, 0)
	LA1.WorldAxis = Vector3.new(0, -1, 0)
	LA1.WorldCFrame = CFrame.new(0.5, 1, 0, 0, -1, -0, -1, 0, -0, 0, 0, -1)
	LA1.WorldSecondaryAxis = Vector3.new(-1, 0, 0)
	LA1:SetAttribute("Parent", "Left Arm")
	LA1.Parent = RagdollParts

	local N1 = Instance.new("Attachment")
	N1.Name = "N1"
	N1.Axis = Vector3.new(0, 1, 0)
	N1.CFrame = CFrame.new(0, -0.5, 0, 0, 0, -1, 1, 0, 0, 0, -1, 0)
	N1.SecondaryAxis = Vector3.new(0, 0, -1)
	N1.WorldAxis = Vector3.new(0, 1, 0)
	N1.WorldCFrame = CFrame.new(0, -0.5, 0, 0, 0, -1, 1, 0, 0, 0, -1, 0)
	N1.WorldSecondaryAxis = Vector3.new(0, 0, -1)
	N1:SetAttribute("Parent", "Head")
	N1.Parent = RagdollParts

	return RagdollParts
end
