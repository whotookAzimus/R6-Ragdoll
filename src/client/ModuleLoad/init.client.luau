local controllers = script.Parent.Controllers:GetDescendants()

local requiredControllers = {}
local requireTimes = {}
local hasStartFunction = {}

local totalTime = 0

local function requireSingleton(singleton: ModuleScript)
	if not singleton:IsA("ModuleScript") or requiredControllers[singleton.Name] then
		return
	end

	local startTime = time()

	local success, err = pcall(function()
		requiredControllers[singleton.Name] = require(singleton)
	end)

	if not success then
		warn("Failed to require " .. singleton.Name .. " because " .. string.lower(err))
	else
		if requiredControllers[singleton.Name] and requiredControllers[singleton.Name].Start then
			hasStartFunction[singleton.Name] = requiredControllers[singleton.Name].Start
		end
	end

	local ms = math.floor((time() - startTime) * 1000)
	table.insert(requireTimes, singleton.Name .. " loaded in " .. ms .. "ms. (" .. ms / 1000 .. "s)")
	totalTime += ms
end

for _, controller in controllers do
	requireSingleton(controller)
end

for controllerName, startFunction in hasStartFunction do
	local success, err = pcall(startFunction, requiredControllers[controllerName])

	if not success then
		warn("Failed to start " .. controllerName .. " because " .. string.lower(err))
	end
end

print(
	"Client require times in order:",
	requireTimes,
	"Total time: " .. totalTime .. "ms. (" .. totalTime / 1000 .. "s)"
)
