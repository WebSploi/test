-- Advanced High Value Brainrot Scanner for "Steal a Brainrot"
-- With Discord webhook notifications, improved GUI, and manual-style auto server hop

task.wait(math.random(2, 3)) -- Random delay to avoid detection

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local displaySettings = {
    showOwnPets = false,
    showOthersPets = true
}

local raritySettings = {
    ["Secret"] = {Enabled = true, Color = Color3.fromRGB(60, 60, 60), Priority = 8},
    ["Brainrot God"] = {Enabled = true, Color = Color3.fromRGB(0, 255, 255), Priority = 7},
    ["Mythic"] = {Enabled = false, Color = Color3.fromRGB(255, 0, 0), Priority = 5},
    ["Legendary"] = {Enabled = false, Color = Color3.fromRGB(255, 255, 0), Priority = 4},
    ["Epic"] = {Enabled = false, Color = Color3.fromRGB(128, 0, 128), Priority = 3},
    ["Rare"] = {Enabled = false, Color = Color3.fromRGB(0, 0, 255), Priority = 2},
    ["Common"] = {Enabled = false, Color = Color3.fromRGB(0, 255, 0), Priority = 1},
}

local specificBrainrots = {
    ["Los Tralaleritos"] = {Enabled = true},
    ["La Vacca Saturno Saturnita"] = {Enabled = true},
    ["Garama and Madundung"] = {Enabled = true},
    ["La Grande Combinasion"] = {Enabled = true},
    ["Graipuss Medussi"] = {Enabled = true},
    ["Chimpanzini Spiderini"] = {Enabled = true},
    ["Matteo"] = {Enabled = true},
    ["Pot Hotspot"] = {Enabled = true},
    ["Nuclearo Dinosauro"] = {Enabled = true},
    ["Lucky Block"] = {Enabled = true},
}

local autoHopEnabled = true


-- CONFIG SYSTEM (Based on working WindUI example)
local CONFIG_FOLDER = "JuunethPetFinder"
local CONFIG_FILE = "config.json"

-- Default configuration
local defaultConfig = {
    displaySettings = {
        showOwnPets = false,
        showOthersPets = true
    },
    raritySettings = {
        ["Secret"] = true,
        ["Brainrot God"] = true
    },
    specificBrainrots = {
        ["Los Tralaleritos"] = true,
        ["La Vacca Saturno Saturnita"] = true,
        ["Garama and Madundung"] = true,
        ["La Grande Combinasion"] = true,
        ["Graipuss Medussi"] = true,
        ["Chimpanzini Spiderini"] = true,
        ["Matteo"] = true,
        ["Pot Hotspot"] = true,
        ["Nuclearo Dinosauro"] = true,
        ["Lucky Block"] = true
    },
    autoHopEnabled = true
}

-- Initialize config folder
local function initConfigFolder()
    local success, error = pcall(function()
        if not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
    end)
    if not success then
        return false
    end
    return true
end

-- Load configuration
local function loadConfig()
    if not initConfigFolder() then
        return defaultConfig
    end
    
    local success, result = pcall(function()
        local configPath = CONFIG_FOLDER .. "/" .. CONFIG_FILE
        
        if not isfile(configPath) then
            return defaultConfig
        end
        
        local configData = readfile(configPath)
        if not configData or configData == "" then
            return defaultConfig
        end
        
        local config = HttpService:JSONDecode(configData)
        return config
    end)
    
    if success and result then
        return result
    else
        return defaultConfig
    end
end

-- Save configuration
local function saveConfig()
    if not initConfigFolder() then
        return false
    end
    
    local currentConfig = {
        displaySettings = {
            showOwnPets = displaySettings.showOwnPets,
            showOthersPets = displaySettings.showOthersPets
        },
        raritySettings = {
            ["Secret"] = raritySettings["Secret"].Enabled,
            ["Brainrot God"] = raritySettings["Brainrot God"].Enabled
        },
        specificBrainrots = {
            ["Los Tralaleritos"] = specificBrainrots["Los Tralaleritos"].Enabled,
            ["La Vacca Saturno Saturnita"] = specificBrainrots["La Vacca Saturno Saturnita"].Enabled,
            ["Garama and Madundung"] = specificBrainrots["Garama and Madundung"].Enabled,
            ["La Grande Combinasion"] = specificBrainrots["La Grande Combinasion"].Enabled,
            ["Graipuss Medussi"] = specificBrainrots["Graipuss Medussi"].Enabled,
            ["Chimpanzini Spiderini"] = specificBrainrots["Chimpanzini Spiderini"].Enabled,
            ["Matteo"] = specificBrainrots["Matteo"].Enabled,
            ["Pot Hotspot"] = specificBrainrots["Pot Hotspot"].Enabled,
            ["Nuclearo Dinosauro"] = specificBrainrots["Nuclearo Dinosauro"].Enabled,
            ["Lucky Block"] = specificBrainrots["Lucky Block"].Enabled
        },
        autoHopEnabled = autoHopEnabled
    }
    
    local success, error = pcall(function()
        local configPath = CONFIG_FOLDER .. "/" .. CONFIG_FILE
        local jsonData = HttpService:JSONEncode(currentConfig)
        writefile(configPath, jsonData)
    end)
    
    if not success then
        return false
    end
    return true
end

-- Apply configuration to settings
local function applyConfig(config)
    -- Debug: Print what we received
    
    -- Ensure config exists and has proper structure
    if not config or type(config) ~= "table" then
        config = defaultConfig
    end
    
    -- Apply display settings with extensive safety checks
    local displayConfig = config.displaySettings
    if displayConfig and type(displayConfig) == "table" then
        displaySettings.showOwnPets = displayConfig.showOwnPets == true
        displaySettings.showOthersPets = displayConfig.showOthersPets ~= false -- default true
    else
        displaySettings.showOwnPets = false
        displaySettings.showOthersPets = true
    end
    
    -- Apply rarity settings with extensive safety checks
    local rarityConfig = config.raritySettings
    if rarityConfig and type(rarityConfig) == "table" then
        raritySettings["Secret"].Enabled = rarityConfig["Secret"] ~= false -- default true
        raritySettings["Brainrot God"].Enabled = rarityConfig["Brainrot God"] ~= false -- default true
    else
        raritySettings["Secret"].Enabled = true
        raritySettings["Brainrot God"].Enabled = true
    end
    
    -- Apply specific brainrot settings with extensive safety checks
    local petsConfig = config.specificBrainrots
    if petsConfig and type(petsConfig) == "table" then
        for petName, petData in pairs(specificBrainrots) do
            if petsConfig[petName] ~= nil then
                petData.Enabled = petsConfig[petName] == true
            else
                petData.Enabled = true -- default enabled
            end
        end
    else
        for petName, petData in pairs(specificBrainrots) do
            petData.Enabled = true
        end
    end
    
    -- Apply auto hop setting with safety check
    if config.autoHopEnabled ~= nil then
        autoHopEnabled = config.autoHopEnabled == true
    else
        autoHopEnabled = true
    end
    
