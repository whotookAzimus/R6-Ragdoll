local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicationConstants = require(ReplicatedStorage.Shared.Constants.ReplicationConstants)
local Types = require(ReplicatedStorage.Shared.Types)

type Snapshot = Types.Snapshot

local lastSnapshotReceived = 0

local clientLastSendTimes = {} :: { [Player]: number } -- the received snapshot timestamp
local clientTargetRenderTimes = {} :: { [Player]: number } -- the current target render time

local RenderCache = {}

function RenderCache.OnSnapshotUpdate(snapshot: Snapshot)
	for player, snapshotData in snapshot do
		local lastSendTime = clientLastSendTimes[player] or 0
		local currentSendTime = snapshotData.Timestamp

		if currentSendTime > lastSendTime then
			clientLastSendTimes[player] = currentSendTime
		end

		if not clientTargetRenderTimes[player] then
			clientTargetRenderTimes[player] = currentSendTime - ReplicationConstants.InterpolationDelay
		end
	end

	lastSnapshotReceived = os.clock()
end

function RenderCache.GetTargetRenderTime(player): number
	local targetRenderTime = clientTargetRenderTimes[player]

	if not targetRenderTime then
		warn("RenderCache: No target render time for player", player.Name)
	end

	return targetRenderTime or 0
end

function RenderCache.Update(deltaTime: number)
	for player, targetRenderTime in clientTargetRenderTimes do
		local lastSendTime = clientLastSendTimes[player]

		if not lastSendTime then
			warn("RenderCache: No last send time for player", player.Name)
			continue
		end

		local estimatedServerTime = lastSendTime + (os.clock() - lastSnapshotReceived)

		local clientRenderAt = targetRenderTime + deltaTime

		local renderTimeError = ReplicationConstants.InterpolationDelay - (estimatedServerTime - clientRenderAt)

		if math.abs(renderTimeError) > 0.1 then
			clientRenderAt = estimatedServerTime - ReplicationConstants.InterpolationDelay
		elseif renderTimeError > 0.01 then
			clientRenderAt =
				math.max(estimatedServerTime - ReplicationConstants.InterpolationDelay, clientRenderAt - 0.1 * deltaTime)
		elseif renderTimeError < -0.01 then
			clientRenderAt =
				math.min(estimatedServerTime - ReplicationConstants.InterpolationDelay, clientRenderAt + 0.1 * deltaTime)
		end

		clientTargetRenderTimes[player] = clientRenderAt
	end
end

function RenderCache.Add(player: Player)
	if not clientLastSendTimes[player] then
		clientLastSendTimes[player] = 0
	end
end

function RenderCache.Remove(player: Player)
	clientLastSendTimes[player] = nil
	clientTargetRenderTimes[player] = nil
end

return RenderCache
