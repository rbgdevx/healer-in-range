local AddonName, NS = ...

local CreateFrame = CreateFrame
local LibStub = LibStub
local IsInInstance = IsInInstance
local issecretvalue = issecretvalue or function(_)
  return false
end

local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local Interface = {}
NS.Interface = Interface

local function CanInteractWithFrame(frame)
  if not frame or not frame.IsVisible or not frame:IsVisible() then
    return false
  end
  local alpha = frame:GetAlpha()
  return (not issecretvalue(alpha)) and alpha ~= 0
end

function Interface:MakeUnmovable(frame)
  frame:SetMovable(false)
  frame:RegisterForDrag()
  frame:SetScript("OnDragStart", nil)
  frame:SetScript("OnDragStop", nil)
end

function Interface:MakeMoveable(frame)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(f)
    if NS.db.global.lock == false and CanInteractWithFrame(frame) then
      f:StartMoving()
    end
  end)
  frame:SetScript("OnDragStop", function(f)
    if NS.db.global.lock == false and CanInteractWithFrame(frame) then
      f:StopMovingOrSizing()
      local a, _, b, c, d = f:GetPoint()
      NS.db.global.position[1] = a
      NS.db.global.position[2] = b
      NS.db.global.position[3] = c
      NS.db.global.position[4] = d
    end
  end)
end

function Interface:RemoveControls(frame)
  frame:EnableMouse(false)
  frame:SetScript("OnMouseUp", nil)
end

function Interface:AddControls(frame)
  frame:EnableMouse(true)
  frame:SetScript("OnMouseUp", function(_, btn)
    if NS.db.global.lock == false and not IsInInstance() and self:CanInteractWithFrame(frame) then
      if btn == "RightButton" then
        AceConfigDialog:Open(AddonName)
      end
    end
  end)
end

function Interface:Lock(frame)
  self:RemoveControls(frame)
  self:MakeUnmovable(frame)
end

function Interface:Unlock(frame)
  self:AddControls(frame)
  self:MakeMoveable(frame)
end

function Interface:CreateInterface()
  if not Interface.textFrame then
    local TextFrame = CreateFrame("Frame", "HIRInterfaceTextFrame", UIParent)
    TextFrame:SetClampedToScreen(true)
    TextFrame:SetPoint(
      NS.db.global.position[1],
      UIParent,
      NS.db.global.position[2],
      NS.db.global.position[3],
      NS.db.global.position[4]
    )

    local Text = TextFrame:CreateFontString(nil, "OVERLAY")
    Text:SetTextColor(NS.db.global.color.r, NS.db.global.color.g, NS.db.global.color.b, NS.db.global.color.a)
    Text:SetShadowOffset(0, 0)
    Text:SetShadowColor(0, 0, 0, 1)
    Text:SetJustifyH("CENTER")
    Text:SetJustifyV("MIDDLE")
    Text:SetPoint("CENTER", TextFrame, "CENTER", 0, 0)

    NS.UpdateFont(Text)
    NS.UpdateText(Text, NS.db.global.reverse)

    Interface.text = Text
    Interface.textFrame = TextFrame

    if NS.db.global.lock then
      self:Lock(Interface.textFrame)
    else
      self:Unlock(Interface.textFrame)
    end

    TextFrame:SetWidth(Text:GetStringWidth())
    TextFrame:SetHeight(Text:GetStringHeight())

    -- All visibility logic is now handled by Interface:ShowText()
    self:ShowText()
  end
end

function Interface:ShowText()
  local frame = Interface.textFrame
  if not frame then
    return
  end

  -- *** Test mode always forces visibility ***
  -- If test mode is active, show the frame and set alpha to 1, then return immediately.
  if NS.db.global.test then
    frame:Show()
    frame:SetAlpha(1)
    return
  end

  local shouldShowFrame = false

  -- Only evaluate other conditions if test mode is NOT active.
  if IsInInstance() then
    if NS.isInGroup() and not NS.isDead("player") then
      if NS.db.global.healer then
        if not NS.isHealer("player") and not NS.noHealersInGroup() then
          shouldShowFrame = true
        end
      else
        if not NS.noHealersInGroup() then
          shouldShowFrame = true
        end
      end
    end
  else -- not IsInInstance()
    if NS.db.global.showOutside and NS.isInGroup() and not NS.isDead("player") then
      if NS.db.global.healer then
        if not NS.isHealer("player") and not NS.noHealersInGroup() then
          shouldShowFrame = true
        end
      else
        if not NS.noHealersInGroup() then
          shouldShowFrame = true
        end
      end
    end
  end

  if shouldShowFrame then
    frame:Show()
    -- Delegate final alpha setting to NS.ToggleVisibility, which handles SetAlphaFromBoolean
    NS.ToggleVisibility(NS.isHealerInRange(), NS.db.global.reverse)
  else
    frame:Hide()
    frame:SetAlpha(0) -- Ensure it is fully transparent when hidden
  end
end
