local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "c00lgui v1 | Rayfield Edition",
   LoadingTitle = "Initializing Green Logic",
   LoadingSubtitle = "Hardware: Axioo Hype 1 Optimized",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "C00L_Settings"
   },
   Theme = "Green",
})

local MainTab = Window:CreateTab("Home", 4483362458)
local Section = MainTab:CreateSection("Movement & Stats")

-- Speed Logic
MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WS",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

-- Jump Logic
MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 300},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JP",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

-- Inf Jump Logic (Ported from Source)
MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
       _G.InfJump = Value
       game:GetService("UserInputService").JumpRequest:Connect(function()
           if _G.InfJump then
               game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
           end
       end)
   end,
})

Rayfield:Notify({
   Title = "Script Loaded",
   Content = "Your custom UI is now active.",
   Duration = 5,
})
