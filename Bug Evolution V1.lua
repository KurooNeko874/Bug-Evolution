local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local guiParent = (gethui and gethui()) or CoreGui
if guiParent:FindFirstChild("BugEvoFarmGUI") then
    guiParent.BugEvoFarmGUI:Destroy()
end

-- Konfigurasi Toggle
local Config = {
    SmartQuest = false,
    AutoOrbs = false,
    AutoBugs = false,
    AutoBreakables = false,
    AutoAttack = false,
    AutoClaim = false
}

local SessionCoins = 0
local CurrentQuestTarget = "Menunggu..."

-- Pembuatan UI (Sneat-Inspired Clean Dark/Blue Theme)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BugEvoFarmGUI"
ScreenGui.Parent = guiParent
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 380)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 110, 245)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Bug Evo V2 - Coin & Quest"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -33, 0, 3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function()
    for k, _ in pairs(Config) do Config[k] = false end
    ScreenGui:Destroy()
end)

-- Panel Status (Target Quest & Perolehan Koin)
local StatusBox = Instance.new("Frame")
StatusBox.Size = UDim2.new(1, -20, 0, 50)
StatusBox.Position = UDim2.new(0, 10, 0, 44)
StatusBox.BackgroundColor3 = Color3.fromRGB(32, 36, 48)
StatusBox.BorderSizePixel = 0
StatusBox.Parent = MainFrame
Instance.new("UICorner", StatusBox).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 1, 0)
StatusLabel.Position = UDim2.new(0, 8, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Target Quest: -\nKoin Sesi Ini: +0"
StatusLabel.TextColor3 = Color3.fromRGB(130, 200, 255)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBox

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -108)
Container.Position = UDim2.new(0, 10, 0, 102)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout", Container)
UIListLayout.Padding = UDim.new(0, 7)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateToggle(text, configKey, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(38, 42, 56)
    Btn.Text = text .. " : OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 205, 220)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 12
    Btn.LayoutOrder = order
    Btn.Parent = Container
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        if Config[configKey] then
            Btn.BackgroundColor3 = Color3.fromRGB(45, 110, 245)
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Text = text .. " : ON"
        else
            Btn.BackgroundColor3 = Color3.fromRGB(38, 42, 56)
            Btn.TextColor3 = Color3.fromRGB(200, 205, 220)
            Btn.Text = text .. " : OFF"
        end
    end)
end

CreateToggle("1. Smart Auto-Quest (Fast Coin)", "SmartQuest", 1)
CreateToggle("2. Auto Collect All Orbs (XP)", "AutoOrbs", 2)
CreateToggle("3. Auto Farm Semua Bugs (Coin)", "AutoBugs", 3)
CreateToggle("4. Auto Farm Semua Breakables", "AutoBreakables", 4)
CreateToggle("5. Auto Bite & Spam Ability", "AutoAttack", 5)
CreateToggle("6. Auto Claim Chest & Rewards", "AutoClaim", 6)

-- Helper Karakter
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Listener Koin Masuk
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CoinRemote = Remotes:FindFirstChild("CoinGain")
if CoinRemote then
    CoinRemote.OnClientEvent:Connect(function(amount, source)
        if type(amount) == "number" then
            SessionCoins = SessionCoins + amount
            StatusLabel.Text = "Target: " .. CurrentQuestTarget .. "\nKoin Sesi Ini: +" .. tostring(SessionCoins) .. " (" .. tostring(source) .. ")"
        end
    end)
end

