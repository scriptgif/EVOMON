-- =================================================================
-- 1. BIBLIOTECAS E SERVIÇOS
-- =================================================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- =================================================================
-- 2. VARIÁVEIS DE ESTADO
-- =================================================================
local evomonSelecionado = "Nenhum"
local autoIrAteEvomon = false
local ilhaSelecionada = "Verdant (Mundo 1)"
local autoAttack = false
local autoCatch = false

-- Tabela de Coordenadas dos Teleportes
local LocaisEvomon = {
    ["Verdant (Mundo 1)"] = Vector3.new(100, 15, 200),
    ["Mundo 2"]           = Vector3.new(500, 20, -1200),
    ["Centro de Trocas"]  = Vector3.new(0, 5, 0),
    ["Arena Global"]      = Vector3.new(-300, 10, 850)
}

-- =================================================================
-- 3. FUNÇÕES AUXILIARES
-- =================================================================

local function getCharacterParts()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return character, hrp, humanoid
end

local function teleportarPara(posicaoVector3)
    local _, hrp, _ = getCharacterParts()
    if hrp and posicaoVector3 then
        hrp.CFrame = CFrame.new(posicaoVector3 + Vector3.new(0, 3, 0))
    end
end

local function obterEvomonAlvo(nomeEvomon)
    local _, hrp, _ = getCharacterParts()
    if not hrp or nomeEvomon == "Nenhum" then return nil end

    local alvoMaisProximo = nil
    local menorDistancia = math.huge

    for _, objeto in pairs(Workspace:GetChildren()) do
        if objeto:IsA("Model") and (nomeEvomon == "Todos" or objeto.Name == nomeEvomon) then
            local posicaoAlvo = objeto:FindFirstChild("HumanoidRootPart") or objeto.PrimaryPart or objeto:FindFirstChildWhichIsA("BasePart")
            if posicaoAlvo then
                local distancia = (hrp.Position - posicaoAlvo.Position).Magnitude
                if distancia < menorDistancia then
                    menorDistancia = distancia
                    alvoMaisProximo = objeto
                end
            end
        end
    end

    return alvoMaisProximo
end

local function irAteEvomon(modeloEvomon)
    local _, hrp, humanoid = getCharacterParts()
    if not hrp or not modeloEvomon then return end

    local parteAlvo = modeloEvomon:FindFirstChild("HumanoidRootPart") or modeloEvomon.PrimaryPart or modeloEvomon:FindFirstChildWhichIsA("BasePart")
    if parteAlvo and humanoid then
        humanoid:MoveTo(parteAlvo.Position)
    end
end

-- =================================================================
-- 4. LOOPS ASSÍNCRONOS
-- =================================================================

task.spawn(function()
    while true do
        if autoIrAteEvomon and evomonSelecionado ~= "Nenhum" then
            local alvo = obterEvomonAlvo(evomonSelecionado)
            if alvo then irAteEvomon(alvo) end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if autoAttack then
            local eventoAtaque = ReplicatedStorage:FindFirstChild("AttackEvent", true) or ReplicatedStorage:FindFirstChild("BattleEvent", true)
            if eventoAtaque and eventoAtaque:IsA("RemoteEvent") then
                eventoAtaque:FireServer()
            end
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    while true do
        if autoCatch then
            local eventoCaptura = ReplicatedStorage:FindFirstChild("CatchEvent", true) or ReplicatedStorage:FindFirstChild("UseBall", true)
            if eventoCaptura and eventoCaptura:IsA("RemoteEvent") then
                eventoCaptura:FireServer("AdvancedBall")
            end
        end
        task.wait(1)
    end
end)

-- =================================================================
-- 5. INTERFACE GRÁFICA (ORION UI)
-- =================================================================
local Window = OrionLib:MakeWindow({
    Name = "Evomon - Control Panel", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "EvomonConfig"
})

-- ABA 1: TARGET
local TargetTab = Window:MakeTab({
    Name = "Evomons & Alvos",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TargetTab:AddSection({ Name = "Seleção e Movimentação" })

TargetTab:AddDropdown({
    Name = "Selecionar Evomon",
    Default = "Nenhum",
    Options = {"Nenhum", "Todos", "Leafbu", "Blazpu", "Bubble"},
    Callback = function(Value)
        evomonSelecionado = Value
    end
})

TargetTab:AddToggle({
    Name = "Ir até o Evomon Selecionado",
    Default = false,
    Callback = function(State)
        autoIrAteEvomon = State
    end
})

-- ABA 2: TELEPORTES
local TeleportTab = Window:MakeTab({
    Name = "Teleportes",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TeleportTab:AddSection({ Name = "Locais do Mapa" })

TeleportTab:AddDropdown({
    Name = "Selecione o Destino",
    Default = "Verdant (Mundo 1)",
    Options = {"Verdant (Mundo 1)", "Mundo 2", "Centro de Trocas", "Arena Global"},
    Callback = function(Value)
        ilhaSelecionada = Value
    end
})

TeleportTab:AddButton({
    Name = "Teleportar Agora",
    Callback = function()
        local pos = LocaisEvomon[ilhaSelecionada]
        if pos then teleportarPara(pos) end
    end
})

-- ABA 3: AUTO FARM
local AutoFarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AutoFarmTab:AddSection({ Name = "Automação de Batalha" })

AutoFarmTab:AddToggle({
    Name = "Auto Attack",
    Default = false,
    Callback = function(State)
        autoAttack = State
    end
})

AutoFarmTab:AddToggle({
    Name = "Auto Catch (Captura)",
    Default = false,
    Callback = function(State)
        autoCatch = State
    end
})

-- =================================================================
-- 6. INICIALIZAÇÃO DA INTERFACE
-- =================================================================
OrionLib:Init()
