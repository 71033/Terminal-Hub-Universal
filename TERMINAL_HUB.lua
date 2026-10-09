-- [[ HACKER TERMINAL HUB - FIXED MOUSE & CAMERA CONFLICTS ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Локальная маскировка собственного ника.
-- Меняется только на этом клиенте: другие игроки продолжают видеть настоящий ник.
local HIDDEN_LOCAL_NAME = "???"
local localNameConnection = nil

local function hideOwnName(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character and character:WaitForChild("Humanoid", 5)
    end
    if humanoid then
        humanoid.DisplayName = HIDDEN_LOCAL_NAME
    end
end

if LocalPlayer.Character then
    task.defer(hideOwnName, LocalPlayer.Character)
end

localNameConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    task.defer(hideOwnName, character)
end)

-- Жесткая очистка старых копий
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "HackerTerminalHub" then
        v:Destroy()
    end
end

-- Создание главного контейнера
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerTerminalHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главное окно терминала
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(35, 35, 35)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Функция плавной анимации
local isOpen = true
local animTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function toggleMenu()
    isOpen = not isOpen
    if isOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(MainFrame, animTweenInfo, {
            Size = UDim2.new(0, 480, 0, 360),
            Position = UDim2.new(0.5, -240, 0.5, -180)
        }):Play()
    else
        local tween = TweenService:Create(MainFrame, animTweenInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        if not isOpen then
            MainFrame.Visible = false
            MainFrame.Size = UDim2.new(0, 480, 0, 360)
            MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and (input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt) then
        toggleMenu()
    end
end)

-- Шапка терминала
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -45, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
TitleLabel.Text = "> TERMINAL_HUB // by 71033"
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 1, 0)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.AutoButtonColor = false
CloseButton.TextColor3 = Color3.fromRGB(200, 80, 80)
CloseButton.Text = "[X]"
CloseButton.TextSize = 13
CloseButton.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
CloseButton.Parent = TopBar

local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, tweenInfo, {TextColor3 = Color3.fromRGB(255, 120, 120)}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, tweenInfo, {TextColor3 = Color3.fromRGB(200, 80, 80)}):Play()
end)
CloseButton.MouseButton1Click:Connect(function()
    if isOpen then toggleMenu() end
end)

-- Перетаскивание окна
local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = UDim2.new(0, 0, 0, 0)

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = MainFrame.Position
        
        local connection
        connection = UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if connection then connection:Disconnect() end
            end
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local currentMouse = UserInputService:GetMouseLocation()
        local delta = currentMouse - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Вкладки
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 42)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 8)
TabListLayout.Parent = TabBar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -85)
ContentContainer.Position = UDim2.new(0, 10, 0, 78)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local function createTabContent()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    sf.Visible = false
    sf.Parent = ContentContainer

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 6)
    padding.Parent = sf

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = sf

    return sf
end

local Tabs = {
    PLAYER = createTabContent(),
    VISUAL = createTabContent(),
    SETTINGS = createTabContent()
}

local tabButtons = {}
local function createTabButton(name, order)
    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(0, 146, 1, 0)
    tBtn.LayoutOrder = order
    tBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    tBtn.AutoButtonColor = false
    tBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    tBtn.Text = "[ " .. name .. " ]"
    tBtn.TextSize = 13
    tBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    tBtn.Parent = TabBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tBtn
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 35, 35)
    stroke.Thickness = 1
    stroke.Parent = tBtn

    tabButtons[name] = {Button = tBtn, Stroke = stroke}
    return tBtn
end

local function switchTab(tabName)
    for name, tabObj in pairs(Tabs) do tabObj.Visible = (name == tabName) end
    for name, data in pairs(tabButtons) do
        if name == tabName then
            TweenService:Create(data.Button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(15, 30, 20), TextColor3 = Color3.fromRGB(0, 170, 80)}):Play()
            TweenService:Create(data.Stroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80), Thickness = 1.2}):Play()
        else
            TweenService:Create(data.Button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(16, 16, 16), TextColor3 = Color3.fromRGB(140, 140, 140)}):Play()
            TweenService:Create(data.Stroke, tweenInfo, {Color = Color3.fromRGB(35, 35, 35), Thickness = 1}):Play()
        end
    end
end

createTabButton("PLAYER", 1).MouseButton1Click:Connect(function() switchTab("PLAYER") end)
createTabButton("VISUAL", 2).MouseButton1Click:Connect(function() switchTab("VISUAL") end)
createTabButton("SETTINGS", 3).MouseButton1Click:Connect(function() switchTab("SETTINGS") end)

-- UI Шаблоны
local function createToggleInputControl(tabName, name, defaultVal, order, callback)
    local targetTab = Tabs[tabName]
    if not targetTab then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.LayoutOrder = order
    row.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    row.Parent = targetTab

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = Color3.fromRGB(35, 35, 35)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -155, 0, 38)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.Text = "[ > ] " .. name
    title.TextSize = 13
    title.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local valBox = Instance.new("TextBox")
    valBox.Size = UDim2.new(0, 42, 0, 24)
    valBox.Position = UDim2.new(1, -142, 0.5, -12)
    valBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    valBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    valBox.Text = tostring(defaultVal)
    valBox.TextSize = 12
    valBox.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    valBox.ClearTextOnFocus = false
    valBox.Parent = row
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", valBox).Color = Color3.fromRGB(40, 40, 40)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 78, 0, 22)
    toggleBtn.Position = UDim2.new(1, -88, 0, 7)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    toggleBtn.TextColor3 = Color3.fromRGB(180, 55, 55)
    toggleBtn.Text = "[OFF]"
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    toggleBtn.Parent = row
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = Color3.fromRGB(0, 0, 0)

    local enabled = false
    local function updateValue() callback(enabled, tonumber(valBox.Text) or defaultVal) end

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            toggleBtn.Text = "[ON]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(15, 30, 20)}):Play()
            TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80), Thickness = 1.2}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 45, 28), TextColor3 = Color3.fromRGB(0, 170, 80)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80)}):Play()
        else
            toggleBtn.Text = "[OFF]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}):Play()
            TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(35, 35, 35), Thickness = 1}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(12, 12, 12), TextColor3 = Color3.fromRGB(180, 55, 55)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 0, 0)}):Play()
        end
        updateValue()
    end)
    valBox.FocusLost:Connect(updateValue)
    return row
end

local function createToggleControl(tabName, name, order, callback)
    local targetTab = Tabs[tabName]
    if not targetTab then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.LayoutOrder = order
    row.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    row.Parent = targetTab

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = Color3.fromRGB(35, 35, 35)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -110, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.Text = "[ > ] " .. name
    title.TextSize = 13
    title.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 78, 0, 22)
    toggleBtn.Position = UDim2.new(1, -94, 0.5, -12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    toggleBtn.TextColor3 = Color3.fromRGB(180, 55, 55)
    toggleBtn.Text = "[OFF]"
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    toggleBtn.Parent = row
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = Color3.fromRGB(0, 0, 0)

    local enabled = false
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            toggleBtn.Text = "[ON]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(15, 30, 20)}):Play()
            TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80), Thickness = 1.2}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 45, 28), TextColor3 = Color3.fromRGB(0, 170, 80)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80)}):Play()
        else
            toggleBtn.Text = "[OFF]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}):Play()
            TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(35, 35, 35), Thickness = 1}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(12, 12, 12), TextColor3 = Color3.fromRGB(180, 55, 55)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 0, 0)}):Play()
        end
        callback(enabled)
    end)
    return row
end

local function createHackerButtonCard(tabName, name, order, callback)
    local targetTab = Tabs[tabName]
    if not targetTab then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.LayoutOrder = order
    row.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    row.Parent = targetTab

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = Color3.fromRGB(35, 35, 35)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -110, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.Text = "[ > ] " .. name
    title.TextSize = 13
    title.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 88, 0, 24)
    btn.Position = UDim2.new(1, -94, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    btn.TextColor3 = Color3.fromRGB(140, 140, 140)
    btn.Text = "[OPEN]"
    btn.TextSize = 12
    btn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Color3.fromRGB(40, 40, 40)

    btn.MouseButton1Click:Connect(callback)
    return row
end

-- ==========================================
-- СПЕЦИАЛЬНЫЕ БЕЗИНСТРУМЕНТАЛЬНЫЕ КОНТРОЛЛЕРЫ
-- ==========================================
local updateVectorsUI = nil

local function createVectorAnchorsControl(tabName, order, onToggle, onRedSet, onBlueSet, onRedTp, onBlueTp)
    local targetTab = Tabs[tabName]
    if not targetTab then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 118)
    row.LayoutOrder = order
    row.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    row.Parent = targetTab

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = Color3.fromRGB(38, 38, 38)
    stroke.Thickness = 1

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 0, 30)
    title.Position = UDim2.new(0, 14, 0, 3)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(215, 215, 215)
    title.Text = "[ > ] VECTOR_ANCHORS"
    title.TextSize = 13
    title.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -120, 0, 16)
    subtitle.Position = UDim2.new(0, 15, 0, 25)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = Color3.fromRGB(95, 95, 95)
    subtitle.Text = "SAVE TWO POINTS • TELEPORT BETWEEN THEM"
    subtitle.TextSize = 8
    subtitle.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = row

    -- Главный переключатель
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 82, 0, 25)
    toggleBtn.Position = UDim2.new(1, -94, 0, 8)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    toggleBtn.TextColor3 = Color3.fromRGB(180, 55, 55)
    toggleBtn.Text = "[OFF]"
    toggleBtn.TextSize = 11
    toggleBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    toggleBtn.Parent = row
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 5)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = Color3.fromRGB(0, 0, 0)
    tStroke.Thickness = 1.2

    -- Красная колонка
    local redCard = Instance.new("Frame")
    redCard.Size = UDim2.new(0.5, -10, 0, 48)
    redCard.Position = UDim2.new(0, 7, 0, 57)
    redCard.BackgroundColor3 = Color3.fromRGB(22, 13, 13)
    redCard.Parent = row
    Instance.new("UICorner", redCard).CornerRadius = UDim.new(0, 6)
    local redCardStroke = Instance.new("UIStroke", redCard)
    redCardStroke.Color = Color3.fromRGB(75, 30, 30)

    local redLabel = Instance.new("TextLabel")
    redLabel.Size = UDim2.new(0, 62, 0, 16)
    redLabel.Position = UDim2.new(0, 9, 0, 5)
    redLabel.BackgroundTransparency = 1
    redLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
    redLabel.Text = "RED"
    redLabel.TextSize = 10
    redLabel.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    redLabel.TextXAlignment = Enum.TextXAlignment.Left
    redLabel.Parent = redCard

    local redStatus = Instance.new("TextLabel")
    redStatus.Size = UDim2.new(0, 90, 0, 16)
    redStatus.Position = UDim2.new(0, 9, 0, 25)
    redStatus.BackgroundTransparency = 1
    redStatus.TextColor3 = Color3.fromRGB(120, 55, 55)
    redStatus.Text = "● NOT SET"
    redStatus.TextSize = 8
    redStatus.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    redStatus.TextXAlignment = Enum.TextXAlignment.Left
    redStatus.Parent = redCard

    local redSetBtn = Instance.new("TextButton")
    redSetBtn.Size = UDim2.new(0, 62, 0, 25)
    redSetBtn.Position = UDim2.new(1, -132, 0, 6)
    redSetBtn.BackgroundColor3 = Color3.fromRGB(31, 16, 16)
    redSetBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    redSetBtn.Text = "SET"
    redSetBtn.TextSize = 9
    redSetBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    redSetBtn.Parent = redCard
    Instance.new("UICorner", redSetBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", redSetBtn).Color = Color3.fromRGB(90, 35, 35)

    local redTpBtn = Instance.new("TextButton")
    redTpBtn.Size = UDim2.new(0, 62, 0, 25)
    redTpBtn.Position = UDim2.new(1, -65, 0, 6)
    redTpBtn.BackgroundColor3 = Color3.fromRGB(31, 16, 16)
    redTpBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    redTpBtn.Text = "TP"
    redTpBtn.TextSize = 9
    redTpBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    redTpBtn.Parent = redCard
    Instance.new("UICorner", redTpBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", redTpBtn).Color = Color3.fromRGB(90, 35, 35)

    -- Синяя колонка
    local blueCard = Instance.new("Frame")
    blueCard.Size = UDim2.new(0.5, -10, 0, 48)
    blueCard.Position = UDim2.new(0.5, 3, 0, 57)
    blueCard.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
    blueCard.Parent = row
    Instance.new("UICorner", blueCard).CornerRadius = UDim.new(0, 6)
    local blueCardStroke = Instance.new("UIStroke", blueCard)
    blueCardStroke.Color = Color3.fromRGB(30, 50, 80)

    local blueLabel = Instance.new("TextLabel")
    blueLabel.Size = UDim2.new(0, 62, 0, 16)
    blueLabel.Position = UDim2.new(0, 9, 0, 5)
    blueLabel.BackgroundTransparency = 1
    blueLabel.TextColor3 = Color3.fromRGB(90, 160, 255)
    blueLabel.Text = "BLUE"
    blueLabel.TextSize = 10
    blueLabel.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    blueLabel.TextXAlignment = Enum.TextXAlignment.Left
    blueLabel.Parent = blueCard

    local blueStatus = Instance.new("TextLabel")
    blueStatus.Size = UDim2.new(0, 90, 0, 16)
    blueStatus.Position = UDim2.new(0, 9, 0, 25)
    blueStatus.BackgroundTransparency = 1
    blueStatus.TextColor3 = Color3.fromRGB(120, 55, 55)
    blueStatus.Text = "● NOT SET"
    blueStatus.TextSize = 8
    blueStatus.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    blueStatus.TextXAlignment = Enum.TextXAlignment.Left
    blueStatus.Parent = blueCard

    local blueSetBtn = Instance.new("TextButton")
    blueSetBtn.Size = UDim2.new(0, 62, 0, 25)
    blueSetBtn.Position = UDim2.new(1, -132, 0, 6)
    blueSetBtn.BackgroundColor3 = Color3.fromRGB(15, 22, 32)
    blueSetBtn.TextColor3 = Color3.fromRGB(100, 170, 255)
    blueSetBtn.Text = "SET"
    blueSetBtn.TextSize = 9
    blueSetBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    blueSetBtn.Parent = blueCard
    Instance.new("UICorner", blueSetBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", blueSetBtn).Color = Color3.fromRGB(35, 60, 95)

    local blueTpBtn = Instance.new("TextButton")
    blueTpBtn.Size = UDim2.new(0, 62, 0, 25)
    blueTpBtn.Position = UDim2.new(1, -65, 0, 6)
    blueTpBtn.BackgroundColor3 = Color3.fromRGB(15, 22, 32)
    blueTpBtn.TextColor3 = Color3.fromRGB(100, 170, 255)
    blueTpBtn.Text = "TP"
    blueTpBtn.TextSize = 9
    blueTpBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    blueTpBtn.Parent = blueCard
    Instance.new("UICorner", blueTpBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", blueTpBtn).Color = Color3.fromRGB(35, 60, 95)

    local function updateStatus(isRedSet, isBlueSet)
        if isRedSet then
            redStatus.Text = "● LINKED"
            redStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
        else
            redStatus.Text = "● NOT SET"
            redStatus.TextColor3 = Color3.fromRGB(120, 55, 55)
        end

        if isBlueSet then
            blueStatus.Text = "● LINKED"
            blueStatus.TextColor3 = Color3.fromRGB(90, 160, 255)
        else
            blueStatus.Text = "● NOT SET"
            blueStatus.TextColor3 = Color3.fromRGB(120, 55, 55)
        end
    end

    updateVectorsUI = updateStatus

    local enabled = false

    -- Управление активностью нижних кнопок.
    local function setAnchorButtonsActive(active)
        redSetBtn.Active = active
        redSetBtn.AutoButtonColor = active
        redSetBtn.TextTransparency = active and 0 or 0.45
        redSetBtn.BackgroundTransparency = active and 0 or 0.35

        redTpBtn.Active = active
        redTpBtn.AutoButtonColor = active
        redTpBtn.TextTransparency = active and 0 or 0.45
        redTpBtn.BackgroundTransparency = active and 0 or 0.35

        blueSetBtn.Active = active
        blueSetBtn.AutoButtonColor = active
        blueSetBtn.TextTransparency = active and 0 or 0.45
        blueSetBtn.BackgroundTransparency = active and 0 or 0.35

        blueTpBtn.Active = active
        blueTpBtn.AutoButtonColor = active
        blueTpBtn.TextTransparency = active and 0 or 0.45
        blueTpBtn.BackgroundTransparency = active and 0 or 0.35
    end

    setAnchorButtonsActive(false)

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled

        if enabled then
            setAnchorButtonsActive(true)
            toggleBtn.Text = "[ON]"
            TweenService:Create(row, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(14, 20, 17)
            }):Play()
            TweenService:Create(stroke, tweenInfo, {
                Color = Color3.fromRGB(0, 170, 80),
                Thickness = 1.2
            }):Play()
            TweenService:Create(toggleBtn, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(18, 40, 25),
                TextColor3 = Color3.fromRGB(0, 190, 90)
            }):Play()
            TweenService:Create(tStroke, tweenInfo, {
                Color = Color3.fromRGB(0, 170, 80)
            }):Play()
        else
            setAnchorButtonsActive(false)
            toggleBtn.Text = "[OFF]"
            TweenService:Create(row, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(14, 14, 14)
            }):Play()
            TweenService:Create(stroke, tweenInfo, {
                Color = Color3.fromRGB(38, 38, 38),
                Thickness = 1
            }):Play()
            TweenService:Create(toggleBtn, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                TextColor3 = Color3.fromRGB(180, 55, 55)
            }):Play()
            TweenService:Create(tStroke, tweenInfo, {
                Color = Color3.fromRGB(0, 0, 0)
            }):Play()
            updateStatus(false, false)
        end

        onToggle(enabled)
    end)

    redSetBtn.MouseButton1Click:Connect(function()
        if not enabled then return end
        onRedSet()
    end)

    blueSetBtn.MouseButton1Click:Connect(function()
        if not enabled then return end
        onBlueSet()
    end)

    redTpBtn.MouseButton1Click:Connect(function()
        if not enabled then return end
        onRedTp()
    end)

    blueTpBtn.MouseButton1Click:Connect(function()
        if not enabled then return end
        onBlueTp()
    end)

    return row
