local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

Rayfield:Notify({
    Title = "Blackout",
    Content = "Loaded: Dinonsaur Simulator",
    Duration = 3
    Image = "shield-check"
}
task.wait(1)

local windowConfig = {
    Name = "Blackout",
    Icon = 119114755415903,
    LoadingTitle = ". . . loading . . .",
    LoadingSubtitle = "Dinonsaur Simulator",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Blackout"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
}

local Window = Rayfield:CreateWindow(windowConfig)

local MissionHelperTab = Window:CreateTab("✔️Mission Helper✔️", 12298401909)

do
    local isAntiAfkEnabled = false
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local function antiAfkJumpLoop()
        while isAntiAfkEnabled do
            task.wait(10)
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
            print("Anti-Idle active: Simulated action to prevent AFK.")
        end
    end

    local function antiAfkRespawnLoop()
        while isAntiAfkEnabled do
            local localPlayer = Players.LocalPlayer
            local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
            character:WaitForChild("Humanoid").Died:Connect(function()
                if isAntiAfkEnabled then
                    print("Player/Dinosaur died. Waiting for respawn...")
                end
            end)
            localPlayer.CharacterAdded:Wait()
            if isAntiAfkEnabled then
                print("Player/Dinosaur respawned or grew. Anti-Idle still active.")
            end
        end
    end

    MissionHelperTab:CreateButton({
        Name = "Press to Enable Anti AFK",
        Callback = function()
            if not isAntiAfkEnabled then
                print("Anti-Idle Enabled!")
                isAntiAfkEnabled = true
                task.spawn(antiAfkJumpLoop)
                task.spawn(antiAfkRespawnLoop)
            else
                print("Anti-Idle already active!")
            end
        end
    })
end

MissionHelperTab:CreateSection("Teleport To Region Bonus|🎯Stay In Region Bonus For 600s Task🎯")
do
    local LocalPlayer = game.Players.LocalPlayer
    local isRegionBonusTeleportEnabled = false

    local function notifyRegionBonusReached()
        Rayfield:Notify({
            Title = "Zumm Region Bonus Reached!",
            Content = "Happy Farming!",
            Duration = 6.5,
            Image = "gem"
        })
    end

    local function teleportToPart(part)
        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            warn("HumanoidRootPart not found for the player")
            return
        end
        local startPosition = rootPart.Position
        local targetPosition = part.Position + Vector3.new(0, 5, 0)
        local duration = 3
        local elapsedTime = 0
        while elapsedTime < duration do
            if not isRegionBonusTeleportEnabled then break end
            elapsedTime = elapsedTime + task.wait()
            local alpha = elapsedTime / duration
            rootPart.CFrame = CFrame.new(startPosition:Lerp(targetPosition, alpha))
        end
        print("Simulated gradual movement to region boundary")
        notifyRegionBonusReached()
    end

    local function findAndTeleportToBonusRegion()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local RegionsFolder = ReplicatedStorage:FindFirstChild("Regions")
        if not RegionsFolder then
            warn("Regions folder not found in ReplicatedStorage")
            return
        end

        local ServerValues = workspace:FindFirstChild("ServerValues")
        local ServerBonus = ServerValues and ServerValues:FindFirstChild("ServerBonus")
        local CurrentRegionBonus = ServerBonus and ServerBonus:FindFirstChild("CurrentRegionBonus")

        if not CurrentRegionBonus or (CurrentRegionBonus.Value == "") then
            warn("No current region bonus active")
            return
        end

        local regionData = string.split(CurrentRegionBonus.Value, ",")
        if #regionData > 0 then
            local regionName = regionData[1]:gsub("%[", ""):gsub("%]", ""):gsub('\"', "")
            local regionFolder = RegionsFolder:FindFirstChild(regionName)
            if regionFolder then
                local boundaryPart = regionFolder:FindFirstChildWhichIsA("Part")
                if boundaryPart then
                    teleportToPart(boundaryPart)
                    print("Region bonus simulated for:", regionName)
                else
                    warn("Boundary part not found for region:", regionName)
                end
            else
                warn("Region folder not found for:", regionName)
            end
        else
            warn("No valid regions to simulate bonus")
        end
    end

    local function regionBonusTeleportLoop()
        while isRegionBonusTeleportEnabled do
            findAndTeleportToBonusRegion()
            wait(15)
        end
    end

    local function toggleRegionBonusTeleport(state)
        isRegionBonusTeleportEnabled = state
        if isRegionBonusTeleportEnabled then
            print("Region Bypass Enabled!")
            spawn(regionBonusTeleportLoop)
        else
            print("Region Bypass Disabled!")
        end
    end

    MissionHelperTab:CreateToggle({
        Name = "✈️Go to Bonus Region✈️",
        CurrentValue = false,
        Flag = "RegionBonusToggle",
        Callback = function(value)
            toggleRegionBonusTeleport(value)
        end
    })
end

MissionHelperTab:CreateSection("Teleport To A Region|🎯Visit Region Task🎯")
do
    local LocalPlayer = game.Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RegionsFolder = ReplicatedStorage:FindFirstChild("Regions")

    local function teleportToPart(part)
        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            warn("HumanoidRootPart not found for the player")
            return
        end
        local startPosition = rootPart.Position
        local targetPosition = part.Position + Vector3.new(0, 5, 0)
        local duration = 3
        local elapsedTime = 0
        while elapsedTime < duration do
            elapsedTime = elapsedTime + task.wait()
            local alpha = elapsedTime / duration
            rootPart.CFrame = CFrame.new(startPosition:Lerp(targetPosition, alpha))
        end
        print("Moved toward:", part.Parent.Name)
    end

    local function teleportToRegion(regionName)
        if not RegionsFolder then
            warn("Regions folder not found")
            return
        end
        local regionFolder = RegionsFolder:FindFirstChild(regionName)
        if regionFolder then
            local boundaryPart = regionFolder:FindFirstChildWhichIsA("Part")
            if boundaryPart then
                teleportToPart(boundaryPart)
            else
                warn("Boundary part not found for region:", regionName)
            end
        else
            warn("Region not found:", regionName)
        end
    end

    local regionNames = {
        "Aviary", "Lower Jungle Wilds", "Restricted Zone", "Southeast Dock",
        "Tallgrass Wilds", "Worker Village", "Jungle", "Ocean Wilds",
    }
    
    for _, regionName in ipairs(regionNames) do
        MissionHelperTab:CreateButton({
            Name = "Go to " .. regionName,
            Callback = function()
                teleportToRegion(regionName)
            end
        })
    end
end

local MainTab = Window:CreateTab("Main", 114884616355341)

MainTab:CreateSection("Auto Shift Lock")
do
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local isAutoCtrlEnabled = false
    local autoCtrlDelay = 0.5

    local function autoCtrlLoop()
        while isAutoCtrlEnabled do
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            task.wait(autoCtrlDelay)
        end
    end

    MainTab:CreateSlider({
        Name = "Auto CTRL Delay",
        Range = {0, 1},
        Increment = 0.1,
        Suffix = " s",
        CurrentValue = 0.5,
        Flag = "CtrlDelay",
        Callback = function(value)
            autoCtrlDelay = value
            print("Auto CTRL Delay set to " .. autoCtrlDelay .. " seconds")
        end
    })

    MainTab:CreateToggle({
        Name = "Press Toggle To Enable UR (Press V to Enable)",
        CurrentValue = false,
        Flag = "AutoCtrlToggle",
        Callback = function(value)
            isAutoCtrlEnabled = value
            print("Auto CTRL Press toggled: " .. tostring(isAutoCtrlEnabled))
            if isAutoCtrlEnabled then
                spawn(autoCtrlLoop)
            end
        end
    })

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if input.KeyCode == Enum.KeyCode.V then
            isAutoCtrlEnabled = not isAutoCtrlEnabled
            if MainTab.SetToggle then
                MainTab:SetToggle("AutoCtrlToggle", isAutoCtrlEnabled)
            end
            print("Auto CTRL toggled via V: " .. tostring(isAutoCtrlEnabled))
            if isAutoCtrlEnabled then
                spawn(autoCtrlLoop)
            end
        end
    end)
