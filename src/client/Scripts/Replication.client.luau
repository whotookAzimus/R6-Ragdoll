local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Blink = require(ReplicatedStorage.Network.Client)
local ReplicationConstants = require(ReplicatedStorage.Shared.Constants.ReplicationConstants)
local CircularBuffer = require(ReplicatedStorage.Client.Modules.CircularBuffer)
local RenderCache = require(ReplicatedStorage.Client.Modules.RenderCache)
local Types = require(ReplicatedStorage.Shared.Types)

type Snapshot = Types.Snapshot

local circularBuffer = CircularBuffer.new()

local localPlayer = Players.LocalPlayer
local characters: { [Player]: Model } = {}
local lastCFrames = {} :: { [Player]: CFrame }

local lastSentCFrameTime = 0

local function lerpCFrame(a: CFrame, b: CFrame, decay: number, dt: number)
	return a:Lerp(b, 1 - math.exp(-decay * dt))
end

local function characterAdded(character)
	if not character:IsA("Model") then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)

	if not player then
		return
	end

	characters[player] = character

	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()
		if characters[player] then
			characters[player]:Destroy()
			characters[player] = nil
		end
	end)
end

for _, character in CollectionService:GetTagged("Player") do
	if character:IsA("Model") then
		characterAdded(character)
	end
end

CollectionService:GetInstanceAddedSignal("Player"):Connect(characterAdded)

-- Lerp all remote clients from current cframe to the target snapshot cframe
RunService.PreSimulation:Connect(function(deltaTime: number)
	if #circularBuffer.Cache < 2 then
		warn("Not enough snapshots to lerp")
		return
	end

	RenderCache.Update(deltaTime)

	local stagedCharacters, stagedCFrames = {}, {}

	for _, player in Players:GetPlayers() do
		if player == localPlayer then
			continue
		end

		local character = characters[player]

		if not character then
			continue
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local renderTime = RenderCache.GetTargetRenderTime(player)

		local targetCFrame = circularBuffer:GetAt(player, renderTime, rootPart.CFrame)

		if not targetCFrame then
			continue
		end

		if not lastCFrames[player] then
			lastCFrames[player] = targetCFrame
		else
			lastCFrames[player] =
				lerpCFrame(lastCFrames[player], targetCFrame, ReplicationConstants.InterpolationSmoothingConstant, deltaTime)
		end

		table.insert(stagedCharacters, character.HumanoidRootPart)
		table.insert(stagedCFrames, lastCFrames[player])
	end

	workspace:BulkMoveTo(stagedCharacters, stagedCFrames, Enum.BulkMoveMode.FireAllEvents)
end)

-- Client send cframe every ReplicationConstants.SendRate
RunService.PostSimulation:Connect(function()
	if time() - lastSentCFrameTime < (1 / ReplicationConstants.SendRate) then
		return
	end

	lastSentCFrameTime = time()

	local character = localPlayer.Character or characters[localPlayer]

	if not character then
		return
	end

	local clientCFrame = character.HumanoidRootPart.CFrame

	Blink.ClientSendSnapshotData.Fire({
		CFrame = clientCFrame,
		Timestamp = os.clock(),
	})
end)

Blink.ServerSendSnapshot.On(function(snapshot: Snapshot)
	RenderCache.OnSnapshotUpdate(snapshot)
	circularBuffer:Add(snapshot)
end)

-- Request replication data now that we are ready
Blink.RequestInitialReplicationData.Fire()

Blink.ReceiveInitialReplicationData.On(function(snapshot: Snapshot)
	for player in snapshot do
		if player == localPlayer or characters[player] or not player.Character then
			continue
		end

		local character = player.Character
		characters[player] = character
		character.HumanoidRootPart.CFrame = snapshot[player].CFrame
	end
end)

Players.PlayerAdded:Connect(function(player: Player)
	RenderCache.Add(player)
end)

for _, player in Players:GetPlayers() do
	RenderCache.Add(player)
end

Players.PlayerRemoving:Connect(function(player: Player)
	RenderCache.Remove(player)
end)