end


local updateDistUI = nil

local function createEspWithExceptionsControl(tabName, order, defaultText, onToggle, onTextChange)
    local targetTab = Tabs[tabName]
    if not targetTab then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 76)
    row.LayoutOrder = order
    row.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    row.Parent = targetTab
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = Color3.fromRGB(35, 35, 35)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -110, 0, 32)
    title.Position = UDim2.new(0, 15, 0, 2)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.Text = "[ > ] ESP_PLAYERS"
    title.TextSize = 13
    title.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 78, 0, 22)
    toggleBtn.Position = UDim2.new(1, -94, 0, 6)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    toggleBtn.TextColor3 = Color3.fromRGB(180, 55, 55)
    toggleBtn.Text = "[OFF]"
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    toggleBtn.Parent = row
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = Color3.fromRGB(0, 0, 0)

    local subTitle = Instance.new("TextLabel")
    subTitle.Size = UDim2.new(0, 110, 0, 26)
    subTitle.Position = UDim2.new(0, 8, 0, 40)
    subTitle.BackgroundTransparency = 1
    subTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subTitle.Text = "[ EXCEPTIONS ]"
    subTitle.TextSize = 11
    subTitle.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    subTitle.TextXAlignment = Enum.TextXAlignment.Left
    subTitle.Parent = row

    local valBox = Instance.new("TextBox")
    valBox.Size = UDim2.new(1, -128, 0, 26)
    valBox.Position = UDim2.new(0, 120, 0, 40)
    valBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    valBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    valBox.Text = tostring(defaultText)
    valBox.TextSize = 12
    valBox.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    valBox.ClearTextOnFocus = false
    valBox.PlaceholderText = "Name1, Name2"
    valBox.Parent = row
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", valBox).Color = Color3.fromRGB(40, 40, 40)

    local enabled = false
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            toggleBtn.Text = "[ON]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(15, 30, 20)}):Play()
            TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80)}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 45, 28), TextColor3 = Color3.fromRGB(0, 170, 80)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80)}):Play()
        else
            toggleBtn.Text = "[OFF]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}):Play()
            TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(35, 35, 35), Thickness = 1}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(12, 12, 12), TextColor3 = Color3.fromRGB(180, 55, 55)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 0, 0)}):Play()
        end
        onToggle(enabled, valBox.Text)
    end)
    valBox.FocusLost:Connect(function() onTextChange(valBox.Text) end)

    return row
end

-- ==========================================
-- PLAYER МОДУЛИ
-- ==========================================

local speedEnabled = false
local speedVal = 32
createToggleInputControl("PLAYER", "SPEED", 32, 1, function(enabled, val)
    speedEnabled = enabled
    speedVal = val
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = speedEnabled and speedVal or 16
    end
end)

local jumpEnabled = false
local jumpVal = 100
createToggleInputControl("PLAYER", "JUMP_POWER", 100, 2, function(enabled, val)
    jumpEnabled = enabled
    jumpVal = val
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        hum.UseJumpPower = true
        hum.JumpPower = jumpEnabled and jumpVal or 50
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    local hum = newChar:WaitForChild("Humanoid", 5)
    if hum then
        if speedEnabled then hum.WalkSpeed = speedVal end
        if jumpEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = jumpVal
        end
    end
end)

local infJumpConnection = nil
createToggleControl("PLAYER", "INFINITY_JUMP", 3, function(enabled)
    if enabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
    end
end)

-- TP TOOL: настоящий Tool в Backpack.
-- Экипируешь предмет и нажимаешь ЛКМ по месту/поверхности — телепорт туда.
local tpToolEnabled = false
local tpTool = nil
local tpToolMouse = nil
local tpToolEquipped = false
local tpToolActivatedConn = nil
local tpToolEquippedConn = nil
local tpToolUnequippedConn = nil

local function destroyTPTool()
    if tpToolActivatedConn then tpToolActivatedConn:Disconnect() tpToolActivatedConn = nil end
    if tpToolEquippedConn then tpToolEquippedConn:Disconnect() tpToolEquippedConn = nil end
    if tpToolUnequippedConn then tpToolUnequippedConn:Disconnect() tpToolUnequippedConn = nil end
    tpToolMouse = nil
    tpToolEquipped = false

    if tpTool then
        pcall(function() tpTool:Destroy() end)
        tpTool = nil
    end
end

local function getTeleportPosition(mouse)
    local character = LocalPlayer.Character
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, tpTool}
    raycastParams.IgnoreWater = false

    -- Сначала используем реальную позицию курсора, а не направление центра камеры.
    local x, y
    if mouse then
        x = mouse.X
        y = mouse.Y
    else
        local pos = UserInputService:GetMouseLocation()
        x, y = pos.X, pos.Y
    end

    local ray = camera:ViewportPointToRay(x, y)
    local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, raycastParams)

    if result then
        -- Ставим HRP немного выше поверхности, чтобы персонаж не оказался внутри неё.
        return result.Position + Vector3.new(0, 3, 0)
    end

    -- Если по лучу ничего нет, используем mouse.Hit как запасной вариант.
    if mouse and mouse.Hit then
        local hitPos = mouse.Hit.Position
        if (hitPos - camera.CFrame.Position).Magnitude <= 2000 then
            return hitPos + Vector3.new(0, 3, 0)
        end
    end

    return nil
end

local function createTPTool()
    destroyTPTool()

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end

    local tool = Instance.new("Tool")
    tool.Name = "TP Tool"
    tool.ToolTip = "Click to teleport"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.ManualActivationOnly = false
    tool.Parent = backpack
    tpTool = tool

    tpToolEquippedConn = tool.Equipped:Connect(function(mouse)
        tpToolMouse = mouse
        tpToolEquipped = true
    end)

    tpToolUnequippedConn = tool.Unequipped:Connect(function()
        tpToolMouse = nil
        tpToolEquipped = false
    end)

    tpToolActivatedConn = tool.Activated:Connect(function()
        if not tpToolEnabled or not tpToolEquipped then return end

        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local targetPos = getTeleportPosition(tpToolMouse)
        if not targetPos then return end

        -- Teleport всей моделью, сохраняя ориентацию персонажа.
        local currentPivot = character:GetPivot()
        local rotation = currentPivot - currentPivot.Position
        character:PivotTo(CFrame.new(targetPos) * rotation)

        -- Убираем остаточную скорость после телепорта.
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end)
end

createToggleControl("PLAYER", "TP_TOOL", 4, function(enabled)
    tpToolEnabled = enabled

    if enabled then
        createTPTool()
    else
        destroyTPTool()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if tpToolEnabled then
        task.wait(0.25)
        createTPTool()
    end
end)

-- Единая прокрутка списков игроков через компактные стрелки.
-- Работает мышью и тапом на телефоне. Никакого hover-переключения
-- родительского вертикального скролла здесь нет.
local horizontalArrowFrames = {}
local HORIZONTAL_ARROW_STEP = 120
local HORIZONTAL_ARROW_TWEEN = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function updateHorizontalCanvas(frame)
    if not frame or not frame.Parent then return 0 end

    -- Пустой сервер: список полностью фиксирован.
    -- Никакой Canvas overflow, стрелок или скрытого смещения быть не должно.
    local serverEmpty = frame:FindFirstChild("ServerEmpty")
    if serverEmpty then
        frame.CanvasSize = UDim2.new(0, frame.AbsoluteSize.X, 0, frame.AbsoluteSize.Y)
        if math.abs(frame.CanvasPosition.X) > 0.01 or math.abs(frame.CanvasPosition.Y) > 0.01 then
            frame.CanvasPosition = Vector2.new(0, 0)
        end
        return 0
    end

    local layout = frame:FindFirstChildOfClass("UIListLayout")
    if not layout then return 0 end

    local contentWidth = layout.AbsoluteContentSize.X
    local padding = frame:FindFirstChildOfClass("UIPadding")
    if padding then
        contentWidth += padding.PaddingLeft.Offset + padding.PaddingRight.Offset
    end

    local canvasWidth = math.max(contentWidth + 10, frame.AbsoluteSize.X)
    frame.CanvasSize = UDim2.new(0, canvasWidth, 0, frame.AbsoluteSize.Y)
    local maxX = math.max(0, canvasWidth - frame.AbsoluteSize.X)
    local clampedX = math.clamp(frame.CanvasPosition.X, 0, maxX)
    if math.abs(frame.CanvasPosition.X - clampedX) > 0.01 then
        frame.CanvasPosition = Vector2.new(clampedX, 0)
    elseif math.abs(frame.CanvasPosition.Y) > 0.01 then
        frame.CanvasPosition = Vector2.new(frame.CanvasPosition.X, 0)
    end
    return maxX
end

local function updateHorizontalProgress(data)
    if not data or not data.frame or not data.frame.Parent then return end

    local frame = data.frame
    local maxX = updateHorizontalCanvas(frame)
    local current = math.clamp(frame.CanvasPosition.X, 0, maxX)
    local canScroll = maxX > 1

    data.left.Visible = canScroll and current > 1
    data.right.Visible = canScroll and current < maxX - 1

    if data.progressTrack and data.progressFill then
        -- Keep the green bar visible even when there are no players / no scrollable content.
        data.progressTrack.Visible = true
        if canScroll then
            local viewWidth = math.max(frame.AbsoluteSize.X, 1)
            local contentWidth = viewWidth + maxX
            local thumbRatio = math.clamp(viewWidth / contentWidth, 0.16, 1)
            local trackWidth = math.max(data.progressTrack.AbsoluteSize.X, 1)
            local thumbWidth = math.max(10, trackWidth * thumbRatio)
            local travel = math.max(0, trackWidth - thumbWidth)
            local progress = maxX > 0 and (current / maxX) or 0

            data.progressFill.Size = UDim2.new(0, thumbWidth, 1, 0)
            data.progressFill.Position = UDim2.new(0, travel * progress, 0, 0)
        else
            -- Empty/short list: leave a fixed centered green indicator.
            data.progressFill.Size = UDim2.new(0, 28, 1, 0)
            data.progressFill.Position = UDim2.new(0.5, -14, 0, 0)
        end
    end
end

local function scrollHorizontalTo(frame, targetX)
    if not frame or not frame.Parent then return end

    local maxX = updateHorizontalCanvas(frame)
    targetX = math.clamp(targetX, 0, maxX)

    local data = horizontalArrowFrames[frame]
    if data and data.tween then
        data.tween:Cancel()
    end

    if data then
        data.tween = TweenService:Create(frame, HORIZONTAL_ARROW_TWEEN, {
            CanvasPosition = Vector2.new(targetX, 0)
        })
        data.tween:Play()
    else
        frame.CanvasPosition = Vector2.new(targetX, 0)
    end
end

local function stepHorizontal(frame, direction)
    if not frame or not frame.Parent or direction == 0 then return end

    local maxX = updateHorizontalCanvas(frame)
    if maxX <= 0 then return end

    local current = frame.CanvasPosition.X
    local targetX = current + (direction * HORIZONTAL_ARROW_STEP)
    scrollHorizontalTo(frame, targetX)
end

local function createScrollArrow(parent, frame, text, side)
    local button = Instance.new("TextButton")
    button.Name = side == "left" and "ScrollLeft" or "ScrollRight"
    button.Size = UDim2.new(0, 16, 0, 20)
    button.AnchorPoint = side == "left" and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)

    local framePos = frame.Position
    local frameSize = frame.Size
    local centerY = framePos.Y.Offset + (frameSize.Y.Offset * 0.5)
    button.Position = side == "left"
        and UDim2.new(framePos.X.Scale, framePos.X.Offset + 1, framePos.Y.Scale, centerY)
        or UDim2.new(
            framePos.X.Scale + frameSize.X.Scale,
            framePos.X.Offset + frameSize.X.Offset - 1,
            framePos.Y.Scale,
            centerY
        )

    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = text
    button.TextColor3 = Color3.fromRGB(150, 150, 150)
    button.TextSize = 13
    button.Font = Enum.Font.RobotoMono
    button.ZIndex = 20
    button.Parent = parent

    button.MouseEnter:Connect(function()
        TweenService:Create(button, HORIZONTAL_ARROW_TWEEN, {
            TextColor3 = Color3.fromRGB(0, 200, 100),
            TextTransparency = 0
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, HORIZONTAL_ARROW_TWEEN, {
            TextColor3 = Color3.fromRGB(150, 150, 150)
        }):Play()
    end)

    return button
end

local function createHorizontalProgress(parent, frame)
    local track = Instance.new("Frame")
    track.Name = "HorizontalScrollTrack"
    track.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset - 8, 0, 2)
    track.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset + 4,
        frame.Position.Y.Scale, frame.Position.Y.Offset + frame.Size.Y.Offset - 2)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    track.BorderSizePixel = 0
    track.ZIndex = 19
    track.Visible = false
    track.Parent = parent

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Thumb"
    fill.Size = UDim2.new(0, 28, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    fill.BorderSizePixel = 0
    fill.ZIndex = 20
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    return track, fill
end

local function enableHorizontalArrowScroll(scrollingFrame)
    if not scrollingFrame or horizontalArrowFrames[scrollingFrame] then return end

    scrollingFrame.Active = true
    scrollingFrame.Selectable = false
    scrollingFrame.ScrollingEnabled = false
    scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
    scrollingFrame.ScrollBarThickness = 0

    local parent = scrollingFrame.Parent
    if not parent then return end

    local progressTrack, progressFill = createHorizontalProgress(parent, scrollingFrame)
    local data = {
        frame = scrollingFrame,
        left = createScrollArrow(parent, scrollingFrame, "‹", "left"),
        right = createScrollArrow(parent, scrollingFrame, "›", "right"),
        progressTrack = progressTrack,
        progressFill = progressFill,
        tween = nil
    }
    horizontalArrowFrames[scrollingFrame] = data

    data.left.ZIndex = math.max(scrollingFrame.ZIndex + 1, 20)
    data.right.ZIndex = math.max(scrollingFrame.ZIndex + 1, 20)

    data.left.MouseButton1Click:Connect(function()
        stepHorizontal(scrollingFrame, -1)
    end)

    data.right.MouseButton1Click:Connect(function()
        stepHorizontal(scrollingFrame, 1)
    end)

    local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            updateHorizontalProgress(data)
        end)
    end

    scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        updateHorizontalProgress(data)
    end)

    scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        updateHorizontalProgress(data)
    end)

    task.defer(function()
        updateHorizontalProgress(data)
    end)
