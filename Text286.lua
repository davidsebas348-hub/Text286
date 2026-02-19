local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Kit = Workspace:WaitForChild("Kit")
local Garge = Kit:WaitForChild("Garge")
local Door = Garge:WaitForChild("Door")
local Button = Garge:WaitForChild("Button")

-- ROOT
local function getRoot()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

-- TELEPORT + ACTIVAR PROMPT
local function teleportAndActivate(prompt, part)
	local root = getRoot()
	root.CFrame = part.CFrame + Vector3.new(0,3,0)
	task.wait(0.2)
	pcall(function()
		fireproximityprompt(prompt)
	end)
end

-- BUSCAR PROMPT DE LA PUERTA
local function findButtonPrompt()
	if Button then
		local prompt = Button:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			return prompt, Button
		end
	end
	return nil, nil
end

-- FUNCION PARA ABRIR PUERTA
local function openDoor()
	local prompt, part = findButtonPrompt()
	if prompt and part then
		teleportAndActivate(prompt, part)
		print("Puerta abierta!")
	end
end

-- ABRIR PUERTA AL EJECUTAR (espera 5 segundos)
task.spawn(function()
	task.wait(5)
	openDoor()
end)

-- DETECTAR CAMBIO DE DÍA
local totalDaysValue = ReplicatedStorage:WaitForChild("TotalDays")
local lastDay = totalDaysValue.Value

totalDaysValue:GetPropertyChangedSignal("Value"):Connect(function()
	local currentDay = totalDaysValue.Value
	if currentDay ~= lastDay then
		lastDay = currentDay
		print("Cambio de día detectado! Esperando 10 segundos antes de abrir puerta...")
		task.spawn(function()
			task.wait(20)
			openDoor()
		end)
	end
end)
