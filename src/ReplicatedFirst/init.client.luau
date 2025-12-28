--!strict
-- ReplicatedFirst runs before anything else on the client
-- Use for loading screens, critical early initialization

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Force landscape mode (mobile first)
PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

-- Remove default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- TODO: Add custom loading screen here

print("[ReplicatedFirst] Landscape mode forced, client bootstrapped")