end

-- Совместимое имя: существующие списки ниже просто получают новую систему стрелок.
local enableHorizontalWheelScroll = enableHorizontalArrowScroll

-- TP TO PLAYER: выбираешь одного игрока из списка и нажимаешь TP.
local tpPlayerTarget = nil
local tpPlayerButtons = {}
local tpPlayerListFrame = nil
local tpPlayerRefresh = nil

local tpPlayerRow = Instance.new("Frame")
tpPlayerRow.Size = UDim2.new(1, 0, 0, 90)
tpPlayerRow.LayoutOrder = 5
tpPlayerRow.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
tpPlayerRow.Parent = Tabs.PLAYER
Instance.new("UICorner", tpPlayerRow).CornerRadius = UDim.new(0, 6)
local tpPlayerStroke = Instance.new("UIStroke", tpPlayerRow)
tpPlayerStroke.Color = Color3.fromRGB(35, 35, 35)

local tpPlayerTitle = Instance.new("TextLabel")
tpPlayerTitle.Size = UDim2.new(1, -110, 0, 30)
tpPlayerTitle.Position = UDim2.new(0, 15, 0, 2)
tpPlayerTitle.BackgroundTransparency = 1
tpPlayerTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
tpPlayerTitle.Text = "[ > ] TP_TO_PLAYER"
tpPlayerTitle.TextSize = 13
tpPlayerTitle.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
tpPlayerTitle.TextXAlignment = Enum.TextXAlignment.Left
tpPlayerTitle.Parent = tpPlayerRow

local tpPlayerButton = Instance.new("TextButton")
tpPlayerButton.Size = UDim2.new(0, 78, 0, 22)
tpPlayerButton.Position = UDim2.new(1, -94, 0, 6)
tpPlayerButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
tpPlayerButton.TextColor3 = Color3.fromRGB(160, 160, 160)
tpPlayerButton.Text = "[TP]"
tpPlayerButton.TextSize = 12
tpPlayerButton.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
tpPlayerButton.Parent = tpPlayerRow
Instance.new("UICorner", tpPlayerButton).CornerRadius = UDim.new(0, 4)
local tpPlayerButtonStroke = Instance.new("UIStroke", tpPlayerButton)
tpPlayerButtonStroke.Color = Color3.fromRGB(0, 0, 0)
tpPlayerButtonStroke.Thickness = 1.2

tpPlayerListFrame = Instance.new("ScrollingFrame")
tpPlayerListFrame.Size = UDim2.new(1, -16, 0, 42)
tpPlayerListFrame.Position = UDim2.new(0, 8, 0, 44)
tpPlayerListFrame.BackgroundTransparency = 1
tpPlayerListFrame.BorderSizePixel = 0
tpPlayerListFrame.ScrollBarThickness = 0
tpPlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 80)
tpPlayerListFrame.ScrollBarImageTransparency = 0
tpPlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 80)
tpPlayerListFrame.ScrollBarImageTransparency = 0
tpPlayerListFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
tpPlayerListFrame.BackgroundTransparency = 1
tpPlayerListFrame.Active = true
tpPlayerListFrame.ScrollingDirection = Enum.ScrollingDirection.X
tpPlayerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
tpPlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tpPlayerListFrame.Parent = tpPlayerRow
local tpPlayerListStroke = Instance.new("UIStroke", tpPlayerListFrame)
tpPlayerListStroke.Color = Color3.fromRGB(0, 0, 0)
tpPlayerListStroke.Thickness = 1
local tpPlayerLayout = Instance.new("UIListLayout")
tpPlayerLayout.FillDirection = Enum.FillDirection.Horizontal
tpPlayerLayout.Padding = UDim.new(0, 5)
tpPlayerLayout.Parent = tpPlayerListFrame
enableHorizontalArrowScroll(tpPlayerListFrame)

local function tpPlayerSetTarget(player)
    tpPlayerTarget = player
    for p, btn in pairs(tpPlayerButtons) do
        if p == player then
            btn.Text = "[✓] " .. p.Name
            btn.TextColor3 = Color3.fromRGB(0, 170, 80)
            btn.BackgroundColor3 = Color3.fromRGB(18, 38, 24)
        else
            btn.Text = "[ ] " .. p.Name
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        end
    end
end

tpPlayerRefresh = function()
    for _, btn in pairs(tpPlayerButtons) do pcall(function() btn:Destroy() end) end
    tpPlayerButtons = {}
    if tpPlayerListFrame then
        tpPlayerListFrame.CanvasPosition = Vector2.new(0, 0)
    end
    if tpPlayerTarget and (not tpPlayerTarget.Parent or tpPlayerTarget == LocalPlayer) then
        tpPlayerTarget = nil
    end

    local foundPlayer = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            foundPlayer = true
            break
        end
    end

    if not foundPlayer then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Name = "ServerEmpty"
        emptyLabel.Size = UDim2.new(1, 0, 1, 0)
        emptyLabel.Position = UDim2.new(0, 0, 0, 0)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.TextColor3 = Color3.fromRGB(135, 135, 135)
        emptyLabel.Text = "[ SERVER EMPTY ]"
        emptyLabel.TextSize = 15
        emptyLabel.Font = Enum.Font.RobotoMono
        emptyLabel.TextStrokeTransparency = 0.82
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
        emptyLabel.TextYAlignment = Enum.TextYAlignment.Center
        emptyLabel.Parent = tpPlayerListFrame
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, math.max(104, math.min(170, #player.Name * 8 + 46)), 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Text = "[ ] " .. player.Name
            btn.TextSize = 12
            btn.Font = Enum.Font.RobotoMono
            TextStrokeTransparency = 0.82
            btn.AutoButtonColor = false
            btn.Active = true
            btn.Parent = tpPlayerListFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            local btnStroke = Instance.new("UIStroke", btn)
            btnStroke.Color = Color3.fromRGB(0, 0, 0)
            btnStroke.Thickness = 1.2
            tpPlayerButtons[player] = btn
            btn.MouseButton1Click:Connect(function() tpPlayerSetTarget(player) end)
        end
    end
    if tpPlayerTarget then tpPlayerSetTarget(tpPlayerTarget) end
end

tpPlayerButton.MouseButton1Click:Connect(function()
    local player = tpPlayerTarget
    if not player or not player.Parent then return end
    local targetChar = player.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not root or not char then return end

    local targetCFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
    char:PivotTo(targetCFrame)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end)

Players.PlayerAdded:Connect(function()
    task.defer(tpPlayerRefresh)
end)
Players.PlayerRemoving:Connect(function(player)
    if tpPlayerTarget == player then tpPlayerTarget = nil end
    task.defer(tpPlayerRefresh)
end)
tpPlayerRefresh()

-- FLING: полностью переработанная система.
-- Выбирается один игрок, после чего используется классический client-side
-- spin-fling: собственный HRP кратко получает очень высокий angular velocity,
-- а персонаж несколько раз подводится вплотную к HRP цели. Это надёжнее,
-- чем пытаться напрямую менять AssemblyLinearVelocity чужого персонажа.
local flingTarget = nil
local flingButtons = {}
local flingListFrame = nil
local flingBusy = false

local FLING_DURATION = 1.35
local FLING_RADIUS = 0.55
local FLING_SPIN = 350000
local FLING_LINEAR = 900

local flingRow = Instance.new("Frame")
flingRow.Size = UDim2.new(1, 0, 0, 90)
flingRow.LayoutOrder = 6
flingRow.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
flingRow.Parent = Tabs.PLAYER
Instance.new("UICorner", flingRow).CornerRadius = UDim.new(0, 6)
local flingStroke = Instance.new("UIStroke", flingRow)
flingStroke.Color = Color3.fromRGB(35, 35, 35)

local flingTitle = Instance.new("TextLabel")
flingTitle.Size = UDim2.new(1, -110, 0, 30)
flingTitle.Position = UDim2.new(0, 15, 0, 2)
flingTitle.BackgroundTransparency = 1
flingTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
flingTitle.Text = "[ > ] FLING"
flingTitle.TextSize = 13
flingTitle.Font = Enum.Font.RobotoMono
flingTitle.TextStrokeTransparency = 0.82
flingTitle.TextXAlignment = Enum.TextXAlignment.Left
flingTitle.Parent = flingRow

local flingButton = Instance.new("TextButton")
flingButton.Size = UDim2.new(0, 78, 0, 22)
flingButton.Position = UDim2.new(1, -94, 0, 6)
flingButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
flingButton.TextColor3 = Color3.fromRGB(160, 160, 160)
flingButton.Text = "[FLING]"
flingButton.TextSize = 12
flingButton.Font = Enum.Font.RobotoMono
flingButton.TextStrokeTransparency = 0.82
flingButton.AutoButtonColor = false
flingButton.Parent = flingRow
Instance.new("UICorner", flingButton).CornerRadius = UDim.new(0, 4)
local flingButtonStroke = Instance.new("UIStroke", flingButton)
flingButtonStroke.Color = Color3.fromRGB(0, 0, 0)
flingButtonStroke.Thickness = 1.2

flingListFrame = Instance.new("ScrollingFrame")
flingListFrame.Size = UDim2.new(1, -16, 0, 42)
flingListFrame.Position = UDim2.new(0, 8, 0, 44)
flingListFrame.BackgroundTransparency = 1
flingListFrame.BorderSizePixel = 0
flingListFrame.ScrollBarThickness = 4
flingListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 80)
flingListFrame.ScrollBarImageTransparency = 0
flingListFrame.Active = true
flingListFrame.ScrollingDirection = Enum.ScrollingDirection.X
flingListFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
flingListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
flingListFrame.Parent = flingRow

local flingListLayout = Instance.new("UIListLayout")
flingListLayout.FillDirection = Enum.FillDirection.Horizontal
flingListLayout.Padding = UDim.new(0, 5)
flingListLayout.Parent = flingListFrame
enableHorizontalArrowScroll(flingListFrame)

local function flingSetTarget(player)
    flingTarget = player
    for p, btn in pairs(flingButtons) do
        if p == player then
            btn.Text = "[✓] " .. p.Name
            btn.TextColor3 = Color3.fromRGB(0, 170, 80)
            btn.BackgroundColor3 = Color3.fromRGB(18, 38, 24)
        else
            btn.Text = "[ ] " .. p.Name
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        end
    end
end

local function refreshFlingList()
    for _, btn in pairs(flingButtons) do
        pcall(function() btn:Destroy() end)
    end
    flingButtons = {}
    if flingListFrame then
        flingListFrame.CanvasPosition = Vector2.new(0, 0)
    end

    if flingTarget and (not flingTarget.Parent or flingTarget == LocalPlayer) then
        flingTarget = nil
    end

    local foundPlayer = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            foundPlayer = true
            break
        end
    end

    if not foundPlayer then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Name = "ServerEmpty"
        emptyLabel.Size = UDim2.new(1, 0, 1, 0)
        emptyLabel.Position = UDim2.new(0, 0, 0, 0)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.TextColor3 = Color3.fromRGB(135, 135, 135)
        emptyLabel.Text = "[ SERVER EMPTY ]"
        emptyLabel.TextSize = 15
        emptyLabel.Font = Enum.Font.RobotoMono
        emptyLabel.TextStrokeTransparency = 0.82
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
        emptyLabel.TextYAlignment = Enum.TextYAlignment.Center
        emptyLabel.Parent = flingListFrame
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, math.max(104, math.min(170, #player.Name * 8 + 46)), 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Text = "[ ] " .. player.Name
            btn.TextSize = 12
            btn.Font = Enum.Font.RobotoMono
            btn.TextStrokeTransparency = 0.82
            btn.AutoButtonColor = false
            btn.Active = true
            btn.Parent = flingListFrame

            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            local btnStroke = Instance.new("UIStroke", btn)
            btnStroke.Color = Color3.fromRGB(0, 0, 0)
            btnStroke.Thickness = 1.2

            flingButtons[player] = btn
            btn.MouseButton1Click:Connect(function()
                flingSetTarget(player)
            end)
        end
    end

    if flingTarget then
        flingSetTarget(flingTarget)
    end
end

local function stopFlingPhysics(root, oldCFrame, oldVelocity, oldAngular)
    if not root or not root.Parent then return end
    pcall(function()
        root.AssemblyAngularVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        if oldCFrame then root.CFrame = oldCFrame end
        if oldVelocity then root.AssemblyLinearVelocity = oldVelocity end
        if oldAngular then root.AssemblyAngularVelocity = oldAngular end
    end)
end

local function performFling(player)
    if flingBusy then return end
    if not player or not player.Parent or player == LocalPlayer then return end

    local targetChar = player.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not targetRoot or not targetHum or targetHum.Health <= 0 or not root then
        return
    end

    flingBusy = true
    flingButton.Text = "[FLING...]"
    flingButton.TextColor3 = Color3.fromRGB(220, 180, 60)

    local oldCFrame = root.CFrame
    local oldVelocity = root.AssemblyLinearVelocity
    local oldAngular = root.AssemblyAngularVelocity
    local start = os.clock()
    local angle = 0

    -- Спин сохраняется на всём коротком цикле, а позиция постоянно меняется
    -- вокруг цели. Heartbeat здесь намеренно используется вместо task.delay,
    -- чтобы импульсы не зависели от разного FPS.
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        if not root.Parent or not targetRoot.Parent or not targetHum.Parent or targetHum.Health <= 0 then
            connection:Disconnect()
            stopFlingPhysics(root, oldCFrame, oldVelocity, oldAngular)
            flingBusy = false
            flingButton.Text = "[FLING]"
            flingButton.TextColor3 = Color3.fromRGB(160, 160, 160)
            return
        end

        local elapsed = os.clock() - start
        if elapsed >= FLING_DURATION then
            connection:Disconnect()
            stopFlingPhysics(root, oldCFrame, oldVelocity, oldAngular)
            flingBusy = false
            flingButton.Text = "[FLING]"
            flingButton.TextColor3 = Color3.fromRGB(160, 160, 160)
            return
        end

        angle += dt * 55
        local vertical = math.sin(angle * 2.0) * 0.35
        local offset = Vector3.new(math.cos(angle) * FLING_RADIUS, vertical, math.sin(angle) * FLING_RADIUS)
        local targetPosition = targetRoot.Position + offset
        -- Keep the local character intersecting/pressing into the target from rapidly changing angles.
        -- This makes the spin-fling much less dependent on getting a perfect single collision.
        local inward = (targetRoot.Position - targetPosition)
        if inward.Magnitude > 0.001 then
            targetPosition += inward.Unit * 0.22
        end
        local direction = targetRoot.Position - targetPosition
        local velocity = Vector3.zero
        if direction.Magnitude > 0.001 then
            velocity = direction.Unit * FLING_LINEAR
        end

        pcall(function()
            -- Несколько раз в секунду персонаж проходит очень близко вокруг цели,
            -- одновременно сохраняя огромную угловую скорость. Это стабильнее
            -- для классического client-side spin-fling, чем один короткий импульс.
            root.CFrame = CFrame.lookAt(targetPosition, targetRoot.Position)
            root.AssemblyAngularVelocity = Vector3.new(0, FLING_SPIN, 0)
            root.AssemblyLinearVelocity = velocity
        end)
    end)
end

flingButton.MouseButton1Click:Connect(function()
    performFling(flingTarget)
end)

Players.PlayerAdded:Connect(function()
    task.defer(refreshFlingList)
end)
Players.PlayerRemoving:Connect(function(player)
    if flingTarget == player then
        flingTarget = nil
    end
    task.defer(refreshFlingList)
end)
refreshFlingList()



local noclipConnection = nil
createToggleControl("PLAYER", "NOCLIP", 6, function(enabled)
    if enabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
            end
        end
    end
end)

local flyConn = nil
createToggleInputControl("PLAYER", "FLY", 50, 7, function(enabled, speed)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if enabled then
        if not flyConn then
            flyConn = RunService.RenderStepped:Connect(function()
                local c = LocalPlayer.Character
                if not c then return end
                local h = c:FindFirstChildOfClass("Humanoid")
                local root = c:FindFirstChild("HumanoidRootPart")
                if not h or not root or h.Health <= 0 then return end
                h.PlatformStand = true
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                if moveDir.Magnitude > 0 then
                    root.AssemblyLinearVelocity = moveDir.Unit * speed
                else
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end)
        end
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if hum then hum.PlatformStand = false end
        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
    end
end)

-- Увеличение хитбокса других игроков
-- Полностью новая реализация:
-- 1) меняем именно HumanoidRootPart, а не создаём отдельный Part в workspace;
-- 2) размер одинаковый по X/Y/Z;
-- 3) центр хитбокса всегда совпадает с HumanoidRootPart;
-- 4) при выключении исходный размер полностью восстанавливается;
-- 5) поверх него показывается отдельный яркий контур, чтобы размер был хорошо виден.
--
-- Это всё ещё клиентская модификация. Серверный hitbox/проверку урона она
-- изменить не может, если конкретная игра проверяет попадания только на сервере.

