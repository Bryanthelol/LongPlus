--	Long Plus 0.0.1
----------------------------------------------------------------------

----------------------------------------------------------------------
--	Initialise variables
----------------------------------------------------------------------

-- Globale Table
_G.LongPlusDB = _G.LongPlusDB or {}
for k, v in pairs(_G.LongPlusDB) do
    print(k, v)
end

-- Locals
local LongPlusLC, LongPlusCB, LongConfigList = {}, {}, {}
local GameLocale = GetLocale()
local void

-- Version
LongPlusLC["AddonVer"] = "0.0.1"

-- Get locale table
local void, Long_Plus = ...
local L = Long_Plus.L

LongPlusLC["ShowErrorsFlag"] = 1
LongPlusLC["NumberOfPages"] = 1

----------------------------------------------------------------------
--	Event Handler
----------------------------------------------------------------------

-- Create event frame
local LpEvt = CreateFrame("FRAME")
LpEvt:RegisterEvent("ADDON_LOADED")
LpEvt:RegisterEvent("PLAYER_LOGIN")

-- Event handler
local function eventHandler(self, event, arg1, arg2, ...)
    if event == "ADDON_LOADED" then
        if arg1 == "LongPlus" then
            -- Friendly Nameplate Health Bar
            LongPlusLC:LoadVarChk("FriendlyNameplateHealthBar", "On")

            -- Panel position
            LongPlusLC:LoadVarAnc("MainPanelA", "CENTER")       -- Panel anchor
            LongPlusLC:LoadVarAnc("MainPanelR", "CENTER")       -- Panel relative
            LongPlusLC:LoadVarNum("MainPanelX", 0, -5000, 5000) -- Panel X axis
            LongPlusLC:LoadVarNum("MainPanelY", 0, -5000, 5000) -- Panel Y axis

            -- Start page
            LongPlusLC:LoadVarNum("LongStartPage", 0, 0, LongPlusLC["NumberOfPages"])

            -- Run other startup items
            LongPlusLC:SetDim()
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        LongPlusLC:Player()
        collectgarbage()
        return
    end

    -- Save locals back to globals on logout
    if event == "PLAYER_LOGOUT" then
        -- Run the logout function without wipe flag
        LongPlusLC:PlayerLogout(false)

        -- Friendly Nameplate Health Bar
        LongPlusDB["FriendlyNameplateHealthBar"] = LongPlusLC["FriendlyNameplateHealthBar"]
        
        -- Panel position
        LongPlusDB["MainPanelA"] = LongPlusLC["MainPanelA"]
        LongPlusDB["MainPanelR"] = LongPlusLC["MainPanelR"]
        LongPlusDB["MainPanelX"] = LongPlusLC["MainPanelX"]
        LongPlusDB["MainPanelY"] = LongPlusLC["MainPanelY"]

        -- Start page
        LongPlusDB["LongStartPage"] = LongPlusLC["LongStartPage"]
    end
end
--	Register event handler
LpEvt:SetScript("OnEvent", eventHandler)

----------------------------------------------------------------------
--	Locks
----------------------------------------------------------------------

-- Function to set lock state for configuration buttons
function LongPlusLC:LockOption(option, item, reloadreq)
    if reloadreq then
        -- Option change requires UI reload
        if LongPlusLC[option] ~= LongPlusDB[option] or LongPlusLC[option] == "Off" then
            LongPlusLC:LockItem(LongPlusCB[item], true)
        else
            LongPlusLC:LockItem(LongPlusCB[item], false)
        end
    else
        -- Option change does not require UI reload
        if LongPlusLC[option] == "Off" then
            LongPlusLC:LockItem(LongPlusCB[item], true)
        else
            LongPlusLC:LockItem(LongPlusCB[item], false)
        end
    end
end

--	Set lock state for configuration buttons
function LongPlusLC:SetDim()
    -- LongPlusLC:LockOption("AutoSellJunk", "AutoSellJunkBtn", true)                -- Sell junk automatically
end

----------------------------------------------------------------------
-- Restarts
----------------------------------------------------------------------

-- Set the reload button state
function LongPlusLC:ReloadCheck()

    -- Nameplate
    if (LongPlusLC["FriendlyNameplateHealthBar"] ~= LongPlusDB["FriendlyNameplateHealthBar"])   -- Friendly Nameplate Health Bar
    then
        -- Enable the reload button
        LongPlusLC:LockItem(LongPlusCB["ReloadUIButton"], false)
        LongPlusCB["ReloadUIButton"].f:Show()
    else
        -- Disable the reload button
        LongPlusLC:LockItem(LongPlusCB["ReloadUIButton"], true)
        LongPlusCB["ReloadUIButton"].f:Hide()
    end

