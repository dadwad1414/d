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
            warn("⚠️ السكربت معطل حالياً من قبل المطور.")
            return false
        end
        return true
    else
        return false
    end
end

if not checkStatus() then return end

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
TextBox.PlaceholderText = "اكتب اسم اللاعب هنا..."
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
CopyBtn.Text = "نسخ الشعر والإكسسوارات ✨"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 14
CopyBtn.Font = Enum.Font.SourceSansBold
CopyBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = CopyBtn

--------------------------------------------------
-- ⚡ النسخ اليدوي القوي للشعر، الإكسسوارات، الرأس، والملابس
--------------------------------------------------

local function forceCopyFullSkin(targetPlayer)
    local myChar = LocalPlayer.Character
    local targetChar = targetPlayer.Character
    if not myChar or not targetChar then return false end
    
    -- 1. تنظيف السكن القديم تماماً (ملابس، إكسسوارات، شعر)
    for _, child in ipairs(myChar:GetChildren()) do
        if child:IsA("Clothing") or child:IsA("ShirtGraphic") or child:IsA("Accessory") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
            child:Destroy()
        end
    end

    -- 2. نسخ رأس الشخصية وملامحه إن وجد
    local myHead = myChar:FindFirstChild("Head")
    local targetHead = targetChar:FindFirstChild("Head")
    if myHead and targetHead then
        -- حذف الوجه القديم ونسخ الجديد
        for _, v in ipairs(myHead:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SpecialMesh") then
                v:Destroy()
            end
        end
        for _, v in ipairs(targetHead:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SpecialMesh") then
                v:Clone().Parent = myHead
            end
        end
    end

    -- 3. نسخ جميع الإكسسوارات (بما فيها الشعر، القبعات، النظارات، والملحقات)
    for _, child in ipairs(targetChar:GetChildren()) do
        if child:IsA("Accessory") then
            local cloneAcc = child:Clone()
            -- التأكد من تفعيل الأجزاء الداخلية للإكسسوار لضمان ظهور الشعر
            for _, part in ipairs(cloneAcc:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0
                end
            end
            cloneAcc.Parent = myChar
        elseif child:IsA("Clothing") or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
            child:Clone().Parent = myChar
        end
    end

    return true
end

local function applySkinByName(nameQuery)
    nameQuery = nameQuery:match("^%s*(.-)%s*$")
    if nameQuery == "" then return end
    
    local targetPlayer = nil
    local query = string.lower(nameQuery)
    
    for _, p in ipairs(Players:GetPlayers()) do
        local pName = string.lower(p.Name)
        local pDisplay = string.lower(p.DisplayName)
        
        if string.find(pName, query, 1, true) or string.find(pDisplay, query, 1, true) then
            targetPlayer = p
            break
        end
    end

    if targetPlayer and targetPlayer.Character then
        local success = forceCopyFullSkin(targetPlayer)
        if success then
            CopyBtn.Text = "✅ تم نسخ الشعر والإكسسوارات!"
        else
            CopyBtn.Text = "❌ فشل تطبيق النسخ!"
        end
    else
        CopyBtn.Text = "❌ اللاعب غير موجود بالسيرفر!"
    end
    
    task.wait(1.5)
    CopyBtn.Text = "نسخ الشعر والإكسسوارات ✨"
end

CopyBtn.MouseButton1Click:Connect(function()
    applySkinByName(TextBox.Text)
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F2 then
        Frame.Visible = not Frame.Visible
    end
end)

print("✨ تم تحديث السكربت لنسخ الشعر والإكسسوارات بدقة!")