local hitboxEnabled = false
local hitboxSize = 20
local hitboxData = {}
local hitboxConn = nil

local function removeHitbox(player)
    local data = hitboxData[player]
    if not data then return end

    local root = data.Root
    if root and root.Parent then
        pcall(function()
            root.Size = data.OriginalSize
            root.Transparency = data.OriginalTransparency
            root.CanQuery = data.OriginalCanQuery
            root.CanCollide = data.OriginalCanCollide
            root.CanTouch = data.OriginalCanTouch
        end)
    end

    if data.Visual then
        pcall(function()
            data.Visual:Destroy()
        end)
    end

    hitboxData[player] = nil
end

local function removeAllHitboxes()
    for player in pairs(hitboxData) do
        removeHitbox(player)
    end
end

local function createOrUpdateHitbox(player)
    if player == LocalPlayer or not hitboxEnabled then
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
        removeHitbox(player)
        return
    end

    local data = hitboxData[player]

    if not data or data.Root ~= root then
        if data then
            removeHitbox(player)
        end

        data = {
            Root = root,
            OriginalSize = root.Size,
            OriginalTransparency = root.Transparency,
            OriginalCanQuery = root.CanQuery,
            OriginalCanCollide = root.CanCollide,
            OriginalCanTouch = root.CanTouch,
            Visual = nil
        }

        hitboxData[player] = data
    end

    -- hitboxSize = точный размер куба: 20 означает 20 x 20 x 20 studs.
    local size = math.clamp(tonumber(hitboxSize) or 20, 2, 200)
    local exactSize = Vector3.new(size, size, size)

    pcall(function()
        root.Size = exactSize

        -- Главное изменение v36: большой HRP остаётся queryable,
        -- но физически не сталкивается с твоим персонажем.
        -- Поэтому резкий поворот другого игрока не должен отбрасывать тебя.
        root.CanCollide = false
        root.CanQuery = true

        -- Не меняем CanTouch: если игра использует Touched/TouchInterest,
        -- локальное поведение не отключается только из-за CanCollide.
        root.CanTouch = data.OriginalCanTouch
    end)

    local visual = data.Visual
    if not visual or not visual.Parent then
        visual = Instance.new("BoxHandleAdornment")
        visual.Name = "HackerHitboxVisual"
        visual.Adornee = root
        visual.AlwaysOnTop = true
        visual.ZIndex = 10
        visual.Size = exactSize
        visual.Color3 = Color3.fromRGB(255, 255, 255)
        visual.Transparency = 0.35
        visual.Parent = root

        data.Visual = visual
    else
        visual.Adornee = root
        visual.Size = exactSize
    end
end

local function startHitboxLoop()
    if hitboxConn then
        hitboxConn:Disconnect()
        hitboxConn = nil
    end

    hitboxConn = RunService.RenderStepped:Connect(function()
        if not hitboxEnabled then
            return
        end

        local activePlayers = {}

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                activePlayers[player] = true
                createOrUpdateHitbox(player)
            end
        end

        -- Удаляем игроков, которые вышли или больше не имеют персонажа.
        for player in pairs(hitboxData) do
            if not activePlayers[player] then
                removeHitbox(player)
            end
        end
    end)
end

createToggleInputControl("PLAYER", "HITBOX_SIZE", 20, 8, function(enabled, value)
    hitboxEnabled = enabled
    hitboxSize = math.clamp(tonumber(value) or 20, 2, 200)

    if not hitboxEnabled then
        if hitboxConn then
            hitboxConn:Disconnect()
            hitboxConn = nil
        end

        removeAllHitboxes()
        return
    end

    startHitboxLoop()
end)

-- Безинструментальные Векторные Якоря
local redPos = nil
local bluePos = nil
local redVisual = nil
local blueVisual = nil

local function getVectorAnchorGround(character)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return nil, nil end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    params.IgnoreWater = false

    local result = workspace:Raycast(
        root.Position + Vector3.new(0, 2, 0),
        Vector3.new(0, -100, 0),
        params
    )

    local groundPos
    if result then
        groundPos = result.Position
    else
        groundPos = root.Position - Vector3.new(0, humanoid.HipHeight + root.Size.Y / 2, 0)
    end

    local rootOffset = root.Position.Y - groundPos.Y
    return groundPos, rootOffset
end

createVectorAnchorsControl("PLAYER", 9, 
    function(enabled)
        if not enabled then
            if redVisual then redVisual:Destroy() redVisual = nil end
            if blueVisual then blueVisual:Destroy() blueVisual = nil end
            redPos = nil
            bluePos = nil
            if updateVectorsUI then updateVectorsUI(false, false) end
        end
    end,
    function() -- Set Red
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local groundPos = getVectorAnchorGround(char)
            if groundPos then
                redPos = groundPos

                if redVisual then redVisual:Destroy() end

                local p = Instance.new("Part")
                p.Name = "RedVectorAnchor"
                p.Size = Vector3.new(4.5, 0.18, 4.5)
                p.Position = groundPos + Vector3.new(0, 0.09, 0)
                p.Anchored = true
                p.CanCollide = false
                p.CanTouch = false
                p.CanQuery = false
                p.CastShadow = false
                p.Material = Enum.Material.Neon
                p.Color = Color3.fromRGB(255, 60, 60)
                p.Transparency = 0.12
                p.Parent = workspace

                local light = Instance.new("PointLight")
                light.Color = p.Color
                light.Brightness = 0.7
                light.Range = 8
                light.Shadows = false
                light.Parent = p

                redVisual = p
                if updateVectorsUI then updateVectorsUI(redPos ~= nil, bluePos ~= nil) end
            end
        end
    end,
    function() -- Set Blue
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local groundPos = getVectorAnchorGround(char)
            if groundPos then
                bluePos = groundPos

                if blueVisual then blueVisual:Destroy() end

                local p = Instance.new("Part")
                p.Name = "BlueVectorAnchor"
                p.Size = Vector3.new(4.5, 0.18, 4.5)
                p.Position = groundPos + Vector3.new(0, 0.09, 0)
                p.Anchored = true
                p.CanCollide = false
                p.CanTouch = false
                p.CanQuery = false
                p.CastShadow = false
                p.Material = Enum.Material.Neon
                p.Color = Color3.fromRGB(50, 150, 255)
                p.Transparency = 0.12
                p.Parent = workspace

                local light = Instance.new("PointLight")
                light.Color = p.Color
                light.Brightness = 0.7
                light.Range = 8
                light.Shadows = false
                light.Parent = p

                blueVisual = p
                if updateVectorsUI then updateVectorsUI(redPos ~= nil, bluePos ~= nil) end
            end
        end
    end,
    function() -- TP Red
        if redPos then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local _, rootOffset = getVectorAnchorGround(char)
                if rootOffset then
                    root.CFrame = CFrame.new(redPos + Vector3.new(0, rootOffset, 0))
                end
            end
        end
    end,
    function() -- TP Blue
        if bluePos then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local _, rootOffset = getVectorAnchorGround(char)
                if rootOffset then
                    root.CFrame = CFrame.new(bluePos + Vector3.new(0, rootOffset, 0))
                end
            end
        end
    end

)

-- ==========================================
-- ТЕЛЕКИНЕЗ (ИНЖЕКТОРНАЯ ФИЗИЧЕСКАЯ РЕАЛИЗАЦИЯ)
-- ==========================================
local telekinesisEnabled = false
local telekinesisGrabbedPart = nil
local telekinesisGrabDistance = 18
local telekinesisReleaseMode = "DROP" -- DROP / THROW

local telekinesisRenderConn = nil
local telekinesisInputConn = nil
local telekinesisJKConn = nil

-- Forward declarations: the input code uses these before the UI is created.
local telekinesisUpdateUI
local telekinesisChangeDistance
local telekinesisTool = nil
local telekinesisToolEquipped = false
local telekinesisToolAnimConn = nil

local TELEKINESIS_MIN_DISTANCE = 4
local TELEKINESIS_MAX_DISTANCE = 80
local TELEKINESIS_PULL_SPEED = 34
local TELEKINESIS_MAX_VELOCITY = 220
local TELEKINESIS_THROW_SPEED = 125

-- Изображения предмета в руке для разных режимов.
local TELEKINESIS_DROP_IMAGE = "rbxassetid://139334701849666"
local TELEKINESIS_THROW_IMAGE = "rbxassetid://134979152121573"

