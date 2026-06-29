-- Пути к полям ввода (замени на свои)
local OldNameBox = script.Parent.OldNameBox
local NewNameBox = script.Parent.NewNameBox

local currentOld = ""
local currentNew = ""

-- Обновляем значения при вводе
OldNameBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentOld = OldNameBox.Text
end)

NewNameBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentNew = NewNameBox.Text
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

-- Постоянная проверка каждый кадр (надёжно перехватывает любые новые объекты)
game:GetService("RunService").Heartbeat:Connect(function()
    ReplaceAll()
end)

-- Также обрабатываем добавление новых объектов (для ускорения реакции)
game.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    ReplaceAll()
end)

-- Следим за изменением текста у существующих объектов (для оперативности)
local function WatchTextChanges(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            task.wait(0.1)
            ReplaceAll()
        end)
    end
end

-- Навешиваем на все текущие объекты
for _, obj in ipairs(game:GetDescendants()) do
    WatchTextChanges(obj)
end

-- Навешиваем на новые объекты
game.DescendantAdded:Connect(function(obj)
    WatchTextChanges(obj)
end)

-- Первичный запуск
task.wait(0.5)
ReplaceAll()

print("Trade Name Changer loaded with periodic scan!")
