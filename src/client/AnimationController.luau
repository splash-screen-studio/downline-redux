--!strict
-- Controls player animations and sounds when on the playing board
-- Disables walking animations and footstep sounds

local Players = game:GetService("Players")

local AnimationController = {}

local player = Players.LocalPlayer

-- Disable walking animations when on the slope
function AnimationController.disableWalkingAnimations()
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
	if not humanoid then
		return
	end

	-- Find animator and stop walk/run tracks
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in animator:GetPlayingAnimationTracks() do
			local name = track.Name:lower()
			if name:find("walk") or name:find("run") then
				track:Stop(0.1)
			end
		end
	end
end

-- Re-enable walking animations when leaving the slope
function AnimationController.enableWalkingAnimations()
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
	if humanoid then
		-- Animations will resume naturally when WalkSpeed is restored
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end

-- Mute footstep sounds
function AnimationController.muteFootsteps()
	local character = player.Character
	if not character then
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local running = hrp:FindFirstChild("Running") :: Sound?
		if running then
			running.Volume = 0
		end
	end
end

-- Restore footstep sounds
function AnimationController.unmuteFootsteps()
	local character = player.Character
	if not character then
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local running = hrp:FindFirstChild("Running") :: Sound?
		if running then
			running.Volume = 0.65
		end
	end
end

-- Called when entering the playing board
function AnimationController.onEnterBoard()
	AnimationController.disableWalkingAnimations()
	AnimationController.muteFootsteps()
end

-- Called when exiting the playing board
function AnimationController.onExitBoard()
	AnimationController.enableWalkingAnimations()
	AnimationController.unmuteFootsteps()
end

return AnimationController
