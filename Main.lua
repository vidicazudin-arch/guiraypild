local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "c00lgui v1 | THE WORLD FINAL",
   LoadingTitle = "Awakening Stand Power...",
   LoadingSubtitle = "Hardware: Axioo N4020 Optimized",
   ConfigurationSaving = { Enabled = true, FolderName = "C00L_Settings" },
   Theme = "Green",
})

-- [[ GLOBAL VARIABLES ]] --
local p = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local flying, stealthFling, orbiting, noclip, autoClick, timeStopped = false, false, false, false, false, false
local aimbotEnabled, showFOV = false, false
local flySpeed, orbitRadius, orbitSpeed, customWS = 50, 10, 5, 16
local aimFOV, aimSmoothness, selectedPlayer = 150, 0, nil
local auraEnabled, auraColor, auraSpeed = false, Color3.fromRGB(0, 255, 0), 5
local frozenPlayers = {}
local lockedObjects = {} -- Untuk Time Stop

-- [[ PHYSICS & RECONNECT LOGIC ]] --
local char = p.Character or p.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

p.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = customWS
    if auraEnabled then createAura() end
end)

-- [[ VISUALS & EFFECTS ]] --
local stopEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
stopEffect.Enabled = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness, FOVCircle.Transparency, FOVCircle.Filled = 1, 0.7, false
FOVCircle.Color = Color3.fromRGB(0, 255, 0)

function createAura()
    if hrp:FindFirstChild("MyAura") then hrp.MyAura:Destroy() end
    local att = Instance.new("Attachment", hrp) att.Name = "MyAura"
    local part = Instance.new("ParticleEmitter", att)
    part.Texture = "rbxassetid://2430536442"
    part.Color = ColorSequence.new(auraColor)
    part.Rate, part.Speed = 50, NumberRange.new(auraSpeed)
    part.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)})
    part.Enabled = auraEnabled
end

-- [[ TABS SETUP ]] --
local MainTab = Window:CreateTab("Movement", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local PlayerTab = Window:CreateTab("Players", 4483362458)
local WorldTab = Window:CreateTab("World", 4483362458)
local AuraTab = Window:CreateTab("Aura", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

--- MOVEMENT SECTION ---
MainTab:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, CurrentValue = 16, Callback = function(v) customWS = v if hum then hum.WalkSpeed = v end end})
MainTab:CreateToggle({Name = "Fly Mode (WASD)", CurrentValue = false, Callback = function(v) 
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

--- COMBAT (AIMBOT & FLING) ---
CombatTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) aimbotEnabled = v end})
CombatTab:CreateToggle({Name = "Show FOV", CurrentValue = false, Callback = function(v) showFOV = v end})
CombatTab:CreateSlider({Name = "Aimbot Smoothness", Range = {0, 1}, CurrentValue = 0, Callback = function(v) aimSmoothness = v end})
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

--- WORLD (PHYSICAL TIME STOP) ---
WorldTab:CreateToggle({
    Name = "PHYSICAL TIME STOP (ZA WARUDO)", 
    CurrentValue = false, 
    Callback = function(v)
        timeStopped = v
        stopEffect.Enabled, stopEffect.Saturation = v, (v and -1 or 0)
        
        if v then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("ZA WARUDO!!!", "All")
            local s = Instance.new("Part", workspace) s.Shape, s.Material, s.Transparency = "Ball", "ForceField", 0.5
            s.Anchored, s.CanCollide, s.Position, s.Size = true, false, hrp.Position, Vector3.new(1,1,1)
            task.spawn(function() for i=1,25 do s.Size = s.Size + Vector3.new(4,4,4) s.Transparency = s.Transparency + 0.02 task.wait(0.01) end s:Destroy() end)
            
            -- Lock Players & Objects (Radius 150)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                    if (obj.Position - hrp.Position).Magnitude < 150 then
                        obj.Anchored = true
                        table.insert(lockedObjects, obj)
                    end
                end
            end
            Rayfield:Notify({Title = "ZA WARUDO", Content = "Semua objek & player dihentikan!", Duration = 3})
        else
            for _, obj in pairs(lockedObjects) do if obj and obj:IsA("BasePart") then obj.Anchored = false end end
            lockedObjects = {}
            Rayfield:Notify({Title = "Time Resumes", Content = "Objek kembali bergerak.", Duration = 2})
        end
end})

--- PLAYER TAB (LIST & FREEZE) ---
local function getPlayers() local t = {} for _,v in pairs(game.Players:GetPlayers()) do if v ~= p then table.insert(t, v.Name) end end return t end
local Dropdown = PlayerTab:CreateDropdown({Name = "Target Player", Options = getPlayers(), Callback = function(o) selectedPlayer = game.Players:FindFirstChild(o) end})
PlayerTab:CreateButton({Name = "Refresh List", Callback = function() Dropdown:Set(getPlayers()) end})
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
PlayerTab:CreateButton({Name = "Unfreeze", Callback = function() if selectedPlayer then frozenPlayers[selectedPlayer.UserId] = false end end})

--- AURA TAB ---
AuraTab:CreateToggle({Name = "Aura On/Off", CurrentValue = false, Callback = function(v) auraEnabled = v createAura() end})
AuraTab:CreateColorPicker({Name = "Aura Color", Color = Color3.fromRGB(0,255,0), Callback = function(v) auraColor = v createAura() end})

--- MISC (OPTIMIZATION) ---
MiscTab:CreateButton({Name = "N4020 Hardware Boost", Callback = function()
    for _,v in pairs(game:GetDescendants()) do if v:IsA("Part") or v:IsA("MeshPart") then v.Material, v.Reflectance = "SmoothPlastic", 0 end end
    settings().Rendering.QualityLevel = 1
    Rayfield:Notify({Title = "Boost", Content = "Grafis diturunkan untuk performa N4020", Duration = 2})
end})

-- [[ RUNTIME LOOPS ]] --
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible, FOVCircle.Radius = showFOV, aimFOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if aimbotEnabled then
        local target, dist = nil, aimFOV
        for _, pl in pairs(game.Players:GetPlayers()) do
            if pl ~= p and pl.Character and pl.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(pl.Character.Head.Position)
                local d = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                if vis and d < dist then target, dist = pl.Character.Head, d end
            end
        end
        if target then
            local cf = CFrame.new(Camera.CFrame.Position, target.Position)
             Camera.CFrame = aimSmoothness == 0 and cf or Camera.CFrame:Lerp(cf, 1 - aimSmoothness)
        end
    end
end)

Rayfield:LoadConfiguration()