end

MainTab:CreateSection("🍖Food🍖 And 💧Water💧")
do
    local UserInputService = game:GetService("UserInputService")
    local isAutoFoodEnabled = false
    local isAutoWaterEnabled = false

    local function findNearestLeaf()
        local GameMap = game.Workspace:FindFirstChild("GameMap")
        if GameMap then
            for _, mapType in ipairs({"GameLand", "GameOcean"}) do
                local mapPart = GameMap:FindFirstChild(mapType)
                if mapPart then
                    local Props = mapPart:FindFirstChild("Props")
                    if Props then
                        for _, descendant in ipairs(Props:GetDescendants()) do
                            if descendant:IsA("BasePart") and descendant.Name == "Leaf" then
                                return descendant
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    local function autoFoodLoop()
        while isAutoFoodEnabled do
            task.wait(0.1)
            local nearestLeaf = findNearestLeaf()
            if nearestLeaf then
                game.Workspace.GameEvents.EatPlant:FireServer(nearestLeaf, 10)
            end
        end
    end

    local function toggleAutoFood()
        isAutoFoodEnabled = not isAutoFoodEnabled
        Rayfield:Notify({
            Title = (isAutoFoodEnabled and "🥩 Hunger Mode Activated!") or "🥩 Hunger Mode Disabled!",
            Content = (isAutoFoodEnabled and "Eating leaves every 0.1s...") or "Stopped eating.",
            Duration = 6.5,
            Image = "check"
        })
        if isAutoFoodEnabled then
            spawn(autoFoodLoop)
        end
    end

    local function drinkWater()
        local waterPart = game:GetService("Workspace"):FindFirstChild("GameMap"):FindFirstChild("Water"):FindFirstChild("OceanWater"):FindFirstChild("Water")
        if waterPart then
            local addThirstEvent = game:GetService("Workspace").GameEvents.addThirst
            addThirstEvent:FireServer(waterPart, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.p)
        end
    end

    local function autoWaterLoop()
        while isAutoWaterEnabled do
            task.wait(0.1)
            drinkWater()
        end
    end

    local function toggleAutoWater()
        isAutoWaterEnabled = not isAutoWaterEnabled
        Rayfield:Notify({
            Title = (isAutoWaterEnabled and "💧 Water Mode Activated!") or "💧 Water Mode Disabled!",
            Content = (isAutoWaterEnabled and "Drinking water every 0.1s...") or "Stopped drinking.",
            Duration = 6.5,
            Image = "check"
        })
        if isAutoWaterEnabled then
            spawn(autoWaterLoop)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.B then
                toggleAutoFood()
            elseif input.KeyCode == Enum.KeyCode.N then
                toggleAutoWater()
            end
        end
    end)

    MainTab:CreateToggle({
        Name = "🥩Give Only Food🥩(Press B)",
        CurrentValue = false,
        Flag = "HungerOnlyToggle",
        Callback = function(value)
            isAutoFoodEnabled = value
            if isAutoFoodEnabled then
                spawn(autoFoodLoop)
            end
        end
    })

    MainTab:CreateToggle({
        Name = "💧Give Water Only💦(Press N)",
        CurrentValue = false,
        Flag = "WaterOnlyToggle",
        Callback = function(value)
            isAutoWaterEnabled = value
            if isAutoWaterEnabled then
                spawn(autoWaterLoop)
            end
        end
    })
