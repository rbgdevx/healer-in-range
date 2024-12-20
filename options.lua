local AddonName, NS = ...

local CopyTable = CopyTable
local next = next
local LibStub = LibStub

local SharedMedia = LibStub("LibSharedMedia-3.0")

---@type HIR
local HIR = NS.HIR
local HIRFrame = NS.HIR.frame

local Options = {}
NS.Options = Options

NS.AceConfig = {
  name = AddonName,
  type = "group",
  args = {
    lock = {
      name = "Lock the text into place",
      type = "toggle",
      width = "double",
      order = 1,
      set = function(_, val)
        NS.db.global.lock = val
        if val then
          NS.Interface:Lock(NS.Interface.textFrame)
        else
          NS.Interface:Unlock(NS.Interface.textFrame)
        end
      end,
      get = function(_)
        return NS.db.global.lock
      end,
    },
    test = {
      name = "Toggle on to test settings (out of group)",
      desc = "Only works outside of a group.",
      type = "toggle",
      width = "double",
      order = 2,
      set = function(_, val)
        NS.db.global.test = val
        if NS.isInGroup() == false then
          if val then
            NS.Interface.textFrame:Show()
            NS.Interface.textFrame:SetAlpha(1)
          else
            NS.Interface.textFrame:Hide()
          end
        end
      end,
      get = function(_)
        return NS.db.global.test
      end,
    },
    reverse = {
      name = "Show Healer out of range instead",
      type = "toggle",
      width = "double",
      order = 3,
      set = function(_, val)
        -- true = show out of range
        -- false = show in range
        NS.db.global.reverse = val
        NS.UpdateText(NS.Interface.text, val)
        if NS.isInGroup() then
          local inRange = NS.isHealerInRange()
          NS.ToggleVisibility(inRange, val)
        end
      end,
      get = function(_)
        return NS.db.global.reverse
      end,
    },
    healer = {
      name = "Disable when spec'd into a healer role",
      type = "toggle",
      width = "double",
      order = 4,
      set = function(_, val)
        NS.db.global.healer = val
        if NS.isInGroup() then
          local inRange = NS.isHealerInRange()
          NS.ToggleVisibility(inRange, val)
        end
      end,
      get = function(_)
        return NS.db.global.healer
      end,
    },
    fontsize = {
      type = "range",
      name = "Font Size",
      width = "double",
      order = 5,
      min = 2,
      max = 64,
      step = 1,
      set = function(_, val)
        NS.db.global.fontsize = val
        NS.UpdateFont(NS.Interface.text)
        NS.Interface.textFrame:SetWidth(NS.Interface.text:GetStringWidth())
        NS.Interface.textFrame:SetHeight(NS.Interface.text:GetStringHeight())
      end,
      get = function(_)
        return NS.db.global.fontsize
      end,
    },
    font = {
      type = "select",
      name = "Font",
      width = "double",
      order = 6,
      dialogControl = "LSM30_Font",
      values = SharedMedia:HashTable("font"),
      set = function(_, val)
        NS.db.global.font = val
        NS.UpdateFont(NS.Interface.text)
        NS.Interface.textFrame:SetWidth(NS.Interface.text:GetStringWidth())
        NS.Interface.textFrame:SetHeight(NS.Interface.text:GetStringHeight())
      end,
      get = function(_)
        return NS.db.global.font
      end,
    },
    color = {
      type = "color",
      name = "Color",
      width = "double",
      order = 7,
      hasAlpha = true,
      set = function(_, val1, val2, val3, val4)
        NS.db.global.color.r = val1
        NS.db.global.color.g = val2
        NS.db.global.color.b = val3
        NS.db.global.color.a = val4
        NS.Interface.text:SetTextColor(val1, val2, val3, val4)
      end,
      get = function(_)
        return NS.db.global.color.r, NS.db.global.color.g, NS.db.global.color.b, NS.db.global.color.a
      end,
    },
    debug = {
      name = "Toggle debug mode",
      desc = "Turning this feature on prints debug messages to the chat window.",
      type = "toggle",
      width = "full",
      order = 99,
      set = function(_, val)
        NS.db.global.debug = val
      end,
      get = function(_)
        return NS.db.global.debug
      end,
    },
    reset = {
      name = "Reset Everything",
      type = "execute",
      width = "normal",
      order = 100,
      func = function()
        HIRDB = CopyTable(NS.DefaultDatabase)
        NS.db = CopyTable(NS.DefaultDatabase)
      end,
    },
  },
}

function Options:SlashCommands(message)
  if message == "toggle lock" then
    if NS.db.global.lock == false then
      NS.db.global.lock = true
    else
      NS.db.global.lock = false
    end
  else
    LibStub("AceConfigDialog-3.0"):Open(AddonName)
  end
end

function Options:Setup()
  LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, NS.AceConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, AddonName)

  SLASH_HIR1 = AddonName
  SLASH_HIR2 = "/hir"

  function SlashCmdList.HIR(message)
    self:SlashCommands(message)
  end
end

function HIR:ADDON_LOADED(addon)
  if addon == AddonName then
    HIRFrame:UnregisterEvent("ADDON_LOADED")

    HIRDB = HIRDB and next(HIRDB) ~= nil and HIRDB or {}

    -- Copy any settings from default if they don't exist in current profile
    NS.CopyDefaults(NS.DefaultDatabase, HIRDB)

    -- Reference to active db profile
    -- Always use this directly or reference will be invalid
    NS.db = HIRDB

    -- Remove table values no longer found in default settings
    NS.CleanupDB(HIRDB, NS.DefaultDatabase)

    Options:Setup()
  end
end
HIRFrame:RegisterEvent("ADDON_LOADED")