end

----------------------------------------------------------------------
--	Player
----------------------------------------------------------------------
function LongPlusLC:Player()

    ----------------------------------------------------------------------
    -- Friendly Nameplate Health Bar
    ----------------------------------------------------------------------
    do
        local function NameplateShowOnlyNames()
            if LongPlusLC["FriendlyNameplateHealthBar"] == "On" then
                C_NamePlate.SetNamePlateFriendlyClickThrough(true)
            else
                C_NamePlate.SetNamePlateFriendlyClickThrough(false)
            end
        end
        LongPlusCB["FriendlyNameplateHealthBar"]:HookScript("OnClick", NameplateShowOnlyNames)
        if LongPlusLC["FriendlyNameplateHealthBar"] == "On" then
            NameplateShowOnlyNames()
        end
    end

    ----------------------------------------------------------------------
    -- minimap button
    ----------------------------------------------------------------------
    do
        -- Minimap button click function
        local function MiniBtnClickFunc(arg1, arg2)
            if arg1 == "Long_Plus" then arg1 = "LeftButton" end -- Needed for compartment menu clicks

            -- Prevent options panel from showing if Blizzard Store is showing
            if StoreFrame and StoreFrame:GetAttribute("isshown") then return end

            -- Left button down
            if arg1 == "LeftButton" or arg2 and arg2 == "LeftButton" then
                if LongPlusLC:IsPlusShowing() then
                    LongPlusLC:HideFrames()
                    LongPlusLC:HideConfigPanels()
                else
                    LongPlusLC:HideFrames()
                    LongPlusLC["PageF"]:Show()
                end
                LongPlusLC["Page" .. LongPlusLC["LongStartPage"]]:Show()
            end

            -- Right button down
            if arg1 == "RightButton" or arg2 and arg2 == "RightButton" then
                if LongPlusLC:IsPlusShowing() then
                    LongPlusLC:HideFrames()
                    LongPlusLC:HideConfigPanels()
                else
                    LongPlusLC:HideFrames()
                    LongPlusLC["PageF"]:Show()
                end
                LongPlusLC["Page" .. LongPlusLC["LongStartPage"]]:Show()
            end
        end

        -- Assign global scope for function (it's used in TOC)
        _G.LongPlusGlobalMiniBtnClickFunc = MiniBtnClickFunc

        -- Create minimap button using LibDBIcon
        local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("Long_Plus", {
            type = "data source",
            text = "Long Plus",
            icon = "Interface\\HELPFRAME\\ReportLagIcon-Movement",
            OnClick = function(self, btn)
                MiniBtnClickFunc(btn)
            end,
            OnTooltipShow = function(tooltip)
                if not tooltip or not tooltip.AddLine then return end
                tooltip:AddLine("Long Plus [|cffeda55f提供更多设置项|r]")
            end,
        })

        local icon = LibStub("LibDBIcon-1.0", true)
        icon:Register("Long_Plus", miniButton, LongPlusDB)
    end

    ----------------------------------------------------------------------
    -- Final code for Player
    ----------------------------------------------------------------------
    
    -- Show first run message
    if LongPlusDB["isFirstRunMessageSeen"] then
        C_Timer.After(1, function()
            LongPlusLC:Print(L["click the minimap button to open Long Plus."])
            LongPlusDB["isFirstRunMessageSeen"] = false
        end)
    end

    -- Register logout event to save settings
    LpEvt:RegisterEvent("PLAYER_LOGOUT")

    -- Update addon memory usage (speeds up initial value)
    UpdateAddOnMemoryUsage()

    -- Release memory
    LongPlusLC.Player = nil
end


----------------------------------------------------------------------
--	Player logout
----------------------------------------------------------------------

-- Player Logout
function LongPlusLC:PlayerLogout(wipe)

    ----------------------------------------------------------------------
    -- Restore default values for options that do not require reloads
    ----------------------------------------------------------------------

    -- Disable screen glow (LeaPlusLC["NoScreenGlow"])
    -- if wipe then
    
    -- end

    ----------------------------------------------------------------------
    -- Restore default values for options that require reloads
    ----------------------------------------------------------------------


end

----------------------------------------------------------------------
--	Hook Functions
----------------------------------------------------------------------
hooksecurefunc("CompactUnitFrame_UpdateWidgetsOnlyMode", function(frame)
    if LongPlusLC["FriendlyNameplateHealthBar"] == "Off" then return end
    if not frame then return end
    if frame:IsForbidden() then return end
    if UnitIsUnit(frame.unit,"player") then return end
    if not string.match(frame.unit,"nameplate") then return end
    CompactUnitFrame_SetHideHealth(frame, not UnitCanAttack("player",frame.unit), 1)
end)

----------------------------------------------------------------------
-- 	Basic Functions
----------------------------------------------------------------------
function LongPlusLC:Print(text)
    DEFAULT_CHAT_FRAME:AddMessage(L[text], 1.0, 0.85, 0.0)
end

-- Find out if Leatrix Plus is showing (main panel or config panel)
function LongPlusLC:IsPlusShowing()
    if LongPlusLC["PageF"]:IsShown() then
        return true
    end
    for k, v in pairs(LongConfigList) do
        if v:IsShown() then
            return true
        end
    end
end

function LongPlusLC:LockItem(item, lock)
    if lock then
        item:Disable()
        item:SetAlpha(0.3)
    else
        item:Enable()
        item:SetAlpha(1.0)
    end
end

--  Hide panel and pages
function LongPlusLC:HideFrames()
    -- Hide option pages
    for i = 0, LongPlusLC["NumberOfPages"] do
        if LongPlusLC["Page" .. i] then
            LongPlusLC["Page" .. i]:Hide();
        end;
    end

    -- Hide options panel
    LongPlusLC["PageF"]:Hide();
end

-- Hide configuration panels
function LongPlusLC:HideConfigPanels()
    for k, v in pairs(LongConfigList) do
        v:Hide()
    end
end

function LongPlusLC:CreateCloseButton(parent, w, h, anchor, x, y)
    local btn = CreateFrame("BUTTON", nil, parent)
    btn:SetSize(w, h)
    btn:SetPoint(anchor, x, y)
    btn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    btn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    btn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    btn:SetDisabledTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
    return btn
end

-- Load a string variable or set it to default if it's not set to "On" or "Off"
function LongPlusLC:LoadVarChk(var, def)
    if LongPlusDB[var] and type(LongPlusDB[var]) == "string" and LongPlusDB[var] == "On" or LongPlusDB[var] == "Off" then
        LongPlusLC[var] = LongPlusDB[var]
    else
        LongPlusLC[var] = def
        LongPlusLC[var] = def
    end
end

-- Load a numeric variable and set it to default if it's not within a given range
function LongPlusLC:LoadVarNum(var, def, valmin, valmax)
    if LongPlusDB[var] and type(LongPlusDB[var]) == "number" and LongPlusDB[var] >= valmin and LongPlusDB[var] <= valmax then
        LongPlusLC[var] = LongPlusDB[var]
    else
        LongPlusLC[var] = def
        LongPlusDB[var] = def
    end
end

-- Load an anchor point variable and set it to default if the anchor point is invalid
function LongPlusLC:LoadVarAnc(var, def)
    if LongPlusDB[var] and type(LongPlusDB[var]) == "string" and LongPlusDB[var] == "CENTER" or LongPlusDB[var] == "TOP" or LongPlusDB[var] == "BOTTOM" or LongPlusDB[var] == "LEFT" or LongPlusDB[var] == "RIGHT" or LongPlusDB[var] == "TOPLEFT" or LongPlusDB[var] == "TOPRIGHT" or LongPlusDB[var] == "BOTTOMLEFT" or LongPlusDB[var] == "BOTTOMRIGHT" then
        LongPlusLC[var] = LongPlusDB[var]
    else
        LongPlusLC[var] = def
        LongPlusDB[var] = def
    end
end

-- Load a string variable and set it to default if it is not a string (used with minimap exclude list)
function LongPlusLC:LoadVarStr(var, def)
    if LongPlusDB[var] and type(LongPlusDB[var]) == "string" then
        LongPlusLC[var] = LongPlusDB[var]
    else
        LongPlusLC[var] = def
        LongPlusDB[var] = def
    end
end

function LongPlusLC:TipSee()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    local parent = self:GetParent()
    if parent:GetParent() and parent:GetParent():GetObjectType() == "ScrollFrame" then
        -- Scrolling frame tooltips have different parent
        parent = self:GetParent():GetParent():GetParent():GetParent()
    end
    local pscale = parent:GetEffectiveScale()
    local gscale = UIParent:GetEffectiveScale()
    local tscale = GameTooltip:GetEffectiveScale()
    local gap = ((UIParent:GetRight() * gscale) - (parent:GetRight() * pscale))
    if gap < (250 * tscale) then
        GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
    else
        GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
    end
    GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
end

-- Create a standard button (using standard button template)
function LongPlusLC:CreateButton(name, frame, label, anchor, x, y, width, height, reskin, tip, naked)
    local mbtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    LongPlusCB[name] = mbtn
    mbtn:SetSize(width, height)
    mbtn:SetPoint(anchor, x, y)
    mbtn:SetHitRectInsets(0, 0, 0, 0)
    mbtn:SetText(L[label])

    -- Create fontstring so the button can be sized correctly
    mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    mbtn.f:SetText(L[label])
    if width > 0 then
        -- Button should have static width
        mbtn:SetWidth(width)
    else
        -- Button should have variable width
        mbtn:SetWidth(mbtn.f:GetStringWidth() + 20)
    end

    -- Tooltip handler
    mbtn.tiptext = L[tip]
    mbtn:SetScript("OnEnter", LongPlusLC.TipSee)
    mbtn:SetScript("OnLeave", GameTooltip_Hide)

    -- Texture the button
    if reskin then
        -- Set skinned button textures
        if not naked then
            mbtn:SetNormalTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus.blp")
            mbtn:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1)
        end
        mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus.blp")
        mbtn:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 1)

        -- Hide the default textures
        mbtn:HookScript("OnShow", function()
            mbtn.Left:Hide();
            mbtn.Middle:Hide();
            mbtn.Right:Hide()
        end)
        mbtn:HookScript("OnEnable", function()
            mbtn.Left:Hide();
            mbtn.Middle:Hide();
            mbtn.Right:Hide()
        end)
        mbtn:HookScript("OnDisable", function()
            mbtn.Left:Hide();
            mbtn.Middle:Hide();
            mbtn.Right:Hide()
        end)
        mbtn:HookScript("OnMouseDown", function()
            mbtn.Left:Hide();
            mbtn.Middle:Hide();
            mbtn.Right:Hide()
        end)
        mbtn:HookScript("OnMouseUp", function()
            mbtn.Left:Hide();
            mbtn.Middle:Hide();
            mbtn.Right:Hide()
        end)
    end

    return mbtn