end

-- CONFIGURATION - EDIT THESE VALUES
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1388626823604207616/HEtHetLMpY_dJZ4jp78CWV6pOGl8u04olgw84OO95pTbttLTf4tq-1TG4xjSjQ_pIT0a"
local BRAINROT_GOD_WEBHOOK_URL = "https://discord.com/api/webhooks/1388626823604207616/HEtHetLMpY_dJZ4jp78CWV6pOGl8u04olgw84OO95pTbttLTf4tq-1TG4xjSjQ_pIT0a"
local HIGH_VALUE_WEBHOOK_URL = "https://discord.com/api/webhooks/1388626823604207616/HEtHetLMpY_dJZ4jp78CWV6pOGl8u04olgw84OO95pTbttLTf4tq-1TG4xjSjQ_pIT0a" -- 1M/s+ filter
local WEBHOOK_AVATAR_URL = "https://i.imgur.com/J8wYHfT.png"
local WEBHOOK_COOLDOWN = 3 -- Reduced from 5 to 3 seconds for faster detection
local lastWebhookTime = 0
local reportedPets = {} -- Track which pets we've already reported

-- Regional server endpoints
local REGIONAL_ENDPOINTS = {
    japan = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=jp",
    korea = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=kr",
    brazil = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=br",
    spain = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=es",
    eu = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=eu",
    netherlands = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=nl",
    ukraine = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=ua",
    vietnam = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=vn",
    usa = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=us",
    canada = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=ca",
    uk = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=gb",
    germany = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=de",
    france = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=fr",
    australia = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=au",
    singapore = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=sg",
    india = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=in",
    mexico = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=mx",
    turkey = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&region=tr"
}

-- Auto Server Hop Variables
local isHopping = false
local hopDelay = 1 -- Seconds to wait before hopping
local scanCompleted = false
local scanStartTime = 0
local SCAN_TIMEOUT = 2 -- Reduced from 4 to 2 seconds for faster hopping
local retryCount = 0
local blacklistedServers = {} -- Servers that have failed multiple times
local WEBHOOK_COOLDOWN = 3 -- Reduced from 5 to 3 seconds for faster detection

    ["Secret"] = {Enabled = true, Color = Color3.fromRGB(60, 60, 60), Priority = 8}, -- Readable dark gray instead of red
    ["Brainrot God"] = {Enabled = true, Color = Color3.fromRGB(0, 255, 255), Priority = 7},
    ["Mythic"] = {Enabled = false, Color = Color3.fromRGB(255, 0, 0), Priority = 5},
    ["Legendary"] = {Enabled = false, Color = Color3.fromRGB(255, 255, 0), Priority = 4},
    ["Epic"] = {Enabled = false, Color = Color3.fromRGB(128, 0, 128), Priority = 3},
    ["Rare"] = {Enabled = false, Color = Color3.fromRGB(0, 0, 255), Priority = 2},
    ["Common"] = {Enabled = false, Color = Color3.fromRGB(0, 255, 0), Priority = 1},
}

    ["Los Tralaleritos"] = {Enabled = true},
    ["La Vacca Saturno Saturnita"] = {Enabled = true},
    ["Garama and Madundung"] = {Enabled = true},
    ["La Grande Combinasion"] = {Enabled = true},
    ["Graipuss Medussi"] = {Enabled = true},
    ["Chimpanzini Spiderini"] = {Enabled = true},
    ["Matteo"] = {Enabled = true},
    ["Pot Hotspot"] = {Enabled = true},
    ["Nuclearo Dinosauro"] = {Enabled = true},
    ["Lucky Block"] = {Enabled = true},
}

    showOwnPets = false,
    showOthersPets = true
}

-- Storage for found items and tracking
local foundHighValueItems = {}
local scanConnection = nil
local updateConnection = nil
local lastPlayerList = {}
local guiVisible = true
local dropdownOpen = false
local lastPlayerCheck = 0

-- Add a reference to the GUI scrollframe for updates
local guiScrollFrame = nil

-- Helper function to parse k/s value for sorting
local function parseKsValue(ksString)
    if not ksString or ksString == "Unknown" then
        return 0
    end
    
    -- Extract number and unit from string like "$1.5M/s" or "$500K/s"
    local number, unit = string.match(ksString, "%$([%d%.]+)([KMB]?)")
    if not number then
        return 0
    end
    
    local value = tonumber(number) or 0
    
    -- Convert to base value for comparison
    if unit == "M" then
        value = value * 1000000
    elseif unit == "K" then
        value = value * 1000
    elseif unit == "B" then
        value = value * 1000000000
    end
    
    return value
end

-- Blacklist a problematic server
local function blacklistServer(serverId, reason)
    blacklistedServers[serverId] = {
        reason = reason,
        timestamp = tick()
    }
    
    -- Clean up old blacklisted servers (older than 10 minutes)
    for id, data in pairs(blacklistedServers) do
        if tick() - data.timestamp > 600 then
            blacklistedServers[id] = nil
        end
    end
end

-- Create the auto hop toggle button
local function createAutoHopToggle()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("AutoHopGui") or Instance.new("ScreenGui")
    screenGui.Name = "AutoHopGui"
    screenGui.Parent = playerGui
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "AutoHopToggle"
    toggleButton.Size = UDim2.new(0, 200, 0, 50)
    toggleButton.Position = UDim2.new(0.5, -100, 0, 110) -- Positioned below the main scanner GUI
    toggleButton.Text = "🔄 Auto Hop: ON"
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 18
    toggleButton.Parent = screenGui
    
    -- Toggle logic
    toggleButton.MouseButton1Click:Connect(function()
        autoHopEnabled = not autoHopEnabled
        toggleButton.Text = autoHopEnabled and "🔄 Auto Hop: ON" or "🔄 Auto Hop: OFF"
        toggleButton.BackgroundColor3 = autoHopEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        if autoHopEnabled then
        else
        end
        saveConfig() -- Auto-save on change
    end)
    
    return toggleButton
end

