-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NameChanger"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
Title.BorderSizePixel = 0
Title.Text = "Auto Trade Name Changer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Поле Old Name (автоматически заполняется)
local OldNameLabel = Instance.new("TextLabel")
OldNameLabel.Size = UDim2.new(1, -20, 0, 20)
OldNameLabel.Position = UDim2.new(0, 10, 0, 40)
OldNameLabel.BackgroundTransparency = 1
OldNameLabel.Text = "Detected name (last trade):"
OldNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
OldNameLabel.TextSize = 12
OldNameLabel.Font = Enum.Font.Gotham
OldNameLabel.TextXAlignment = Enum.TextXAlignment.Left
OldNameLabel.Parent = MainFrame

local OldNameBox = Instance.new("TextBox")
OldNameBox.Size = UDim2.new(1, -20, 0, 30)
OldNameBox.Position = UDim2.new(0, 10, 0, 60)
OldNameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
OldNameBox.BorderSizePixel = 0
OldNameBox.Text = ""
OldNameBox.PlaceholderText = "Auto-detected..."
OldNameBox.TextColor3 = Color3.fromRGB(255, 255, 100)
OldNameBox.TextSize = 14
OldNameBox.Font = Enum.Font.Gotham
OldNameBox.ClearTextOnFocus = false
OldNameBox.Parent = MainFrame

-- Поле New Name (редактируемое)
local NewNameLabel = Instance.new("TextLabel")
NewNameLabel.Size = UDim2.new(1, -20, 0, 20)
NewNameLabel.Position = UDim2.new(0, 10, 0, 100)
NewNameLabel.BackgroundTransparency = 1
NewNameLabel.Text = "New name (edit this):"
NewNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
NewNameLabel.TextSize = 12
NewNameLabel.Font = Enum.Font.Gotham
NewNameLabel.TextXAlignment = Enum.TextXAlignment.Left
NewNameLabel.Parent = MainFrame

local NewNameBox = Instance.new("TextBox")
NewNameBox.Size = UDim2.new(1, -20, 0, 30)
NewNameBox.Position = UDim2.new(0, 10, 0, 120)
NewNameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
NewNameBox.BorderSizePixel = 0
NewNameBox.Text = ""
NewNameBox.PlaceholderText = "Enter new name..."
NewNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NewNameBox.TextSize = 14
NewNameBox.Font = Enum.Font.Gotham
NewNameBox.Parent = MainFrame

-- История трейдов
local HistoryLabel = Instance.new("TextLabel")
HistoryLabel.Size = UDim2.new(1, -20, 0, 15)
HistoryLabel.Position = UDim2.new(0, 10, 0, 155)
HistoryLabel.BackgroundTransparency = 1
HistoryLabel.Text = "Last trades:"
HistoryLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
HistoryLabel.TextSize = 11
HistoryLabel.Font = Enum.Font.Gotham
HistoryLabel.TextXAlignment = Enum.TextXAlignment.Left
HistoryLabel.Parent = MainFrame

local HistoryBox = Instance.new("TextBox")
HistoryBox.Size = UDim2.new(1, -20, 0, 25)
HistoryBox.Position = UDim2.new(0, 10, 0, 170)
HistoryBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
HistoryBox.BorderSizePixel = 0
HistoryBox.Text = ""
HistoryBox.TextColor3 = Color3.fromRGB(180, 180, 180)
HistoryBox.TextSize = 11
HistoryBox.Font = Enum.Font.Gotham
HistoryBox.TextEditable = false
HistoryBox.TextXAlignment = Enum.TextXAlignment.Left
HistoryBox.Parent = MainFrame

-- Status лейбл
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 15)
StatusLabel.Position = UDim2.new(0, 10, 0, 200)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Waiting for trade..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Переменные
local lastTradeNames = {} -- хранит последние 5 ников
local currentOldName = ""
local isInTrade = false
local tradeNameChecked = false

-- Функция для проверки что объект в трейде
local function IsInTrade(obj)
    local parent = obj.Parent
    while parent do
        if parent.Name:lower():find("trade") then
            return true
        end
        parent = parent.Parent
    end
    return false
end

-- Функция для проверки что объект в чате/уведомлениях
local function IsInChat(obj)
    local parent = obj.Parent
    while parent do
        local name = parent.Name:lower()
        if name:find("notif") or name:find("message") or name:find("chat") then
            return true
        end
        parent = parent.Parent
    end
    return false
end

-- Функция для извлечения ника из текста (ищет @username или просто имя)
local function ExtractName(text)
    -- Убираем @ если есть
    local name = text:gsub("@", "")
    -- Убираем пробелы по краям
    name = name:match("^%s*(.-)%s*$")
    return name
end

-- Функция для поиска ника в трейде
local function FindTradeName()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if IsInTrade(obj) and obj.Text and obj.Text ~= "" then
                local text = obj.Text
                
                -- Пропускаем системные тексты
                if text:find("Trade") or text:find("Accept") or text:find("Decline") or 
                   text:find("Add") or text:find("Inventory") or text:find("You") or
                   text:find("Pet") or text:find("Item") or text:find("Click") then
                    goto continue
                end
                
                -- Проверяем что это ник (обычно короткий текст без спецсимволов)
                if #text >= 3 and #text <= 20 and not text:find("%s") then
                    -- Проверяем что это не название предмета
                    if not text:find("Egg") and not text:find("Pet") and not text:find("Vehicle") then
                        local name = ExtractName(text)
                        if name ~= "" then
                            return name
                        end
                    end
                end
                
                ::continue::
            end
        end
    end
    return nil
