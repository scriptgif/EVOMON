-- =================================================================
-- EVOMON HUB 🐺 - COM TEMPORIZADOR DE ATAQUE (SEM TRAVAMENTOS)
-- =================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- VARIÁVEIS DE CONFIGURAÇÃO
local autoIrAteEvomon = false
local autoAttack = false
local autoCatch = false
local distanciaAproximacao = 3
local tempoAtaque = 0.8 -- Tempo de pausa entre cada ataque (segundos)

-- =================================================================
-- 1. FUNÇÕES DE MOVIMENTAÇÃO E BUSCA
-- =================================================================
local function irAteEvomonBloxFruits()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local menorDistancia = math.huge
    local parteAlvo = nil

    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj) then
            local parte = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if parte then
                local dist = (hrp.Position - parte.Position).Magnitude
                if dist < menorDistancia and dist > 2 then
                    menorDistancia = dist
                    parteAlvo = parte
                end
            end
        end
    end

    if parteAlvo then
        local CFrameAlvo = parteAlvo.CFrame * CFrame.new(distanciaAproximacao, 1, 0)
        hrp.CFrame = CFrameAlvo
    end
end

-- =================================================================
-- 2. LOOPS DE AUTOMAÇÃO
-- =================================================================

-- Loop 1: Ir até o Evomon
task.spawn(function()
    while task.wait(0.1) do
        if autoIrAteEvomon then
            pcall(irAteEvomonBloxFruits)
        end
    end
end)

-- Loop 2: Auto Attack Com Temporizador
task.spawn(function()
    while true do
        if autoAttack then
            pcall(function()
                local playerGui = player:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    for _, gui in pairs(playerGui:GetDescendants()) do
                        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                            local nome = string.lower(gui.Name)
                            local texto = (gui:IsA("TextButton") and string.lower(gui.Text)) or ""
                            
                            -- Procura pelo botão Automático ou habilidades de batalha
                            if string.find(nome, "auto") or string.find(texto, "automático") or string.find(texto, "automatico") or string.find(nome, "skill") then
                                local pos = gui.AbsolutePosition
                                local size = gui.AbsoluteSize
                                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, true, game, 0)
                                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, game, 0)
                            end
                        end
                    end
                end
            end)
            -- Pausa com base no slider selecionado para não travar o jogo
            task.wait(tempoAtaque)
        else
            task.wait(0.5)
        end
    end
end)

-- Loop 3: Auto Catch
task.spawn(function()
    while task.wait(0.5) do
        if autoCatch then
            pcall(function()
                local playerGui = player:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    for _, gui in pairs(playerGui:GetDescendants()) do
                        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                            local nome = string.lower(gui.Name)
                            local texto = (gui:IsA("TextButton") and string.lower(gui.Text)) or ""
                            
                            if string.find(nome, "catch") or string.find(texto, "catch") then
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

-- BOTÃO FLUTUANTE
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

-- ABAS DA INTERFACE
local Tab1 = Window:NewTab("Auto Evomon")
local Sec1 = Tab1:NewSection("Movimentação Blox Fruits")

Sec1:NewToggle("Ir até o Evomon (Teleporte)", "Teleporta do lado do monstro", function(state)
    autoIrAteEvomon = state
end)

Sec1:NewSlider("Distância do Teleporte", "Ajusta a proximidade", 10, 1, function(val)
    distanciaAproximacao = val
end)

local Tab2 = Window:NewTab("Auto Farm")
local Sec2 = Tab2:NewSection("Combate & Captura")

Sec2:NewToggle("Auto Attack", "Ativa a batalha automática", function(state)
    autoAttack = state
end)

-- Controle do temporizador de ataque diretamente pelo menu (0.2s a 2s)
Sec2:NewSlider("Atraso do Ataque (Segundos)", "Evita travamentos e lags", 20, 2, function(val)
    tempoAtaque = val / 10 -- Converte o valor do slider em segundos (ex: 8 = 0.8s)
end)

Sec2:NewToggle("Auto Catch", "Clica no botão de captura", function(state)
    autoCatch = state
end)
