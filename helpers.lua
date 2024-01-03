local _, NS = ...

local LibStub = LibStub
local IsInRaid = IsInRaid
local UnitInRange = UnitInRange
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

local sformat = string.format

local LSM = LibStub("LibSharedMedia-3.0")

-- Function to assist iterating group members whether in a party or raid.
NS.IterateGroupMembers = function(reversed, forceParty)
  local unit = (not forceParty and IsInRaid()) and "raid" or "party"
  local numGroupMembers = unit == "party" and GetNumSubgroupMembers() or GetNumGroupMembers()
  local i = reversed and numGroupMembers or (unit == "party" and 0 or 1)
  return function()
    local ret
    if i == 0 and unit == "party" then
      ret = "player"
    elseif i <= numGroupMembers and i > 0 then
      ret = unit .. i
    end
    i = i + (reversed and -1 or 1)
    return ret
  end
end

NS.isHealerInRange = function()
  for unit in NS.IterateGroupMembers() do
    if unit then
      if UnitGroupRolesAssigned(unit) == "HEALER" then
        if UnitInRange(unit) then
          return true
        else
          return false
        end
      end
    end
  end
end

NS.UpdateText = function(frame, reverse)
  local displayText = sformat("HEALER %s RANGE", reverse == true and "OUT OF" or "IN")
  frame:SetText(displayText)
end

NS.UpdateFont = function(frame)
  frame:SetFont(LSM:Fetch("font", HIR.db.global.font), HIR.db.global.fontsize, "THINOUTLINE")
end

NS.ToggleVisibility = function(inRange, reverse)
  if inRange then
    if reverse then
      NS.Interface:ShowText(false)
    else
      NS.Interface:ShowText(true)
    end
  else
    if reverse then
      NS.Interface:ShowText(true)
    else
      NS.Interface:ShowText(false)
    end
  end
end
