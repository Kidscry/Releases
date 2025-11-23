local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local startTime = os.clock()
local themeRed = Color3.fromRGB(255, 60, 60)

local gui = Instance.new("ScreenGui")
gui.Parent = game:GetService("CoreGui")
gui.Name = "Kidscry"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local container = Instance.new("Frame")
container.Parent = gui
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.Position = UDim2.fromScale(0.5, 0.5)
container.Size = UDim2.fromOffset(300, 80)
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
container.BackgroundTransparency = 0.15
container.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = container

local glow = Instance.new("ImageLabel")
glow.Parent = container
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Position = UDim2.fromScale(0.5, 0.5)
glow.Size = UDim2.new(1, 40, 1, 40)
glow.ZIndex = -1
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://4996891970"
glow.ImageTransparency = 0.55
glow.ImageColor3 = Color3.fromRGB(255, 70, 70)

local gradient = Instance.new("UIGradient")
gradient.Parent = container
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 22)),
}
gradient.Rotation = 90

local loadingText = Instance.new("TextLabel")
loadingText.Parent = container
loadingText.Size = UDim2.new(1, 0, 0, 24)
loadingText.Position = UDim2.fromOffset(0, 8)
loadingText.Text = "Loading..."
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.Font = Enum.Font.GothamBold
loadingText.TextSize = 18
loadingText.BackgroundTransparency = 1

local gameName = Instance.new("TextLabel")
gameName.Parent = container
gameName.Size = UDim2.new(1, 0, 0, 20)
gameName.Position = UDim2.fromOffset(0, 30)
gameName.Text = MarketplaceService:GetProductInfo(game.PlaceId).Name or "Game"
gameName.TextColor3 = Color3.fromRGB(180, 180, 180)
gameName.Font = Enum.Font.Gotham
gameName.TextSize = 13
gameName.BackgroundTransparency = 1

local barBackground = Instance.new("Frame")
barBackground.Parent = container
barBackground.Size = UDim2.new(0.9, 0, 0, 14)
barBackground.Position = UDim2.new(0.05, 0, 1, -24)
barBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
barBackground.BackgroundTransparency = 0.15
barBackground.BorderSizePixel = 0

local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(1, 0)
barBgCorner.Parent = barBackground

local bgGrad = Instance.new("UIGradient")
bgGrad.Parent = barBackground
bgGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 65)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 45)),
}
bgGrad.Rotation = 90

local barFill = Instance.new("Frame")
barFill.Parent = barBackground
barFill.Size = UDim2.fromOffset(0, 0)
barFill.Position = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = themeRed
barFill.BorderSizePixel = 0

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = barFill

local barGrad = Instance.new("UIGradient")
barGrad.Parent = barFill
barGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 50, 50)),
}
barGrad.Rotation = 90

function updateProgressBar(progress: number)
	progress = math.clamp(progress, 0, 1)
	local newHeight = 14 * progress

	TweenService:Create(
		barFill,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(1, 0, 0, newHeight),
			Position = UDim2.new(0, 0, 1 - progress, 0)
		}
	):Play()
end

function fadeOutAndDestroy()
	local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	local propsText = { TextTransparency = 1 }
	local propsBar = { BackgroundTransparency = 1 }

	TweenService:Create(loadingText, tweenInfo, propsText):Play()
	TweenService:Create(gameName, tweenInfo, propsText):Play()
	TweenService:Create(barBackground, tweenInfo, propsBar):Play()
	TweenService:Create(barFill, tweenInfo, propsBar):Play()
	TweenService:Create(glow, tweenInfo, { ImageTransparency = 1 }):Play()

	task.delay(0.4, function()
		TweenService:Create(container, tweenInfo, {
			BackgroundTransparency = 1,
			Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, 0),
		}):Play()

		task.delay(0.6, function()
			gui:Destroy()
		end)
	end)
end

function finishLoading(elapsed: number)
	updateProgressBar(1)
	loadingText.Text = string.format("Loaded in %.2f seconds", elapsed)
	task.wait(1)

	local playerName = Players.LocalPlayer and Players.LocalPlayer.Name or "Player"
	loadingText.Text = "Welcome, " .. playerName
	task.wait(2)

	fadeOutAndDestroy()
end

if game:IsLoaded() then
	finishLoading(0)
else
	local progress = 0
	local loadingComplete = false
	updateProgressBar(0)

	local conn
	conn = RunService.Heartbeat:Connect(function(dt: number)
		if loadingComplete then
			conn:Disconnect()
			return
		end

		progress = math.min(progress + dt * 0.5, 0.95)
		updateProgressBar(progress)
	end)

	game.Loaded:Connect(function()
		loadingComplete = true
		local elapsed = os.clock() - startTime
		finishLoading(elapsed)
	end)
end

task.wait(1.5)
