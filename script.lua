-- ====================================================================
-- DELTA MOBILE HUB - CÓDIGO FONTE INTEGRAL (VERSÃO 1.3.1 - OTIMIZADA)
-- ====================================================================
local Player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Evita duplicar a interface na tela
if CoreGui:FindFirstChild("DeltaCustomHub_Premium") then CoreGui:FindFirstChild("DeltaCustomHub_Premium"):Destroy() end
if Player:WaitForChild("PlayerGui"):FindFirstChild("DeltaCustomHub_Premium") then Player:WaitForChild("PlayerGui"):FindFirstChild("DeltaCustomHub_Premium"):Destroy() end

-- 1. Base da UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCustomHub_Premium"
ScreenGui.ResetOnSpawn = false

local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- 2. Botão Flutuante (Abre/Fecha)
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
local BtnCorner = Instance.new("UICorner") ; BtnCorner.CornerRadius = UDim.new(0, 8) ; BtnCorner.Parent = ToggleBtn

-- Arrastar o Botão Flutuante (Mobile)
local dragBtnStart, startBtnPos, draggingBtn
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true ; dragBtnStart = input.Position ; startBtnPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragBtnStart
        ToggleBtn.Position = UDim2.new(startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X, startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y)
    end
end)
ToggleBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingBtn = false end end)

-- 3. Painel Principal
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -130)
MainFrame.Size = UDim2.new(0, 420, 0, 280)
MainFrame.Active = true
MainFrame.Visible = true
local MainCorner = Instance.new("UICorner") ; MainCorner.CornerRadius = UDim.new(0, 12) ; MainCorner.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Barra de Título Arrastável
local TopBar = Instance.new("Frame") ; TopBar.Parent = MainFrame ; TopBar.Size = UDim2.new(1, 0, 0, 35) ; TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
local TopCorner = Instance.new("UICorner") ; TopCorner.CornerRadius = UDim.new(0, 12) ; TopCorner.Parent = TopBar
local Title = Instance.new("TextLabel") ; Title.Parent = TopBar ; Title.Size = UDim2.new(1, -20, 1, 0) ; Title.Position = UDim2.new(0, 12, 0, 0) ; Title.Text = "PREMIUM MOBILE HUB" ; Title.Font = Enum.Font.SourceSansBold ; Title.TextColor3 = Color3.fromRGB(255, 255, 255) ; Title.TextSize = 15 ; Title.TextXAlignment = Enum.TextXAlignment.Left ; Title.BackgroundTransparency = 1

local dragStart, startPos, dragging
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true ; dragStart = input.Position ; startPos = MainFrame.Position
    end
end)
TopBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
TopBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

-- Containers das Abas
local TabContainer = Instance.new("Frame") ; TabContainer.Parent = MainFrame ; TabContainer.Position = UDim2.new(0, 8, 0, 42) ; TabContainer.Size = UDim2.new(0, 105, 1, -50) ; TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
local TabContainerCorner = Instance.new("UICorner") ; TabContainerCorner.CornerRadius = UDim.new(0, 8) ; TabContainerCorner.Parent = TabContainer
local TabListLayout = Instance.new("UIListLayout") ; TabListLayout.Parent = TabContainer ; TabListLayout.Padding = UDim.new(0, 4)

local ContentContainer = Instance.new("Frame") ; ContentContainer.Parent = MainFrame ; ContentContainer.Position = UDim2.new(0, 120, 0, 42) ; ContentContainer.Size = UDim2.new(1, -128, 1, -50) ; ContentContainer.BackgroundTransparency = 1

-- 4. Tabela de Configurações Globais
local Config = {
    FastMode = false, Shadows = true, CameraShake = true, Fullbright = false, PlayerESP = false,
    Fly = false, FlySpeed = 50, KeepFlyAfterDeath = false,
    WalkSpeedActive = false, WalkSpeedValue = 16, KeepSpeedAfterDeath = false,
    AutoEquip = false, SelectedWeapon = ""
}

