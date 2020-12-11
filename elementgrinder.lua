local gui = Instance.new("ScreenGui")
gui.Parent = game:service("CoreGui")
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Active = true
frame.Draggable = true
frame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 201, 0, 280)
local holder = Instance.new("ScrollingFrame")
holder.Parent = frame
holder.Active = true
holder.BackgroundTransparency = 0.970
holder.BorderSizePixel = 0
holder.Position = UDim2.new(0, 0, 0.107, 0)
holder.Size = UDim2.new(0, 201, 0, 249)
holder.ScrollBarThickness = 5
local list = Instance.new("UIListLayout")
list.Parent = holder
list.SortOrder = Enum.SortOrder.LayoutOrder
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	holder.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
end)
local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundTransparency = 1.000
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Size = UDim2.new(0, 190, 0, 30)
title.Font = Enum.Font.SourceSans
title.Text = "Spin Holder"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16.000
title.TextXAlignment = Enum.TextXAlignment.Left
local search = Instance.new("TextBox")
search.Parent = frame
search.BackgroundTransparency = 1.000
search.ClipsDescendants = true
search.Position = UDim2.new(0.482587069, 0, 0.021428572, 0)
search.Size = UDim2.new(0, 95, 0, 17)
search.Font = Enum.Font.SourceSans
search.Text = ""
search.PlaceholderText = "Search"
search.TextColor3 = Color3.fromRGB(255, 255, 255)
search.TextSize = 14.000

function insert(element)
	local label = Instance.new("TextLabel")
	label.Name = string.upper(element)
	label.Parent = holder
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 17)
	label.Text = "  " .. element
	label.Font = Enum.Font.SourceSans
	label.TextSize = 15.000
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left
end

function update()
	local input = string.upper(search.Text)
	for i,v in pairs(holder:GetChildren()) do
		if v:IsA("TextLabel") then
			if input == "" or string.find(string.upper(v.Name), input) ~= nil then
				v.Visible = true
			else
				v.Visible = false
			end
		end
	end
end
spawn(function() while wait() do update() end end)

if not isfile("spincounter.vozoid") then
	writefile("spincounter.vozoid", "0")
end

getgenv().spinning = false
getgenv().disablerespawn = false

local client = game:service("ReplicatedStorage"):WaitForChild(game:service("Players").LocalPlayer.UserId .. "Client")

function firemoves()
    for i,v in pairs(game:service("Players").LocalPlayer.Backpack:GetChildren()) do
        client.StartMove:FireServer(tostring(v))
        client.EndMove:FireServer(tostring(v))
    end
end

function restartplayer()
	game:service("ReplicatedStorage").Client.StartGame:FireServer()
	game:service("ReplicatedStorage").Client.Intro:InvokeServer()
	game:service("ReplicatedStorage").Client.Teleport:InvokeServer()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.CameraSubject = game:service("Players").LocalPlayer.Character.Humanoid
	game:service("Players").LocalPlayer.PlayerGui.IntroGui.Enabled = false
	game:service("Players").LocalPlayer.PlayerGui.StatsGui.Enabled = true
	if workspace:FindFirstChild("platform:weary:") then
		workspace["platform:weary:"]:Destroy()
	end
	if not workspace:FindFirstChild("platform:weary:") then
		local platform = Instance.new("Part", workspace)
		platform.Name = "platform:weary:"
		platform.Size = Vector3.new(1000, 10, 1000)
		platform.Position = Vector3.new(0, math.random(10000, 100000), 0)
		platform.Anchored = true
		platform.Transparency = 0
	end
	game:service("Players").LocalPlayer.Character:MoveTo(workspace["platform:weary:"].Position + Vector3.new(0, 5, 0))
end

game:service("Players").LocalPlayer.CharacterAdded:connect(function()
	if not getgenv().disablerespawn then
		restartplayer()
	else
		getgenv().disablerespawn = false
	end
end)

function getlevel()
    for i,v in pairs(game:service("ReplicatedStorage").Client.GetLevels:InvokeServer()) do
        for i2, v2 in pairs(v) do
            if v2 == game:service("Players").LocalPlayer then
                return v[2]
            end
         end
    end
end

function farmuntillevel()
    repeat
        wait(.1)
        firemoves()
    until
		getlevel() >= getgenv().Settings.LevelBeforeSpinning
	game:service("Players").LocalPlayer.Character.Humanoid.Health = 0
	getgenv().spinning = true
end

function checkelement(element)
    for i,v in pairs(getgenv().Settings.ElementsToFarm) do
        if tostring(element) == v then
            return true
        end
    end
end

function startfarm()
	while wait(.1) do
		if getgenv().Settings.ElementFarm == true then
			if not checkelement(game:service("ReplicatedStorage").Client.GetElement:InvokeServer()) then
				if getgenv().spinning then
					getgenv().disablerespawn = true
					game:service("ReplicatedStorage").Client.Spin:InvokeServer()
					writefile("spincounter.vozoid", tostring((tonumber(readfile("spincounter.vozoid")) + 1)))
					print("new element: " .. game:service("ReplicatedStorage").Client.GetElement:InvokeServer() .. " - total spins: " .. readfile("spincounter.vozoid"))
					insert(game:service("ReplicatedStorage").Client.GetElement:InvokeServer())
				end
				if game:service("ReplicatedStorage").Client.GetSpins:InvokeServer() <= 0 then
					getgenv().spinning = false
					getgenv().disablerespawn = false
					restartplayer()
					farmuntillevel()
				end
			else
				getgenv().Settings.ElementFarm = false
				if getgenv().Settings.LevelFarm == true then
					levelfarm()
				end
			end
		end
	end
end

function levelfarm()
	repeat
		wait(.1)
		firemoves()
	until
		getlevel() >= getgenv().Settings.MaxLevel
end

if getgenv().Settings.ElementFarm == true then
	farmuntillevel()
	startfarm()
end
if getgenv().Settings.LevelFarm == true then
	levelfarm()
end
