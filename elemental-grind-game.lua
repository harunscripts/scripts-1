--// library

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/venus-library/main/eggmodified.lua"))()

local commons = {}
local uncommons = {}
local rares = {}
local legends = {}
local myths = {}

do
    local elements = game:GetService("ReplicatedStorage").Client.GetElements:InvokeServer()

    for _, tbl in next, elements do
        if type(tbl) == "table" then
            if tbl[2] == "Common" then
                table.insert(commons, tbl[1])
            elseif tbl[2] == "Uncommon" then
                table.insert(uncommons, tbl[1])
            elseif tbl[2] == "Rare" then
                table.insert(rares, tbl[1])
            elseif tbl[2] == "Legend" then
                table.insert(legends, tbl[1])
            elseif tbl[2] == "Myth" then
                table.insert(myths, tbl[1])
            end
        end
    end
end

local main = library:Load({Name = "EGG Farmer", Theme = "Dark", SizeX = 237, SizeY = 362, ColorOverrides = {}})
local aimbot = main:Tab("Main")
local section = aimbot:Section({Name = "Autofarm", column = 1})

section:Toggle({Name = "Element Farmer", Flag = "elementfarm"})
local levelbeforespin = section:Box({Name = "Level Before Spinning", Flag = "levelbeforespin", Callback = function() end})
levelbeforespin:Set("2")

section:Toggle({Name = "Level Farmer", Flag = "levelfarm"})
local maxlevel = section:Box({Name = "Max Level", Flag = "maxlevel"})
maxlevel:Set("100")

local elements = {}

section:Label("Commons")

section:Dropdown({Content = commons, MultiChoice = true, Callback = function(tbl)
    table.clear(elements)
    for _, elem in next, tbl do
        table.insert(elements, elem)
    end
end})

section:Label("Uncommons")

section:Dropdown({Content = uncommons, MultiChoice = true, Callback = function(tbl)
    table.clear(elements)
    for _, elem in next, tbl do
        table.insert(elements, elem)
    end
end})

section:Label("Rares")

section:Dropdown({Content = rares, MultiChoice = true, Callback = function(tbl)
    table.clear(elements)
    for _, elem in next, tbl do
        table.insert(elements, elem)
    end
end})

section:Label("Legends")

section:Dropdown({Content = legends, MultiChoice = true, Callback = function(tbl)
    table.clear(elements)
    for _, elem in next, tbl do
        table.insert(elements, elem)
    end
end})

section:Label("Myths")

section:Dropdown({Content = myths, MultiChoice = true, Callback = function(tbl)
    table.clear(elements)
    for _, elem in next, tbl do
        table.insert(elements, elem)
    end
end})   

--// main

local services = setmetatable({}, {
    __index = function(_, service)
        return game:GetService(service)
    end
})

local client = services.Players.LocalPlayer
local moves = services.ReplicatedStorage[client.UserId .. "Client"]

local function getlevel()
    local data = services.ReplicatedStorage.Client.GetLevels:InvokeServer()
    for _, tbl in next, data do
        if table.find(tbl, client) then
            return tbl[2]
        end
    end
end

local function domoves()
    for _, move in next, client.Backpack:GetChildren() do
        local str = move.Name:split(" (")[1]

        task.spawn(function()
            moves.StartMove:FireServer(str)
            moves.EndMove:FireServer(str)
        end)
    end
end

local function farmspinlevel()
    repeat
        domoves()
        task.wait(0.1)
    until
        getlevel() >= tonumber(library.flags.levelbeforespin)
end

local found = false

local function spin()
    repeat
        local currentelement = services.ReplicatedStorage.Client.GetElement:InvokeServer()

        if table.find(elements, currentelement) then
            found = true
        else
            services.ReplicatedStorage.Client.Spin:InvokeServer()
        end

        task.wait(0.1)
    until
        library.flags.elementfarm == false or found or services.ReplicatedStorage.Client.GetSpins:InvokeServer() <= 0
end

local function startgame()
    services.ReplicatedStorage.Client.Teleport:InvokeServer()
    services.ReplicatedStorage.Client.Intro:InvokeServer()
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    workspace.CurrentCamera.CameraSubject = client.Character.Humanoid
    client.PlayerGui.IntroGui.Enabled = false
    client.PlayerGui.Spinner.Enabled = false
    client.PlayerGui.StatsGui.Enabled = true

    if not workspace:FindFirstChild("platform") then
		local platform = Instance.new("Part", workspace)
		platform.Name = "platform"
		platform.Size = Vector3.new(10000, 10, 10000)
		platform.Position = Vector3.new(0, math.random(10000, 100000), 0)
		platform.Anchored = true
		platform.Transparency = 0.5
	end

	client.Character:MoveTo(workspace["platform"].Position + Vector3.new(0, 5, 0))
end

local function farmlevel()
    repeat
        domoves()
        task.wait(0.1)
    until
        getlevel() >= tonumber(library.flags.maxlevel) or library.flags.levelfarm == false
end

--// main loop

while task.wait(0.1) do
    if library.flags.elementfarm and not found then
        startgame()
        farmspinlevel()
        client.Character.Humanoid.Health = 0
        repeat task.wait(0.1) until client.Character and client.Character:WaitForChild("Humanoid").Health > 0
        spin()
    end
    if library.flags.levelfarm and (library.flags.elementfarm and found or true) then
        repeat task.wait(0.1) until client.Character and client.Character:WaitForChild("Humanoid").Health > 0
        startgame()
        farmlevel()
    end
end
