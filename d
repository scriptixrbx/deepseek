--[[
    Adopt Me Pet Spawning Script
    This script allows users to spawn pets from a predefined list.
    It handles case-insensitive input, validates against the list,
    and suggests close matches using Levenshtein distance.
    Placeholder functions are provided for game-specific I/O and API calls.
]]

-- ============================================================
-- 1. Define the list of valid pet names (as per Adopt Me)
-- ============================================================
local VALID_PETS = {
    "Unicorn", "Dragon", "Turtle", "Kangaroo", "Frost Dragon",
    "Shadow Dragon", "Giraffe", "Bat Dragon", "Owl", "Parrot",
    "Crow", "Evil Unicorn", "Arctic Reindeer", "Monkey King",
    "Queen Bee", "King Bee", "Golden Rat", "Albino Monkey",
    "King Monkey", "Ninja Monkey", "Frost Fury", "Snow Owl",
    "T-Rex", "Dodo", "Golden Unicorn", "Diamond Unicorn",
    "Lunar Ox", "Metal Ox", "Golden Ladybug", "Diamond Ladybug",
    "Peacock", "Octopus", "Shark", "Phoenix", "Goldhorn",
    "Dancing Dragon", "Hawk", "Chimera", "Baku", "Sugar Glider"
    -- Add more pets as needed
}

-- ============================================================
-- 2. Create a lookup table with lowercase keys for O(1) validation
-- ============================================================
local petLookup = {}
for _, name in ipairs(VALID_PETS) do
    petLookup[name:lower()] = name  -- store the original casing
end

-- ============================================================
-- 3. Helper function to convert a string to lowercase
-- ============================================================
local function toLower(str)
    if not str then return "" end
    return str:lower()
end

-- ============================================================
-- 4. Levenshtein distance function (case-sensitive, but we call it on lowercased strings)
-- ============================================================
local function levenshtein(s, t)
    local m, n = #s, #t
    if m == 0 then return n end
    if n == 0 then return m end

    local d = {}
    for i = 0, m do d[i] = { [0] = i } end
    for j = 0, n do d[0][j] = j end

    for i = 1, m do
        local si = s:sub(i, i)
        for j = 1, n do
            local tj = t:sub(j, j)
            local cost = (si == tj) and 0 or 1
            d[i][j] = math.min(
                d[i-1][j] + 1,
                d[i][j-1] + 1,
                d[i-1][j-1] + cost
            )
        end
    end
    return d[m][n]
end

-- ============================================================
-- 5. Function to suggest pet names close to the input
--    Returns a table of suggested names (original casing) with distance <= threshold
-- ============================================================
local function suggestPets(input, threshold)
    threshold = threshold or 2
    local suggestions = {}
    local inputLower = toLower(input)
    if inputLower == "" then return suggestions end

    for _, validName in ipairs(VALID_PETS) do
        local dist = levenshtein(inputLower, toLower(validName))
        if dist <= threshold then
            table.insert(suggestions, { name = validName, distance = dist })
        end
    end

    -- Sort by distance, then by alphabetical order
    table.sort(suggestions, function(a, b)
        if a.distance ~= b.distance then
            return a.distance < b.distance
        else
            return a.name < b.name
        end
    end)

    -- Extract just the names
    local result = {}
    for _, item in ipairs(suggestions) do
        table.insert(result, item.name)
    end
    return result
end

-- ============================================================
-- 6. Pet spawning function (placeholder for Adopt Me API)
--    In the actual environment, replace the comment with the real API call.
-- ============================================================
local function spawnPet(petName)
    -- ==========================================================
    -- !!! REPLACE THIS COMMENT WITH ACTUAL ADOPT ME API CALL !!!
    -- Example: AdoptMe.SpawnPet(petName)
    -- ==========================================================
    print("[API] Spawning pet: " .. petName)
    -- In a real environment, you would call something like:
    -- game:GetService("ReplicatedStorage"):WaitForChild("PetSpawn"):FireServer(petName)
    return true   -- assume success
end

-- ============================================================
-- 7. Main interaction loop
-- ============================================================
local function main()
    print("=== Adopt Me Pet Spawner ===")
    print("Enter the name of the pet you want to spawn.")
    print("Type 'exit' or 'quit' to cancel.\n")

    while true do
        -- ==========================================================
        -- !!! REPLACE THIS WITH ACTUAL INPUT METHOD !!!
        -- Example: local userInput = io.read()   (for console)
        -- In Adopt Me, this might be a TextBox or chat command.
        -- ==========================================================
        io.write("Pet name: ")
        local userInput = io.read()
        if not userInput then break end

        -- Trim whitespace
        userInput = userInput:gsub("^%s+", ""):gsub("%s+$", "")

        -- Allow user to cancel
        if userInput:lower() == "exit" or userInput:lower() == "quit" then
            print("Exiting pet spawner.")
            break
        end

        -- Handle empty input
        if userInput == "" then
            print("No pet name entered. Please try again.")
            goto continue
        end

        -- Check if input is valid (case-insensitive)
        local lowerInput = toLower(userInput)
        local validName = petLookup[lowerInput]
        if validName then
            -- Valid pet: spawn it and exit loop
            print("Spawning " .. validName .. " ...")
            spawnPet(validName)
            print("Pet spawned successfully!")
            break
        else
            -- Invalid input: provide feedback and suggestions
            print("'" .. userInput .. "' is not a valid pet name.")
            local suggestions = suggestPets(userInput, 2)
            if #suggestions > 0 then
                print("Did you mean one of these?")
                for i, name in ipairs(suggestions) do
                    print("  " .. i .. ". " .. name)
                end
            else
                print("No close matches found. Please check the spelling.")
            end
            print("Try again.\n")
        end

        ::continue::
    end
end

-- ============================================================
-- Run the main function if this script is executed directly
-- ============================================================
if pcall(function() return ... end) then
    -- If running as a module, do not automatically execute
else
    main()
end