local function telekinesisIsCharacterPart(part)
    if not part or not part:IsA("BasePart") then return false end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and part:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local function telekinesisClearGrab(stopVelocity)
    local part = telekinesisGrabbedPart
    telekinesisGrabbedPart = nil

    if stopVelocity and part and part.Parent then
        pcall(function()
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

local function telekinesisGetTargetPosition()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local mouse = LocalPlayer:GetMouse()
    if not mouse then return nil end

    return camera.CFrame.Position + mouse.UnitRay.Direction * telekinesisGrabDistance
end

local function telekinesisTryGrab()
    if telekinesisGrabbedPart then return end

    local mouse = LocalPlayer:GetMouse()
    local target = mouse and mouse.Target
    if not target or not target:IsA("BasePart") then return end

    -- Только реальные незакреплённые физические детали.
    if target.Anchored then return end
    if telekinesisIsCharacterPart(target) then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    telekinesisGrabbedPart = target
    -- Всегда начинаем с фиксированной дистанции, чтобы число не менялось
    -- случайно в зависимости от того, где именно был выбран Part.
    telekinesisGrabDistance = 18

    pcall(function()
        target.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function telekinesisRelease()
    local part = telekinesisGrabbedPart
    if not part or not part.Parent then
        telekinesisClearGrab(false)
        return
    end

    local camera = workspace.CurrentCamera
    local mouse = LocalPlayer:GetMouse()

    if telekinesisReleaseMode == "THROW" and camera and mouse then
        -- THROW: обычный физический импульс в направлении курсора.
        pcall(function()
            part.AssemblyAngularVelocity = Vector3.zero
            part.AssemblyLinearVelocity = mouse.UnitRay.Direction * TELEKINESIS_THROW_SPEED
        end)
        telekinesisClearGrab(false)
    else
        -- DROP: полностью отпускаем предмет без сохранения скорости телекинеза.
        telekinesisClearGrab(true)
    end
end

local function telekinesisStart()
    if telekinesisRenderConn then return end

    telekinesisRenderConn = RunService.RenderStepped:Connect(function()
        local part = telekinesisGrabbedPart
        if not part or not part.Parent or part.Anchored or telekinesisIsCharacterPart(part) then
            telekinesisClearGrab(true)
            return
        end

        local targetPos = telekinesisGetTargetPosition()
        if not targetPos then return end

        -- Никаких визуальных объектов не создаём.
        -- Двигаем сам физический Part через его AssemblyLinearVelocity.
        local delta = targetPos - part.Position
        local velocity = delta * TELEKINESIS_PULL_SPEED

        if velocity.Magnitude > TELEKINESIS_MAX_VELOCITY then
            velocity = velocity.Unit * TELEKINESIS_MAX_VELOCITY
        end

        pcall(function()
            part.AssemblyLinearVelocity = velocity
            part.AssemblyAngularVelocity = Vector3.zero
        end)
    end)

    telekinesisJKConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not telekinesisToolEquipped then return end
        if not telekinesisGrabbedPart then return end

        -- J = ближе, K = дальше.
        if input.KeyCode == Enum.KeyCode.J then
            telekinesisChangeDistance(-3)
        elseif input.KeyCode == Enum.KeyCode.K then
            telekinesisChangeDistance(3)
        end
    end)
end

local function telekinesisStop()
    if telekinesisRenderConn then
        telekinesisRenderConn:Disconnect()
        telekinesisRenderConn = nil
    end
    if telekinesisInputConn then
        telekinesisInputConn:Disconnect()
        telekinesisInputConn = nil
    end
    if telekinesisJKConn then
        telekinesisJKConn:Disconnect()
        telekinesisJKConn = nil
    end

    telekinesisClearGrab(true)
end

-- Инвентарь: TELEKINESIS как настоящий Tool.
-- В инвентаре используется TextureId, поэтому вместо текстового названия
-- отображается физган. DROP и THROW имеют разные картинки.
local function telekinesisGetImageId()
    if telekinesisReleaseMode == "THROW" then
        return TELEKINESIS_THROW_IMAGE
    end
    return TELEKINESIS_DROP_IMAGE
end

local function telekinesisApplyToolImage(tool)
    if not tool then return end

    -- Главное изображение для инвентаря Roblox.
    -- Backpack сам помещает TextureId в квадратный слот и сохраняет
    -- пропорции исходной картинки, поэтому физган не растягивается.
    tool.TextureId = telekinesisGetImageId()

    -- Убираем старую визуализацию через BillboardGui.
    -- Картинка теперь показывается именно в слоте инвентаря,
    -- а не над Handle в мире.
    local handle = tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        local oldGui = handle:FindFirstChild("TelekinesisImage")
        if oldGui then
            oldGui:Destroy()
        end
    end
end

local function telekinesisCreateTool()
    if telekinesisTool and telekinesisTool.Parent then
        telekinesisTool.Name = "Telekinesis [" .. telekinesisReleaseMode .. "]"
        telekinesisTool.ToolTip = "Created by 71033"
        telekinesisApplyToolImage(telekinesisTool)
        return telekinesisTool
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return nil end

    local tool = Instance.new("Tool")
    tool.Name = "Telekinesis"
    tool.ToolTip = "Telekinesis [" .. telekinesisReleaseMode .. "] | Created by 71033"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.ManualActivationOnly = false

    tool.Equipped:Connect(function()
        telekinesisToolEquipped = true
        telekinesisApplyToolImage(tool)

        -- Roblox обычно запускает Tool-анимацию при экипировке.
        -- Для Telekinesis её глушим, чтобы правая рука не поднималась.
        if telekinesisToolAnimConn then
            telekinesisToolAnimConn:Disconnect()
            telekinesisToolAnimConn = nil
        end
        telekinesisToolAnimConn = RunService.RenderStepped:Connect(function()
            if not telekinesisToolEquipped then return end
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    local n = string.lower(track.Name or "")
                    if string.find(n, "tool", 1, true) then
                        pcall(function() track:Stop(0) end)
                    end
                end
            end
        end)

        telekinesisUpdateUI()
    end)

    tool.Unequipped:Connect(function()
        telekinesisToolEquipped = false
        if telekinesisToolAnimConn then
            telekinesisToolAnimConn:Disconnect()
            telekinesisToolAnimConn = nil
        end
        if telekinesisGrabbedPart then
            telekinesisRelease()
        end
        telekinesisUpdateUI()
    end)

    tool.Activated:Connect(function()
        if not telekinesisEnabled or not telekinesisToolEquipped then
            return
        end

        if telekinesisGrabbedPart then
            telekinesisRelease()
        else
            telekinesisTryGrab()
        end
        telekinesisUpdateUI()
    end)

    tool.Parent = backpack
    telekinesisTool = tool
    telekinesisApplyToolImage(tool)
    return tool
end

local function telekinesisRemoveTool()
    telekinesisToolEquipped = false
    if telekinesisToolAnimConn then
        telekinesisToolAnimConn:Disconnect()
        telekinesisToolAnimConn = nil
    end
    if telekinesisTool then
        pcall(function()
            telekinesisTool:Destroy()
        end)
        telekinesisTool = nil
    end
end

-- Один компактный блок управления:
-- ON/OFF + режим DROP/THROW + текущая дистанция.
local telekinesisRow = Instance.new("Frame")
telekinesisRow.Size = UDim2.new(1, 0, 0, 82)
telekinesisRow.LayoutOrder = 10
telekinesisRow.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
telekinesisRow.Parent = Tabs.PLAYER
Instance.new("UICorner", telekinesisRow).CornerRadius = UDim.new(0, 6)

local telekinesisStroke = Instance.new("UIStroke", telekinesisRow)
telekinesisStroke.Color = Color3.fromRGB(35, 35, 35)

local telekinesisTitle = Instance.new("TextLabel")
telekinesisTitle.Size = UDim2.new(1, -230, 0, 32)
telekinesisTitle.Position = UDim2.new(0, 15, 0, 3)
telekinesisTitle.BackgroundTransparency = 1
telekinesisTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
telekinesisTitle.Text = "[ > ] TELEKINESIS"
telekinesisTitle.TextSize = 13
telekinesisTitle.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
telekinesisTitle.TextXAlignment = Enum.TextXAlignment.Left
telekinesisTitle.Parent = telekinesisRow

local telekinesisModeButton = Instance.new("TextButton")
telekinesisModeButton.Size = UDim2.new(0, 92, 0, 22)
telekinesisModeButton.Position = UDim2.new(1, -198, 0, 7)
telekinesisModeButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
telekinesisModeButton.TextColor3 = Color3.fromRGB(200, 170, 80)
telekinesisModeButton.Text = "[DROP]"
telekinesisModeButton.TextSize = 11
telekinesisModeButton.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
telekinesisModeButton.Parent = telekinesisRow
Instance.new("UICorner", telekinesisModeButton).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", telekinesisModeButton).Color = Color3.fromRGB(70, 60, 30)

local telekinesisToggleButton = Instance.new("TextButton")
telekinesisToggleButton.Size = UDim2.new(0, 78, 0, 22)
telekinesisToggleButton.Position = UDim2.new(1, -94, 0, 7)
telekinesisToggleButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
telekinesisToggleButton.TextColor3 = Color3.fromRGB(180, 55, 55)
telekinesisToggleButton.Text = "[OFF]"
telekinesisToggleButton.TextSize = 12
telekinesisToggleButton.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
telekinesisToggleButton.Parent = telekinesisRow
Instance.new("UICorner", telekinesisToggleButton).CornerRadius = UDim.new(0, 4)
local telekinesisToggleStroke = Instance.new("UIStroke", telekinesisToggleButton)
telekinesisToggleStroke.Color = Color3.fromRGB(0, 0, 0)

local telekinesisInfo = Instance.new("TextLabel")
telekinesisInfo.Size = UDim2.new(1, -250, 0, 28)
telekinesisInfo.Position = UDim2.new(0, 15, 0, 38)
telekinesisInfo.BackgroundTransparency = 1
telekinesisInfo.TextColor3 = Color3.fromRGB(120, 120, 120)
telekinesisInfo.Text = "LMB: GRAB / RELEASE"
telekinesisInfo.TextSize = 10
telekinesisInfo.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
telekinesisInfo.TextXAlignment = Enum.TextXAlignment.Left
telekinesisInfo.Parent = telekinesisRow

local telekinesisDistanceDown = Instance.new("TextButton")
telekinesisDistanceDown.Size = UDim2.new(0, 76, 0, 22)
telekinesisDistanceDown.Position = UDim2.new(1, -174, 0, 40)
telekinesisDistanceDown.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
telekinesisDistanceDown.TextColor3 = Color3.fromRGB(190, 190, 190)
telekinesisDistanceDown.Text = "[J]"
telekinesisDistanceDown.TextSize = 10
telekinesisDistanceDown.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
telekinesisDistanceDown.Parent = telekinesisRow
Instance.new("UICorner", telekinesisDistanceDown).CornerRadius = UDim.new(0, 4)
local telekinesisDistanceDownStroke = Instance.new("UIStroke", telekinesisDistanceDown)
telekinesisDistanceDownStroke.Color = Color3.fromRGB(55, 55, 55)

local telekinesisDistanceUp = Instance.new("TextButton")
telekinesisDistanceUp.Size = UDim2.new(0, 76, 0, 22)
telekinesisDistanceUp.Position = UDim2.new(1, -92, 0, 40)
telekinesisDistanceUp.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
telekinesisDistanceUp.TextColor3 = Color3.fromRGB(190, 190, 190)
telekinesisDistanceUp.Text = "[K]"
telekinesisDistanceUp.TextSize = 10
telekinesisDistanceUp.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
telekinesisDistanceUp.Parent = telekinesisRow
Instance.new("UICorner", telekinesisDistanceUp).CornerRadius = UDim.new(0, 4)
local telekinesisDistanceUpStroke = Instance.new("UIStroke", telekinesisDistanceUp)
telekinesisDistanceUpStroke.Color = Color3.fromRGB(55, 55, 55)

telekinesisChangeDistance = function(delta)
    telekinesisGrabDistance = math.clamp(
        telekinesisGrabDistance + delta,
        TELEKINESIS_MIN_DISTANCE,
        TELEKINESIS_MAX_DISTANCE
    )
    telekinesisUpdateUI()
end

telekinesisUpdateUI = function()
    telekinesisModeButton.Text = telekinesisReleaseMode == "THROW" and "[THROW]" or "[DROP]"
    local modeText = telekinesisReleaseMode == "THROW" and "[THROW]" or "[DROP]"
    if telekinesisGrabbedPart then
        telekinesisInfo.Text = string.format(
            "LMB: GRAB / RELEASE    |    DIST: %d",
            math.floor(telekinesisGrabDistance + 0.5)
        )
    else
        telekinesisInfo.Text = "LMB: GRAB / RELEASE"
    end
end

telekinesisDistanceDown.MouseButton1Click:Connect(function()
    telekinesisChangeDistance(-3)
end)

telekinesisDistanceUp.MouseButton1Click:Connect(function()
    telekinesisChangeDistance(3)
end)

telekinesisModeButton.MouseButton1Click:Connect(function()
    telekinesisReleaseMode = telekinesisReleaseMode == "DROP" and "THROW" or "DROP"

    if telekinesisTool and telekinesisTool.Parent then
        telekinesisTool.Name = "Telekinesis [" .. telekinesisReleaseMode .. "]"
        telekinesisTool.ToolTip = "Created by 71033"
        telekinesisApplyToolImage(telekinesisTool)
    end

    telekinesisUpdateUI()
end)

telekinesisToggleButton.MouseButton1Click:Connect(function()
    telekinesisEnabled = not telekinesisEnabled

    if telekinesisEnabled then
        telekinesisStart()
        telekinesisCreateTool()
        if telekinesisTool then
            telekinesisTool.Name = "Telekinesis [" .. telekinesisReleaseMode .. "]"
            telekinesisTool.ToolTip = "Created by 71033"
            telekinesisApplyToolImage(telekinesisTool)
        end
        telekinesisToggleButton.Text = "[ON]"
        TweenService:Create(telekinesisRow, tweenInfo, {BackgroundColor3 = Color3.fromRGB(15, 30, 20)}):Play()
        TweenService:Create(telekinesisStroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80), Thickness = 1.2}):Play()
        TweenService:Create(telekinesisToggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 45, 28), TextColor3 = Color3.fromRGB(0, 170, 80)}):Play()
        TweenService:Create(telekinesisToggleStroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80)}):Play()
    else
        telekinesisStop()
        telekinesisRemoveTool()
        telekinesisToggleButton.Text = "[OFF]"
        TweenService:Create(telekinesisRow, tweenInfo, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}):Play()
        TweenService:Create(telekinesisStroke, tweenInfo, {Color = Color3.fromRGB(35, 35, 35), Thickness = 1}):Play()
        TweenService:Create(telekinesisToggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(12, 12, 12), TextColor3 = Color3.fromRGB(180, 55, 55)}):Play()
        TweenService:Create(telekinesisToggleStroke, tweenInfo, {Color = Color3.fromRGB(0, 0, 0)}):Play()
    end

    telekinesisUpdateUI()
end)

telekinesisUpdateUI()

-- ==========================================
-- VISUAL МОДУЛИ
-- ==========================================
local espEnabled = false
local specialNames = {}
local espConnection = nil
local espBillboards = {}
local espHighlights = {}

local function updateSpecialNames(text)
    specialNames = {}
    for name in string.gmatch(text, "[^,%s]+") do table.insert(specialNames, string.lower(name)) end
end

local function isSpecial(name)
    local lowerName = string.lower(name)
    for _, sName in ipairs(specialNames) do
        if sName == lowerName then return true end
    end
    return false
end

-- ESP_PLAYERS + список исключений.
-- Выбранные игроки подсвечиваются красным, остальные — синим.
local espEnabled = false
local specialNames = {}
local espConnection = nil
local espBillboards = {}
local espHighlights = {}
local espExceptionButtons = {}
local espExceptionPlayerList = nil

local function isSpecial(name)
    local lowerName = string.lower(name)
    return specialNames[lowerName] == true
end

local function syncEspExceptionNames()
    specialNames = {}
    for player, selected in pairs(espExceptionButtons) do
        if selected then specialNames[string.lower(player.Name)] = true end
    end
end

local function refreshEspExceptionButtons()
    if not espExceptionPlayerList then return end
    for _, child in ipairs(espExceptionPlayerList:GetChildren()) do
        if child:IsA("TextButton") or (child:IsA("TextLabel") and child.Name == "ServerEmpty") then
            child:Destroy()
        end
    end
    espExceptionButtons = {}
    if espExceptionPlayerList then
        espExceptionPlayerList.CanvasPosition = Vector2.new(0, 0)
    end

    local foundPlayer = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            foundPlayer = true
            break
        end
    end

    if not foundPlayer then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Name = "ServerEmpty"
        emptyLabel.Size = UDim2.new(1, 0, 1, 0)
        emptyLabel.Position = UDim2.new(0, 0, 0, 0)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.TextColor3 = Color3.fromRGB(125, 125, 125)
        emptyLabel.Text = "[ SERVER EMPTY ]"
        emptyLabel.TextSize = 16
        emptyLabel.Font = Enum.Font.RobotoMono
        emptyLabel.TextStrokeTransparency = 0.82
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
        emptyLabel.TextYAlignment = Enum.TextYAlignment.Center
        emptyLabel.Parent = espExceptionPlayerList
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, math.max(104, math.min(170, #player.Name * 8 + 46)), 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Text = "[ ] " .. player.Name
            btn.TextSize = 12
            btn.Font = Enum.Font.RobotoMono
            TextStrokeTransparency = 0.82
            btn.AutoButtonColor = false
            btn.Active = true
            btn.Parent = espExceptionPlayerList
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            local btnStroke = Instance.new("UIStroke", btn)
            btnStroke.Color = Color3.fromRGB(0, 0, 0)
            btnStroke.Thickness = 1.2
            espExceptionButtons[player] = false

            btn.MouseButton1Click:Connect(function()
                espExceptionButtons[player] = not espExceptionButtons[player]
                if espExceptionButtons[player] then
                    btn.Text = "[✓] " .. player.Name
                    btn.TextColor3 = Color3.fromRGB(0, 170, 80)
                    btn.BackgroundColor3 = Color3.fromRGB(18, 38, 24)
                else
                    btn.Text = "[ ] " .. player.Name
                    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                    btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                end
                syncEspExceptionNames()
            end)
        end
    end
end

local espRow = Instance.new("Frame")
espRow.Size = UDim2.new(1, 0, 0, 90)
espRow.LayoutOrder = 1
espRow.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
espRow.Parent = Tabs.VISUAL
Instance.new("UICorner", espRow).CornerRadius = UDim.new(0, 6)
local espStroke = Instance.new("UIStroke", espRow)
espStroke.Color = Color3.fromRGB(35, 35, 35)

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, -110, 0, 30)
espTitle.Position = UDim2.new(0, 15, 0, 2)
espTitle.BackgroundTransparency = 1
espTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
espTitle.Text = "[ > ] ESP_PLAYERS"
espTitle.TextSize = 13
espTitle.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Parent = espRow

local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0, 78, 0, 22)
espToggle.Position = UDim2.new(1, -94, 0, 6)
espToggle.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
espToggle.TextColor3 = Color3.fromRGB(180, 55, 55)
espToggle.Text = "[OFF]"
espToggle.TextSize = 12
espToggle.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
espToggle.Parent = espRow
Instance.new("UICorner", espToggle).CornerRadius = UDim.new(0, 4)
local espToggleStroke = Instance.new("UIStroke", espToggle)
espToggleStroke.Color = Color3.fromRGB(0, 0, 0)
espToggleStroke.Thickness = 1.2

local espClear = Instance.new("TextButton")
espClear.Size = UDim2.new(0, 58, 0, 24)
espClear.Position = UDim2.new(0, 12, 0, 47)
espClear.BackgroundColor3 = Color3.fromRGB(24, 12, 12)
espClear.TextColor3 = Color3.fromRGB(235, 70, 70)
espClear.Text = "[CLEAR]"
espClear.TextSize = 11
espClear.Font = Enum.Font.RobotoMono
TextStrokeTransparency = 0.82
espClear.AutoButtonColor = false
espClear.Parent = espRow
Instance.new("UICorner", espClear).CornerRadius = UDim.new(0, 4)
local espClearStroke = Instance.new("UIStroke", espClear)
espClearStroke.Color = Color3.fromRGB(90, 20, 20)
espClearStroke.Thickness = 1.2

espExceptionPlayerList = Instance.new("ScrollingFrame")
espExceptionPlayerList.Size = UDim2.new(1, -82, 0, 42)
espExceptionPlayerList.Position = UDim2.new(0, 78, 0, 36)
espExceptionPlayerList.BackgroundTransparency = 1
espExceptionPlayerList.BorderSizePixel = 0
espExceptionPlayerList.ScrollBarThickness = 0
espExceptionPlayerList.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 80)
espExceptionPlayerList.ScrollBarImageTransparency = 0
espExceptionPlayerList.Active = true
espExceptionPlayerList.ScrollingDirection = Enum.ScrollingDirection.X
espExceptionPlayerList.AutomaticCanvasSize = Enum.AutomaticSize.X
espExceptionPlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
espExceptionPlayerList.Parent = espRow
local espExceptionListStroke = Instance.new("UIStroke", espExceptionPlayerList)
espExceptionListStroke.Color = Color3.fromRGB(0, 0, 0)
espExceptionListStroke.Thickness = 1
local espListLayout = Instance.new("UIListLayout")
espListLayout.FillDirection = Enum.FillDirection.Horizontal
espListLayout.Padding = UDim.new(0, 5)
espListLayout.Parent = espExceptionPlayerList
enableHorizontalArrowScroll(espExceptionPlayerList)

