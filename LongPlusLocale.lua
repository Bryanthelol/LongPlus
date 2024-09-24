-- Create locale structure
local GameLocale = GetLocale()
local void, Long_Plus = ...
local function localeFunc(L, key) return key end
local L = setmetatable({}, { __index = localeFunc })
Long_Plus.L = L


if GameLocale == "zhCN" then
    L["Version"] = "版本"
    L["Reload"] = "重载插件"
    L["Requires UI reload."] = "需要重载插件"
    L["Your UI needs to be reloaded."] = "你的插件需要重新载入。"
    L["Your UI needs to be reloaded for some of the changes to take effect.|n|nYou don't have to click the reload button immediately but you do need to click it when you are done making changes and you want the changes to take effect."] = "你需要进行重载插件后才能使部分设置生效。|n|n你无需立即点击重载插件按钮，但是你完成设置并希望其生效时，必须点击它。"

    L["Home"] = "主页"
    L["Welcome to Long Plus."] = "欢迎使用 Long Plus"
    L["To begin, choose an options page."] = "请选择一项开始使用"
    L["Support"] = "帮助支持"

    L["Nameplate"] = "姓名板"
    L["Friendly Nameplate Health Bar"] = "友方姓名板血条"
    L["Hide Friendly Unit Health Bar"] = "隐藏友方血条"
    L["Health bars will only be displayed for targetable enemies."] = "只有可攻击目标才会显示血条。"
    L["Friendly Nameplate Width"] = "友方姓名板宽度"
    L["Drag to set the width of friendly nameplate."] = "拖动以设置友方姓名板的宽度。"
end
