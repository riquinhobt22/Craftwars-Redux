-- ====================================================================
-- DELTA MOBILE CUSTOM HUB - ESTRUTURA PREMIUM ULTRA-FLUIDA
-- ====================================================================

local Player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- 1. Criar a Base da UI (Protegida contra reset e deletes comuns)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCustomHub_Premium"
ScreenGui.ResetOnSpawn = false

-- Tenta injetar no CoreGui (padrão de exploit), se não der, joga no PlayerGui
local success, err = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- 2. Botão Flutuante (Estilo Rayfield - Abre/Fecha o Menu)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 60, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
ToggleBtn.Text = "HUB"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.ZIndex = 10

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

-- Sistema de Arrastar o Botão Flutuante no Touch (Mobile Fix)
local dragBtnStart, startBtnPos, draggingBtn
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        dragBtnStart = input.Position
        startBtnPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragBtnStart
        ToggleBtn.Position = UDim2.new(startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X, startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y)
    end
end)
ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = false
    end
end)

-- 3. Painel Principal do Menu (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -130)
MainFrame.Size = UDim2.new(0, 400, 0, 260)
MainFrame.Active = true
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Clique no botão flutuante para abrir/fechar com efeito simples
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sistema de Arrastar o Painel Principal na Barra de Título
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "PREMIUM MOBILE HUB"
Title.Font = Enum.Font.SourceSansBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local dragStart, startPos, dragging
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TopBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 4. Containers de Divisão (Abas Esquerda vs Conteúdo Direita)
local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame
TabContainer.Position = UDim2.new(0, 8, 0, 42)
TabContainer.Size = UDim2.new(0, 105, 1, -50)
TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 26)

local TabContainerCorner = Instance.new("UICorner")
TabContainerCorner.CornerRadius = UDim.new(0, 8)
TabContainerCorner.Parent = TabContainer

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.Padding = UDim.new(0, 4)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.Position = UDim2.new(0, 120, 0, 42)
ContentContainer.Size = UDim2.new(1, -128, 1, -50)
ContentContainer.BackgroundTransparency = 1

-- 5. Configurações Globais do Script
local Config = {
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Fullbright = false
}

-- 6. Motores Criadores de Componentes (Abas, Toggles, Textbox)
local currentTabFrame = nil

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabContainer
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 13
    
    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 6)
    TabBtnCorner.Parent = TabBtn

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Parent = ContentContainer
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    TabFrame.ScrollBarThickness = 3
    TabFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = TabFrame
    ContentLayout.Padding = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        if currentTabFrame then currentTabFrame.Visible = false end
        TabFrame.Visible = true
        currentTabFrame = TabFrame
        
        for _, v in pairs(TabContainer:GetChildren()) do 
            if v:IsA("TextButton") then 
                v.BackgroundColor3 = Color3.fromRGB(28, 28, 36) 
                v.TextColor3 = Color3.fromRGB(180, 180, 180)
            end 
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    if not currentTabFrame then
        TabFrame.Visible = true
        currentTabFrame = TabFrame
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    return TabFrame
end

local function AddToggle(tab, text, callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Parent = tab
    Toggle.Size = UDim2.new(1, -6, 0, 35)
    Toggle.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    Toggle.Text = "  " .. text .. " [OFF]"
    Toggle.Font = Enum.Font.SourceSansBold
    Toggle.TextColor3 = Color3.fromRGB(230, 75, 75)
    Toggle.TextSize = 13
    Toggle.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = Toggle

    local state = false
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = state and "  " .. text .. " [ON]" or "  " .. text .. " [OFF]"
        Toggle.TextColor3 = state and Color3.fromRGB(75, 230, 130) or Color3.fromRGB(230, 75, 75)
        callback(state)
    end)
end

local function AddTextBox(tab, placeholder, callback)
    local Box = Instance.new("TextBox")
    Box.Parent = tab
    Box.Size = UDim2.new(1, -6, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    Box.Text = ""
    Box.PlaceholderText = placeholder
    Box.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSansBold
    Box.TextSize = 13

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = Box

    Box.FocusLost:Connect(function(enterPressed)
        callback(Box.Text)
    end)
end

local function AddButton(tab, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = tab
    Btn.Size = UDim2.new(1, -6, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    Btn.Text = text
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.TextSize = 13

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        callback()
    end)
end
