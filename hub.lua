-- ====================================================================
-- DELTA MOBILE HUB - VERSÃO 6.1 (WEAPON BLACKOUT - JOGABILIDADE LIVRE)
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
    WeaponBlackout = false, Fullbright = false, PlayerESP = false,
    Fly = false, FlySpeed = 50, KeepFlyAfterDeath = false,
    WalkSpeedActive = false, WalkSpeedValue = 16, KeepSpeedAfterDeath = false,
    AutoEquip = false, SelectedWeapon = "",
    SkillSpam = false, SpamSpeed = 0.15
}

local flyBodyGyro, flyBodyVelocity
local espFolder = Instance.new("Folder") ; espFolder.Name = "CustomESP_Storage" ; espFolder.Parent = CoreGui

-- Motores de UI
local currentTabFrame = nil
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton") ; TabBtn.Parent = TabContainer ; TabBtn.Size = UDim2.new(1, 0, 0, 32) ; TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36) ; TabBtn.Text = name ; TabBtn.Font = Enum.Font.SourceSansBold ; TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180) ; TabBtn.TextSize = 13
    local TabBtnCorner = Instance.new("UICorner") ; TabBtnCorner.CornerRadius = UDim.new(0, 6) ; TabBtnCorner.Parent = TabBtn
    local TabFrame = Instance.new("ScrollingFrame") ; TabFrame.Parent = ContentContainer ; TabFrame.Size = UDim2.new(1, 0, 1, 0) ; TabFrame.BackgroundTransparency = 1 ; TabFrame.Visible = false ; TabFrame.CanvasSize = UDim2.new(0, 0, 0, 800) ; TabFrame.ScrollBarThickness = 3 ; TabFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
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
-- JANELA PRINCIPAL
-- ====================================================================
local TabMisc = CreateTab("Main Menu")

-- NOVO BOTÃO EQUILIBRADO: APENAS OCULTA SKILLS E ANIMAÇÕES DE ARMAS
AddToggle(TabMisc, "Ocultar Skills Globais (Weapon Blackout)", function(state)
    Config.WeaponBlackout = state
end)

-- Motor Fly
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
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.cframe = root.CFrame
    flyBodyGyro.Parent = root
    
    local Camera = workspace.CurrentCamera
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.Parent = root
    
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    
    task.spawn(function()
        while Config.Fly and root and root.Parent and hum and hum.Parent do
            RunService.RenderStepped:Wait()
            local moveDirection = hum.MoveDirection
            if moveDirection.Magnitude > 0 then
                local camCFrame = Camera.CFrame
                local localMove = camCFrame:VectorToObjectSpace(moveDirection)
                local finalDirection = (camCFrame.LookVector * (-localMove.Z)) + (camCFrame.RightVector * localMove.X)
                if finalDirection.Magnitude > 0 then flyBodyVelocity.velocity = finalDirection.Unit * Config.FlySpeed end
            else
                flyBodyVelocity.velocity = Vector3.new(0, 0, 0)
            end
            local camLook = Camera.CFrame.LookVector
            flyBodyGyro.cframe = CFrame.new(root.Position, root.Position + Vector3.new(camLook.X, camLook.Y * 0, camLook.Z))
        end
        if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
    end)
end

AddToggle(TabMisc, "Voar (Fly Infinite Yield)", function(state)
    Config.Fly = state
    if state then StartFly() else if flyBodyGyro then flyBodyGyro:Destroy() end if flyBodyVelocity then flyBodyVelocity:Destroy() end end
end)
AddToggle(TabMisc, "Manter Fly após morrer", function(state) Config.KeepFlyAfterDeath = state end)

-- WalkSpeed
AddTextBox(TabMisc, "Ajustar WalkSpeed (0-999)", function(text)
    Config.WalkSpeedValue = math.clamp(tonumber(text) or 16, 0, 999)
    if Config.WalkSpeedActive and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = Config.WalkSpeedValue
    end
end)
AddToggle(TabMisc, "Ativar WalkSpeed", function(state)
    Config.WalkSpeedActive = state
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = state and Config.WalkSpeedValue or 16 end
end)
AddToggle(TabMisc, "Manter WalkSpeed após morrer", function(state) Config.KeepSpeedAfterDeath = state end)

-- FullBright
AddToggle(TabMisc, "FullBright (Iluminação Estável)", function(state)
    Config.Fullbright = state
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255) ; Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) ; Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.fromRGB(130, 130, 130) ; Lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 130) ; Lighting.Brightness = 1
    end
end)

