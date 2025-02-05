local api = require("api")

local loss_porn_addon = {
	name = "Loss Porn",
	author = "Michaelqt",
	version = "1.0",
	desc = "See failed regrades from other players in chat."
}

local lossPornWindow

local clockTimer = 0
local clockResetTime = 1000

local ENCHANT_RESULT = {
    BREAK = 0,
    DOWNGRADE = 1,
    FAIL = 2,
    SUCCESS = 3,
    GREATE_SUCCESS = 4
  }
local ITEM_GRADES = {
    COMMON = 0,
    POOR = 1,
    UNCOMMON = 2,
    RARE = 3,
    ANCIENT = 4,
    HEROIC = 5,
    UNIQUE = 6,
    ARTIFACT = 7,
    WONDER = 8,
    EPIC = 9,
    LEGENDARY = 10,
    MYTHIC = 11
}

local GRADE_COLORS = {
    CELESTIAL = "FFf95252",
    DIVINE = "FFcf7d5d",
    EPIC = "FF8fa5ca",
    LEGENDARY = "FFbf7900",
    MYTHIC = "FFc90b0b",
}

local function getGradeName(gradeId)
    if gradeId == 1 then 
        return "Basic" 
    elseif gradeId == 2 then
        return "Grand"
    elseif gradeId == 3 then
        return "Rare"
    elseif gradeId == 4 then
        return "Arcane"
    elseif gradeId == 5 then
        return "Heroic"
    elseif gradeId == 6 then
        return "Unique"
    elseif gradeId == 7 then
        return "Celestial"
    elseif gradeId == 8 then
        return "Divine"
    elseif gradeId == 9 then
        return "Epic"
    elseif gradeId == 10 then
        return "Legendary"
    elseif gradeId == 11 then
        return "Mythic"
    end
    return nil 
end 

function split(s, sep)
    local fields = {}
    
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end

local function itemIdFromItemLinkText(itemLinkText)
    local itemIdStr = string.sub(itemLinkText, 3)
    itemIdStr = split(itemIdStr, ",")
    itemIdStr = itemIdStr[1]
    return itemIdStr
end 

local function OnUpdate(dt)
    if clockTimer + dt > clockResetTime then

		clockTimer = 0
    end 
    clockTimer = clockTimer + dt
end 

local function logRegradeFailuresToChat(characterName, resultCode, itemLink, oldGrade, newGrade)
    -- api.Log:Info("A regrade happened.")
    if resultCode == ENCHANT_RESULT.DOWNGRADE then 
        -- It has to be a celestial to arcane downgrade, no others in the game.
        api.Log:Info("|cFFFFF8C7" .. characterName .. " failed their regrade, |cFFF8BD47Downgrading|r their " .. itemLink .. " from |cFFf95252Celestial|r to |cFFc267cdArcane|r")
    elseif resultCode == ENCHANT_RESULT.BREAK then 
        api.Log:Info("|cFFFFF8C7" .. characterName .. " failed their regrade, |cFFFF6060Destroying|r their " .. itemLink)
    end 
    
end

local function OnLoad()
	local settings = api.GetSettings("loss_porn")
    lossPornWindow = api.Interface:CreateEmptyWindow("lossPornWnd", "UIParent")

    -- Event Handlers
    function lossPornWindow:OnEvent(event, ...)
        if event == "GRADE_ENCHANT_BROADCAST" then
            logRegradeFailuresToChat(unpack(arg))
        end
    end
    lossPornWindow:SetHandler("OnEvent", lossPornWindow.OnEvent)
    lossPornWindow:RegisterEvent("GRADE_ENCHANT_BROADCAST")
	
    api.On("UPDATE", OnUpdate)
	api.SaveSettings()
end

local function OnUnload()
    local settings = api.GetSettings("loss_porn")

    lossPornWindow:ReleaseHandler("OnEvent")

	api.On("UPDATE", function() return end)
    api.SaveSettings()
end

loss_porn_addon.OnLoad = OnLoad
loss_porn_addon.OnUnload = OnUnload

return loss_porn_addon
