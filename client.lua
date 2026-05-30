local Config = {
    ThirdPersonMode = 1, -- 0 = far, 1 = medium, 2 = close
    AdditionalMelee = {
        -- [`WEAPON_YOUR_CUSTOM_MELEE`] = true,
    },
}

local function isMeleeEquipped(ped)
    local _, weapon = GetCurrentPedWeapon(ped, true)
    if not weapon or weapon == 0 or weapon == `WEAPON_UNARMED` then
        return true
    end
    if Config.AdditionalMelee[weapon] then return true end
    return GetWeapontypeGroup(weapon) == `GROUP_MELEE`
end

local function isFightingMelee(ped)
    if not isMeleeEquipped(ped) then return false end
    if IsPedInMeleeCombat(ped) then return true end
    return IsControlPressed(0, 24) or IsControlPressed(0, 25)
end

local lastTPMode = Config.ThirdPersonMode

local function forceThirdPerson()
    local mode = GetFollowPedCamViewMode()
    if mode == 4 then
        lastTPMode = (lastTPMode + 1) % 3
        SetFollowPedCamViewMode(lastTPMode)
    else
        lastTPMode = mode
    end
    for i = 0, 31 do
        if GetCamViewModeForContext(i) == 4 then
            SetCamViewModeForContext(i, lastTPMode)
        end
    end
end

CreateThread(function()
    Wait(500)
    while true do
        local ped = PlayerPedId()
        if isFightingMelee(ped) and not IsPedInAnyVehicle(ped, true) then
            forceThirdPerson()
            DisableFirstPersonCamThisFrame()
            Wait(0)
        else
            Wait(200)
        end
    end
end)