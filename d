-- MM2 Auto Trade Script v7 - AUTO ADD ALL INVENTORY ITEMS
-- Автоматически добавляет все предметы из инвентаря в трейд

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки
local AUTO_TRADE_ENABLED = false
local AUTO_ADD_ENABLED = false
local TRADE_CHECK_INTERVAL = 2
local WIN_THRESHOLD = 1.05 -- 5% выгоды

-- Кэш цен
local itemValues = {}
local addedItems = {} -- Отслеживаем уже добавленные предметы

-- Фиксированные цены для популярных предметов
local function fetchItemValue(itemName)
    local priceList = {
        -- Godly
        icebreaker = 120,
        luger = 100,
        fang = 85,
        heartblade = 75,
        gemstone = 65,
        frostbite = 60,
        flames = 55,
        ["fire tiger"] = 45,
        ["brush knife"] = 40,
        vampire = 35,
        
        -- Ancient
        ancient = 150,
        ["amerilaser"] = 140,
        ["eternal"] = 130,
        
        -- Common (для теста)
        knife = 5,
        gun = 5,
        sword = 5
    }
    
    local cleanName = itemName:lower():gsub("%s+", "")
    return priceList[cleanName] or 10 -- Дефолтная цена
end

-- Функция для клика по кнопкам
local function clickButton(button)
    if button and button:IsA("TextButton") then
        pcall(function()
            if button.Visible then
                -- Визуальная обратная связь
                local originalColor = button.BackgroundColor3
                button.BackgroundColor3 = Color3.new(0, 1, 0)
                
                -- Симулируем клик
                if firesignal then
                    firesignal(button.MouseButton1Click)
                end
                
                wait(0.1)
                button.BackgroundColor3 = originalColor
                return true
            end
        end)
    end
    return false
end

-- Поиск интерфейса торговли
local function findTradeInterface()
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:lower():find("trade") or gui.Name:lower():find("trading")) then
            return gui
        end
    end
    return nil
end

-- Поиск кнопок в интерфейсе
local function findTradeButtons(tradeGui)
    local buttons = {}
    
    for _, element in pairs(tradeGui:GetDescendants()) do
        if element:IsA("TextButton") then
            local text = element.Text:lower()
            local name = element.Name:lower()
            
            if text:find("accept") or text:find("принять") or name:find("accept") then
                buttons.accept = element
            end
            
            if text:find("decline") or text:find("отказаться") or name:find("decline") then
                buttons.decline = element
            end
            
            if text:find("confirm") or text:find("подтвердить") then
                buttons.confirm = element
            end
        end
    end
    
    return buttons
end

-- Получение предметов из инвентаря
local function getInventoryItems()
    local items = {}
    local backpack = player:FindFirstChild("Backpack")
    
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(items, {
                    name = item.Name,
                    object = item
                })
            end
        end
    end
    
    return items
end

-- Автоматическое добавление ВСЕХ предметов из инвентаря
local function autoAddAllItems()
    if not AUTO_ADD_ENABLED then return end
    
    local tradeGui = findTradeInterface()
    if not tradeGui or not tradeGui.Visible then
        return
    end
    
    local inventoryItems = getInventoryItems()
    local addedCount = 0
    
    for _, itemData in pairs(inventoryItems) do
        -- Проверяем, не добавляли ли уже этот предмет
        if not addedItems[itemData.name] then
            pcall(function()
                -- Способ 1: Через Remote Events
                local addRemote = ReplicatedStorage:FindFirstChild("AddItemToTrade") or
                                ReplicatedStorage:FindFirstChild("TradeAddItem") or
                                ReplicatedStorage:FindFirstChild("AddToTrade")
                
                if addRemote then
                    addRemote:FireServer(itemData.object)
                    print("✅ Добавлен предмет:", itemData.name)
                    addedItems[itemData.name] = true
                    addedCount = addedCount + 1
                else
                    -- Способ 2: Через интерфейсные кнопки
                    for _, element in pairs(tradeGui:GetDescendants()) do
                        if element:IsA("ImageButton") and element.Name == itemData.name then
                            clickButton(element)
                            print("✅ Добавлен через кнопку:", itemData.name)
                            addedItems[itemData.name] = true
                            addedCount = addedCount + 1
                            break
                        end
                    end
                end
            end)
        end
    end
    
    if addedCount > 0 then
        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("add Добавлено " .. addedCount .. " предметов!")
    end
    
    return addedCount
end

-- Получение предметов из сторон торговли
local function getTradeItems(tradeGui)
    local myItems = {}
    local theirItems = {}
    
    for _, frame in pairs(tradeGui:GetDescendants()) do
        if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
            for _, item in pairs(frame:GetDescendants()) do
                if (item:IsA("ImageButton") or item:IsA("TextLabel")) and item.Text ~= "" then
                    local itemName = item.Text or item.Name
                    if frame.Name:lower():find("my") or frame.Name:lower():find("left") then
                        table.insert(myItems, itemName)
                    elseif frame.Name:lower():find("other") or frame.Name:lower():find("right") then
                        table.insert(theirItems, itemName)
                    end
                end
            end
        end
    end
    
    return myItems, theirItems
end

-- Расчет стоимости
local function calculateTradeValue(items)
    local total = 0
    for _, itemName in pairs(items) do
        total = total + fetchItemValue(itemName)
    end
    return total
end

