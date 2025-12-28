--!strict
-- Zone detection utilities for playing board

local Constants = require(script.Parent.Constants)

local ZoneUtils = {}

-- Check if a position is within the playing board bounds
function ZoneUtils.isOnBoard(position: Vector3): boolean
	local min = Constants.BOARD.MIN
	local max = Constants.BOARD.MAX

	return position.X >= min.X
		and position.X <= max.X
		and position.Z >= min.Z
		and position.Z <= max.Z
		and position.Y >= min.Y
		and position.Y <= max.Y
end

-- Get terrain normal at a position by raycasting down
function ZoneUtils.getTerrainNormalAt(position: Vector3): Vector3?
	local rayOrigin = position + Vector3.new(0, 5, 0)
	local rayDirection = Vector3.new(0, -20, 0)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {}

	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if result then
		return result.Normal
	end

	return nil
end

-- Get the slope angle in radians from a terrain normal
function ZoneUtils.getSlopeAngle(normal: Vector3): number
	-- Angle between normal and up vector
	return math.acos(math.clamp(normal.Y, -1, 1))
end

-- Check if player is grounded (close to terrain)
function ZoneUtils.isGrounded(position: Vector3): boolean
	local rayOrigin = position
	local rayDirection = Vector3.new(0, -4, 0)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {}

	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	return result ~= nil
end

return ZoneUtils
