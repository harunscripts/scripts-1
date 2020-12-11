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
	if not workspace:FindFirstChild("platform:weary:") then
		local platform = Instance.new("Part", workspace)
		platform.Name = "platform:weary:"
		platform.Size = Vector3.new(1000, 10, 1000)
		platform.Position = Vector3.new(0, math.random(10000, 500000), 0)
		platform.Anchored = true
		platform.Transparency = 1
	end
	game:service("Players").LocalPlayer.Character:MoveTo(workspace["platform:weary:"].Position)
	workspace["platform:weary:"]:Destroy()
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
