local AddonName, NS = ...

local LibStub = LibStub

local HIR = LibStub("AceAddon-3.0"):GetAddon("HIR")

NS.AceConfig = {
  name = AddonName,
  type = "group",
  args = {
    lock = {
      name = "Lock the text into place",
      type = "toggle",
      width = "double",
      set = function(_, val)
        HIR.db.global.lock = val
        if val then
          NS.Interface:Lock(NS.Interface.textFrame)
        else
          NS.Interface:Unlock(NS.Interface.textFrame)
        end
      end,
      get = function(_)
        return HIR.db.global.lock
      end,
    },
    test = {
      name = "Toggle on to test settings (out of group)",
      desc = "Only works outside of a group.",
      type = "toggle",
      width = "double",
      set = function(_, val)
        HIR.db.global.test = val
        if NS.isInGroup() == false then
          if val then
            NS.Interface.textFrame:Show()
          else
            NS.Interface.textFrame:Hide()
          end
        end
      end,
      get = function(_)
        return HIR.db.global.test
      end,
    },
    reverse = {
      name = "Show Healer out of range instead",
      type = "toggle",
      width = "double",
      set = function(_, val)
        -- true = show out of range
        -- false = show in range
        HIR.db.global.reverse = val
        NS.UpdateText(NS.Interface.text, val)
        if NS.isInGroup() then
          local inRange = NS.isHealerInRange()
          NS.ToggleVisibility(inRange, val)
        end
      end,
      get = function(_)
        return HIR.db.global.reverse
      end,
    },
    fontsize = {
      type = "range",
      name = "Font Size",
      width = "double",
      min = 1,
      max = 500,
      step = 1,
      set = function(_, val)
        HIR.db.global.fontsize = val
        NS.UpdateFont(NS.Interface.text)
        NS.Interface.textFrame:SetWidth(NS.Interface.text:GetStringWidth())
        NS.Interface.textFrame:SetHeight(NS.Interface.text:GetStringHeight())
      end,
      get = function(_)
        return HIR.db.global.fontsize
      end,
    },
    font = {
      type = "select",
      name = "Font",
      width = "double",
      dialogControl = "LSM30_Font",
      values = AceGUIWidgetLSMlists.font,
      set = function(_, val)
        HIR.db.global.font = val
        NS.UpdateFont(NS.Interface.text)
        NS.Interface.textFrame:SetWidth(NS.Interface.text:GetStringWidth())
        NS.Interface.textFrame:SetHeight(NS.Interface.text:GetStringHeight())
      end,
      get = function(_)
        return HIR.db.global.font
      end,
    },
    color = {
      type = "color",
      name = "Color",
      width = "double",
      hasAlpha = true,
      set = function(_, val1, val2, val3, val4)
        HIR.db.global.color.r = val1
        HIR.db.global.color.g = val2
        HIR.db.global.color.b = val3
        HIR.db.global.color.a = val4
        NS.Interface.text:SetTextColor(val1, val2, val3, val4)
      end,
      get = function(_)
        return HIR.db.global.color.r, HIR.db.global.color.g, HIR.db.global.color.b, HIR.db.global.color.a
      end,
    },
  },
}

function HIR:SetupOptions()
  LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, NS.AceConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, AddonName)
end
