--[[
    Ashlabs UI Library v2.0
    Inspirado no design fornecido pelo usuário.
    Estrutura moderna com navegação lateral, header customizado e novos elementos.
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--================================================================--
--[[                           TEMA                             ]]--
--================================================================--
local Theme = {
    Background = Color3.fromRGB(26, 24, 32),        -- Cor de fundo principal
    Secondary = Color3.fromRGB(38, 35, 46),         -- Cor dos painéis internos
    Tertiary = Color3.fromRGB(54, 51, 64),          -- Cor para elementos como dropdowns
    Main = Color3.fromRGB(120, 34, 255),            -- Roxo principal para seleção
    Text = Color3.fromRGB(230, 230, 230),           -- Texto principal
    SubText = Color3.fromRGB(150, 150, 150),        -- Texto secundário (menos importante)
    Close = Color3.fromRGB(255, 95, 87),            -- Botão de fechar
    Minimize = Color3.fromRGB(255, 189, 46),        -- Botão de minimizar
    Maximize = Color3.fromRGB(39, 206, 64),         -- Botão de maximizar/outra ação
    Outline = Color3.fromRGB(68, 64, 80)            -- Borda sutil
}

--================================================================--
--[[                      FUNÇÕES PRINCIPAIS                    ]]--
--================================================================--

function UILibrary.new(config)
    config = config or {}
    
    local self = setmetatable({
        Title = config.Title or "UI Library",
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift,
        Tabs = {},
        CurrentTab = nil,
        IsVisible = true
    }, UILibrary)
    
    self:_CreateUI()
    self:_SetupControls()
    
    return self
end

function UILibrary:_CreateUI()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Ashlabs_UI_" .. math.random(1000, 9999)
    self.ScreenGui.Parent = playerGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true

    -- Frame Principal
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.BackgroundColor3 = Theme.Background
    self.MainFrame.BorderSizePixel = 1
    self.MainFrame.BorderColor3 = Theme.Outline
    self.MainFrame.Size = UDim2.new(0, 550, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 8)

    -- Header (Barra de Título)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = self.MainFrame
    Header.BackgroundColor3 = Theme.Secondary
    Header.Size = UDim2.new(1, 0, 0, 40)
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    -- Arredonda apenas os cantos superiores
    task.defer(function() HeaderCorner.Parent = nil; Instance.new("UICorner", Header).CornerRadius = UDim.new(0,8); Header.ClipsDescendants = true end)


    -- Ícone do Título (Exemplo: use o seu asset ID)
    local TitleIcon = Instance.new("ImageLabel")
    TitleIcon.Name = "TitleIcon"
    TitleIcon.Parent = Header
    TitleIcon.Image = "rbxassetid://6031023223" -- ID de um ícone genérico de engrenagem
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Size = UDim2.new(0, 20, 0, 20)
    TitleIcon.Position = UDim2.new(0, 15, 0.5, -10)
    
    -- Texto do Título
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = Header
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.Title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 45, 0, 0)

    -- Botões de Controle da Janela (Fechar, etc.)
    local ControlButtons = Instance.new("Frame")
    ControlButtons.Parent = Header
    ControlButtons.BackgroundTransparency = 1
    ControlButtons.Size = UDim2.new(0, 80, 1, 0)
    ControlButtons.Position = UDim2.new(1, -90, 0, 0)
    local ControlLayout = Instance.new("UIListLayout", ControlButtons)
    ControlLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlLayout.Padding = UDim.new(0, 8)
    
    local function CreateControlButton(color)
        local btn = Instance.new("Frame")
        btn.Parent = ControlButtons
        btn.BackgroundColor3 = color
        btn.Size = UDim2.new(0, 14, 0, 14)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        return btn
    end
    CreateControlButton(Theme.Minimize)
    CreateControlButton(Theme.Maximize)
    CreateControlButton(Theme.Close).MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)
    
    -- Container Principal (Navegação + Conteúdo)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = self.MainFrame
    Container.BackgroundTransparency = 1
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 40)
    
    -- Navegação Lateral (Esquerda)
    self.NavFrame = Instance.new("Frame")
    self.NavFrame.Name = "NavFrame"
    self.NavFrame.Parent = Container
    self.NavFrame.BackgroundTransparency = 1
    self.NavFrame.Size = UDim2.new(0, 130, 1, 0)
    
    self.NavLayout = Instance.new("UIListLayout", self.NavFrame)
    self.NavLayout.Padding = UDim.new(0, 5)
    
    -- Conteúdo (Direita)
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Parent = Container
    self.ContentFrame.BackgroundColor3 = Theme.Secondary
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.Size = UDim2.new(1, -140, 1, 0)
    self.ContentFrame.Position = UDim2.new(0, 140, 0, 0)
    Instance.new("UICorner", self.ContentFrame).CornerRadius = UDim.new(0, 6)

