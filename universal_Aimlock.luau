--// services
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local UIS = game:GetService("UserInputService");
local Camera = workspace.CurrentCamera;

local LocalPlayer = Players.LocalPlayer;

--// config
local Aimlock = {
    Enabled = false;
    Keybind = Enum.KeyCode.Q;
    Smoothness = 0.22;
    MaxDistance = 3000;

    RaycastDelay = 0.08;
};

--// cache
local LastRaycastTime = 0;
local CurrentTarget = nil;

--//
local function IsVisible(part: BasePart)
    if not part then return false end;

    -- throttle raycasts a bit
    if tick() - LastRaycastTime < Aimlock.RaycastDelay then
        return true;
    end
    LastRaycastTime = tick();

    local origin = Camera.CFrame.Position;

    -- sample multiple points on the target part
    local size = part.Size / 2;
    local base = part.Position;

    local points = {
        base;
        base + Vector3.new(0, size.Y, 0);
        base - Vector3.new(0, size.Y, 0);
        base + Vector3.new(size.X, 0, 0);
        base - Vector3.new(size.X, 0, 0);
    };

    local params = RaycastParams.new();
    params.FilterType = Enum.RaycastFilterType.Blacklist;
    params.FilterDescendantsInstances = {
        LocalPlayer.Character;
        Camera;
    };

    for _, pos in ipairs(points) do
        local direction = pos - origin;
        local result = workspace:Raycast(origin, direction, params);
        if result and result.Instance and result.Instance:IsDescendantOf(part.Parent) then
            return true;
        end
    end

    return false;
end

--// get closest visible target to crosshair
local function GetTarget()
    local mousePos = UIS:GetMouseLocation();
    local bestDist = Aimlock.MaxDistance;
    local bestPart = nil;

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character;
            if char then
                local head = char:FindFirstChild("Head") :: BasePart?;
                local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?;
                local part = head or hrp;

                if part then
                    -- cheap check
                    local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position);
                    if onScreen then
                        local dist = (Vector2.new(mousePos.X, mousePos.Y)
                            - Vector2.new(screenPos.X, screenPos.Y)).Magnitude;

                        if dist < bestDist then
                            -- only visibility check when crosshair close
                            if dist < 200 then
                                if not IsVisible(part) then continue end;
                            end

                            bestDist = dist;
                            bestPart = part;
                        end
                    end
                end
            end
        end
    end

    return bestPart;
end

--// toggle aimlock
UIS.InputBegan:Connect(function(key, gp)
    if gp then return end;
    if key.KeyCode == Aimlock.Keybind then
        Aimlock.Enabled = not Aimlock.Enabled;
        if not Aimlock.Enabled then
            CurrentTarget = nil;
        end
    end
end);

--// aimlock loop
RunService.RenderStepped:Connect(function()
    if not Aimlock.Enabled then 
        CurrentTarget = nil;
        return;
    end

    -- stick to target if still valid
    if CurrentTarget then
        if CurrentTarget.Parent 
            and CurrentTarget:IsA("BasePart")
            and IsVisible(CurrentTarget) then

            local cf = CFrame.lookAt(Camera.CFrame.Position, CurrentTarget.Position);
            Camera.CFrame = Camera.CFrame:Lerp(cf, Aimlock.Smoothness);
            return;
        end

        -- target lost
        CurrentTarget = nil;
    end

    -- grab new target
    CurrentTarget = GetTarget();
end);