end

MainTab:CreateSection("🤜Auto Attack🤛")
do
    local UserInputService = game:GetService("UserInputService")
    local autoAttackState = { Enabled = false }

    local function autoAttackLoop()
        while autoAttackState.Enabled do
            task.wait()
            game.Workspace.GameEvents.Damage:FireServer("Workspace")
        end
    end

    local function toggleAutoAttack()
        if autoAttackState.Enabled then
            coroutine.wrap(autoAttackLoop)()
            Rayfield:Notify({Title = "Auto Attack", Content = "Auto Attack has been enabled!⚔️", Duration = 6.5, Image = "swords"})
            print("Auto Attack is enabled.")
        else
            Rayfield:Notify({Title = "Auto Attack", Content = "Auto Attack has been disabled.❌", Duration = 6.5, Image = "swords"})
            print("Auto Attack is disabled.")
        end
    end

    UserInputService.InputBegan:Connect(function(input)
        if UserInputService:GetFocusedTextBox() then return end
        if (input.UserInputType == Enum.UserInputType.Keyboard) and (input.KeyCode == Enum.KeyCode.Y) then
            autoAttackState.Enabled = not autoAttackState.Enabled
            toggleAutoAttack()
        end
    end)

    MainTab:CreateToggle({
        Name = "⚔️Auto Attack🤺(Press y To Enable)",
        CurrentValue = autoAttackState.Enabled,
        Flag = "ToggleAutoAttack",
        Callback = function(value)
            autoAttackState.Enabled = value
            toggleAutoAttack()
        end
    })
end

MainTab:CreateSection("Fly")
do
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = game.Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    _G.Speed = 50
    local platformOffset = 5
    local isFlyEnabled = false
    local flyLoopConnection = nil
    local flightPlatform = nil

    local function enableFly()
        local character = LocalPlayer.Character
        if not character then return end

        local rootPart = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not rootPart or not humanoid then return end

        humanoid.PlatformStand = true
        flightPlatform = Instance.new("Part")
        flightPlatform.Name = "FlightPlatform"
        flightPlatform.Size = Vector3.new(10, 1, 10)
        flightPlatform.Transparency = 1
        flightPlatform.Anchored = true
        flightPlatform.CanCollide = false
        flightPlatform.Parent = workspace
        flightPlatform.CFrame = rootPart.CFrame * CFrame.new(0, -platformOffset, 0)

        flyLoopConnection = RunService.RenderStepped:Connect(function(deltaTime)
            local moveDirection = Vector3.new(0, 0, 0)
            local cameraCFrame = Camera.CFrame

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + cameraCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - cameraCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cameraCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cameraCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

            if moveDirection.Magnitude < 0.1 then
                local lookY = cameraCFrame.LookVector.Y
                if lookY > 0.7 then moveDirection = Vector3.new(0, 1, 0)
                elseif lookY < -0.7 then moveDirection = Vector3.new(0, -1, 0)
                end
            else
                moveDirection = moveDirection.Unit
            end

            flightPlatform.CFrame = flightPlatform.CFrame + (moveDirection * _G.Speed * deltaTime)
            rootPart.CFrame = flightPlatform.CFrame * CFrame.new(0, platformOffset, 0)
        end)
        isFlyEnabled = true
    end

    local function disableFly()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
        if flyLoopConnection then
            flyLoopConnection:Disconnect()
            flyLoopConnection = nil
        end
        if flightPlatform then
            flightPlatform:Destroy()
            flightPlatform = nil
        end
        isFlyEnabled = false
    end

    LocalPlayer.CharacterAdded:Connect(function(character)
        disableFly()
    end)

    MainTab:CreateButton({
        Name = "Skateboard fly. Respawn to disable, (Can Cause Ban)",
        Callback = function()
            if isFlyEnabled then
                print("Platform Flight already enabled.")
                return
            end
            isFlyEnabled = true
            print("Platform Flight enabled. Control the platform to fly; your character remains above it until you respawn.")
            enableFly()
        end
    })
end

