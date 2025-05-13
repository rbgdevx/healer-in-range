local _, NS = ...

local LibStub = LibStub
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local UnitInRange = UnitInRange
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local IsInInstance = IsInInstance
local pairs = pairs
local type = type
local next = next
local setmetatable = setmetatable
local getmetatable = getmetatable
local print = print
local tonumber = tonumber

local sformat = string.format
-- local tinsert = table.insert
-- local tsort = table.sort
-- local wipe = table.wipe

local SharedMedia = LibStub("LibSharedMedia-3.0")
-- local LibRangeCheck = LibStub("LibRangeCheck-3.0")

NS.trim = function(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

NS.Debug = function(...)
  if NS.db.global.debug then
    print(...)
  end
end

NS.isConnected = function(unit)
  return UnitIsConnected(unit)
end

NS.isDead = function(unit)
  return UnitIsDeadOrGhost(unit)
end

NS.isInGroup = function()
  return IsInRaid() or IsInGroup()
end

NS.isHealer = function(unit)
  return UnitGroupRolesAssigned(unit) == "HEALER"
end

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

-- function NS.GetRange(unit, checkVisible)
-- 	return LibRangeCheck:GetRange(unit, checkVisible)
-- end

-- function NS.CheckRange(unit, range, operator)
--   local min, max = LibRangeCheck:GetRange(unit, true)
--   if type(range) ~= "number" then
--     range = tonumber(range)
--   end
--   if not range then
--     return
--   end
--   if operator == "<=" then
--     return (max or 999) <= range
--   else
--     return (min or 0) >= range
--   end
-- end

-- local RangeCacheStrings = { friend = "", harm = "", misc = "" }
-- local function RangeCacheUpdate()
--   local friend, harm, misc = {}, {}, {}
--   local friendString, harmString, miscString

--   for range in LibRangeCheck:GetFriendCheckers() do
--     tinsert(friend, range)
--   end
--   tsort(friend)
--   for range in LibRangeCheck:GetHarmCheckers() do
--     tinsert(harm, range)
--   end
--   tsort(harm)
--   for range in LibRangeCheck:GetMiscCheckers() do
--     tinsert(misc, range)
--   end
--   tsort(misc)

--   for _, key in pairs(friend) do
--     friendString = (friendString and (friendString .. ", ") or "") .. key
--   end
--   for _, key in pairs(harm) do
--     harmString = (harmString and (harmString .. ", ") or "") .. key
--   end
--   for _, key in pairs(misc) do
--     miscString = (miscString and (miscString .. ", ") or "") .. key
--   end
--   RangeCacheStrings.friend, RangeCacheStrings.harm, RangeCacheStrings.misc = friendString, harmString, miscString
-- end

-- LibRangeCheck:RegisterCallback(LibRangeCheck.CHECKERS_CHANGED, RangeCacheUpdate)

NS.isHealerInRange = function()
  if NS.isHealer("player") then
    return true
  else
    local rangeEnabled = NS.db.global.enableRange and tonumber(NS.db.global.range) ~= nil
    local count = 0
    for unit in NS.IterateGroupMembers() do
      if unit and NS.isHealer(unit) and NS.isConnected(unit) and not NS.isDead(unit) then
        if rangeEnabled then
          local rangeSquared = NS.db.global.range * NS.db.global.range
          local distanceSquared = UnitDistanceSquared(unit)

          -- NS.CheckRange(unit, tonumber(NS.db.global.range), NS.db.global.rangeOperator)
          local inRangeCustom = false
          if NS.db.global.rangeOperator == "<=" then
            inRangeCustom = distanceSquared <= rangeSquared
          else
            inRangeCustom = distanceSquared >= rangeSquared
          end

          if inRangeCustom then
            count = count + 1
          end
        else
          local inRangeDefault = UnitInRange(unit)

          if inRangeDefault then
            count = count + 1
          end
        end
      end
    end
    if count > 0 then
      return true
    end
    return false
  end
end

NS.noHealersInGroup = function()
  if NS.isHealer("player") then
    return false
  else
    for unit in NS.IterateGroupMembers() do
      if unit and NS.isHealer(unit) then
        return false
      end
    end
    return true
  end
end

NS.UpdateText = function(frame, reverse)
  local displayText = sformat("HEALER %s RANGE", reverse == true and "OUT OF" or "IN")
  frame:SetText(displayText)
end

NS.UpdateFont = function(frame)
  frame:SetFont(SharedMedia:Fetch("font", NS.db.global.font), NS.db.global.fontsize, "OUTLINE")
end

NS.ToggleVisibility = function(inRange, reverse)
  if IsInInstance() then
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
  else
    if NS.db.global.showOutside then
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
  end
end

-- Copies table values from src to dst if they don't exist in dst
NS.CopyDefaults = function(src, dst)
  if type(src) ~= "table" then
    return {}
  end

  if type(dst) ~= "table" then
    dst = {}
  end

  for k, v in pairs(src) do
    if type(v) == "table" then
      dst[k] = NS.CopyDefaults(v, dst[k])
    elseif type(v) ~= type(dst[k]) then
      dst[k] = v
    end
  end

  return dst
end

NS.CopyTable = function(src, dest)
  -- Handle non-tables and previously-seen tables.
  if type(src) ~= "table" then
    return src
  end

  if dest and dest[src] then
    return dest[src]
  end

  -- New table; mark it as seen an copy recursively.
  local s = dest or {}
  local res = {}
  s[src] = res

  for k, v in next, src do
    res[NS.CopyTable(k, s)] = NS.CopyTable(v, s)
  end

  return setmetatable(res, getmetatable(src))
end

-- Cleanup savedvariables by removing table values in src that no longer
-- exists in table dst (default settings)
NS.CleanupDB = function(src, dst)
  for key, value in pairs(src) do
    if dst[key] == nil then
      -- HACK: offsetsXY are not set in DEFAULT_SETTINGS but sat on demand instead to save memory,
      -- which causes nil comparison to always be true here, so always ignore these for now
      if key ~= "offsetsX" and key ~= "offsetsY" and key ~= "version" then
        src[key] = nil
      end
    elseif type(value) == "table" then
      if key ~= "disabledCategories" and key ~= "categoryTextures" then -- also sat on demand
        dst[key] = NS.CleanupDB(value, dst[key])
      end
    end
  end
  return dst
end
