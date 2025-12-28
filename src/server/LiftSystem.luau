--!strict
-- Server-side T-bar/conveyor lift system
-- Players are pulled uphill while touching the lift zone

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared.Constants)

local LiftSystem = {}

local activeLifts: { [BasePart]: { direction: Vector3, speed: number } } = {}
local connections: { [BasePart]: { touched: RBXScriptConnection, ended: RBXScriptConnection } } = {}
local playersOnLift: { [Player]: BasePart } = {}

function LiftSystem.init()
	-- Set up existing lifts
	for _, lift in CollectionService:GetTagged(Constants.TAGS.LIFT) do
		if lift:IsA("BasePart") then
			LiftSystem.setupLift(lift)
		end
	end

	-- Handle dynamically added lifts
	CollectionService:GetInstanceAddedSignal(Constants.TAGS.LIFT):Connect(function(lift)
		if lift:IsA("BasePart") then
			LiftSystem.setupLift(lift)
		end
	end)

	-- Handle removed lifts
	CollectionService:GetInstanceRemovedSignal(Constants.TAGS.LIFT):Connect(function(lift)
		if lift:IsA("BasePart") then
			LiftSystem.cleanupLift(lift)
		end
	end)
end

function LiftSystem.setupLift(lift: BasePart)
	-- Skip if already set up
	if connections[lift] then
		return
	end

	-- Determine lift direction from attributes or name
	local liftData = LiftSystem.getLiftData(lift)
	activeLifts[lift] = liftData

	-- Make lift non-collidable but touchable
	lift.CanCollide = false
	lift.Transparency = 0.8

	local touchedConn = lift.Touched:Connect(function(hit)
		LiftSystem.onLiftTouched(lift, hit)
	end)

	local endedConn = lift.TouchEnded:Connect(function(hit)
		LiftSystem.onLiftEnded(lift, hit)
	end)

	connections[lift] = { touched = touchedConn, ended = endedConn }
end

function LiftSystem.getLiftData(lift: BasePart): { direction: Vector3, speed: number }
	-- Check for custom attributes first
	local dirX = lift:GetAttribute("DirectionX") or 0
	local dirY = lift:GetAttribute("DirectionY") or 0
	local dirZ = lift:GetAttribute("DirectionZ") or 0
	local speed = lift:GetAttribute("Speed") or 30

	if dirX ~= 0 or dirY ~= 0 or dirZ ~= 0 then
		return {
			direction = Vector3.new(dirX, dirY, dirZ).Unit,
			speed = speed,
		}
	end

	-- Fallback: determine from lift name or position
	local name = lift.Name:lower()
	if name:find("xwall") or name:find("x_wall") then
		local data = Constants.LIFTS.X_WALL
		return {
			direction = (data.finish - data.start).Unit,
			speed = data.speed,
		}
	elseif name:find("zwall") or name:find("z_wall") then
		local data = Constants.LIFTS.Z_WALL
		return {
			direction = (data.finish - data.start).Unit,
			speed = data.speed,
		}
	elseif name:find("diagonal") then
		local data = Constants.LIFTS.DIAGONAL
		return {
			direction = (data.finish - data.start).Unit,
			speed = data.speed,
		}
	end

	-- Default: push toward high corner
	return {
		direction = Vector3.new(1, 0.5, 1).Unit,
		speed = 30,
	}
end

function LiftSystem.cleanupLift(lift: BasePart)
	local conns = connections[lift]
	if conns then
		conns.touched:Disconnect()
		conns.ended:Disconnect()
		connections[lift] = nil
	end
	activeLifts[lift] = nil
end

function LiftSystem.onLiftTouched(lift: BasePart, hit: BasePart)
	local character = hit.Parent
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
	local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local player = game:GetService("Players"):GetPlayerFromCharacter(character)

	if not humanoid or not hrp or not player then
		return
	end

	-- Already on a lift
	if playersOnLift[player] then
		return
	end

	playersOnLift[player] = lift

	-- Start pulling the player
	LiftSystem.startPulling(player, lift, hrp)
end

function LiftSystem.onLiftEnded(lift: BasePart, hit: BasePart)
	local character = hit.Parent
	if not character then
		return
	end

	local player = game:GetService("Players"):GetPlayerFromCharacter(character)
	if not player then
		return
	end

	-- Only stop if leaving this specific lift
	if playersOnLift[player] == lift then
		playersOnLift[player] = nil
		LiftSystem.stopPulling(player, character)
	end
end

function LiftSystem.startPulling(_player: Player, lift: BasePart, hrp: BasePart)
	local liftData = activeLifts[lift]
	if not liftData then
		return
	end

	-- Create or update BodyVelocity
	local bv = hrp:FindFirstChild("LiftVelocity") :: BodyVelocity?
	if not bv then
		bv = Instance.new("BodyVelocity")
		bv.Name = "LiftVelocity"
		bv.MaxForce = Vector3.new(50000, 50000, 50000)
		bv.Parent = hrp
	end

	bv.Velocity = liftData.direction * liftData.speed
end

function LiftSystem.stopPulling(_player: Player, character: Model)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local bv = hrp:FindFirstChild("LiftVelocity")
		if bv then
			bv:Destroy()
		end
	end
end

return LiftSystem
