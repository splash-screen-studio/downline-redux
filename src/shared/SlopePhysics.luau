--!strict
-- Pure math functions for slope physics calculations

local Constants = require(script.Parent.Constants)

local SlopePhysics = {}

-- Get the downhill direction from a terrain normal
-- Returns a unit vector pointing downhill (toward lower elevation)
function SlopePhysics.getDownhillDirection(terrainNormal: Vector3): Vector3
	-- If surface is nearly flat, no slide direction
	if terrainNormal.Y > 0.99 then
		return Vector3.zero
	end

	-- The downhill direction is the projection of gravity onto the slope plane
	local gravity = Vector3.new(0, -1, 0)

	-- Project gravity onto the plane defined by the normal
	-- projection = gravity - (gravity · normal) * normal
	local dot = gravity:Dot(terrainNormal)
	local projection = gravity - (terrainNormal * dot)

	if projection.Magnitude < 0.001 then
		return Vector3.zero
	end

	return projection.Unit
end

-- Calculate acceleration based on slope steepness
-- Steeper slopes = faster acceleration
function SlopePhysics.calculateAcceleration(terrainNormal: Vector3, gravity: number): number
	-- Slope angle from vertical (0 = flat, pi/2 = vertical wall)
	local slopeAngle = math.acos(math.clamp(terrainNormal.Y, -1, 1))

	-- Acceleration = g * sin(angle)
	-- On flat ground (angle=0), acceleration = 0
	-- On 45 degree slope, acceleration = g * 0.707
	return gravity * math.sin(slopeAngle) * Constants.PHYSICS.GRAVITY_MULTIPLIER
end

-- Calculate new velocity given current speed and terrain
function SlopePhysics.calculateSlideVelocity(
	terrainNormal: Vector3,
	currentSpeed: number,
	deltaTime: number,
	gravity: number
): (Vector3, number)
	local downhill = SlopePhysics.getDownhillDirection(terrainNormal)

	if downhill.Magnitude < 0.001 then
		-- Flat surface, apply friction to slow down
		local newSpeed = math.max(0, currentSpeed - Constants.PHYSICS.SLOPE_FRICTION * gravity * deltaTime)
		return Vector3.zero, newSpeed
	end

	-- Calculate acceleration
	local acceleration = SlopePhysics.calculateAcceleration(terrainNormal, gravity)

	-- Apply friction (reduces acceleration slightly)
	acceleration = acceleration - (Constants.PHYSICS.SLOPE_FRICTION * gravity)
	acceleration = math.max(0, acceleration)

	-- Update speed
	local newSpeed = currentSpeed + acceleration * deltaTime

	-- Clamp speed
	newSpeed = math.clamp(newSpeed, 0, Constants.PHYSICS.MAX_SLIDE_SPEED)

	-- Return velocity vector and new speed
	return downhill * newSpeed, newSpeed
end

-- Check if speed is below minimum (player has stopped)
function SlopePhysics.isStopped(speed: number): boolean
	return speed < Constants.PHYSICS.MIN_SLIDE_SPEED
end

return SlopePhysics
