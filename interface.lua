local AddonName, NS = ...

local CreateFrame = CreateFrame
local LibStub = LibStub

local Interface = {}
NS.Interface = Interface

function Interface:StopMovement(frame)
  frame:SetMovable(false)
end

function Interface:MakeMoveable(frame)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(f)
    if HIR.db.global.lock == false then
      f:StartMoving()
    end
  end)
  frame:SetScript("OnDragStop", function(f)
    if HIR.db.global.lock == false then
      f:StopMovingOrSizing()
      local a, _, b, c, d = f:GetPoint()
      HIR.db.global.position[1] = a
      HIR.db.global.position[2] = b
      HIR.db.global.position[3] = c
      HIR.db.global.position[4] = d
    end
  end)
end

function Interface:Lock(frame)
  self:StopMovement(frame)
end

function Interface:Unlock(frame)
  self:MakeMoveable(frame)
end

function Interface:AddControls(frame)
  frame:EnableMouse(true)
  frame:SetScript("OnMouseUp", function(_, btn)
    if btn == "RightButton" then
      LibStub("AceConfigDialog-3.0"):Open(AddonName)
    end
  end)

  if HIR.db.global.lock then
    self:StopMovement(frame)
  else
    self:MakeMoveable(frame)
  end
end

function Interface:CreateInterface()
  if not Interface.textFrame then
    local TextFrame = CreateFrame("Frame", "HIRInterfaceTextFrame", UIParent)
    TextFrame:SetClampedToScreen(true)
    TextFrame:SetPoint(
      HIR.db.global.position[1],
      UIParent,
      HIR.db.global.position[2],
      HIR.db.global.position[3],
      HIR.db.global.position[4]
    )

    local Text = TextFrame:CreateFontString(nil, "OVERLAY")
    Text:SetTextColor(HIR.db.global.color.r, HIR.db.global.color.g, HIR.db.global.color.b, HIR.db.global.color.a)
    Text:SetShadowOffset(0, 0)
    Text:SetShadowColor(0, 0, 0, 1)
    Text:SetJustifyH("CENTER")
    Text:SetJustifyV("MIDDLE")
    Text:SetPoint("CENTER", TextFrame, "CENTER", 0, 0)

    NS.UpdateFont(Text)
    NS.UpdateText(Text, HIR.db.global.reverse)

    Interface.text = Text
    Interface.textFrame = TextFrame

    self:AddControls(Interface.textFrame)

    TextFrame:SetWidth(Text:GetStringWidth())
    TextFrame:SetHeight(Text:GetStringHeight())

    if NS.isInGroup() then
      local inRange = NS.isHealerInRange()
      NS.ToggleVisibility(inRange, HIR.db.global.reverse)
    else
      if HIR.db.global.test then
        TextFrame:Show()
      else
        TextFrame:Hide()
      end
    end
  end
end

function Interface:ShowText(value)
  if NS.isInGroup() then
    if value then
      Interface.textFrame:Show()
    else
      Interface.textFrame:Hide()
    end
  else
    Interface.textFrame:Hide()
  end
end
