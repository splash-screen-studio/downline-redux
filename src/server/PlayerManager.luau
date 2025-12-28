--!strict
-- Server-side player management
-- Handles spawning and respawning players at high elevation

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared.Constants)

local PlayerManager = {}

function PlayerManager.init()
	Players.PlayerAdded:Connect(PlayerManager.onPlayerAdded)

	-- Handle players already in game
	for _, player in Players:GetPlayers() do
		PlayerManager.onPlayerAdded(player)
	end
end

function PlayerManager.onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character)
		PlayerManager.onCharacterAdded(player, character)
	end)

	-- If character already exists
	if player.Character then
		PlayerManager.onCharacterAdded(player, player.Character)
	end
end

function PlayerManager.onCharacterAdded(player: Player, character: Model)
	-- Wait for character to load
	local hrp = character:WaitForChild("HumanoidRootPart", 10) :: BasePart?
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?

	if not hrp or not humanoid then
		warn("[PlayerManager] Failed to find HumanoidRootPart or Humanoid for", player.Name)
		return
	end

	-- Spawn at high point
	task.defer(function()
		hrp.CFrame = CFrame.new(Constants.SPAWN_POSITION)
	end)

	-- Handle death/respawn
	humanoid.Died:Once(function()
		task.wait(Constants.RESPAWN_DELAY)
		player:LoadCharacter()
	end)
end

-- Force respawn a player at the spawn point
function PlayerManager.respawnPlayer(player: Player)
	local character = player.Character
	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then
			hrp.CFrame = CFrame.new(Constants.SPAWN_POSITION)
		end
	end
end

return PlayerManager
