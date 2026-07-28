-- =================================================================
-- 1. BIBLIOTECAS E SERVIÇOS
-- =================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("EVOMON HUB 🐺", "BloodTheme")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- =================================================================
-- 2. VARIÁVEIS DE ESTADO
-- =================================================================
local evomonSelecionado = "Nenhum"
local autoIrAteEvomon = false
local autoAttack = false
local autoCatch = false

local listaEvomons = {
    "Todos", "Nenhum",
    "Leafbu", "Leafine", "Florasaur",
    "Blazpu", "Infernus", "Pyrosaur",
    "Bubble", "Aquafish", "Hydrodon",
    "Graveling", "Golemot", "Sparky", "Voltigo",
    "Frosty", "Icebeak", "Shadowling", "Grimclaw",
    "Pebble", "Boulder", "Zephyr", "Aerojet",
    "Lumina", "Solaur", "Duskling", "Vortex"
}

-- =================================================================
-- 3. BOTÃO FLUTUANTE (TOGGLE UI HOHO STYLE)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")

ScreenGui.Name = "EvomonHubGui"
ScreenGui.Parent = game:GetService("CoreGui") or player:FindFirstChildOfClass("PlayerGui")
ScreenGui.ResetOnSpawn = false

ToggleBtn.Name = "ToggleHub"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.Position = UDim2.new(0, 10, 0, 150)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "🐺"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 25
ToggleBtn.Active = true
ToggleBtn.Draggable = true -- Permite arrastar o botão flutuante para qualquer lugar

ToggleBtn.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

-- =================================================================
-- 4. FUNÇÕES DE MOVIMENTAÇÃO E BUSCA
-- =================================================================

local function getCharacterParts()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return character, hrp, humanoid
end

-- Busca avançada por Evomons dentro de pastas ou soltos no Workspace
local function obterEvomonAlvo(nomeEvomon)
    local _, hrp, _ = getCharacterParts()
    if not hrp or nomeEvomon == "Nenhum" then return nil end

    local alvoMaisProximo = nil
    local menorDistancia = math.huge

    local function checarModelo(objeto)
        if objeto:IsA("Model") and objeto ~= player.Character then
            local nomeValido = (nomeEvomon == "Todos") or (string.lower(objeto.Name) == string.lower(nomeEvomon))
            if nomeValido then
                local parteBase = objeto:FindFirstChild("HumanoidRootPart") 
                               or objeto.PrimaryPart 
                               or objeto:FindFirstChildWhichIsA("BasePart")
                if parteBase then
                    local dist = (hrp.Position - parteBase.Position).Magnitude
                    if dist < menorDistancia then
                        menorDistancia = dist
                        alvoMaisProximo = objeto
                    end
                end
            end
        end
    end

    -- Varre Workspace e pastas internas (ex: Spawns/Wilds)
    for _, obj in pairs(Workspace:GetChildren()) do
        checarModelo(obj)
        if obj:IsA("Folder") or obj:IsA("Model") then
            for _, subObj in pairs(obj:GetChildren()) do
                checarModelo(subObj)
            end
        end
    end

    return alvoMaisProximo
end

-- Movimentação direta ajustada
local function irAteEvomon(modeloEvomon)
    local character, hrp, humanoid = getCharacterParts()
    if not hrp or not modeloEvomon then return end

    local parteAlvo = modeloEvomon:FindFirstChild("HumanoidRootPart") 
                     or modeloEvomon.PrimaryPart 
                     or modeloEvomon:FindFirstChildWhichIsA("BasePart")
    
    if parteAlvo then
        local distancia = (hrp.Position - parteAlvo.Position).Magnitude
        
        -- Se estiver longe, teleporta/move até ficar colado no monstro
        if distancia > 4 then
            if humanoid then
                humanoid:MoveTo(parteAlvo.Position)
            end
            -- Garante a aproximação suave
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(parteAlvo.Position.X, hrp.Position.Y, parteAlvo.Position.Z))
        end
    end
end

-- =================================================================
-- 5. LOOPS DE AUTOMAÇÃO
-- =================================================================

-- Loop: Aproximação do Evomon
task.spawn(function()
    while true do
        if autoIrAteEvomon and evomonSelecionado ~= "Nenhum" then
            local alvo = obterEvomonAlvo(evomonSelecionado)
            if alvo then 
                irAteEvomon(alvo) 
            end
        end
        task.wait(0.1)
    end
end)

-- Loop: Auto Attack Corrigido
task.spawn(function()
    while true do
        if autoAttack then
            -- 1. Tenta acionar remotes de ataque
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "attack") or string.find(string.lower(obj.Name), "battle") or string.find(string.lower(obj.Name), "skill")) then
                    obj:FireServer()
                elseif obj:IsA("RemoteFunction") and (string.find(string.lower(obj.Name), "attack") or string.find(string.lower(obj.Name), "battle")) then
                    pcall(function() obj:InvokeServer() end)
                end
            end
            
            -- 2. Simula o clique de ataque na tela para batalhas por turno/interativas
            VirtualUser:Button1Down(Vector2.new(0, 0))
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end
        task.wait(0.2)
    end
end)

-- Loop: Auto Catch
task.spawn(function()
    while true do
        if autoCatch then
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "catch") or string.find(string.lower(obj.Name), "ball") or string.find(string.lower(obj.Name), "capture")) then
                    obj:FireServer("AdvancedBall")
                end
            end
        end
        task.wait(0.8)
    end
end)

-- =================================================================
-- 6. INTERFACE GRÁFICA
-- =================================================================

local TabEvomon = Window:NewTab("Auto Evomon")
local SecEvomon = TabEvomon:NewSection("Detecção & Movimento")

SecEvomon:NewDropdown("Selecionar Evomon", "Escolha o alvo", listaEvomons, function(Value)
    evomonSelecionado = Value
end)

SecEvomon:NewToggle("Ir até o Evomon", "Aproxima do monstro", function(State)
    autoIrAteEvomon = State
end)

local TabFarm = Window:NewTab("Auto Farm")
local SecFarm = TabFarm:NewSection("Combate & Captura")

SecFarm:NewToggle("Auto Attack", "Ataca na batalha", function(State)
    autoAttack = State
end)

SecFarm:NewToggle("Auto Catch", "Arremessa bola", function(State)
    autoCatch = State
end)
