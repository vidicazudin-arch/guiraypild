local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "c00lgui v3 | FINAL STAND",
   LoadingTitle = "Synchronizing Stand & Zero-G...",
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
local flySpeed, customWS = 50, 16
local originalGravity = workspace.Gravity
local flyConnection, frozenObjects = nil, {}

-- [[ EFFECTS & AUDIO ]] --
local stopEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
stopEffect.Enabled = false

local kcColor = Instance.new("ColorCorrectionEffect", game.Lighting)
kcColor.Enabled = false
kcColor.TintColor = Color3.fromRGB(180, 100, 255)

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
    char, hrp, hum = newChar, newChar:WaitForChild("HumanoidRootPart"), newChar:WaitForChild("Humanoid")
end)

-- [[ TABS ]] --
local MainTab = Window:CreateTab("Movement", 4483362458)
local WorldTab = Window:CreateTab("Stand Powers", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

--- ZERO-G SPECTATOR FLY ---
MainTab:CreateToggle({
    Name = "Zero-G Spectator Fly",
    CurrentValue = false,
    Callback = function(v)
        flying = v
        if flying then
            workspace.Gravity = 0
            hum.PlatformStand = true
            flyConnection = RunService.RenderStepped:Connect(function()
                if not flying or not hrp then return end
                local moveDir = Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                if moveDir.Magnitude > 0 then
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Camera.CFrame.LookVector) * CFrame.new(moveDir.Unit * (flySpeed / 10))
                else
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Camera.CFrame.LookVector)
                end
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
            workspace.Gravity = originalGravity
            hum.PlatformStand = false
        end
    end
})

MainTab:CreateSlider({Name = "Fly Speed", Range = {10, 300}, CurrentValue = 50, Callback = function(v) flySpeed = v end})

--- STAND ABILITIES ---
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
                        table.insert(frozenObjects, obj)
                    end
                end
            end
        else
            for _, obj in pairs(frozenObjects) do if obj and obj.Parent then obj.Anchored = false end end
            frozenObjects = {}
        end
end})

WorldTab:CreateSection("Diavolo: KING CRIMSON")
WorldTab:CreateButton({
    Name = "TIME ERASE (10s Visual & Sound)",
    Callback = function()
        if timeSkipping then return end
        timeSkipping = true
        kcStartSound:Play()
        playBlink()
        kcColor.Enabled = true
        
        local snapshot = {}
        local partsToHide = {}

        for _, pl in pairs(game.Players:GetPlayers()) do
            if pl ~= p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                snapshot[pl.UserId] = pl.Character.HumanoidRootPart.CFrame
            end
        end

        for _, v in pairs(char:GetDescendants()) do
            if (v:IsA("BasePart") or v:IsA("Decal")) and v.Transparency ~= 1 then
                v.Transparency = 1
                table.insert(partsToHide, v)
            end
        end
        hrp.CanCollide = false

        task.delay(10, function()
            playBlink()
            kcEndSound:Play()
            kcColor.Enabled = false
            for _, pl in pairs(game.Players:GetPlayers()) do
                if pl ~= p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    if snapshot[pl.UserId] then pl.Character.HumanoidRootPart.CFrame = snapshot[pl.UserId] end
                end
            end
            for _, v in pairs(partsToHide) do v.Transparency = 0 end
            hrp.CanCollide = true
            timeSkipping = false
            Rayfield:Notify({Title = "King Crimson", Content = "Waktu kembali normal!", Duration = 3})
        end)
    end
})

--- MISC ---
MiscTab:CreateButton({
    Name = "N4020 Super Boost",
    Callback = function()
        settings().Rendering.QualityLevel = 1
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = "SmoothPlastic" end
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end
})

Rayfield:LoadConfiguration()