-- Fungsi Pembaca UI Quest Otomatis
local function GetActiveQuests()
    local tasks = {
         needOrbs = false,
         needAbility = false,
         bugTarget = nil,
         breakTarget = nil
    }
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local questHUD = pGui and pGui:FindFirstChild("HUD") and pGui.HUD:FindFirstChild("Quest")
    if not questHUD then return tasks end

    for _, v in pairs(questHUD:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible and v.Text ~= "" then
            local txt = v.Text
            if string.find(txt, "abilities") then
                tasks.needAbility = true
            elseif string.find(txt, "XP orbs") then
                tasks.needOrbs = true
            elseif string.find(txt, "Crack") then
                -- Contoh: "Crack 21 Acorns" -> ambil kata "Acorn"
                local target = string.match(txt, "Crack %d+ (.+)")
                if target then
                    target = string.gsub(target, "s$", "") -- Hapus huruf 's' jamak di belakang
                    tasks.breakTarget = target
                end
            elseif string.find(txt, "Eat") and not string.find(txt, "player") and not string.find(txt, "orbs") then
                -- Contoh: "Eat 4 Beetles" -> ambil kata "Beetle"
                local target = string.match(txt, "Eat %d+ (.+)")
                if target then
                    target = string.gsub(target, "s$", "")
                    tasks.bugTarget = target
                end
            end
        end
    end
    return tasks
end

-- Loop 1: Auto Attack & Ability
task.spawn(function()
    local AttackRemote = Remotes:FindFirstChild("Attack")
    local AbilityRemote = Remotes:FindFirstChild("UseAbility")

    while task.wait(0.15) do
        if Config.AutoAttack or Config.SmartQuest then
            if AttackRemote then pcall(function() AttackRemote:FireServer() end) end
            if AbilityRemote then pcall(function() AbilityRemote:FireServer() end) end
        end
    end
end)

-- Loop 2: Auto Claim SandChest & Rewards
task.spawn(function()
    local SandChestAction = Remotes:FindFirstChild("SandChestAction")
    local RewardsRemote = Remotes:FindFirstChild("Rewards")
    local PassAction = Remotes:FindFirstChild("PassAction")

    while task.wait(3) do
        if Config.AutoClaim then
            pcall(function()
                if SandChestAction then
                    SandChestAction:InvokeServer("Claim")
                    SandChestAction:InvokeServer()
                end
                if RewardsRemote then
                    for i = 1, 12 do RewardsRemote:InvokeServer(i) end
                end
                if PassAction then
                    PassAction:InvokeServer("ClaimAll")
                end
            end)
        end
    end
end)

-- Loop 3: Main Grinder (Smart Quest, Orbs, Bugs, Breakables)
task.spawn(function()
    local orbFolders = {"RainbowOrbs", "Orbs", "VoidOrbs", "SandOrbs"}
    local OrbRemote = Remotes:FindFirstChild("OrbCollected")

    while task.wait(0.1) do
        local hrp = getHRP()
        if not hrp then continue end

        -- MODE 1: SMART AUTO-QUEST
        if Config.SmartQuest then
            local q = GetActiveQuests()

            if q.breakTarget then
                CurrentQuestTarget = "Break: " .. q.breakTarget
                StatusLabel.Text = "Target: " .. CurrentQuestTarget .. "\nKoin Sesi Ini: +" .. tostring(SessionCoins)
                local breakFolder = workspace:FindFirstChild("Breakables")
                if breakFolder then
                    for _, item in ipairs(breakFolder:GetChildren()) do
                        if not Config.SmartQuest then break end
                        if string.find(string.lower(item.Name), string.lower(q.breakTarget)) then
                            local hitbox = item:FindFirstChild("Hitbox") or item:FindFirstChildWhichIsA("BasePart")
                            while Config.SmartQuest and item.Parent and hitbox and hitbox.Parent do
                                local myHRP = getHRP()
                                if not myHRP then break end
                                myHRP.CFrame = hitbox.CFrame * CFrame.new(0, 1, 2)
                                myHRP.AssemblyLinearVelocity = Vector3.zero
                                task.wait(0.05)
                            end
                            break
                        end
                    end
                end

            elseif q.bugTarget then
                CurrentQuestTarget = "Eat: " .. q.bugTarget
                StatusLabel.Text = "Target: " .. CurrentQuestTarget .. "\nKoin Sesi Ini: +" .. tostring(SessionCoins)
                local bugsFolder = workspace:FindFirstChild("Bugs")
                if bugsFolder then
                    for _, bug in ipairs(bugsFolder:GetChildren()) do
                        if not Config.SmartQuest then break end
                        if string.find(string.lower(bug.Name), string.lower(q.bugTarget)) then
                            local bugHRP = bug:FindFirstChild("HumanoidRootPart") or bug:FindFirstChild("Body")
                            local bugHum = bug:FindFirstChild("Humanoid")
                            if bugHRP and bugHum and bugHum.Health > 0 then
                                while Config.SmartQuest and bug.Parent and bugHum.Health > 0 do
                                    local myHRP = getHRP()
                                    if not myHRP then break end
                                    myHRP.CFrame = bugHRP.CFrame * CFrame.new(0, 1.5, 2)
                                    myHRP.AssemblyLinearVelocity = Vector3.zero
                                    task.wait(0.05)
                                end
                                break
                            end
                        end
                    end
                end

            elseif q.needOrbs then
                CurrentQuestTarget = "Collect XP Orbs"
                StatusLabel.Text = "Target: " .. CurrentQuestTarget .. "\nKoin Sesi Ini: +" .. tostring(SessionCoins)
                local folder = workspace:FindFirstChild("Orbs")
                if folder then
                    for _, orb in ipairs(folder:GetChildren()) do
                        if not Config.SmartQuest then break end
                        local part = orb:IsA("BasePart") and orb or orb:FindFirstChildWhichIsA("BasePart")
                        if part then
                            hrp.CFrame = part.CFrame
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            if OrbRemote then pcall(function() OrbRemote:FireServer(orb) end) end
                            task.wait(0.08)
                        end
                    end
                end
            else
                CurrentQuestTarget = "Farming Umum (Bugs)"
                StatusLabel.Text = "Target: " .. CurrentQuestTarget .. "\nKoin Sesi Ini: +" .. tostring(SessionCoins)
            end
        end

        -- MODE 2: AUTO ORBS MANUAL
        if Config.AutoOrbs then
            for _, folderName in ipairs(orbFolders) do
                if not Config.AutoOrbs then break end
                local folder = workspace:FindFirstChild(folderName)
                if folder then
                    for _, orb in ipairs(folder:GetChildren()) do
                        if not Config.AutoOrbs then break end
                        local part = orb:IsA("BasePart") and orb or orb:FindFirstChildWhichIsA("BasePart")
                        if part and part.Parent then
                            hrp.CFrame = part.CFrame
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            if OrbRemote then pcall(function() OrbRemote:FireServer(orb) end) end
                            task.wait(0.08)
                        end
                    end
                end
            end
        end

        -- MODE 3: AUTO SEMUA BUGS (12-15 Koin per Kill)
        if Config.AutoBugs then
            local bugsFolder = workspace:FindFirstChild("Bugs")
            if bugsFolder then
                for _, bug in ipairs(bugsFolder:GetChildren()) do
                    if not Config.AutoBugs then break end
                    local bugHRP = bug:FindFirstChild("HumanoidRootPart") or bug:FindFirstChild("Body")
                    local bugHum = bug:FindFirstChild("Humanoid")
                    if bugHRP and bugHum and bugHum.Health > 0 then
                        while Config.AutoBugs and bug.Parent and bugHum.Health > 0 do
                            local myHRP = getHRP()
                            if not myHRP then break end
                            myHRP.CFrame = bugHRP.CFrame * CFrame.new(0, 1.5, 2)
                            myHRP.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.05)
                        end
                    end
                end
            end
        end

        -- MODE 4: AUTO SEMUA BREAKABLES (3-15 Koin per Break)
        if Config.AutoBreakables then
            local breakFolder = workspace:FindFirstChild("Breakables")
            if breakFolder then
                for _, item in ipairs(breakFolder:GetChildren()) do
                    if not Config.AutoBreakables then break end
                    local hitbox = item:FindFirstChild("Hitbox") or item:FindFirstChildWhichIsA("BasePart")
                    if hitbox then
                        while Config.AutoBreakables and item.Parent and hitbox.Parent do
                            local myHRP = getHRP()
                            if not myHRP then break end
                            myHRP.CFrame = hitbox.CFrame * CFrame.new(0, 1, 2)
                            myHRP.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end)
