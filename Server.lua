ESX 					= nil
local PlayersHarvestingVendange    	= {}
local PlayersTransformingVendange  	= {}
local PlayersSellingVendange       	= {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


local function HarvestVendange(source)

	SetTimeout(Vendange.TempsRecolte, function()
		if PlayersHarvestingVendange[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local ItemRaisin = xPlayer.getInventoryItem('raisin')

			if ItemRaisin.limit ~= -1 and ItemRaisin.count >= ItemRaisin.limit then
				TriggerClientEvent('esx:showNotification', source, Notif4)
			else
				xPlayer.addInventoryItem('raisin', 1)
				HarvestVendange(source)
			end
		end
	end)
end

RegisterServerEvent('seln_Vendange:startHarvestVendange')
AddEventHandler('seln_Vendange:startHarvestVendange', function()
	local _source = source

	if not PlayersHarvestingVendange[_source] then
		PlayersHarvestingVendange[_source] = true

		TriggerClientEvent('esx:showNotification', _source, Notif5)
		HarvestVendange(_source)
	else
		print(('seln_Vendange: %s Tentative de Glitch ( Recolte )!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('seln_Vendange:stopHarvestVendange')
AddEventHandler('seln_Vendange:stopHarvestVendange', function()
	local _source = source

	PlayersHarvestingVendange[_source] = false
end)

local function TransformVendange(source)

	SetTimeout(Vendange.TempsTraite, function()
		if PlayersTransformingVendange[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local InvRaisin = xPlayer.getInventoryItem('raisin').count
			local InvJus = xPlayer.getInventoryItem('jusraisin')

			if InvJus.limit ~= -1 and InvJus.count >= InvJus.limit then
				TriggerClientEvent('esx:showNotification', source, Notif6)
			elseif InvRaisin < 2 then
				TriggerClientEvent('esx:showNotification', source, Notif6)
			else
				xPlayer.removeInventoryItem('raisin', 2)
				xPlayer.addInventoryItem('jusraisin', 1)

				TransformVendange(source)
			end
		end
	end)
end

RegisterServerEvent('seln_Vendange:startTransformVendange')
AddEventHandler('seln_Vendange:startTransformVendange', function()
	local _source = source

	if not PlayersTransformingVendange[_source] then
		PlayersTransformingVendange[_source] = true

		TriggerClientEvent('esx:showNotification', _source, Notif7)
		TransformVendange(_source)
	else
		print(('seln_Vendange: %s Tentative de Glitch ( Traitement )!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('seln_Vendange:stopTransformVendange')
AddEventHandler('seln_Vendange:stopTransformVendange', function()
	local _source = source

	PlayersTransformingVendange[_source] = false
end)

local function SellVendange(source)

	SetTimeout(Vendange.TempsVente, function()
		if PlayersSellingVendange[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local InvJus = xPlayer.getInventoryItem('jusraisin').count

			if InvJus == 0 then
				TriggerClientEvent('esx:showNotification', source, Notif8)
			else
				xPlayer.removeInventoryItem('jusraisin', InvJus)
				local prixunitaire 	= Vendange.Prix
				local thunasses 	= InvJus*prixunitaire
				TriggerClientEvent('esx:showNotification', source, '~g~'..InvJus..Notif9..thunasses..' $')
				
				xPlayer.addAccountMoney('bank', thunasses)
				SellVendange(source)
			end
		end
	end)
end

RegisterServerEvent('seln_Vendange:startSellVendange')
AddEventHandler('seln_Vendange:startSellVendange', function()
	local _source = source

	if not PlayersSellingVendange[_source] then
		PlayersSellingVendange[_source] = true

		SellVendange(_source)
	else
		print(('seln_Vendange: %s Tentative de Glitch ( Vente )!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('seln_Vendange:stopSellVendange')
AddEventHandler('seln_Vendange:stopSellVendange', function()
	local _source = source

	PlayersSellingVendange[_source] = false
end)

RegisterServerEvent('seln_Vendange:GetUserInventory')
AddEventHandler('seln_Vendange:GetUserInventory', function(currentZone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('seln_Vendange:ReturnInventory',
		_source,
		xPlayer.getInventoryItem('raisin').count,
		xPlayer.getInventoryItem('jusraisin').count,
		xPlayer.job.name,
		currentZone
	)
end)
