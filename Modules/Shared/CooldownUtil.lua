-- For Midnight Secret

local _, addon = ...
local API = addon.API;

local CooldownUtil = {};
addon.CooldownUtil = CooldownUtil;


local GetSpellCooldown = API.GetSpellCooldown;
local GetSpellCharges = API.GetSpellCharges;
local GetItemCooldown = C_Container.GetItemCooldown;


if not addon.IS_MIDNIGHT then
    function CooldownUtil.SetSpellCooldown(cooldownFrame, spellID)
        local startTime, duration, modRate, fromChargeCooldown;

        local chargeInfo = GetSpellCharges(spellID);
        if chargeInfo and chargeInfo.currentCharges > 0 then
            if chargeInfo.cooldownStartTime > 0 and chargeInfo.cooldownDuration > 0 then
                startTime = chargeInfo.cooldownStartTime;
                duration = chargeInfo.cooldownDuration;
                modRate = chargeInfo.chargeModRate;
                fromChargeCooldown = true;
            end
        end

        if not (startTime and duration) then
            local cooldownInfo = GetSpellCooldown(spellID);
            if cooldownInfo and cooldownInfo.isEnabled and cooldownInfo.startTime > 0 and cooldownInfo.duration > 0 then
                startTime = cooldownInfo.startTime;
                duration = cooldownInfo.duration;
                modRate = cooldownInfo.modRate
            end
        end

        if startTime and duration then
            cooldownFrame:SetCooldown(startTime, duration, modRate);
            cooldownFrame:Show();
            if fromChargeCooldown then
                cooldownFrame:SetHideCountdownNumbers(true);
            else
                cooldownFrame:SetHideCountdownNumbers(false);
            end
        else
            cooldownFrame:Hide();
            cooldownFrame:Clear();
        end
    end
else
    local GetSpellCooldownDuration = C_Spell.GetSpellCooldownDuration;

    function CooldownUtil.SetSpellCooldown(cooldownFrame, spellID)
        --[[ --Unsuable in combat
        local duo = C_DurationUtil.CreateDuration();
        local chargeInfo = GetSpellCharges(spellID);
        local fromChargeCooldown;

        if chargeInfo then
            duo:SetTimeFromStart(chargeInfo.cooldownStartTime, chargeInfo.cooldownDuration, chargeInfo.chargeModRate);
            if not duo:IsZero() then
                fromChargeCooldown = true;
            end
        end

        if not fromChargeCooldown then
            local cooldownInfo = GetSpellCooldown(spellID);
            if cooldownInfo then
                duo:SetTimeFromStart(cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.modRate);
            end
        end
        --]]

        local duo = GetSpellCooldownDuration(spellID);
        if duo then
            cooldownFrame:SetCooldownFromDurationObject(duo);
            cooldownFrame:SetHideCountdownNumbers(false);
            cooldownFrame:Show();
        else
            cooldownFrame:Hide();
            cooldownFrame:Clear();
        end
    end
end



-- Shared

function CooldownUtil.SetItemCooldown(cooldownFrame, itemID)
    --ItemCooldown seems to be non-secret
    local startTime, duration, enable = GetItemCooldown(itemID);
    if enable == 1 and startTime and startTime > 0 and duration and duration > 0 then
        cooldownFrame:SetCooldown(startTime, duration);
        cooldownFrame:Show();
        cooldownFrame:SetHideCountdownNumbers(false);
    else
        cooldownFrame:Hide();
        cooldownFrame:Clear();
    end
end

function CooldownUtil.UpdateSpellButtonCooldowns(buttons)
    if not buttons then return end;
    for _, button in ipairs(buttons) do
        if button.id and button.actionType == "spell" then
            CooldownUtil.SetSpellCooldown(button.Cooldown, button.id);
        end
    end
end

function CooldownUtil.UpdateItemButtonCooldowns(buttons)
    if not buttons then return end;
    for _, button in ipairs(buttons) do
        if button.id and button.actionType == "item" then
            CooldownUtil.SetItemCooldown(button.Cooldown, button.id);
        end
    end
end
