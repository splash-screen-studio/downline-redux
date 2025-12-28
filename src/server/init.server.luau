local Version = require(game.ReplicatedStorage.Shared.Version)
Version.logAll()

-- Initialize server systems
local PlayerManager = require(script.PlayerManager)
local TreeCollision = require(script.TreeCollision)
local LiftSystem = require(script.LiftSystem)

PlayerManager.init()
TreeCollision.init()
LiftSystem.init()

print("[server] All systems initialized")