end

-- Create a dropdown menu (using standard dropdown template)
function LongPlusLC:CreateDropdown(frame, label, width, anchor, parent, relative, x, y, items)
    local RadioDropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    LongPlusLC[frame] = RadioDropdown
    RadioDropdown:SetPoint(anchor, parent, relative, x, y)

    local function IsSelected(value)
        return value == LongPlusLC[frame]
    end

    local function SetSelected(value)
        LongPlusLC[frame] = value
    end

    MenuUtil.CreateRadioMenu(RadioDropdown, IsSelected, SetSelected, unpack(items))

    local lf = RadioDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    lf:SetPoint("TOPLEFT", RadioDropdown, 0, 20);
    lf:SetPoint("TOPRIGHT", RadioDropdown, -5, 20);
    lf:SetJustifyH("LEFT");
    lf:SetText(L[label])
end

-- Display on-screen message
function LongPlusLC:DisplayMessage(self)
    ActionStatus:DisplayMessage(self)
end

-- Show a single line prefilled editbox with copy functionality
function LongPlusLC:ShowSystemEditBox(word, focuschat)
    if not LongPlusLC.FactoryEditBox then
        -- Create frame for first time
        local eFrame = CreateFrame("FRAME", nil, UIParent)
        LongPlusLC.FactoryEditBox = eFrame
        eFrame:SetSize(700, 110)
        eFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
        eFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        eFrame:SetFrameLevel(5000)
        eFrame:SetScript("OnMouseDown", function(self, btn)
            if btn == "RightButton" then
                eFrame:Hide()
            end
        end)
        -- Add background color
        eFrame.t = eFrame:CreateTexture(nil, "BACKGROUND")
        eFrame.t:SetAllPoints()
        eFrame.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)
        -- Add copy title
        eFrame.f = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        eFrame.f:SetPoint("TOPLEFT", x, y)
        eFrame.f:SetPoint("TOPLEFT", eFrame, "TOPLEFT", 12, -52)
        eFrame.f:SetWidth(676)
        eFrame.f:SetJustifyH("LEFT")
        eFrame.f:SetWordWrap(false)
        -- Add copy label
        eFrame.c = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        eFrame.c:SetPoint("TOPLEFT", x, y)
        eFrame.c:SetText(L["Press CTRL/C to copy"])
        eFrame.c:SetPoint("TOPLEFT", eFrame, "TOPLEFT", 12, -82)
        -- Add cancel label
        eFrame.x = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        eFrame.x:SetPoint("TOPRIGHT", x, y)
        eFrame.x:SetText(L["Right-click to close"])
        eFrame.x:SetPoint("TOPRIGHT", eFrame, "TOPRIGHT", -12, -82)
        -- Create editbox
        eFrame.b = CreateFrame("EditBox", nil, eFrame, "InputBoxTemplate")
        eFrame.b:ClearAllPoints()
        eFrame.b:SetPoint("TOPLEFT", eFrame, "TOPLEFT", 16, -12)
        eFrame.b:SetSize(672, 24)
        eFrame.b:SetFontObject("GameFontNormalLarge")
        eFrame.b:SetTextColor(1.0, 1.0, 1.0, 1)
        eFrame.b:SetBlinkSpeed(0)
        eFrame.b:SetHitRectInsets(99, 99, 99, 99)
        eFrame.b:SetAutoFocus(true)
        eFrame.b:SetAltArrowKeyMode(true)
        -- Editbox texture
        eFrame.t = CreateFrame("FRAME", nil, eFrame.b, "BackdropTemplate")
        eFrame.t:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile =
            "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 5, right = 5, top = 5, bottom = 5 }
        })
        eFrame.t:SetPoint("LEFT", -6, 0)
        eFrame.t:SetWidth(eFrame.b:GetWidth() + 6)
        eFrame.t:SetHeight(eFrame.b:GetHeight())
        eFrame.t:SetBackdropColor(1.0, 1.0, 1.0, 0.3)
        -- Handler
        eFrame.b:SetScript("OnKeyDown", function(void, key)
            if key == "C" and IsControlKeyDown() then
                C_Timer.After(0.1, function()
                    eFrame:Hide()
                    LongPlusLC:DisplayMessage(L["Copied to clipboard."], true)
                    if LongPlusLC.FactoryEditBoxFocusChat then
                        local eBox = ChatEdit_ChooseBoxForSend()
                        ChatEdit_ActivateChat(eBox)
                    end
                end)
            end
        end)
        -- Prevent changes
        eFrame.b:SetScript("OnEscapePressed", function()
            eFrame:Hide()
        end)
        eFrame.b:SetScript("OnEnterPressed", eFrame.b.HighlightText)
        eFrame.b:SetScript("OnMouseDown", eFrame.b.ClearFocus)
        eFrame.b:SetScript("OnMouseUp", eFrame.b.HighlightText)
        eFrame.b:SetFocus(true)
        eFrame.b:HighlightText()
        eFrame:Show()
    end
    if focuschat then
        LongPlusLC.FactoryEditBoxFocusChat = true
    else
        LongPlusLC.FactoryEditBoxFocusChat = nil
    end
    LongPlusLC.FactoryEditBox:Show()
    LongPlusLC.FactoryEditBox.b:SetText(word)
    LongPlusLC.FactoryEditBox.b:HighlightText()
    LongPlusLC.FactoryEditBox.b:SetScript("OnChar", function()
        LongPlusLC.FactoryEditBox.b:SetFocus(true)
        LongPlusLC.FactoryEditBox.b:SetText(word)
        LongPlusLC.FactoryEditBox.b:HighlightText()
    end)
    LongPlusLC.FactoryEditBox.b:SetScript("OnKeyUp", function()
        LongPlusLC.FactoryEditBox.b:SetFocus(true)
        LongPlusLC.FactoryEditBox.b:SetText(word)
        LongPlusLC.FactoryEditBox.b:HighlightText()
    end)
