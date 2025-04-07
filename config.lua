local _, NS = ...

local CreateFrame = CreateFrame

---@class PositionArray
---@field[1] string
---@field[2] string
---@field[3] number
---@field[4] number

---@class ColorArray
---@field r number
---@field g number
---@field b number
---@field a number

---@class GlobalTable : table
---@field lock boolean
---@field test boolean
---@field reverse boolean
---@field healer boolean
---@field showOutside boolean
---@field fontsize number
---@field font string
---@field enableRange boolean
---@field rangeOperator string
---@field range string
---@field color ColorArray
---@field position PositionArray
---@field debug boolean

---@class DBTable : table
---@field global GlobalTable

---@class HIR
---@field ADDON_LOADED function
---@field PLAYER_LOGIN function
---@field PLAYER_ENTERING_WORLD function
---@field PLAYER_DEAD function
---@field PLAYER_UNGHOST function
---@field GROUP_ROSTER_UPDATE function
---@field CheckForHealerInRange function
---@field SlashCommands function
---@field frame Frame

---@type HIR
---@diagnostic disable-next-line: missing-fields
local HIR = {}
NS.HIR = HIR

local HIRFrame = CreateFrame("Frame", "HIRFrame")
HIRFrame:SetScript("OnEvent", function(_, event, ...)
  if HIR[event] then
    HIR[event](HIR, ...)
  end
end)
NS.HIR.frame = HIRFrame

NS.DefaultDatabase = {
  global = {
    lock = false,
    test = true,
    reverse = false,
    healer = true,
    showOutside = false,
    fontsize = 30,
    font = "Friz Quadrata TT",
    enableRange = false,
    range = "",
    rangeOperator = "<=",
    color = {
      r = 1,
      g = 1,
      b = 1,
      a = 1,
    },
    position = {
      "CENTER",
      "CENTER",
      0,
      0,
    },
    debug = false,
  },
}
