local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// Tạo GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "NPC_ESP_GUI"
gui.ResetOnSpawn = false

-- Nút thu gọn
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Position = UDim2.new(0, 10, 0.25, 0)
toggleButton.Size = UDim2.new(0, 150, 0, 35)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.Text = "📦 ESP Pro - Hiện Menu"
toggleButton.ZIndex = 2

-- Frame chính
local mainFrame = Instance.new("Frame", gui)
mainFrame.Position = UDim2.new(0, 10, 0.3, 0)
mainFrame.Size = UDim2.new(0, 250, 0, 400)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ZIndex = 2

-- Scrollable list
local scrollingFrame = Instance.new("ScrollingFrame", mainFrame)
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.ZIndex = 2

local layout = Instance.new("UIListLayout", scrollingFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- Danh sách NPC
local npcNames = {
    "Noobini Pizzanini", "Lirili Larila", "Tim Cheese", "FluriFlura", "Talpa Di Fero", "Svinina Bombardino",
    "Pipi Kiwi", "Trippi Troppi", "Tung Tung Tung Sahur", "Gangster Footera", "Bandito Bobritto",
    "Boneca Ambalabu", "Cacto Hipopotamo", "Ta Ta Ta Ta Sahur", "Tric Trac Baraboom",
    "Cappuccino Assassino", "Brr Brr Patapim", "Trulimero Trulicina", "Bambini Crostini", "Bananita Dolphinita",
    "Perochello Lemonchello", "Brri Brri Bicus Dicus Bombicus", "Avocadini Guffo", "Salamino Penguino",
    "Burbaloni Loliloli", "Chimpazini Bananini", "Ballerina Cappuccina", "Chef Crabracadabra",
    "Lionel Cactuseli", "Glorbo Fruttodrillo", "Blueberrini Octopusini", "Strawberelli Flamingelli",
    "Pandaccini Bananini", "Frigo Camelo", "Orangutini Ananassini", "Rhino Toasterino", "Bombardiro Crocodilo",
    "Bombombini Gusini", "Cavallo Virtuso", "Gorillo Watermelondrillo", "Spioniro Golubiro",
    "Zibra Zubra Zibralini", "Tigrilini Watermelini", "Cocofanto Elefanto", "Girafa Celestre",
    "Gattatino Nyanino", "Matteo", "Tralalero Tralala", "Espresso Signora", "Odin Din Din Dun",
    "Statutino Libertino", "Trenostruzzo Turbo 3000", "Ballerino Lololo", "Trigoligre Frutonni",
    "Orcalero Orcala", "Los Crocodillitos", "Piccione Macchina", "La Vacca Staturno Saturnita",
    "Chimpanzini Spiderini", "Los Tralaleritos", "Las Tralaleritas", "Graipuss Medussi",
    "La Grande Combinasion", "Nuclearo Dinossauro", "Garama and Madundung",
    "Tortuginni Dragonfruitini", "Pot Hotspot", "Las Vaquitas Saturnitas", "Chicleteira Bicicleteira"
}

-- Danh sách đã chọn
local selectedNPCs = {}

-- Tạo nút chọn cho mỗi NPC
for _, name in ipairs(npcNames) do
    local toggle = Instance.new("TextButton", scrollingFrame)
    toggle.Size = UDim2.new(1, -10, 0, 25)
    toggle.Text = "❌ " .. name
    toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.SourceSansBold
    toggle.TextSize = 18
    toggle.ZIndex = 2

    toggle.MouseButton1Click:Connect(function()
        selectedNPCs[name] = not selectedNPCs[name]
        toggle.Text = (selectedNPCs[name] and "✅ " or "❌ ") .. name
    end)
end

-- Tự cập nhật CanvasSize
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Toggle nút hiển thị khung chọn
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleButton.Text = "📦 ESP Pro - " .. (mainFrame.Visible and "Ẩn Menu" or "Hiện Menu")
end)