end

function LongPlusLC:CreateBar(name, parent, width, height, anchor, r, g, b, alp, tex)
    local ft = parent:CreateTexture(nil, "BORDER")
    ft:SetTexture(tex)
    ft:SetSize(width, height)
    ft:SetPoint(anchor)
    ft:SetVertexColor(r, g, b, alp)
    if name == "MainTexture" then
        ft:SetTexCoord(0.09, 1, 0, 1);
    end
end

-- Define subheadings
function LongPlusLC:MakeTx(frame, title, x, y)
    local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    text:SetPoint("TOPLEFT", x, y)
    text:SetText(L[title])
    return text
end

-- Define text
function LongPlusLC:MakeWD(frame, title, x, y)
    local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    text:SetPoint("TOPLEFT", x, y)
    text:SetText(L[title])
    text:SetJustifyH "LEFT";
    return text
end

-- Create a slider control (uses standard template)
function LongPlusLC:MakeSL(frame, field, caption, low, high, step, x, y, form)
    -- Create slider control
    local Slider = CreateFrame("Slider", nil, frame, "UISliderTemplate")
    LongPlusLC[field] = Slider
    Slider:SetMinMaxValues(low, high)
    Slider:SetValueStep(step)
    Slider:EnableMouseWheel(true)
    Slider:SetPoint('TOPLEFT', x, y)
    Slider:SetWidth(100)
    Slider:SetHeight(20)
    Slider:SetHitRectInsets(0, 0, 0, 0)
    Slider.tiptext = L[caption]
    Slider:SetScript("OnEnter", LongPlusLC.TipSee)
    Slider:SetScript("OnLeave", GameTooltip_Hide)

    -- Create slider label
    Slider.f = Slider:CreateFontString(nil, 'BACKGROUND')
    Slider.f:SetFontObject('GameFontHighlight')
    Slider.f:SetPoint('LEFT', Slider, 'RIGHT', 12, 0)
    Slider.f:SetFormattedText("%.2f", Slider:GetValue())

    -- Process mousewheel scrolling
    Slider:SetScript("OnMouseWheel", function(self, arg1)
        if Slider:IsEnabled() then
            local step = step * arg1
            local value = self:GetValue()
            if step > 0 then
                self:SetValue(min(value + step, high))
            else
                self:SetValue(max(value + step, low))
            end
        end
    end)

    -- Process value changed
    Slider:SetScript("OnValueChanged", function(self, value)
        local value = floor((value - low) / step + 0.5) * step + low
        Slider.f:SetFormattedText(form, value)
        LongPlusLC[field] = value
    end)

    -- Set slider value when shown
    Slider:SetScript("OnShow", function(self)
        self:SetValue(LongPlusLC[field])
    end)
