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
RegisterServerEvent('drivingschool:checkLicense')
AddEventHandler('drivingschool:checkLicense', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasLicense = exports.ox_inventory:HasItem(source, Config.LicenseItem)

    if hasLicense then
        TriggerClientEvent('drivingschool:notify', source, 'Du hast bereits einen Führerschein.')
    else
        if xPlayer.getMoney() >= Config.DrivingSchoolPrice then
            xPlayer.removeMoney(Config.DrivingSchoolPrice)
            TriggerClientEvent('drivingschool:startTest', source)
        else
            TriggerClientEvent('drivingschool:notify', source, 'Du hast nicht genug Geld.')
        end
    end
end)

RegisterServerEvent('drivingschool:giveLicense')
AddEventHandler('drivingschool:giveLicense', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    exports.ox_inventory:AddItem(source, Config.LicenseItem, 1)
end)



GithubUpdater = function()
    GetCurrentVersion = function()
	    return GetResourceMetadata( GetCurrentResourceName(), "version" )
    end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "^4["..GetCurrentResourceName().."]^0"

    if Config.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/NoxiZ95/Development/main/VERSION', function(Error, NewestVersion, Header)
            print("###############################")
            if CurrentVersion == NewestVersion then
                print(resourceName .. '^2 ✓ Keine Updates verfügbar^0 - ^5Aktuelle Version: ^2' .. CurrentVersion .. '^0')
            elseif CurrentVersion ~= NewestVersion then
                print(resourceName .. '^1 ✗ Update verfügbar!^0 - ^5Aktuelle Version: ^1' .. CurrentVersion .. '^0')
                print('^5Neuste Version: ^2' .. NewestVersion .. '^0 - ^6Download:^9 https://github.com/MSK-Scripts/msk_trackphone/releases/tag/v'.. NewestVersion .. '^0')
            end
            print("###############################")
        end)
    else
        print("###############################")
        print(resourceName .. '^2 ✓ Resource loaded^0')
        print("###############################")
    end
end
GithubUpdater()