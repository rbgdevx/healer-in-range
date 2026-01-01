local AddonName, NS = ...

local CopyTable = CopyTable
local next = next
local LibStub = LibStub
local IsInInstance = IsInInstance

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
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
            NS.Interface.textFrame:SetAlpha(0)
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
          NS.ToggleVisibility(NS.isHealerInRange(), NS.db.global.reverse)
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
          NS.ToggleVisibility(NS.isHealerInRange(), NS.db.global.reverse)
        end
      end,
      get = function(_)
        return NS.db.global.healer
      end,
    },
    showOutside = {
      name = "Show outside of instances",
      type = "toggle",
      width = "double",
      order = 5,
      set = function(_, val)
        NS.db.global.showOutside = val
        if not IsInInstance() then
          if val then
            NS.Interface.textFrame:Show()
            NS.Interface.textFrame:SetAlpha(1)
            local inRange = NS.isHealerInRange()
            NS.ToggleVisibility(inRange, NS.db.global.reverse)
          else
            NS.Interface.textFrame:SetAlpha(0)
          end
        end
      end,
      get = function(_)
        return NS.db.global.showOutside
      end,
    },
    spacer1 = { name = "", type = "description", order = 6, width = "full" },
    enableRange = {
      name = "Watch a specific distance:",
      desc = "This only works outdoors and not in instanced content (raids/dungeons/delves/battlegrounds/arena)",
      type = "toggle",
      width = 1.15,
      order = 7,
      disabled = function()
        return IsInInstance()
      end,
      set = function(_, val)
        NS.db.global.enableRange = val

        if val then
          if NS.trim(NS.db.global.range) == "" then
            NS.AceConfig.args.spacer2.name = "Distance tracker won't run without a number provided."
          else
            NS.AceConfig.args.spacer2.name = ""
          end

          if not tonumber(NS.db.global.range) and NS.trim(NS.db.global.range) ~= "" then
            NS.AceConfig.args.rangeError.name = "Must be a number."
          end
        else
          NS.AceConfig.args.rangeError.name = ""
          NS.AceConfig.args.spacer2.name = ""
        end
      end,
      get = function(_)
        return NS.db.global.enableRange
      end,
    },
    rangeOperator = {
      name = "",
      desc = "",
      type = "select",
      width = 0.4,
      order = 8,
      values = {
        ["<="] = "<=",
        [">="] = ">=",
      },
      disabled = function()
        return not NS.db.global.enableRange or IsInInstance()
      end,
      set = function(_, val)
        NS.db.global.rangeOperator = val
      end,
      get = function(_)
        return NS.db.global.rangeOperator
      end,
    },
    gap1 = {
      name = "",
      desc = "",
      type = "description",
      order = 9,
      width = 0.025,
    },
    range = {
      name = "",
      desc = "",
      type = "input",
      width = 0.75,
      order = 10,
      disabled = function()
        return not NS.db.global.enableRange or IsInInstance()
      end,
      set = function(_, val)
        NS.db.global.range = val

        if NS.trim(val) == "" then
          NS.AceConfig.args.spacer2.name = "Distance tracker won't run without a number provided."
        else
          NS.AceConfig.args.spacer2.name = ""
        end

        -- ensure val can be converted to a number
        local num = tonumber(val)
        if not num and NS.trim(val) ~= "" then
          NS.AceConfig.args.rangeError.name = "Must be a number."
        else
          NS.AceConfig.args.rangeError.name = ""
        end
      end,
      get = function(_)
        if NS.db.global.enableRange and NS.trim(NS.db.global.range) == "" then
          NS.AceConfig.args.spacer2.name = "Distance tracker won't run without a number provided."
        end
        return NS.db.global.range
      end,
    },
    gap2 = {
      name = "",
      desc = "",
      type = "description",
      order = 11,
      width = 0.01,
    },
    rangeError = {
      name = "",
      type = "description",
      order = 12,
      width = 1.0,
      disabled = function()
        return not NS.db.global.enableRange
      end,
    },
    spacer2 = { name = " ", type = "description", order = 13, width = "full" },
    fontSize = {
      type = "range",
      name = "Font Size",
      width = "double",
      order = 14,
      min = 2,
      max = 64,
      step = 1,
      set = function(_, val)
        NS.db.global.fontSize = val
        NS.UpdateFont(NS.Interface.text)
        NS.Interface.textFrame:SetWidth(NS.Interface.text:GetStringWidth())
        NS.Interface.textFrame:SetHeight(NS.Interface.text:GetStringHeight())
      end,
      get = function(_)
        return NS.db.global.fontSize
      end,
    },
    spacer3 = { name = " ", type = "description", order = 15, width = "full" },
    font = {
      type = "select",
      name = "Font",
      width = 1.5,
      dialogControl = "LSM30_Font",
      values = SharedMedia:HashTable("font"),
      order = 16,
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
    spacer4 = { name = "", type = "description", order = 17, width = 0.1 },
    color = {
      type = "color",
      name = "Color",
      width = 0.5,
      order = 18,
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
    spacer5 = { type = "description", order = 19, name = " ", width = "full" },
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
      NS.Interface:Lock(NS.Interface.textFrame)
    else
      NS.db.global.lock = false
      NS.Interface:Unlock(NS.Interface.textFrame)
    end
  else
    AceConfigDialog:Open(AddonName)
  end
end

function Options:Setup()
  AceConfig:RegisterOptionsTable(AddonName, NS.AceConfig)
  AceConfigDialog:AddToBlizOptions(AddonName, AddonName)

  SLASH_HIR1 = "/healerinrange"
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