-- Discord webhook notification function
local function sendDiscordWebhook(petsArray, webhookUrl)
    local HttpService = game:GetService("HttpService")
    
    -- Explorer is the person running the script (the server hopper)
    local explorerName = LocalPlayer.Name or "Unknown Explorer"
    
    -- Check if any ultra-rare pets are found for special notifications
    local hasUltraRarePets = false
    for _, pet in ipairs(petsArray) do
        if pet.name == "Garama and Madundung" or pet.name == "La Grande Combinasion" then
            hasUltraRarePets = true
            break
        end
    end
    
    -- Set embed color based on webhook type and rarity
    local embedColor
    if webhookUrl == HIGH_VALUE_WEBHOOK_URL then
        -- High-value webhook: Green for Brainrot God, Black for Secret
        local isSecret = false
        for _, pet in ipairs(petsArray) do
            if string.lower(pet.rarity or "") == "secret" then
                isSecret = true
                break
            end
        end
        embedColor = isSecret and 0 or 65280 -- Black (0) for Secret, Green (65280) for Brainrot God
    else
        -- Other webhooks: Use original color logic
        embedColor = hasUltraRarePets and 16711680 or math.random(0, 16777215) -- 16711680 = bright red
    end
    
    -- Count duplicates by name+variant+ksValue
    local petCounts = {}
    for _, pet in ipairs(petsArray) do
        local petKey = pet.name .. "_" .. (pet.variant or "Normal") .. "_" .. (pet.ksValue or "Unknown")
        petCounts[petKey] = (petCounts[petKey] or 0) + 1
    end
    
    -- Build formatted and sorted pet list
    local petDisplay = {}
    local added = {}
    
    -- Sort pets: by k/s value (highest to lowest), then by rarity
    table.sort(petsArray, function(a, b)
        local aKs = parseKsValue(a.ksValue)
        local bKs = parseKsValue(b.ksValue)
        if aKs == bKs then
            -- If same k/s, sort by rarity rank
            local function rarityRank(pet)
                local r = string.lower(pet.rarity or "")
                if r == "secret" then return 1
                elseif r == "brainrot god" then return 2
                else return 3 end
            end
            return rarityRank(a) < rarityRank(b)
        else
            return aKs > bKs -- Sort by k/s value (highest first)
        end
    end)
    
    for _, pet in ipairs(petsArray) do
        local petKey = pet.name .. "_" .. (pet.variant or "Normal") .. "_" .. (pet.ksValue or "Unknown")
        if not added[petKey] then
            local count = petCounts[petKey]
            
            -- Determine emoji based on rarity and specific pet names
            local emoji = ""
            local rarity = string.lower(pet.rarity or "")
            
            -- Custom emojis for specific pets
            if pet.name == "Garama and Madundung" then
                emoji = "🔥 "
            elseif pet.name == "La Grande Combinasion" then
                emoji = "⭐ "
            elseif rarity == "brainrot god" then
                emoji = "🔥 "
            elseif rarity == "secret" then
                emoji = "💎 "
            end
            
            -- Format name with variant and k/s information - reordered format
            local countText = count > 1 and "(" .. count .. "x) " or ""
            local variantText = pet.variant and pet.variant ~= "Normal" and "[" .. pet.variant .. "] " or ""
            local ksText = pet.ksValue and pet.ksValue ~= "Unknown" and " (" .. pet.ksValue .. ")" or ""
            
            -- Add owner info to the display
            local ownerInfo = pet.owner and pet.owner ~= "" and pet.owner or "Unknown Owner"
            
            -- Average distance for this specific pet variant/ks combination
            local totalDist, entries = 0, 0
            for _, p in ipairs(petsArray) do
                local pKey = p.name .. "_" .. (p.variant or "Normal") .. "_" .. (p.ksValue or "Unknown")
                if pKey == petKey then
                    totalDist += p.distance
                    entries += 1
                end
            end
            local avgDist = totalDist / entries
            
            -- Add formatted line with owner and ensure proper line breaks
            table.insert(petDisplay, string.format("%s__%s%s%s__ %s → **%.1f studs**", emoji, countText, variantText, pet.name, ksText, avgDist))
            table.insert(petDisplay, string.format("Owner: %s", ownerInfo))
            table.insert(petDisplay, "") -- Add spacing between entries
            
            added[petKey] = true
        end
    end
    
    -- Create the embed
    local embed = {
        title = string.format("🔍 **PET DETECTED** (%d Found)", #petsArray),
        color = embedColor,
        fields = {
            {
                name = "**DETECTED PETS**",
                value = table.concat(petDisplay, "\n"),
                inline = false
            },
            {
                name = "**Explorer**",
                value = explorerName,
                inline = false
            },
            {
                name = "🆔 Job ID (PC)",
                value = game.JobId,
                inline = true
            },
            {
                name = "🆔 Job ID (Mobile)",
                value = string.format("`%s`", game.JobId),
                inline = true
            },
            {
                name = "📊 Players Online",
                value = string.format("```%d/%d```", #game.Players:GetPlayers(), game.Players.MaxPlayers),
                inline = true
            },
            {
                name = "🔗 Quick Join",
                value = string.format("```roblox://experiences/start?placeId=%s&gameInstanceId=%s```", game.PlaceId, game.JobId),
                inline = false
            },
            {
                name = "📋 Join Script",
                value = string.format("`game:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\", game.Players.LocalPlayer)`", game.PlaceId, game.JobId),
                inline = false
            }
        },
        footer = {
            text = "100% FREE Logs ❤️"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    
    -- Create the payload with @here mention for ultra-rare pets
    local payload = {
        content = hasUltraRarePets and "@here" or nil,
        embeds = {embed},
        username = "Pet Scanner",
        avatar_url = WEBHOOK_AVATAR_URL
    }
    
    -- Send the webhook
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(payload)
        local request = (syn and syn.request) or http_request or request
        if request then
            request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        end
    end)
    
    if not success then
    end
end

-- Make GUI draggable
local function makeDraggableFromAnywhere(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Get brainrot info from podium (enhanced to detect variants and k/s)
local function getOverheadAndRarity(podium)
    local attach = podium:FindFirstChild("Base", true)
    if attach then
        local spawn = attach:FindFirstChild("Spawn", true)
        if spawn then
            local attachment = spawn:FindFirstChild("Attachment", true)
            if attachment then
                local overhead = attachment:FindFirstChild("AnimalOverhead", true)
                if overhead then
                    local displayName = overhead:FindFirstChild("DisplayName")
                    local rarity = overhead:FindFirstChild("Rarity")
                    
                    -- Try to find variant information
                    local variant = "Normal" -- Default variant
                    local ksValue = "Unknown" -- Default k/s value
                    
                    -- Look for Generation TextLabel to get k/s value
                    local generation = overhead:FindFirstChild("Generation")
                    if generation and generation:IsA("TextLabel") and generation.Text ~= "" then
                        ksValue = generation.Text
                    end
                    
                    -- Look for Mutation TextLabel that belongs to THIS specific pet
                    local mutation = overhead:FindFirstChild("Mutation")
                    if mutation and mutation:IsA("TextLabel") and mutation.Visible then
                        local mutationText = mutation.Text
                        -- Only consider it a variant if it's actually a variant keyword and not empty
                        if mutationText and mutationText ~= "" then
                            local lowerText = string.lower(mutationText)
                            -- Check if the mutation text matches THIS pet's display area
                            if string.find(lowerText, "gold") or string.find(lowerText, "diamond") or
                               string.find(lowerText, "candy") or string.find(lowerText, "rainbow") then
                                -- Additional check: see if this mutation is actually visible on screen
                                -- by checking if the mutation label is close to the display name
                                if mutation.AbsolutePosition and displayName.AbsolutePosition then
                                    local distance = (mutation.AbsolutePosition - displayName.AbsolutePosition).Magnitude
                                    if distance < 200 then -- Only if mutation is close to pet name
                                        variant = mutationText
                                    end
                                else
                                    variant = mutationText -- Fallback if position check fails
                                end
                            end
                        end
                    end
                    
                    -- Alternative: Look in UiListLayout for multiple children to determine variants
                    local uiList = overhead:FindFirstChild("UiListLayout")
                    if variant == "Normal" and uiList then
                        -- If there are multiple text elements in the list, check for variants
                        local textLabels = {}
                        for _, child in ipairs(overhead:GetChildren()) do
                            if child:IsA("TextLabel") and child.Visible and child ~= displayName and child ~= rarity and child ~= generation then
                                table.insert(textLabels, child)
                            end
                        end
                        
                        -- If we have additional text labels, check them for variants
                        for _, label in ipairs(textLabels) do
                            local text = label.Text
                            if text and text ~= "" then
                                local lowerText = string.lower(text)
                                if string.find(lowerText, "gold") or string.find(lowerText, "diamond") or
                                   string.find(lowerText, "candy") or string.find(lowerText, "rainbow") then
                                    variant = text
                                    break
                                end
                            end
                        end
                    end
                    
                    if displayName and rarity then
                        return displayName, rarity.Text, variant, ksValue
                    end
                end
            end
        end
    end
    return nil, nil, "Normal", "Unknown"
end

-- Get plot owner
local function getPlotOwner(plot)
    if not plot then return nil end
    
    local s = plot:FindFirstChild("PlotSign")
    local sg = s and s:FindFirstChild("SurfaceGui")
    local f = sg and sg:FindFirstChild("Frame")
    local lbl = f and f:FindFirstChild("TextLabel")
    local txt = lbl and lbl.Text
    
    if not txt or txt:find("Empty Base") then
        return nil
    end
    
    return txt:match("^(.-)'s Base$") or nil
end

-- Clear and refresh the UI
local function clearAndRefreshUI()
    if guiScrollFrame then
        -- Clear all existing items
        for _, child in ipairs(guiScrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Reset the canvas size
        local listLayout = guiScrollFrame:FindFirstChild("UIListLayout")
        if listLayout then
            guiScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        end
    end
    
    -- Clear found items and reported pets
    foundHighValueItems = {}
    reportedPets = {}
end

-- Create GUI for notifications
local function createNotificationGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrainrotScanner"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "ScannerFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(1, -360, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.8, 0, 0, 25) -- Reduced height from 30 to 25
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.Text = "Pet Finder"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 4) -- Reduced corner radius from 8 to 4
    titleCorner.Parent = title
    
    -- Settings button (Windows 10 style)
    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(0, 35, 0, 25) -- Much smaller: 35x25 instead of percentage
    settingsButton.Position = UDim2.new(1, -70, 0, 0) -- Positioned from right edge
    settingsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Darker, more subtle
    settingsButton.Text = "⚙"
    settingsButton.TextColor3 = Color3.fromRGB(200, 200, 200) -- Softer white
    settingsButton.TextSize = 14 -- Fixed text size instead of scaled
    settingsButton.Font = Enum.Font.Gotham
    settingsButton.BorderSizePixel = 0
    settingsButton.Parent = mainFrame
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 2) -- Much smaller corner radius
    settingsCorner.Parent = settingsButton
    
    -- Exit button (Windows 10 style)
    local exitButton = Instance.new("TextButton")
    exitButton.Name = "ExitButton"
    exitButton.Size = UDim2.new(0, 35, 0, 25) -- Much smaller: 35x25 instead of percentage
    exitButton.Position = UDim2.new(1, -35, 0, 0) -- Positioned from right edge
    exitButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Same as settings button
    exitButton.Text = "×" -- Using multiplication symbol for cleaner look
    exitButton.TextColor3 = Color3.fromRGB(200, 200, 200) -- Softer white
    exitButton.TextSize = 16 -- Slightly larger for the X
    exitButton.Font = Enum.Font.Gotham
    exitButton.BorderSizePixel = 0
    exitButton.Parent = mainFrame
    
    local exitCorner = Instance.new("UICorner")
    exitCorner.CornerRadius = UDim.new(0, 2) -- Much smaller corner radius
    exitCorner.Parent = exitButton
    
    -- Hover effects for Windows 10 feel
    settingsButton.MouseEnter:Connect(function()
        settingsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    settingsButton.MouseLeave:Connect(function()
        settingsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    
    exitButton.MouseEnter:Connect(function()
        exitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red hover like Windows
        exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    exitButton.MouseLeave:Connect(function()
        exitButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        exitButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    exitButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        guiVisible = false
    end)
    
    -- Main content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -10, 1, -35) -- Adjusted for new title bar height
    contentFrame.Position = UDim2.new(0, 5, 0, 30) -- Adjusted for new title bar height
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ItemsList"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.Parent = contentFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scrollFrame
    
    -- Store reference to scrollFrame
    guiScrollFrame = scrollFrame
    
    -- Settings screen frame
    local settingsScroll = Instance.new("ScrollingFrame")
    settingsScroll.Name = "SettingsScroll"
    settingsScroll.Size = UDim2.new(1, -10, 1, -35) -- Adjusted for new title bar height
    settingsScroll.Position = UDim2.new(0, 5, 0, 30) -- Adjusted for new title bar height
    settingsScroll.BackgroundTransparency = 1
    settingsScroll.Visible = false
    settingsScroll.ScrollBarThickness = 5
    settingsScroll.Parent = mainFrame
    
    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    settingsLayout.Padding = UDim.new(0, 5)
    settingsLayout.Parent = settingsScroll
    
    -- Create settings content
    local function createSettingsContent()
        for _, child in ipairs(settingsScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        
        local displayLabel = Instance.new("TextLabel")
        displayLabel.Size = UDim2.new(1, 0, 0, 25)
        displayLabel.BackgroundTransparency = 1
        displayLabel.Text = "Display Settings:"
        displayLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        displayLabel.TextScaled = true
        displayLabel.Font = Enum.Font.GothamBold
        displayLabel.TextXAlignment = Enum.TextXAlignment.Left
        displayLabel.LayoutOrder = 1
        displayLabel.Parent = settingsScroll
        
        -- Own pets toggle
        local ownPetsToggle = Instance.new("TextButton")
        ownPetsToggle.Size = UDim2.new(1, 0, 0, 25)
        ownPetsToggle.BackgroundColor3 = displaySettings.showOwnPets and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        ownPetsToggle.Text = "Show Own Pets: " .. (displaySettings.showOwnPets and "ON" or "OFF")
        ownPetsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        ownPetsToggle.TextScaled = true
        ownPetsToggle.Font = Enum.Font.Gotham
        ownPetsToggle.LayoutOrder = 2
        ownPetsToggle.Parent = settingsScroll
        
        -- Others pets toggle
        local othersPetsToggle = Instance.new("TextButton")
        othersPetsToggle.Size = UDim2.new(1, 0, 0, 25)
        othersPetsToggle.BackgroundColor3 = displaySettings.showOthersPets and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        othersPetsToggle.Text = "Show Others' Pets: " .. (displaySettings.showOthersPets and "ON" or "OFF")
        othersPetsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        othersPetsToggle.TextScaled = true
        othersPetsToggle.Font = Enum.Font.Gotham
        othersPetsToggle.LayoutOrder = 3
        othersPetsToggle.Parent = settingsScroll
        
        -- Spacer
        local spacer1 = Instance.new("Frame")
        spacer1.Size = UDim2.new(1, 0, 0, 10)
        spacer1.BackgroundTransparency = 1
        spacer1.LayoutOrder = 4
        spacer1.Parent = settingsScroll
        
        -- Specific brainrots section - Dropdown style
        local brainrotLabel = Instance.new("TextLabel")
        brainrotLabel.Size = UDim2.new(1, 0, 0, 25)
        brainrotLabel.BackgroundTransparency = 1
        brainrotLabel.Text = "Specific Pets:"
        brainrotLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        brainrotLabel.TextScaled = true
        brainrotLabel.Font = Enum.Font.GothamBold
        brainrotLabel.TextXAlignment = Enum.TextXAlignment.Left
        brainrotLabel.LayoutOrder = 5
        brainrotLabel.Parent = settingsScroll
        
        -- Dropdown toggle button
        local dropdownToggle = Instance.new("TextButton")
        dropdownToggle.Size = UDim2.new(1, 0, 0, 25)
        dropdownToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        dropdownToggle.Text = "▼ Show/Hide Specific Pets"
        dropdownToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownToggle.TextScaled = true
        dropdownToggle.Font = Enum.Font.Gotham
        dropdownToggle.LayoutOrder = 6
        dropdownToggle.Parent = settingsScroll
        
        local petsVisible = false
        local petToggles = {}
        
        -- Create toggles for specific brainrots (initially hidden)
        for name, data in pairs(specificBrainrots) do
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(1, 0, 0, 25)
            toggle.BackgroundColor3 = data.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
            toggle.Text = name .. ": " .. (data.Enabled and "ON" or "OFF")
            toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggle.TextScaled = true
            toggle.Font = Enum.Font.Gotham
            toggle.LayoutOrder = 7 + #petToggles
            toggle.Visible = false -- Initially hidden
            toggle.Parent = settingsScroll
            
            table.insert(petToggles, toggle)
            
            toggle.MouseButton1Click:Connect(function()
                if specificBrainrots[name] then
                    specificBrainrots[name].Enabled = not specificBrainrots[name].Enabled
                    toggle.BackgroundColor3 = specificBrainrots[name].Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
                    toggle.Text = name .. ": " .. (specificBrainrots[name].Enabled and "ON" or "OFF")
                    clearAndRefreshUI()
                    scanForHighValueBrainrots()
                    saveConfig() -- Auto-save on change
                end
            end)
        end
        
        -- Dropdown toggle functionality
        dropdownToggle.MouseButton1Click:Connect(function()
            petsVisible = not petsVisible
            dropdownToggle.Text = (petsVisible and "▲" or "▼") .. " Show/Hide Specific Pets"
            
            for _, toggle in ipairs(petToggles) do
                toggle.Visible = petsVisible
            end
            
            -- Update scroll frame size
            settingsScroll.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y)
        end)
        
        -- Spacer
        local spacer2 = Instance.new("Frame")
        spacer2.Size = UDim2.new(1, 0, 0, 10)
        spacer2.BackgroundTransparency = 1
        spacer2.LayoutOrder = 100
        spacer2.Parent = settingsScroll
        
        -- Rarity section
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(1, 0, 0, 25)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = "Rarity Filters:"
        rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        rarityLabel.TextScaled = true
        rarityLabel.Font = Enum.Font.GothamBold
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
        rarityLabel.LayoutOrder = 101
        rarityLabel.Parent = settingsScroll
        
        -- Create toggles for rarities (only keep enabled ones)
        local rarityOrder = {"Secret", "Brainrot God"}
        for i, rarityName in ipairs(rarityOrder) do
            local data = raritySettings[rarityName]
            if data then
                local toggle = Instance.new("TextButton")
                toggle.Size = UDim2.new(1, 0, 0, 25)
                toggle.BackgroundColor3 = data.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
                toggle.Text = rarityName .. ": " .. (data.Enabled and "ON" or "OFF")
                toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggle.TextScaled = true
                toggle.Font = Enum.Font.Gotham
                toggle.LayoutOrder = 102 + i
                toggle.Parent = settingsScroll
                
                toggle.MouseButton1Click:Connect(function()
                    raritySettings[rarityName].Enabled = not raritySettings[rarityName].Enabled
                    createSettingsContent()
                    clearAndRefreshUI()
                    scanForHighValueBrainrots()
                    saveConfig() -- Auto-save on change
                end)
            end
        end
        
        -- Spacer
        local spacer3 = Instance.new("Frame")
        spacer3.Size = UDim2.new(1, 0, 0, 10)
        spacer3.BackgroundTransparency = 1
        spacer3.LayoutOrder = 200
        spacer3.Parent = settingsScroll
        
        -- Server hopper section
        local hopLabel = Instance.new("TextLabel")
        hopLabel.Size = UDim2.new(1, 0, 0, 25)
        hopLabel.BackgroundTransparency = 1
        hopLabel.Text = "Server Tools:"
        hopLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        hopLabel.TextScaled = true
        hopLabel.Font = Enum.Font.GothamBold
        hopLabel.TextXAlignment = Enum.TextXAlignment.Left
        hopLabel.LayoutOrder = 201
        hopLabel.Parent = settingsScroll
        
        -- Server hop button
        local hopButton = Instance.new("TextButton")
        hopButton.Size = UDim2.new(1, 0, 0, 25)
        hopButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        hopButton.Text = "🚀 Force Manual Hop"
        hopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        hopButton.TextScaled = true
        hopButton.Font = Enum.Font.Gotham
        hopButton.LayoutOrder = 202
        hopButton.Parent = settingsScroll
        
        hopButton.MouseButton1Click:Connect(function()
            -- Force manual hop - skip regional entirely
            if isHopping then
                return
            end
            
            isHopping = true
            
            local success, err = pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            
            if success then
            else
                isHopping = false
            end
        end)
        
        -- Webhook settings (smaller but keep original text)
        local webhookLabel = Instance.new("TextLabel")
        webhookLabel.Size = UDim2.new(1, 0, 0, 20) -- Reduced height from 25 to 20
        webhookLabel.BackgroundTransparency = 1
        webhookLabel.Text = "Webhook Status: "..(DISCORD_WEBHOOK_URL ~= "" and "ENABLED" or "DISABLED") -- Back to original text
        webhookLabel.TextColor3 = DISCORD_WEBHOOK_URL ~= "" and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        webhookLabel.TextSize = 12 -- Fixed smaller text size
        webhookLabel.Font = Enum.Font.Gotham
        webhookLabel.TextXAlignment = Enum.TextXAlignment.Left
        webhookLabel.LayoutOrder = 203
        webhookLabel.Parent = settingsScroll
        
        -- Hybrid hopper info (shortened)
        local hybridLabel = Instance.new("TextLabel")
        hybridLabel.Size = UDim2.new(1, 0, 0, 20) -- Reduced height from 25 to 20
        hybridLabel.BackgroundTransparency = 1
        hybridLabel.Text = "Hybrid Hopper" -- Removed extra text
        hybridLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        hybridLabel.TextSize = 12 -- Fixed smaller text size
        hybridLabel.Font = Enum.Font.Gotham
        hybridLabel.TextXAlignment = Enum.TextXAlignment.Left
        hybridLabel.LayoutOrder = 204
        hybridLabel.Parent = settingsScroll
        
        -- Event handlers
        ownPetsToggle.MouseButton1Click:Connect(function()
            displaySettings.showOwnPets = not displaySettings.showOwnPets
            createSettingsContent()
            clearAndRefreshUI()
            scanForHighValueBrainrots()
            saveConfig() -- Auto-save on change
        end)
        
        othersPetsToggle.MouseButton1Click:Connect(function()
            displaySettings.showOthersPets = not displaySettings.showOthersPets
            createSettingsContent()
            clearAndRefreshUI()
            scanForHighValueBrainrots()
            saveConfig() -- Auto-save on change
        end)
        
        -- Update scroll frame size
        settingsScroll.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y)
    end
    
    -- Settings button click handler
    settingsButton.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        contentFrame.Visible = not dropdownOpen
        settingsScroll.Visible = dropdownOpen
        if dropdownOpen then
            createSettingsContent()
        end
    end)
    
    makeDraggableFromAnywhere(mainFrame)
    return screenGui, scrollFrame
end

-- Create item entry in GUI
local function createItemEntry(parent, brainrotName, rarity, plotOwner, distance, count, variant, ksValue)
    local rarityData = raritySettings[rarity]
    if not rarityData then return end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40) -- Reduced from 60 to 40 for more compact look
    frame.BackgroundColor3 = rarityData.Color
    frame.BackgroundTransparency = 0.8
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    -- Custom emoji for specific pets
    local emoji = "💎"
    if brainrotName == "Garama and Madundung" then
        emoji = "🔥"
    elseif brainrotName == "La Grande Combinasion" then
        emoji = "⭐"
    end
    
    -- Format with count and variant at the front like Discord
    local countText = count > 1 and "(" .. count .. "x) " or ""
    local variantText = variant and variant ~= "Normal" and "[" .. variant .. "] " or ""
    local ksText = ksValue and ksValue ~= "Unknown" and " (" .. ksValue .. ")" or ""
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 20)
    nameLabel.Position = UDim2.new(0, 5, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = string.format("%s %s%s%s%s", emoji, countText, variantText, brainrotName, ksText)
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -10, 0, 20) -- Increased height to fill remaining space
    infoLabel.Position = UDim2.new(0, 5, 0, 20)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = string.format("Owner: %s | Distance: %.1f studs", plotOwner, distance or 0)
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = frame
    
    -- Removed the rarity/priority label completely
    
    return frame
end

-- Declare scanForHighValueBrainrots before using it
local scanForHighValueBrainrots

-- Main scanning function
scanForHighValueBrainrots = function()
    -- Only check every few seconds for webhook
    local shouldCheckWebhook = tick() - lastWebhookTime >= WEBHOOK_COOLDOWN
    
    local newFoundItems = {}
    local currentPets = {}
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    -- Collect all pets first
    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        local plotOwner = getPlotOwner(plot)
        
        -- Check if we should scan this plot based on display settings
        local isOwnPlot = plotOwner == LocalPlayer.Name or plotOwner == LocalPlayer.DisplayName
        local shouldScanPlot = false
        
        if isOwnPlot and displaySettings.showOwnPets then
            shouldScanPlot = true
        elseif not isOwnPlot and displaySettings.showOthersPets then
            shouldScanPlot = true
        end
        
        if shouldScanPlot then
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, podium in ipairs(podiums:GetChildren()) do
                    local displayName, rarity, variant, ksValue = getOverheadAndRarity(podium)
                    if displayName and rarity then
                        local brainrotName = displayName.Text
                        local isSpecificBrainrot = specificBrainrots[brainrotName]
                        local rarityEnabled = raritySettings[rarity] and raritySettings[rarity].Enabled
                        local shouldScan = rarityEnabled or (isSpecificBrainrot and isSpecificBrainrot.Enabled)
                        
                        if shouldScan then
                            local part = nil
                            -- Try multiple methods to find the correct part for distance calculation
                            if podium.PrimaryPart then
                                part = podium.PrimaryPart
                            else
                                -- Try to find the base/spawn part more specifically
                                local base = podium:FindFirstChild("Base", true)
                                if base then
                                    local spawn = base:FindFirstChild("Spawn", true)
                                    if spawn then
                                        part = spawn
                                    else
                                        part = base
                                    end
                                else
                                    -- Fallback to any BasePart
                                    part = podium:FindFirstChildWhichIsA("BasePart")
                                end
                            end
                            
                            local distance = 0
                            -- Fixed distance calculation with better error handling
                            if part and humanoidRootPart then
                                local success, result = pcall(function()
                                    return (humanoidRootPart.Position - part.Position).Magnitude
                                end)
                                if success then
                                    distance = result
                                else
                                    distance = 999999 -- Set to very high number if calculation fails
                                end
                            else
                                distance = 999999 -- Set to very high number if parts not found
                            end
                            
                            local itemKey = displayName.Text .. "_" .. plotOwner .. "_" .. rarity .. "_" .. variant .. "_" .. ksValue
                            local petKey = plotOwner .. "_" .. displayName.Text .. "_" .. rarity .. "_" .. variant .. "_" .. ksValue
                            
                            if newFoundItems[itemKey] then
                                newFoundItems[itemKey].count = newFoundItems[itemKey].count + 1
                                if distance < newFoundItems[itemKey].distance then
                                    newFoundItems[itemKey].distance = distance
                                end
                            else
                                newFoundItems[itemKey] = {
                                    name = displayName.Text,
                                    rarity = rarity,
                                    variant = variant,
                                    ksValue = ksValue,
                                    owner = plotOwner,
                                    distance = distance,
                                    priority = raritySettings[rarity] and raritySettings[rarity].Priority or 0,
                                    count = 1
                                }
                                
                                -- Add to currentPets for webhook checking
                                if shouldCheckWebhook then
                                    currentPets[petKey] = {
                                        name = displayName.Text,
                                        rarity = rarity,
                                        variant = variant,
                                        ksValue = ksValue,
                                        owner = plotOwner,
                                        distance = distance,
                                        count = 1
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Check for new pets and send webhook if needed
    if shouldCheckWebhook then
        local newPets = {}
        for key, pet in pairs(currentPets) do
            if not reportedPets[key] then
                table.insert(newPets, pet)
                reportedPets[key] = true -- Mark as reported immediately
            end
        end
        
        -- Send webhook if new pets found
        if #newPets > 0 then
            -- Group pets by owner first
            local petsByOwner = {}
            for _, pet in ipairs(newPets) do
                local owner = pet.owner or "Unknown"
                if not petsByOwner[owner] then
                    petsByOwner[owner] = {}
                end
                table.insert(petsByOwner[owner], pet)
            end
            
            -- Separate pets by rarity for different webhooks
            local secretPets = {}
            local brainrotGodPets = {}
            local highValuePets = {} -- 1M/s+ filter
            
            for owner, ownerPets in pairs(petsByOwner) do
                -- Check if this owner has ANY 1M/s+ secret pet
                local hasHighValueSecret = false
                for _, pet in ipairs(ownerPets) do
                    local rarity = string.lower(pet.rarity or "")
                    local ksValue = parseKsValue(pet.ksValue)
                    if rarity == "secret" and ksValue >= 1000000 then
                        hasHighValueSecret = true
                        break
                    end
                end
                
                -- Process each pet based on owner's qualification
                for _, pet in ipairs(ownerPets) do
                    local rarity = string.lower(pet.rarity or "")
                    local ksValue = parseKsValue(pet.ksValue)
                    
                    if rarity == "secret" then
                        if hasHighValueSecret then
                            -- Owner has 1M/s+ secret, so ALL their secrets go to high-value webhook
                            table.insert(highValuePets, pet)
                        else
                            -- Owner has no 1M/s+ secrets, so secrets go to main webhook
                            table.insert(secretPets, pet)
                        end
                    elseif rarity == "brainrot god" then
                        -- Block specific spam pets by name
                        if pet.name ~= "Girafa Celestre" and pet.name ~= "Cocofanto Elefanto" then
                            table.insert(brainrotGodPets, pet)
                            
                            -- High value brainrot gods (1M/s+) ALSO go to high-value webhook
                            if ksValue >= 1000000 then
                                table.insert(highValuePets, pet)
                            end
                        end
                    end
                end
            end
            
            -- Send to appropriate webhooks
            if #secretPets > 0 then
                sendDiscordWebhook(secretPets, DISCORD_WEBHOOK_URL)
            end
            if #brainrotGodPets > 0 then
                sendDiscordWebhook(brainrotGodPets, BRAINROT_GOD_WEBHOOK_URL)
            end
            if #highValuePets > 0 then
                sendDiscordWebhook(highValuePets, HIGH_VALUE_WEBHOOK_URL)
            end
            
            lastWebhookTime = tick()
            scanCompleted = true
            
            -- Auto-hop if enabled and pets were found
            if autoHopEnabled then
                task.wait(hopDelay)
                _G.hopServer()
            end
        else
            -- No new pets found, mark scan as starting if not already started
            if scanStartTime == 0 then
                scanStartTime = tick()
            end
            
            -- Check if scan timeout reached (no pets found for X seconds)
            if autoHopEnabled and tick() - scanStartTime >= SCAN_TIMEOUT then
                scanStartTime = 0
                scanCompleted = false
                task.wait(hopDelay)
                _G.hopServer()
            end
        end
    end
    
    foundHighValueItems = newFoundItems
end

-- Update GUI
local function updateGUI(scrollFrame)
    -- Don't clear if we're in settings
    if dropdownOpen then return end
    
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local sortedItems = {}
    for _, item in pairs(foundHighValueItems) do
        table.insert(sortedItems, item)
    end
    
    -- Sort by k/s value (highest to lowest), then by priority
    table.sort(sortedItems, function(a, b)
        local aKs = parseKsValue(a.ksValue)
        local bKs = parseKsValue(b.ksValue)
        if aKs == bKs then
            return a.priority > b.priority -- If same k/s, sort by priority
        else
            return aKs > bKs -- Sort by k/s value (highest first)
        end
    end)
    
    for _, item in ipairs(sortedItems) do
        createItemEntry(scrollFrame, item.name, item.rarity, item.owner, item.distance, item.count, item.variant, item.ksValue)
    end
    
    local listLayout = scrollFrame:FindFirstChild("UIListLayout")
    if listLayout then
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end
end

-- Check for player changes
local function checkPlayerChanges()
    local currentPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        currentPlayers[player.UserId] = player.Name
    end
    
    -- Check for new players joining
    for userId, name in pairs(currentPlayers) do
        if not lastPlayerList[userId] then
            -- Don't clear all reported pets, just allow new scanning
        end
    end
    
    -- Check for players leaving
    for userId, name in pairs(lastPlayerList) do
        if not currentPlayers[userId] then
            -- Only remove reported pets that belonged to this specific player
            for petKey, _ in pairs(reportedPets) do
                if string.find(petKey, name .. "_") then -- petKey format: "owner_name_rarity_variant_ks"
                    reportedPets[petKey] = nil
                end
            end
        end
    end
    
    lastPlayerList = currentPlayers
end

-- Regional server hopper with single attempt fallback
local function tryRegionalHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    
    -- Pick a random region
    local regions = {"japan", "korea", "brazil", "spain", "eu", "netherlands", "ukraine", "vietnam", "usa", "canada", "uk", "germany", "france", "australia", "singapore", "india", "mexico", "turkey"}
    local selectedRegion = regions[math.random(1, #regions)]
    local endpoint = REGIONAL_ENDPOINTS[selectedRegion]
    
    
    -- Single HTTP request attempt
    local success, serverData = pcall(function()
        local response = game:HttpGet(endpoint)
        return HttpService:JSONDecode(response)
    end)
    
    if not success then
        return false
    end
    
    if not serverData.data or #serverData.data == 0 then
        return false
    end
    
    -- Find a suitable server
    local availableServers = {}
    for _, server in ipairs(serverData.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId and server.playing >= 3 then
            table.insert(availableServers, server)
        end
    end
    
    if #availableServers == 0 then
        return false
    end
    
    -- Pick random server from available ones
    local targetServer = availableServers[math.random(1, #availableServers)]
        selectedRegion, targetServer.id, targetServer.playing, targetServer.maxPlayers))
    
    -- Single teleport attempt
    local teleportSuccess, teleportError = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, LocalPlayer)
    end)
    
    if teleportSuccess then
        return true
    else
        return false
    end
end

-- HYBRID SERVER HOPPER (REGIONAL THEN MANUAL FALLBACK)
_G.hopServer = function()
    if isHopping then
        return
    end
    
    isHopping = true
    retryCount = 0
    
    -- Try regional hop first (single attempt only)
    local regionalSuccess = tryRegionalHop()
    
    if not regionalSuccess then
        -- Fall back to manual-style hopper
        local TeleportService = game:GetService("TeleportService")
        
        local function tryManualHop()
            retryCount = retryCount + 1
            
            local timeout = false
            -- Shorter timeout for faster hopping
            task.spawn(function()
                task.wait(10) -- Reduced from 15 to 10 seconds
                if isHopping and not timeout then
                    timeout = true
                    task.wait(2)
                    tryManualHop()
                end
            end)
            
            -- Handle teleport failures
            local teleportFailConnection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
                if player == LocalPlayer and isHopping and not timeout then
                    teleportFailConnection:Disconnect()
                    task.wait(1) -- Reduced delay
                    tryManualHop()
                end
            end)
            
            -- Use manual-style teleport
            local success, err = pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            
            if success then
            else
                if not timeout then
                    if teleportFailConnection then teleportFailConnection:Disconnect() end
                    task.wait(1) -- Reduced delay
                    tryManualHop()
                end
            end
        end
        
        tryManualHop()
    end
    
    -- Shorter backup cleanup
    task.spawn(function()
        task.wait(20) -- Reduced from 30 to 20 seconds
        if isHopping then
            isHopping = false
        end
    end)
end

-- Enhanced character spawn handler to reset hopping flag
local function setupCharacterHandlers()
    local function onCharacterAdded(character)
        if isHopping then
            -- Add a small delay to ensure we're actually in a new server
            task.wait(2)
            -- Check if we're actually in a different server
            local currentJobId = game.JobId
            if currentJobId and currentJobId ~= "" then
                isHopping = false
                retryCount = 0
                -- Clear blacklist on successful hop
                blacklistedServers = {}
                -- Reset scan state for new server
                scanStartTime = 0
                scanCompleted = false
                reportedPets = {} -- Clear all reported pets for new server
                clearAndRefreshUI()
            else
                -- If no JobId yet, we might still be loading
            end
        end
    end
    
    -- Connect to current and future characters
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

-- Main execution
local function startScanner()
    -- Load and apply config on startup
    local loadedConfig = loadConfig()
    applyConfig(loadedConfig)
    local gui, scrollFrame = createNotificationGUI()
    
    -- Create and store the auto hop toggle button
    local autoHopToggle = createAutoHopToggle()
    
    -- Make the toggle button draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    autoHopToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = autoHopToggle.Position
            game:GetService("RunService").Heartbeat:Connect(function()
                if dragging then
                    local delta = UserInputService:GetMouseLocation() - dragStart
                    autoHopToggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Initialize player list
    for _, player in ipairs(Players:GetPlayers()) do
        lastPlayerList[player.UserId] = player.Name
    end
    
    -- Setup character spawn handlers
    setupCharacterHandlers()
    
    -- Wait for character if needed
    if LocalPlayer.Character then
        task.wait(1)
    end
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
    end)
    
    -- Keybind to toggle GUI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            local mainFrame = LocalPlayer.PlayerGui:FindFirstChild("BrainrotScanner")
            if mainFrame and mainFrame:FindFirstChild("ScannerFrame") then
                local frame = mainFrame.ScannerFrame
                frame.Visible = not frame.Visible
                guiVisible = frame.Visible
            end
        end
    end)
    
    -- Start scanning connections
    scanConnection = RunService.Heartbeat:Connect(function()
        scanForHighValueBrainrots()
        updateGUI(scrollFrame)
    end)
    
    updateConnection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastPlayerCheck >= 3 then
            checkPlayerChanges()
            lastPlayerCheck = currentTime
        end
    end)
    
    wait(1)
