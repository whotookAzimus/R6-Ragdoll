local services = script.Parent.Services:GetDescendants()

local requiredServices = {}
local requireTimes = {}

local requireFirst = require(script.RequireFirst)

local totalTime = 0

local function requireSingleton(singleton: ModuleScript)
	if not singleton:IsA("ModuleScript") or requiredServices[singleton.Name] then
		return
	end

	local startTime = time()

	local success, err = pcall(function()
		requiredServices[singleton.Name] = require(singleton)
	end)

	if not success then
		warn("Failed to require " .. singleton.Name .. " because " .. string.lower(err))
	end

	local ms = math.floor((time() - startTime) * 1000)
	table.insert(requireTimes, singleton.Name .. " loaded in " .. ms .. "ms. (" .. ms / 1000 .. "s)")
	totalTime += ms
end

for _, service in requireFirst do
	requireSingleton(service)
end

for _, service in services do
	requireSingleton(service)
end

print(
	"Server require times in order:",
	requireTimes,
	"Total time: " .. totalTime .. "ms. (" .. totalTime / 1000 .. "s)"
)
