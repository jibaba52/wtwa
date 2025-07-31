-- Remastered Goofy Scripts GUI with fixes
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Auto-refresh character reference on respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
end)

-- Prevent GUI duplication
if player:FindFirstChild("PlayerGui"):FindFirstChild("GoofyScriptsGui") then
    player.PlayerGui.GoofyScriptsGui:Destroy()
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "GoofyScriptsGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Popup Text
local popup = Instance.new("TextLabel")
popup.Size = UDim2.new(0, 300, 0, 50)
popup.Position = UDim2.new(0.5, -150, 0.4, 0)
popup.BackgroundTransparency = 0.5
popup.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
popup.TextColor3 = Color3.new(1, 1, 1)
popup.Font = Enum.Font.GothamBold
popup.TextSize = 40
popup.Text = "GOOFY SCRIPTS"
popup.ZIndex = 10
popup.Parent = gui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 200)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 5
mainFrame.Parent = gui

-- UI Styling
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(80, 80, 80)

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local layout = Instance.new("UIListLayout", mainFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

-- Toggle Utility
local function createToggle(name, parent, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 52, 0, 22)
    toggle.Position = UDim2.new(1, -57, 0, 4)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.Text = "Off"
    toggle.Font = Enum.Font.GothamSemibold
    toggle.TextSize = 14
    toggle.TextColor3 = Color3.new(1, 0, 0)
    toggle.Parent = frame

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "On" or "Off"
        toggle.TextColor3 = state and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        toggle.BackgroundColor3 = state and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)

    return frame
end

-- Speed Slider
local speedValue = 16
local function createSpeedSlider(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = "Speed"
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 20)
    sliderFrame.Position = UDim2.new(0, 5, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame

    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new(0.25, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

    local knob = Instance.new("TextButton", sliderFrame)
    knob.Size = UDim2.new(0, 14, 1, 0)
    knob.Position = UDim2.new(0.25, -7, 0, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.ZIndex = 10

    local dragging = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local x = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
            local ratio = x / sliderFrame.AbsoluteSize.X
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            knob.Position = UDim2.new(ratio, -7, 0, 0)
            speedValue = math.floor(16 + ratio * 64)
            label.Text = "Speed: " .. speedValue
            if speedEnabled then humanoid.WalkSpeed = speedValue end
        end
    end)

    return frame
end

-- States
local speedEnabled = false
local espEnabled = false
local flyEnabled = false
local flying = false
local espBoxes = {}

-- UI Elements
createToggle("Speedhack", mainFrame, function(state)
    speedEnabled = state
    humanoid.WalkSpeed = state and speedValue or 16
end)

mainFrame:AddChild(createSpeedSlider(mainFrame))

createToggle("Flyhack", mainFrame, function(state)
    flyEnabled = state
    if not character:FindFirstChild("HumanoidRootPart") then return end
    flying = state
    humanoid.PlatformStand = state
    if state then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent = character.HumanoidRootPart

        RunService:BindToRenderStep("FlyHack", Enum.RenderPriority.Character.Value + 1, function()
            if not flying then return end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            character.HumanoidRootPart:FindFirstChild("FlyVelocity").Velocity = dir.Magnitude > 0 and dir.Unit * 50 or Vector3.zero
        end)
    else
        RunService:UnbindFromRenderStep("FlyHack")
        local bv = character.HumanoidRootPart:FindFirstChild("FlyVelocity")
        if bv then bv:Destroy() end
    end
end)

createToggle("Player ESP", mainFrame, function(state)
    espEnabled = state
    if not state then
        for _, box in pairs(espBoxes) do box:Destroy() end
        espBoxes = {}
    end
end)

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if not espBoxes[plr] then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = Vector3.new(4,6,1)
                    box.Adornee = plr.Character.HumanoidRootPart
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Color3 = Color3.fromRGB(0,255,0)
                    box.Transparency = 0.5
                    box.Parent = workspace
                    espBoxes[plr] = box
                end
            elseif espBoxes[plr] then
                espBoxes[plr]:Destroy()
                espBoxes[plr] = nil
            end
        end
    end
end)

-- Fade out popup and show main GUI
spawn(function()
    wait(2)
    for i = 1, 20 do
        popup.TextTransparency = math.clamp(popup.TextTransparency + 0.05, 0, 1)
        popup.BackgroundTransparency = math.clamp(popup.BackgroundTransparency + 0.025, 0, 1)
        wait(0.05)
    end
    popup:Destroy()
    if mainFrame then
        mainFrame.Visible = true
        print("Main GUI is now visible")
    else
        warn("mainFrame is nil!")
    end
end)

-- Drag Logic
local dragging, dragInput, dragStart, startPos = false
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