-- Variáveis de Controle dos Sistemas
local flyBodyGyro, flyBodyVelocity
local espConnections = {}
local espRegistry = {} -- Correção do vazamento de memória e remoção do ESP

-- 5. Motores de Elementos (Abas, Toggles, Caixas de Texto, Botões)
local currentTabFrame = nil
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton") ; TabBtn.Parent = TabContainer ; TabBtn.Size = UDim2.new(1, 0, 0, 32) ; TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36) ; TabBtn.Text = name ; TabBtn.Font = Enum.Font.SourceSansBold ; TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180) ; TabBtn.TextSize = 13
    local TabBtnCorner = Instance.new("UICorner") ; TabBtnCorner.CornerRadius = UDim.new(0, 6) ; TabBtnCorner.Parent = TabBtn
    local TabFrame = Instance.new("ScrollingFrame") ; TabFrame.Parent = ContentContainer ; TabFrame.Size = UDim2.new(1, 0, 1, 0) ; TabFrame.BackgroundTransparency = 1 ; TabFrame.Visible = false ; TabFrame.CanvasSize = UDim2.new(0, 0, 0, 650) ; TabFrame.ScrollBarThickness = 3 ; TabFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
    local ContentLayout = Instance.new("UIListLayout") ; ContentLayout.Parent = TabFrame ; ContentLayout.Padding = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        if currentTabFrame then currentTabFrame.Visible = false end
        TabFrame.Visible = true ; currentTabFrame = TabFrame
        for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(28, 28, 36) ; v.TextColor3 = Color3.fromRGB(180, 180, 180) end end
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255) ; TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    if not currentTabFrame then TabFrame.Visible = true ; currentTabFrame = TabFrame ; TabBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255) ; TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) end
    return TabFrame
end

local function AddToggle(tab, text, callback)
    local Toggle = Instance.new("TextButton") ; Toggle.Parent = tab ; Toggle.Size = UDim2.new(1, -6, 0, 32) ; Toggle.BackgroundColor3 = Color3.fromRGB(24, 24, 32) ; Toggle.Text = "  " .. text .. " [OFF]" ; Toggle.Font = Enum.Font.SourceSansBold ; Toggle.TextColor3 = Color3.fromRGB(230, 75, 75) ; Toggle.TextSize = 12 ; Toggle.TextXAlignment = Enum.TextXAlignment.Left
    local ToggleCorner = Instance.new("UICorner") ; ToggleCorner.CornerRadius = UDim.new(0, 6) ; ToggleCorner.Parent = Toggle
    local state = false
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = state and "  " .. text .. " [ON]" or "  " .. text .. " [OFF]"
        Toggle.TextColor3 = state and Color3.fromRGB(75, 230, 130) or Color3.fromRGB(230, 75, 75)
        pcall(callback, state)
    end)
    return Toggle
end

local function AddTextBox(tab, placeholder, callback)
    local Box = Instance.new("TextBox") ; Box.Parent = tab ; Box.Size = UDim2.new(1, -6, 0, 32) ; Box.BackgroundColor3 = Color3.fromRGB(24, 24, 32) ; Box.Text = "" ; Box.PlaceholderText = placeholder ; Box.PlaceholderColor3 = Color3.fromRGB(130, 130, 140) ; Box.TextColor3 = Color3.fromRGB(255, 255, 255) ; Box.Font = Enum.Font.SourceSansBold ; Box.TextSize = 12
    local BoxCorner = Instance.new("UICorner") ; BoxCorner.CornerRadius = UDim.new(0, 6) ; BoxCorner.Parent = Box
    Box.FocusLost:Connect(function() pcall(callback, Box.Text) end)
    return Box
end

local function AddButton(tab, text, callback)
    local Btn = Instance.new("TextButton") ; Btn.Parent = tab ; Btn.Size = UDim2.new(1, -6, 0, 32) ; Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 42) ; Btn.Text = text ; Btn.Font = Enum.Font.SourceSansBold ; Btn.TextColor3 = Color3.fromRGB(240, 240, 240) ; Btn.TextSize = 12
    local BtnCorner = Instance.new("UICorner") ; BtnCorner.CornerRadius = UDim.new(0, 6) ; BtnCorner.Parent = Btn
    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return Btn
