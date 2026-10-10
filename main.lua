local HttpService = game:GetService("HttpService")

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

-- 🛑 التحقق من حالة التشغيل قبل بدء السكربت
if not checkStatus() then
    return
end

--------------------------------------------------
-- 🎮 كود الهيدبوكس الخاص بك
--------------------------------------------------

-- ⚙️ الاعدادات — عدل هنا كما تريد
local TOGGLE_KEY = Enum.KeyCode.B    -- زر التشغيل/الإيقاف الحالي: B غيره لو تبي حرف ثاني
local HITBOX_SIZE = 3.0       -- حجم الهيدبوكس اللي طلبته
local KEEP_HEAD_NORMAL = true        -- يخلي شكل الراس ظاهر وطبيعي دائمًا ✅

-- 🚀 لا تعدل تحت هذا السطر
local Enabled = false
local Original = {}

game:GetService("RunService").RenderStepped:Connect(function()
    if not Enabled then return end
    for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
        if v == game.Players.LocalPlayer or not v.Character or not v.Character:FindFirstChild("Head") then continue end
        local Head = v.Character.Head
        if not Original[v.UserId] then
            Original[v.UserId] = {Size=Head.Size, Transparency=Head.Transparency, CanCollide=Head.CanCollide}
        end
        -- حجم المنطقة اللي تضربها فقط
        Head.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
        -- ✅ مهم: شكل الراس يبقى طبيعي ومخفيش عينيا أحد
        Head.Transparency = Original[v.UserId].Transparency
        Head.CanCollide = false
        local Mesh=Head:FindFirstChildWhichIsA("SpecialMesh")
        if Mesh then Mesh.Scale=Vector3.one end
    end
end)

-- ⏹️ لما تطفيه يرجع كل شي زي ما كان
function RestoreAll()
    for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") and Original[v.UserId] then
            local Head=v.Character.Head
            Head.Size=Original[v.UserId].Size
            Head.Transparency=Original[v.UserId].Transparency
            Head.CanCollide=Original[v.UserId].CanCollide
        end
    end
end

-- ⌨️ زر التشغيل والإيقاف
game:GetService("UserInputService").InputBegan:Connect(function(Input, GP)
    if GP or Input.KeyCode~=TOGGLE_KEY then return end
    Enabled=not Enabled
    if not Enabled then RestoreAll() end
end)

print("تم تشغيل سكربت الهيدبوكس بنجاح!")
