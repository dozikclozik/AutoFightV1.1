local lplayer = game.Players.LocalPlayer
local character = lplayer.Character or lplayer.CharacterAdded:Wait()
local Hrp = character:WaitForChild("HumanoidRootPart")
local pathFinding = game:GetService("PathfindingService")

local firstPlayerLocation = nil
local isTarget = false
local isFight = false

local TargetDistance = 60
local FightDistance = 19
local ExtraDistance = 12

local PlayersOnServer = #game:GetService("Players"):GetPlayers()

local path = pathFinding:CreatePath({
	AgentRadius = 2,
	AgentHeight = 5,
	AgentCanJump = true,
	AgentJumpHeight = 10,
	AgentMaxSlope = 45,
	AgentCanClimb = true,
	AgentMaxClimb = 2,
	Costs = {
		Neon = 100;
	}
})

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExampleGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local textBox = Instance.new("TextBox")
textBox.Name = "TopTextBox"
textBox.Size = UDim2.new(0.125, 0,0.062, 0)
textBox.Position = UDim2.new(0.437, 0,0.016, 0)
textBox.Text = ""
textBox.PlaceholderText = "Attack Distance (write only number)"
textBox.Parent = screenGui
textBox.TextScaled = true
textBox.PlaceholderColor3 = Color3.new(0, 0, 0)

local textButton = Instance.new("TextButton")
textButton.Name = "BelowTextBoxButton"
textButton.Size = UDim2.new(0.125, 0,0.062, 0)
textButton.Position = UDim2.new(0.437, 0,0.1, 0)
textButton.Text = "Confirm"
textButton.Parent = screenGui
textButton.TextScaled = true

textButton.MouseButton1Click:Connect(function()
	if textBox.Text ~= "" then
	FightDistance = tonumber(textBox.Text)
	print("Attack distance: " .. FightDistance)
	end
end)

local humanoid = character:FindFirstChildOfClass("Humanoid")

local function Move(object)
	path:ComputeAsync(Hrp.Position, object.Position)
	local waypoints = path:GetWaypoints()
	for _, waypoint in pairs(waypoints) do
		humanoid:MoveTo(waypoint.Position)
		if waypoint.Action == Enum.PathWaypointAction.Jump and humanoid:GetState() ~= Enum.HumanoidStateType.FallingDown and
			humanoid:GetState() ~= Enum.HumanoidStateType.GettingUp and
			humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		if waypoint.Action == Enum.PathWaypointAction.Custom then
			humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
		end
		humanoid.MoveToFinished:Wait()
	end
end

local function jumpingSystem()
	if humanoid:GetState() ~= Enum.HumanoidStateType.FallingDown and
		humanoid:GetState() ~= Enum.HumanoidStateType.GettingUp and
		humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and
	    isFight then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
end

game:GetService("RunService").Stepped:Connect(function()
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player ~= lplayer and player.Character then
			local PlayerCharacter = player.Character
			local HrpPlayer = PlayerCharacter:FindFirstChild("HumanoidRootPart")
			local tool = PlayerCharacter:FindFirstChildOfClass("Tool")
			if tool then
				local EquippedTool = lplayer.Character:FindFirstChildOfClass("Tool")
				local magnitude = (Hrp.Position - HrpPlayer.Position).Magnitude
				local unit = (Hrp.Position - HrpPlayer.Position).unit
				
				if magnitude <= ExtraDistance and isTarget and EquippedTool then
					spawn(function()
						EquippedTool:Activate()
						Hrp:PivotTo(PlayerCharacter.PrimaryPart.CFrame * CFrame.new(nil, nil, -6))
						print("EXTRA ACTIVATED!!!")
					end)
				end
				
				if magnitude <= TargetDistance and not isTarget and isFight ~= true then
					isTarget = true
					Move(HrpPlayer)
				elseif magnitude > TargetDistance then
					isTarget = false
				end

				if magnitude <= FightDistance and isTarget and EquippedTool then
					firstPlayerLocation = player
					isFight = true
					spawn(jumpingSystem)
					EquippedTool:Activate()
					local newPos = Hrp.Position + unit * 4
					Hrp.CFrame = CFrame.lookAt(Hrp.Position, HrpPlayer.Position)
					humanoid:MoveTo(newPos)
				elseif magnitude > FightDistance then
					isFight = false
				end
			end
		end
	end
end)
