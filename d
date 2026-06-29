-- Поля для ввода старого и нового имени (создай их в ScreenGui)
local OldNameBox = script.Parent.OldNameBox  -- замени путь
local NewNameBox = script.Parent.NewNameBox  -- замени путь

local currentOld = ""
local currentNew = ""

-- Обновляем значения при изменении текста в полях
OldNameBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentOld = OldNameBox.Text
end)

NewNameBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentNew = NewNameBox.Text
end)

-- Флаг для предотвращения рекурсивных вызовов при замене
local isProcessing = false

-- Функция замены текста в одном объекте
local function ProcessObject(obj)
    if isProcessing then return end
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
        return
    end
    if currentOld == "" or currentNew == "" then return end

    local originalText = obj.Text
    if originalText and string.find(originalText, currentOld, 1, true) then
        isProcessing = true
        local newText = string.gsub(originalText, currentOld, currentNew, 1) -- заменяем только первое вхождение? лучше все
        -- Чтобы заменить все вхождения, используй string.gsub без лимита
        newText = string.gsub(originalText, currentOld, currentNew) -- заменит все
        if newText ~= originalText then
            obj.Text = newText
        end
        isProcessing = false
    end
end

-- Функция для обработки всех существующих объектов
local function ProcessAllExisting()
    for _, obj in ipairs(game:GetDescendants()) do
        ProcessObject(obj)
    end
end

-- Отслеживаем новые объекты
game.DescendantAdded:Connect(function(obj)
    task.wait(0.05) -- небольшая задержка для гарантии, что объект полностью создан
    ProcessObject(obj)
end)

-- Отслеживаем изменение текста в любом объекте (чтобы реагировать на обновления сообщений)
local function WatchTextChanges(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            task.wait(0.05)
            ProcessObject(obj)
        end)
    end
end

-- Навешиваем слежение на все существующие объекты
for _, obj in ipairs(game:GetDescendants()) do
    WatchTextChanges(obj)
end

-- Навешиваем слежение на новые объекты
game.DescendantAdded:Connect(function(obj)
    WatchTextChanges(obj)
end)

-- Первичная обработка после небольшой задержки
task.wait(0.5)
ProcessAllExisting()

print("Trade Name Changer loaded!")
print("Old: " .. currentOld .. " → New: " .. currentNew)
