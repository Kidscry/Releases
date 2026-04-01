local player = game.Players.LocalPlayer;

while true do
    local map = workspace:WaitForChild("Map");
    local character = player.Character;
    local root = character and character:FindFirstChild("HumanoidRootPart");

    if root then
        for _, item in pairs(map:GetChildren()) do
            local prompt = item:FindFirstChild("Prompt");

            if prompt and prompt:IsA("ProximityPrompt") and prompt.ActionText == "Collect" then
                prompt.HoldDuration = 0;
                prompt.RequiresLineOfSight = false;

                while item and item.Parent do
                    prompt = item:FindFirstChild("Prompt");
                    if not prompt or not prompt.Enabled then
                        break;
                    end

                    root.CFrame = item.CFrame + Vector3.new(0, 4, 0);

                    task.wait(0.1);

                    pcall(function()
                        prompt:InputHoldBegin();
                        task.wait(0.2);
                        prompt:InputHoldEnd();
                    end);

                    task.wait(0.15);
                end

                task.wait(0.1);
            end
        end
    end

    task.wait(0.5);
end
