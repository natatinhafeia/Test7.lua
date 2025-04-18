local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variáveis
local AimbotEnabled = false
local ESPEnabled = false
local FOVEnabled = false
local RGBEnabled = false
local TargetPlayer = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 250)
Main.Position = UDim2.new(0.5, -110, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local DragLabel = Instance.new("TextLabel", Main)
DragLabel.Size = UDim2.new(1, 0, 0, 30)
DragLabel.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
DragLabel.Text = "by hixdow"
DragLabel.TextColor3 = Color3.new(1, 1, 1)
DragLabel.Font = Enum.Font.GothamBold
DragLabel.TextSize = 16

local function CreateButton(name, posY, callback)
    local Button = Instance.new("TextButton", Main)
    Button.Size = UDim2.new(0.9, 0, 0, 30)
    Button.Position = UDim2.new(0.05, 0, 0, posY)
    Button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    Button.TextColor3 = Color3.fromRGB(math.random(100,255), math.random(100,255), math.random(100,255))
    Button.Text = name
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- Botões
CreateButton("Toggle Aimbot", 40, function()
    AimbotEnabled = not AimbotEnabled
end)

CreateButton("Toggle ESP", 80, function()
    ESPEnabled = not ESPEnabled
end)

CreateButton("Toggle FOV", 120, function()
    FOVEnabled = not FOVEnabled
    if not FOVEnabled and FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
end)

CreateButton("Toggle RGB", 160, function()
    RGBEnabled = not RGBEnabled
end)

-- Desenho do FOV
local FOVCircle
local function DrawFOV()
    if FOVCircle then return end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 50
    FOVCircle.Radius = 100
    FOVCircle.Filled = false
end

-- ESP
local function DrawESP(player)
    local character = player.Character
    if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
        local head = character.Head
        local root = character.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            -- Nome
            local nameLabel = Drawing.new("Text")
            nameLabel.Text = player.Name
            nameLabel.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
            nameLabel.Size = 16
            nameLabel.Center = true
            nameLabel.Color = Color3.new(1, 1, 1)
            nameLabel.Outline = true
            nameLabel.Visible = true
            game:GetService("Debris"):AddItem(nameLabel, 0.1)

            -- Box
            local box = Drawing.new("Square")
            box.Size = Vector2.new(60, 100)
            local rootScreen, vis = Camera:WorldToViewportPoint(root.Position)
            box.Position = Vector2.new(rootScreen.X - 30, rootScreen.Y - 50)
            box.Color = Color3.fromRGB(255, 0, 0)
            box.Thickness = 2
            box.Transparency = 1
            box.Visible = true
            game:GetService("Debris"):AddItem(box, 0.1)

            -- Vida
            if character:FindFirstChildOfClass("Humanoid") then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local healthBar = Drawing.new("Text")
                healthBar.Text = "HP: " .. math.floor(humanoid.Health)
                healthBar.Position = Vector2.new(screenPos.X, screenPos.Y + 30)
                healthBar.Size = 14
                healthBar.Center = true
                healthBar.Color = Color3.fromRGB(0, 255, 0)
                healthBar.Outline = true
                healthBar.Visible = true
                game:GetService("Debris"):AddItem(healthBar, 0.1)
            end
        end
    end
end

-- Aimbot
local function FindTarget()
    local closest = nil
    local shortest = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPoint, visible = Camera:WorldToViewportPoint(head.Position)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if visible and distance < shortest and distance < 100 then
                closest = player
                shortest = distance
            end
        end
    end
    TargetPlayer = closest
end

local function Aimbot()
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
        local head = TargetPlayer.Character.Head
        local current = Camera.CFrame.Position
        local goal = head.Position
        local tween = TweenService:Create(Camera, TweenInfo.new(0.05), {CFrame = CFrame.new(current, goal)})
        tween:Play()
    end
end

-- RGB no personagem
task.spawn(function()
    while true do
        if RGBEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                end
            end
        end
        wait(0.1)
    end
end)

-- Loop principal
RunService.RenderStepped:Connect(function()
    if FOVEnabled then
        if not FOVCircle then DrawFOV() end
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                DrawESP(player)
            end
        end
    end

    if AimbotEnabled then
        FindTarget()
        Aimbot()
    else
        TargetPlayer = nil
    end
end)
