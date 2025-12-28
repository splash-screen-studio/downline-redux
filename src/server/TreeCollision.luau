--!strict
-- Server-side tree collision detection
-- Kills players instantly when they touch a tree tagged with "KillTree"

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared.Constants)

local TreeCollision = {}

local connections: { [BasePart]: RBXScriptConnection } = {}

function TreeCollision.init()
	-- Set up existing trees
	for _, tree in CollectionService:GetTagged(Constants.TAGS.KILL_TREE) do
		if tree:IsA("BasePart") then
			TreeCollision.setupTree(tree)
		end
	end

	-- Handle dynamically added trees
	CollectionService:GetInstanceAddedSignal(Constants.TAGS.KILL_TREE):Connect(function(tree)
		if tree:IsA("BasePart") then
			TreeCollision.setupTree(tree)
		end
	end)

	-- Handle removed trees
	CollectionService:GetInstanceRemovedSignal(Constants.TAGS.KILL_TREE):Connect(function(tree)
		if tree:IsA("BasePart") then
			TreeCollision.cleanupTree(tree)
		end
	end)
end

function TreeCollision.setupTree(tree: BasePart)
	-- Skip if already set up
	if connections[tree] then
		return
	end

	connections[tree] = tree.Touched:Connect(function(hit)
		TreeCollision.onTreeTouched(tree, hit)
	end)
end

function TreeCollision.cleanupTree(tree: BasePart)
	local conn = connections[tree]
	if conn then
		conn:Disconnect()
		connections[tree] = nil
	end
end

function TreeCollision.onTreeTouched(_tree: BasePart, hit: BasePart)
	-- Find the character
	local character = hit.Parent
	if not character then
		return
	end

	-- Check if it's a player character
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
	local player = Players:GetPlayerFromCharacter(character)

	if humanoid and player and humanoid.Health > 0 then
		TreeCollision.killPlayer(player, humanoid)
	end
end

function TreeCollision.killPlayer(player: Player, humanoid: Humanoid)
	-- Instant death
	humanoid.Health = 0

	-- Respawn is handled by PlayerManager.onCharacterAdded -> humanoid.Died
	print("[TreeCollision]", player.Name, "hit a tree!")
end

return TreeCollision
