
local function getClosestPlayer(distance)
	local allPlayers = {}
    local coordsPlayer = GetEntityCoords(cache.ped)
    local coords = lib.getNearbyPlayers(coordsPlayer, 2.5, true)
	for i = 1, #coords do
		local players = coords[i]
		local playerName = lib.callback.await('krs_contract:gePlayerName', false, GetPlayerServerId(players.id))
		playerData = {
			playerId = GetPlayerServerId(players.id),
			playerName = playerName
		}
		table.insert(allPlayers, playerData)
		-- print(json.encode(playerData))
	end

    return allPlayers
end

local function openContractMenu()
	local playerPed = cache.ped
    local coords = GetEntityCoords(playerPed)
    local vehicle = lib.getClosestVehicle(coords, 3.0, false)
	local props = lib.getVehicleProperties(vehicle)
	if not vehicle then return end
    local playerData = getClosestPlayer()

	if type(playerData) ~= "table" then
        playerData = { playerData }
    end

    local options = {}
    for _, v in pairs(playerData) do
      print(json.encode(v, {indent = true}))
        table.insert(options, {
            label = v.playerName,
            value = v.playerId
        })
    end

	local input = lib.inputDialog('Krs Contract', {
		{type = 'select', label = 'Player Search', options =  options, icon = 'fa-solid fa-magnifying-glass'},  
		{type = 'textarea', label = 'Description', description = 'Vehicle model', icon = 'fa-solid fa-pen'},
		{type = 'number', label = 'Amount', description = 'Price of the vehicle', icon = 'fa-solid fa-file-invoice-dollar', min = 1}, 
		{type = 'checkbox', label = 'Confirm', required = true}
	  })

    if not input then return end
	  local data = {
		playerId = input[1],
		vehicleDescription = input[2],
		priceContract = input[3]
	  }

	  data.plate = props.plate
	  TriggerServerEvent('krs_contract:sendAlert', data)

end

RegisterNetEvent('krs_contract:confirmPurchase', function(data)
	print(json.encode(data))
	local string = ('model: %s  \n Plate: %s  \n Price: $%s'):format(data.vehicleDescription, data.plate, data.priceContract)
	local alert = lib.alertDialog({
		header = 'Are you sure about selling your vehicle?',
		content = string,
		centered = false,
		cancel = true
	})
	if alert == 'confirm' then
		TriggerEvent('krs_contract:getVehicle', data)
	end
end)

RegisterNetEvent('krs_contract:getVehicle', function(data)
    local playerPed = cache.ped
    local coords = GetEntityCoords(playerPed)
    local vehicle = lib.getClosestVehicle(coords, 3.0, false)
    
    if DoesEntityExist(vehicle) then
		local vehProps = lib.getVehicleProperties(vehicle)
		TriggerServerEvent('krs_contract:sellVehicle', data.playerId, vehProps.plate, data.vehicleDescription, data.priceContract)
    else
		lib.notify({title = 'Krs Contract', description = 'No vehicles nearby', type = 'error'})
    end
end)

RegisterNetEvent('krs_contract:showAnim', function(player)
	lib.progressCircle({
		duration = 3000,
		label = 'Sale in progress...',
		position = 'middle',
		useWhileDead = false,
		canCancel = true,
		disable = {
			car = true,
			move = true,
			combat = true,
			sprint = true,
			mouse = true
		},
		anim = {
			dict = 'amb@code_human_wander_clipboard@male@base',
			clip = 'static'
		},
		prop = {
			model = "p_amb_clipboard_01",
			pos = vec3(0.03, 0.03, 0.02),
			rot = vec3(0.0, 0.0, -1.5)
		},
	}) 
end)

exports('contract', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
        if data then
			openContractMenu()
        end
    end)
end)