MainTab:CreateSection("🥮Simulate Tokens In Inventory (To Use Skins)📮")
do
    local function addDinosaurToken(dinoName)
        local LocalPlayer = game.Players.LocalPlayer
        local MemoryCard = LocalPlayer:FindFirstChild("MemoryCard")
        if not MemoryCard then
            MemoryCard = Instance.new("Folder")
            MemoryCard.Name = "MemoryCard"
            MemoryCard.Parent = LocalPlayer
            print("Created new MemoryCard folder")
        end

        local TokensFolder = MemoryCard:FindFirstChild("Tokens")
        if not TokensFolder then
            TokensFolder = Instance.new("Folder")
            TokensFolder.Name = "Tokens"
            TokensFolder.Parent = MemoryCard
            print("Created new Tokens folder")
        end

        local dinoToken = TokensFolder:FindFirstChild(dinoName)
        if not dinoToken then
            dinoToken = Instance.new("IntValue")
            dinoToken.Name = dinoName
            dinoToken.Parent = TokensFolder
            print("Simulated token ownership of dinosaur:", dinoName)
        else
            print("Dinosaur token already exists for:", dinoName)
        end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Database = ReplicatedStorage:FindFirstChild("Database")
        if Database then
            local DinosaursDB = Database:FindFirstChild("Dinosaurs")
            if DinosaursDB then
                local dinoData = DinosaursDB:FindFirstChild(dinoName)
                if dinoData then
                    local playerDinosFolder = MemoryCard:FindFirstChild("Dinosaurs")
                    if not playerDinosFolder then
                        playerDinosFolder = Instance.new("Folder")
                        playerDinosFolder.Name = "Dinosaurs"
                        playerDinosFolder.Parent = MemoryCard
                        print("Created new Dinosaurs folder in MemoryCard")
                    end
                    if not playerDinosFolder:FindFirstChild(dinoName) then
                        local clonedDinoData = dinoData:Clone()
                        clonedDinoData.Parent = playerDinosFolder
                        print("Moved dinosaur folder to MemoryCard->Dinosaurs:", dinoName)
                    else
                        print("Dinosaur folder already exists in MemoryCard->Dinosaurs:", dinoName)
                    end
                else
                    warn("Dinosaur folder not found in ReplicatedStorage:", dinoName)
                end
            else
                warn("Dinosaurs folder not found in Database")
            end
        else
            warn("Database folder not found in ReplicatedStorage")
        end
    end

    local dinoNameInput = MainTab:CreateInput({
        Name = "Enter Dinosaur Name",
        CurrentValue = "",
        PlaceholderText = "Please Name Of Dinosaur Here",
        RemoveTextAfterFocusLost = false,
        Flag = "Input1",
        Callback = function(text)
            if text and text ~= "" then
                print("Text entered: ", text)
            else
                print("❗Please enter a dinosaur name❗.")
            end
        end
    })

    MainTab:CreateButton({
        Name = "🌟Add Token to Inventory🌟",
        Callback = function()
            local dinoName = dinoNameInput.CurrentValue
            if dinoName and dinoName ~= "" then
                addDinosaurToken(dinoName)
                print("Added entered dinosaur to inventory:", dinoName)
            else
                print("❗Please enter a dinosaur name❗.")
            end
        end
    })
end

MainTab:CreateSection("☁️Make Rain☁️")
do
    local ServerValues = workspace:FindFirstChild("ServerValues")
    if not ServerValues then
        warn("ServerValues not found!")
        return
    end
    local rainingValue = ServerValues:FindFirstChild("Raining")
    if not rainingValue then
        warn("Raining value not found in ServerValues!")
        return
    end

    local function setRaining(state)
        if state then
            rainingValue.Value = true
            print("Raining activated!")
        else
            rainingValue.Value = false
            print("Raining deactivated!")
        end
    end

    MainTab:CreateToggle({
        Name = "☔ Toggle Rain ☔",
        CurrentValue = false,
        Flag = "ToggleRaining",
        Callback = function(value)
            setRaining(value)
        end
    })
end

local FarmTab = Window:CreateTab("Farm", 15864549276)

