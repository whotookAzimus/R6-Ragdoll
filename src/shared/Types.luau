-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type SnapshotData = {
	CFrame: CFrame,
	Timestamp: number,
}

export type Snapshot = {
	[Player]: SnapshotData,
}

export type CircularBuffer = {
	Cache: { Snapshot },
	PivotIndex: number, -- Index of the latest snapshot ( think about keys rotating around a key chain )

	Add: (self: CircularBuffer, snapshot: Snapshot) -> (),
	GetAt: (self: CircularBuffer, player: Player, time: number, currentCFrame: CFrame) -> CFrame?,
}

export type Buffer = {
	Cache: { Snapshot },
	Add: (self: CircularBuffer, snapshot: Snapshot) -> (),
	GetAt: (self: CircularBuffer, player: Player, time: number) -> CFrame?,
}

export type Quaternion = {
	X: number,
	Y: number,
	Z: number,
	W: number,

	ToCFrame: () -> CFrame,
	SLerp: (quaternion2: Quaternion, t: number) -> Quaternion,
}

return {}