local function startESP()
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.RenderStepped:Connect(function()
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        for player, gui in pairs(espBillboards) do
            if not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChildOfClass("Humanoid") or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                if gui then gui:Destroy() end
                espBillboards[player] = nil
                if espHighlights[player] then espHighlights[player]:Destroy() espHighlights[player] = nil end
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local head = char and char:FindFirstChild("Head")
                if root and humanoid and head and humanoid.Health > 0 then
                    local gui = espBillboards[player]
                    if not gui then
                        gui = Instance.new("BillboardGui")
                        gui.Name = "HackerESP"
                        gui.Size = UDim2.new(0, 220, 0, 70)
                        gui.StudsOffset = Vector3.new(0, 3, 0)
                        gui.AlwaysOnTop = true
                        gui.Adornee = head
                        local label = Instance.new("TextLabel")
                        label.Name = "Text"
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextSize = 20
                        label.Font = Enum.Font.RobotoMono
                        label.TextStrokeTransparency = 0.2
                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label.Parent = gui
                        gui.Parent = head
                        espBillboards[player] = gui
                    end
                    local hl = espHighlights[player]
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "HackerHighlight"
                        hl.Adornee = char
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.Parent = char
                        espHighlights[player] = hl
                    else
                        hl.Adornee = char
                    end
                    local label = gui:FindFirstChild("Text")
                    if label then
                        local dist = localRoot and math.floor((localRoot.Position - root.Position).Magnitude) or 0
                        local hp = math.floor(humanoid.Health)
                        local maxHp = math.floor(humanoid.MaxHealth)
                        label.Text = string.format("[%s]\nHP: %d/%d | Dist: %dm", player.Name, hp, maxHp, dist)
                        if isSpecial(player.Name) then
                            label.TextColor3 = Color3.fromRGB(255, 60, 60)
                            hl.FillColor = Color3.fromRGB(255, 60, 60)
                        else
                            label.TextColor3 = Color3.fromRGB(50, 150, 255)
                            hl.FillColor = Color3.fromRGB(50, 150, 255)
                        end
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
    end)
end

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espToggle.Text = "[ON]"
        refreshEspExceptionButtons()
        startESP()
        espToggle.TextColor3 = Color3.fromRGB(0, 170, 80)
        espToggle.BackgroundColor3 = Color3.fromRGB(20, 45, 28)
    else
        espToggle.Text = "[OFF]"
        if espConnection then espConnection:Disconnect() espConnection = nil end
        for _, gui in pairs(espBillboards) do if gui then gui:Destroy() end end
        for _, hl in pairs(espHighlights) do if hl then hl:Destroy() end end
        espBillboards, espHighlights = {}, {}
        espToggle.TextColor3 = Color3.fromRGB(180, 55, 55)
        espToggle.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    end
end)

espClear.MouseButton1Click:Connect(function()
    -- CLEAR: очистить выбор особых игроков
    for player, btn in pairs(espExceptionButtons) do
        espExceptionButtons[player] = false
        btn.Text = "[ ] " .. player.Name
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    end
    syncEspExceptionNames()
end)

Players.PlayerAdded:Connect(function() refreshEspExceptionButtons() end)
Players.PlayerRemoving:Connect(function(player)
    if espExceptionButtons[player] then espExceptionButtons[player] = nil end
    syncEspExceptionNames()
    task.defer(refreshEspExceptionButtons)
end)
refreshEspExceptionButtons()

-- ==========================================
-- ==========================================
-- INVENTORY VIEWER (VISUAL)
-- Выбор конкретных игроков + компактные панели.
-- ==========================================
local inventoryViewerConnection = nil
local inventoryBillboards = {}

-- Размер панели инвентаря фиксированный: при удалении меняется только дальность
-- видимости. Это сохраняет одинаковый, читаемый вид панели на всей дистанции.
local INVENTORY_PANEL_WIDTH = 250
local INVENTORY_PANEL_HEIGHT = 150
local inventoryViewDistance = 105
local INVENTORY_MIN_VIEW_DISTANCE = 20
local INVENTORY_MAX_VIEW_DISTANCE = 300

local function updateInventoryBillboardScale(gui, player, dt)
    if not gui or not gui.Parent then return end

    local panel = gui:FindFirstChild("Panel")
    if not panel then return end

    -- Screen-space overlay: the panel keeps exactly the same pixel size
    -- regardless of camera distance. DIST only controls visibility.
    panel.Size = UDim2.new(0, INVENTORY_PANEL_WIDTH, 0, INVENTORY_PANEL_HEIGHT)

    local camera = workspace.CurrentCamera
    local character = player and player.Character
    local head = character and character:FindFirstChild("Head")
    if not camera or not head then
        panel.Visible = false
        return
    end

    local distance = (camera.CFrame.Position - head.Position).Magnitude
    if distance > inventoryViewDistance then
        panel.Visible = false
        return
    end

    local worldPosition = head.Position + Vector3.new(0, 2.9, 0)
    local screenPosition, onScreen = camera:WorldToViewportPoint(worldPosition)
    if not onScreen or screenPosition.Z <= 0 then
        panel.Visible = false
        return
    end

    panel.Visible = true
    panel.Position = UDim2.fromOffset(screenPosition.X, screenPosition.Y)
end
local inventorySignatures = {}
local inventorySelected = {}
local inventoryPlayerButtons = {}
local inventoryPlayerList = nil
local inventoryRefreshConnection = nil

local function getInventoryIcon(item)
    if not item then return "" end
    local textureId = item:IsA("Tool") and item.TextureId or ""
    if typeof(textureId) == "string" and textureId ~= "" then return textureId end

    for _, attrName in ipairs({"Icon", "Image", "TextureId", "IconId"}) do
        local value = item:GetAttribute(attrName)
        if typeof(value) == "string" and value ~= "" then return value end
        if typeof(value) == "number" and value > 0 then return "rbxassetid://" .. tostring(value) end
    end

    for _, childName in ipairs({"Icon", "Image", "TextureId"}) do
        local child = item:FindFirstChild(childName)
        if child then
            if child:IsA("StringValue") and child.Value ~= "" then return child.Value end
            if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 0 then
                return "rbxassetid://" .. tostring(child.Value)
            end
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                if child.Image ~= "" then return child.Image end
            end
        end
    end
    return ""
end

local function collectPlayerInventory(player)
    local grouped = {}
    local total = 0
    local backpack = player:FindFirstChildOfClass("Backpack")
    local character = player.Character

    local function addItem(item)
        if not item or not item:IsA("Tool") then return end
        local icon = getInventoryIcon(item)
        local key = item.Name .. "\0" .. icon
        grouped[key] = grouped[key] or {Name = item.Name, Icon = icon, Count = 0}
        grouped[key].Count = grouped[key].Count + 1
        total = total + 1
    end

    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do addItem(item) end
    end
    if character then
        for _, item in ipairs(character:GetChildren()) do addItem(item) end
    end

    local items = {}
    for _, item in pairs(grouped) do table.insert(items, item) end
    table.sort(items, function(a, b) return string.lower(a.Name) < string.lower(b.Name) end)
    return items, total, backpack and "LIVE" or "CHARACTER ONLY"
end

local function createInventoryBillboard(player)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end

    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    if not head then return nil end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HackerInventoryViewer_" .. tostring(player.UserId)
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 20
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    gui:SetAttribute("InventoryPlayerUserId", player.UserId)

    local main = Instance.new("Frame")
    main.Name = "Panel"
    main.Size = UDim2.new(0, INVENTORY_PANEL_WIDTH, 0, INVENTORY_PANEL_HEIGHT)
    main.AnchorPoint = Vector2.new(0.5, 1)
    main.Position = UDim2.fromOffset(0, 0)
    main.Visible = false
    main.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    main.BackgroundTransparency = 0.06
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(42, 42, 42)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -8, 0, 23)
    header.Position = UDim2.new(0, 4, 0, 3)
    header.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 5)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerName"
    nameLabel.Size = UDim2.new(1, -58, 1, 0)
    nameLabel.Position = UDim2.new(0, 6, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(205, 205, 205)
    nameLabel.Text = "[ > ] " .. player.Name
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = header

    local countLabel = Instance.new("TextLabel")
    countLabel.Name = "Count"
    countLabel.Size = UDim2.new(0, 54, 1, 0)
    countLabel.Position = UDim2.new(1, -58, 0, 0)
    countLabel.BackgroundTransparency = 1
    countLabel.TextColor3 = Color3.fromRGB(80, 160, 255)
    countLabel.Text = "0"
    countLabel.TextSize = 9
    countLabel.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    countLabel.TextXAlignment = Enum.TextXAlignment.Right
    countLabel.Parent = header

    local itemsFrame = Instance.new("ScrollingFrame")
    itemsFrame.Name = "Items"
    itemsFrame.Size = UDim2.new(1, -8, 1, -30)
    itemsFrame.Position = UDim2.new(0, 4, 0, 29)
    itemsFrame.BackgroundTransparency = 1
    itemsFrame.BorderSizePixel = 0
    itemsFrame.ScrollBarThickness = 2
    itemsFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65)
    itemsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    itemsFrame.Parent = main

    local padding = Instance.new("UIPadding", itemsFrame)
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 3)
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 2)

    local grid = Instance.new("UIGridLayout", itemsFrame)
    grid.CellSize = UDim2.new(0, 52, 0, 42)
    grid.CellPadding = UDim2.new(0, 4, 0, 4)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    return gui
end

local function clearInventoryItems(gui)
    local itemsFrame = gui and gui:FindFirstChild("Panel") and gui.Panel:FindFirstChild("Items")
    if not itemsFrame then return end
    for _, child in ipairs(itemsFrame:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then child:Destroy() end
    end
end

local function setInventoryEmptyState(gui, text, color)
    local itemsFrame = gui and gui:FindFirstChild("Panel") and gui.Panel:FindFirstChild("Items")
    if not itemsFrame then return end
    clearInventoryItems(gui)
    local empty = Instance.new("TextLabel")
    empty.Size = UDim2.new(1, -8, 0, 32)
    empty.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    empty.BackgroundTransparency = 0.1
    empty.TextColor3 = color or Color3.fromRGB(130, 130, 130)
    empty.Text = text
    empty.TextSize = 8
    empty.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    empty.TextWrapped = true
    empty.Parent = itemsFrame
    Instance.new("UICorner", empty).CornerRadius = UDim.new(0, 5)
end

local function rebuildInventoryBillboard(gui, player)
    if not gui or not gui.Parent then return end
    local panel = gui:FindFirstChild("Panel")
    local itemsFrame = panel and panel:FindFirstChild("Items")
    local header = panel and panel:FindFirstChild("Header")
    if not panel or not itemsFrame or not header then return end

    local countLabel = header:FindFirstChild("Count")
    local nameLabel = header:FindFirstChild("PlayerName")
    local items, total, sourceState = collectPlayerInventory(player)
    local signatureParts = {sourceState, tostring(total)}
    for _, item in ipairs(items) do table.insert(signatureParts, item.Name .. "x" .. tostring(item.Count) .. "[" .. item.Icon .. "]") end
    local signature = table.concat(signatureParts, "|")

    if inventorySignatures[player] == signature then
        if nameLabel then nameLabel.Text = "[ > ] " .. player.Name end
        return
    end
    inventorySignatures[player] = signature
    clearInventoryItems(gui)

    if nameLabel then nameLabel.Text = "[ > ] " .. player.Name end
    if countLabel then
        countLabel.Text = tostring(total) .. " ITEM" .. (total == 1 and "" or "S")
        countLabel.TextColor3 = total > 0 and Color3.fromRGB(80, 160, 255) or Color3.fromRGB(130, 130, 130)
    end

    if #items == 0 then
        if sourceState == "CHARACTER ONLY" then
            setInventoryEmptyState(gui, "[ NO BACKPACK DATA ]\nEQUIPPED ITEMS ONLY", Color3.fromRGB(160, 120, 80))
        else
            setInventoryEmptyState(gui, "[ EMPTY ]\nNO TOOL ITEMS", Color3.fromRGB(130, 130, 130))
        end
        return
    end

    for index, item in ipairs(items) do
        local card = Instance.new("Frame")
        card.Name = "Item_" .. index
        card.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        card.BorderSizePixel = 0
        card.LayoutOrder = index
        card.Parent = itemsFrame
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)
        Instance.new("UIStroke", card).Color = Color3.fromRGB(34, 34, 34)

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.Position = UDim2.new(0.5, -12, 0, 2)
        icon.BackgroundTransparency = 1
        icon.Image = item.Icon
        icon.ImageTransparency = item.Icon == "" and 1 or 0
        icon.Parent = card

        local fallback = Instance.new("TextLabel")
        fallback.Size = UDim2.new(0, 24, 0, 24)
        fallback.Position = UDim2.new(0.5, -12, 0, 2)
        fallback.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        fallback.TextColor3 = Color3.fromRGB(150, 150, 150)
        fallback.Text = string.sub(item.Name, 1, 1):upper()
        fallback.TextSize = 11
        fallback.Font = Enum.Font.RobotoMono
        TextStrokeTransparency = 0.82
        fallback.Visible = item.Icon == ""
        fallback.Parent = card
        Instance.new("UICorner", fallback).CornerRadius = UDim.new(0, 4)

        local itemName = Instance.new("TextLabel")
        itemName.Size = UDim2.new(1, -4, 0, 10)
        itemName.Position = UDim2.new(0, 2, 0, 24)
        itemName.BackgroundTransparency = 1
        itemName.TextColor3 = Color3.fromRGB(190, 190, 190)
        itemName.Text = item.Name
        itemName.TextSize = 9
        itemName.Font = Enum.Font.RobotoMono
        TextStrokeTransparency = 0.82
        itemName.TextTruncate = Enum.TextTruncate.AtEnd
        itemName.Parent = card

        local amount = Instance.new("TextLabel")
        amount.Size = UDim2.new(1, -4, 0, 9)
        amount.Position = UDim2.new(0, 2, 1, -10)
        amount.BackgroundTransparency = 1
        amount.TextColor3 = Color3.fromRGB(80, 160, 255)
        amount.Text = "x" .. tostring(item.Count)
        amount.TextSize = 9
        amount.Font = Enum.Font.RobotoMono
        TextStrokeTransparency = 0.82
        amount.Parent = card
    end
end

local function cleanupInventoryBillboards()
    for player, gui in pairs(inventoryBillboards) do
        if gui then gui:Destroy() end
        inventoryBillboards[player] = nil
        inventorySignatures[player] = nil
    end
end

