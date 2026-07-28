-- =================================================================
-- EVOMON HUB 🐺 (Baseado nas telas reais do jogo)
-- =================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- VARIÁVEIS DE CONFIGURAÇÃO
local autoIrAteEvomon = false
local autoAttack = false
local autoCatch = false

-- =================================================================
-- 1. FUNÇÃO DE ANDAR ATÉ O MONSTRO NO MAPA
-- =================================================================
local function irAteMonstroProximo()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    local menorDistancia = math.huge
    local posicaoAlvo = nil

    -- Varre os objetos do mapa procurando modelos de monstros com Humanoid ou partes principais
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj) then
            -- Procura por parte física do monstro
            local parte = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if parte then
                local dist = (hrp.Position - parte.Position).Magnitude
                -- Filtra por monstros próximos (evita alvos infinitamente distantes)
                if dist < menorDistancia and dist > 3 then
                    menorDistancia = dist
                    posicaoAlvo = parte.Position
                end
            end
        end
    end

    -- Se achou o monstro, faz o personagem andar direto até a exclamação/corpo dele
    if posicaoAlvo and hum then
        hum:MoveTo(posicaoAlvo)
    end
end

-- =================================================================
-- 2. LOOPS DE AUTOMAÇÃO
-- =================================================================

-- Loop 1: Ir até o monstro no mapa (Entrar em batalha)
task.spawn(function()
    while task.wait(0.3) do
        if autoIrAteEvomon then
            irAteMonstroProximo()
        end
    end
end)

-- Loop 2: Auto Batalha / Ataque (Aciona a interface da batalha)
task.spawn(function()
    while task.wait(0.5) do
        if autoAttack then
            pcall(function()
                local playerGui = player:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    -- Procura pelo botão AUTOMÁTICO na interface de Batalha (visível na print)
                    for _, gui in pairs(playerGui:GetDescendants()) do
                        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                            local nomeLower = string.lower(gui.Name)
                            local textoLower = (gui:IsA("TextButton") and string.lower(gui.Text)) or ""
                            
                            -- Se encontrar o botão 'Automático' ou botões de skill, simula o clique
                            if string.find(nomeLower, "auto") or string.find(textoLower, "automático") or string.find(textoLower, "automatico") then
                                local pos = gui.AbsolutePosition
                                local size = gui.AbsoluteSize
                                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, true, game, 0)
                                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, game, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop 3: Auto Catch (Simula toque no botão 'Catch' e arremesso)
task.spawn(function()
    while task.wait(0.5) do
        if autoCatch then
            pcall(function()
                local playerGui = player:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    for _, gui in pairs(playerGui:GetDescendants()) do
                        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                            local nomeLower = string.lower(gui.Name)
                            local textoLower = (gui:IsA("TextButton") and string.lower(gui.Text)) or ""
                            
                            -- Clica no botão Catch central que aparece na foto 4
                            if string.find(nomeLower, "catch") or string.find(textoLower, "catch") then
                                local pos = gui.AbsolutePosition
                                local size = gui.AbsoluteSize
                                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, true, game, 0)
                                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, game, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. INTERFACE GRÁFICA (KAVO UI)
-- =================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("EVOMON HUB 🐺", "BloodTheme")

-- BOTÃO FLUTUANTE (TOGGLE HOHO STYLE)
local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")

ScreenGui.Name = "EvomonHubToggle"
ScreenGui.Parent = game:GetService("CoreGui") or player:FindFirstChildOfClass("PlayerGui")

ToggleBtn.Name = "BtnToggle"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ToggleBtn.Position = UDim2.new(0, 10, 0, 200)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Text = "🐺"
ToggleBtn.TextSize = 25
ToggleBtn.Active = true
ToggleBtn.Draggable = true

ToggleBtn.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

-- ABAS SIMPLIFICADAS E DIRETAS
local Tab1 = Window:NewTab("Auto Evomon")
local Sec1 = Tab1:NewSection("Movimentação no Mapa")

Sec1:NewToggle("Ir até o Evomon Próximo", "Caminha até os monstros com exclamação", function(state)
    autoIrAteEvomon = state
end)

local Tab2 = Window:NewTab("Auto Farm")
local Sec2 = Tab2:NewSection("Automação de Batalha")

Sec2:NewToggle("Auto Attack (Ativa Automático)", "Liga a batalha automática na luta", function(state)
    autoAttack = state
end)

Sec2:NewToggle("Auto Catch", "Clica no botão Catch na captura", function(state)
    autoCatch = state
end)
