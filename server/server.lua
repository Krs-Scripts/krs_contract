
lib.callback.register('krs_contract:gePlayerName', function(source, target)
    local xPlayer = ESX.GetPlayerFromId(target)
    local playerName = xPlayer.getName()

    log(string.format("Retrieved player name: %s for target: %d", playerName, target), cfg.discordWebhook, 3386850)
    return playerName
end)

RegisterNetEvent('krs_contract:sendAlert', function(data)
    log(string.format("Sending alert to player: %d with data: %s", source, json.encode(data)), cfg.discordWebhook, 3386850)
    TriggerClientEvent('krs_contract:confirmPurchase', source, data)
end)

RegisterNetEvent('krs_contract:sellVehicle', function(target, plate, description, priceContract)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local _target = target
    local tPlayer = ESX.GetPlayerFromId(_target)

    log(string.format("Initiating vehicle sale by source: %d to target: %d, Plate: %s, Price: %d", _source, _target, plate, priceContract), cfg.discordWebhook, 3386850)

    local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?', {
        xPlayer.identifier, plate
    })

    if result[1] then
        log(string.format("Vehicle found in database for source: %d, Identifier: %s, Plate: %s", _source, xPlayer.identifier, plate), cfg.discordWebhook, 3386850)

        local success = exports.ox_inventory:RemoveItem(_target, 'money', priceContract)
        if success then
            exports.ox_inventory:AddItem(_source, 'money', priceContract)

            log(string.format("Transaction successful. Money transferred from target: %d to source: %d. Amount: %d", _target, _source, priceContract), cfg.discordWebhook, 3386850)

            local rowsChanged = MySQL.update.await('UPDATE owned_vehicles SET owner = ? WHERE owner = ? AND plate = ?', {
                tPlayer.identifier, xPlayer.identifier, plate
            })

            if rowsChanged ~= 0 then
                log(string.format("Ownership updated successfully. New Owner: %s, Plate: %s", tPlayer.identifier, plate), cfg.discordWebhook, 3386850)

                TriggerClientEvent('krs_contract:showAnim', _source)
                Wait(1000)
                TriggerClientEvent('krs_contract:showAnim', _target)
                TriggerClientEvent('ox_lib:notify', _source, {title = 'Krs Contract', description = ("You sold the vehicle with the following license plate: %s"):format(plate), type = 'success'}) 
                TriggerClientEvent('ox_lib:notify', _target, {title = 'Krs Contract', description = ("You bought the vehicle with the following license plate: %s"):format(plate), type = 'success'}) 
                exports.ox_inventory:RemoveItem(_source, 'contract', 1)
                exports.ox_inventory:AddItem(_target, 'contract', 1)

                log(string.format("Contract item transferred from source: %d to target: %d for vehicle plate: %s", _source, _target, plate), cfg.discordWebhook, 3386850)
            else
                log("Error: Failed to update vehicle ownership in the database.", cfg.discordWebhook, 16711680)
            end
        else
            log(string.format("Error: Failed to remove money from target: %d's inventory.", _target), cfg.discordWebhook, 16711680)
        end
    else
        log(string.format("Error: Vehicle not found or not owned by source: %d, Plate: %s", _source, plate), cfg.discordWebhook, 16711680)
        TriggerClientEvent('ox_lib:notify', _target, {title = 'Krs Contract', description = "This is not your vehicle", type = 'error'}) 
    end
end)

function log(description, webhook, color)
    PerformHttpRequest(webhook, function()
    end, "POST", json.encode({
        embeds = { {
            author = {
                name = "Krs Logs",
                icon_url = "https://cdn.discordapp.com/attachments/1212234946605748242/1274305516486660138/krs.png?ex=6735c8fe&is=6734777e&hm=fac0f5e5c48349fd254ed6b1cc32f697567bb4f54905aa22a8d8259030948a75&"
            },
            title = "Krs Contract",
            description = description,
            color = color
        } }
    }), { ["Content-Type"] = "application/json" })
end