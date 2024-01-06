local _, NS = ...

local Interface = NS.Interface

local LibStub = LibStub
local CreateFrame = CreateFrame

HIR = LibStub("AceAddon-3.0"):NewAddon("HIR", "AceEvent-3.0")

-- Range Checker
do
  --- @class HealerInRangeFrame
  --- @field inRange boolean|nil

  --- @type HealerInRangeFrame|Frame|nil
  local healerInRangeFrame = nil
  local timeElapsed = 0

  local function InRangeChecker(_, elapsed)
    timeElapsed = timeElapsed + elapsed
    if timeElapsed > 0.1 then
      timeElapsed = 0

      local inRange = NS.isHealerInRange()

      if healerInRangeFrame and healerInRangeFrame.inRange ~= inRange then
        healerInRangeFrame.inRange = inRange
        Interface.inRange = inRange

        NS.ToggleVisibility(inRange, HIR.db.global.reverse)
      end
    end
  end

  function HIR:CheckForHealerInRange()
    local inRange = NS.isHealerInRange()

    if not healerInRangeFrame then
      healerInRangeFrame = CreateFrame("Frame")
      --- @cast healerInRangeFrame HealerInRangeFrame
      healerInRangeFrame.inRange = inRange
      Interface.inRange = inRange
    end

    NS.ToggleVisibility(inRange, HIR.db.global.reverse)

    if NS.isInGroup() then
      healerInRangeFrame:SetScript("OnUpdate", InRangeChecker)
    else
      healerInRangeFrame:SetScript("OnUpdate", nil)
      Interface.textFrame:Hide()
    end
  end

  function HIR:GROUP_ROSTER_UPDATE()
    self:CheckForHealerInRange()
  end
end

function HIR:PLAYER_ENTERING_WORLD()
  if NS.isInGroup() then
    self:CheckForHealerInRange()
  end

  self:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function HIR:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("HIRDB", NS.DefaultDatabase, true)
  self:SetupOptions()
end

function HIR:OnEnable()
  Interface:CreateInterface()

  self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
