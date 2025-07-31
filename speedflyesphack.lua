-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local mouse = player:GetMouse()

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GoofyScriptsGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- TextLabel for "GOOFY SCRIPTS" popup
local popupText = Instance.new("TextLabel")
popupText.Size = UDim2.new(0, 300, 0, 50)
popupText.Position = UDim2.new(0.5, -150, 0.4, 0)
popupText.BackgroundTransparency = 0.5
popupText.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
popupText.TextColor3 = Color3.new(1, 1, 1)
popupText.Font = Enum.Font.GothamBold
popupText.TextSize = 40
popupText.Text = "GOOFY SCRIPTS"
popupText.Parent = ScreenGui
popupText.ZIndex = 10

-- Main GUI Frame (based on the reference image style)
local guiFrame = Instance.new("Frame")
guiFrame.Size = UDim2.new(0, 280, 0, 180)
guiFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
guiFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
guiFrame.BorderSizePixel = 0
guiFrame.Visible = false
guiFrame.Parent = ScreenGui
guiFrame.ZIndex = 5
guiFrame.ClipsDescendants = true

-- UIStroke for border (like in image)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Parent = guiFrame

-- UIListLayout for vertical layout
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.Parent = guiFrame
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Function to create toggle buttons
local function createToggle(name, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 5, 0, 0)
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

    local toggled = false

    toggle.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            toggle.Text = "On"
            toggle.TextColor3 = Color3.new(0, 1, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        else
            toggle.Text = "Off"
            toggle.TextColor3 = Color3.new(1, 0, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
        frame:SetAttribute("Toggled", toggled)
    end)

    frame:SetAttribute("Toggled", false)
    return frame
end

-- Speed slider UI
local function createSpeedSlider(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 2
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = "Speed"
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 20)
    sliderFrame.Position = UDim2.new(0, 5, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.Parent = frame
    sliderFrame.ClipsDescendants = true
    sliderFrame.BorderSizePixel = 0
    sliderFrame.AnchorPoint = Vector2.new(0, 0)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.Parent = sliderFrame

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 14, 1, 0)
    sliderButton.Position = UDim2.new(0.5, -7, 0, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    sliderButton.Parent = sliderFrame
    sliderButton.AutoButtonColor = false
    sliderButton.ZIndex = 10
    sliderButton.Modal = true

    local speedValue = 16 -- default walk speed
    local dragging = false

    local function updateSlider(inputPosX)
        local relativePos = math.clamp(inputPosX - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
        local scale = relativePos / sliderFrame.AbsoluteSize.X
        sliderFill.Size = UDim2.new(scale, 0, 1, 0)
        sliderButton.Position = UDim2.new(scale, -7, 0, 0)
        speedValue = math.floor(16 + scale * 64) -- range: 16 to 80
        label.Text = "Speed: "..speedValue
        if speedHackEnabled then
            humanoid.WalkSpeed = speedValue
        end
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)

    return frame, function() return speedValue end
end

-- Add toggles and slider to GUI
local speedToggleFrame = createToggle("Speedhack", guiFrame)
speedToggleFrame.LayoutOrder = 1
local speedHackEnabled = false

local speedSliderFrame, getSpeedValue = createSpeedSlider(guiFrame)
speedSliderFrame.LayoutOrder = 2

local flyToggleFrame = createToggle("Flyhack", guiFrame)
flyToggleFrame.LayoutOrder = 3
local flyHackEnabled = false

local espToggleFrame = createToggle("Player ESP", guiFrame)
espToggleFrame.LayoutOrder = 4
local espHackEnabled = false

-- Moveable GUI logic
local draggingGui = false
local dragInput, dragStart, startPos

guiFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingGui = true
        dragStart = input.Position
        startPos = guiFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingGui = false
            end
        end)
    end
end)

guiFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and draggingGui then
        local delta = input.Position - dragStart
        guiFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Speedhack logic
speedToggleFrame:GetAttributeChangedSignal("Toggled"):Connect(function()
    speedHackEnabled = speedToggleFrame:GetAttribute("Toggled")
    if speedHackEnabled then
        humanoid.WalkSpeed = getSpeedValue()
    else
        humanoid.WalkSpeed = 16
    end
end)

-- Flyhack logic
local flying = false
local flySpeed = 50
local bodyVelocity

flyToggleFrame:GetAttributeChangedSignal("Toggled"):Connect(function()
    flyHackEnabled = flyToggleFrame:GetAttribute("Toggled")
    if flyHackEnabled then
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        flying = true
        humanoid.PlatformStand = true

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.Parent = character.HumanoidRootPart

        RunService:BindToRenderStep("FlyHack", Enum.RenderPriority.Character.Value + 1, function()
            if flying and character and character:FindFirstChild("HumanoidRootPart") then
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir = moveDir + Vector3.new(0,1,0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDir = moveDir - Vector3.new(0,1,0)
                end
                if moveDir.Magnitude > 0 then
                    bodyVelocity.Velocity = moveDir.Unit * flySpeed
                else
                    bodyVelocity.Velocity = Vector3.new(0,0,0)
                end
            end
        end)
    else
        flying = false
        humanoid.PlatformStand = false
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        RunService:UnbindFromRenderStep("FlyHack")
    end
end)

-- Player ESP logic
local espBoxes = {}

local function createEspBox(plr)
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = Vector3.new(4, 6, 1)
    box.Color3 = Color3.fromRGB(0, 255, 0)
    box.Transparency = 0.5
    box.Parent = workspace
    return box
end

local function updateEsp()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if espHackEnabled then
                if not espBoxes[plr] then
                    espBoxes[plr] = createEspBox(plr)
                end
                espBoxes[plr].Adornee = plr.Character.HumanoidRootPart
            else
                if espBoxes[plr] then
                    espBoxes[plr]:Destroy()
                    espBoxes[plr] = nil
                end
            end
        elseif espBoxes[plr] then
            espBoxes[plr]:Destroy()
            espBoxes[plr] = nil
        end
    end
end

espToggleFrame:GetAttributeChangedSignal("Toggled"):Connect(function()
    espHackEnabled = espToggleFrame:GetAttribute("Toggled")
    if not espHackEnabled then
        for _, box in pairs(espBoxes) do
            box:Destroy()
        end
        espBoxes = {}
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        wait(1)
        updateEsp()
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if espBoxes[plr] then
        espBoxes[plr]:Destroy()
        espBoxes[plr] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if espHackEnabled then
        updateEsp()
    end
end)

-- Corrected popup fade and GUI show
spawn(function()
    wait(2)
    for i = 1, 20 do
        popupText.TextTransparency = popupText.TextTransparency + 0.05
        popupText.BackgroundTransparency = popupText.BackgroundTransparency + 0.05
        wait(0.05)
    end
    popupText:Destroy()
    guiFrame.Visible = true -- Move this here to ensure it shows after popup disappears
end)
