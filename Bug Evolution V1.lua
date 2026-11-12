-- Hapus GUI lama jika sudah ada agar tidak menumpuk
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local guiParent = (gethui and gethui()) or CoreGui
if guiParent:FindFirstChild("BugEvoFarmGUI") then
    guiParent.BugEvoFarmGUI:Destroy()
end

-- Variabel Toggle
local Config = {
    AutoOrbs = false,
    AutoBugs = false,
    AutoBreakables = false,
    AutoAttack = false,
    AutoAbility = false
}

-- Pembuatan UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BugEvoFarmGUI"
ScreenGui.Parent = guiParent
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 290)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Top Bar (Biru)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 110, 245)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Bug Evolution - Auto Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
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

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 44)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout", Container)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Fungsi Pembuat Tombol Toggle
local function CreateToggle(text, configKey, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(38, 42, 56)
    Btn.Text = text .. " : OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 205, 220)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 13
    Btn.LayoutOrder = order
    Btn.Parent = Container

    local BtnCorner = Instance.new("UICorner", Btn)
    BtnCorner.CornerRadius = UDim.new(0, 6)

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

CreateToggle("1. Auto Collect Orbs (Fast XP)", "AutoOrbs", 1)
CreateToggle("2. Auto Farm Bugs (NPC)", "AutoBugs", 2)
CreateToggle("3. Auto Farm Breakables", "AutoBreakables", 3)
CreateToggle("4. Auto Bite / Attack", "AutoAttack", 4)
CreateToggle("5. Auto Use Ability (Quest)", "AutoAbility", 5)

-- Fungsi Helper Karakter
local function getHRP()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

-- Loop 1: Auto Attack & Auto Ability via Remote
task.spawn(function()
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local AttackRemote = Remotes:FindFirstChild("Attack")
    local AbilityRemote = Remotes:FindFirstChild("UseAbility")

    while task.wait(0.15) do
        if Config.AutoAttack and AttackRemote then
            pcall(function()
                AttackRemote:FireServer()
            end)
        end
        if Config.AutoAbility and AbilityRemote then
            pcall(function()
                AbilityRemote:FireServer(1)
                AbilityRemote:FireServer()
            end)
        end
    end
end)

-- Loop 2: Pergerakan Auto-Farm (Orbs, Bugs, Breakables)
task.spawn(function()
    local orbFolders = {"RainbowOrbs", "Orbs", "VoidOrbs", "SandOrbs"}
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local OrbRemote = Remotes:FindFirstChild("OrbCollected")

    while task.wait(0.1) do
        local hrp = getHRP()
        if not hrp then continue end

        -- Prioritas 1: Auto Collect Orbs
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
                            if OrbRemote then
                                pcall(function() OrbRemote:FireServer(orb) end)
                            end
                            task.wait(0.08) -- Jeda aman agar tidak terkena rubberband/kick
                        end
                    end
                end
            end
        end

        -- Prioritas 2: Auto Farm Bugs (NPC)
        if Config.AutoBugs then
            local bugsFolder = workspace:FindFirstChild("Bugs")
            if bugsFolder then
                for _, bug in ipairs(bugsFolder:GetChildren()) do
                    if not Config.AutoBugs then break end
                    local bugHRP = bug:FindFirstChild("HumanoidRootPart") or bug:FindFirstChild("Body")
                    local bugHum = bug:FindFirstChild("Humanoid")

                    if bugHRP and bugHum and bugHum.Health > 0 then
                        -- Menempel di belakang/atas sedikit dari target sampai darahnya habis
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

        -- Prioritas 3: Auto Farm Breakables (Acorn, Silk Stash, dll)
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