end

-- Функция для поиска ника в сообщениях о трейде
local function FindChatTradeName(obj)
    if obj.Text and obj.Text:find("trade") then
        -- Ищем ник в сообщении
        for word in obj.Text:gmatch("%S+") do
            if #word >= 3 and #word <= 20 and not word:find("trade") then
                local clean = ExtractName(word)
                if clean ~= "" and clean ~= "You" and clean ~= "you" then
                    return clean
                end
            end
        end
    end
    return nil
end

-- Функция добавления ника в историю
local function AddToHistory(name)
    -- Проверяем что такого ника еще нет в истории
    for _, n in ipairs(lastTradeNames) do
        if n == name then
            return
        end
    end
    
    table.insert(lastTradeNames, 1, name)
    
    -- Храним только 5 последних
    if #lastTradeNames > 5 then
        table.remove(lastTradeNames)
    end
    
    -- Обновляем историю в GUI
    HistoryBox.Text = table.concat(lastTradeNames, " → ")
end

-- Функция замены текста
local function ReplaceText(obj)
    if not obj or not obj.Text then return false end
    if currentOldName == "" then return false end
    
    local newName = NewNameBox.Text
    if newName == "" then return false end
    
    local changed = false
    
    if obj.Text == currentOldName then
        obj.Text = newName
        changed = true
    elseif obj.Text:find(currentOldName) then
        obj.Text = obj.Text:gsub(currentOldName, newName)
        changed = true
    end
    
    return changed
end

-- Обработка объекта
local function ProcessObject(obj)
    if not obj:IsA("TextLabel") and not obj:IsA("TextButton") and not obj:IsA("TextBox") then
        return
    end
    
    if not obj.Text then return end
    
    -- Проверяем не появился ли трейд
    if IsInTrade(obj) and not isInTrade then
        isInTrade = true
        tradeNameChecked = false
        StatusLabel.Text = "🔍 Trade detected! Scanning..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
    
    -- Если мы в трейде и еще не нашли ник
    if isInTrade and not tradeNameChecked then
        task.wait(0.5) -- Ждем загрузки трейда
        
        local foundName = FindTradeName()
        if foundName then
            currentOldName = foundName
            OldNameBox.Text = foundName
            AddToHistory(foundName)
            tradeNameChecked = true
            StatusLabel.Text = "✅ Detected: " .. foundName
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end
    
    -- Если трейд закрылся
    if not IsInTrade(obj) and isInTrade then
        -- Проверяем действительно ли трейд закрылся
        local tradeStillOpen = false
        for _, o in ipairs(game:GetDescendants()) do
            if IsInTrade(o) then
                tradeStillOpen = true
                break
            end
        end
        
        if not tradeStillOpen then
            isInTrade = false
            tradeNameChecked = false
            StatusLabel.Text = "Waiting for trade..."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end
    
    -- Замена текста
    if currentOldName ~= "" and NewNameBox.Text ~= "" then
        if obj.Text:find(currentOldName) then
            if IsInTrade(obj) or IsInChat(obj) then
                if ReplaceText(obj) then
                    StatusLabel.Text = "✅ Replaced: " .. currentOldName .. " → " .. NewNameBox.Text
                    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                end
            end
        end
    end
end

-- Функция для проверки сообщений чата (для поиска ника)
local function CheckChatForName(obj)
    if not obj.Text then return end
    
    if obj.Text:find("trade") and not obj.Text:find("Trade") then
        local name = FindChatTradeName(obj)
        if name and currentOldName == "" then
            currentOldName = name
            OldNameBox.Text = name
            AddToHistory(name)
            StatusLabel.Text = "✅ Found in chat: " .. name
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end
end

-- Обработка всех существующих объектов
local function ProcessAllExisting()
    for _, obj in ipairs(game:GetDescendants()) do
        ProcessObject(obj)
        CheckChatForName(obj)
    end
end

-- Отслеживание новых объектов
game.DescendantAdded:Connect(function(obj)
    task.wait(0.05)
    ProcessObject(obj)
    CheckChatForName(obj)
end)

-- Отслеживание изменения текста
local function WatchTextChanges(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            task.wait(0.05)
            ProcessObject(obj)
            CheckChatForName(obj)
        end)
    end
end

-- Вешаем отслеживание на все существующие объекты
for _, obj in ipairs(game:GetDescendants()) do
    WatchTextChanges(obj)
end

-- Вешаем отслеживание на новые объекты
game.DescendantAdded:Connect(function(obj)
    WatchTextChanges(obj)
end)

-- Периодическая проверка (каждые 500мс) на случай пропуска
task.spawn(function()
    while task.wait(0.5) do
        if isInTrade and not tradeNameChecked then
            local foundName = FindTradeName()
            if foundName then
                currentOldName = foundName
                OldNameBox.Text = foundName
                AddToHistory(foundName)
                tradeNameChecked = true
                StatusLabel.Text = "✅ Detected: " .. foundName
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        end
        
        -- Проверяем не закрылся ли трейд
        if isInTrade then
            local tradeFound = false
            for _, obj in ipairs(game:GetDescendants()) do
                if IsInTrade(obj) then
                    tradeFound = true
                    break
                end
            end
            if not tradeFound then
                isInTrade = false
                tradeNameChecked = false
                StatusLabel.Text = "Waiting for trade..."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
        end
    end
end)

-- Запуск
task.wait(1)
ProcessAllExisting()
print("Auto Trade Name Changer loaded!")