end

function UILibrary:_SetupControls()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.ToggleKey then
            self.IsVisible = not self.IsVisible
            self.MainFrame.Visible = self.IsVisible
        end
    end)
end

function UILibrary:SelectTab(selectedTab)
    if self.CurrentTab then
        TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play()
        self.CurrentTab.Container.Visible = false
    end
    
    TweenService:Create(selectedTab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Main}):Play()
    selectedTab.Container.Visible = true
    self.CurrentTab = selectedTab
end

--================================================================--
--[[                    ELEMENTOS DA UI                         ]]--
--================================================================--

--- Cria um botão na barra de navegação lateral.
function UILibrary:CreateTab(name, iconId)
    iconId = iconId or "rbxassetid://3926307971" -- Ícone padrão (casa)

    local tab = {}
    
    -- Botão de Navegação
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = name
    tab.Button.Parent = self.NavFrame
    tab.Button.BackgroundColor3 = Theme.Background -- Cor inicial
    tab.Button.Size = UDim2.new(1, 0, 0, 35)
    tab.Button.Text = "" -- O texto será um label separado
    Instance.new("UICorner", tab.Button).CornerRadius = UDim.new(0, 6)
    
    -- Ícone do botão
    local Icon = Instance.new("ImageLabel", tab.Button)
    Icon.Image = iconId
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.Position = UDim2.new(0, 12, 0.5, -9)
    
    -- Texto do botão
    local Label = Instance.new("TextLabel", tab.Button)
    Label.Text = "  " .. name
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.TextColor3 = Theme.Text
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 30, 0, 0)
    
    -- Container para o conteúdo desta aba
    tab.Container = Instance.new("ScrollingFrame")
    tab.Container.Name = name .. "_Content"
    tab.Container.Parent = self.ContentFrame
    tab.Container.BackgroundColor3 = Theme.Secondary
    tab.Container.BorderSizePixel = 0
    tab.Container.Size = UDim2.new(1, 0, 1, 0)
    tab.Container.Visible = false
    tab.Container.CanvasSize = UDim2.new(0,0,0,0)
    tab.Container.ScrollBarThickness = 3
    
    local layout = Instance.new("UIListLayout", tab.Container)
    layout.Padding = UDim.new(0, 10)
    Instance.new("UIPadding", tab.Container).PaddingTop = UDim.new(0, 10)
    
    tab.Layout = layout
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Seleciona a primeira aba criada por padrão
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

--- Cria um título de seção dentro de uma aba.
function UILibrary:CreateSection(tab, title)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = title
    SectionLabel.Parent = tab.Container
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Size = UDim2.new(1, -20, 0, 25)
    SectionLabel.Position = UDim2.new(0, 10, 0, 0)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.Text = title
    SectionLabel.TextColor3 = Theme.Text
    SectionLabel.TextSize = 16
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    self:_UpdateCanvasSize(tab)
end