FarmTab:CreateSection("🚀🔴Enable Anti Ban🚀🔴")
do
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local CharStorage = Workspace:FindFirstChild("CharStorage")
    local LocalPlayer = Players.LocalPlayer
    local isAntiBanEnabled = false

    local adminUserIds = {
        8245193366, 96541104, 21238127, 24836348, 23952793, 6828351, 109217153, 119868, 39523020,
        14922769, 35276317, 63300487, 33488003, 117551840, 4317782, 69239108, 21447425, 204949625,
        160319861, 302566312, 69453307, 95126752, 55328654, 10032944, 113655887, 93676120, 44193678,
        9741973, 83259917, 105626586, 74108393, 42285938, 94254052, 57628717, 81275825, 14099358,
        144170792, 39925610, 94254052, 128978453, 42213282, 566686862
    }
    local devDinoNames = {
        "Rekkusu, Destroyer of Worlds", "Lucas Tha Kittygator", "Violex Behemoth", "Mad Al",
        "Supersuchus", "Alligaterror", "Vexahias", "?????", "Zweinova-Exa", "Apocalios",
        "Crimson Soaked Terranotus", "Igneous Teravore", "Ultimallosaurus", "Anastasia",
        "Overmoth", "Lucy", "Droid", "Voltacoatl", "Kralkatorrik", "Spooki"
    }

    local function kickPlayerForBan()
        LocalPlayer:Kick("🚨 Anti-Ban Triggered! Admin/Dev detected. 🚨")
        print("Anti-ban triggered! Player kicked due to Admin/Dev presence.")
    end

    local function checkAdmins()
        for _, player in ipairs(Players:GetPlayers()) do
            if table.find(adminUserIds, player.UserId) then
                print("Admin detected: " .. player.Name)
                kickPlayerForBan()
                return
            end
        end
    end

    local function checkDevDinos()
        if CharStorage then
            for _, dinoName in ipairs(devDinoNames) do
                if CharStorage:FindFirstChild(dinoName) then
                    print("Dev Dinosaur detected: " .. dinoName)
                    kickPlayerForBan()
                    return
                end
            end
        end
    end

    local function setupRespawnAntiBanCheck()
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.2)
            if isAntiBanEnabled then
                print("Player respawned! Restarting Anti-Ban...")
                task.spawn(antiBanLoop)
            end
        end)
    end
    
    local function antiBanLoop()
        while isAntiBanEnabled do
            checkAdmins()
            checkDevDinos()
            task.wait(0.2)
        end
    end

    local function toggleAntiBan(state)
        isAntiBanEnabled = state
        if isAntiBanEnabled then
            print("Anti-Ban Activated! Scanning for Admins & Dev Dinosaurs...")
            task.spawn(antiBanLoop)
            setupRespawnAntiBanCheck()
        else
            print("Anti-Ban Disabled! Stopping scans.")
        end
    end

    FarmTab:CreateButton({
        Name = "🔴 Anti-Ban",
        Callback = function()
            if isAntiBanEnabled then
                Rayfield:Notify({
                    Title = "🚨 Anti-Ban Already Enabled!",
                    Content = "Hey! It's already running—you don't need to worry!",
                    Duration = 6.5,
                    Image = "circle-pause"
                })
            else
                toggleAntiBan(true)
            end
        end
    })
end

FarmTab:CreateSection("Auto Grown And Auto Farm")
do
    local hasSetupRan = false

    local function runAutoFarmSetup()
        if hasSetupRan then return end
        hasSetupRan = true

        game.Workspace.GameEvents.GoToMenu:FireServer()
        print("✅ Sending player to menu...")
        Rayfield:Notify({
            Title = "📢 Setup in Progress...",
            Content = "Please wait while we set everything up for you!",
            Duration = 8,
            Image = 4483362458
        })
        wait(8)

        local dinoToSpawn = "Caveman 2"
        game.Workspace.GameEvents.ChangeDinosaur:FireServer(dinoToSpawn)
        wait(2.5)
        game.Workspace.GameEvents.StartPlayer:FireServer()
        game.Workspace.GameEvents.ChangeDinosaur:FireServer(dinoToSpawn)
        wait(3)
        game.Workspace.GameEvents.ChangeDinosaur:FireServer(dinoToSpawn)
        print("✅ Spawn successful as Caveman 2!")
        Rayfield:Notify({
            Title = "✅ Setup Complete!",
            Content = "Done! Now Disable AutoFarm Setup and Enable AutoGrown.",
            Duration = 6.5,
            Image = 4483362458
        })
    end

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local farmPlatformPosition = Vector3.new(-1561, 115, -992)
    local isAutoGrownEnabled = false

    local function createFarmPlatform()
        local platform = Instance.new("Part")
        platform.Name = "AutoFarmPlatform"
        platform.Size = Vector3.new(10, 1, 10)
        platform.Position = farmPlatformPosition
        platform.Anchored = true
        platform.CanCollide = true
        platform.BrickColor = BrickColor.new("Bright red")
        platform.Parent = game.Workspace
        return platform
    end

    local function moveToPlatform(character)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            warn("HumanoidRootPart not found!")
            return
        end
        local startPosition = rootPart.Position
        local targetPosition = farmPlatformPosition
        local duration = 25
        local elapsedTime = 0
        local connection
        connection = RunService.RenderStepped:Connect(function(deltaTime)
            if not isAutoGrownEnabled then
                connection:Disconnect()
                return
            end
            elapsedTime = elapsedTime + deltaTime
            local alpha = math.clamp(elapsedTime / duration, 0, 1)
            rootPart.CFrame = CFrame.new(startPosition:Lerp(targetPosition, alpha))
            if alpha == 1 then
                connection:Disconnect()
                rootPart.Anchored = true
                print("✅ Player/Caveman 2 reached the platform!")
                Rayfield:Notify({
                    Title = "🎉 Setup Finished!",
                    Content = "Done! Please Create Pack and Nest, then Menu and Choose your Dinosaur to grow.",
                    Duration = 6.5,
                    Image = 4483362458
                })
            end
        end)
    end
    
    local function findNearestLeaf()
        local GameMap = game.Workspace:FindFirstChild("GameMap")
        if GameMap then
            for _, mapType in ipairs({"GameLand", "GameOcean"}) do
                local mapPart = GameMap:FindFirstChild(mapType)
                if mapPart then
                    local Props = mapPart:FindFirstChild("Props")
                    if Props then
                        for _, descendant in ipairs(Props:GetDescendants()) do
                            if descendant:IsA("BasePart") and descendant.Name == "Leaf" then
                                return descendant
                            end
                        end
                    end
                end
            end
        end
        return nil
    end
    
    local function drinkWater()
        local waterPart = game.Workspace:FindFirstChild("GameMap"):FindFirstChild("Water"):FindFirstChild("OceanWater"):FindFirstChild("Water")
        if waterPart then
            game.Workspace.GameEvents.addThirst:FireServer(waterPart, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.p)
        end
    end

    local function autoFarmLoop()
        while isAutoGrownEnabled do
            task.wait(0.1)
            local nearestLeaf = findNearestLeaf()
            if nearestLeaf then
                game.Workspace.GameEvents.EatPlant:FireServer(nearestLeaf, 20)
                drinkWater()
            else
                print("No valid Leaf found.")
            end
        end
    end

    local function setupRespawnHandler()
        local localPlayer = Players.LocalPlayer
        localPlayer.CharacterAdded:Connect(function(character)
            if isAutoGrownEnabled then
                print("Respawn detected. Moving back to platform in 7 seconds...")
                Rayfield:Notify({
                    Title = "⚠️ Respawn Detected!",
                    Content = "AutoFarm will restart in 7 seconds.",
                    Duration = 6.5,
                    Image = "triangle-alert"
                })
                task.wait(7)
                if isAutoGrownEnabled then
                    task.spawn(autoFarmLoop)
                    moveToPlatform(character)
                end
            end
        end)
    end

    FarmTab:CreateToggle({
        Name = "⚙️ AutoFarm Setup",
        CurrentValue = false,
        Flag = "AutoFarmSetupToggle",
        Callback = function(value)
            if value then
                print("✅ AutoFarm Setup Started!")
                runAutoFarmSetup()
            else
                print("❌ Setup Disabled! Now enable AutoGrown.")
            end
        end
    })

    FarmTab:CreateToggle({
        Name = "🐰 Enable AutoGrown | Motion 🐮",
        CurrentValue = false,
        Flag = "AutoFarmToggle",
        Callback = function(value)
            if value then
                print("✅ AutoGrown Enabled!")
                isAutoGrownEnabled = true
                createFarmPlatform()
                local localPlayer = Players.LocalPlayer
                local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                moveToPlatform(character)
                task.spawn(autoFarmLoop)
                task.spawn(setupRespawnHandler)
            else
                print("❌ AutoGrown Disabled!")
                isAutoGrownEnabled = false
                local platform = game.Workspace:FindFirstChild("AutoFarmPlatform")
                if platform then
                    platform:Destroy()
                end
                local localPlayer = Players.LocalPlayer
                local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                if character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.Anchored = false
                end
            end
        end
    })