end

-- Create a checkbox control (uses standard template)
function LongPlusLC:MakeCB(parent, field, caption, x, y, reload, tip, tipstyle)
    -- Create the checkbox
    local Cbox = CreateFrame('CheckButton', nil, parent, "ChatConfigCheckButtonTemplate")
    LongPlusCB[field] = Cbox
    Cbox:SetPoint("TOPLEFT", x, y)
    Cbox:SetScript("OnEnter", LongPlusLC.TipSee)
    Cbox:SetScript("OnLeave", GameTooltip_Hide)

    -- Add label and tooltip
    Cbox.f = Cbox:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    Cbox.f:SetPoint('LEFT', 20, 0)
    if reload then
        -- Checkbox requires UI reload
        Cbox.f:SetText(L[caption] .. "*")
        Cbox.tiptext = L[tip] .. "|n|n* " .. L["Requires UI reload."]
    else
        -- Checkbox does not require UI reload
        Cbox.f:SetText(L[caption])
        Cbox.tiptext = L[tip]
    end

    -- Set label parameters
    Cbox.f:SetJustifyH("LEFT")
    Cbox.f:SetWordWrap(false)

    -- Set maximum label width
    if parent:GetParent() == LongPlusLC["PageF"] then
        -- Main panel checkbox labels
        if Cbox.f:GetWidth() > 152 then
            Cbox.f:SetWidth(152)
            LongPlusLC["TruncatedLabelsList"] = LongPlusLC["TruncatedLabelsList"] or {}
            LongPlusLC["TruncatedLabelsList"][Cbox.f] = L[caption]
        end
        -- Set checkbox click width
        if Cbox.f:GetStringWidth() > 152 then
            Cbox:SetHitRectInsets(0, -142, 0, 0)
        else
            Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
        end
    else
        -- Configuration panel checkbox labels (other checkboxes either have custom functions or blank labels)
        if Cbox.f:GetWidth() > 302 then
            Cbox.f:SetWidth(302)
            LongPlusLC["TruncatedLabelsList"] = LongPlusLC["TruncatedLabelsList"] or {}
            LongPlusLC["TruncatedLabelsList"][Cbox.f] = L[caption]
        end
        -- Set checkbox click width
        if Cbox.f:GetStringWidth() > 302 then
            Cbox:SetHitRectInsets(0, -292, 0, 0)
        else
            Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
        end
    end

    -- Set default checkbox state and click area
    Cbox:SetScript('OnShow', function(self)
        if LongPlusLC[field] == "On" then
            self:SetChecked(true)
        else
            self:SetChecked(false)
        end
    end)

    -- Process clicks
    Cbox:SetScript('OnClick', function()
        if Cbox:GetChecked() then
            LongPlusLC[field] = "On"
        else
            LongPlusLC[field] = "Off"
        end
        LongPlusLC:SetDim();      -- Lock invalid options
        LongPlusLC:ReloadCheck(); -- Show reload button if needed
    end)
