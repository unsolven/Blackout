-- Roblox UI Library v1.0
-- Biblioteca de UI moderna com cores roxas/pretas/cinzas

local UILibrary = {}
UILibrary.__index = UILibrary

-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações de tema
local Theme = {
    MainPurple = Color3.fromRGB(120, 81, 169),
    DarkPurple = Color3.fromRGB(75, 51, 105),
    DarkerPurple = Color3.fromRGB(45, 30, 65),
    Black = Color3.fromRGB(25, 25, 30),
    DarkGray = Color3.fromRGB(40, 40, 45),
    Gray = Color3.fromRGB(55, 55, 65),
    LightGray = Color3.fromRGB(180, 180, 190),
    White = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(85, 170, 85),
    Red = Color3.fromRGB(220, 85, 85)
}

-- Função para criar uma nova janela
function UILibrary.new(config)
    config = config or {}
    
    local self = setmetatable({
        Title = config.Title or "UI Library",
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift, -- Alterado para uma tecla comum de Hub
        Tabs = {},
        CurrentTab = nil,
        IsVisible = true,
        StatusTexts = {},
        IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    }, UILibrary)
    
    self:CreateUI()
    self:SetupControls()
    
    return self
end

function UILibrary:CreateUI()
    -- ScreenGui principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary_" .. math.random(1000, 9999)
    self.ScreenGui.Parent = playerGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true
    
    -- Frame principal
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.BackgroundColor3 = Theme.Black
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Size = UDim2.new(0, self.IsMobile and 350 or 450, 0, self.IsMobile and 400 or 500)
    self.MainFrame.Position = UDim2.new(0.5, -self.MainFrame.Size.X.Offset / 2, 0.5, -self.MainFrame.Size.Y.Offset / 2)
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    
    -- Corner arredondado
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.MainFrame
    
    -- Título
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Parent = self.MainFrame
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    self.TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Theme.White
    self.TitleLabel.TextSize = 18
    self.TitleLabel.Font = Enum.Font.GothamBold
    
    -- Separador
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Parent = self.MainFrame
    separator.BackgroundColor3 = Theme.MainPurple
    separator.BorderSizePixel = 0
    separator.Size = UDim2.new(1, 0, 0, 2)
    separator.Position = UDim2.new(0, 0, 0, 40)
    
    -- Container das abas (lateral esquerda)
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Parent = self.MainFrame
    self.TabContainer.BackgroundColor3 = Theme.DarkGray
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Size = UDim2.new(0, 120, 1, -80)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 42)
    self.TabContainer.ScrollBarThickness = 4
    self.TabContainer.ScrollBarImageColor3 = Theme.MainPurple
    self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = self.TabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = self.TabContainer
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 2)
    
    -- Container do conteúdo (direita)
    self.ContentContainer = Instance.new("ScrollingFrame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Parent = self.MainFrame
    self.ContentContainer.BackgroundColor3 = Theme.DarkGray
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Size = UDim2.new(1, -125, 1, -80)
    self.ContentContainer.Position = UDim2.new(0, 125, 0, 42)
    self.ContentContainer.ScrollBarThickness = 4
    self.ContentContainer.ScrollBarImageColor3 = Theme.MainPurple
    self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 4)
    contentCorner.Parent = self.ContentContainer
    
    -- Status bar (embaixo)
    self.StatusBar = Instance.new("Frame")
    self.StatusBar.Name = "StatusBar"
    self.StatusBar.Parent = self.MainFrame
    self.StatusBar.BackgroundColor3 = Theme.DarkerPurple
    self.StatusBar.BorderSizePixel = 0
    self.StatusBar.Size = UDim2.new(1, 0, 0, 35)
    self.StatusBar.Position = UDim2.new(0, 0, 1, -35)
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 4)
    statusCorner.Parent = self.StatusBar
    
    self.StatusLabel = Instance.new("TextLabel")
    self.StatusLabel.Name = "StatusLabel"
    self.StatusLabel.Parent = self.StatusBar
    self.StatusLabel.BackgroundTransparency = 1
    self.StatusLabel.Size = UDim2.new(1, -10, 1, 0)
    self.StatusLabel.Position = UDim2.new(0, 5, 0, 0)
    self.StatusLabel.Text = "Nenhum toggle ativo"
    self.StatusLabel.TextColor3 = Theme.LightGray
    self.StatusLabel.TextSize = 12
    self.StatusLabel.Font = Enum.Font.Gotham
    self.StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    if self.IsMobile then self:CreateMobileToggle() end
end

function UILibrary:CreateMobileToggle()
    self.MobileButton = Instance.new("TextButton")
    self.MobileButton.Name = "MobileToggle"
    self.MobileButton.Parent = self.ScreenGui
    self.MobileButton.BackgroundColor3 = Theme.DarkerPurple
    self.MobileButton.BorderSizePixel = 0
    self.MobileButton.Size = UDim2.new(0, 50, 0, 50)
    self.MobileButton.Position = UDim2.new(0, 10, 0, 100)
    self.MobileButton.Text = ""
    self.MobileButton.Active = true
    self.MobileButton.Draggable = true
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 25)
    mobileCorner.Parent = self.MobileButton
    
    local icon = Instance.new("TextLabel")
    icon.Parent = self.MobileButton
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Text = "⚙️"
    icon.TextColor3 = Theme.White
    icon.TextSize = 20
    
    self.MobileButton.MouseButton1Click:Connect(function() self:Toggle() end)
end

function UILibrary:SetupControls()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.ToggleKey then self:Toggle() end
    end)