local function updateInventoryPlayerButtons()
    if inventoryPlayerList then
        inventoryPlayerList.CanvasPosition = Vector2.new(0, 0)
    end
    local alive = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then alive[player] = true end
    end

    local emptyLabel = inventoryPlayerList and inventoryPlayerList:FindFirstChild("ServerEmpty")
    if emptyLabel then emptyLabel:Destroy() end

    if inventoryPlayerList and next(alive) == nil then
        -- Полностью тот же режим SERVER EMPTY, что и в TP / FLING / ESP:
        -- список не прокручивается, стрелки скрыты, индикатор стоит по центру.
        inventoryPlayerList.CanvasPosition = Vector2.new(0, 0)
        inventoryPlayerList.ScrollingEnabled = false

        local layout = inventoryPlayerList:FindFirstChildOfClass("UIListLayout")
        if layout then
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout.VerticalAlignment = Enum.VerticalAlignment.Center
        end

        local label = Instance.new("TextLabel")
        label.Name = "ServerEmpty"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(135, 135, 135)
        label.Text = "[ SERVER EMPTY ]"
        label.TextSize = 16
        label.Font = Enum.Font.RobotoMono
        label.TextStrokeTransparency = 0.82
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.LayoutOrder = -1
        label.ZIndex = 7
        label.Parent = inventoryPlayerList

        local scrollData = horizontalArrowFrames[inventoryPlayerList]
        if scrollData then
            if scrollData.tween then
                scrollData.tween:Cancel()
                scrollData.tween = nil
            end
            scrollData.left.Visible = false
            scrollData.right.Visible = false
            if scrollData.progressTrack then scrollData.progressTrack.Visible = true end
            if scrollData.progressFill then
                scrollData.progressFill.Size = UDim2.new(0, 28, 1, 0)
                scrollData.progressFill.Position = UDim2.new(0.5, -14, 0, 0)
            end
        end
    elseif inventoryPlayerList then
        local layout = inventoryPlayerList:FindFirstChildOfClass("UIListLayout")
        if layout then
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            layout.VerticalAlignment = Enum.VerticalAlignment.Top
        end
    end

    for player, button in pairs(inventoryPlayerButtons) do
        if not alive[player] then
            if button then button:Destroy() end
            inventoryPlayerButtons[player] = nil
            inventorySelected[player] = nil
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not inventoryPlayerButtons[player] then
            local playerList = inventoryPlayerList
            if playerList then
                local btn = Instance.new("TextButton")
                btn.Name = "Player_" .. player.UserId
                btn.Size = UDim2.new(0, math.max(90, math.min(150, #player.Name * 8 + 38)), 0, 24)
                btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                btn.Text = "[ ] " .. player.Name
                btn.TextSize = 12
                btn.Font = Enum.Font.RobotoMono
                TextStrokeTransparency = 0.82
                btn.AutoButtonColor = false
                btn.Active = true
                btn.LayoutOrder = player.UserId
                btn.ZIndex = 6
                btn.Parent = playerList
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                local bs = Instance.new("UIStroke", btn)
                bs.Color = Color3.fromRGB(0, 0, 0)
                    bs.Thickness = 1.2
                bs.Thickness = 1.2

                btn.MouseButton1Click:Connect(function()
                    inventorySelected[player] = not inventorySelected[player]
                    local selected = inventorySelected[player]
                    btn.Text = (selected and "[✓] " or "[ ] ") .. player.Name
                    btn.TextColor3 = selected and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(180, 180, 180)
                    bs.Color = Color3.fromRGB(0, 0, 0)
                    bs.Thickness = 1.2
                    if not selected then
                        if inventoryBillboards[player] then inventoryBillboards[player]:Destroy() end
                        inventoryBillboards[player] = nil
                        inventorySignatures[player] = nil
                    end
                end)
                inventoryPlayerButtons[player] = btn
            end
        end
    end

    for player, btn in pairs(inventoryPlayerButtons) do
        if player ~= "__container" and btn and btn:IsA("TextButton") then
            local selected = inventorySelected[player] == true
            btn.Text = (selected and "[✓] " or "[ ] ") .. player.Name
            btn.TextColor3 = selected and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(180, 180, 180)
            local bs = btn:FindFirstChildOfClass("UIStroke")
            if bs then bs.Color = Color3.fromRGB(0, 0, 0)
                    bs.Thickness = 1.2 end
        end
    end
end

local function createInventoryViewerControl(tabName, order)
    local targetTab = Tabs[tabName]
    if not targetTab then return end

    -- Компактная карточка: заголовок -> настройки -> отдельная строка игроков.
    local row = Instance.new("Frame")
    row.Name = "InventoryViewerControl"
    row.Size = UDim2.new(1, 0, 0, 148)
    row.LayoutOrder = order
    row.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    row.Parent = targetTab
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = Color3.fromRGB(35, 35, 35)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -115, 0, 25)
    title.Position = UDim2.new(0, 15, 0, 3)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.Text = "[ > ] INVENTORY_VIEWER"
    title.TextSize = 13
    title.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -115, 0, 15)
    sub.Position = UDim2.new(0, 15, 0, 26)
    sub.BackgroundTransparency = 1
    sub.TextColor3 = Color3.fromRGB(105, 105, 105)
    sub.Text = "[ SELECT TARGETS ]  ONLY SELECTED PLAYERS"
    sub.TextSize = 10
    sub.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = row

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 78, 0, 22)
    toggleBtn.Position = UDim2.new(1, -88, 0, 7)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    toggleBtn.TextColor3 = Color3.fromRGB(180, 55, 55)
    toggleBtn.Text = "[OFF]"
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = row
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = Color3.fromRGB(0, 0, 0)

    -- Строка настроек. Все три элемента стоят на одной линии и не налезают друг на друга.
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(0, 38, 0, 20)
    distanceLabel.Position = UDim2.new(0, 15, 0, 47)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
    distanceLabel.Text = "DIST:"
    distanceLabel.TextSize = 10
    distanceLabel.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Parent = row

    local distanceBox = Instance.new("TextBox")
    distanceBox.Size = UDim2.new(0, 60, 0, 24)
    distanceBox.Position = UDim2.new(0, 53, 0, 46)
    distanceBox.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    distanceBox.TextColor3 = Color3.fromRGB(170, 170, 170)
    distanceBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    distanceBox.Text = tostring(inventoryViewDistance)
    distanceBox.PlaceholderText = "20-300"
    distanceBox.TextSize = 10
    distanceBox.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    distanceBox.ClearTextOnFocus = false
    distanceBox.Parent = row
    Instance.new("UICorner", distanceBox).CornerRadius = UDim.new(0, 4)
    local distanceStroke = Instance.new("UIStroke", distanceBox)
    distanceStroke.Color = Color3.fromRGB(45, 45, 45)

    local allBtn = Instance.new("TextButton")
    allBtn.Size = UDim2.new(0, 54, 0, 24)
    allBtn.Position = UDim2.new(0, 120, 0, 46)
    allBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    allBtn.TextColor3 = Color3.fromRGB(100, 150, 110)
    allBtn.Text = "[ALL]"
    allBtn.TextSize = 11
    allBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    allBtn.AutoButtonColor = false
    allBtn.Parent = row
    Instance.new("UICorner", allBtn).CornerRadius = UDim.new(0, 4)
    local allBtnStroke = Instance.new("UIStroke", allBtn)
    allBtnStroke.Color = Color3.fromRGB(0, 0, 0)
    allBtnStroke.Thickness = 1

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 70, 0, 24)
    clearBtn.Position = UDim2.new(0, 179, 0, 46)
    clearBtn.BackgroundColor3 = Color3.fromRGB(24, 12, 12)
    clearBtn.TextColor3 = Color3.fromRGB(235, 70, 70)
    clearBtn.Text = "[CLEAR]"
    clearBtn.TextSize = 11
    clearBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    clearBtn.AutoButtonColor = false
    clearBtn.Parent = row
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)
    local clearBtnStroke = Instance.new("UIStroke", clearBtn)
    clearBtnStroke.Color = Color3.fromRGB(90, 20, 20)
    clearBtnStroke.Thickness = 1.2

    -- Отдельная видимая область для выбора игроков.
    local playerList = Instance.new("ScrollingFrame")
    playerList.Name = "PlayerList"
    playerList.Size = UDim2.new(1, -16, 0, 42)
    playerList.Position = UDim2.new(0, 8, 0, 82)
    playerList.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    playerList.BackgroundTransparency = 0
    playerList.BorderSizePixel = 0
    playerList.ScrollBarThickness = 0
    playerList.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 80)
    playerList.ScrollBarImageTransparency = 0
    playerList.ScrollingDirection = Enum.ScrollingDirection.X
    playerList.CanvasSize = UDim2.new(0, 0, 0, 40)
    playerList.AutomaticCanvasSize = Enum.AutomaticSize.None
    playerList.ClipsDescendants = true
    playerList.Active = true
    playerList.ZIndex = 5
    playerList.Parent = row
    Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 4)
    local listStroke = Instance.new("UIStroke", playerList)
    listStroke.Color = Color3.fromRGB(0, 0, 0)
    listStroke.Thickness = 1

    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Horizontal
    list.HorizontalAlignment = Enum.HorizontalAlignment.Left
    list.VerticalAlignment = Enum.VerticalAlignment.Top
    list.Padding = UDim.new(0, 5)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = playerList

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingLeft = UDim.new(0, 5)
    listPadding.PaddingRight = UDim.new(0, 5)
    listPadding.PaddingTop = UDim.new(0, 4)
    listPadding.Parent = playerList
    enableHorizontalArrowScroll(playerList)

    local function updatePlayerListCanvas()
        task.defer(function()
            local width = math.max(list.AbsoluteContentSize.X + 10, playerList.AbsoluteSize.X)
            playerList.CanvasSize = UDim2.new(0, width, 0, playerList.AbsoluteSize.Y)
            local maxX = math.max(0, width - playerList.AbsoluteSize.X)
            local x = math.clamp(playerList.CanvasPosition.X, 0, maxX)
            if math.abs(playerList.CanvasPosition.X - x) > 0.01 then
                playerList.CanvasPosition = Vector2.new(x, 0)
            end
        end)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePlayerListCanvas)
    playerList:GetPropertyChangedSignal("AbsoluteSize"):Connect(updatePlayerListCanvas)

    inventoryPlayerList = playerList

    local enabled = false
    local elapsed = 0

    local function applyInventoryViewDistance()
        local value = tonumber(distanceBox.Text)
        if not value then value = inventoryViewDistance end
        value = math.clamp(math.floor(value + 0.5), INVENTORY_MIN_VIEW_DISTANCE, INVENTORY_MAX_VIEW_DISTANCE)
        inventoryViewDistance = value
        distanceBox.Text = tostring(value)
        for _, gui in pairs(inventoryBillboards) do
        end
    end

    distanceBox.FocusLost:Connect(function()
        applyInventoryViewDistance()
    end)

    local function updateButton()
        if enabled then
            toggleBtn.Text = "[ON]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(15, 30, 20)}):Play()
            TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80)}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 45, 28), TextColor3 = Color3.fromRGB(0, 170, 80)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80)}):Play()
        else
            toggleBtn.Text = "[OFF]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}):Play()
            TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(35, 35, 35)}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(12, 12, 12), TextColor3 = Color3.fromRGB(180, 55, 55)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 0, 0)}):Play()
        end
    end

    -- Сначала создаём список, затем наполняем его игроками.
    updateInventoryPlayerButtons()
    task.defer(function()
        updateInventoryPlayerButtons()
        task.wait()
        updatePlayerListCanvas()
    end)

    if inventoryRefreshConnection then inventoryRefreshConnection:Disconnect() end
    inventoryRefreshConnection = Players.PlayerAdded:Connect(function()
        task.defer(function()
            updateInventoryPlayerButtons()
            updatePlayerListCanvas()
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        inventorySelected[player] = nil
        if inventoryBillboards[player] then inventoryBillboards[player]:Destroy() end
        inventoryBillboards[player] = nil
        inventorySignatures[player] = nil
        task.defer(function()
            updateInventoryPlayerButtons()
            updatePlayerListCanvas()
        end)
    end)

    allBtn.MouseButton1Click:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then inventorySelected[player] = true end
        end
        updateInventoryPlayerButtons()
        updatePlayerListCanvas()
    end)

    clearBtn.MouseButton1Click:Connect(function()
        inventorySelected = {}
        cleanupInventoryBillboards()
        updateInventoryPlayerButtons()
        updatePlayerListCanvas()
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateButton()
        if enabled then
            -- По умолчанию при включении показываем инвентари всех игроков.
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    inventorySelected[player] = true
                end
            end
            updateInventoryPlayerButtons()
            elapsed = 0
            inventoryViewerConnection = RunService.Heartbeat:Connect(function(dt)
                for player, gui in pairs(inventoryBillboards) do
                    if inventorySelected[player] and gui and gui.Parent then
                        updateInventoryBillboardScale(gui, player, dt)
                    end
                end

                elapsed = elapsed + dt
                if elapsed < 0.4 then return end
                elapsed = 0
                updateInventoryPlayerButtons()

                local activePlayers = {}
                for player, selected in pairs(inventorySelected) do
                    if selected and player ~= LocalPlayer and player.Parent then
                        local character = player.Character
                        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        local head = character and character:FindFirstChild("Head")
                        if head and humanoid and humanoid.Health > 0 then
                            activePlayers[player] = true
                            local gui = inventoryBillboards[player]
                            if not gui or not gui.Parent then
                                if gui then gui:Destroy() end
                                gui = createInventoryBillboard(player)
                                inventoryBillboards[player] = gui
                                inventorySignatures[player] = nil
                            end
                            if gui then rebuildInventoryBillboard(gui, player) end
                        end
                    end
                end

                for player, gui in pairs(inventoryBillboards) do
                    if not activePlayers[player] then
                        if gui then gui:Destroy() end
                        inventoryBillboards[player] = nil
                        inventorySignatures[player] = nil
                    end
                end
            end)
        else
            if inventoryViewerConnection then inventoryViewerConnection:Disconnect() inventoryViewerConnection = nil end
            cleanupInventoryBillboards()
        end
    end)
end

createInventoryViewerControl("VISUAL", 5)

local fullbrightConn = nil
local origBrightness, origClock, origShadows, origOutdoor, origAmbient

createToggleControl("VISUAL", "FULLBRIGHT", 2, function(enabled)
    if enabled then
        origBrightness = Lighting.Brightness
        origClock = Lighting.ClockTime
        origShadows = Lighting.GlobalShadows
        origOutdoor = Lighting.OutdoorAmbient
        origAmbient = Lighting.Ambient
        fullbrightConn = RunService.RenderStepped:Connect(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        end)
    else
        if fullbrightConn then fullbrightConn:Disconnect() fullbrightConn = nil end
        if origBrightness then Lighting.Brightness = origBrightness end
        if origClock then Lighting.ClockTime = origClock end
        if origShadows ~= nil then Lighting.GlobalShadows = origShadows end
        if origOutdoor then Lighting.OutdoorAmbient = origOutdoor end
        if origAmbient then Lighting.Ambient = origAmbient end
    end
end)

local noFogConn = nil
local origFogEnd, origFogStart
local origAtmosphereDensities = {}

createToggleControl("VISUAL", "NO_FOG", 3, function(enabled)
    if enabled then
        origFogEnd = Lighting.FogEnd
        origFogStart = Lighting.FogStart
        
        origAtmosphereDensities = {}
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Atmosphere") then
                origAtmosphereDensities[child] = child.Density
            end
        end

        noFogConn = RunService.RenderStepped:Connect(function()
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 0
            for _, child in ipairs(Lighting:GetChildren()) do
                if child:IsA("Atmosphere") then
                    child.Density = 0
                end
            end
        end)
    else
        if noFogConn then
            noFogConn:Disconnect()
            noFogConn = nil
        end
        if origFogEnd then Lighting.FogEnd = origFogEnd end
        if origFogStart then Lighting.FogStart = origFogStart end
        
        for child, density in pairs(origAtmosphereDensities) do
            if child and child.Parent then
                child.Density = density
            end
        end
        origAtmosphereDensities = {}
    end
end)

local aimbotConn = nil

-- AIMBOT + FOV полностью объединены в один модуль.
-- RMB (правая кнопка мыши) = удерживать для наведения.
-- FOV_RADIUS = радиус FOV в пикселях, меняется прямо в меню.
-- AIM_SMOOTHNESS = плавность наведения.