end

-- ====================================================================
-- 6. CRIAÇÃO DA JANELA MISC E IMPLEMENTAÇÃO DAS FUNÇÕES
-- ====================================================================
local TabMisc = CreateTab("Misc")

-- 1. FastMode
AddToggle(TabMisc, "FastMode", function(state)
    Config.FastMode = state
    for _, v in pairs(workspace:GetDescendants()) do
        if state and (v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
            v.Material = Enum.Material.SmoothPlastic
        elseif not state and (v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
            v.Material = Enum.Material.Plastic
        end
    end
end)

-- 2. Shadows
AddToggle(TabMisc, "Sombra do Jogo (Shadows)", function(state)
    Config.Shadows = state
    Lighting.GlobalShadows = state
end)

-- 3. CameraShake
AddToggle(TabMisc, "CameraShake", function(state)
    Config.CameraShake = state
    if not state then
        RunService:BindToRenderStep("NoShake", Enum.RenderPriority.Camera.Value + 1, function()
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                Player.Character.Humanoid.CameraOffset = Vector3.new(0,0,0)
            end
        end)
    else
        RunService:UnbindFromRenderStep("NoShake")
    end
end)

-- 4. Fly (Ajuste de Velocidade e Controles)
AddTextBox(TabMisc, "Ajustar Fly Speed (0-999)", function(text)
    local num = math.clamp(tonumber(text) or 50, 0, 999)
    Config.FlySpeed = num
end)

local function StartFly()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    
    -- Limpeza preventiva de instâncias antigas de Fly
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4 ; flyBodyGyro.maxTorque = Vector3.new(9e5, 9e5, 9e5) ; flyBodyGyro.cframe = root.CFrame ; flyBodyGyro.Parent = root
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.velocity = Vector3.new(0,0.1,0) ; flyBodyVelocity.maxForce = Vector3.new(9e5, 9e5, 9e5) ; flyBodyVelocity.Parent = root
    local Camera = workspace.CurrentCamera
    
    task.spawn(function()
        while Config.Fly and root and root.Parent and Player.Character and Player.Character:FindFirstChild("Humanoid") do
            RunService.RenderStepped:Wait()
            local dir = Vector3.new(0,0,0)
            if Player.Character.Humanoid.MoveDirection.Magnitude > 0 then
                dir = Player.Character.Humanoid.MoveDirection
            end
            flyBodyVelocity.velocity = dir * Config.FlySpeed
            flyBodyGyro.cframe = Camera.CFrame
        end
        -- Garante a destruição ao sair do loop
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
    end)
end

local function StopFly()
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
end

AddToggle(TabMisc, "Voar (Fly)", function(state)
    Config.Fly = state
    if state then StartFly() else StopFly() end
end)

AddToggle(TabMisc, "Manter Fly após morrer", function(state)
    Config.KeepFlyAfterDeath = state
end)

-- 5. WalkSpeed (Ajuste e Fix)
AddTextBox(TabMisc, "Ajustar WalkSpeed (0-999)", function(text)
    local num = math.clamp(tonumber(text) or 16, 0, 999)
    Config.WalkSpeedValue = num
    if Config.WalkSpeedActive and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = num
    end
end)

AddToggle(TabMisc, "Ativar WalkSpeed", function(state)
    Config.WalkSpeedActive = state
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = state and Config.WalkSpeedValue or 16
    end
end)

AddToggle(TabMisc, "Manter WalkSpeed após morrer", function(state)
    Config.KeepSpeedAfterDeath = state
end)

-- Loop nativo para impedir redefinições do jogo na velocidade
RunService.Heartbeat:Connect(function()
    if Config.WalkSpeedActive and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        if Player.Character.Humanoid.WalkSpeed ~= Config.WalkSpeedValue then
            Player.Character.Humanoid.WalkSpeed = Config.WalkSpeedValue
        end
    end
end)

-- 6. FullBright
AddToggle(TabMisc, "FullBright", function(state)
    Config.Fullbright = state
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.fromRGB(130, 130, 130)
        Lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 130)
        Lighting.Brightness = 1
    end
end)

-- 7. AutoEquip Weapon (Lógica Dinâmica de Inventário)
local WeaponLabel = Instance.new("TextLabel") ; WeaponLabel.Parent = TabMisc ; WeaponLabel.Size = UDim2.new(1, -6, 0, 20) ; WeaponLabel.BackgroundTransparency = 1 ; WeaponLabel.Text = "Arma Selecionada: Nenhuma" ; WeaponLabel.Font = Enum.Font.SourceSansItalic ; WeaponLabel.TextColor3 = Color3.fromRGB(180, 180, 180) ; WeaponLabel.TextSize = 12
AddTextBox(TabMisc, "Nome Exato da Arma para Equipar", function(text)
    Config.SelectedWeapon = text
    WeaponLabel.Text = "Arma Selecionada: " .. text
end)

AddButton(TabMisc, "Atualizar/Checar Mochila (Refresh)", function()
    local encontrou = false
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower() == Config.SelectedWeapon:lower() then
            encontrou = true
            break
        end
    end
    if encontrou then WeaponLabel.Text = "Arma Validada na Mochila: " .. Config.SelectedWeapon else WeaponLabel.Text = "Arma não encontrada! Use Refresh." end
end)

AddToggle(TabMisc, "AutoEquip Weapon", function(state)
    Config.AutoEquip = state
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoEquip and Config.SelectedWeapon ~= "" and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local currentTool = Player.Character:FindFirstChildOfClass("Tool")
            if not currentTool or currentTool.Name:lower() ~= Config.SelectedWeapon:lower() then
                local tool = Player.Backpack:FindFirstChild(Config.SelectedWeapon)
                if tool and tool:IsA("Tool") then
                    Player.Character.Humanoid:EquipTool(tool)
                end
            end
        end
    end
end)

-- 8. Player ESP (Visão Além das Paredes)
local function CreateESP(p)
    if p == Player then return end
    
    local function apply(character)
        if not character then return end
        local root = character:WaitForChild("HumanoidRootPart", 5)
        if root and not root:FindFirstChild("ESPHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.FillColor = Color3.fromRGB(255, 0, 50)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = root
        end
    end
    
    -- Registra o evento CharacterAdded do jogador específico para gerenciar pós-morte
    local conn = p.CharacterAdded:Connect(function(char)
        if Config.PlayerESP then
            apply(char)
        end
    end)
    table.insert(espRegistry, conn)
    
    if p.Character then apply(p.Character) end
end

AddToggle(TabMisc, "Player ESP", function(state)
    Config.PlayerESP = state
    if state then
        for _, p in pairs(game.Players:GetPlayers()) do CreateESP(p) end
        espConnections[#espConnections+1] = game.Players.PlayerAdded:Connect(CreateESP)
    else
        -- Limpa conexões principais do PlayerAdded
        for _, conn in pairs(espConnections) do conn:Disconnect() end
        espConnections = {}
        
        -- Limpa conexões internas do CharacterAdded de cada player (Evita memory leak)
        for _, conn in pairs(espRegistry) do conn:Disconnect() end
        espRegistry = {}
        
        -- Remove os efeitos visuais
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart:FindFirstChild("ESPHighlight") then
                p.Character.HumanoidRootPart.ESPHighlight:Destroy()
            end
        end
    end
end)

-- 9. Loop de Persistência Pós-Morte (WalkSpeed e Fly)
Player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    task.wait(0.8)
    if Config.KeepSpeedAfterDeath and Config.WalkSpeedActive then
        hum.WalkSpeed = Config.WalkSpeedValue
    end
    if Config.KeepFlyAfterDeath and Config.Fly then
        StartFly()
    end
end)
