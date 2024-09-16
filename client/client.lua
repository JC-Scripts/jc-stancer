local isStanced = false 
local camberFront = 0.000000
local camberRear = 0.000000
local stancing = false
local whitlistedVehicle = false
local lastVehicle = nil
local heightModifier = 0

-- Need to have Camber subhandlings in handling.meta 

RegisterCommand('+stance', function (source)

    local playerId         = PlayerPedId()
    local playerVehicle    = GetVehiclePedIsIn(playerId, false)
    local suspensionHeight = GetVehicleSuspensionHeight(playerVehicle)

    -- Reset command when new vehicle is selected
    if lastVehicle ~= playerVehicle and isStanced == true then
        isStanced = false
        suspensionHeight = GetVehicleSuspensionHeight(playerVehicle)
        camberFront = 0.000000
        camberRear = 0.000000
    end

    if lastVehicle ~= playerVehicle then
        whitlistedVehicle = false
    end

    for _, vehicle in pairs(config.stancableCars) do
        if string.lower(vehicle) == string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(playerVehicle))) then
            whitlistedVehicle = true
            break
        end
    end

    if not whitlistedVehicle then
        print("This car does not support stancing. Create Handling.meta values fCamberFront, fCamberRear under <SubHandlingData> and try again")
        return
    end
    -- Prevent using command when in middle of stancing
    if stancing then
        return
    end
    
    if playerVehicle <= 0 then
        return
    end 

    -- If suspension is already lowered, lower the height decrement rate.
    if not isStanced then
        if suspensionHeight > 0.015 then
            heightModifier = 0.00070
        else
            heightModifier = 0.00130
        end
    end

    SetVehicleUseAlternateHandling(playerVehicle, true)

    if isStanced then
        SetVehicleNitroPurgeEnabled(playerVehicle, false)
        stancing = true
        for _ = 1, 80, 1 do
            Citizen.Wait(50)
            suspensionHeight = suspensionHeight - heightModifier
            camberFront = camberFront + 0.002000
            camberRear = camberRear + 0.002000
            SetVehicleSuspensionHeight(playerVehicle, suspensionHeight)
            SetVehicleHandlingField(playerVehicle, 'CCarHandlingData', 'fCamberFront', camberFront)
            SetVehicleHandlingField(playerVehicle, 'CCarHandlingData', 'fCamberRear', camberRear)
        end
        
        isStanced = false
    else
        SetVehicleNitroPurgeEnabled(playerVehicle, true)
        stancing = true
        for _ = 1, 80, 1 do
            Citizen.Wait(50)
            suspensionHeight = suspensionHeight + heightModifier
            camberFront = camberFront - 0.002000
            camberRear = camberRear - 0.002000
            SetVehicleSuspensionHeight(playerVehicle, suspensionHeight)
            SetVehicleHandlingField(playerVehicle, 'CCarHandlingData', 'fCamberFront', camberFront)
            SetVehicleHandlingField(playerVehicle, 'CCarHandlingData', 'fCamberRear', camberRear)
        end

        isStanced = true
    end
    lastVehicle = playerVehicle
    stancing = false

end)

RegisterKeyMapping('+stance', 'Stance a vehicle', 'keyboard', config.keybind)