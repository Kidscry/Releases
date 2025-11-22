--[[
 __  __     __     _____     ______     ______     ______     __  __    
/\ \/ /    /\ \   /\  __-.  /\  ___\   /\  ___\   /\  == \   /\ \_\ \   
\ \  _"-.  \ \ \  \ \ \/\ \ \ \___  \  \ \ \____  \ \  __<   \ \____ \  
 \ \_\ \_\  \ \_\  \ \____-  \/\_____\  \ \_____\  \ \_\ \_\  \/\_____\ 
  \/_/\/_/   \/_/   \/____/   \/_____/   \/_____/   \/_/ /_/   \/_____/ 
  - Rewrite : Introvert1337 Chams.lua
    Note: Planning to severly modify the script soon
    Loader : loadstring(game:HttpGet("https://raw.githubusercontent.com/Kidscry/Releases/main/Universal_Rewrite_Chams/Rewrite_Chams.lua"))();

Changelogs:
06/10/25
+ Improved initialization logic and error handling in ApplyChams() using pcall.
     + Added table.clear() to safely reset Connections and Highlights in DisconnectAll() function.
     ! Cleaned up Heartbeat loop logic: reduced nesting, improved readability, and grouped conditions.
     ! Simplified character connection/disconnection flow by checking for connection existence before disconnecting.
03/18/23
     + Added Check to Apply Highlights to non-team players
        ! Revised the script to only apply chams to non-teammates, even in non-team-based games.(Universal)
        ! Chams Setting Issues: Some errors in Configuration
03/17/23
     * Increased highlights Update Frequency and Table Iteration Performance.
     * Changed to 'function()' notation for better compatibility.
     * Improved table iteration performance with 'ipairs' instead of 'pairs'.
     * Replaced 'table.getn(table)' with '#table' for better performance.
     * Added 'Connection Manager' to handle event management & Code Maintainability .
     + Added error handling with 'PCall'

     - Removed Unused Connections Table Keys
]]
-- // Services
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local CoreGui = game:GetService("CoreGui");

-- // Vars
local LocalPlayer = Players.LocalPlayer;

-- // Chams Settings
local ChamsSettings = {
    TeamOutlineColor = Color3.new(1, 1, 1);
    EnemyOutlineColor = Color3.new(1, 1, 1);
    TeamFillColor = Color3.new(0, 1, 0);
    EnemyFillColor = Color3.new(1, 0, 0);
    FillTransparency = 0.75;
    OutlineTransparency = 0;
    UseTeamColors = false;
    ShowTeam = false;
};

-- // Highlight Objects
local Highlights = {};

-- // Event Connections
local Connections = {
    PlayerAdded = nil;
    CharacterAdded = {};
    CharacterRemoving = {};
};

-- // Remove Highlight
local function RemoveChams(Player) 
    local Highlight = Highlights[Player];
    if Highlight then
        Highlight:Destroy();
        Highlights[Player] = nil;
    end;
end;

-- // Apply Highlight Function
local function ApplyChams(Player)
    local function OnCharacterAdded(Character)
        local Highlight = Instance.new("Highlight");
        Highlight.Adornee = Character;
        Highlight.Parent = CoreGui;
        Highlight.OutlineTransparency = ChamsSettings.OutlineTransparency;
        Highlight.FillTransparency = ChamsSettings.FillTransparency;
        Highlights[Player] = Highlight;
    end;

    if Player.Character then
        OnCharacterAdded(Player.Character);
    end;

    Connections.CharacterAdded[Player] = Player.CharacterAdded:Connect(OnCharacterAdded);
    Connections.CharacterRemoving[Player] = Player.CharacterRemoving:Connect(function()
        RemoveChams(Player);
    end);
end;

-- // Initialization
for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        pcall(ApplyChams, Player);
    end;
end;

Connections.PlayerAdded = Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer then
        pcall(ApplyChams, Player);
    end;
end);

Players.PlayerRemoving:Connect(function(Player)
    local addConn = Connections.CharacterAdded[Player];
    local remConn = Connections.CharacterRemoving[Player];
    if addConn then addConn:Disconnect(); end;
    if remConn then remConn:Disconnect(); end;
    RemoveChams(Player);
end);

local ConnectionManager = {
    DisconnectAll = function()
        if Connections.PlayerAdded then
            Connections.PlayerAdded:Disconnect();
        end;
        for _, Connection in pairs(Connections.CharacterAdded) do
            Connection:Disconnect();
        end;
        for _, Connection in pairs(Connections.CharacterRemoving) do
            Connection:Disconnect();
        end;
        table.clear(Connections);
        table.clear(Highlights);
    end;
};

RunService.Heartbeat:Connect(function()
    local enemyFound = false;
    for Player, Highlight in pairs(Highlights) do
        if Player.Team ~= LocalPlayer.Team then
            enemyFound = true;
            Highlight.Enabled = true;
            Highlight.OutlineColor = ChamsSettings.EnemyOutlineColor;
            Highlight.FillColor = ChamsSettings.EnemyFillColor;
        else
            Highlight.Enabled = false;
        end;
    end;
    if not enemyFound then
        for _, Highlight in pairs(Highlights) do
            Highlight.Enabled = true;
            Highlight.OutlineColor = ChamsSettings.TeamOutlineColor;
            Highlight.FillColor = ChamsSettings.TeamFillColor;
        end;
    end;
end);

return ConnectionManager;