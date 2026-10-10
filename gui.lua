local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- 🔗 رابط ملف status.json المباشر الخاص بك
local statusUrl = "https://raw.githubusercontent.com/dadwad1414/d/main/status.json"

local function checkStatus()
    local success, response = pcall(function()
        return game:HttpGet(statusUrl)
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        if not data.enabled then
            warn("⚠️ السكربت معطل حالياً من قبل المطور. السبب: " .. tostring(data.reason))
            return false
        end
        return true
    else
        warn("❌ فشل التحقق من حالة السكربت.")
        return false
    end
end

if not checkStatus() then
    return
end

--------------------------------------------------
-- 🎨 إنشاء واجهة المستخدم (GUI)
--------------------------------------------------

if CoreGui:FindFirstChild("SkinChangerGui") then
    CoreGui.SkinChangerGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkinChangerGui"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 150)
Frame.Position = UDim2.new(0.5, -130, 0.4, -75)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "👕 ناسخ السكنات (F2 للإخفاء)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.85, 0, 0, 35)
TextBox.Position = UDim2.new(0.075, 0, 0.32, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TextBox.PlaceholderText = "اكتب اسم اللاعب أو ID..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
TextBox.TextSize = 14
TextBox.Font = Enum.Font.SourceSans
TextBox.Parent = Frame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = TextBox

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.85, 0, 0, 35)
CopyBtn.Position = UDim2.new(0.075, 0, 0.65, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 232)
CopyBtn.Text = "نسخ السكن بالكامل ✨"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 14
CopyBtn.Font = Enum.Font.SourceSansBold
CopyBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = CopyBtn

--------------------------------------------------
-- ⚡ دالة جلب وتطبيق السكن الشامل (شعر، فيس، ملامح، ملابس)
--------------------------------------------------

local function applyFullSkinByUserId(targetUserId, displayName)
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    if not myHumanoid then return false end

    -- 1. محاولة جلب السكن الكامل عن طريق سيرفرات روبلوكس (يجلب الشعر، الفيس، الملامح، الجسم والإكسسوارات)
    local success, err = pcall(function()
        local humDesc = Players:GetHumanoidDescriptionFromUserId(targetUserId)
        if humDesc then
            myHumanoid:ApplyDescription(humDesc)
        end
    end)

    -- 2. خطة بديلة (إذا منع النظام التطبيق، نقوم بنسخ الكاراكتر المباشر إن وجد في السيرفر)
    if not success then
        local targetPlayer = Players:GetPlayerByUserId(targetUserId)
        if targetPlayer and targetPlayer.Character then
            local targetChar = targetPlayer.Character
            local myHead = myChar:FindFirstChild("Head")
            local targetHead = targetChar:FindFirstChild("Head")
            
            -- تنظيف القديم
            for _, child in ipairs(myChar:GetChildren()) do
                if child:IsA("Clothing") or child:IsA("ShirtGraphic") or child:IsA("Accessory") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
                    child:Destroy()
                end
            end
            
            -- نسخ الفيس والملامح
            if myHead and targetHead then
                local targetFace = targetHead:FindFirstChildOfClass("Decal") or targetHead:FindFirstChildOfClass("Texture")
                if targetFace then
                    local myFace = myHead:FindFirstChildOfClass("Decal") or myHead:FindFirstChildOfClass("Facing")
                    if myFace then myFace:Destroy() end
                    targetFace:Clone().Parent = myHead
                end
            end
            
            -- نسخ الشعر والإكسسوارات والملابس
            for _, child in ipairs(targetChar:GetChildren()) do
                if child:IsA("Clothing") or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") or child:IsA("Accessory") then
                    child:Clone().Parent = myChar
                end
            end
            success = true
        end
    end

    return success
end

local function processInput(inputName)
    inputName = inputName:match("^%s*(.-)%s*$")
    if inputName == "" then return end
    
    -- التحقق إذا كان المدخل رقم (UserId مباشر لشخص حتى لو مو معك بالسيرفر)
    if tonumber(inputName) then
        local targetUserId = tonumber(inputName)
        CopyBtn.Text = "⏳ جاري جلب السكن..."
        
        task.spawn(function()
            local success = pcall(function()
                applyFullSkinByUserId(targetUserId, tostring(targetUserId))
            end)
            
            if success then
                CopyBtn.Text = "✅ تم تطبيق السكن بنجاح!"
            else
                CopyBtn.Text = "❌ فشل جلب السكن (تأكد من الـ ID)!"
            end
            task.wait(1.5)
            CopyBtn.Text = "نسخ السكن بالكامل ✨"
        end)
        return
    end
    
    -- البحث عن اللاعب في السيرفر الحالي (بالاسم أو النك نيم)
    local targetPlayer = nil
    local query = string.lower(inputName)
    
    for _, p in ipairs(Players:GetPlayers()) do
        local pName = string.lower(p.Name)
        local pDisplay = string.lower(p.DisplayName)
        
        if string.find(pName, query, 1, true) or string.find(pDisplay, query, 1, true) then
            targetPlayer = p
            break
        end
    end

    if targetPlayer then
        local success = applyFullSkinByUserId(targetPlayer.UserId, targetPlayer.DisplayName)
        if success then
            CopyBtn.Text = "✅ تم نسخ سكن: " .. targetPlayer.DisplayName
        else
            CopyBtn.Text = "❌ فشل تطبيق السكن!"
        end
    else
        CopyBtn.Text = "❌ اللاعب غير موجود بالسيرفر!"
    end
    
    task.wait(1.5)
    CopyBtn.Text = "نسخ السكن بالكامل ✨"
end

CopyBtn.MouseButton1Click:Connect(function()
    processInput(TextBox.Text)
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F2 then
        Frame.Visible = not Frame.Visible
    end
end)

print("✨ تم تحديث السكربت لنسخ السكن الكامل ودعم الـ ID للاعبين خارج السيرفر!")
