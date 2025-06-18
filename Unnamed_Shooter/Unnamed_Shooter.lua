--[[
 __  __     __     _____     ______     ______     ______     __  __    
/\ \/ /    /\ \   /\  __-.  /\  ___\   /\  ___\   /\  == \   /\ \_\ \   
\ \  _"-.  \ \ \  \ \ \/\ \ \ \___  \  \ \ \____  \ \  __<   \ \____ \  
 \ \_\ \_\  \ \_\  \ \____-  \/\_____\  \ \_____\  \ \_\ \_\  \/\_____\ 
  \/_/\/_/   \/_/   \/____/   \/_____/   \/_____/   \/_/ /_/   \/_____/ 

Loader : loadstring(game:HttpGet("https://github.com/Kidscry/Releases/blob/main/Unnamed_Shooter/Unnamed_Shooter.lua"))();
]]

--[[ INITIAL SETUP ]]--
local serviceCache = {}
local Services = setmetatable(serviceCache, {
    __index = function(_, service)
        local s = game:GetService(service)
        rawset(serviceCache, service, s)
        return s
    end
})

local secureLoadstring = function(url)
    local s, r = pcall(function()
        return loadstring(game:HttpGet(url))
    end)
    return s and r or function() end
end

--[[ MODULE LOADING ]]--
local Config = {
    UI_URL = "https://raw.githubusercontent.com/Kidscry/Releases/refs/heads/main/Utilities/Loader_UI",
    LIBRARY_URL = "https://raw.githubusercontent.com/Kidscry/Releases/main/Utilities/UI.lua",
    MIN_FOV = 10,
    MAX_FOV = 300,
    DEFAULT_FOV = 100,
    TOGGLE_KEY = Enum.KeyCode.Backspace,
    SCRIPT_VERSION = "1.0.0"
}

local library = secureLoadstring(Config.LIBRARY_URL)()
secureLoadstring(Config.UI_URL)()

--[[ SERVICE REFERENCES ]]--
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local Workspace = Services.Workspace
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--[[ STATE ]]--
local State = {
    Enabled = true,
    FOV = Config.DEFAULT_FOV,
    Circle = nil
}

--[[ UTILITY FUNCTIONS ]]--
local function createCircle()
    local circle = Drawing.new("Circle")
    circle.Position = Camera.ViewportSize * 0.5
    circle.Visible = true
    circle.Color = Color3.fromRGB(255, 255, 255)
    circle.Radius = State.FOV
    circle.Transparency = 1
    circle.Filled = false
    circle.NumSides = 0
    return circle
end

local function updateFOV()
    if State.Circle then
        State.Circle.Radius = State.FOV
        State.Circle.Visible = State.Enabled
    end
end

--[[ AIMBOT TARGETING ]]--
local function getClosestTarget()
    local closest, shortest = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or (player.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil) then continue end

        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        if not root or not head then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen or screenPos.Z <= 0 then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - (Camera.ViewportSize * 0.5)).Magnitude
        if dist < State.FOV and dist < shortest then
            closest, shortest = character, dist
        end
    end
    return closest
end

--[[ MODULE OVERRIDE ]]--
local function applyAimbot(raycastModule)
    for k, v in pairs(raycastModule) do
        if typeof(v) == "function" then
            raycastModule[k] = function(...)
                if not State.Enabled then return v(...) end
                local target = getClosestTarget()
                if not target then return v(...) end
                return target.Head, target.Head.Position, Vector3.zero
            end
        end
    end
end

--[[ TAMPER-PROOFING ]]--
local function harden()
    setreadonly(getfenv(), false)
    getgenv().Enabled = true
    getgenv().FOV = State.FOV

    hookfunction(getfenv, function(...) return {} end)
    hookfunction(setfenv, function(...) return nil end)
    -- Optional: inject detection-blocks, anti-hooks, async exec
end

--[[ UI CONFIGURATION ]]--
local function setupUI()
    local Main = library:CreateWindow("AIMBOT")
    Main:AddToggle({text = "Aimbot Enabled", flag = "Aimbot", state = true, callback = function(state)
        State.Enabled = state
        getgenv().Enabled = state
    end})

    local Settings = library:CreateWindow("CONFIGURATIONS")
    Settings:AddSlider({
        text = "FOV Radius",
        flag = "FOV",
        min = Config.MIN_FOV,
        max = Config.MAX_FOV,
        value = Config.DEFAULT_FOV,
        callback = function(val)
            State.FOV = val
            getgenv().FOV = val
            updateFOV()
        end
    })

    local Credits = library:CreateWindow("CREDITS")
    Credits:AddLabel({text='Jan - UI library'})
    Credits:AddLabel({text='Kidscry - Script'})
    Credits:AddLabel({text='Version ' .. Config.SCRIPT_VERSION})
    Credits:AddDivider()
    Credits:AddButton({text = 'Unload script', callback = function()
        shared._unload()
    end})
    Credits:AddButton({text = 'More Scripts', callback = function()
        setclipboard("https://github.com/Kidscry/Releases")
    end})
    Credits:AddBind({
        text = 'Menu toggle',
        key = Config.TOGGLE_KEY,
        callback = function()
            library:Close()
        end
    })
end

--[[ UNLOADING / CLEANUP ]]--
if shared._unload then pcall(shared._unload) end
shared._unload = function()
    pcall(function()
        State.Circle:Remove()
        library.base:ClearAllChildren()
        library.base:Destroy()
    end)
end

--[[ RUNTIME INIT ]]--
State.Circle = createCircle()
RunService.RenderStepped:Connect(updateFOV)

local success, err = pcall(function()
    local RaycastModule = require(ReplicatedStorage:WaitForChild("Events"):WaitForChild("Modules"):WaitForChild("RaycastModule"))
    applyAimbot(RaycastModule)
    setupUI()
    harden()
    library:Init()
end)

if not success then warn("[AIMBOT ERROR]", err) end
