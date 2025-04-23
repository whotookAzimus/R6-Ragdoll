-- do
-- 	return
-- end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Blink = require(ReplicatedStorage.Network.Server)
local ReplicationConstants = require(ReplicatedStorage.Shared.Constants.ReplicationConstants)
local Snapshot = require(ServerScriptService.Server.Modules.Snapshot)
local Types = require(ReplicatedStorage.Shared.Types)

type Snapshot = Types.Snapshot
type SnapshotData = Types.SnapshotData

local characters = {} :: { [Player]: SnapshotData }
local snapshotReceivers = {} :: { [Player]: boolean }

local lastCframeReplication = 0

local function createSnapshot(): Snapshot
	local snapshot = Snapshot.new()

	local snapshotData = snapshot.Data
	local addToSnapshot = snapshot.Add

	for player, characterInfo in characters do
		addToSnapshot(player, characterInfo.CFrame, characterInfo.Timestamp or os.clock())
	end

	return snapshotData
end

-- Sending snapshots of game state to clients
RunService.PostSimulation:Connect(function()
	if time() - lastCframeReplication < (1 / ReplicationConstants.SendRate) then
		return
	end

	lastCframeReplication = time()

	for _, player in Players:GetPlayers() do
		if not snapshotReceivers[player] then
			continue
		end

		-- Build snapshot, remove them from their own snapshot
		-- ! TODO: Remove any faraway players from the snapshot
		local snapshot = createSnapshot()
		snapshot[player] = nil
		Blink.ServerSendSnapshot.Fire(player, snapshot)
	end
end)

-- Receiving client cframe
Blink.ClientSendSnapshotData.On(function(player: Player, data: SnapshotData)
	if not characters[player] then
		return
	end

	characters[player].CFrame = data.CFrame
	characters[player].Timestamp = data.Timestamp
end)

-- Replicating existing game state to new clients
Blink.RequestInitialReplicationData.On(function(player: Player)
	snapshotReceivers[player] = true

	local snapshot = createSnapshot()
	Blink.ReceiveInitialReplicationData.Fire(player, snapshot)
end)

-- Character added event
Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(character: Model)
		task.delay(1, function()
			local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
			characters[player] = {
				CFrame = rootPart.CFrame,
				Timestamp = os.clock(),
			}

			character:AddTag("Player")

			local humanoid = character:WaitForChild("Humanoid")

			humanoid.Died:Connect(function()
				characters[player] = nil
			end)
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	snapshotReceivers[player] = nil
	characters[player] = nil
end)

return {}
