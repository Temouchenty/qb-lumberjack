QBCore = exports['qb-core']:GetCoreObject()

local job = nil
local onduty = false
local level = 1
local doing = false
local i = nil
local blip = nil

--Easy Pixel Anti Add Item
local Code = nil
local GotCode = false

RegisterNetEvent("EP:lumberjack:GetCode")
AddEventHandler("EP:lumberjack:GetCode", function(code)
	if not GotCode then
    	Code = code
		GotCode = true
	else
		ForceSocialClubUpdate()
	end
end)


RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        job = PlayerData.job.name
        TriggerServerEvent("EP:lumberjack:ImLoaded")
        TriggerServerEvent("qb-lumberjack:addPlayer")
    end)
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload")
AddEventHandler("QBCore:Client:OnPlayerUnload", function()
    job = nil
    level = 1
    GotCode = false
    Code = nil
    onduty = false
    TriggerServerEvent("qb-lumberjack:offDuty")
    if blip then
        RemoveBlip(blip)
        blip = nil
    end
    TriggerServerEvent("qb-lumberjack:removePlayer")
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(new)
    job = new.name
    if job ~= 'lumberjack' then
        onduty = false
        TriggerServerEvent("qb-lumberjack:offDuty")
        if blip then
            RemoveBlip(blip)
            blip = nil
        end
    end
end)

RegisterNetEvent("qb-lumberjack:onPlayerLoaded")
AddEventHandler("qb-lumberjack:onPlayerLoaded", function(newL)
    level = newL
end)


RegisterNetEvent("qb-lumberjack:onLevelUpdate")
AddEventHandler("qb-lumberjack:onLevelUpdate", function(newL)
    level = newL
    NewLocation()
end)

function NewLocation()
    local old = i
    RemoveBlip(blip)
    blip = nil
    if level >= 2 then
        i = math.random(1, #Config.Boridan)
        blip = AddBlipForCoord(Config.Boridan[i].x, Config.Boridan[i].y, Config.Boridan[i].z)
    else
        i = math.random(1, #Config.Bardasht)
        blip = AddBlipForCoord(Config.Bardasht[i].x, Config.Bardasht[i].y, Config.Bardasht[i].z)
    end
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("LumberJack Work")
    EndTextCommandSetBlipName(blip)
    if i == old then
        NewLocation()
    end
end

Citizen.CreateThread(function()
    local lumberjack = AddBlipForCoord(Config.TakeIt.x, Config.TakeIt.y, Config.TakeIt.z)
    SetBlipSprite(lumberjack, 77)
    SetBlipScale(lumberjack, 0.8)
    SetBlipColour(lumberjack, 1)
    SetBlipAsShortRange(lumberjack, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("LumberJack")
    EndTextCommandSetBlipName(lumberjack)
end)

Citizen.CreateThread(function()
    local model = Config.NpcModel
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(1)
    end
    local npc = CreatePed(4, GetHashKey(model), Config.TakeIt.x, Config.TakeIt.y, Config.TakeIt.z -1,  Config.TakeIt.h, false, true)
    SetEntityHeading(npc,  Config.TakeIt.h)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                event = 'qb-lumberjack:onUpdateDuty',
                type = 'client',
                icon = "fa fa-globe",
                label = "Toggle Duty",
            },
            {
                event = 'qb-lumberjack:sellWood',
                type = 'server',
                icon = "fa fa-tree",
                label = "Sell Wood",
            },
        },
        distance = 1.5,
    })
end)

