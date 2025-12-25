local function findAndTriggerPrompts()
    local mapFolder = workspace:WaitForChild("Map")
    local partsToVisit = {}

    for _, part in pairs(mapFolder:GetChildren()) do
        local prompt = part:FindFirstChild("Prompt")

        if prompt and prompt:IsA("ProximityPrompt") then
            if prompt.ActionText == "Collect" then
                table.insert(partsToVisit, part)
            end
        end
    end

    local function fireProximity(prompt)
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(1)
            prompt:InputHoldEnd()
        end)
    end

    local function triggerNextPrompt()
        if #partsToVisit > 0 then
            local part = table.remove(partsToVisit, 1)
            local prompt = part:FindFirstChild("Prompt")

            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character:MoveTo(part.Position + Vector3.new(0, 5, 0))

                task.wait(0.1)

                fireProximity(prompt)

                task.wait(1)
                triggerNextPrompt()
            end
        end
    end

    triggerNextPrompt()
end

findAndTriggerPrompts()
