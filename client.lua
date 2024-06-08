--[[#######################################################]]
--[[### #          ### | ###        ### | ### #######      ]]
--[[### ##         ### |  ###      ###  | ### #########    ]]
--[[### ###        ### |   ###    ###   | ###        ###   ]]
--[[###  ###       ### |    ###  ###    | ###         ###  ]]
--[[###   ###      ### |     ######     | ###          ### ]]
--[[###    ###     ### |      ####      | ###           ###]]
--[[###     ###    ### |      ####      | ###          ### ]]
--[[###      ###   ### |     ######     | ###         ###  ]]
--[[###       ###  ### |    ###  ###    | ###        ###   ]]
--[[###        ### ### |   ###    ###   | ###       ###    ]]
--[[###         ## ### |  ###      ###  | ### ########     ]]
--[[###          # ### | ###        ### | ### ######       ]]
--[[#######################################################]]
--### MADE BY NoxiZ95 #####################################]]
ESX = exports["es_extended"]:getSharedObject()
local isInTest = false
local vehicle
local currentCheckpoint = 1
local errorCount = 0

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.StartPoint.x, Config.StartPoint.y, Config.StartPoint.z)
    SetBlipSprite(blip, 198)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.5)
    SetBlipColour(blip, 0)
    SetBlipAsShortRange(blip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Fahrschule") -- Name des Blips
    EndTextCommandSetBlipName(blip)

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if not isInTest and GetDistanceBetweenCoords(playerCoords, Config.StartPoint, true) < 5.0 then
            exports['codem-textui']:OpenTextUI("Fahrprüfung starten","E","thema-8")
            --ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um die Fahrschule zu starten.')

            if IsControlJustReleased(0, 38) then -- E Taste
                TriggerServerEvent('drivingschool:checkLicense')
                exports['codem-textui']:CloseTextUI()
            end
        end
    end
end)

RegisterNetEvent('drivingschool:notify')
AddEventHandler('drivingschool:notify', function(message)
    ESX.ShowNotification(message)
end)

RegisterNetEvent('drivingschool:startTest')
AddEventHandler('drivingschool:startTest', function()
    isInTest = true
    errorCount = 0
    currentCheckpoint = 1

    -- Spawn Fahrzeug
    local vehicleModel = GetHashKey(Config.VehicleModel)
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Citizen.Wait(0)
    end

    local playerPed = PlayerPedId()
    vehicle = CreateVehicle(vehicleModel, Config.VehicleSpawnPoint, 0.0, true, false)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

    SetNewWaypoint(Config.Checkpoints[currentCheckpoint].x, Config.Checkpoints[currentCheckpoint].y)

    ESX.ShowNotification('Fahre zum ersten Checkpoint.')
    exports['codem-textui']:CloseTextUI()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInTest then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local vehicleHealth = GetEntityHealth(vehicle)

            if GetDistanceBetweenCoords(playerCoords, Config.Checkpoints[currentCheckpoint], true) < 5.0 then
                currentCheckpoint = currentCheckpoint + 1

                if currentCheckpoint > #Config.Checkpoints then
                    EndTest()
                else
                    SetNewWaypoint(Config.Checkpoints[currentCheckpoint].x, Config.Checkpoints[currentCheckpoint].y)
                    ESX.ShowNotification('Fahre zum nächsten Checkpoint.')
                end
            end

            if IsEntityDead(vehicle) or vehicleHealth < 1000 then
                errorCount = errorCount + 1
                SetEntityHealth(vehicle, 1000)
            end
        end
    end
end)

function EndTest()
    isInTest = false
    DeleteVehicle(vehicle)

    if errorCount < Config.MaxErrors then
        TriggerServerEvent('drivingschool:giveLicense')
        ESX.ShowNotification('Herzlichen Glückwunsch! Du hast die Prüfung bestanden.')
    else
        ESX.ShowNotification('Du bist durchgefallen. Versuche es erneut.')
    end
end