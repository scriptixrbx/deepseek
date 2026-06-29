local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаём GUI для полей ввода, если его нет
local gui = PlayerGui:FindFirstChild("TradeNameChangerGUI")
if not gui then
    gui = Instance.new("ScreenGui")
    gui.Name = "TradeNameChangerGUI"
    gui.Parent = PlayerGui
    gui.ResetOnSpawn = false -- не удалять при респавне
end

-- Функция создания текстового поля с подписью
local function CreateTextBox(name, placeholderText, position)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 1
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 60, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -70, 1, 0)
    box.Position = UDim2.new(0, 65, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = placeholderText
    box.Text = ""
    box.Font = Enum.Font.SourceSans
    box.TextSize = 14
    box.Parent = frame

    return box
end

-- Создаём поля, если их нет, или берём существующие
local oldBox = gui:FindFirstChild("OldNameBox") or CreateTextBox("Old name", "Enter old name", UDim2.new(0, 10, 0, 10))
if not oldBox:IsA("TextBox") then oldBox = CreateTextBox("Old name", "Enter old name", UDim2.new(0, 10, 0, 10)) end
oldBox.Name = "OldNameBox"

local newBox = gui:FindFirstChild("NewNameBox") or CreateTextBox("New name", "Enter new name", UDim2.new(0, 10, 0, 60))
if not newBox:IsA("TextBox") then newBox = CreateTextBox("New name", "Enter new name", UDim2.new(0, 10, 0, 60)) end
newBox.Name = "NewNameBox"

-- Переменные для хранения имён
local currentOld = ""
local currentNew = ""

-- Обновляем при изменении текста
oldBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentOld = oldBox.Text
end)

newBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentNew = newBox.Text
end)

-- Функция замены во всех текстовых объектах
local function ReplaceAll()
    if currentOld == "" or currentNew == "" then return end
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local txt = obj.Text
            if txt and string.find(txt, currentOld, 1, true) then
                local newTxt = string.gsub(txt, currentOld, currentNew)
                if newTxt ~= txt then
                    obj.Text = newTxt
                end
            end
        end
    end
end

-- Постоянная проверка каждый кадр
RunService.Heartbeat:Connect(function()
    ReplaceAll()
end)

-- Отслеживание добавления новых объектов
game.DescendantAdded:Connect(function()
    task.wait(0.1)
    ReplaceAll()
end)

-- Отслеживание изменения текста у существующих объектов
local function WatchTextChanges(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            task.wait(0.1)
            ReplaceAll()
        end)
    end
end

for _, obj in ipairs(game:GetDescendants()) do
    WatchTextChanges(obj)
end

game.DescendantAdded:Connect(function(obj)
    WatchTextChanges(obj)
end)

-- Первичная замена
task.wait(0.5)
ReplaceAll()

print("✅ Trade Name Changer loaded!")
print("Old name: " .. currentOld .. " → New name: " .. currentNew)
