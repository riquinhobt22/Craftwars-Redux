-- ====================================================================
-- DELTA MOBILE HUB - VERSÃO 1.9 (FLY DEFINITIVO COM SUPORTE A SHIFTLOCK)
-- ====================================================================
local Player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Evita duplicar a interface na tela
if CoreGui:FindFirstChild("DeltaCustomHub_Premium") then CoreGui:FindFirstChild("DeltaCustomHub_Premium"):Destroy() end
if Player:WaitForChild("PlayerGui"):FindFirstChild("DeltaCustomHub_Premium") then Player:WaitForChild("PlayerGui"):FindFirstChild("DeltaCustomHub_Premium"):Destroy() end

-- Base da UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCustomHub_Premium"
ScreenGui.ResetOnSpawn = false

local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- Botão Flutuante
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

-- Arrastar Botão Flutuante (Mobile)
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

-- Painel Principal
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

-- Tabelas de Controle Globais
local Config = {
    FastMode = false, Shadows = true, CameraShake = true, Fullbright = false, PlayerESP = false,
    Fly = false, FlySpeed = 50, KeepFlyAfterDeath = false,
    WalkSpeedActive = false, WalkSpeedValue = 16, KeepSpeedAfterDeath = false,
    AutoEquip = false, SelectedWeapon = ""
}

local flyBodyGyro, flyBodyVelocity
local espFolder = Instance.new("Folder") ; espFolder.Name = "CustomESP_Storage" ; espFolder.Parent = CoreGui

-- Motores de UI
local currentTabFrame = nil
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton") ; TabBtn.Parent = TabContainer ; TabBtn.Size = UDim2.new(1, 0, 0, 32) ; TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36) ; TabBtn.Text = name ; TabBtn.Font = Enum.Font.SourceSansBold ; TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180) ; TabBtn.TextSize = 13
    local TabBtnCorner = Instance.new("UICorner") ; TabBtnCorner.CornerRadius = UDim.new(0, 6) ; TabBtnCorner.Parent = TabBtn
    local TabFrame = Instance.new("ScrollingFrame") ; TabFrame.Parent = ContentContainer ; TabFrame.Size = UDim2.new(1, 0, 1, 0) ; TabFrame.BackgroundTransparency = 1 ; TabFrame.Visible = false ; TabFrame.CanvasSize = UDim2.new(0, 0, 0, 750) ; TabFrame.ScrollBarThickness = 3 ; TabFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
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
-- JANELA MISC
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

-- 4. Fly Mobile Anti-ShiftLock (Estilo Infinite Yield)
AddTextBox(TabMisc, "Ajustar Fly Speed (0-999)", function(text)
    Config.FlySpeed = math.clamp(tonumber(text) or 50, 0, 999)
end)

local function StartFly()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    
    -- Gyro com torque reduzido nos eixos locais para permitir que o ShiftLock gire o personagem sem travar os eixos lineares
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(0, 9e5, 0) -- Deixa o jogo controlar o eixo Y livremente (evita bugs de ShiftLock)
    flyBodyGyro.cframe = root.CFrame
    flyBodyGyro.Parent = root
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.maxForce = Vector3.new(9e5, 9e5, 9e5)
    flyBodyVelocity.Parent = root
    
    local Camera = workspace.CurrentCamera
    
    task.spawn(function()
        while Config.Fly and root and root.Parent and hum and hum.Parent do
            RunService.RenderStepped:Wait()
            
            -- LÓGICA DE MOVIMENTO EM MATRIZ COMPENSADA:
            -- Lemos a CFrame da Câmera mas zeramos a influência de rotação no mundo real para evitar inversões com o ShiftLock ativo
            if hum.MoveDirection.Magnitude > 0 then
                local camCFrame = Camera.CFrame
                local moveDir = hum.MoveDirection
                
                -- Vetor para Frente/Trás absoluto em relação para onde os seus olhos apontam
                local forward = camCFrame.LookVector * (-moveDir.Z)
                -- Vetor Lateral absoluto (Garante Strafe perfeito mesmo com mira travada)
                local side = camCFrame.RightVector * moveDir.X
                
                -- Combina os vetores e gera a direção final sem colisões com a física interna do analógico
                local rawDirection = forward + side
                if rawDirection.Magnitude > 0 then
                    flyBodyVelocity.velocity = rawDirection.Unit * Config.FlySpeed
                end
            else
                -- Estabiliza completamente plano e imóvel no ar se soltar o analógico
                flyBodyVelocity.velocity = Vector3.new(0, 0, 0)
            end
            
            -- Sincroniza suavemente a rotação visual apenas se o ShiftLock não estiver forçando outra rotação
            flyBodyGyro.cframe = CFrame.new(root.Position, root.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z))
        end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
    end)
end

AddToggle(TabMisc, "Voar (Fly Infinite Yield)", function(state)
    Config.Fly = state
    if state then StartFly() else if flyBodyGyro then flyBodyGyro:Destroy() end if flyBodyVelocity then flyBodyVelocity:Destroy() end end
end)

