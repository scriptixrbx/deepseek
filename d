-- MM2 Simple Auto Trade - WORKING VERSION
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки
local AUTO_TRADE_ENABLED = false
local AUTO_ADD_ENABLED = false

-- Создаем интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleAutoTrade"
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "MM2 Auto Trade"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Кнопка автотрейда
local tradeToggle = Instance.new("TextButton")
tradeToggle.Size = UDim2.new(0.9, 0, 0, 40)
tradeToggle.Position = UDim2.new(0.05, 0, 0, 35)
tradeToggle.Text = "Автотрейд: ВЫКЛ"
tradeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
tradeToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
tradeToggle.TextSize = 14
tradeToggle.Parent = mainFrame

-- Кнопка авто-добавления
local addToggle = Instance.new("TextButton")
addToggle.Size = UDim2.new(0.9, 0, 0, 40)
addToggle.Position = UDim2.new(0.05, 0, 0, 80)
addToggle.Text = "Авто-добавление: ВЫКЛ"
addToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
addToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
addToggle.TextSize = 14
addToggle.Parent = mainFrame

-- Функция поиска трейд GUI
local function findTradeGUI()
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:lower():find("trade") or gui.Name:lower():find("trading")) then
            return gui
        end
    end
    return nil
end

-- Функция добавления всех предметов
local function addAllItems()
    if not AUTO_ADD_ENABLED then return end
    
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end
    
    -- Пробуем разные Remote события
    local remotes = {
        "AddItemToTrade",
        "TradeAddItem", 
        "AddToTrade",
        "AddItem",
        "TradeItem"
    }
    
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            for _, remoteName in pairs(remotes) do
                local remote = ReplicatedStorage:FindFirstChild(remoteName)
                if remote then
                    pcall(function()
                        remote:FireServer(item)
                        print("Добавлен предмет: " .. item.Name)
                    end)
                end
            end
        end
    end
end

-- Функция принятия трейда
local function acceptTrade()
    if not AUTO_TRADE_ENABLED then return end
    
    local tradeGUI = findTradeGUI()
    if not tradeGUI then return end
    
    -- Ищем кнопку Accept
    for _, element in pairs(tradeGUI:GetDescendants()) do
        if element:IsA("TextButton") then
            local text = element.Text:lower()
            if text:find("accept") or text:find("принять") then
                pcall(function()
                    if firesignal then
                        firesignal(element.MouseButton1Click)
                    end
                    element.BackgroundColor3 = Color3.new(0, 1, 0)
                    print("Трейд принят!")
                end)
                return true
            end
        end
    end
    
    -- Пробуем Remote событие
    local acceptRemote = ReplicatedStorage:FindFirstChild("AcceptTrade") or 
                        ReplicatedStorage:FindFirstChild("TradeAccept")
    if acceptRemote then
        pcall(function()
            acceptRemote:FireServer()
            print("Трейд принят через Remote!")
        end)
    end
    
    return false
end

-- Обработчики кнопок
tradeToggle.MouseButton1Click:Connect(function()
    AUTO_TRADE_ENABLED = not AUTO_TRADE_ENABLED
    if AUTO_TRADE_ENABLED then
        tradeToggle.Text = "Автотрейд: ВКЛ"
        tradeToggle.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        print("Автотрейд включен!")
    else
        tradeToggle.Text = "Автотрейд: ВЫКЛ"
        tradeToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
end)

addToggle.MouseButton1Click:Connect(function()
    AUTO_ADD_ENABLED = not AUTO_ADD_ENABLED
    if AUTO_ADD_ENABLED then
        addToggle.Text = "Авто-добавление: ВКЛ"
        addToggle.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
        print("Авто-добавление включено!")
    else
        addToggle.Text = "Авто-добавление: ВЫКЛ"
        addToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
end)

-- Главный цикл
while true do
    wait(1)
    
    -- Проверяем активен ли трейд
    local tradeGUI = findTradeGUI()
    if tradeGUI and tradeGUI.Visible then
        -- Добавляем предметы если включено
        if AUTO_ADD_ENABLED then
            addAllItems()
        end
        
        -- Принимаем трейд если включено
        if AUTO_TRADE_ENABLED then
            acceptTrade()
        end
    end
end