-- Основная логика трейда
local function performAutoTrade()
    if not AUTO_TRADE_ENABLED then return end
    
    local tradeGui = findTradeInterface()
    if not tradeGui or not tradeGui.Visible then
        return
    end
    
    -- Автоматически добавляем предметы при открытии трейда
    if AUTO_ADD_ENABLED then
        autoAddAllItems()
    end
    
    -- Получаем кнопки
    local buttons = findTradeButtons(tradeGui)
    
    -- Получаем предметы и считаем стоимость
    local myItems, theirItems = getTradeItems(tradeGui)
    local myValue = calculateTradeValue(myItems)
    local theirValue = calculateTradeValue(theirItems)
    
    print("📊 Мои предметы:", #myItems, "Цена:", myValue)
    print("📊 Их предметы:", #theirItems, "Цена:", theirValue)
    
    -- Принимаем решение
    if myValue > 0 and theirValue > 0 then
        local ratio = theirValue / myValue
        
        if ratio >= WIN_THRESHOLD then
            -- ВЫГОДНЫЙ ТРЕЙД
            if buttons.accept then
                clickButton(buttons.accept)
                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("add ✅ ВЫГОДА " .. math.floor((ratio-1)*100) .. "%! Принимаю!")
                print("✅ Принят выгодный трейд!")
            end
        else
            -- НЕВЫГОДНЫЙ ТРЕЙД
            if buttons.decline then
                clickButton(buttons.decline)
                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("no ❌ Проигрыш " .. math.floor((1-ratio)*100) .. "%! Отказываюсь!")
                print("❌ Отказано от невыгодного трейда!")
            end
        end
    end
end

-- Сброс добавленных предметов при закрытии трейда
local function resetAddedItems()
    local tradeGui = findTradeInterface()
    if not tradeGui or not tradeGui.Visible then
        addedItems = {}
    end
end

-- Создание интерфейса
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2AutoTradeV7"
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 180)
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
    title.Text = "MM2 Auto Trade v7"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Кнопка автотрейда
    local tradeToggle = Instance.new("TextButton")
    tradeToggle.Size = UDim2.new(0.9, 0, 0, 35)
    tradeToggle.Position = UDim2.new(0.05, 0, 0, 35)
    tradeToggle.Text = "Автотрейд: ВЫКЛ"
    tradeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    tradeToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    tradeToggle.TextSize = 14
    tradeToggle.Parent = mainFrame
    
    tradeToggle.MouseButton1Click:Connect(function()
        AUTO_TRADE_ENABLED = not AUTO_TRADE_ENABLED
        if AUTO_TRADE_ENABLED then
            tradeToggle.Text = "Автотрейд: ВКЛ"
            tradeToggle.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("🤖 Автотрейд АКТИВИРОВАН!")
        else
            tradeToggle.Text = "Автотрейд: ВЫКЛ"
            tradeToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        end
    end)
    
    -- Кнопка авто-добавления ВСЕХ предметов
    local addToggle = Instance.new("TextButton")
    addToggle.Size = UDim2.new(0.9, 0, 0, 35)
    addToggle.Position = UDim2.new(0.05, 0, 0, 75)
    addToggle.Text = "Авто-добавление: ВЫКЛ"
    addToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    addToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    addToggle.TextSize = 14
    addToggle.Parent = mainFrame
    
    addToggle.MouseButton1Click:Connect(function()
        AUTO_ADD_ENABLED = not AUTO_ADD_ENABLED
        if AUTO_ADD_ENABLED then
            addToggle.Text = "Авто-добавление: ВКЛ"
            addToggle.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("📦 Авто-добавление ВКЛ!")
        else
            addToggle.Text = "Авто-добавление: ВЫКЛ"
            addToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        end
    end)
    
    -- Статус
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0, 50)
    status.Position = UDim2.new(0.05, 0, 0, 115)
    status.Text = "Ожидание трейда..."
    status.TextColor3 = Color3.fromRGB(220, 220, 220)
    status.BackgroundTransparency = 1
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = mainFrame
    
    -- Обновление статуса
    spawn(function()
        while true do
            wait(2)
            local tradeGui = findTradeInterface()
            local inventory = getInventoryItems()
            
            local statusText = "Автотрейд: " .. (AUTO_TRADE_ENABLED and "ВКЛ" : "ВЫКЛ")
            statusText = statusText .. "\nАвто-добавление: " .. (AUTO_ADD_ENABLED and "ВКЛ" : "ВЫКЛ")
            statusText = statusText .. "\nИнвентарь: " .. #inventory .. " предметов"
            
            if tradeGui and tradeGui.Visible then
                statusText = statusText .. "\n🎯 ТРЕЙД АКТИВЕН!"
            end
            
            status.Text = statusText
        end
    end)
end

-- Запуск системы
createGUI()

-- Основной цикл
spawn(function()
    while true do
        wait(TRADE_CHECK_INTERVAL)
        pcall(performAutoTrade)
        pcall(resetAddedItems)
    end
end)

print("🎯 MM2 Auto Trade v7 ЗАГРУЖЕН!")
print("📦 Функции:")
print("• Автоматически добавляет ВСЕ предметы из инвентаря")
print("• Автоматически принимает/отклоняет трейды")
print("• Работает с любыми предметами")

game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("🤖 AutoTrade v7 loaded! Добавляет ВСЕ предметы автоматически!")
