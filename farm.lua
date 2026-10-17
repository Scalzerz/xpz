

local function InitCandyWaypointFarm()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return end

    local WAYPOINT_FILE = "BrazilHub_Waypoints.json"

    local function LoadWaypoints()
        if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(WAYPOINT_FILE) then
            local success, content = pcall(readfile, WAYPOINT_FILE)
            if success and content then
                local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(content) end)
                if decodeSuccess and typeof(decoded) == "table" then
                    return decoded
                end
            end
        end
        return {}
    end

    local state = {
        isEnabled = false,
        isMinimized = false,
        farmThread = nil,
        candyDelay = 0.5,     
        waypointDelay = 10.0, 
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

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 32)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    ToggleBtn.Text = "AUTO FARM: OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 11
    ToggleBtn.LayoutOrder = 1
    ToggleBtn.Parent = ContentFrame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

    local SettingsContainer = Instance.new("Frame")
    SettingsContainer.Size = UDim2.new(1, 0, 0, 52)
    SettingsContainer.BackgroundTransparency = 1
    SettingsContainer.LayoutOrder = 2
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

    local CandyDelayInput = CreateInputBox("Delay Doces (s)", "0.5", 0)
    local WpDelayInput = CreateInputBox("Delay Posições (s)", "10.0", 0.52)

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
    StatusLabel.LayoutOrder = 3
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

        local adjustedCFrame = CFrame.new(targetCFrame.Position + Vector3.new(0, 2, 0))
        if char.PrimaryPart then 
            char:PivotTo(adjustedCFrame) 
        else 
            hrp.CFrame = adjustedCFrame 
        end
    end

    local function StopFarmLoop()
        state.isEnabled = false
        if state.farmThread then task.cancel(state.farmThread) state.farmThread = nil end
    end

    local function StartFarmLoop()
        StopFarmLoop()
        state.isEnabled = true

        state.farmThread = task.spawn(function()
            while state.isEnabled do
                pcall(function()
                    state.waypoints = LoadWaypoints()

                    local folder = Workspace:FindFirstChild("HalloweenCandiesLocal")
                    local candies = folder and folder:GetChildren() or {}

                    if #candies > 0 then
                        -- Modo Doces (Seguro contra modelos sem part direta)
                        for _, candy in ipairs(candies) do
                            if not state.isEnabled then break end
                            if candy and candy.Parent then
                                local targetCf = nil
                                if candy:IsA("Model") then
                                    targetCf = candy:GetPivot()
                                elseif candy:IsA("BasePart") then
                                    targetCf = candy.CFrame
                                else
                                    local part = candy:FindFirstChildWhichIsA("BasePart", true)
                                    if part then targetCf = part.CFrame end
                                end

                                if targetCf then
                                    StatusLabel.Text = "Status: Coletando Doce"
                                    StatusLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
                                    TeleportToCFrame(targetCf)
                                    task.wait(state.candyDelay)
                                end
                            end
                        end
                    else
                        -- Modo Posições / Waypoints salvos
                        if #state.waypoints > 0 then
                            if state.currentWpIndex > #state.waypoints then 
                                state.currentWpIndex = 1 
                            end
                            
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
                                StatusLabel.Text = string.format("Status: TP Localização (%d/%d)", state.currentWpIndex, #state.waypoints)
                                StatusLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
                                TeleportToCFrame(targetCFrame)
                            end

                            state.currentWpIndex = state.currentWpIndex + 1

                            local elapsed = 0
                            while state.isEnabled and elapsed < state.waypointDelay do
                                local currentFolder = Workspace:FindFirstChild("HalloweenCandiesLocal")
                                if currentFolder and #currentFolder:GetChildren() > 0 then break end
                                task.wait(0.2)
                                elapsed = elapsed + 0.2
                            end
                        else
                            StatusLabel.Text = "Status: Nenhum Waypoint Salvo!"
                            StatusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
                            task.wait(1)
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        state.isEnabled = not state.isEnabled
        if state.isEnabled then
            ToggleBtn.Text = "AUTO FARM: ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 35, 120)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            StartFarmLoop()
        else
            ToggleBtn.Text = "AUTO FARM: OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
            ToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
            StatusLabel.Text = "Status: Parado"
            StatusLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
            StopFarmLoop()
        end
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        state.isMinimized = not state.isMinimized
        ContentFrame.Visible = not state.isMinimized
        MinimizeBtn.Text = state.isMinimized and "+" or "-"
    end)

    UnloadBtn.MouseButton1Click:Connect(function()
        StopFarmLoop()
        for _, conn in ipairs(state.connections) do conn:Disconnect() end
        if ScreenGui then ScreenGui:Destroy() end
    end)
end

InitCandyWaypointFarm()
