QBCore = exports['qb-core']:GetCoreObject()

local Players = {}
local Karfarma = {}

--Easy Pixel Anti Add Item
local Mani = math.random(1, 100)

RegisterServerEvent('EP:lumberjack:ImLoaded')
AddEventHandler('EP:lumberjack:ImLoaded', function()
    TriggerClientEvent('EP:lumberjack:GetCode', source, Mani)
end)

RegisterServerEvent("qb-lumberjack:addPlayer")
AddEventHandler("qb-lumberjack:addPlayer", function()
    local Source = source
    local CitizenId = QBCore.Functions.GetPlayer(Source).PlayerData.citizenid
    MySQL.query('SELECT * FROM lumberjack WHERE `citizenid`=@citizenid;',
	{
		['citizenid'] = CitizenId
	}, function(resault)
		if resault[1] then
			Players[Source] = CreatePlayer(Source, CitizenId, resault[1])
		else
            MySQL.query('INSERT INTO lumberjack (`citizenid`) VALUES (@citizenid);',
			{
				['citizenid'] = CitizenId,
			}, function(e)
				Players[Source] = CreatePlayer(Source, CitizenId, false)
			end)
		end
	end)
end)

RegisterServerEvent("qb-lumberjack:removePlayer")
AddEventHandler("qb-lumberjack:removePlayer", function()
    local Source = source
    if Players[Source] then
        MySQL.query.await('UPDATE lumberjack SET `level` = @level, `action` = @action WHERE `citizenid` = @citizenid',{
            ['level'] = Players[Source].level,
            ['action'] = Players[Source].action,
            ['citizenid'] = Players[Source].CitizenId
        })
        Players[Source] = nil
    end
end)

AddEventHandler('playerDropped', function(resoan)
    local Source = source
    if Players[Source] then
        MySQL.query.await('UPDATE lumberjack SET `level` = @level, `action` = @action WHERE `citizenid` = @citizenid',{
            ['level'] = Players[Source].level,
            ['action'] = Players[Source].action,
            ['citizenid'] = Players[Source].CitizenId
        })
        Players[Source] = nil
    end
end)

RegisterServerEvent("qb-lumberjack:getReward")
AddEventHandler("qb-lumberjack:getReward", function(level, Code)
    if Code == Mani then
        local Player = QBCore.Functions.GetPlayer(source)
        if level == 1 then
            if Karfarma[source] ~= nil then
                Player.Functions.AddMoney('cash', Config.ActionSalary + Config.Level3Price, 'LumberJack Work')
                local boss = QBCore.Functions.GetPlayer(Karfarma[source])
                if boss then
                    boss.Functions.AddMoney('cash', Config.Level3Price, 'LumberJack Boss')
                else
                    Karfarma[source] = nil
                end
            else
                Player.Functions.AddMoney('cash', Config.ActionSalary, 'LumberJack Work')
            end
        elseif level >= 2 then
            Player.Functions.AddItem(Config.woodItem, math.random(1,3))
        end
        if Players[source] then
            Players[source].newAction()
        end
    else
        print("Id: "..source.." Try to add item with "..GetCurrentResourceName())
    end
end)

RegisterServerEvent("qb-lumberjack:sellWood")
AddEventHandler("qb-lumberjack:sellWood", function()
    local Player = QBCore.Functions.GetPlayer(source)
    local count = tonumber(Player.Functions.GetItemByName(Config.woodItem).amount)
    if count > 0 then
        if Player.Functions.RemoveItem(Config.woodItem, count) then
            if Karfarma[source] ~= nil then
                Player.Functions.AddMoney('cash', (Config.WoodPrice * count) + Config.Level3Price, 'Sell Wood')
                local boss = QBCore.Functions.GetPlayer(Karfarma[source])
                if boss then
                    boss.Functions.AddMoney('cash', Config.Level3Price, "LumberJack Boss")
                else
                    Karfarma[source] = nil
                end
            else
                Player.Functions.AddMoney('cash', Config.WoodPrice * count, "Sell Wood")
            end
        end
    else
        TriggerClientEvent("QBCore:Notify", source, "You don't have Wood!", "error")
    end
end)

RegisterServerEvent("qb-lumberjack:addWorker")
AddEventHandler("qb-lumberjack:addWorker", function(id)
    local Source = source
    local Player = QBCore.Functions.GetPlayer(Source)
    if tonumber(id) ~= tonumber(Source) then
        if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(id))) <= 5 then
            if Player.PlayerData.job.name == Config.JobName or Config.NeedJob == false then
                if Players[Source].level == 3 then
                    Karfarma[id] = Source
                    TriggerClientEvent("QBCore:Notify", Source, 'You Add a Worker!', 'success')
                    TriggerClientEvent("QBCore:Notify", id, 'You Are Now Working For SomeOne!', 'success')
                else
                    TriggerClientEvent("QBCore:Notify", Source, 'You Are Not Level 3', 'error')
                end
            else
                TriggerClientEvent("QBCore:Notify", Source, 'You Are Not LumberJack!', 'error')
            end
        else
            TriggerClientEvent("QBCore:Notify", Source, 'Player Is Not Near You!', 'error')
        end
    else
        TriggerClientEvent("QBCore:Notify", Source, 'You Can Not Add YourSelf :/', 'error')
    end
end)

RegisterServerEvent("qb-lumberjack:offDuty")
AddEventHandler("qb-lumberjack:offDuty", function()
    local Source = source
    if Karfarma[Source] ~= nil then
        Karfarma[Source] = nil
    end
    if Players[Source] then
        if Players[Source].level == 3 then
            for i=1, #Karfarma, 1 do
                if Karfarma[i] == Source then
                    Karfarma[i] = nil
                end
            end
        end
    end
end)