end

----------------------------------------------------------------------
-- 	Create main options panel frame
----------------------------------------------------------------------
function LongPlusLC:CreateMainPanel()
    -- Create the panel
    local PageF = CreateFrame("Frame", nil, UIParent);

    -- Make it a system frame
    _G["LongPlusGlobalPanel"] = PageF
    table.insert(UISpecialFrames, "LongPlusGlobalPanel")

    -- Set frame parameters
    LongPlusLC["PageF"] = PageF
    PageF:SetSize(570, 370)
    PageF:Hide();
    PageF:SetFrameStrata("FULLSCREEN_DIALOG")
    PageF:SetClampedToScreen(true)
    PageF:SetClampRectInsets(500, -500, -300, 300)
    PageF:EnableMouse(true)
    PageF:SetMovable(true)
    PageF:RegisterForDrag("LeftButton")
    PageF:SetScript("OnDragStart", PageF.StartMoving)
    PageF:SetScript("OnDragStop", function()
        PageF:StopMovingOrSizing();
        PageF:SetUserPlaced(false);
        -- Save panel position
        LongPlusLC["MainPanelA"], void, LongPlusLC["MainPanelR"], LongPlusLC["MainPanelX"], LongPlusLC["MainPanelY"] =
            PageF:GetPoint()
    end)

    -- Add background color
    PageF.t = PageF:CreateTexture(nil, "BACKGROUND")
    PageF.t:SetAllPoints()
    PageF.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

    -- Add textures
    LongPlusLC:CreateBar("FootTexture", PageF, 570, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0,
        "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
    LongPlusLC:CreateBar("MainTexture", PageF, 440, 323, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,
        "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
    LongPlusLC:CreateBar("MenuTexture", PageF, 130, 323, "TOPLEFT", 0.7, 0.7, 0.7, 0.7,
        "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

    -- Set panel position when shown
    PageF:SetScript("OnShow", function()
        PageF:ClearAllPoints()
        PageF:SetPoint(LongPlusLC["MainPanelA"], UIParent, LongPlusLC["MainPanelR"], LongPlusLC["MainPanelX"],
            LongPlusLC["MainPanelY"])
    end)

    -- Add main title (shown above menu in the corner)
    PageF.mt = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
    PageF.mt:SetPoint('TOPLEFT', 16, -16)
    PageF.mt:SetText("Long Plus")

    -- Add version text (shown underneath main title)
    PageF.v = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    PageF.v:SetHeight(32);
    PageF.v:SetPoint('TOPLEFT', PageF.mt, 'BOTTOMLEFT', 0, -8);
    PageF.v:SetPoint('RIGHT', PageF, -32, 0)
    PageF.v:SetJustifyH('LEFT'); PageF.v:SetJustifyV('TOP');
    PageF.v:SetNonSpaceWrap(true); PageF.v:SetText(L["Version"] .. " " .. LongPlusLC["AddonVer"])

    -- Add reload UI Button
    local reloadb = LongPlusLC:CreateButton("ReloadUIButton", PageF, "Reload", "BOTTOMRIGHT", -16, 10, 0, 25, true,
        "Your UI needs to be reloaded for some of the changes to take effect.|n|nYou don't have to click the reload button immediately but you do need to click it when you are done making changes and you want the changes to take effect.")
    LongPlusLC:LockItem(reloadb, true)
    reloadb:SetScript("OnClick", ReloadUI)

    reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
    reloadb.f:SetHeight(32);
    reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
    reloadb.f:SetText(L["Your UI needs to be reloaded."])
    reloadb.f:Hide()

    -- Add close Button (LeaPlusLC.DF: Using custom template)
    local CloseB = LongPlusLC:CreateCloseButton(PageF, 30, 30, "TOPRIGHT", 0, 0)
    CloseB:SetScript("OnClick", LongPlusLC.HideFrames)

    -- Release memory
    LongPlusLC.CreateMainPanel = nil
end
LongPlusLC:CreateMainPanel();


----------------------------------------------------------------------
-- 	Create options panel pages (no content yet)
----------------------------------------------------------------------

-- Function to add menu button
function LongPlusLC:MakeMN(name, text, parent, anchor, x, y, width, height)
    local mbtn = CreateFrame("Button", nil, parent)
    LongPlusLC[name] = mbtn
    mbtn:Show();
    mbtn:SetSize(width, height)
    mbtn:SetAlpha(1.0)
    mbtn:SetPoint(anchor, x, y)

    mbtn.t = mbtn:CreateTexture(nil, "BACKGROUND")
    mbtn.t:SetAllPoints()
    mbtn.t:SetColorTexture(0.3, 0.3, 0.00, 0.8)
    mbtn.t:SetAlpha(0.7)
    mbtn.t:Hide()

    mbtn.s = mbtn:CreateTexture(nil, "BACKGROUND")
    mbtn.s:SetAllPoints()
    mbtn.s:SetColorTexture(0.3, 0.3, 0.00, 0.8)
    mbtn.s:Hide()

    mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    mbtn.f:SetPoint('LEFT', 16, 0)
    mbtn.f:SetText(L[text])

    mbtn:SetScript("OnEnter", function()
        mbtn.t:Show()
    end)

    mbtn:SetScript("OnLeave", function()
        mbtn.t:Hide()
    end)

    return mbtn, mbtn.s
end

-- Function to create individual options panel pages
function LongPlusLC:MakePage(name, title, menu, menuname, menuparent, menuanchor, menux, menuy, menuwidth, menuheight)
    -- Create frame
    local oPage = CreateFrame("Frame", nil, LongPlusLC["PageF"])
    LongPlusLC[name] = oPage
    oPage:SetAllPoints(LongPlusLC["PageF"])
    oPage:Hide()

    -- Add page title
    oPage.s = oPage:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
    oPage.s:SetPoint('TOPLEFT', 146, -16)
    oPage.s:SetText(L[title])

    -- Add menu item if needed
    if menu then
        LongPlusLC[menu], LongPlusLC[menu .. ".s"] = LongPlusLC:MakeMN(menu, menuname, menuparent, menuanchor, menux,
            menuy,
            menuwidth, menuheight)
        LongPlusLC[name]:SetScript("OnShow", function() LongPlusLC[menu .. ".s"]:Show(); end)
        LongPlusLC[name]:SetScript("OnHide", function() LongPlusLC[menu .. ".s"]:Hide(); end)
    end

    return oPage
end

-- Create options pages
LongPlusLC["Page0"] = LongPlusLC:MakePage("Page0", "Home", "LongPlusNav0", "Home", LongPlusLC["PageF"], "TOPLEFT", 16,
    -72,
    112, 20)
LongPlusLC["Page1"] = LongPlusLC:MakePage("Page1", "Nameplate", "LongPlusNav1", "Nameplate", LongPlusLC["PageF"],
    "TOPLEFT", 16, -112, 112, 20)

-- Page navigation mechanism
for i = 0, LongPlusLC["NumberOfPages"] do
    LongPlusLC["LongPlusNav" .. i]:SetScript("OnClick", function()
        LongPlusLC:HideFrames()
        LongPlusLC["PageF"]:Show()
        LongPlusLC["Page" .. i]:Show()
        LongPlusLC["LongStartPage"] = i
    end)
end

-- Use a variable to contain the page number (makes it easier to move options around)
local pg;

----------------------------------------------------------------------
-- 	0: Welcome
----------------------------------------------------------------------

pg = "Page0"

LongPlusLC:MakeTx(LongPlusLC[pg], "Welcome to Long Plus.", 146, -72)
LongPlusLC:MakeWD(LongPlusLC[pg], "To begin, choose an options page.", 146, -92)

LongPlusLC:MakeTx(LongPlusLC[pg], "Support", 146, -132);
LongPlusLC:MakeWD(LongPlusLC[pg], "bryantsisu@gmail.com", 146, -152)


----------------------------------------------------------------------
-- 	1: Nameplate
----------------------------------------------------------------------

pg = "Page1"

LongPlusLC:MakeTx(LongPlusLC[pg], "Friendly Nameplate Health Bar", 146, -72)
LongPlusLC:MakeCB(LongPlusLC[pg], "FriendlyNameplateHealthBar", "Hide Friendly Unit Health Bar", 146, -92, true, "Health bars will only be displayed for targetable enemies.")

LongPlusLC:MakeTx(LongPlusLC[pg], "Friendly Nameplate Width", 340, -72)
LongPlusLC:MakeSL(LongPlusLC[pg], "PlusPanelScale", "Drag to set the width of friendly nameplate.", 1, 2, 0.1, 340, -92, "%.1f")

