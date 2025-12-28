--!strict
-- Game constants for Downline Redux

local Constants = {
	-- Playing board bounds (500x500 studs, 250 stud vertical drop)
	BOARD = {
		MIN = Vector3.new(0, 0, 0),
		MAX = Vector3.new(500, 250, 500),
	},

	-- Physics parameters
	PHYSICS = {
		GRAVITY_MULTIPLIER = 1.0,
		SLOPE_FRICTION = 0.02,
		MAX_SLIDE_SPEED = 100,
		MIN_SLIDE_SPEED = 5,
	},

	-- Spawn point (high elevation corner)
	SPAWN_POSITION = Vector3.new(480, 245, 480),

	-- Respawn delay after death (seconds)
	RESPAWN_DELAY = 2,

	-- Lift endpoints (all start at lowest corner)
	LIFTS = {
		X_WALL = {
			start = Vector3.new(10, 5, 10),
			finish = Vector3.new(490, 240, 10),
			speed = 30,
		},
		Z_WALL = {
			start = Vector3.new(10, 5, 10),
			finish = Vector3.new(10, 240, 490),
			speed = 30,
		},
		DIAGONAL = {
			start = Vector3.new(10, 5, 10),
			finish = Vector3.new(490, 245, 490),
			speed = 40,
		},
	},

	-- Tags used by CollectionService
	TAGS = {
		KILL_TREE = "KillTree",
		LIFT = "Lift",
		PLAYING_BOARD = "PlayingBoard",
	},
}

return Constants
