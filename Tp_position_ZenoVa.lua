local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local AimbotGUI = Instance.new("ScreenGui")
local Background = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local Divider = Instance.new("Frame")
local MinMaxBtn = Instance.new("TextButton")
local ContentFrame = Instance.new("ScrollingFrame") -- Pake scrolling biar muat banyak input

-- --- Data Variables ---
local tpPositions = {"", "", "", ""}
local delayTime = 5
local autoTPActive = false
local hue = 0

-- --- Main GUI Setup ---
AimbotGUI.Name = "ZenoVa_TP_System"
AimbotGUI.ResetOnSpawn = false
AimbotGUI.Parent = lp:WaitForChild("PlayerGui")

Background.Name = "Background"
Background.Parent = AimbotGUI
Background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Background.Position = UDim2.new(0.5, -85, 0.5, -150)
Background.Size = UDim2.new(0, 170, 0, 320)
Background.Active = true
Background.Draggable = true

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Background

-- --- Header ---
Title.Name = "Title"
Title.Parent = Background
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Size = UDim2.new(1, -40, 0, 20)
Title.Font = Enum.Font.GothamBold
Title.Text = "ZenoVa | TP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

MinMaxBtn.Name = "MinMaxBtn"
MinMaxBtn.Parent = Background
MinMaxBtn.BackgroundTransparency = 1
MinMaxBtn.Position = UDim2.new(1, -25, 0, 5)
MinMaxBtn.Size = UDim2.new(0, 20, 0, 20)
MinMaxBtn.Font = Enum.Font.GothamBold
MinMaxBtn.Text = "[-]"
MinMaxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

Divider.Name = "Divider"
Divider.Parent = Background
Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0, 0, 0, 30)
Divider.Size = UDim2.new(1, 0, 0, 1)

ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = Background
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 5, 0, 35)
ContentFrame.Size = UDim2.new(1, -10, 1, -45)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
ContentFrame.ScrollBarThickness = 2

local function createInput(name, placeholder, yPos)
    local box = Instance.new("TextBox")
    box.Name = name
    box.Parent = ContentFrame
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    box.Position = UDim2.new(0, 5, 0, yPos)
    box.Size = UDim2.new(1, -10, 0, 25)
    box.Font = Enum.Font.Gotham
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 10
    local corner = Instance.new("UICorner", box)
    corner.CornerRadius = UDim.new(0, 4)
    return box
end

local function createBtn(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Parent = ContentFrame
    btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 45)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    return btn
end

-- --- UI Elements ---
local posInputs = {}
for i = 1, 4 do
    local label = Instance.new("TextLabel", ContentFrame)
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Position = UDim2.new(0, 5, 0, (i-1)*55)
    label.BackgroundTransparency = 1
    label.Text = "Position " .. i
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left

    posInputs[i] = createInput("Pos"..i, "Paste X, Y, Z here...", (i-1)*55 + 18)
end

local copyPosBtn = createBtn("📍 COPY CURRENT POSITION", 225, Color3.fromRGB(70, 100, 140))
local delayInput = createInput("DelayInput", "Delay (seconds)... Default: 5", 265)
local startBtn = createBtn("START AUTO TELEPORT: OFF", 300, Color3.fromRGB(150, 50, 50))

local currentPosLabel = Instance.new("TextLabel", ContentFrame)
currentPosLabel.Size = UDim2.new(1, 0, 0, 20)
currentPosLabel.Position = UDim2.new(0, 0, 0, 340)
currentPosLabel.BackgroundTransparency = 1
currentPosLabel.Text = "X:0 Y:0 Z:0"
currentPosLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
currentPosLabel.Font = Enum.Font.Code
currentPosLabel.TextSize = 9

-- --- Core Logic ---

-- Update Position Label
task.spawn(function()
    while task.wait(0.2) do
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local p = lp.Character.HumanoidRootPart.Position
            currentPosLabel.Text = string.format("LIVE POS: %.1f, %.1f, %.1f", p.X, p.Y, p.Z)
        end
    end
end)

-- Copy Position Function
copyPosBtn.MouseButton1Click:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local p = lp.Character.HumanoidRootPart.Position
        local text = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
        
        if setclipboard then setclipboard(text) end
        copyPosBtn.Text = "✔ COPIED TO CLIPBOARD!"
        task.wait(1)
        copyPosBtn.Text = "📍 COPY CURRENT POSITION"
    end
end)

-- Delay Input Logic
delayInput.FocusLost:Connect(function()
    local val = tonumber(delayInput.Text)
    if val then delayTime = val end
end)

-- Start/Stop Auto TP
startBtn.MouseButton1Click:Connect(function()
    autoTPActive = not autoTPActive
    startBtn.Text = autoTPActive and "START AUTO TELEPORT: ON" or "START AUTO TELEPORT: OFF"
    startBtn.BackgroundColor3 = autoTPActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    
    if autoTPActive then
        task.spawn(function()
            while autoTPActive do
                for i = 1, 4 do
                    if not autoTPActive then break end
                    
                    local rawText = posInputs[i].Text
                    if rawText ~= "" then
                        -- Parsing string ke Vector3
                        local coords = {}
                        for word in string.gmatch(rawText:gsub("|", ","), "[%-?%.%d]+") do
                            table.insert(coords, tonumber(word))
                        end
                        
                        if #coords >= 3 then
                            local targetPos = Vector3.new(coords[1], coords[2], coords[3])
                            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                lp.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                            end
                            task.wait(delayTime)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- --- Rainbow & Minimize ---
RunService.RenderStepped:Connect(function()
    hue = (hue + 0.5/360) % 1
    Title.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
    Divider.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 1)
end)

local isMin = false
MinMaxBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Background.Size = isMin and UDim2.new(0, 170, 0, 30) or UDim2.new(0, 170, 0, 320)
    ContentFrame.Visible = not isMin
    MinMaxBtn.Text = isMin and "[+]" or "[-]"
end)
