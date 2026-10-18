-- PI Target
local ADDON_NAME = ...
-- /pit set [unit] : point the PI macro at your target, or another unit such as
--                   mouseover for click-cast bindings on unit frames (out of combat)
-- /pit lock | unlock | reset

local MACRO_NAME = "PI"
local SPELL      = "Power Infusion"
local TRINKET    = "/use 13"   -- delete or change if you don't want the trinket line

------------------------------------------------------------------------
-- Look. Flat dark panel, 1px black border, class-coloured accent bar,
-- to sit alongside EllesmereUI frames. Tweak freely.
------------------------------------------------------------------------
local STYLE = {
    width     = 170,
    height    = 24,
    bg        = { 0.05, 0.05, 0.05, 0.85 },
    border    = { 0, 0, 0, 1 },
    accentW   = 3,
    font      = nil,   -- nil = game font; or a LibSharedMedia font name, e.g. "Expressway"
    fontSize  = 12,
    fontFlags = "",    -- "" with shadow, or "OUTLINE"
    dim       = { 0.55, 0.55, 0.55 },
    bad       = { 1, 0.3, 0.3 },
}

local function ResolveFont()
    if STYLE.font and LibStub then
        local LSM = LibStub("LibSharedMedia-3.0", true)
        local path = LSM and LSM:Fetch("font", STYLE.font, true)
        if path then return path end
    end
    return STANDARD_TEXT_FONT
end

------------------------------------------------------------------------
-- Frame
------------------------------------------------------------------------
local f = CreateFrame("Frame", "PITargetFrame", UIParent, "BackdropTemplate")
f:SetSize(STYLE.width, STYLE.height)
f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
f:SetBackdropColor(unpack(STYLE.bg))
f:SetBackdropBorderColor(unpack(STYLE.border))
f:SetClampedToScreen(true)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
f:SetFrameStrata("HIGH") -- sit above unit frames / cast bars
f:SetFrameLevel(50)
f:Show()

local accent = f:CreateTexture(nil, "ARTWORK")
accent:SetPoint("TOPLEFT", 1, -1)
accent:SetPoint("BOTTOMLEFT", 1, 1)
accent:SetWidth(STYLE.accentW)
accent:SetColorTexture(unpack(STYLE.dim))

local icon = f:CreateTexture(nil, "ARTWORK")
icon:SetPoint("TOPLEFT", accent, "TOPRIGHT", 1, 0)
icon:SetPoint("BOTTOMLEFT", accent, "BOTTOMRIGHT", 1, 0)
icon:SetWidth(STYLE.height - 2)
icon:SetTexture(135939) -- Power Infusion
icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

local text = f:CreateFontString(nil, "OVERLAY")
text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
text:SetPoint("RIGHT", -6, 0)
text:SetJustifyH("LEFT")
text:SetWordWrap(false)
text:SetFontObject(GameFontNormal) -- safe default before ApplyFont runs

local function ApplyFont()
    text:SetFont(ResolveFont(), STYLE.fontSize, STYLE.fontFlags)
    if STYLE.fontFlags == "" then
        text:SetShadowColor(0, 0, 0, 1)
        text:SetShadowOffset(1, -1)
    else
        text:SetShadowOffset(0, 0)
    end
end

local function Show(msg, r, g, b)
    text:SetText(msg)
    text:SetTextColor(r, g, b)
    accent:SetColorTexture(r, g, b)
end

------------------------------------------------------------------------
-- Reading the macro
------------------------------------------------------------------------
local SKIP = { mouseover = true, target = true, focus = true, cursor = true }

local function GetPITarget()
    local idx = GetMacroIndexByName(MACRO_NAME)
    if not idx or idx == 0 then return nil end
    local body = select(3, GetMacroInfo(idx))
    if not body then return nil end
    for name in body:gmatch("@([^,%]]+)") do
        if not SKIP[name] then return name end
    end
end

