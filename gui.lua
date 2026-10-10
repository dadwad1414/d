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

-- 🛑 التحقق من حالة التشغيل
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
CopyBtn.Text = "نسخ وتطبيق السكن ✨"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 14
CopyBtn.Font = Enum.Font.SourceSansBold
CopyBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = CopyBtn

--------------------------------------------------
-- ⚡ البحث المطور عن اللاعب ونسخ السكن
--------------------------------------------------

local function applySkinByName(nameQuery)
    if nameQuery == "" then return end
    
    local targetPlayer = nil
    local query = string.lower(nameQuery)
    
    -- بحث ذكي يشمل الاسم الحقيقي والاسم الظاهر
    for _, p in ipairs(Players:GetPlayers()) do
        local pName = string.lower(p.Name)
        local pDisplay = string.lower(p.DisplayName)
        
        if string.find(pName, query, 1, true) or string.find(pDisplay, query, 1, true) then
            targetPlayer = p
            break
        end
    end

    if targetPlayer and targetPlayer.Character then
        local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        local myHumanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

        if targetHumanoid and myHumanoid then
            local success, err = pcall(function()
                local description = targetHumanoid:GetAppliedDescription()
                myHumanoid:ApplyDescription(description)
            end)
            
            if success then
                CopyBtn.Text = "✅ تم نسخ سكن: " .. targetPlayer.DisplayName
            else
                CopyBtn.Text = "❌ فشل تطبيق السكن!"
            end
            task.wait(1.5)
            CopyBtn.Text = "نسخ وتطبيق السكن ✨"
        end
    else
        CopyBtn.Text = "❌ لم يتم العثور على اللاعب!"
        task.wait(1.5)
        CopyBtn.Text = "نسخ وتطبيق السكن ✨"
    end
end

CopyBtn.MouseButton1Click:Connect(function()
    applySkinByName(TextBox.Text)
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F2 then
        Frame.Visible = not Frame.Visible
    end
end)

print("✨ تم تحديث الواجهة بنجاح!")
