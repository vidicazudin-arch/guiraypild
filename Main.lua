local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "c00lgui v4 | STAND OVERHEAVEN",
   LoadingTitle = "Synchronizing Stand...",
   LoadingSubtitle = "King Crimson + The World",
   ConfigurationSaving = { Enabled = true, FolderName = "C00L_Settings" },
   Theme = "Green",
})

-- SERVICES
local p = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- CHARACTER
local function getChar()
    local c = p.Character or p.CharacterAdded:Wait()
    return c, c:WaitForChild("HumanoidRootPart"), c:WaitForChild("Humanoid")
end

local char, hrp, hum = getChar()

p.CharacterAdded:Connect(function()
    char, hrp, hum = getChar()
end)

-- VAR
local flying = false
local flySpeed = 50
local flyBV, flyBG

local timeStopped = false
local frozenPlayers = {}

local timeSkipping = false

-- UI
local MainTab = Window:CreateTab("Movement", 4483362458)
local WorldTab = Window:CreateTab("Stand Powers", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

--------------------------------------------------
-- ✈️ FLY (FIXED)
--------------------------------------------------
MainTab:CreateToggle({
    Name = "Zero-G Fly",
    CurrentValue = false,
    Callback = function(v)
        flying = v

        if flying then
            flyBV = Instance.new("BodyVelocity", hrp)
            flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)

            flyBG = Instance.new("BodyGyro", hrp)
            flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)

            hum.PlatformStand = true

            RunService:BindToRenderStep("Fly", 0, function()
                local dir = Vector3.zero

                if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

                flyBV.Velocity = (dir.Magnitude > 0) and dir.Unit * flySpeed or Vector3.zero
                flyBG.CFrame = Camera.CFrame
            end)

        else
            RunService:UnbindFromRenderStep("Fly")
            if flyBV then flyBV:Destroy() end
            if flyBG then flyBG:Destroy() end
            hum.PlatformStand = false
        end
    end
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10,300},
    CurrentValue = 50,
    Callback = function(v)
        flySpeed = v
    end
})

--------------------------------------------------
-- ⏱️ TIME STOP
--------------------------------------------------
WorldTab:CreateSection("THE WORLD")

WorldTab:CreateToggle({
    Name = "Time Stop",
    CurrentValue = false,
    Callback = function(v)
        timeStopped = v

        if v then
            for _,plr in pairs(game.Players:GetPlayers()) do
                if plr ~= p and plr.Character then
                    local h = plr.Character:FindFirstChild("Humanoid")
                    if h then
                        frozenPlayers[plr] = {ws = h.WalkSpeed, jp = h.JumpPower}
                        h.WalkSpeed = 0
                        h.JumpPower = 0
                    end
                end
            end
        else
            for plr,data in pairs(frozenPlayers) do
                if plr.Character then
                    local h = plr.Character:FindFirstChild("Humanoid")
                    if h then
                        h.WalkSpeed = data.ws
                        h.JumpPower = data.jp
                    end
                end
            end
            frozenPlayers = {}
        end
    end
})

--------------------------------------------------
-- 😈 KING CRIMSON (ANIME)
--------------------------------------------------
WorldTab:CreateSection("KING CRIMSON")

WorldTab:CreateButton({
    Name = "Time Erase (Anime Mode)",
    Callback = function()
        if timeSkipping then return end
        timeSkipping = true

        local snapshot = {}
        local ghostParts = {}
        local clone

        -- SAVE POS
        for _,plr in pairs(game.Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                snapshot[plr] = plr.Character.HumanoidRootPart.CFrame
            end
        end

        -- CLONE
        clone = char:Clone()
        clone.Parent = workspace

        for _,v in pairs(clone:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Anchored = true
                v.CanCollide = false
                v.Transparency = 0.5
                v.Color = Color3.fromRGB(255,0,0)
            end
        end

        -- GHOST
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0.6
                v.CanCollide = false
                table.insert(ghostParts, v)
            end
        end

        -- EFFECT
        local cc = Instance.new("ColorCorrectionEffect", game.Lighting)
        cc.TintColor = Color3.fromRGB(255,50,50)

        -- DASH
        local dash
        dash = RunService.RenderStepped:Connect(function()
            if not timeSkipping then return end
            hrp.CFrame = hrp.CFrame * CFrame.new(0,0,-2)
        end)

        task.delay(10, function()

            if dash then dash:Disconnect() end

            -- RESET OTHERS
            for plr,cf in pairs(snapshot) do
                if plr ~= p and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = cf
                end
            end

            if clone then clone:Destroy() end

            for _,v in pairs(ghostParts) do
                if v then
                    v.Transparency = 0
                    v.CanCollide = true
                end
            end

            cc:Destroy()
            timeSkipping = false

            Rayfield:Notify({
                Title = "King Crimson",
                Content = "Time erased. Only you moved.",
                Duration = 4
            })
        end)
    end
})

--------------------------------------------------
-- ⚙️ BOOST
--------------------------------------------------
MiscTab:CreateButton({
    Name = "N4020 Boost",
    Callback = function()
        settings().Rendering.QualityLevel = 1
        for _,v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
    end
})

Rayfield:LoadConfiguration()