-- Configurações de Armas e Spam
local WeaponLabel = Instance.new("TextLabel") ; WeaponLabel.Parent = TabMisc ; WeaponLabel.Size = UDim2.new(1, -6, 0, 20) ; WeaponLabel.BackgroundTransparency = 1 ; WeaponLabel.Text = "Arma Ativa: Nenhuma" ; WeaponLabel.Font = Enum.Font.SourceSansBold ; WeaponLabel.TextColor3 = Color3.fromRGB(0, 140, 255) ; WeaponLabel.TextSize = 13
local WeaponListFrame = Instance.new("Frame") ; WeaponListFrame.Parent = TabMisc ; WeaponListFrame.Size = UDim2.new(1, -6, 0, 100) ; WeaponListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
local ListCorner = Instance.new("UICorner") ; ListCorner.CornerRadius = UDim.new(0, 6) ; ListCorner.Parent = WeaponListFrame
local ListScroll = Instance.new("ScrollingFrame") ; ListScroll.Parent = WeaponListFrame ; ListScroll.Size = UDim2.new(1, -4, 1, -4) ; ListScroll.Position = UDim2.new(0, 2, 0, 2) ; ListScroll.BackgroundTransparency = 1 ; ListScroll.CanvasSize = UDim2.new(0, 0, 0, 200) ; ListScroll.ScrollBarThickness = 2
local ListLayout = Instance.new("UIListLayout") ; ListLayout.Parent = ListScroll ; ListLayout.Padding = UDim.new(0, 4)

local function BuildWeaponMenu()
    for _, child in pairs(ListScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local foundAny = false
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            foundAny = true
            local WBtn = Instance.new("TextButton") ; WBtn.Parent = ListScroll ; WBtn.Size = UDim2.new(1, -4, 0, 25) ; WBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40) ; WBtn.Text = item.Name ; WBtn.TextColor3 = Color3.fromRGB(255, 255, 255) ; WBtn.Font = Enum.Font.SourceSansBold ; WBtn.TextSize = 12
            local c = Instance.new("UICorner") ; c.CornerRadius = UDim.new(0, 4) ; c.Parent = WBtn
            WBtn.MouseButton1Click:Connect(function()
                Config.SelectedWeapon = item.Name
                WeaponLabel.Text = "Arma Ativa: " .. item.Name
                for _, b in pairs(ListScroll:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end end
                WBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            end)
        end
    end
    if not foundAny then WeaponLabel.Text = "Nenhuma arma na Mochila! Use Refresh." end
end

AddButton(TabMisc, "🔄 Atualizar Lista de Armas", function() BuildWeaponMenu() end)
AddToggle(TabMisc, "AutoEquip Weapon", function(state) Config.AutoEquip = state end)
AddToggle(TabMisc, "Skill Spammer (Anti-Trava)", function(state) Config.SkillSpam = state end)
AddTextBox(TabMisc, "Calibrar Delay (Recomendado: 0.15 a 0.3)", function(text) Config.SpamSpeed = math.clamp(tonumber(text) or 0.15, 0.01, 3) end)

-- Loops de suporte remotes
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.AutoEquip and Config.SelectedWeapon ~= "" and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local currentTool = Player.Character:FindFirstChildOfClass("Tool")
            if not currentTool or currentTool.Name ~= Config.SelectedWeapon then
                local tool = Player.Backpack:FindFirstChild(Config.SelectedWeapon)
                if tool and tool:IsA("Tool") then Player.Character.Humanoid:EquipTool(tool) end
            end
        end
    end
end)

task.spawn(function()
    while true do
        if Config.SkillSpam and Player.Character then
            local equippedTool = Player.Character:FindFirstChildOfClass("Tool")
            if equippedTool then
                local targetPos = Player:GetMouse().Hit.Position
                local remotes = {}
                for _, child in pairs(equippedTool:GetDescendants()) do
                    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then table.insert(remotes, child) end
                end
                for _, remote in pairs(remotes) do
                    if not Config.SkillSpam then break end
                    if remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer() ; remote:FireServer(targetPos) end)
                    elseif remote:IsA("RemoteFunction") then
                        pcall(function() task.spawn(function() remote:InvokeServer(targetPos) end) end)
                    end
                    task.wait(0.02) 
                end
            end
        end
        task.wait(Config.SpamSpeed)
    end
end)

