local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local HumFolder = Workspace:WaitForChild("Hum")

-------------------------------------------------
-- ROOT
-------------------------------------------------
local function getRoot()
	local char = player.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("UpperTorso")
end

-------------------------------------------------
-- TELEPORT + ACTIVAR
-------------------------------------------------
local function teleportAndActivate(prompt, part)
	local root = getRoot()
	if root and part and prompt then
		root.CFrame = part.CFrame + Vector3.new(0,3,0)
		task.wait(0.2)
		pcall(function()
			fireproximityprompt(prompt)
		end)
	end
end

-------------------------------------------------
-- BUSCAR D2
-------------------------------------------------
local function findD2Prompt()
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("MeshPart") and obj.Name == "D2" then
			local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				return prompt, obj
			end
		end
	end
	return nil, nil
end

-------------------------------------------------
-- DETECTAR POPCAN
-------------------------------------------------
local function isPopcan(name)
	return string.match(string.lower(name), "^popcan%d*$") ~= nil
end

local function handlePopcans()
	local promptsFolder = Workspace:FindFirstChild("Prompts")
	if not promptsFolder then return end
	
	for _, obj in pairs(promptsFolder:GetChildren()) do
		if obj:IsA("MeshPart") and isPopcan(obj.Name) then
			local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
			while prompt and prompt.Parent and prompt.Enabled do
				teleportAndActivate(prompt, obj)
				task.wait(0.5)
			end
		end
	end
end

-------------------------------------------------
-- GUI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local labelDone = Instance.new("TextLabel")
labelDone.Size = UDim2.new(0,300,0,50)
labelDone.Position = UDim2.new(0.5,-150,0,50)
labelDone.BackgroundColor3 = Color3.fromRGB(0,0,0)
labelDone.TextColor3 = Color3.fromRGB(255,255,255)
labelDone.TextScaled = true
labelDone.Parent = screenGui
labelDone.Text = "Done True: 0"

local labelCupid = Instance.new("TextLabel")
labelCupid.Size = UDim2.new(0,300,0,50)
labelCupid.Position = UDim2.new(0.5,-150,0,110)
labelCupid.BackgroundColor3 = Color3.fromRGB(0,0,0)
labelCupid.TextColor3 = Color3.fromRGB(255,0,0)
labelCupid.TextScaled = true
labelCupid.Parent = screenGui
labelCupid.Text = "Cupid: Activo"

-------------------------------------------------
-- CONTADOR DE DONE TRUE
-------------------------------------------------
local doneCount = 0

local function updateDoneCounter()
	doneCount += 1
	labelDone.Text = "Done True: "..doneCount
end

local function trackModel(model)
	model:GetAttributeChangedSignal("Done"):Connect(function()
		if model:GetAttribute("Done") == true then
			updateDoneCounter()
		end
	end)
end

for _, model in pairs(HumFolder:GetChildren()) do
	if model:IsA("Model") then
		trackModel(model)
	end
end

HumFolder.ChildAdded:Connect(function(model)
	if model:IsA("Model") then
		task.wait(0.2)
		trackModel(model)
	end
end)

-- Contar Clown al desaparecer
HumFolder.ChildRemoved:Connect(function(model)
	if model.Name == "Clown" then
		updateDoneCounter()
	end
end)

-------------------------------------------------
-- EXCLUSIONES
-------------------------------------------------
local excluded = {
	OldMna = true,
	Clown = true,
	Myso = true,
	Myst = true
}

-- Scream puede tener número
local function isExcluded(model)
	if excluded[model.Name] then return true end
	if string.match(model.Name, "^Scream%d*$") then return true end
	return false
end

local cupidIgnored = false

-------------------------------------------------
-- VERIFICAR SI HAY DONE FALSE VÁLIDO
-------------------------------------------------
local function hasValidDoneFalse()
	for _, model in pairs(HumFolder:GetChildren()) do
		if model:IsA("Model") then
			
			if isExcluded(model) then
				continue
			end
			
			-- Cupid especial
			if model.Name == "Cupid" then
				if cupidIgnored then
					continue
				end
				if model:GetAttribute("Done") == false then
					labelCupid.Text = "Cupid: Ignorando..."
					local startTime = tick()
					repeat
						task.wait(1)
						if model:GetAttribute("Done") == true then
							labelCupid.Text = "Cupid: Activo"
							return true
						end
					until tick() - startTime >= 20
					cupidIgnored = true
					labelCupid.Text = "Cupid: Ignorado hasta reaparezca"
					continue
				end
			end
			
			if model:GetAttribute("Done") == false then
				labelCupid.Text = "Cupid: Activo"
				return true
			end
		end
	end
	return false
end

-- Reset Cupid si reaparece
HumFolder.ChildAdded:Connect(function(model)
	if model.Name == "Cupid" then
		cupidIgnored = false
		labelCupid.Text = "Cupid: Activo"
	end
end)

-------------------------------------------------
-- LOOP PRINCIPAL
-------------------------------------------------
while true do
	
	if not hasValidDoneFalse() then
		repeat task.wait(1) until hasValidDoneFalse()
	end
	
	local promptD2, partD2 = findD2Prompt()
	
	for _, model in pairs(HumFolder:GetChildren()) do
		if model:IsA("Model") then
			if isExcluded(model) then
				continue
			end
			if model.Name == "Cupid" and cupidIgnored then
				continue
			end
			if model:GetAttribute("Done") == false then
				if promptD2 and partD2 then
					teleportAndActivate(promptD2, partD2)
				end
			end
		end
	end
	
	handlePopcans()
	
	task.wait(2)
end
