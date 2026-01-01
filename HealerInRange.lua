local _, NS = ...

local Interface = NS.Interface

local CreateFrame = CreateFrame
local IsInInstance = IsInInstance

---@type HIR
local HIR = NS.HIR
local HIRFrame = NS.HIR.frame

-- Range Checker
do
  --- @class HealerInRangeFrame
  --- @field inRange boolean|nil
  --- @field SetScript fun(scriptType: string, handler: function|nil)

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

        NS.ToggleVisibility(inRange, NS.db.global.reverse)
      end
    end
  end

  function HIR:CheckForHealerInRange()
    if IsInInstance() then
      if NS.isInGroup() then
        if NS.noHealersInGroup() then
          NS.ToggleVisibility(false, false)

          if healerInRangeFrame then
            ---@type HealerInRangeFrame
            healerInRangeFrame:SetScript("OnUpdate", nil)
          end
        else
          local inRange = NS.isHealerInRange()

          if not healerInRangeFrame then
            healerInRangeFrame = CreateFrame("Frame")
            --- @cast healerInRangeFrame HealerInRangeFrame
            healerInRangeFrame.inRange = inRange
            Interface.inRange = inRange
          end

          NS.ToggleVisibility(inRange, NS.db.global.reverse)

          ---@type HealerInRangeFrame
          healerInRangeFrame:SetScript("OnUpdate", InRangeChecker)
        end
      else
        if healerInRangeFrame then
          ---@type HealerInRangeFrame
          healerInRangeFrame:SetScript("OnUpdate", nil)
        end

        -- Test mode handled by NS.ToggleVisibility, otherwise hide.
        NS.ToggleVisibility(false, false)
      end
    else
      if NS.db.global.showOutside then
        if NS.isInGroup() then
          if NS.noHealersInGroup() then
            NS.ToggleVisibility(false, false)

            if healerInRangeFrame then
              ---@type HealerInRangeFrame
              healerInRangeFrame:SetScript("OnUpdate", nil)
            end
          else
            local inRange = NS.isHealerInRange()

            if not healerInRangeFrame then
              healerInRangeFrame = CreateFrame("Frame")
              --- @cast healerInRangeFrame HealerInRangeFrame
              healerInRangeFrame.inRange = inRange
              Interface.inRange = inRange
            end

            NS.ToggleVisibility(inRange, NS.db.global.reverse)

            ---@type HealerInRangeFrame
            healerInRangeFrame:SetScript("OnUpdate", InRangeChecker)
          end
        else
          if healerInRangeFrame then
            ---@type HealerInRangeFrame
            healerInRangeFrame:SetScript("OnUpdate", nil)
          end

          -- Test mode handled by NS.ToggleVisibility, otherwise hide.
          NS.ToggleVisibility(false, false)
        end
      else
        -- Test mode handled by NS.ToggleVisibility, otherwise hide.
        NS.ToggleVisibility(false, false)
      end
    end
  end

  function HIR:GROUP_ROSTER_UPDATE()
    self:CheckForHealerInRange()
  end
end

function HIR:PLAYER_UNGHOST()
  self:CheckForHealerInRange()
end

function HIR:PLAYER_DEAD()
  self:CheckForHealerInRange()
end

local DEAD_EVENTS = {
  "PLAYER_DEAD",
  "PLAYER_UNGHOST",
}

function HIR:PLAYER_ENTERING_WORLD()
  FrameUtil.RegisterFrameForEvents(HIRFrame, DEAD_EVENTS)

  if IsInInstance() then
    if NS.isInGroup() then
      if NS.isDead("player") then
        NS.ToggleVisibility(false, false)
      else
        if NS.db.global.healer then
          if NS.isHealer("player") then
            NS.ToggleVisibility(false, false)
          else
            if NS.noHealersInGroup() then
              NS.ToggleVisibility(false, false)
            else
              NS.ToggleVisibility(NS.isHealerInRange(), NS.db.global.reverse)
            end
          end
        else
          if NS.noHealersInGroup() then
            NS.ToggleVisibility(false, false)
          else
            NS.ToggleVisibility(NS.isHealerInRange(), NS.db.global.reverse)
          end
        end
      end
    else
      NS.ToggleVisibility(false, false)
    end
  else
    if NS.db.global.showOutside then
      if NS.isInGroup() then
        if NS.isDead("player") then
          NS.ToggleVisibility(false, false)
        else
          if NS.db.global.healer then
            if NS.isHealer("player") then
              NS.ToggleVisibility(false, false)
            else
              if NS.noHealersInGroup() then
                NS.ToggleVisibility(false, false)
              else
                NS.ToggleVisibility(NS.isHealerInRange(), NS.db.global.reverse)
              end
            end
          else
            if NS.noHealersInGroup() then
              NS.ToggleVisibility(false, false)
            else
              NS.ToggleVisibility(NS.isHealerInRange(), NS.db.global.reverse)
            end
          end
        end
      else
        NS.ToggleVisibility(false, false)
      end
    else
      NS.ToggleVisibility(false, false)
    end
  end

  self:CheckForHealerInRange()

  HIRFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function HIR:PLAYER_LOGIN()
  HIRFrame:UnregisterEvent("PLAYER_LOGIN")

  Interface:CreateInterface()

  HIRFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end
HIRFrame:RegisterEvent("PLAYER_LOGIN")
