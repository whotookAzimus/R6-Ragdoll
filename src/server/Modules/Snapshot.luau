local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
type Snapshot = Types.Snapshot

local Snapshot = {}

function Snapshot.new(): {
	Data: Snapshot,
	Add: (player: Player, cframe: CFrame, timestamp: number) -> (),
}
	local snapshot = {} :: Snapshot

	local function addToSnapshot(player: Player, cframe: CFrame, timestamp: number)
		snapshot[player] = {
			CFrame = cframe,
			Timestamp = timestamp,
		}
	end

	return {
		Data = snapshot,
		Add = addToSnapshot,
	}
end

return Snapshot