end

-- Stop scanner function
local function stopScanner()
    if scanConnection then
        scanConnection:Disconnect()
        scanConnection = nil
    end
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    
    local gui = LocalPlayer.PlayerGui:FindFirstChild("BrainrotScanner")
    if gui then
        gui:Destroy()
    end
    local hopGui = LocalPlayer.PlayerGui:FindFirstChild("AutoHopGui")
    if hopGui then
        hopGui:Destroy()
    end
    
    isHopping = false
end

-- Global functions for manual control
_G.startPetFinder = startScanner
_G.stopPetFinder = stopScanner
_G.toggleSpecificBrainrot = function(name, enabled)
    if specificBrainrots[name] then
        specificBrainrots[name].Enabled = enabled
        clearAndRefreshUI()
    else
    end
end

_G.toggleRarity = function(rarity, enabled)
    if raritySettings[rarity] then
        raritySettings[rarity].Enabled = enabled
        clearAndRefreshUI()
    else
    end
end

-- Debug functions
_G.showBlacklist = function()
    for id, data in pairs(blacklistedServers) do
    end
end

_G.clearBlacklist = function()
    blacklistedServers = {}
end

_G.getHopStatus = function()
        isHopping and "HOPPING" or "IDLE", retryCount, #blacklistedServers))
end

_G.clearReported = function()
    reportedPets = {}
end

-- Auto-start
startScanner()