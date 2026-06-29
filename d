-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NameChanger"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
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
Title.Text = "Trade Name Changer"
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

-- Поле Old Name (то что ищем)
local OldNameLabel = Instance.new("TextLabel")
OldNameLabel.Size = UDim2.new(1, -20, 0, 20)
OldNameLabel.Position = UDim2.new(0, 10, 0, 40)
OldNameLabel.BackgroundTransparency = 1
OldNameLabel.Text = "Old name (auto-detected):"
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
OldNameBox.PlaceholderText = "Waiting for trade..."
OldNameBox.TextColor3 = Color3.fromRGB(255, 255, 100)
OldNameBox.TextSize = 14
OldNameBox.Font = Enum.Font.Gotham
OldNameBox.TextEditable = false
OldNameBox.Parent = MainFrame

-- Поле New Name (сюда вводим на что менять)
local NewNameLabel = Instance.new("TextLabel")
NewNameLabel.Size = UDim2.new(1, -20, 0, 20)
NewNameLabel.Position = UDim2.new(0, 10, 0, 100)
NewNameLabel.BackgroundTransparency = 1
NewNameLabel.Text = "New name (edit to change):"
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
NewNameBox.Text = "zolo"
NewNameBox.PlaceholderText = "Enter name to show..."
NewNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NewNameBox.TextSize = 14
NewNameBox.Font = Enum.Font.Gotham
NewNameBox.Parent = MainFrame

-- Status лейбл
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 155)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "✅ Ready - waiting for trade"
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Переменные
local currentOldName = ""
local foundNames = {}

-- Функция проверки что объект в трейде
local function IsInTrade(obj)
    local parent = obj.Parent
    while parent do
        local name = parent.Name:lower()
        if name:find("trade") then
            return true
        end
        parent = parent.Parent
    end
    return false
end

-- Функция проверки что это ник (а не текст интерфейса)
local function IsNickname(text)
    if not text then return false end
    if #text < 3 or #text > 20 then return false end
    if text:find("Trade") or text:find("Accept") or text:find("Decline") then return false end
    if text:find("Add") or text:find("Inventory") or text:find("Click") then return false end
    if text:find("Pet") or text:find("Egg") or text:find("Vehicle") then return false end
    if text:find("Toy") or text:find("Food") or text:find("Gift") then return false end
    if text:find("You") or text:find("Offer") or text:find("Reset") then return false end
    if text:find("%s") then return false end -- нет пробелов
    return true
end

-- Функция поиска ника в трейде
local function FindTradeName()
    local possibleNames = {}
    
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            if IsInTrade(obj) and obj.Text and obj.Visible then
                local text = obj.Text
                if IsNickname(text) then
                    -- Проверяем что это не наш ник
                    local player = game.Players.LocalPlayer
                    if player and text ~= player.Name and text ~= player.DisplayName then
                        table.insert(possibleNames, text)
                    end
                end
            end
        end
    end
    
    -- Возвращаем самый часто встречающийся ник
    if #possibleNames > 0 then
        local counts = {}
        for _, name in ipairs(possibleNames) do
            counts[name] = (counts[name] or 0) + 1
        end
        
        local bestName = possibleNames[1]
        local bestCount = 0
        for name, count in pairs(counts) do
            if count > bestCount then
                bestCount = count
                bestName = name
            end
        end
        
        return bestName
    end
    
    return nil
end

-- Функция замены текста
local function ReplaceName(oldName, newName)
    if not oldName or oldName == "" then return 0 end
    if not newName or newName == "" then return 0 end
    
    local count = 0
    
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if obj.Text and obj.Text:find(oldName) then
                -- Меняем только в трейде и чате
                if IsInTrade(obj) or obj.Parent.Name:lower():find("notif") or obj.Parent.Name:lower():find("chat") then
                    obj.Text = obj.Text:gsub(oldName, newName)
                    count = count + 1
                end
            end
        end
    end
    
    return count
end

-- Главная функция - поиск и замена
local function CheckAndReplace()
    local foundName = FindTradeName()
    
    if foundName and foundName ~= currentOldName then
        currentOldName = foundName
        OldNameBox.Text = foundName
        StatusLabel.Text = "🔍 Found: " .. foundName
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        -- Сразу меняем
        local newName = NewNameBox.Text
        if newName ~= "" then
            local count = ReplaceName(foundName, newName)
            if count > 0 then
                StatusLabel.Text = "✅ Replaced: " .. foundName .. " → " .. newName .. " (" .. count .. ")"
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        end
    end
    
    -- Если трейд открыт и ник найден - продолжаем менять
    if currentOldName ~= "" then
        local newName = NewNameBox.Text
        if newName ~= "" then
            local count = ReplaceName(currentOldName, newName)
            if count > 0 then
                StatusLabel.Text = "✅ Active: " .. currentOldName .. " → " .. newName
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        end
    end
    
    -- Проверяем не закрылся ли трейд
    local tradeOpen = false
    for _, obj in ipairs(game:GetDescendants()) do
        if IsInTrade(obj) then
            tradeOpen = true
            break
        end
    end
    
    if not tradeOpen and currentOldName ~= "" then
        currentOldName = ""
        OldNameBox.Text = ""
        StatusLabel.Text = "✅ Ready - waiting for trade"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end

-- Постоянная проверка каждые 200мс
task.spawn(function()
    while task.wait(0.2) do
        pcall(CheckAndReplace)
    end
end)

-- Отслеживание новых объектов
game.DescendantAdded:Connect(function(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        task.wait(0.05)
        pcall(CheckAndReplace)
    end
end)

-- Отслеживание изменения текста
game.DescendantAdded:Connect(function(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            task.wait(0.05)
            pcall(CheckAndReplace)
        end)
    end
end)

print("Trade Name Changer loaded!")
print("Edit 'New name' field to set replacement name")