--- Cria um botão com um ícone de ação à direita.
function UILibrary:CreateButton(tab, text, callback)
    local Container = Instance.new("Frame")
    Container.Name = text
    Container.Parent = tab.Container
    Container.BackgroundColor3 = Theme.Background
    Container.Size = UDim2.new(1, -20, 0, 40)
    Container.Position = UDim2.new(0, 10, 0, 0)
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Container)
    Label.Text = text
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = Theme.SubText
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    
    local ActionButton = Instance.new("ImageButton")
    ActionButton.Name = "ActionButton"
    ActionButton.Parent = Container
    ActionButton.BackgroundColor3 = Theme.Main
    ActionButton.Size = UDim2.new(0, 28, 0, 28)
    ActionButton.Position = UDim2.new(1, -38, 0.5, -14)
    ActionButton.Image = "rbxassetid://6031023223" -- Ícone de "clique" ou similar
    Instance.new("UICorner", ActionButton).CornerRadius = UDim.new(0, 6)
    
    ActionButton.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    self:_UpdateCanvasSize(tab)
    return Container
end

--- Cria uma opção com um menu dropdown.
function UILibrary:CreateDropdown(tab, text, options, callback)
    local options = options or {}
    
    local Container = Instance.new("Frame", tab.Container)
    Container.Name = text
    Container.BackgroundColor3 = Theme.Background
    Container.Size = UDim2.new(1, -20, 0, 40)
    Container.Position = UDim2.new(0, 10, 0, 0)
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Container)
    Label.Text = text
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = Theme.SubText
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    
    local DropdownFrame = Instance.new("Frame", Container)
    DropdownFrame.Name = "DropdownFrame"
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Size = UDim2.new(0.5, -20, 1, 0)
    DropdownFrame.Position = UDim2.new(0.5, 10, 0, 0)
    
    local DropdownButton = Instance.new("TextButton", DropdownFrame)
    DropdownButton.Name = "DropdownButton"
    DropdownButton.BackgroundColor3 = Theme.Tertiary
    DropdownButton.Size = UDim2.new(1, 0, 0, 28)
    DropdownButton.Position = UDim2.new(0, 0, 0.5, -14)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Text = options[1] or "Selecione..."
    DropdownButton.TextColor3 = Theme.Text
    DropdownButton.TextSize = 13
    Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 5)
    
    local OptionsList = Instance.new("ScrollingFrame", DropdownFrame)
    OptionsList.Name = "OptionsList"
    OptionsList.BackgroundColor3 = Theme.Tertiary
    OptionsList.Size = UDim2.new(1, 0, 0, 0) -- Começa fechado
    OptionsList.Position = UDim2.new(0, 0, 1, 5)
    OptionsList.Visible = false
    OptionsList.ZIndex = 2
    OptionsList.ScrollBarThickness = 4
    Instance.new("UIListLayout", OptionsList).Padding = UDim.new(0, 2)
    Instance.new("UICorner", OptionsList).CornerRadius = UDim.new(0, 5)
    
    local isOpen = false
    DropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        OptionsList.Visible = isOpen
        local numOptions = #options
        local listHeight = math.min(numOptions * 30, 90) -- Mostra no max 3 opções
        local tween = TweenService:Create(OptionsList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, isOpen and listHeight or 0)})
        tween:Play()
    end)
    
    for _, optionText in pairs(options) do
        local OptionBtn = Instance.new("TextButton", OptionsList)
        OptionBtn.Name = optionText
        OptionBtn.BackgroundColor3 = Theme.Tertiary
        OptionBtn.BackgroundTransparency = 0.5
        OptionBtn.Size = UDim2.new(1, 0, 0, 28)
        OptionBtn.Font = Enum.Font.Gotham
        OptionBtn.Text = optionText
        OptionBtn.TextColor3 = Theme.Text
        OptionBtn.TextSize = 13
        
        OptionBtn.MouseButton1Click:Connect(function()
            DropdownButton.Text = optionText
            pcall(callback, optionText)
            isOpen = false
            OptionsList.Visible = false
            OptionsList.Size = UDim2.new(1, 0, 0, 0)
        end)
    end
    
    OptionsList.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
    
    self:_UpdateCanvasSize(tab)
    return Container
end

function UILibrary:_UpdateCanvasSize(tab)
    task.wait() -- Dá tempo para a UI calcular o tamanho
    if tab and tab.Layout then
        tab.Container.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y + 20)
    end
end

return UILibrary
