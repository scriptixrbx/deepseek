-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NameChanger"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 150)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
Title.BorderSizePixel = 0
Title.Text = "Auto Trade Name"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Поле для нового ника (сюда авто-копируется ник из трейда)
local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.new(1, -20, 0, 30)
NameBox.Position = UDim2.new(0, 10, 0, 45)
NameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
NameBox.BorderSizePixel = 0
NameBox.Text = ""
NameBox.PlaceholderText = "Nick will appear here..."
NameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NameBox.TextSize = 14
NameBox.Font = Enum.Font.Gotham
NameBox.Parent = MainFrame

-- Кнопка Apply
local ApplyButton = Instance.new("TextButton")
ApplyButton.Size = UDim2.new(1, -20, 0, 30)
ApplyButton.Position = UDim2.new(0, 10, 0, 85)
ApplyButton.BackgroundColor3 = Color3.fromRGB(65, 130, 200)
ApplyButton.BorderSizePixel = 0
ApplyButton.Text = "APPLY NAME"
ApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyButton.TextSize = 14
ApplyButton.Font = Enum.Font.GothamBold
ApplyButton.Parent = MainFrame

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 120)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Waiting for trade..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Функция проверки что объект в трейде
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

-- Функция поиска ника в трейде
local function FindNameInTrade()
    local names = {}
    
    for _, obj in ipairs(game:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text and obj.Visible then
            if IsInTrade(obj) then
                local text = obj.Text
                -- Отсеиваем системные надписи
                if text ~= "Trade" and text ~= "Accept" and text ~= "Decline" 
                    and text ~= "Add" and text ~= "Inventory" and text ~= "Reset"
                    and not text:find("Pet") and not text:find("Egg") and not text:find("Vehicle")
                    and not text:find("Toy") and not text:find("Food") and not text:find("Gift")
                    and not text:find("Click") and not text:find("Offer")
                    and #text >= 3 and #text <= 20 and not text:find(" ") then
                    
                    -- Исключаем свой ник
                    local player = game.Players.LocalPlayer
                    if player and text ~= player.Name and text ~= player.DisplayName then
                        names[text] = (names[text] or 0) + 1
                    end
                end
            end
        end
    end
    
    -- Находим самый частый ник
    local bestName = nil
    local bestCount = 0
    for name, count in pairs(names) do
        if count > bestCount then
            bestCount = count
            bestName = name
        end
    end
    
    return bestName
end

-- Функция замены ника в трейде
local function ReplaceInTrade(oldName, newName)
    local count = 0
    for _, obj in ipairs(game:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.Text then
            if IsInTrade(obj) and obj.Text:find(oldName) then
                obj.Text = obj.Text:gsub(oldName, newName)
                count = count + 1
            end
        end
    end
    return count
end

-- Переменная для хранения оригинального ника
local originalName = ""

-- Функция применения ника
local function ApplyName()
    local newName = NameBox.Text
    if newName == "" then
        StatusLabel.Text = "❌ Enter a name first!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    if originalName == "" then
        StatusLabel.Text = "❌ No trade detected!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    local count = ReplaceInTrade(originalName, newName)
    if count > 0 then
        StatusLabel.Text = "✅ Changed to: " .. newName .. " (" .. count .. ")"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        StatusLabel.Text = "❌ Name not found in trade"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- Кнопка Apply
ApplyButton.MouseButton1Click:Connect(ApplyName)

-- Авто-поиск ника при открытии трейда
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local foundName = FindNameInTrade()
            
            if foundName then
                if foundName ~= originalName then
                    originalName = foundName
                    NameBox.Text = foundName
                    StatusLabel.Text = "🔍 Found: " .. foundName
                    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                end
            else
                if originalName ~= "" then
                    originalName = ""
                    StatusLabel.Text = "Waiting for trade..."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                end
            end
        end)
    end
end)

-- Отслеживание появления трейда
game.DescendantAdded:Connect(function(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        task.wait(0.2)
        pcall(function()
            local foundName = FindNameInTrade()
            if foundName and foundName ~= originalName then
                originalName = foundName
                NameBox.Text = foundName
                StatusLabel.Text = "🔍 Found: " .. foundName
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        end)
    end
end)

print("Script loaded! When trade opens, name will appear automatically.")
