--[[
    ========================================================================
    CANDY & POTIONS TP FARM (CLOUD JSON & ANTI-VOID MATRIX SAFE)
    ========================================================================
--]]

local function InitCandyWaypointFarm()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return end

    local URL_DO_JSON_RAW = "https://raw.githubusercontent.com/Scalzerz/xpz/refs/heads/main/BrazilHub_Waypoints.json"

    local function LoadWaypoints()
        local success, response = pcall(function()
            return game:HttpGet(URL_DO_JSON_RAW)
        end)

        if success and response then
            local decodeSuccess, decoded = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            if decodeSuccess and typeof(decoded) == "table" then
                return decoded
            end
        end
        return {}
    end

    local state = {
        isCandyEnabled = false,
        isPotionsEnabled = false,
        isMinimized = false,
        candyThread = nil,
        potionsThread = nil,
        candyDelay = 0.4,      
        waypointDelay = 8.0,   
        waypoints = LoadWaypoints(),
        currentWpIndex = 1,
        connections = {}
    }

    local function GetSafeGuiParent(): Instance
        if typeof(gethui) == "function" then
            local success, result = pcall(gethui)
            if success and result then return result end
        end
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        if playerGui then
            if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
                pcall(syn.protect_gui, playerGui)
            end
            return playerGui
        end
        error("Container seguro não encontrado.")
    end

    local parentContainer = GetSafeGuiParent()
    local oldGui = parentContainer:FindFirstChild("CandyWaypointFarm_GUI")
    if oldGui then oldGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CandyWaypointFarm_GUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentContainer

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 220, 0, 0)
    MainFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.AutomaticSize = Enum.AutomaticSize.Y
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 60)
    stroke.Thickness = 1.2
    stroke.Parent = MainFrame

    local MainLayout = Instance.new("UIListLayout")
    MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MainLayout.Padding = UDim.new(0, 6)
    MainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    MainLayout.Parent = MainFrame

    local MainPadding = Instance.new("UIPadding")
    MainPadding.PaddingTop = UDim.new(0, 8)
    MainPadding.PaddingBottom = UDim.new(0, 8)
    MainPadding.PaddingLeft = UDim.new(0, 10)
    MainPadding.PaddingRight = UDim.new(0, 10)
    MainPadding.Parent = MainFrame

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 24)
    TopBar.BackgroundTransparency = 1
    TopBar.LayoutOrder = 1
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -44, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "BRAZIL HUB | FARM"
    TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextSize = 11
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 20, 0, 22)
    MinimizeBtn.Position = UDim2.new(1, -42, 0, 0)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 14
    MinimizeBtn.Parent = TopBar
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

    local UnloadBtn = Instance.new("TextButton")
    UnloadBtn.Size = UDim2.new(0, 20, 0, 22)
    UnloadBtn.Position = UDim2.new(1, -20, 0, 0)
    UnloadBtn.BackgroundColor3 = Color3.fromRGB(60, 25, 30)
    UnloadBtn.Text = "×"
    UnloadBtn.TextColor3 = Color3.fromRGB(220, 100, 100)
    UnloadBtn.Font = Enum.Font.GothamBold
    UnloadBtn.TextSize = 14
    UnloadBtn.Parent = TopBar
    Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 4)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 0, 0)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
    ContentFrame.LayoutOrder = 2
    ContentFrame.Parent = MainFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 6)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.Parent = ContentFrame

    -- Botão 1: Auto Farm de Doces + Waypoints
    local ToggleCandyBtn = Instance.new("TextButton")
    ToggleCandyBtn.Size = UDim2.new(1, 0, 0, 30)
    ToggleCandyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    ToggleCandyBtn.Text = "AUTO CANDIES: OFF"
    ToggleCandyBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    ToggleCandyBtn.Font = Enum.Font.GothamBold
    ToggleCandyBtn.TextSize = 11
    ToggleCandyBtn.LayoutOrder = 1
    ToggleCandyBtn.Parent = ContentFrame
    Instance.new("UICorner", ToggleCandyBtn).CornerRadius = UDim.new(0, 6)

    -- Botão 2: Auto Farm de Poções (WerewolfPotionsLocal)
    local TogglePotionsBtn = Instance.new("TextButton")
    TogglePotionsBtn.Size = UDim2.new(1, 0, 0, 30)
    TogglePotionsBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    TogglePotionsBtn.Text = "AUTO POTIONS: OFF"
    TogglePotionsBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    TogglePotionsBtn.Font = Enum.Font.GothamBold
    TogglePotionsBtn.TextSize = 11
    TogglePotionsBtn.LayoutOrder = 2
    TogglePotionsBtn.Parent = ContentFrame
    Instance.new("UICorner", TogglePotionsBtn).CornerRadius = UDim.new(0, 6)

    local SettingsContainer = Instance.new("Frame")
    SettingsContainer.Size = UDim2.new(1, 0, 0, 52)
    SettingsContainer.BackgroundTransparency = 1
    SettingsContainer.LayoutOrder = 3
    SettingsContainer.Parent = ContentFrame

    local function CreateInputBox(name, defaultVal, orderX)
        local boxFrame = Instance.new("Frame")
        boxFrame.Size = UDim2.new(0.48, 0, 1, 0)
        boxFrame.Position = UDim2.new(orderX, 0, 0, 0)
        boxFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
        boxFrame.Parent = SettingsContainer
        Instance.new("UICorner", boxFrame).CornerRadius = UDim.new(0, 5)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = Color3.fromRGB(140, 140, 150)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 8
        lbl.Parent = boxFrame

        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, 0, 0, 28)
        input.Position = UDim2.new(0, 0, 0, 18)
        input.BackgroundTransparency = 1
        input.Text = tostring(defaultVal)
        input.TextColor3 = Color3.fromRGB(0, 210, 255)
        input.Font = Enum.Font.GothamBold
        input.TextSize = 11
        input.ClearTextOnFocus = false
        input.Parent = boxFrame

        return input
    end

    local CandyDelayInput = CreateInputBox("Delay Itens (s)", "0.4", 0)
    local WpDelayInput = CreateInputBox("Delay Posições (s)", "8.0", 0.52)

    CandyDelayInput.FocusLost:Connect(function()
        local val = tonumber(CandyDelayInput.Text)
        if val and val > 0 then state.candyDelay = val else CandyDelayInput.Text = tostring(state.candyDelay) end
    end)

    WpDelayInput.FocusLost:Connect(function()
        local val = tonumber(WpDelayInput.Text)
        if val and val > 0 then state.waypointDelay = val else WpDelayInput.Text = tostring(state.waypointDelay) end
    end)

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Status: Parado"
    StatusLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextSize = 10
    StatusLabel.LayoutOrder = 4
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = ContentFrame

    local function RegisterDrag(guiObject)
        local dragging, dragStart, startPos
        local connBegan = guiObject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                local connEnded
                connEnded = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false connEnded:Disconnect() end
                end)
            end
        end)
        local connChanged = UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        table.insert(state.connections, connBegan)
        table.insert(state.connections, connChanged)
    end
    RegisterDrag(MainFrame)
    RegisterDrag(TopBar)

    local function TeleportToCFrame(targetCFrame)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local targetPos = targetCFrame.Position + Vector3.new(0, 2, 0)

        pcall(function()
            if LocalPlayer.RequestStreamAroundAsync then
                LocalPlayer:RequestStreamAroundAsync(targetPos)
            end
        end)

        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        local adjustedCFrame = CFrame.new(targetPos)
        if char.PrimaryPart then 
            char:PivotTo(adjustedCFrame) 
        else 
            hrp.CFrame = adjustedCFrame 
        end

        task.defer(function()
            if hrp and hrp.Parent then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    local function GetValidItems(folderName)
        local folder = Workspace:FindFirstChild(folderName)
        local items = folder and folder:GetChildren() or {}
        local validItems = {}

        for _, item in ipairs(items) do
            if item and item.Parent then
                local rawCf = nil
                if item:IsA("Model") then
                    rawCf = item:GetPivot()
                elseif item:IsA("BasePart") then
                    rawCf = item.CFrame
                else
                    local part = item:FindFirstChildWhichIsA("BasePart", true)
                    if part then rawCf = part.CFrame end
                end

                if rawCf then
                    local success, yPos = pcall(function()
                        return rawCf.Position.Y
                    end)
                    
                    if not success or not yPos then
                        local components = {rawCf:GetComponents()}
                        yPos = components[2]
                    end

                    -- Trava Y > 0 (Ignora subsolo e void)
                    if yPos and yPos > 0 then
                        table.insert(validItems, {instance = item, cframe = rawCf})
                    end
                end
            end
        end
        return validItems
    end

    -- Loop de Doces + Waypoints
    local function StartCandyLoop()
        if state.candyThread then task.cancel(state.candyThread) end
        state.candyThread = task.spawn(function()
            while state.isCandyEnabled do
                pcall(function()
                    state.waypoints = LoadWaypoints()
                    local validCandies = GetValidItems("HalloweenCandiesLocal")

                    if #validCandies > 0 then
                        for _, data in ipairs(validCandies) do
                            if not state.isCandyEnabled then break end
                            if data.instance and data.instance.Parent then
                                StatusLabel.Text = "Status: Coletando Doce 🍬"
                                StatusLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
                                TeleportToCFrame(data.cframe)
                                task.wait(state.candyDelay)
                            end
                        end
                    else
                        if #state.waypoints > 0 then
                            if state.currentWpIndex > #state.waypoints then state.currentWpIndex = 1 end
                            local wp = state.waypoints[state.currentWpIndex]
                            local targetCFrame = nil
                            
                            if typeof(wp) == "table" then
                                if wp[1] and wp[2] and wp[3] then
                                    targetCFrame = CFrame.new(wp[1], wp[2], wp[3])
                                else
                                    targetCFrame = CFrame.new(wp.X or wp[1], wp.Y or wp[2], wp.Z or wp[3])
                                end
                            end

                            if targetCFrame then
                                StatusLabel.Text = string.format("Status: TP Rota (%d/%d)", state.currentWpIndex, #state.waypoints)
                                StatusLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
                                TeleportToCFrame(targetCFrame)
                            end

                            state.currentWpIndex = state.currentWpIndex + 1

                            local elapsed = 0
                            while state.isCandyEnabled and elapsed < state.waypointDelay do
                                if #GetValidItems("HalloweenCandiesLocal") > 0 then break end
                                task.wait(0.2)
                                elapsed = elapsed + 0.2
                            end
                        else
                            StatusLabel.Text = "Status: Sem Waypoints!"
                            StatusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
                            task.wait(1)
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end

    -- Loop Exclusivo de Poções (WerewolfPotionsLocal)
    local function StartPotionsLoop()
        if state.potionsThread then task.cancel(state.potionsThread) end
        state.potionsThread = task.spawn(function()
            while state.isPotionsEnabled do
                pcall(function()
                    local validPotions = GetValidItems("WerewolfPotionsLocal")

                    if #validPotions > 0 then
                        for _, data in ipairs(validPotions) do
                            if not state.isPotionsEnabled then break end
                            if data.instance and data.instance.Parent then
                                StatusLabel.Text = "Status: Coletando Poção 🧪"
                                StatusLabel.TextColor3 = Color3.fromRGB(150, 50, 255)
                                TeleportToCFrame(data.cframe)
                                task.wait(state.candyDelay)
                            end
                        end
                    else
                        StatusLabel.Text = "Status: Procurando Poções..."
                        StatusLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
                        task.wait(1)
                    end
                end)
                task.wait(0.1)
            end
        end)
    end

    ToggleCandyBtn.MouseButton1Click:Connect(function()
        state.isCandyEnabled = not state.isCandyEnabled
        if state.isCandyEnabled then
            ToggleCandyBtn.Text = "AUTO CANDIES: ON"
            ToggleCandyBtn.BackgroundColor3 = Color3.fromRGB(60, 35, 120)
            ToggleCandyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            StartCandyLoop()
        else
            ToggleCandyBtn.Text = "AUTO CANDIES: OFF"
            ToggleCandyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
            ToggleCandyBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
            if not state.isPotionsEnabled then
                StatusLabel.Text = "Status: Parado"
                StatusLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
            end
            if state.candyThread then task.cancel(state.candyThread) state.candyThread = nil end
        end
    end)

    TogglePotionsBtn.MouseButton1Click:Connect(function()
        state.isPotionsEnabled = not state.isPotionsEnabled
        if state.isPotionsEnabled then
            TogglePotionsBtn.Text = "AUTO POTIONS: ON"
            TogglePotionsBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 140)
            TogglePotionsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            StartPotionsLoop()
        else
            TogglePotionsBtn.Text = "AUTO POTIONS: OFF"
            TogglePotionsBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
            TogglePotionsBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
            if not state.isCandyEnabled then
                StatusLabel.Text = "Status: Parado"
                StatusLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
            end
            if state.potionsThread then task.cancel(state.potionsThread) state.potionsThread = nil end
        end
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        state.isMinimized = not state.isMinimized
        ContentFrame.Visible = not state.isMinimized
        MinimizeBtn.Text = state.isMinimized and "+" or "-"
    end)

    UnloadBtn.MouseButton1Click:Connect(function()
        state.isCandyEnabled = false
        state.isPotionsEnabled = false
        if state.candyThread then task.cancel(state.candyThread) end
        if state.potionsThread then task.cancel(state.potionsThread) end
        for _, conn in ipairs(state.connections) do conn:Disconnect() end
        if ScreenGui then ScreenGui:Destroy() end
    end)
end

InitCandyWaypointFarm()