AddEventHandler("qb-lumberjack:onUpdateDuty", function()
    if job == Config.JobName or Config.NeedJob == false then
        onduty = not onduty
        if onduty then
            NewLocation()
        else
            TriggerServerEvent("qb-lumberjack:offDuty")
            if blip then
                RemoveBlip(blip)
                blip = nil
            end
        end
    else
        QBCore.Functions.Notify("You Are Not LumberJack Employee!", "error")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if job == Config.JobName or Config.NeedJob == false then
            if onduty then
                if level <= 1 then
                    if not doing then
                        local playerPed = PlayerPedId()
                        local coords = GetEntityCoords(playerPed)
                        DrawMarker(20, Config.Bardasht[i].x, Config.Bardasht[i].y, Config.Bardasht[i].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.3, 255, 0, 0, 255, false, true, 2, true, false, false, false)
                        if GetDistanceBetweenCoords(coords, Config.Bardasht[i].x, Config.Bardasht[i].y, Config.Bardasht[i].z, true) < 2.0 then
                            if IsControlPressed(1, 38) then
                                doing = true
                                GetPackage()
                            end
                        end
                    else
                        Citizen.Wait(3000)
                    end
                elseif level >= 2 then
                    if not doing then
                        local playerPed = PlayerPedId()
                        local coords = GetEntityCoords(playerPed)
                        DrawMarker(20, Config.Boridan[i].x, Config.Boridan[i].y, Config.Boridan[i].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.3, 255, 0, 0, 255, false, true, 2, true, false, false, false)
                        if GetDistanceBetweenCoords(coords, Config.Boridan[i].x, Config.Boridan[i].y, Config.Boridan[i].z, true) < 2.0 then
                            if IsControlJustReleased(1, 38) then
                                doing = true
                                FreezeEntityPosition(playerPed, true)
                                GiveWeaponToPed(playerPed, GetHashKey("WEAPON_HATCHET"),0, true, true)
                                SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_HATCHET"), false)
                                RequestAnimDict("melee@hatchet@streamed_core")
                                while (not HasAnimDictLoaded("melee@hatchet@streamed_core")) do Citizen.Wait(0) end
                                Wait(1500)
                                TaskPlayAnim(playerPed, "melee@hatchet@streamed_core", "plyr_front_takedown", 8.0, -8.0, -1, 0, 0, false, false, false)
                                Wait(2000)
                                TaskPlayAnim(playerPed, "melee@hatchet@streamed_core", "plyr_front_takedown", 8.0, -8.0, -1, 0, 0, false, false, false)
                                Wait(2000)
                                TaskPlayAnim(playerPed, "melee@hatchet@streamed_core", "plyr_front_takedown", 8.0, -8.0, -1, 0, 0, false, false, false)
                                Wait(2000)
                                TaskPlayAnim(playerPed, "melee@hatchet@streamed_core", "plyr_front_takedown", 8.0, -8.0, -1, 0, 0, false, false, false)
                                Wait(2000)
                                TaskPlayAnim(playerPed, "melee@hatchet@streamed_core", "plyr_front_takedown", 8.0, -8.0, -1, 0, 0, false, false, false)
                                Wait(2000)
                                TaskPlayAnim(playerPed, "melee@hatchet@streamed_core", "plyr_front_takedown", 8.0, -8.0, -1, 0, 0, false, false, false)
                                Wait(2000)
                                TaskPlayAnim(playerPed, "melee@hatchet@streamed_core", "plyr_front_takedown_b", 8.0, -8.0, -1, 0, 0, false, false, false)
                                Citizen.Wait(100)
                                FreezeEntityPosition(playerPed, false)
                                RemoveWeaponFromPed(PlayerPedId(), GetHashKey("WEAPON_HATCHET"), true, true)
                                TriggerServerEvent("qb-lumberjack:getReward", level, Code)
                                NewLocation()
                                doing = false
                            end
                        end
                    else
                        Citizen.Wait(3000)
                    end
                end
            else
                Citizen.Wait(3000)
            end
        else
            Citizen.Wait(5000)
        end
    end
end)

function GetPackage()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
	local prop_name = 'prop_cs_cardbox_01'
    local box = CreateObject(GetHashKey(prop_name), coords.x, coords.y, -100.0, true, true, true)
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, false)
    Wait(5000)
    ClearPedTasksImmediately(ped)
    RequestAnimDict("anim@heists@box_carry@")
	while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
        Wait(7)
    end
	TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
    Wait(100)
    AttachEntityToEntity(box, ped, GetPedBoneIndex(ped,  28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
    Citizen.CreateThread(function()
        while doing do
            Citizen.Wait(1)
            local coords = GetEntityCoords(ped)
            DrawMarker(20, Config.Tahvil.x, Config.Tahvil.y, Config.Tahvil.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.3, 255, 0, 0, 255, false, true, 2, true, false, false, false)
            if GetDistanceBetweenCoords(coords, Config.Tahvil.x, Config.Tahvil.y, Config.Tahvil.z, true) < 2.0 then
                if IsControlJustReleased(1, 38) then
                    ClearPedTasksImmediately(ped)
                    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, false)
	                DetachEntity(box, false, false)
                    PlaceObjectOnGroundProperly(box)
                    Wait(2000)
                    DeleteEntity(box)
                    ClearPedTasksImmediately(ped)
                    TriggerServerEvent("qb-lumberjack:getReward", level, Code)
                    doing = false
                    NewLocation()
                end
            end
        end
    end)
end

RegisterCommand('addworker', function(source, args)
    if args[1] then
        local id = tonumber(args[1])
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.TakeIt.x, Config.TakeIt.y, Config.TakeIt.z, true) < Config.AreaDistance then
            if onduty then
                TriggerServerEvent("qb-lumberjack:addWorker", id)
            else
                QBCore.Functions.Notify("You Are Not OnduTy!", "error")
            end
        else
            QBCore.Functions.Notify("You Are Not in Area!", "error")
        end
    else
        QBCore.Functions.Notify("Enter Id!", "error")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if job == Config.JobName or Config.NeedJob == false then
            if onduty then
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                if GetDistanceBetweenCoords(coords, Config.TakeIt.x, Config.TakeIt.y, Config.TakeIt.z, true) > Config.AreaDistance then
                    onduty = false
                    QBCore.Functions.Notify("You Have Been Off Duty!", "error")
                    TriggerServerEvent("qb-lumberjack:offDuty")
                    if blip then
                        RemoveBlip(blip)
                        blip = nil
                    end
                else
                    Citizen.Wait(3000)
                end
            else
                Citizen.Wait(5000)
            end
        else
            Citizen.Wait(5000)
        end
    end
end)