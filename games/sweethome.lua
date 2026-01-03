local map = workspace:WaitForChild("Map")
local parts = {}

for _, part in pairs(map:GetChildren()) do
    local prompt = part:FindFirstChild("Prompt")
    if prompt and prompt:IsA("ProximityPrompt") and prompt.ActionText == "Collect" then
        table.insert(parts, part)
    end
end

local function firePrompt(prompt)
    pcall(function()
        prompt:InputHoldBegin()
        wait(0.5)
        prompt:InputHoldEnd()
    end)
end

local function triggerPrompt()
    if #parts > 0 then
        local part = table.remove(parts, 1)
        local prompt = part:FindFirstChild("Prompt")
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character:MoveTo(part.Position + Vector3.new(0, 5, 0))
            wait(math.random(0.1, 0.15))
            firePrompt(prompt)
            wait(math.random(0.5, 0.6))
            triggerPrompt()
        end
    end
end

triggerPrompt()
