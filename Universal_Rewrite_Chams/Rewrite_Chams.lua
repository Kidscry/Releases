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

03/17/23
     * Increased highlights Update Frequency and Table Iteration Performance.
     * Changed to 'function()' notation for better compatibility.
     * Improved table iteration performance with 'ipairs' instead of 'pairs'.
     * Replaced 'table.getn(table)' with '#table' for better performance.

     + Added error handling with 'PCall'

     - Removed Unused Connections Table Keys
]]
--// Services
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local CoreGui = game:GetService("CoreGui");

-- Variables and Settings
local LocalPlayer = Players.LocalPlayer;

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

local Highlights = {};
local Connections = {
    PlayerAdded = nil;
    CharacterAdded = {};
    CharacterRemoving = {};
};

-- Functions
local function RemoveChams(Player)
    local Highlight = Highlights[Player];
    if Highlight then
        Highlight:Destroy();
        Highlights[Player] = nil;
    end;
end;

local function ApplyChams(Player)
    local function OnCharacterAdded(Character)
        local Highlight = Instance.new("Highlight");
        Highlight.Adornee = Character;
        Highlight.Parent = CoreGui;
        Highlight.OutlineTransparency = ChamsSettings.OutlineTransparency;
        Highlight.FillTransparency = ChamsSettings.FillTransparency;
        Highlights[Player] = Highlight;
    end;

    local Character = Player.Character;
    if Character then
        OnCharacterAdded(Character);
    end;

    Connections.CharacterAdded[Player] = Player.CharacterAdded:Connect(function(Character)
        OnCharacterAdded(Character);
    end);

    Connections.CharacterRemoving[Player] = Player.CharacterRemoving:Connect(function()
        RemoveChams(Player);
    end);
end;

-- Initialization
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
    local CharacterAddedConnection = Connections.CharacterAdded[Player];
    local CharacterRemovingConnection = Connections.CharacterRemoving[Player];
    if CharacterAddedConnection and CharacterRemovingConnection then
        CharacterAddedConnection:Disconnect();
        CharacterRemovingConnection:Disconnect();
    end;
    RemoveChams(Player);
end);

RunService.Heartbeat:Connect(function()
    for Player, Highlight in pairs(Highlights) do
        local IsSameTeam = Player.Team == LocalPlayer.Team;
        Highlight.Enabled = ChamsSettings.ShowTeam or not IsSameTeam;
        Highlight.OutlineColor = IsSameTeam and ChamsSettings.TeamOutlineColor or ChamsSettings.EnemyOutlineColor;
        Highlight.FillColor = ChamsSettings.UseTeamColors and Player.TeamColor or (IsSameTeam and ChamsSettings.TeamFillColor or ChamsSettings.EnemyFillColor);
    end;
end);

