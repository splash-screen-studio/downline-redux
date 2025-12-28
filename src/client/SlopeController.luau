--!strict
-- Client-side slope physics controller
-- Handles player movement when on the playing board

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ZoneUtils = require(Shared.ZoneUtils)
local SlopePhysics = require(Shared.SlopePhysics)
local Constants = require(Shared.Constants)

local SlopeController = {}

local player = Players.LocalPlayer
local currentSpeed = 0
local isOnBoard = false
local connection: RBXScriptConnection? = nil

-- Callbacks for zone transitions (set by init)
local onEnterBoard: (() -> ())? = nil
local onExitBoard: (() -> ())? = nil

function SlopeController.init(enterCallback: () -> (), exitCallback: () -> ())
	onEnterBoard = enterCallback
	onExitBoard = exitCallback

	connection = RunService.Heartbeat:Connect(function(dt)
		SlopeController.update(dt)
	end)
end

function SlopeController.update(dt: number)
	local character = player.Character
	if not character then
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
	if not hrp or not humanoid then
		return
	end

	-- Check zone
	local wasOnBoard = isOnBoard
	isOnBoard = ZoneUtils.isOnBoard(hrp.Position)

	-- Handle zone transitions
	if isOnBoard and not wasOnBoard then
		SlopeController.enterBoard(humanoid)
	elseif not isOnBoard and wasOnBoard then
		SlopeController.exitBoard(humanoid)
	end

	-- Apply slope physics if on board and grounded
	if isOnBoard and ZoneUtils.isGrounded(hrp.Position) then
		SlopeController.updateSlide(hrp, dt)
	end
	-- When in air on board, horizontal velocity is preserved automatically
end

function SlopeController.enterBoard(humanoid: Humanoid)
	-- Disable walking
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	-- Reset speed
	currentSpeed = Constants.PHYSICS.MIN_SLIDE_SPEED

	-- Call external callback (for animation controller)
	if onEnterBoard then
		onEnterBoard()
	end
end

function SlopeController.exitBoard(humanoid: Humanoid)
	-- Restore normal movement
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50

	-- Reset speed
	currentSpeed = 0

	-- Call external callback
	if onExitBoard then
		onExitBoard()
	end
end

function SlopeController.updateSlide(hrp: BasePart, dt: number)
	-- Get terrain normal
	local normal = ZoneUtils.getTerrainNormalAt(hrp.Position)
	if not normal then
		return
	end

	-- Calculate slide velocity
	local velocity, newSpeed = SlopePhysics.calculateSlideVelocity(normal, currentSpeed, dt, workspace.Gravity)

	currentSpeed = newSpeed

	-- Apply velocity (preserve vertical component for gravity)
	hrp.AssemblyLinearVelocity = Vector3.new(velocity.X, hrp.AssemblyLinearVelocity.Y, velocity.Z)
end

function SlopeController.isOnBoard(): boolean
	return isOnBoard
end

function SlopeController.getCurrentSpeed(): number
	return currentSpeed
end

function SlopeController.destroy()
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

return SlopeController
