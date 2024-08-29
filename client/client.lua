local isStanced = false 
local height = 0.00000
local camberFront = 0.000000
local camberRear = 0.000000
local stancing = false
local lastVehicle


RegisterCommand('handling', function(source, args)
    local handling = args[1]
    local playerId = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerId, false)
    local currentHandling = GetVehicleHandlingFloat(playerVehicle, 'CHandlingData', handling)
    print(currentHandling)
end)

RegisterCommand('audio', function (source, args)
    local audio = args[1]
    local playerId = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerId, false)
    ForceVehicleEngineAudio(playerVehicle, audio)
end)


-- Need to have Camber subhandlings in handling.meta 

RegisterCommand('+stance', function (source)

    local playerId      = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerId, false)

    if stancing then
        return
    end
    
    if playerVehicle <= 0 then
        return
    end 

    if lastVehicle ~= playerVehicle and isStanced == true then
        isStanced = false
        height = 0.00000
        camberFront = 0.000000
        camberRear = 0.000000
    end

    SetVehicleUseAlternateHandling(playerVehicle, true)

    if isStanced then
        SetVehicleNitroPurgeEnabled(playerVehicle, false)
        stancing = true
        for _ = 1, 80, 1 do
            Citizen.Wait(50)
            height = height - 0.00130
            camberFront = camberFront + 0.002000
            camberRear = camberRear + 0.002000
            SetVehicleSuspensionHeight(playerVehicle, height)
            SetVehicleHandlingField(playerVehicle, 'CCarHandlingData', 'fCamberFront', camberFront)
            SetVehicleHandlingField(playerVehicle, 'CCarHandlingData', 'fCamberRear', camberRear)
        end
        
        isStanced = false
    else
        SetVehicleNitroPurgeEnabled(playerVehicle, true)
        stancing = true
        for _ = 1, 80, 1 do
            Citizen.Wait(50)
            height = height + 0.00130
            camberFront = camberFront - 0.002000
            camberRear = camberRear - 0.002000
            SetVehicleSuspensionHeight(playerVehicle, height)
            SetVehicleHandlingField(playerVehicle, 'CCarHandlingData', 'fCamberFront', camberFront)
            SetVehicleHandlingField(playerVehicle, 'CCarHandlingData', 'fCamberRear', camberRear)
        end

        isStanced = true
    end
    lastVehicle = playerVehicle
    stancing = false

end)

RegisterKeyMapping('+stance', 'Stance a vehicle', 'keyboard', 'k')