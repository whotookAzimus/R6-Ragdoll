--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicationConstants = require(ReplicatedStorage.Shared.Constants.ReplicationConstants)
local Types = require(ReplicatedStorage.Shared.Types)

type CircularBuffer = Types.CircularBuffer
type Snapshot = Types.Snapshot

local CircularBuffer = {}

local function getBefore(self: CircularBuffer, player: Player, time: number): Snapshot?
	local closest: Snapshot?, distance: number = nil, math.huge

	for _, snapshot in self.Cache do
		local snapshotData = snapshot[player]

		if not snapshotData then
			continue
		end

		local timeDifference = math.abs(snapshotData.Timestamp - time)

		if snapshotData.Timestamp < time and timeDifference < distance then
			closest, distance = snapshot, timeDifference
		end
	end

	return closest
end

local function getAfter(self: CircularBuffer, player: Player, time: number): Snapshot?
	local closest: Snapshot?, distance: number = nil, math.huge

	for _, snapshot in self.Cache do
		local snapshotData = snapshot[player]

		if not snapshotData then
			continue
		end

		local timeDifference = math.abs(snapshotData.Timestamp - time)

		if snapshotData.Timestamp > time and timeDifference < distance then
			closest, distance = snapshot, timeDifference
		end
	end

	return closest
end

local function GetAt(self: CircularBuffer, player: Player, time: number, currentCFrame: CFrame): CFrame?
	local nextSnapshot = getAfter(self, player, time)
	local previousSnapshot = getBefore(self, player, time)

	if previousSnapshot and nextSnapshot then
		local timeDifference = nextSnapshot[player].Timestamp - previousSnapshot[player].Timestamp
		local alpha = (time - previousSnapshot[player].Timestamp) / timeDifference

		local previousCFrame = previousSnapshot[player].CFrame
		local nextCFrame = nextSnapshot[player].CFrame

		if not previousCFrame or not nextCFrame then
			warn("No CFrame found")
			return nil
		end

		local interpolatedCFrame = previousCFrame:Lerp(nextCFrame, alpha)
		return currentCFrame:Lerp(interpolatedCFrame, ReplicationConstants.SmoothingFactor)
	elseif previousSnapshot then
		return currentCFrame:Lerp(previousSnapshot[player].CFrame, ReplicationConstants.SmoothingFactor)
	elseif nextSnapshot then
		return currentCFrame:Lerp(nextSnapshot[player].CFrame, ReplicationConstants.SmoothingFactor)
	else
		warn("No snapshots found")
		return nil
	end
end

local function Add(self: CircularBuffer, snapshot: Snapshot)
	self.PivotIndex = (self.PivotIndex % ReplicationConstants.CircularBufferLength) + 1
	self.Cache[self.PivotIndex] = snapshot
end

function CircularBuffer.new(): CircularBuffer
	return {
		Cache = {},
		PivotIndex = 1, -- 1-based indexing

		Add = Add,
		GetAt = GetAt,
	}
end

return CircularBuffer
