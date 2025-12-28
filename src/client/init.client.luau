local Version = require(game.ReplicatedStorage.Shared.Version)
Version.log("client")

-- Initialize client controllers
local SlopeController = require(script.SlopeController)
local AnimationController = require(script.AnimationController)

-- Connect animation controller to slope controller zone events
SlopeController.init(AnimationController.onEnterBoard, AnimationController.onExitBoard)

print("[client] Slope and animation controllers initialized")
