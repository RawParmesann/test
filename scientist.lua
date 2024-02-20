local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

input = {
	hold = function(key, time)
		VirtualInputManager:SendKeyEvent(true, key, false, nil)
		task.wait(time)
		VirtualInputManager:SendKeyEvent(false, key, false, nil)
	end,
	press = function(key)
		VirtualInputManager:SendKeyEvent(true, key, false, nil)
		task.wait(0.005)
		VirtualInputManager:SendKeyEvent(false, key, false, nil)
	end
}

local TweenService = game:GetService("TweenService")

local function tweenPlayer(Destination)
	local HumanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
	local timeForWay = (HumanoidRootPart.Position - Destination).Magnitude / 150
	local Info = TweenInfo.new(timeForWay, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	local TweenGoals = {CFrame = CFrame.new(Destination)}
	local Tween = TweenService:Create(HumanoidRootPart, Info, TweenGoals)
	Tween:Play()
	Tween.Completed:Wait()
end

local function GetPlayer()	
	local localPlayer = game.Players.LocalPlayer
	local foundPlayer = false
	for _, v in pairs(workspace.Level.Players:GetChildren()) do
		if v:WaitForChild("Interact"):WaitForChild("ObjectTip").Value == localPlayer.Name then
			_G.Player = v
			foundPlayer = true
		end
	end
	local waitFunc
	if not foundPlayer then
		waitFunc = game.Workspace.Level.Players.ChildAdded:Connect(function(child)
			if child:WaitForChild("Interact"):WaitForChild("ObjectTip").Value == localPlayer.Name then
				child:WaitForChild("Humanoid")
				child:WaitForChild("HumanoidRootPart")
				child:WaitForChild("Head")
				_G.Player = child
				foundPlayer = true
				waitFunc:Disconnect()
			end
		end)
	end
	while not foundPlayer do task.wait() end
end

local function NpcNoclip(Npc)
	if Npc.Character:FindFirstChild("Spot") then
		Npc.Character.Spot:Destroy()
	end
	for _, part in pairs(Npc:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

local function moveObject(obj, objPos)
	local movePart = obj:FindFirstChildOfClass("Part")
	if not movePart:FindFirstChild("MyForceInstance") then
		local ForceInstance = Instance.new("BodyPosition", movePart)
		ForceInstance.Name = "MyForceInstance"
		ForceInstance.P = 1000000
		ForceInstance.MaxForce = Vector3.new(2500000, 2500000, 2500000)
	end
	movePart.MyForceInstance.Position = objPos
end

local BodyForces = {"Hold", "Turn", "BodyPosition"}

local function tpNpc(Npc, NpcPos)
	if Npc:FindFirstChild("Character") and Npc.Character:FindFirstChild("HumanoidRootPart") then
		NpcNoclip(Npc)
		for index, Part in pairs(BodyForces) do
			if Npc.Character.HumanoidRootPart:FindFirstChild(Part) then
				Npc.Character.HumanoidRootPart:FindFirstChild(Part):Destroy()
			end
		end
		if not Npc.Character.HumanoidRootPart:FindFirstChild("MyForceInstance") then
			local ForceInstance = Instance.new("BodyPosition", Npc.Character.HumanoidRootPart)
			ForceInstance.Name = "MyForceInstance"
			ForceInstance.P = 1000000
			ForceInstance.MaxForce = Vector3.new(2500000, 2500000, 2500000)
		end
		Npc.Character.HumanoidRootPart.MyForceInstance.Position = NpcPos
	end
end

local function WaitForObjectNameTip(Name, Tip)
	local objectName = game:GetService("Players").LocalPlayer.PlayerGui.Weapons.WeaponGui.Interact.ObjectName
	local objectTip = game:GetService("Players").LocalPlayer.PlayerGui.Weapons.WeaponGui.Interact.ObjectTip
	while objectName.Text ~= Name and objectTip.Text ~= Tip do
		RunService.RenderStepped:Wait()
	end
end

local function killNpc(npc)
	pcall(function()
		npc.Character.Humanoid.Health = -1
		npc.Character.Head.Neck:Destroy()
		npc.Character.HumanoidRootPart.MyForceInstance:Destroy()
	end)
end

local function sendMessage(message)
	local args = {
		[1] = message,
		[2] = "All"
	}

	game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(unpack(args))
end

workspace.Level.Actors.SeparatedNPCS.Guards.ChildAdded:Connect(function(npc)
	killNpc(npc)
end)

GetPlayer()

task.wait(0.1)

spawn(function()
	tweenPlayer(Vector3.new(-81.75, 12.25, 110.75))
	tweenPlayer(Vector3.new(-45.644, 9.45, 69.491))
	tweenPlayer(Vector3.new(-9.15, 3.65, 26.15))
	tweenPlayer(Vector3.new(-2.65, 3.65, 26.15))
	tweenPlayer(Vector3.new(-2.65, 3.65, 20.65))
	tweenPlayer(Vector3.new(-2.65, -6.85, 7.65))
end)

for _, v in pairs(workspace.Level.Actors.SeparatedNPCS.Guards:GetChildren()) do
	tpNpc(v, Vector3.new(-21.118181228637695, 3.500000476837158, -20.95203971862793))
end

for _, v in pairs(workspace.Level.Actors.SeparatedNPCS.Specials:GetChildren()) do
	tpNpc(v, Vector3.new(-21.118181228637695, 3.500000476837158, -20.95203971862793))
end

local keycardHolder = workspace.Level.Actors.SeparatedNPCS.Workers:FindFirstChild("NPC0")
local keycardHolderRadio = keycardHolder.Character.Head.Investigate.Radio

local keycardHolderHRP = keycardHolder.Character.HumanoidRootPart 
tpNpc(keycardHolder, Vector3.new(-68.7646103, 2.31619978, -44.3416023))

while keycardHolderHRP.Position.X > -56 and keycardHolderHRP.Position.Z > -30 do
	task.wait()
end

if keycardHolderRadio.Visible == true then
	sendMessage("[Script]: Radio call detected (Worker). Waiting...")
	while keycardHolderRadio.Visible == true do task.wait() end
	sendMessage("[Script]: Radio call has ended.")
end

task.wait(0.5)

killNpc(keycardHolder)

local Head = game.Players.LocalPlayer.Character.HeadM
local keycard = workspace.Level.GroundItems:WaitForChild("KeycardHS"):FindFirstChildOfClass("Part")
keycard.Anchored = true

local didKeycard = false
local didKeypad = false
local didControlRoomDoor = false

spawn(function()
	while didKeycard == false and task.wait() do
		keycard.CFrame = Head.CFrame + (Head.CFrame.LookVector * 2)
	end
end)

WaitForObjectNameTip("High Security Keycard", "Hit [F] to take")

input.press(Enum.KeyCode.F) 
didKeycard = true

task.wait(0.25)

local keypad = workspace.Level.Geometry.HighSecurityKeypad

spawn(function()
	while didKeypad == false and task.wait() do
		keypad.Base.CFrame = Head.CFrame + (Head.CFrame.LookVector * 2)
	end
	keypad:Destroy()
end)

WaitForObjectNameTip("Keycard Reader", "Hold [F] to use")

input.hold(Enum.KeyCode.F, keypad.Interact.Time.Value + 0.5)
didKeypad = true

local controlRoomDoor = workspace.Level.Geometry.Doors:GetChildren()[18]
controlRoomDoor.Interact.Opened.Value = true

spawn(function()
	while didControlRoomDoor == false and task.wait() do
		controlRoomDoor.Center.CFrame = Head.CFrame + (Head.CFrame.LookVector * 2)
	end
	controlRoomDoor:Destroy()
end)

WaitForObjectNameTip("Door", "Hit [F] to close")

input.press(Enum.KeyCode.F) 
didControlRoomDoor = true

tweenPlayer(Vector3.new(-2.75, 3.25, 21.25))
tweenPlayer(Vector3.new(-2.75, 3.25, 26.25))
tweenPlayer(Vector3.new(-12.25, 3.25, 26.25))
tweenPlayer(Vector3.new(-16.55, 3.25, -20.65))

local objectiveList = nil
local Objectives = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Weapons"):WaitForChild("WeaponGui"):WaitForChild("Objectives")
local Blacklist = {}

while objectiveList == nil and task.wait() do
	for _, object in pairs(Objectives:GetChildren()) do
		if not table.find(Blacklist, object) then
			if object.ClassName == "TextLabel" then
				table.insert(Blacklist, object)
			end
			if object.ClassName == "ScrollingFrame" then
				for _, objective in pairs(object:GetChildren()) do
					if objective.Label.Text ~= "Taking out Falcon will raise the alarm" then
						objectiveList = object
						break
					end
				end
			end
		end
 	end
end

local waitForOpenDoorFunc = nil
waitForOpenDoorFunc = objectiveList.ChildAdded:Connect(function(npc)
	for _, v in pairs(workspace.Level.Actors.SeparatedNPCS.Guards:GetChildren()) do
		killNpc(v)
	end
	for _, v in pairs(workspace.Level.Actors.SeparatedNPCS.Specials:GetChildren()) do
		killNpc(v)
	end
	tweenPlayer(Vector3.new(-15.05, 4.35, -61.55))
	waitForOpenDoorFunc:Disconnect()
end)
