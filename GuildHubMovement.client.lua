-- Drop this script into StarterPlayer > StarterPlayerScripts.
-- LeftShift = sprint
-- LeftAlt = toggle shift lock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local DEFAULT_WALK_SPEED = 16
local SPRINT_WALK_SPEED = 24
local DEFAULT_FOV = 70
local SPRINT_FOV = 78
local SHIFT_LOCK_OFFSET = Vector3.new(1.8, 0.35, 0)
local SHIFT_LOCK_KEY = Enum.KeyCode.LeftAlt
local SPRINT_KEY = Enum.KeyCode.LeftShift

local character
local humanoid
local rootPart
local wantsSprint = false
local shiftLockEnabled = false

local function applyMouseLockState()
	UserInputService.MouseBehavior = shiftLockEnabled and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = not shiftLockEnabled

	if humanoid then
		humanoid.CameraOffset = shiftLockEnabled and SHIFT_LOCK_OFFSET or Vector3.zero
		humanoid.AutoRotate = not shiftLockEnabled
	end
end

local function cacheCharacter(nextCharacter)
	character = nextCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")

	humanoid.WalkSpeed = DEFAULT_WALK_SPEED
	local camera = Workspace.CurrentCamera
	if camera then
		camera.FieldOfView = DEFAULT_FOV
	end
	applyMouseLockState()
end

local function resetMovementState()
	wantsSprint = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true

	local camera = Workspace.CurrentCamera
	if camera then
		camera.FieldOfView = DEFAULT_FOV
	end

	if humanoid then
		humanoid.WalkSpeed = DEFAULT_WALK_SPEED
		humanoid.CameraOffset = Vector3.zero
		humanoid.AutoRotate = true
	end
end

player.CharacterAdded:Connect(cacheCharacter)
player.CharacterRemoving:Connect(resetMovementState)

if player.Character then
	cacheCharacter(player.Character)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == SPRINT_KEY then
		wantsSprint = true
	elseif input.KeyCode == SHIFT_LOCK_KEY then
		shiftLockEnabled = not shiftLockEnabled
		applyMouseLockState()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == SPRINT_KEY then
		wantsSprint = false
	end
end)

RunService.RenderStepped:Connect(function(deltaTime)
	local camera = Workspace.CurrentCamera
	if not humanoid or not rootPart or not camera then
		return
	end

	local isMoving = humanoid.MoveDirection.Magnitude > 0.05
	local targetSpeed = wantsSprint and isMoving and SPRINT_WALK_SPEED or DEFAULT_WALK_SPEED
	if humanoid.WalkSpeed ~= targetSpeed then
		humanoid.WalkSpeed = targetSpeed
	end

	local targetFov = wantsSprint and isMoving and SPRINT_FOV or DEFAULT_FOV
	camera.FieldOfView += (targetFov - camera.FieldOfView) * math.min(1, deltaTime * 10)

	if shiftLockEnabled then
		local lookVector = camera.CFrame.LookVector
		local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)
		if flatLook.Magnitude > 0.001 then
			rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + flatLook.Unit)
		end
	end
end)
