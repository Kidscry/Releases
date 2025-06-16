
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kidscry/Releases/refs/heads/main/Utilities/Loader_UI"))();

-- // Dependencies
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kidscry/Releases/main/Utilities/UI.lua"))();

-- // Services
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local Workspace = game:GetService("Workspace");

-- // Objects
local LocalPlayer = Players.LocalPlayer;
local Camera = Workspace.CurrentCamera;

-- // RaycastModule
local raycastModule = require(ReplicatedStorage:WaitForChild("Events"):WaitForChild("Modules"):WaitForChild("RaycastModule"))

-- // Global settings
getgenv().Enabled = true
getgenv().FOV = 100

-- // Drawing Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Position = Camera.ViewportSize * 0.5
fovCircle.Visible = true
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Radius = getgenv().FOV
fovCircle.Transparency = 1
fovCircle.Filled = false
fovCircle.NumSides = 0

-- // Aimbot Targeting
local function getClosestPlayer()
    local closest = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or (player.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil) then continue end

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        if not rootPart or not head then continue end

        local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen or screenPosition.Z <= 0 then continue end

        local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - (Camera.ViewportSize * 0.5)).Magnitude
        if distance < getgenv().FOV and distance < closestDistance then
            closest = character
            closestDistance = distance
        end
    end

    return closest
end

-- // Override RaycastModule functions
for i, func in pairs(raycastModule) do
    if typeof(func) ~= "function" then continue end

    raycastModule[i] = function(...)
        if not getgenv().Enabled then return func(...) end

        local closest = getClosestPlayer()
        if not closest then return func(...) end

        return closest.Head, closest.Head.Position, Vector3.zero
    end
end

-- // FOV Circle dynamic update
RunService.RenderStepped:Connect(function()
    fovCircle.Radius = getgenv().FOV
    fovCircle.Visible = getgenv().Enabled
end)

-- // Unload function
if shared._unload then pcall(shared._unload) end;
function shared._unload()
    if library.open then library:Close() end;
    if fovCircle then fovCircle:Remove() end;
    library.base:ClearAllChildren()
    library.base:Destroy()
end

-- // UI Setup
local Main = library:CreateWindow("AIMBOT")
local Toggle = Main:AddToggle({text = "Aimbot Enabled", flag = "Aimbot", state = true, callback = function(state)
    getgenv().Enabled = state
end})

local Settings = library:CreateWindow("CONFIGURATIONS")

Settings:AddSlider({
    text = "FOV Radius",
    flag = "FOV",
    min = 10,
    max = 300,
    value = 100,
    callback = function(value)
        getgenv().FOV = value
    end
})

-- // Credits
local Credits = library:CreateWindow("CREDITS")
Credits:AddLabel({text='Jan - UI library'});
Credits:AddLabel({text='Kidscry - Script'});
Credits:AddLabel({text='Version 1.0.0'});
Credits:AddLabel({text='Updated 06/15/25'});
Credits:AddDivider();
Credits:AddButton({text = 'Unload script', callback = function() shared._unload() end});
Credits:AddDivider();
Credits:AddButton({text = 'More Scripts', callback = function() setclipboard("https://github.com/Kidscry/Releases") end});
Credits:AddDivider();
Credits:AddBind({
    text = 'Menu toggle',
    key = Enum.KeyCode.Backspace,
    callback = function() library:Close() end
})

-- // Init
library:Init()
