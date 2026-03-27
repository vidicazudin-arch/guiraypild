local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "c00lgui v1 | Rayfield All-In-One",
   LoadingTitle = "Loading Green Logic...",
   LoadingSubtitle = "Hardware: Axioo Hype 1 Optimized",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "C00L_Settings"
   },
   Theme = "Green", -- Keeping the green aesthetic from your source
})

-- Variables for Logic
local p = game.Players.LocalPlayer
local flying = false
local flySpeed = 50
local infJump = false

-- Tabs
local MainTab = Window:CreateTab("Movement", 4483362458)
local DoeTab = Window:CreateTab("John Doe FE", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

--- MOVEMENT SECTION ---
MainTab:CreateSection("Character Physics")

MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WS_Slider",
   Callback = function(Value)
      if p.Character and p.Character:FindFirstChild("Humanoid") then
          p.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 300},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JP_Slider",
   Callback = function(Value)
      if p.Character and p.Character:FindFirstChild("Humanoid") then
          p.Character.Humanoid.JumpPower = Value
      end
   end,
})

MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value)
       infJump = Value
       game:GetService("UserInputService").JumpRequest:Connect(function()
           if infJump and p.Character then
               p.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
           end
       end)
   end,
})

MainTab:CreateSection("Flight")

MainTab:CreateToggle({
   Name = "Fly Mode",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
       flying = Value
       local char = p.Character or p.CharacterAdded:Wait()
       local hrp = char:WaitForChild("HumanoidRootPart")
       
       if flying then
           local bv = Instance.new("BodyVelocity", hrp)
           bv.Name = "FlyVelocity"
           bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
           
           local bg = Instance.new("BodyGyro", hrp)
           bg.Name = "FlyGyro"
           bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
           bg.P = 9e4
           
           task.spawn(function()
               while flying do
                   local cam = workspace.CurrentCamera
                   bv.Velocity = cam.CFrame.LookVector * flySpeed
                   bg.CFrame = cam.CFrame
                   task.wait()
               end
               if bv then bv:Destroy() end
               if bg then bg:Destroy() end
           end)
       end
   end,
})

MainTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 300},
   Increment = 1,
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(v) flySpeed = v end,
})

--- JOHN DOE FE SECTION ---
DoeTab:CreateSection("Visible Transformation")

DoeTab:CreateButton({
   Name = "Become John Doe (FE Fixed)",
   Callback = function()
       local char = p.Character
       if not char then return end
       
       -- Strip current look
       for _, v in pairs(char:GetChildren()) do
           if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then
               v:Destroy()
           end
       end

       -- Apply Colors (Server Replicated via BodyColors)
       local colors = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", char)
       colors.HeadColor = BrickColor.new("Pastel yellow")
       colors.LeftArmColor = BrickColor.new("Pastel yellow")
       colors.RightArmColor = BrickColor.new("Pastel yellow")
       colors.TorsoColor = BrickColor.new("Bright blue")
       colors.LeftLegColor = BrickColor.new("Br. yellowish orange")
       colors.RightLegColor = BrickColor.new("Br. yellowish orange")

       -- Face
       if char.Head:FindFirstChild("face") then
           char.Head.face.Texture = "rbxassetid://27044081"
       end

       Rayfield:Notify({Title = "Success", Content = "John Doe mode active!", Duration = 3})
   end,
})

--- MISC SECTION ---
MiscTab:CreateSection("Utilities")

MiscTab:CreateButton({
   Name = "Fullbright",
   Callback = function()
       game:GetService("Lighting").Brightness = 2
       game:GetService("Lighting").ClockTime = 14
       game:GetService("Lighting").GlobalShadows = false
   end,
})

MiscTab:CreateButton({
   Name = "Destroy UI",
   Callback = function() Rayfield:Destroy() end,
})

Rayfield:LoadConfiguration()
