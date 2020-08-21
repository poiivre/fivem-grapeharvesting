local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local InvRaisin       		= 0
local InvJus 			= 0

local myJob 			= nil
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('seln_Vendange:hasEnteredMarker', function(zone)

	ESX.UI.Menu.CloseAll()
	
	if zone == 'Recolte' then
		CurrentAction     = 'Recolte'
		CurrentActionMsg  = Notif1
		CurrentActionData = {}

	elseif zone == 'Traitement' then
		if InvRaisin >= 5 then
			CurrentAction     = 'Traitement'
			CurrentActionMsg  = Notif2
			CurrentActionData = {}
		end
	elseif zone == 'Vente' then
		if InvJus >= 1 then
			CurrentAction     = 'Vente'
			CurrentActionMsg  = Notif3
			CurrentActionData = {}
		end
	end
end)

AddEventHandler('seln_Vendange:hasExitedMarker', function(zone)
	CurrentAction = nil

	TriggerServerEvent('seln_Vendange:stopHarvestVendange')
	TriggerServerEvent('seln_Vendange:stopTransformVendange')
	TriggerServerEvent('seln_Vendange:stopSellVendange')

end)

-- Marker
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		local coords = GetEntityCoords(GetPlayerPed(-1))

		v = Vendange.Traitement
		if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Vendange.Distance then
			DrawMarker(Vendange.Type, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Vendange.Taille.x, Vendange.Taille.y, Vendange.Taille.z, Vendange.Couleur.r, Vendange.Couleur.g, Vendange.Couleur.b, 100, false, true, 2, false, false, false, false)
		end

		v = Vendange.Vente
		if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Vendange.Distance then
			DrawMarker(Vendange.Type, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Vendange.Taille.x, Vendange.Taille.y, Vendange.Taille.z, Vendange.Couleur.r, Vendange.Couleur.g, Vendange.Couleur.b, 100, false, true, 2, false, false, false, false)
		end

	end
end)

RegisterNetEvent('seln_Vendange:ReturnInventory')
AddEventHandler('seln_Vendange:ReturnInventory', function(Raisin, Jus, job, Zone)
	InvRaisin	= Raisin
	InvJus		= Jus
	myJob		= job
	TriggerEvent('seln_Vendange:hasEnteredMarker', Zone)
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil


		v = Vendange.Recolte
		if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 100) then
			isInMarker  = true
			currentZone = 'Recolte'
		end


		v = Vendange.Traitement
		if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Vendange.Taille.x ) then
			isInMarker  = true
			currentZone = 'Traitement'
		end

		v = Vendange.Vente
		if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Vendange.Taille.x ) then
			isInMarker  = true
			currentZone = 'Vente'
		end


		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			lastZone 		= currentZone
			TriggerServerEvent('seln_Vendange:GetUserInventory', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('seln_Vendange:hasExitedMarker', lastZone)
		end
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) and IsPedOnFoot(PlayerPedId()) then
				if CurrentAction == 'Recolte' then
					TriggerServerEvent('seln_Vendange:startHarvestVendange')
				elseif CurrentAction == 'Traitement' then
					TriggerServerEvent('seln_Vendange:startTransformVendange')
				elseif CurrentAction == 'Vente' then
					TriggerServerEvent('seln_Vendange:startSellVendange')
				end
				
				CurrentAction = nil
			end
		end
	end
end)
