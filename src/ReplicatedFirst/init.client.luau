--!strict
-- ReplicatedFirst runs before anything else on the client
-- Use for loading screens, critical early initialization

local ReplicatedFirst = game:GetService("ReplicatedFirst")

-- Remove default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- TODO: Add custom loading screen here

print("[ReplicatedFirst] Client bootstrapped")
