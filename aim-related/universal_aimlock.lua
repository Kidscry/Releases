--// load UI library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kidscry/Releases/refs/heads/main/UI.lua"))();

--// services
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local UIS = game:GetService("UserInputService");
local Camera = workspace.CurrentCamera;

local LocalPlayer = Players.LocalPlayer;

--// aimlock config
local Aimlock = {
    Enabled = false;
    Keybind = Enum.KeyCode.Q;
    Smoothness = 0.22;
    MaxDistance = 3000;
    RaycastDelay = 0.08;
};

local LastRaycastTime = 0;
local CurrentTarget = nil;

local function IsVisible(part: BasePart)
    if not part then return false end;

    if tick() - LastRaycastTime < Aimlock.RaycastDelay then
        return true;
    end;
    LastRaycastTime = tick();

    local origin = Camera.CFrame.Position;
    local half = part.Size / 2;
    local base = part.Position;

    local points = {
        base;
        base + Vector3.new(0, half.Y, 0);
        base - Vector3.new(0, half.Y, 0);
        base + Vector3.new(half.X, 0, 0);
        base - Vector3.new(half.X, 0, 0);
    };

    local params = RaycastParams.new();
    params.FilterType = Enum.RaycastFilterType.Blacklist;
    params.FilterDescendantsInstances = { LocalPlayer.Character; Camera; };

    for _, pos in ipairs(points) do
        local result = workspace:Raycast(origin, pos - origin, params);
        if result and result.Instance and result.Instance:IsDescendantOf(part.Parent) then
            return true;
        end;
    end;

    return false;
end;

local function GetTarget()
    local mousePos = UIS:GetMouseLocation();
    local bestDist = Aimlock.MaxDistance;
    local bestPart = nil;

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character;
            if char then
                local head = char:FindFirstChild("Head") :: BasePart?;
                local hrp  = char:FindFirstChild("HumanoidRootPart") :: BasePart?;
                local part = head or hrp;

                if part then
                    local sp, onScreen = Camera:WorldToScreenPoint(part.Position);
                    if onScreen then
                        local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(sp.X, sp.Y)).Magnitude;

                        if dist < bestDist then
                            if dist < 200 then
                                if not IsVisible(part) then continue end;
                            end;

                            bestDist = dist;
                            bestPart = part;
                        end;
                    end;
                end;
            end;
        end;
    end;

    return bestPart;
end;

RunService.RenderStepped:Connect(function()
    if not Aimlock.Enabled then
        CurrentTarget = nil;
        return;
    end;

    if CurrentTarget then
        if CurrentTarget.Parent
            and CurrentTarget:IsA("BasePart")
            and IsVisible(CurrentTarget) then

            local look = CFrame.lookAt(Camera.CFrame.Position, CurrentTarget.Position);
            Camera.CFrame = Camera.CFrame:Lerp(look, Aimlock.Smoothness);
            return;
        end;

        CurrentTarget = nil;
    end;

    CurrentTarget = GetTarget();
end);

local win = library:CreateWindow("Aimlock");

win:AddToggle({
    text = "Enable Aimlock";
    state = false;
    flag = "aim_enable";
    callback = function(val)
        Aimlock.Enabled = val;
    end;
});

win:AddBind({
    text = "Aim Key";
    key = "Q";
    hold = false;
    callback = function()
        Aimlock.Enabled = not Aimlock.Enabled;
    end;
});

win:AddSlider({
    text = "Smoothness";
    min = 0.01;
    max = 1;
    float = 0.01;
    value = Aimlock.Smoothness;
    flag = "aim_smooth";
    callback = function(v)
        Aimlock.Smoothness = v;
    end;
});

win:AddSlider({
    text = "Max Distance";
    min = 100;
    max = 3000;
    value = Aimlock.MaxDistance;
    float = 1;
    flag = "aim_dist";
    callback = function(v)
        Aimlock.MaxDistance = v;
    end;
});

library:Init();
