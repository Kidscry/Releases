while true do
    local map = workspace:WaitForChild("Map")
    local parts = {}

    for _, part in pairs(map:GetChildren()) do
        local prompt = part:FindFirstChild("Prompt")
        if prompt and prompt:IsA("ProximityPrompt") and prompt.ActionText == "Collect" then
            table.insert(parts, part)
        end
    end

    for _, part in pairs(parts) do
        local prompt = part:FindFirstChild("Prompt")
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                character:MoveTo(part.Position + Vector3.new(0, 5, 0))
                wait(math.random(0.05, 0.15))
                prompt:InputHoldBegin()
                wait(0.65)
                prompt:InputHoldEnd()
                wait(math.random(0.3, 0.6))
            end)
        end
        wait(0.1)
    end
end