local function FindUnit(name)
    if name == "player" then return "player" end
    local short = name:match("^[^-]+")
    local prefix = IsInRaid() and "raid" or "party"
    local units = { "player" }
    for i = 1, GetNumGroupMembers() do units[#units + 1] = prefix .. i end
    for _, unit in ipairs(units) do
        if UnitExists(unit) then
            local full = GetUnitName(unit, true)
            if full == name or full == short then return unit end
        end
    end
end

local function Update()
    local name = GetPITarget()
    if not name then
        Show("PI: not set", unpack(STYLE.dim))
        return
    end
    if InCombatLockdown() then return end -- keep what's shown; group lookups can be restricted mid-fight

    local unit = FindUnit(name)
    local label = (name == "player") and UnitName("player") or name:match("^[^-]+")
    if unit then
        local _, class = UnitClass(unit)
        local c = class and RAID_CLASS_COLORS[class]
        if c then Show(label, c.r, c.g, c.b) else Show(label, 1, 1, 1) end
    else
        Show(label .. "  (not in group)", unpack(STYLE.bad))
    end
end

local function Flash(msg)
    Show(msg, unpack(STYLE.bad))
    C_Timer.After(2, Update)
end

------------------------------------------------------------------------
-- Writing the macro
------------------------------------------------------------------------
local function BuildBody(name)
    local body = "#showtooltip\n/cast [@mouseover,help,nodead][@" .. name .. ",exists,nodead][] " .. SPELL
    if TRINKET and TRINKET ~= "" then body = body .. "\n" .. TRINKET end
    return body
end

-- unit is "target" from /pit set, or e.g. "mouseover" from a click-cast binding
local function SetPITarget(unit)
    if InCombatLockdown() then return Flash("Can't change PI in combat") end

    local name = "player"
    if UnitExists(unit) then
        if not (UnitIsPlayer(unit) and UnitIsFriend("player", unit)) then
            return Flash("Pick a friendly player")
        end
        name = GetUnitName(unit, true) -- includes realm for cross-realm players
    elseif unit ~= "target" then
        return Flash("No " .. unit) -- only a bare /pit set falls back to you
    end

    local body = BuildBody(name)
    local idx = GetMacroIndexByName(MACRO_NAME)
    if idx and idx > 0 then
        EditMacro(idx, nil, nil, body)
    else
        local ok = pcall(CreateMacro, MACRO_NAME, "INV_MISC_QUESTIONMARK", body)
        if not ok then return Flash("No free macro slot") end
        print("PI Target: created the '" .. MACRO_NAME .. "' macro. Drag it to your bars with /macro.")
    end
    Update()
end

------------------------------------------------------------------------
-- Position, events, slash
------------------------------------------------------------------------
local function SavePosition()
    PITargetDB = PITargetDB or {}
    local point, _, relPoint, x, y = f:GetPoint()
    PITargetDB.pos = { point, relPoint, x, y }
end

local function ResetPosition()
    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
    SavePosition()
end

f:SetScript("OnDragStart", function(self)
    if not (PITargetDB and PITargetDB.locked) then self:StartMoving() end
end)
f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_MACROS")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then return end
        PITargetDB = PITargetDB or {}
        local p = PITargetDB.pos
        if p then
            self:ClearAllPoints()
            self:SetPoint(p[1], UIParent, p[2], p[3], p[4])
        else
            ResetPosition()
        end
        self:EnableMouse(not PITargetDB.locked)
        ApplyFont()
        self:UnregisterEvent("ADDON_LOADED")
        return
    end
    if event == "PLAYER_ENTERING_WORLD" then ApplyFont() end -- pick up LSM fonts registered late
    Update()
end)

SLASH_PITARGET1 = "/pit"
SlashCmdList.PITARGET = function(msg)
    local cmd, arg = strtrim((msg or ""):lower()):match("^(%S*)%s*(.-)$")
    if cmd == "set" then
        SetPITarget(arg ~= "" and arg or "target")
    elseif cmd == "lock" or cmd == "unlock" then
        PITargetDB = PITargetDB or {}
        PITargetDB.locked = (cmd == "lock")
        f:EnableMouse(not PITargetDB.locked) -- locked = click-through
        print("PI Target: frame " .. cmd .. "ed")
    elseif cmd == "reset" then
        ResetPosition()
        f:Show()
    elseif cmd == "debug" then
        local pt, _, _, x, y = f:GetPoint()
        print(("PI Target: loaded as %s | shown=%s visible=%s | point=%s %s,%s | macro target=%s"):format(
            tostring(ADDON_NAME), tostring(f:IsShown()), tostring(f:IsVisible()),
            tostring(pt), tostring(x), tostring(y), tostring(GetPITarget())))
    else
        print("PI Target: /pit set [unit] | lock | unlock | reset | debug")
    end
end
