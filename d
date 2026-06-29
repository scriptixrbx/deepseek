-- Простой и рабочий скрипт для замены ника в трейде Adopt Me
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TradeNameChanger"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 120)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
Title.BorderSizePixel = 0
Title.Text = "Trade Name Changer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local NewNameLabel = Instance.new("TextLabel")
NewNameLabel.Size = UDim2.new(1, -20, 0, 18)
NewNameLabel.Position = UDim2.new(0, 10, 0, 38)
NewNameLabel.BackgroundTransparency = 1
NewNameLabel.Text = "New name (will replace opponent's nick):"
NewNameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
NewNameLabel.TextSize = 11
NewNameLabel.Font = Enum.Font.Gotham
NewNameLabel.TextXAlignment = Enum.TextXAlignment.Left
NewNameLabel.Parent = MainFrame

local NewNameBox = Instance.new("TextBox")
NewNameBox.Size = UDim2.new(1, -20, 0, 28)
NewNameBox.Position = UDim2.new(0, 10, 0, 58)
NewNameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
NewNameBox.BorderSizePixel = 0
NewNameBox.Text = "zolo"
NewNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NewNameBox.TextSize = 14
NewNameBox.Font = Enum.Font.Gotham
NewNameBox.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 10, 0, 92)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Waiting for trade..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Функция поиска всех TextLabel в трейде
local function getTradeTextLabels()
    local labels = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text and obj.Text ~= "" then
            -- Проверяем, что объект находится внутри интерфейса трейда
            local parent = obj.Parent
            while parent do
                if parent.Name:lower():find("trade") then
                    table.insert(labels, obj)
                    break
                end
                parent = parent.Parent
            end
        end
    end
    return labels
end

-- Функция определения ника соперника
local function findOpponentName()
    local labels = getTradeTextLabels()
    local myName = player.DisplayName ~= "" and player.DisplayName or player.Name
    
    for _, label in ipairs(labels) do
        local text = label.Text
        -- Отсеиваем системные надписи
        if text ~= "Trade" and text ~= "Accept" and text ~= "Decline" 
            and text ~= "Add" and text ~= "Inventory" and text ~= "Reset"
            and not text:find("Click") and not text:find("Offer") 
            and #text >= 3 and #text <= 20 and not text:find(" ") then
            -- Убеждаемся, что это не наш собственный ник
            if text ~= myName then
                return text
            end
        end
    end
    return nil
end

-- Замена ника соперника во всех TextLabel трейда
local function replaceOpponentName(oldName, newName)
    local count = 0
    local labels = getTradeTextLabels()
    for _, label in ipairs(labels) do
        if label.Text:find(oldName) then
            label.Text = label.Text:gsub(oldName, newName)
            count = count + 1
        end
    end
    return count
end

-- Главный цикл: каждые 0.3 секунды проверяем трейд
local lastOpponent = ""
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local opponent = findOpponentName()
            if opponent then
                if opponent ~= lastOpponent then
                    lastOpponent = opponent
                    local newName = NewNameBox.Text
                    if newName ~= "" then
                        local replaced = replaceOpponentName(opponent, newName)
                        StatusLabel.Text = "✅ " .. opponent .. " → " .. newName .. " (" .. replaced .. ")"
                        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    else
                        StatusLabel.Text = "🔍 Found: " .. opponent .. " (no replacement)"
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                    end
                else
                    -- Трейд ещё открыт, продолжаем замену на случай появления новых элементов
                    local newName = NewNameBox.Text
                    if newName ~= "" then
                        replaceOpponentName(opponent, newName)
                    end
                end
            else
                if lastOpponent ~= "" then
                    lastOpponent = ""
                    StatusLabel.Text = "Waiting for trade..."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                end
            end
        end)
    end
end)

-- Немедленная реакция на появление новых объектов
game.DescendantAdded:Connect(function(obj)
    if obj:IsA("TextLabel") then
        task.wait(0.1)
        pcall(function()
            local opponent = findOpponentName()
            if opponent and opponent ~= lastOpponent then
                lastOpponent = opponent
                local newName = NewNameBox.Text
                if newName ~= "" then
                    local replaced = replaceOpponentName(opponent, newName)
                    StatusLabel.Text = "✅ " .. opponent .. " → " .. newName .. " (" .. replaced .. ")"
                    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                end
            end
        end)
    end
end)

print("Trade Name Changer ready! New name: " .. NewNameBox.Text)