end

function UILibrary:Toggle()
    self.IsVisible = not self.IsVisible
    local pos = self.MainFrame.Position
    local size = self.MainFrame.Size
    local targetPosition = self.IsVisible and 
        UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2) or 
        UDim2.new(0.5, -size.X.Offset / 2, 1, 50)
    
    local tween = TweenService:Create(self.MainFrame, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = targetPosition}
    )
    tween:Play()
end

function UILibrary:CreateTab(name)
    local tab = { Name = name, Elements = {}, Frame = nil, Button = nil }
    
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = name .. "Button"; tab.Button.Parent = self.TabContainer
    tab.Button.BackgroundColor3 = Theme.Gray; tab.Button.BorderSizePixel = 0
    tab.Button.Size = UDim2.new(1, -4, 0, 30); tab.Button.Text = name
    tab.Button.TextColor3 = Theme.White; tab.Button.TextSize = 14
    tab.Button.Font = Enum.Font.Gotham
    
    local buttonCorner = Instance.new("UICorner"); buttonCorner.CornerRadius = UDim.new(0, 4); buttonCorner.Parent = tab.Button
    
    tab.Frame = Instance.new("Frame")
    tab.Frame.Name = name .. "Frame"; tab.Frame.Parent = self.ContentContainer
    tab.Frame.BackgroundTransparency = 1; tab.Frame.Size = UDim2.new(1, 0, 1, 0)
    tab.Frame.Position = UDim2.new(0, 0, 0, 0); tab.Frame.Visible = false
    
    local layout = Instance.new("UIListLayout"); layout.Parent = tab.Frame
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 8)
    
    tab.Button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
    
    if #self.Tabs == 0 then self:SelectTab(tab) end
    table.insert(self.Tabs, tab)
    
    self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, #self.Tabs * 32)
    return tab
end

function UILibrary:SelectTab(selectedTab)
    if self.CurrentTab then
        self.CurrentTab.Frame.Visible = false
        self.CurrentTab.Button.BackgroundColor3 = Theme.Gray
    end
    selectedTab.Frame.Visible = true
    selectedTab.Button.BackgroundColor3 = Theme.MainPurple
    self.CurrentTab = selectedTab
end

function UILibrary:CreateButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"; button.Parent = tab.Frame
    button.BackgroundColor3 = Theme.MainPurple; button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 35); button.Text = text
    button.TextColor3 = Theme.White; button.TextSize = 14
    button.Font = Enum.Font.Gotham
    
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 4); corner.Parent = button
    
    button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.DarkPurple}):Play() end)
    button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.MainPurple}):Play() end)
    button.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
    
    self:UpdateCanvasSize(tab)
    return button
end

function UILibrary:CreateToggle(tab, text, defaultState, callback)
    defaultState = defaultState or false
    
    local container = Instance.new("Frame")
    container.Name = text .. "Container"; container.Parent = tab.Frame
    container.BackgroundColor3 = Theme.Gray; container.BorderSizePixel = 0
    container.Size = UDim2.new(1, 0, 0, 35)
    
    local containerCorner = Instance.new("UICorner"); containerCorner.CornerRadius = UDim.new(0, 4); containerCorner.Parent = container
    
    local label = Instance.new("TextLabel"); label.Parent = container
    label.BackgroundTransparency = 1; label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0); label.Text = text
    label.TextColor3 = Theme.White; label.TextSize = 14
    label.Font = Enum.Font.Gotham; label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton"); toggle.Parent = container
    toggle.BackgroundColor3 = defaultState and Theme.Green or Theme.Red
    toggle.BorderSizePixel = 0; toggle.Size = UDim2.new(0, 35, 0, 20)
    toggle.Position = UDim2.new(1, -45, 0.5, -10); toggle.Text = defaultState and "ON" or "OFF"
    toggle.TextColor3 = Theme.White; toggle.TextSize = 12
    toggle.Font = Enum.Font.GothamBold
    
    local toggleCorner = Instance.new("UICorner"); toggleCorner.CornerRadius = UDim.new(0, 10); toggleCorner.Parent = toggle
    
    local isToggled = defaultState
    self.StatusTexts[text] = isToggled
    self:UpdateStatus()
    
    toggle.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        local targetColor = isToggled and Theme.Green or Theme.Red
        local targetText = isToggled and "ON" or "OFF"
        
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        toggle.Text = targetText
        
        self.StatusTexts[text] = isToggled
        self:UpdateStatus()
        
        if callback then pcall(callback, isToggled) end
    end)
    
    self:UpdateCanvasSize(tab)
    return container
end

function UILibrary:UpdateStatus()
    local activeToggles = {}
    for name, state in pairs(self.StatusTexts) do if state then table.insert(activeToggles, name) end end
    
    if #activeToggles > 0 then
        self.StatusLabel.Text = "Ativo: " .. table.concat(activeToggles, ", ")
        self.StatusLabel.TextColor3 = Theme.Green
    else
        self.StatusLabel.Text = "Nenhum toggle ativo"
        self.StatusLabel.TextColor3 = Theme.LightGray
    end
end

function UILibrary:UpdateCanvasSize(tab)
    -- Adiciona um pequeno atraso para garantir que a UI foi renderizada
    task.wait() 
    local layout = tab.Frame:FindFirstChildOfClass("UIListLayout")
    if layout then
        tab.Frame.Parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
end

-- ESSENCIAL: Retorne a tabela da biblioteca para que o loadstring possa capturá-la.
return UILibrary
