local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "c00lgui v1 | GOD STAND Edition",
   LoadingTitle = "Awakening Stand Powers...",
   LoadingSubtitle = "Hardware: Axioo N4020 Optimized",
   ConfigurationSaving = { Enabled = true, FolderName = "C00L_Settings" },
   Theme = "Green",
})

-- [[ GLOBAL VARIABLES ]] --
local p = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local flying, stealthFling, timeStopped, timeSkipping = false, false, false, false
local aimbotEnabled, showFOV = false, false
local flySpeed, customWS = 50, 16
local aimFOV, aimSmoothness, selectedPlayer = 150, 0, nil
local frozenPlayers, lockedObjects, storedPositions = {}, {}, {}

-- [[ EFFECTS & AUDIO SETUP ]] --
local stopEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
stopEffect.Enabled = false

local kcColor = Instance.new("ColorCorrectionEffect", game.Lighting)
kcColor.Enabled = false
kcColor.TintColor = Color3.fromRGB(180, 100, 255) -- Efek Ungu King Crimson

local kcStartSound = Instance.new("Sound", game.SoundService)
kcStartSound.SoundId = "rbxassetid://9113110134"
kcStartSound.Volume = 3

local kcEndSound = Instance.new("Sound", game.SoundService)
kcEndSound.SoundId = "rbxassetid://9113110294"
kcEndSound.Volume = 3

local function playBlink()
    local blink = Instance.new("ColorCorrectionEffect", game.Lighting)
    blink.Brightness = 1
    TweenService:Create(blink, TweenInfo.new(0.3), {Brightness = 0}):Play()
    game:GetService("Debris"):AddItem(blink, 0.4)
end

-- [[ CHARACTER LOGIC ]] --
local char = p.Character or p.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

p.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end)

-- [[ TABS SETUP ]] --
local MainTab = Window:CreateTab("Movement", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local WorldTab = Window:CreateTab("Stand Powers", 4483362458)
local PlayerTab = Window:CreateTab("Players", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

--- MOVEMENT ---
MainTab:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, CurrentValue = 16, Callback = function(v) customWS = v if hum then hum.WalkSpeed = v end end})
MainTab:CreateToggle({Name = "Fly Mode", CurrentValue = false, Callback = function(v) 
    flying = v 
    if flying then
        local bv = Instance.new("BodyVelocity", hrp) bv.MaxForce = Vector3.new(1,1,1) * math.huge
        local bg = Instance.new("BodyGyro", hrp) bg.MaxTorque = Vector3.new(1,1,1) * math.huge
        task.spawn(function()
            while flying and hrp do
                local dir = Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                bv.Velocity = dir.Unit * (dir.Magnitude > 0 and flySpeed or 0)
                bg.CFrame = Camera.CFrame task.wait()
            end
            if bv then bv:Destroy() end if bg then bg:Destroy() end
        end)
    end
end})

--- COMBAT ---
CombatTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) aimbotEnabled = v end})
CombatTab:CreateToggle({Name = "Stealth Fling", CurrentValue = false, Callback = function(v) 
    stealthFling = v
    task.spawn(function()
        while stealthFling do
            if hrp then
                local oldV = hrp.Velocity
                hrp.Velocity, hrp.RotVelocity = Vector3.new(0,35,0), Vector3.new(0,25000,0)
                RunService.Heartbeat:Wait() hrp.Velocity = oldV
            end
            task.wait()
        end
    end)
end})

--- STAND POWERS (THE WORLD & KING CRIMSON) ---
WorldTab:CreateSection("Dio: THE WORLD")
WorldTab:CreateToggle({
    Name = "TIME STOP (Physical Lock)", 
    CurrentValue = false, 
    Callback = function(v)
        timeStopped = v
        stopEffect.Enabled, stopEffect.Saturation = v, (v and -1 or 0)
        if v then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("ZA WARUDO!!!", "All")
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                    if (obj.Position - hrp.Position).Magnitude < 150 then
                        obj.Anchored = true
                        table.insert(lockedObjects, obj)
                    end
                end
            end
        else
            for _, obj in pairs(lockedObjects) do if obj and obj:IsA("BasePart") then obj.Anchored = false end end
            lockedObjects = {}
        end
end})

WorldTab:CreateSection("Diavolo: KING CRIMSON")
WorldTab:CreateButton({
    Name = "TIME ERASE (10s Visual & Sound)",
    Callback = function()
        if timeSkipping then return end
        timeSkipping = true
        
        -- Start Effect
        kcStartSound:Play()
        playBlink()
        kcColor.Enabled = true
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("KING CRIMSON!!!", "All")
        
        -- Snapshot
        table.clear(storedPositions)
        for _, pl in pairs(game.Players:GetPlayers()) do
            if pl ~= p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                storedPositions[pl.UserId] = pl.Character.HumanoidRootPart.CFrame
            end
        end

        -- Invisible
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then part.Transparency = 1 end
        end
        hrp.CanCollide = false

        task.delay(10, function()
            -- End Effect
            playBlink()
            kcEndSound:Play()
            kcColor.Enabled = false
            
            for _, pl in pairs(game.Players:GetPlayers()) do
                if pl ~= p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    if storedPositions[pl.UserId] then pl.Character.HumanoidRootPart.CFrame = storedPositions[pl.UserId] end
                end
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then part.Transparency = 0 end
            end
            hrp.CanCollide = true
            timeSkipping = false
            Rayfield:Notify({Title = "King Crimson", Content = "Waktu kembali normal!", Duration = 3})
        end)
    end
})

--- PLAYER TAB ---
local function getPlayers() local t = {} for _,v in pairs(game.Players:GetPlayers()) do if v ~= p then table.insert(t, v.Name) end end return t end
local Dropdown = PlayerTab:CreateDropdown({Name = "Target Player", Options = getPlayers(), Callback = function(o) selectedPlayer = game.Players:FindFirstChild(o) end})
PlayerTab:CreateButton({Name = "Freeze & Ice Box", Callback = function()
    if selectedPlayer and selectedPlayer.Character then
        local tHrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tHrp then
            frozenPlayers[selectedPlayer.UserId] = true
            local ice = Instance.new("Part", workspace) ice.Size = Vector3.new(6,9,6) ice.CFrame = tHrp.CFrame
            ice.Anchored, ice.Material, ice.Transparency, ice.Color = true, "Glass", 0.5, Color3.fromRGB(165, 242, 255)
            task.spawn(function() while frozenPlayers[selectedPlayer.UserId] and tHrp do tHrp.CFrame = ice.CFrame task.wait() end ice:Destroy() end)
        end
    end
end})

--- MISC ---
MiscTab:CreateButton({Name = "N4020 Boost", Callback = function()
    settings().Rendering.QualityLevel = 1
    for _,v in pairs(game:GetDescendants()) do if v:IsA("Part") then v.Material = "SmoothPlastic" end end
end})

-- [[ LOOPS ]] --
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target, dist = nil, aimFOV
        for _, pl in pairs(game.Players:GetPlayers()) do
            if pl ~= p and pl.Character and pl.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(pl.Character.Head.Position)
                local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if vis and d < dist then target, dist = pl.Character.Head, d end
            end
        end
        if target then
            local cf = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(cf, 1 - aimSmoothness)
        end
    end
end)

Rayfield:LoadConfiguration()