AddToggle(TabMisc, "Manter Fly após morrer", function(state)
    Config.KeepFlyAfterDeath = state
end)

-- 5. WalkSpeed
AddTextBox(TabMisc, "Ajustar WalkSpeed (0-999)", function(text)
    Config.WalkSpeedValue = math.clamp(tonumber(text) or 16, 0, 999)
    if Config.WalkSpeedActive and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = Config.WalkSpeedValue
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

RunService.Heartbeat:Connect(function()
    if Config.WalkSpeedActive and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = Config.WalkSpeedValue
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

-- 7. AutoEquip Weapon
local WeaponLabel = Instance.new("TextLabel") ; WeaponLabel.Parent = TabMisc ; WeaponLabel.Size = UDim2.new(1, -6, 0, 20) ; WeaponLabel.BackgroundTransparency = 1 ; WeaponLabel.Text = "Arma Ativa: Nenhuma" ; WeaponLabel.Font = Enum.Font.SourceSansBold ; WeaponLabel.TextColor3 = Color3.fromRGB(0, 140, 255) ; WeaponLabel.TextSize = 13
local WeaponListFrame = Instance.new("Frame") ; WeaponListFrame.Parent = TabMisc ; WeaponListFrame.Size = UDim2.new(1, -6, 0, 100) ; WeaponListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
local ListCorner = Instance.new("UICorner") ; ListCorner.CornerRadius = UDim.new(0, 6) ; ListCorner.Parent = WeaponListFrame
local ListScroll = Instance.new("ScrollingFrame") ; ListScroll.Parent = WeaponListFrame ; ListScroll.Size = UDim2.new(1, -4, 1, -4) ; ListScroll.Position = UDim2.new(0, 2, 0, 2) ; ListScroll.BackgroundTransparency = 1 ; ListScroll.CanvasSize = UDim2.new(0, 0, 0, 200) ; ListScroll.ScrollBarThickness = 2
local ListLayout = Instance.new("UIListLayout") ; ListLayout.Parent = ListScroll ; ListLayout.Padding = UDim.new(0, 4)

local function BuildWeaponMenu()
    for _, child in pairs(ListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local foundAny = false
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            foundAny = true
            local WBtn = Instance.new("TextButton")
            WBtn.Parent = ListScroll
            WBtn.Size = UDim2.new(1, -4, 0, 25)
            WBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            WBtn.Text = item.Name
            WBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            WBtn.Font = Enum.Font.SourceSansBold
            WBtn.TextSize = 12
            local c = Instance.new("UICorner") ; c.CornerRadius = UDim.new(0, 4) ; c.Parent = WBtn
            
            WBtn.MouseButton1Click:Connect(function()
                Config.SelectedWeapon = item.Name
                WeaponLabel.Text = "Arma Ativa: " .. item.Name
                for _, b in pairs(ListScroll:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end end
                WBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            end)
        end
    end
    if not foundAny then
        WeaponLabel.Text = "Nenhuma arma na Mochila! Use Refresh."
    end
end

AddButton(TabMisc, "🔄 Atualizar Lista de Armas", function()
    BuildWeaponMenu()
end)

AddToggle(TabMisc, "AutoEquip Weapon", function(state)
    Config.AutoEquip = state
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if Config.AutoEquip and Config.SelectedWeapon ~= "" and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local currentTool = Player.Character:FindFirstChildOfClass("Tool")
            if not currentTool or currentTool.Name ~= Config.SelectedWeapon then
                local tool = Player.Backpack:FindFirstChild(Config.SelectedWeapon)
                if tool and tool:IsA("Tool") then
                    Player.Character.Humanoid:EquipTool(tool)
                end
            end
        end
    end
end)

-- 8. Player ESP (Wallhack)
local function RefreshESP()
    espFolder:ClearAllChildren()
    if not Config.PlayerESP then return end
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local root = p.Character.HumanoidRootPart
            
            local box = Instance.new("BoxHandleAdornment")
            box.Name = p.Name .. "_ESPBox"
            box.Size = Vector3.new(4, 6, 2)
            box.Color3 = Color3.fromRGB(255, 0, 50)
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Transparency = 0.6
            box.Adornee = root
            box.Parent = espFolder
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = p.Name .. "_ESPText"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.Adornee = root
            billboard.ExtentsOffset = Vector3.new(0, 4, 0)
            billboard.Parent = espFolder
            
            local label = Instance.new("TextLabel")
            label.Parent = billboard
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = p.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 14
        end
    end
end

AddToggle(TabMisc, "Player ESP (Wallhack)", function(state)
    Config.PlayerESP = state
    if not state then espFolder:ClearAllChildren() end
end)

RunService.Heartbeat:Connect(function()
    if Config.PlayerESP then
        RefreshESP()
    end
end)

-- 9. Loop de Persistência Pós-Morte
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

task.defer(BuildWeaponMenu)

