local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаём GUI, если его нет
local gui = PlayerGui:FindFirstChild("TradeNameChangerGUI")
if not gui then
    gui = Instance.new("ScreenGui")
    gui.Name = "TradeNameChangerGUI"
    gui.Parent = PlayerGui
    gui.ResetOnSpawn = false
end

-- Функция создания поля ввода
local function CreateTextBox(name, placeholder, posY)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 35)
    frame.Position = UDim2.new(0, 10, 0, posY)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 1
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 70, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -80, 1, 0)
    box.Position = UDim2.new(0, 75, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Font = Enum.Font.SourceSans
    box.TextSize = 14
    box.Parent = frame
    return box
end

-- Создаём поля (или берём существующие)
local oldBox = gui:FindFirstChild("OldNameBox")
if not oldBox or not oldBox:IsA("TextBox") then
    oldBox = CreateTextBox("Old name", "Введи старое имя", 10)
    oldBox.Name = "OldNameBox"
end

local newBox = gui:FindFirstChild("NewNameBox")
if not newBox or not newBox:IsA("TextBox") then
    newBox = CreateTextBox("New name", "Введи новое имя", 55)
    newBox.Name = "NewNameBox"
end

-- Переменные для имён
local currentOld = ""
local currentNew = ""

oldBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentOld = oldBox.Text
end)

newBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentNew = newBox.Text
end)

-- Замена во всех текстовых объектах
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

-- Постоянное сканирование (каждый кадр)
RunService.Heartbeat:Connect(ReplaceAll)

-- Реакция на новые объекты
game.DescendantAdded:Connect(function()
    task.wait(0.1)
    ReplaceAll()
end)

-- Отслеживание изменений текста
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

-- Первичный запуск
task.wait(0.5)
ReplaceAll()

print("✅ Trade Name Changer loaded!")