-- ====================================================================
-- INTERCEPTADOR CIRÚRGICO DE WEAPONS (FOCADO APENAS EM PODERES EXTERNOS)
-- ====================================================================
RunService.RenderStepped:Connect(function()
    if not Config.WeaponBlackout then return end
    
    local Camera = workspace.CurrentCamera
    
    -- 1. PROTEÇÃO DE CÂMERA (Impede a arma de mexer ou afastar a sua visão)
    if Camera then
        Camera.CameraType = Enum.CameraType.Custom 
        Camera.FieldOfView = 70 
    end
    
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.CameraOffset = Vector3.new(0,0,0) -- Zera tremores de tela das skills
        
        -- 2. BLOQUEIO DE ANIMAÇÕES DE ATAQUE DA FERRAMENTA EQUIPADA
        local Tool = Player.Character:FindFirstChildOfClass("Tool")
        local Animator = Player.Character.Humanoid:FindFirstChildOfClass("Animator")
        if Tool and Animator then
            for _, track in pairs(Animator:GetPlayingAnimationTracks()) do
                -- Para apenas animações ligadas à ativação de habilidades/ferramentas
                if track.Animation and (track.Name:lower():find("slash") or track.Name:lower():find("skill") or track.Name:lower():find("attack") or track.Name:lower():find("weapon")) then
                    track:Stop(0)
                end
            end
        end
    end

    -- 3. EXPURGO EXCLUSIVO DE PROJÉTEIS E PARTÍCULAS DE ARMAS NO MAPA
    for _, obj in pairs(workspace:GetChildren()) do
        -- Ignora infraestrutura básica do mapa e os personagens dos jogadores
        if obj.Name ~= "Terrain" and obj.Name ~= "Baseplate" and not obj:IsDescendantOf(Player.Character) and not game.Players:GetPlayerFromCharacter(obj) then
            
            -- Se for uma explosão física ou emissor solto no mundo, deleta na hora
            if obj:IsA("Explosion") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                pcall(function() obj:Destroy() end)
            
            -- Se for um modelo de poder/skill arremessado ou invocado:
            elseif obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") then
                -- Silencia os sons gerados pelas armas
                for _, snd in pairs(obj:GetDescendants()) do
                    if snd:IsA("Sound") then snd.Volume = 0 ; snd:Stop() end
                end
                
                -- Caça e remove os emissores e efeitos visuais internos do projétil
                for _, fx in pairs(obj:GetDescendants()) do
                    if fx:IsA("ParticleEmitter") or fx:IsA("Trail") or fx:IsA("Beam") or fx:IsA("Decal") or fx:IsA("Texture") or fx:IsA("SpecialMesh") then
                        pcall(function() fx:Destroy() end)
                    end
                end
                
                -- Deixa o objeto físico completamente transparente (para não tampar a sua visão de jogo)
                if obj:IsA("BasePart") then
                    obj.Transparency = 1
                    obj.CanCollide = false
                end
            end
        end
    end

    -- 4. MANUTENÇÃO AMBIENTAL (Limpa distorções de luz e flash sem alterar a sua UI)
    Lighting.ExposureCompensation = 0
    Lighting.FogEnd = 999999
    Lighting.FogStart = 999999
    Lighting.Brightness = Config.Fullbright and 2 or 1
    Lighting.GlobalShadows = false
    
    for _, postFx in pairs(Lighting:GetChildren()) do
        if postFx:IsA("ColorCorrectionEffect") or postFx:IsA("BlurEffect") or postFx:IsA("BloomEffect") then
            pcall(function() postFx:Destroy() end)
        end
    end
end)

-- Player ESP (Wallhack)
local function RefreshESP()
    espFolder:ClearAllChildren()
    if not Config.PlayerESP then return end
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local root = p.Character.HumanoidRootPart
            local box = Instance.new("BoxHandleAdornment") ; box.Name = p.Name .. "_ESPBox" ; box.Size = Vector3.new(4, 6, 2) ; box.Color3 = Color3.fromRGB(255, 0, 50) ; box.AlwaysOnTop = true ; box.ZIndex = 5 ; box.Transparency = 0.6 ; box.Adornee = root ; box.Parent = espFolder
            local billboard = Instance.new("BillboardGui") ; billboard.Name = p.Name .. "_ESPText" ; billboard.Size = UDim2.new(0, 200, 0, 50) ; billboard.AlwaysOnTop = true ; billboard.Adornee = root ; billboard.ExtentsOffset = Vector3.new(0, 4, 0) ; billboard.Parent = espFolder
            local label = Instance.new("TextLabel") ; label.Parent = billboard ; label.Size = UDim2.new(1, 0, 1, 0) ; label.BackgroundTransparency = 1 ; label.Text = p.Name ; label.TextColor3 = Color3.fromRGB(255, 255, 255) ; label.TextStrokeTransparency = 0 ; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) ; label.Font = Enum.Font.SourceSansBold ; label.TextSize = 14
        end
    end
end

AddToggle(TabMisc, "Player ESP (Wallhack)", function(state)
    Config.PlayerESP = state
    if not state then espFolder:ClearAllChildren() end
end)

RunService.Heartbeat:Connect(function() if Config.PlayerESP then RefreshESP() end end)

-- Loop de Persistência Pós-Morte
Player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    task.wait(0.8)
    if Config.KeepSpeedAfterDeath and Config.WalkSpeedActive then hum.WalkSpeed = Config.WalkSpeedValue end
    if Config.KeepFlyAfterDeath and Config.Fly then StartFly() end
end)

task.defer(BuildWeaponMenu)

