--// load UI library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kidscry/Releases/refs/heads/main/UI.lua"))();

--// services
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local UIS = game:GetService("UserInputService");
local Camera = workspace.CurrentCamera;

local LocalPlayer = Players.LocalPlayer;

--// legit aim assist config
local Assist = {
    Enabled = false;
    Strength = 0.05; 
    MaxDistance = 2500;
    FOV = 120;
    RaycastDelay = 0.08;
};

local LastRaycast = 0;
local MouseDown = false;

--// detect M1 hold
UIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        MouseDown = true;
    end;
end);

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        MouseDown = false;
    end;
end);

local function IsVisible(part)
    if not part or not part:IsA("BasePart") then 
        return false;
    end;

    local camCF = Camera.CFrame;
    local origin = camCF.Position;

    --
    local dir = (part.Position - origin).Unit;
    if dir:Dot(camCF.LookVector) <= 0 then
        return false;
    end;

    -- Screen check
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position);
    if not onScreen then
        return false;
    end;

    -- Distance check
    if screenPos.Z < 0 then
        return false;
    end;

    -- obstruction check
    local params = RaycastParams.new();
    params.FilterType = Enum.RaycastFilterType.Blacklist;
    params.FilterDescendantsInstances = { LocalPlayer.Character; };

    local result = workspace:Raycast(origin, (part.Position - origin), params);
    if not result then
        return false;
    end;

    -- hit must be part of the same model
    if result.Instance:IsDescendantOf(part.Parent) then
        return true;
    end;

    -- Accessory fallback
    if part.Parent:FindFirstChildWhichIsA("Accessory") then
        if result.Instance.Parent == part.Parent then
            return true;
        end;
    end;

    -- fallback around head
    local offsets = {
        Vector3.new(0, 0.75, 0);
        Vector3.new(0, -0.75, 0);
        Vector3.new(0.75, 0, 0);
        Vector3.new(-0.75, 0, 0);
    };

    for _, v in ipairs(offsets) do
        local testPos = part.Position + v;
        local result2 = workspace:Raycast(origin, (testPos - origin), params);
        if result2 and result2.Instance and result2.Instance:IsDescendantOf(part.Parent) then
            return true;
        end;
    end;

    return false;
end;


--// find target
local function GetTarget()
    local mousePos = UIS:GetMouseLocation();
    local best = nil;
    local bestScore = math.huge;

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character;
            if char then
                local head = char:FindFirstChild("Head") :: BasePart?;
                local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?;
                local part = head or hrp;

                if part then
                    local sp, onScreen = Camera:WorldToScreenPoint(part.Position);
                    if onScreen then
                        local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(sp.X, sp.Y)).Magnitude;

                        if dist < Assist.MaxDistance and dist < Assist.FOV then
                            if IsVisible(part) then
                                if dist < bestScore then
                                    bestScore = dist;
                                    best = part;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;

    return best;
end;

--// main soft-aim 
RunService.RenderStepped:Connect(function()
    if not Assist.Enabled then return end;

    if not MouseDown then return end;

    local target = GetTarget();
    if not target then return end;

    -- gentle pull toward target
    local camPos = Camera.CFrame.Position;
    local desired = CFrame.lookAt(camPos, target.Position);

    -- soft correction 
    Camera.CFrame = Camera.CFrame:Lerp(desired, Assist.Strength);
end);

--// UI Window
local win = library:CreateWindow("Aim Assist");

win:AddToggle({
    text = "Enable Aim Assist";
    state = false;
    flag = "assist_enable";
    callback = function(v)
        Assist.Enabled = v;
    end;
});

win:AddSlider({
    text = "Assist Strength";
    min = 0.01;
    max = 0.15;
    float = 0.01;
    value = Assist.Strength;
    flag = "assist_strength";
    callback = function(v)
        Assist.Strength = v;
    end;
});

win:AddSlider({
    text = "Assist FOV";
    min = 20;
    max = 300;
    float = 1;
    value = Assist.FOV;
    flag = "assist_fov";
    callback = function(v)
        Assist.FOV = v;
    end;
});

win:AddSlider({
    text = "Max Distance";
    min = 500;
    max = 3000;
    float = 1;
    value = Assist.MaxDistance;
    flag = "assist_dist";
    callback = function(v)
        Assist.MaxDistance = v;
    end;
});

library:Init();