local function createAimbotControl(tabName, name, defaultFov, order)
    local targetTab = Tabs[tabName]
    if not targetTab then return end

    local FOV_RADIUS = defaultFov
    local AIM_SMOOTHNESS = 0.92
    local MAX_DISTANCE = 2000

    local fovGui = nil
    local fovCircle = nil
    local fovStroke = nil
    local currentTarget = nil
    local enabled = false

    -- ==========================================
    -- UI AIMBOT + FOV RADIUS
    -- ==========================================
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 54)
    row.LayoutOrder = order
    row.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    row.Parent = targetTab

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = Color3.fromRGB(35, 35, 35)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -155, 0, 38)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.Text = "[ > ] " .. name
    title.TextSize = 13
    title.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local fovBox = Instance.new("TextBox")
    fovBox.Size = UDim2.new(0, 50, 0, 26)
    fovBox.Position = UDim2.new(1, -150, 0, 6)
    fovBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    fovBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    fovBox.Text = tostring(defaultFov)
    fovBox.TextSize = 13
    fovBox.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    fovBox.ClearTextOnFocus = false
    fovBox.Parent = row
    Instance.new("UICorner", fovBox).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", fovBox).Color = Color3.fromRGB(40, 40, 40)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 78, 0, 22)
    toggleBtn.Position = UDim2.new(1, -88, 0, 7)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    toggleBtn.TextColor3 = Color3.fromRGB(180, 55, 55)
    toggleBtn.Text = "[OFF]"
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.RobotoMono
    TextStrokeTransparency = 0.82
    toggleBtn.Parent = row
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = Color3.fromRGB(0, 0, 0)

    -- ==========================================
    -- AIMBOT / FOV LOGIC
    -- ==========================================
    local function getScreenCenter(camera)
        local viewport = camera.ViewportSize
        return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    end

    local function isValidTarget(player, character, humanoid, head)
        if player == LocalPlayer or not player.Parent then return false end
        if not character or not character.Parent then return false end
        if not humanoid or humanoid.Health <= 0 then return false end
        if not head or not head.Parent then return false end

        local localCharacter = LocalPlayer.Character
        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        if localRoot and (head.Position - localRoot.Position).Magnitude > MAX_DISTANCE then
            return false
        end


        return true
    end

    local function getTarget()
        local camera = workspace.CurrentCamera
        if not camera then return nil end

        local screenCenter = getScreenCenter(camera)
        local bestTarget = nil
        local bestScreenDistance = FOV_RADIUS
        local bestWorldDistance = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local head = character and character:FindFirstChild("Head")

                if isValidTarget(player, character, humanoid, head) then
                    local screenPosition, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen and screenPosition.Z > 0 then
                        local screenPoint = Vector2.new(screenPosition.X, screenPosition.Y)
                        local screenDistance = (screenPoint - screenCenter).Magnitude
                        local worldDistance = (head.Position - camera.CFrame.Position).Magnitude

                        if screenDistance <= FOV_RADIUS then
                            if screenDistance < bestScreenDistance
                                or (math.abs(screenDistance - bestScreenDistance) < 0.5 and worldDistance < bestWorldDistance) then
                                bestScreenDistance = screenDistance
                                bestWorldDistance = worldDistance
                                bestTarget = head
                            end
                        end
                    end
                end
            end
        end

        return bestTarget
    end

    local function updateFovCircle(camera)
        if not fovCircle then return end

        local viewport = camera.ViewportSize
        fovCircle.Size = UDim2.fromOffset(FOV_RADIUS * 2, FOV_RADIUS * 2)
        fovCircle.Position = UDim2.fromOffset(viewport.X * 0.5, viewport.Y * 0.5)
    end

    local function destroyFov()
        currentTarget = nil
        if fovGui then
            fovGui:Destroy()
            fovGui = nil
        end
        fovCircle = nil
        fovStroke = nil
    end

    local function startAimbot()
        if aimbotConn then
            aimbotConn:Disconnect()
            aimbotConn = nil
        end

        if fovGui then fovGui:Destroy() end
        fovGui = Instance.new("ScreenGui")
        fovGui.Name = "HackerAimbotFOV"
        fovGui.IgnoreGuiInset = true
        fovGui.ResetOnSpawn = false
        fovGui.DisplayOrder = 999
        fovGui.Parent = PlayerGui

        fovCircle = Instance.new("Frame")
        fovCircle.Name = "FOVCircle"
        fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        fovCircle.BackgroundTransparency = 1
        fovCircle.BorderSizePixel = 0
        fovCircle.Parent = fovGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = fovCircle

        fovStroke = Instance.new("UIStroke")
        fovStroke.Thickness = 1.5
        fovStroke.Transparency = 0.15
        fovStroke.Color = Color3.fromRGB(0, 255, 120)
        fovStroke.Parent = fovCircle

        local camera = workspace.CurrentCamera
        if camera then updateFovCircle(camera) end

        aimbotConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            if not cam then return end

            updateFovCircle(cam)

            -- Правая кнопка мыши: удерживаем для наведения.
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                currentTarget = nil
                if fovStroke then
                    fovStroke.Color = Color3.fromRGB(0, 255, 120)
                end
                return
            end

            if currentTarget then
                -- После захвата цель фиксируется до отпускания RMB.
                -- FOV повторно не проверяем, чтобы движение мышью не срывало захват.
                local targetCharacter = currentTarget.Parent
                local targetPlayer = targetCharacter and Players:GetPlayerFromCharacter(targetCharacter)
                local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

                if not targetPlayer or not targetCharacter or not targetCharacter.Parent
                    or not targetHumanoid or targetHumanoid.Health <= 0
                    or not currentTarget.Parent then
                    currentTarget = nil
                end
            end

            if not currentTarget then
                currentTarget = getTarget()
            end

            if currentTarget then
                if fovStroke then
                    fovStroke.Color = Color3.fromRGB(255, 255, 255)
                end

                local desiredCFrame = CFrame.lookAt(cam.CFrame.Position, currentTarget.Position)
                cam.CFrame = cam.CFrame:Lerp(desiredCFrame, AIM_SMOOTHNESS)
            else
                if fovStroke then
                    fovStroke.Color = Color3.fromRGB(0, 255, 120)
                end
            end
        end)
    end

    local function stopAimbot()
        if aimbotConn then
            aimbotConn:Disconnect()
            aimbotConn = nil
        end
        destroyFov()
    end

    local function refreshFovValue()
        local value = tonumber(fovBox.Text)
        if not value then
            fovBox.Text = tostring(FOV_RADIUS)
            return
        end

        FOV_RADIUS = math.clamp(math.floor(value), 20, 1000)
        fovBox.Text = tostring(FOV_RADIUS)

        if enabled and workspace.CurrentCamera then
            updateFovCircle(workspace.CurrentCamera)
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled

        if enabled then
            toggleBtn.Text = "[ON]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(15, 30, 20)}):Play()
            TweenService:Create(rowStroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80), Thickness = 1.2}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 45, 28), TextColor3 = Color3.fromRGB(0, 170, 80)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80)}):Play()
            startAimbot()
        else
            toggleBtn.Text = "[OFF]"
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}):Play()
            TweenService:Create(rowStroke, tweenInfo, {Color = Color3.fromRGB(35, 35, 35), Thickness = 1}):Play()
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(12, 12, 12), TextColor3 = Color3.fromRGB(180, 55, 55)}):Play()
            TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 0, 0)}):Play()
            stopAimbot()
        end
    end)

    fovBox.FocusLost:Connect(refreshFovValue)
end

-- FREECAM: камера без видимого шара; скорость движения настраивается в VISUAL.
-- Код изолирован в do-блоке, чтобы не увеличивать число локальных регистров основного скрипта.
do
    local FC = {
        active = false, camera = nil, root = nil, savedAnchored = nil,
        savedCameraType = nil, savedSubject = nil, savedMouseBehavior = nil,
        savedMouseIcon = nil, savedCFrame = nil, savedFov = nil,
        position = nil, yaw = 0, pitch = 0, mouseHeld = false, speed = 42,
        keys = {}, connections = {}, render = nil,
    }

    local function fcCleanupConnections()
        for _, connection in ipairs(FC.connections) do
            pcall(function() connection:Disconnect() end)
        end
        table.clear(FC.connections)
        if FC.render then FC.render:Disconnect(); FC.render = nil end
    end

    local function fcStop()
        if not FC.active then return end
        FC.active = false
        fcCleanupConnections()
        UserInputService.MouseBehavior = FC.savedMouseBehavior or Enum.MouseBehavior.Default
        if FC.savedMouseIcon ~= nil then UserInputService.MouseIconEnabled = FC.savedMouseIcon end
        if FC.root and FC.root.Parent and FC.savedAnchored ~= nil then
            pcall(function()
                FC.root.AssemblyLinearVelocity = Vector3.zero
                FC.root.AssemblyAngularVelocity = Vector3.zero
                FC.root.Anchored = FC.savedAnchored
            end)
        end
        local cam = workspace.CurrentCamera or FC.camera
        if cam then
            cam.CameraType = FC.savedCameraType or Enum.CameraType.Custom
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            cam.CameraSubject = humanoid or FC.savedSubject
            if FC.savedCFrame then cam.CFrame = FC.savedCFrame end
            if FC.savedFov then cam.FieldOfView = FC.savedFov end
        end
        table.clear(FC.keys)
        FC.camera, FC.root, FC.position = nil, nil, nil
        FC.mouseHeld = false
    end

    local function fcStart()
        if FC.active then return end
        local cam = workspace.CurrentCamera
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not cam or not root then
            warn("[FREECAM] Не найден персонаж или камера.")
            return false
        end
        FC.active = true
        FC.camera, FC.root = cam, root
        FC.savedAnchored = root.Anchored
        FC.savedCameraType, FC.savedSubject = cam.CameraType, cam.CameraSubject
        FC.savedCFrame, FC.savedFov = cam.CFrame, cam.FieldOfView
        FC.savedMouseBehavior, FC.savedMouseIcon = UserInputService.MouseBehavior, UserInputService.MouseIconEnabled
        local look = cam.CFrame.LookVector
        FC.position = cam.CFrame.Position
        FC.yaw = math.atan2(-look.X, -look.Z)
        FC.pitch = math.asin(math.clamp(look.Y, -0.98, 0.98))
        table.clear(FC.keys)


        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Anchored = true
        cam.CameraType = Enum.CameraType.Scriptable
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default

        table.insert(FC.connections, UserInputService.InputBegan:Connect(function(input, processed)
            if not FC.active then return end
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                FC.mouseHeld = true
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            elseif not processed and (input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl) then
                FC.keys[input.KeyCode] = true
            end
        end))
        table.insert(FC.connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                FC.mouseHeld = false
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
            FC.keys[input.KeyCode] = nil
        end))
        table.insert(FC.connections, UserInputService.InputChanged:Connect(function(input)
            if not FC.active then return end
            if FC.mouseHeld and input.UserInputType == Enum.UserInputType.MouseMovement then
                FC.yaw = FC.yaw - input.Delta.X * 0.0025
                FC.pitch = math.clamp(FC.pitch - input.Delta.Y * 0.0025, math.rad(-85), math.rad(85))
            end
        end))
        FC.render = RunService.RenderStepped:Connect(function(dt)
            if not FC.active or not FC.camera then return end
            local rotation = CFrame.fromOrientation(FC.pitch, FC.yaw, 0)
            local move = Vector3.zero
            if FC.keys[Enum.KeyCode.W] then move += rotation.LookVector end
            if FC.keys[Enum.KeyCode.S] then move -= rotation.LookVector end
            if FC.keys[Enum.KeyCode.D] then move += rotation.RightVector end
            if FC.keys[Enum.KeyCode.A] then move -= rotation.RightVector end
            local frameDt = math.clamp(dt, 0, 0.05)
            if move.Magnitude > 0 then FC.position += move.Unit * FC.speed * frameDt end

            -- Вертикальная скорость постоянная и зависит от настройки FREECAM SPEED.
            -- Ctrl — более быстрое снижение; Space — подъём; Shift — обычный спуск.
            if FC.keys[Enum.KeyCode.LeftControl] or FC.keys[Enum.KeyCode.RightControl] then
                FC.position += Vector3.yAxis * -(FC.speed * (24 / 42)) * frameDt
            elseif FC.keys[Enum.KeyCode.Space] then
                FC.position += Vector3.yAxis * (FC.speed * (20 / 42)) * frameDt
            elseif FC.keys[Enum.KeyCode.LeftShift] or FC.keys[Enum.KeyCode.RightShift] then
                FC.position += Vector3.yAxis * -(FC.speed * (20 / 42)) * frameDt
            end

            FC.camera.CFrame = CFrame.lookAt(FC.position, FC.position + rotation.LookVector)
        end)
        return true
    end

    -- Единая строка FREECAM: скорость и переключатель в одном классическом элементе.
    local function createFreecamControl()
        local row = Instance.new("Frame")
        row.Name = "FreecamControl"
        row.Size = UDim2.new(1, 0, 0, 38)
        row.LayoutOrder = 5
        row.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
        row.Parent = Tabs.VISUAL
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", row)
        stroke.Color = Color3.fromRGB(35, 35, 35)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -190, 1, 0)
        title.Position = UDim2.new(0, 15, 0, 0)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 200)
        title.Text = "[ > ] FREECAM / SPEED"
        title.TextSize = 13
        title.Font = Enum.Font.RobotoMono
        TextStrokeTransparency = 0.82
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = row

        local speedBox = Instance.new("TextBox")
        speedBox.Name = "FreecamSpeedValue"
        speedBox.Size = UDim2.new(0, 50, 0, 24)
        speedBox.Position = UDim2.new(1, -155, 0.5, -12)
        speedBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        speedBox.TextColor3 = Color3.fromRGB(200, 200, 200)
        speedBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
        speedBox.Text = tostring(FC.speed)
        speedBox.PlaceholderText = "1-200"
        speedBox.TextSize = 13
        speedBox.Font = Enum.Font.RobotoMono
        TextStrokeTransparency = 0.82
        speedBox.ClearTextOnFocus = false
        speedBox.Parent = row
        Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 4)
        local boxStroke = Instance.new("UIStroke", speedBox)
        boxStroke.Color = Color3.fromRGB(40, 40, 40)

        speedBox.FocusLost:Connect(function()
            local value = tonumber(speedBox.Text)
            if not value then speedBox.Text = tostring(FC.speed); return end
            FC.speed = math.clamp(math.floor(value), 1, 200)
            speedBox.Text = tostring(FC.speed)
        end)

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 78, 0, 22)
        toggleBtn.Position = UDim2.new(1, -94, 0.5, -12)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        toggleBtn.TextColor3 = Color3.fromRGB(180, 55, 55)
        toggleBtn.Text = "[OFF]"
        toggleBtn.TextSize = 12
        toggleBtn.Font = Enum.Font.RobotoMono
        TextStrokeTransparency = 0.82
        toggleBtn.Parent = row
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
        local tStroke = Instance.new("UIStroke", toggleBtn)
        tStroke.Color = Color3.fromRGB(0, 0, 0)
        local enabled = false
        toggleBtn.MouseButton1Click:Connect(function()
            enabled = not enabled
            if enabled then
                toggleBtn.Text = "[ON]"
                TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(15, 30, 20)}):Play()
                TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80), Thickness = 1.2}):Play()
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 45, 28), TextColor3 = Color3.fromRGB(0, 170, 80)}):Play()
                TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 170, 80)}):Play()
                if not fcStart() then task.defer(fcStop) end
            else
                toggleBtn.Text = "[OFF]"
                TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}):Play()
                TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(35, 35, 35), Thickness = 1}):Play()
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(12, 12, 12), TextColor3 = Color3.fromRGB(180, 55, 55)}):Play()
                TweenService:Create(tStroke, tweenInfo, {Color = Color3.fromRGB(0, 0, 0)}):Play()
                fcStop()
            end
        end)
    end
    createFreecamControl()

    -- В случае респавна освобождаем управление камерой.
    table.insert(FC.connections, LocalPlayer.CharacterAdded:Connect(function()
        if FC.active then task.defer(fcStop) end
    end))
end

createAimbotControl("VISUAL", "AIMBOT / FOV", 180, 4)

-- ==========================================
-- SETTINGS МОДУЛИ
-- ==========================================
createHackerButtonCard("SETTINGS", "UI_THEME_DARK", 1, function()
    print("[SETTINGS]: Тема интерфейса установлена.")
end)

local antiAfkConn = nil
createToggleControl("SETTINGS", "ANTI_AFK", 2, function(enabled)
    if enabled then
        antiAfkConn = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    else
        if antiAfkConn then
            antiAfkConn:Disconnect()
            antiAfkConn = nil
        end
    end
end)

local instantPromptConn = nil
local originalHoldDurations = {}

createToggleControl("SETTINGS", "INSTANT_PROMPT", 3, function(enabled)
    if enabled then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                originalHoldDurations[desc] = desc.HoldDuration
                desc.HoldDuration = 0
            end
        end
        instantPromptConn = workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") then
                originalHoldDurations[desc] = desc.HoldDuration
                desc.HoldDuration = 0
            end
        end)
    else
        if instantPromptConn then
            instantPromptConn:Disconnect()
            instantPromptConn = nil
        end
        for prompt, origDuration in pairs(originalHoldDurations) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = origDuration
            end
        end
        originalHoldDurations = {}
    end
end)

-- Запуск по умолчанию
switchTab("PLAYER")
