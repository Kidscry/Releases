--[[

https://www.roblox.com/games/9800976141/Pandis-Aim-Trainer

ranked number #1 on the leaderboard

]]


local RunService = game:GetService("RunService");
local Camera = workspace.CurrentCamera;


local Settings = {
    Enabled = true;          
    TickRate = 1 / 240;      

    BaseLerp = 0.55;          -- base pull force 
    MaxLerp = 0.95;           -- adaptive upper force cap

    Adaptive = true;         
    Predict = true;          
    PredictionTime = 0.045;   -- slight forward prediction for stickiness
};

local MapCache = nil;
local HumanoidCache = {};
local LastTargetPos = nil;

-- detect active map
local function getActiveMap()
    local maps = workspace:FindFirstChild("Maps");
    if not maps then return nil; end;

    if MapCache and MapCache.Parent == maps and MapCache:FindFirstChild("Targets") then
        return MapCache;
    end;

    for _, obj in ipairs(maps:GetChildren()) do
        if obj:FindFirstChild("Targets") then
            MapCache = obj;
            return MapCache;
        end;
    end;

    return nil;
end;

-- rebuild humanoid list
local function rebuildHumanoidCache()
    table.clear(HumanoidCache);

    local map = getActiveMap();
    if not map then return HumanoidCache; end;

    local targets = map:FindFirstChild("Targets");
    if not targets then return HumanoidCache; end;

    for _, node in ipairs(targets:GetChildren()) do
        if node.Name == "Mesh" then
            local hum = node:FindFirstChild("Humanoid");
            if hum and hum.Health > 0 then
                HumanoidCache[#HumanoidCache + 1] = hum;
            end;
        end;
    end;

    return HumanoidCache;
end;

-- find aim part
local function resolveAimPart(humanoid)
    local model = humanoid.Parent;
    if not model then return nil; end;

    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Primary")
        or model:FindFirstChildWhichIsA("BasePart");
end;

-- choose closest
local function getClosestTargetPart()
    rebuildHumanoidCache();

    local best, bestDist = nil, math.huge;
    local camPos = Camera.CFrame.Position;

    for _, hum in ipairs(HumanoidCache) do
        local aimPart = resolveAimPart(hum);
        if aimPart then
            local d = (aimPart.Position - camPos).Magnitude;
            if d < bestDist then
                bestDist = d;
                best = aimPart;
            end;
        end;
    end;

    return best;
end;

-- adaptive lerp
local function computeLerpAlpha(targetPart)
    if not Settings.Adaptive then
        return Settings.BaseLerp;
    end;

    if not LastTargetPos then
        LastTargetPos = targetPart.Position;
        return Settings.BaseLerp;
    end;

    local movement = (targetPart.Position - LastTargetPos).Magnitude;
    LastTargetPos = targetPart.Position;

    -- stronger follow when target moves more
    local boosted = Settings.BaseLerp + movement * 0.35;
    return math.clamp(boosted, Settings.BaseLerp, Settings.MaxLerp);
end;

-- micro prediction
local function projectPosition(part)
    if not Settings.Predict then
        return part.Position;
    end;

    local v = part.AssemblyLinearVelocity or Vector3.zero;
    return part.Position + v * Settings.PredictionTime;
end;

-- main loop
task.spawn(function()
    while true do
        task.wait(Settings.TickRate);
        if not Settings.Enabled then continue; end;

        local targetPart = getClosestTargetPart();
        if targetPart then
            local projectedPos = projectPosition(targetPart);
            local desiredCF = CFrame.lookAt(Camera.CFrame.Position, projectedPos);

            local alpha = computeLerpAlpha(targetPart);
            Camera.CFrame = Camera.CFrame:Lerp(desiredCF, alpha);
        end;
    end;
end);