-- Tối ưu hóa ESP
local rainbowCache = {}
local lastUpdate = 0
local UPDATE_INTERVAL = 0.2 -- Giảm tần suất cập nhật
local espInstances = {} -- Lưu trữ các ESP đã tạo
local heartbeatConnection
local anyNPCSelected = false

local function getRainbowColor(speed)
    local t = tick() * (speed or 1)
    return Color3.fromHSV((t % 5) / 5, 1, 1)
end

-- Hàm xóa toàn bộ ESP
local function clearAllESP()
    for _, esp in pairs(espInstances) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    table.clear(espInstances)
    table.clear(rainbowCache)
end

-- Hàm tạo ESP
local function createESP(model)
    if not espInstances[model] and model:IsA("Model") then
        local head = model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
        if head then
            local billboard = Instance.new("BillboardGui", model)
            billboard.Name = "ESP_Name"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.Adornee = head
            billboard.MaxDistance = 500 -- Giới hạn khoảng cách hiển thị
            billboard.Enabled = false -- Tắt mặc định

            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextScaled = true
            label.Font = Enum.Font.FredokaOne
            label.Text = model.Name
            label.TextColor3 = getRainbowColor()
            label.TextStrokeTransparency = 0.3
            
            espInstances[model] = billboard
            rainbowCache[billboard] = label
            
            -- Bật ESP nếu NPC được chọn
            if selectedNPCs[model.Name] then
                billboard.Enabled = true
            end
            
            return billboard
        end
    end
    return espInstances[model]
end

-- Hàm cập nhật màu
local function updateRainbowColors()
    local currentTime = tick()
    if currentTime - lastUpdate < UPDATE_INTERVAL then return end
    lastUpdate = currentTime
    
    local rainbowColor = getRainbowColor(1.5) -- Giảm tốc độ đổi màu
    for _, label in pairs(rainbowCache) do
        if label and label.Parent then
            label.TextColor3 = rainbowColor
        end
    end
end

-- Hàm kiểm tra và cập nhật ESP
local function updateESP()
    -- Kiểm tra xem có NPC nào được chọn không
    local newAnyNPCSelected = false
    for _, selected in pairs(selectedNPCs) do
        if selected then
            newAnyNPCSelected = true
            break
        end
    end
    
    -- Nếu không có NPC nào được chọn, xóa toàn bộ ESP
    if not newAnyNPCSelected then
        if anyNPCSelected then
            clearAllESP()
        end
        anyNPCSelected = false
        return
    end
    
    anyNPCSelected = true
    
    -- Tìm và cập nhật ESP cho các NPC được chọn
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and selectedNPCs[model.Name] then
            local esp = createESP(model)
            if esp then
                esp.Enabled = true
            end
        end
    end
    
    -- Vô hiệu hóa ESP cho các NPC không được chọn
    for model, esp in pairs(espInstances) do
        if esp and esp.Parent then
            esp.Enabled = selectedNPCs[model.Name] or false
        end
    end
    
    -- Cập nhật màu
    updateRainbowColors()
end

-- Kết nối sự kiện
local function toggleESP(enabled)
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    
    if enabled then
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            updateESP()
        end)
    else
        clearAllESP()
    end
end

-- Thêm sự kiện khi thay đổi lựa chọn NPC
for _, toggle in ipairs(scrollingFrame:GetChildren()) do
    if toggle:IsA("TextButton") then
        toggle.MouseButton1Click:Connect(function()
            -- Bật ESP nếu có ít nhất 1 NPC được chọn
            local shouldEnable = false
            for _, selected in pairs(selectedNPCs) do
                if selected then
                    shouldEnable = true
                    break
                end
            end
            toggleESP(shouldEnable)
        end)
    end
end

-- Tự động tắt ESP khi script kết thúc
gui.AncestryChanged:Connect(function()
    if not gui.Parent then
        toggleESP(false)
    end
end)
