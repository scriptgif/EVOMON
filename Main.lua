-- Carrega a Biblioteca de UI (Exemplo: Orion Library)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Cria a Janela Principal do Painel
local Window = OrionLib:MakeWindow({
    Name = "Evomon - Control Panel", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "EvomonConfig"
})

-- =================================================================
-- ABAS DO PAINEL
-- =================================================================

-- Aba 1: Teleportes
local TeleportTab = Window:MakeTab({
    Name = "Teleportes",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Aba 2: Seleção & Busca de Evomons
local TargetTab = Window:MakeTab({
    Name = "Evomons & Alvos",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Aba 3: Automação (Combate e Captura)
local AutoFarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- =================================================================
-- ELEMENTOS INICIAIS DA INTERFACE
-- =================================================================

--- ABAS DE TELEPORTE ---
TeleportTab:AddSection({
    Name = "Teleporte para Ilhas/Biomas"
})

-- Exemplo de seletor de ilhas (preencheremos com as coordenadas reais depois)
TeleportTab:AddDropdown({
    Name = "Selecione a Ilha",
    Default = "Verdant",
    Options = {"Verdant", "Mundo 2", "Arena Global", "Centro de Trocas"},
    Callback = function(Value)
        print("Ilha selecionada:", Value)
    end
})

TeleportTab:AddButton({
    Name = "Teleportar para a Ilha Selecionada",
    Callback = function()
        print("Executando teleporte...")
    end
})

--- ABAS DE EVOMONS & ALVOS ---
TargetTab:AddSection({
    Name = "Detecção e Seleção"
})

TargetTab:AddDropdown({
    Name = "Selecionar Evomon Específico",
    Default = "Nenhum",
    Options = {"Nenhum", "Leafbu", "Blazpu", "Bubble"},
    Callback = function(Value)
        print("Alvo selecionado:", Value)
    end
})

TargetTab:AddToggle({
    Name = "Ir até o Evomon Selecionado",
    Default = false,
    Callback = function(State)
        print("Busca por alvo:", State)
    end
})

--- ABAS DE AUTO FARM ---
AutoFarmTab:AddSection({
    Name = "Combate e Captura"
})

AutoFarmTab:AddToggle({
    Name = "Atacar Automaticamente",
    Default = false,
    Callback = function(State)
        print("Auto Attack:", State)
    end
})

AutoFarmTab:AddToggle({
    Name = "Capturar Automaticamente",
    Default = false,
    Callback = function(State)
        print("Auto Catch:", State)
    end
})

-- Inicializa a Interface
OrionLib:Init()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Função para obter a posição atual do personagem do jogador
local function getCharacterParts()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return character, hrp, humanoid
end

-- 1. Função para encontrar o Evomon mais próximo pelo nome
local function obterEvomonAlvo(nomeEvomon)
    local _, hrp, _ = getCharacterParts()
    if not hrp then return nil end

    local alvoMaisProximo = nil
    local menorDistancia = math.huge

    -- Procura no Workspace (se os Evomons estiverem em uma pasta específica, ajuste 'Workspace' para a pasta)
    for _, objeto in pairs(Workspace:GetChildren()) do
        -- Verifica se o modelo existe, tem o nome correto e possui uma parte principal (HumanoidRootPart ou PrimaryPart)
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

-- 2. Função para mover o personagem até o alvo
local function irAteEvomon(modeloEvomon)
    local _, hrp, humanoid = getCharacterParts()
    if not hrp or not modeloEvomon then return end

    local parteAlvo = modeloEvomon:FindFirstChild("HumanoidRootPart") or modeloEvomon.PrimaryPart or modeloEvomon:FindFirstChildWhichIsA("BasePart")
    if not parteAlvo then return end

    -- Opção A: Caminhar naturalmente até a posição
    if humanoid then
        humanoid:MoveTo(parteAlvo.Position)
    end

    -- Opção B: Teleporte direto (comente a Opção A e descomente a linha abaixo se preferir ir instantaneamente)
    -- hrp.CFrame = parteAlvo.CFrame * CFrame.new(0, 3, 0) -- Teleporta 3 blocos acima do alvo
end
local evomonSelecionado = "Leafbu" -- Nome definido pelo Dropdown
local buscando = false

-- Exemplo do evento acionado pelo Toggle de "Ir até o Evomon"
local function iniciarBusca(estado)
    buscando = estado
    
    task.spawn(function()
        while buscando do
            local alvo = obterEvomonAlvo(evomonSelecionado)
            
            if alvo then
                irAteEvomon(alvo)
            end
            
            task.wait(1) -- Intervalo de checagem a cada 1 segundo
        end
    end)
end
-- =================================================================
-- TABELA DE COORDENADAS (ILHAS / LOCAIS)
-- =================================================================
-- Substitua ou adicione os Vector3 de cada ilha/local conforme achar no jogo
local LocaisEvomon = {
    ["Verdant (Mundo 1)"] = Vector3.new(100, 15, 200),
    ["Mundo 2"]           = Vector3.new(500, 20, -1200),
    ["Centro de Trocas"]  = Vector3.new(0, 5, 0),
    ["Arena Global"]      = Vector3.new(-300, 10, 850)
}

local ilhaSelecionada = "Verdant (Mundo 1)"

-- Função de Teleporte
local function teleportarPara(posicaoVector3)
    local _, hrp, _ = getCharacterParts()
    if hrp and posicaoVector3 then
        hrp.CFrame = CFrame.new(posicaoVector3 + Vector3.new(0, 3, 0)) -- Teleporta 3 blocos acima do chão
    end
end
-- =================================================================
-- VARIÁVEIS DE AUTOMAÇÃO
-- =================================================================
local autoAttack = false
local autoCatch = false

-- ReplicatedStorage para acessar os eventos do jogo
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Loop de Combate Automático
task.spawn(function()
    while true do
        if autoAttack then
            -- Mapeie aqui o RemoteEvent de ataque do jogo (exemplo genérico)
            local eventoAtaque = ReplicatedStorage:FindFirstChild("AttackEvent", true) or ReplicatedStorage:FindFirstChild("BattleEvent", true)
            
            if eventoAtaque and eventoAtaque:IsA("RemoteEvent") then
                eventoAtaque:FireServer() -- Envia o comando de ataque
            end
        end
        task.wait(0.2) -- Frequência dos ataques
    end
end)

-- Loop de Captura Automática
task.spawn(function()
    while true do
        if autoCatch then
            -- Mapeie aqui o RemoteEvent de captura do jogo (exemplo genérico)
            local eventoCaptura = ReplicatedStorage:FindFirstChild("CatchEvent", true) or ReplicatedStorage:FindFirstChild("UseBall", true)
            
            if eventoCaptura and eventoCaptura:IsA("RemoteEvent") then
                eventoCaptura:FireServer("AdvancedBall") -- Substitua pelo nome da bola desejada
            end
        end
        task.wait(1) -- Verifica/Aplica captura a cada 1 segundo
    end
end)
--- ABA DE TELEPORTES ---
TeleportTab:AddSection({
    Name = "Locais do Mapa"
})

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
        if pos then
            teleportarPara(pos)
        end
    end
})

--- ABA DE AUTO FARM ---
AutoFarmTab:AddSection({
    Name = "Automação de Batalha"
})

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
-- Finaliza e carrega a interface gráfica
OrionLib:Init()
print("Sua Posição:", game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
