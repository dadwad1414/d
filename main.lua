local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "War Tycoon Hub | تم صنعه من قبل ريان العنزي",
   LoadingTitle = "جاري التحميل...",
   LoadingSubtitle = "تم صنعه من قبل ريان العنزي",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- الخدمات الأساسية
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

---------------------------------------------------------
-- 1. تبويب الميزات القتالية والهيتبوكس (Combat & Hitbox)
---------------------------------------------------------
local CombatTab = Window:CreateTab("الميزات القتالية", 4483362458)

-- تكبير الهيتبوكس (Hitbox Expander)
local HitboxEnabled = false
local HitboxSize = 10
local HitboxTransparency = 0.7

CombatTab:CreateToggle({
   Name = "تفعيل تكبير الهيتبوكس (Hitbox)",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
       HitboxEnabled = Value
       if not Value then
           -- إعادة الأحجام الافتراضية
           for _, p in ipairs(Players:GetPlayers()) do
               if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                   p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                   p.Character.HumanoidRootPart.Transparency = 1
               end
           end
       end
   end,
})

CombatTab:CreateSlider({
   Name = "حجم الهيتبوكس (Hitbox Size)",
   Range = {2, 50},
   Increment = 1,
   Suffix = "Size",
   CurrentValue = 10,
   Flag = "HitboxSizeSlider",
   Callback = function(Value)
       HitboxSize = Value
   end,
})

-- حلقة تطبيق الهيتبوكس بأسلوب خفيف جداً (بدون لاج)
task.spawn(function()
    while task.wait(1) do
        if HitboxEnabled then
            pcall(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local root = p.Character.HumanoidRootPart
                        root.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        root.Transparency = HitboxTransparency
                        root.Color = Color3.fromRGB(255, 0, 0)
                        root.Material = Enum.Material.ForceField
                        root.CanCollide = false
                    end
                end
            end)
        end
    end
end)

-- نقطة التصويب وسط الشاشة (Crosshair Dot)
local CenterDotEnabled = false
local CenterDot = Drawing.new("Circle")
CenterDot.Visible = false
CenterDot.Radius = 3
CenterDot.Color = Color3.fromRGB(0, 255, 0)
CenterDot.Thickness = 1
CenterDot.Filled = true
CenterDot.Transparency = 1

CombatTab:CreateToggle({
   Name = "تفعيل نقطة الايم وسط الشاشة",
   CurrentValue = false,
   Flag = "CenterDotToggle",
   Callback = function(Value)
       CenterDotEnabled = Value
       CenterDot.Visible = Value
   end,
})

RunService.RenderStepped:Connect(function()
    if CenterDotEnabled then
        local viewportSize = Camera.ViewportSize
        CenterDot.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    end
end)

-- كشف اللاعبين عبر الجدران (ESP)
local ESPEnabled = false

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setupHighlight(character)
        if not character then return end
        if not character:FindFirstChild("CustomESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "CustomESP"
            highlight.Adornee = character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Enabled = ESPEnabled
            highlight.Parent = character
        end
    end
    if player.Character then setupHighlight(player.Character) end
    player.CharacterAdded:Connect(setupHighlight)
end

for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

CombatTab:CreateToggle({
   Name = "كشف اللاعبين عبر الجدران (ESP)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       ESPEnabled = Value
       for _, p in ipairs(Players:GetPlayers()) do
           if p.Character and p.Character:FindFirstChild("CustomESP") then
               p.Character.CustomESP.Enabled = Value
           end
       end
   end,
})

-- الايم بوت الخفيف (Smooth Aimbot)
local AimbotEnabled = false
local AimPart = "Head"
local FOVEnabled = false
local FOVRadius = 150

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

local function getClosestTarget()
    local target = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local part = player.Character:FindFirstChild(AimPart)
            
            if humanoid and humanoid.Health > 0 and part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDistance then
                        if not FOVEnabled or dist <= FOVRadius then
                            shortestDistance = dist
                            target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

CombatTab:CreateToggle({
   Name = "تفعيل الايم بوت (Aimbot)",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
       AimbotEnabled = Value
   end,
})

CombatTab:CreateDropdown({
   Name = "تحديد نقطة الايم",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = "Head",
   Flag = "AimPartDropdown",
   Callback = function(Option)
       AimPart = Option
   end,
})

CombatTab:CreateToggle({
   Name = "تفعيل دائرة الايم (FOV)",
   CurrentValue = false,
   Flag = "FOVToggle",
   Callback = function(Value)
       FOVEnabled = Value
       FOVCircle.Visible = Value
   end,
})

CombatTab:CreateSlider({
   Name = "حجم دائرة الايم",
   Range = {50, 500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 150,
   Flag = "FOVSlider",
   Callback = function(Value)
       FOVRadius = Value
       FOVCircle.Radius = Value
   end,
})

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos

    if AimbotEnabled then
        local targetPart = getClosestTarget()
        if targetPart then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), 0.25)
        end
    end
end)

---------------------------------------------------------
-- 2. تبويب الحركة والطيران (Movement)
---------------------------------------------------------
local MoveTab = Window:CreateTab("الحركة والطيران", 4483362458)

local flying = false
local flySpeed = 50
local flyBV, flyBG

MoveTab:CreateToggle({
   Name = "تفعيل الطيران",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
       flying = Value
       local char = LocalPlayer.Character
       if not char or not char:FindFirstChild("HumanoidRootPart") then return end
       local root = char.HumanoidRootPart
       local hum = char:FindFirstChildOfClass("Humanoid")

       if flying then
           if hum then hum.PlatformStand = true end
           flyBV = Instance.new("BodyVelocity")
           flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
           flyBV.Velocity = Vector3.new(0, 0, 0)
           flyBV.Parent = root

           flyBG = Instance.new("BodyGyro")
           flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
           flyBG.CFrame = Camera.CFrame
           flyBG.Parent = root

           task.spawn(function()
               while flying and char and root.Parent do
                   local moveDir = Vector3.new(0, 0, 0)
                   if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                   if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                   if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                   if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                   
                   flyBV.Velocity = moveDir * flySpeed
                   flyBG.CFrame = Camera.CFrame
                   task.wait()
               end
               if flyBV then flyBV:Destroy() end
               if flyBG then flyBG:Destroy() end
               if hum then hum.PlatformStand = false end
           end)
       else
           if flyBV then flyBV:Destroy() end
           if flyBG then flyBG:Destroy() end
           if hum then hum.PlatformStand = false end
       end
   end,
})

MoveTab:CreateSlider({
   Name = "سرعة الطيران",
   Range = {10, 300},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
       flySpeed = Value
   end,
})

MoveTab:CreateSlider({
   Name = "سرعة المشي (WalkSpeed)",
   Range = {16, 300},
   Increment = 2,
   Suffix = "Speed",
   CurrentValue = 16,
