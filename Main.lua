-- =================================================================
-- 1. BIBLIOTECAS E SERVIÇOS (Design Otimizado Mobile / HoHo Style)
-- =================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- Usamos o tema 'BloodTheme' / 'Midnight' compacto para facilitar o arrasto na tela
local Window = Library.CreateLib("EVOMON HUB 🐺", "BloodTheme")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- =================================================================
-- 2. VARIÁVEIS DE ESTADO
-- =================================================================
local evomonSelecionado = "Nenhum"
local autoIrAteEvomon = false
local autoAttack = false
local autoCatch = false

-- Lista expandida de Evomons para a seleção automática
local listaEvomons = {
    "Todos", "Nenhum",
    -- Iniciais e Estágios
    "Leafbu", "Leafine", "Florasaur",
    "Blazpu", "Infernus", "Pyrosaur",
    "Bubble", "Aquafish", "Hydrodon",
    -- Selvagens / Raros / Biomas
    "Graveling", "Golemot", "Sparky", "Voltigo",
    "Frosty", "Icebeak", "Shadowling", "Grimclaw",
    "Pebble", "Boulder", "Zephyr", "Aerojet",
    "Lumina", "Solaur", "Duskling", "Vortex"
}

-- =================================================================
-- 3. FUNÇÕES AUXILIARES DE BUSCA E MOVIMENTAÇÃO
-- =================================================================

local function getCharacterParts()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return character, hrp, humanoid
end

-- Varre o Workspace procurando pelo Evomon
local function obterEvomonAlvo(nomeEvomon)
    local _, hrp, _ = getCharacterParts()
    if not hrp or nomeEvomon == "Nenhum" then return nil end

    local alvoMaisProximo = nil
    local menorDistancia = math.huge

    -- Busca recursiva ou direta por modelos no Workspace
    for _, objeto in pairs(Workspace:GetChildren()) do
        if objeto:IsA("Model") and objeto ~= player.Character then
            -- Verifica se bate com o nome selecionado ou se a opção é "Todos"
            if nomeEvomon == "Todos" or string.lower(objeto.Name) == string.lower(nomeEvomon) then
                local posicaoAlvo = objeto:FindFirstChild("HumanoidRootPart") 
                                 or objeto.PrimaryPart 
                                 or objeto:FindFirstChildWhichIsA("BasePart")
                
                if posicaoAlvo then
                    local distancia = (hrp.Position - posicaoAlvo.Position).Magnitude
                    if distancia < menorDistancia then
                        menorDistancia = distancia
                        alvoMaisProximo = objeto
                    end
                end
            end
        end
    end

    return alvoMaisProximo
end

local function irAteEvomon(modeloEvomon)
    local _, hrp, humanoid = getCharacterParts()
    if not hrp or not modeloEvomon then return end

    local parteAlvo = modeloEvomon:FindFirstChild("HumanoidRootPart") 
                     or modeloEvomon.PrimaryPart 
                     or modeloEvomon:FindFirstChildWhichIsA("BasePart")
    
    if parteAlvo and humanoid then
        -- Move o personagem até o monstro
        humanoid:MoveTo(parteAlvo.Position)
    end
end

-- =================================================================
-- 4. LOOPS DE AUTOMAÇÃO
-- =================================================================

-- Loop: Ir até o Evomon
task.spawn(function()
    while true do
        if autoIrAteEvomon and evomonSelecionado ~= "Nenhum" then
            local alvo = obterEvomonAlvo(evomonSelecionado)
            if alvo then 
                irAteEvomon(alvo) 
            end
        end
        task.wait(0.3)
    end
end)

-- Loop: Auto Attack
task.spawn(function()
    while true do
        if autoAttack then
            local eventoAtaque = ReplicatedStorage:FindFirstChild("AttackEvent", true) 
                              or ReplicatedStorage:FindFirstChild("BattleEvent", true)
            
            if eventoAtaque and eventoAtaque:IsA("RemoteEvent") then
                eventoAtaque:FireServer()
            end
        end
        task.wait(0.15)
    end
end)

-- Loop: Auto Catch
task.spawn(function()
    while true do
        if autoCatch then
            local eventoCaptura = ReplicatedStorage:FindFirstChild("CatchEvent", true) 
                               or ReplicatedStorage:FindFirstChild("UseBall", true)
            
            if eventoCaptura and eventoCaptura:IsA("RemoteEvent") then
                eventoCaptura:FireServer("AdvancedBall")
            end
        end
        task.wait(0.8)
    end
end)

-- =================================================================
-- 5. INTERFACE GRÁFICA (HOHO STYLE / COMPACTA)
-- =================================================================

-- ABA 1: AUTOMAÇÃO DE EVOMONS
local TabEvomon = Window:NewTab("Auto Evomon")
local SecEvomon = TabEvomon:NewSection("Detecção & Movimento")

SecEvomon:NewDropdown("Selecionar Evomon", "Escolha qual monstro buscar", listaEvomons, function(Value)
    evomonSelecionado = Value
end)

SecEvomon:NewToggle("Ir até o Evomon", "Anda automaticamente até o alvo", function(State)
    autoIrAteEvomon = State
end)

-- ABA 2: AUTO FARM & BATALHA
local TabFarm = Window:NewTab("Auto Farm")
local SecFarm = TabFarm:NewSection("Combate & Captura")

SecFarm:NewToggle("Auto Attack", "Ataca automaticamente na batalha", function(State)
    autoAttack = State
end)

SecFarm:NewToggle("Auto Catch", "Arremessa bola de captura", function(State)
    autoCatch = State
end)

-- ABA 3: CONFIGURAÇÕES DA UI
local TabConfig = Window:NewTab("Configurações")
local SecConfig = TabConfig:NewSection("Controle da Janela")

SecConfig:NewKeybind("Ocultar/Exibir Painel", "Aperte para esconder o painel", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)