end

FarmTab:CreateSection("Glass Farm")
do
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local beamFarmTweenSpeed = 2
    local isBeamFarmEnabled = false
    local roamingPositions = {
        Vector3.new(100, 50, -200), Vector3.new(-350, 48, 720), Vector3.new(450, 60, -100),
        Vector3.new(0, 45, 0), Vector3.new(-600, 47, -500), Vector3.new(250, 52, 500),
        Vector3.new(-150, 51, -300)
    }

    local function tweenToPosition(position)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local tweenInfo = TweenInfo.new(beamFarmTweenSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local goal = { CFrame = CFrame.new(position + Vector3.new(0, 3, 0)) }
        local tween = TweenService:Create(rootPart, tweenInfo, goal)
        tween:Play()
        tween.Completed:Wait()
    end

    local function beamFarmLoop()
        while isBeamFarmEnabled do
            local MiscStorage = Workspace:FindFirstChild("MiscellaneousStorage")
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local beam = MiscStorage and (MiscStorage:FindFirstChild("Beam") or MiscStorage:FindFirstChild("Glass Beam"))

            if beam and rootPart then
                local beamPosition = beam:GetPivot().Position
                print("🌟 Found:", beam.Name)
                local tweenInfo = TweenInfo.new(beamFarmTweenSpeed, Enum.EasingStyle.Sine)
                local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = CFrame.new(beamPosition + Vector3.new(0, 3, 0)) })
                tween:Play()
                tween.Completed:Wait()
                task.wait(0.25)
            elseif rootPart then
                local randomPosition = roamingPositions[math.random(1, #roamingPositions)]
                print("🧭 Roaming to:", randomPosition)
                tweenToPosition(randomPosition)
                task.wait(0.5)
            else
                task.wait(1)
            end
        end
    end

    LocalPlayer.CharacterAdded:Connect(function()
        if isBeamFarmEnabled then
            task.wait(1)
            spawn(beamFarmLoop)
        end
    end)

    FarmTab:CreateSlider({
        Name = "Tween Speed",
        Range = {0.5, 10},
        Increment = 0.5,
        Suffix = " sec",
        CurrentValue = beamFarmTweenSpeed,
        Flag = "BeamSpeedSlider",
        Callback = function(value)
            beamFarmTweenSpeed = value
            print("⚙️ Tween Speed set to:", value)
        end
    })

    FarmTab:CreateToggle({
        Name = "Enable Beam Farm (Roaming)",
        CurrentValue = false,
        Flag = "BeamFarmRoamToggle",
        Callback = function(value)
            isBeamFarmEnabled = value
            if value then
                print("🚀 Beam Farm Activated")
                spawn(beamFarmLoop)
                Rayfield:Notify({ Title = "Beam Farm ON", Content = "Searching & roaming until beam appears.", Duration = 5, Image = "check" })
            else
                print("🛑 Beam Farm Disabled")
                Rayfield:Notify({ Title = "Beam Farm OFF", Content = "Stopped roaming.", Duration = 3, Image = "warning" })
            end
        end
    })
end

local JurassicEventTab = Window:CreateTab("Jurassic Event", 254809709)

JurassicEventTab:CreateSection("Amber ESP")
do
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local isAmberEspEnabled = false
    local activeEspElements = {}

    local function createEspForAmber(amberModel)
        if activeEspElements[amberModel] then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "AmberRockESP_HL"
        highlight.Adornee = amberModel
        highlight.FillColor = Color3.fromRGB(255, 200, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 50, 0)
        highlight.OutlineTransparency = 0
        highlight.Parent = amberModel

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "AmberRockESP_GUI"
        billboardGui.Adornee = amberModel
        billboardGui.Size = UDim2.new(0, 120, 0, 40)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = amberModel

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "AmberRock"
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Parent = billboardGui

        activeEspElements[amberModel] = { highlight = highlight, gui = billboardGui }
    end

    local function clearAllEsp()
        for _, esp in pairs(activeEspElements) do
            if esp.highlight then esp.highlight:Destroy() end
            if esp.gui then esp.gui:Destroy() end
        end
        activeEspElements = {}
    end

    RunService.RenderStepped:Connect(function()
        if not isAmberEspEnabled then return end
        local MiscStorage = Workspace:FindFirstChild("MiscellaneousStorage")
        if not MiscStorage then return end

        for _, child in ipairs(MiscStorage:GetChildren()) do
            if child.Name == "AmberRock" and child:IsA("Model") then
                createEspForAmber(child)
            end
        end
    end)

    JurassicEventTab:CreateToggle({
        Name = "Amber ESP",
        CurrentValue = false,
        Flag = "AmberRockESP",
        Callback = function(value)
            isAmberEspEnabled = value
            if not isAmberEspEnabled then
                clearAllEsp()
            end
        end
    })
end

JurassicEventTab:CreateSection("Auto Farm Amber")
do
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local isAmberFarmEnabled = false
    local amberFarmTweenSpeed = 2

    local function getLocalPlayerRootPart()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        return character:WaitForChild("HumanoidRootPart")
    end

    local function tweenToPosition(position)
        local rootPart = getLocalPlayerRootPart()
        local tween = TweenService:Create(rootPart, TweenInfo.new(amberFarmTweenSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(position) })
        tween:Play()
        tween.Completed:Wait()
    end

    local function collectAmber(amberModel)
        local prompt = amberModel:FindFirstChildWhichIsA("ProximityPrompt", true)
        local MiscStorage = Workspace:FindFirstChild("MiscellaneousStorage")
        if not prompt or not MiscStorage then return end

        while isAmberFarmEnabled and amberModel.Parent == MiscStorage do
            fireproximityprompt(prompt)
            task.wait(0.1)
        end
    end

    local function findClosestAmberRock()
        local MiscStorage = Workspace:FindFirstChild("MiscellaneousStorage")
        local rootPart = getLocalPlayerRootPart()
        if not MiscStorage then return nil end

        local closestRock
        local minDistance = math.huge
        for _, child in ipairs(MiscStorage:GetChildren()) do
            if child:IsA("Model") and child.Name == "AmberRock" then
                local part1 = child:FindFirstChild("Part1", true)
                if part1 then
                    local distance = (rootPart.Position - part1.Position).Magnitude
                    if distance < minDistance then
                        minDistance = distance
                        closestRock = child
                    end
                end
            end
        end
        return closestRock
    end

    local function amberFarmLoop()
        spawn(function()
            while isAmberFarmEnabled do
                local closestRock = findClosestAmberRock()
                local MiscStorage = Workspace:FindFirstChild("MiscellaneousStorage")
                if closestRock and isAmberFarmEnabled and closestRock.Parent == MiscStorage then
                    local targetPart = closestRock:FindFirstChild("Part1", true)
                    if targetPart then
                        print("🎯 Targeting AmberRock at", math.floor((getLocalPlayerRootPart().Position - targetPart.Position).Magnitude), "studs")
                        tweenToPosition(targetPart.Position)
                        collectAmber(closestRock)
                        while isAmberFarmEnabled and closestRock.Parent == MiscStorage do
                            task.wait(0.1)
                        end
                        print("✅ Rock collected. Continuing...")
                    end
                else
                    print("🔄 No valid AmberRock found.")
                    task.wait(1)
                end
            end
        end)
    end
    
    LocalPlayer.CharacterAdded:Connect(function()
        if isAmberFarmEnabled then
            spawn(amberFarmLoop)
        end
    end)
    
    JurassicEventTab:CreateSlider({
        Name = "Tween Speed",
        Range = {0.5, 10},
        Increment = 0.5,
        Suffix = " sec",
        CurrentValue = amberFarmTweenSpeed,
        Flag = "AmberTweenSpeed",
        Callback = function(value)
            amberFarmTweenSpeed = value
            print("⚙️ Tween speed updated:", value)
        end
    })

    JurassicEventTab:CreateToggle({
        Name = "Smart AmberRock Farm",
        CurrentValue = false,
        Flag = "SmartAmberFarm",
        Callback = function(value)
            isAmberFarmEnabled = value
            if value then
                spawn(amberFarmLoop)
                Rayfield:Notify({Title = "AmberRock Tracker", Content = "Auto-farming closest AmberRock activated!", Duration = 5, Image = "gem"})
            else
                Rayfield:Notify({Title = "AmberRock Tracker", Content = "Farming stopped.", Duration = 3, Image = "warning"})
            end
        end
    })
end

JurassicEventTab:CreateSection("Spam Extract amber")
do
    local Workspace = game:GetService("Workspace")
    local isSpamExtractEnabled = false

    local function spamExtractLoop()
        while isSpamExtractEnabled do
            local movieEvent = Workspace:FindFirstChild("GameEvents") and Workspace.GameEvents:FindFirstChild("MovieEvent2025")
            local extractEvent = movieEvent and movieEvent:FindFirstChild("ExtractAmber")
            if extractEvent then
                extractEvent:FireServer()
                print("🎞️ Fired ExtractAmber event")
            else
                warn("❌ ExtractAmber event not found.")
            end
            task.wait(0.2)
        end
    end

    JurassicEventTab:CreateToggle({
        Name = "Spam ExtractAmber",
        CurrentValue = false,
        Flag = "ExtractAmberToggle",
        Callback = function(value)
            isSpamExtractEnabled = value
            if value then
                spawn(spamExtractLoop)
                Rayfield:Notify({Title = "Amber Extraction", Content = "Spamming ExtractAmber event...", Duration = 5, Image = "gem"})
            else
                Rayfield:Notify({Title = "Amber Extraction", Content = "Stopped ExtractAmber spam.", Duration = 3, Image = "warning"})
            end
        end
    })
end

JurassicEventTab:CreateSection("Hack Terminals")
do
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local terminalTweenSpeed = 2
    local terminalEspDistance = 100
    local activeTerminalEsp = {}
    local terminalObjects = {
        ActiveTerminal1 = Workspace:WaitForChild("Interactables"):FindFirstChild("ActiveTerminal1"),
        ActiveTerminal2 = Workspace:WaitForChild("Interactables"):FindFirstChild("ActiveTerminal2"),
        ActiveTerminal3 = Workspace:WaitForChild("Interactables"):FindFirstChild("ActiveTerminal3")
    }

    local function goToTerminal(terminal)
        local targetPosition = terminal:GetPivot().Position
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        local tween = TweenService:Create(rootPart, TweenInfo.new(terminalTweenSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(targetPosition) })
        tween:Play()
    end

    local function createTerminalEsp(terminal, name)
        if activeTerminalEsp[terminal] then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "TerminalESP_HL"
        highlight.Adornee = terminal
        highlight.FillColor = Color3.new(0, 0.8, 1)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.3
        highlight.Parent = terminal

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "TerminalESP_GUI"
        billboardGui.Adornee = terminal
        billboardGui.Size = UDim2.new(0, 120, 0, 35)
        billboardGui.StudsOffset = Vector3.new(0, 4, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = terminal

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = name
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = billboardGui

        activeTerminalEsp[terminal] = { highlight = highlight, gui = billboardGui }
    end

    RunService.RenderStepped:Connect(function()
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        for terminal, esp in pairs(activeTerminalEsp) do
            if esp.gui then
                local distance = (rootPart.Position - terminal:GetPivot().Position).Magnitude
                esp.gui.Enabled = distance <= terminalEspDistance
            end
        end
    end)
    
    for name, terminal in pairs(terminalObjects) do
        if terminal then
            createTerminalEsp(terminal, name)
        end
    end
    
    JurassicEventTab:CreateButton({
        Name = "Go to Terminal 1",
        Callback = function()
            if terminalObjects.ActiveTerminal1 then
                goToTerminal(terminalObjects.ActiveTerminal1)
            end
        end
    })
    
    JurassicEventTab:CreateButton({
        Name = "Go to Terminal 2",
        Callback = function()
            if terminalObjects.ActiveTerminal2 then
                goToTerminal(terminalObjects.ActiveTerminal2)
            end
        end
    })
    
    JurassicEventTab:CreateButton({
        Name = "Go to Terminal 3",
        Callback = function()
            if terminalObjects.ActiveTerminal3 then
                goToTerminal(terminalObjects.ActiveTerminal3)
            end
        end
    })
    
    JurassicEventTab:CreateSlider({
        Name = "ESP Distance",
        Range = {10, 500},
        Increment = 10,
        Suffix = " studs",
        CurrentValue = terminalEspDistance,
        Flag = "TerminalESPDistance",
        Callback = function(value)
            terminalEspDistance = value
            print("🛰️ ESP label distance set to:", value)
        end
    })
end
