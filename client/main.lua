local QBCore = exports['qb-core']:GetCoreObject()
local src = source

local function GetRandomPrice(min, max)
    return math.random(min, max)
end

local function GenerateBlackMarketItems()
    local items = {}
    for _, item in ipairs(Config.BlackMarketItems) do
        table.insert(items, {
            name = item.name,
            itemID = item.itemID,
            price = GetRandomPrice(item.priceRange.min, item.priceRange.max),
            event = item.event,
        })
    end
    return items
end

RegisterNetEvent('smdx-blackmarket:Openblackmarket')
AddEventHandler('smdx-blackmarket:Openblackmarket', function()
    local chance = math.random()
    local items = GenerateBlackMarketItems()
    QBCore.Functions.Notify(Config.WelcomeMessage, 'success', 5000)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openUI', data = { products = items } })

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    if chance <= Config.ChanceValue then
        if Config.DispatchSystem == "qb-dispatch" then
            TriggerEvent('police:client:policeAlert', playerCoords, Config.Disptachmessage)
        elseif Config.DispatchSystem == "ps-dispatch" then
            exports["ps-dispatch"]:BlackmarketTrading()
        elseif Config.DispatchSystem == "none" then
            ---Add your custom dispatch system here, Or contact us via our discord if you want us to add any.
        end
    end
end)

local function OpenBlackMarketUI()
    local items = GenerateBlackMarketItems()
    QBCore.Functions.Notify(Config.ConnectingBM, 'success', 5000)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openUI', data = { products = items } })
end

function OpenBlackMarketUI()
    local items = GenerateBlackMarketItems() 
    QBCore.Functions.Notify(Config.ConnectingBM, 'success', 5000)
    SetNuiFocus(true, true)
        print(json.encode({
        action = 'openUI',
        data = { products = items }
    })) 
    SendNUIMessage({
        action = 'openUI',
        data = {
            products = items
        }
    })
end

RegisterNetEvent('smdx-blackmarket:useItem')
AddEventHandler('smdx-blackmarket:useItem', function()
    if not IsBlackMarketActive() then
        QBCore.Functions.Notify(Config.NotAvailable, 'error', 5000)
        return
    end
    OpenBlackMarketUI()
end)

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('buyItem', function(data, cb)
    local item = data.item
    if item and item.price then
        local price = tonumber(item.price)
        if price then
            TriggerServerEvent(item.event)
            if Config.Discordlogs then
                TriggerServerEvent('logItemPurchase', { playerName = GetPlayerName(PlayerId()), item = item })
            end
        else
            print("Price is not a valid number")
        end
    else
        print("Felaktig item data mottagen")
    end
    cb('ok')
end)

RegisterNetEvent('smdx-blackmarket:startProgressBar')
AddEventHandler('smdx-blackmarket:startProgressBar', function(itemPrice, itemName, itemID)
    exports['progressbar']:Progress({
        name = "buying_" .. itemName:lower() .. "_bm",
        duration = 5000,
        label = Config.Buying .. itemName,
        useWhileDead = false,
        canCancel = true,
        controlDisables = { disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true },
        animation = { animDict = "switch@michael@talks_to_guard", anim = "001393_02_mics3_3_talks_to_guard_idle_guard", flags = 49 }
    }, function(cancelled)
        if not cancelled then
            TriggerServerEvent("smdx-blackmarket:completePurchase", itemPrice, itemName, itemID)
        else
            QBCore.Functions.Notify(Config.Action, 'error', 5000)
        end
    end)
end)

RegisterNetEvent('smdx-blackmarket:noMoney')
AddEventHandler('smdx-blackmarket:noMoney', function()
    QBCore.Functions.Notify(Config.NotEnough, 'error')
end)

RegisterNetEvent('smdx-blackmarket:boughtItem')
AddEventHandler('smdx-blackmarket:boughtItem', function(itemName)
    QBCore.Functions.Notify(Config.YouBought .. itemName, 'error', 5000)
end)

function IsBlackMarketActive()
    local currentHour = GetClockHours()
    local startHour, endHour = Config.BlackMarketActiveTimes.startHour, Config.BlackMarketActiveTimes.endHour
    return (startHour < endHour and currentHour >= startHour and currentHour < endHour) or
           (startHour >= endHour and (currentHour >= startHour or currentHour < endHour))
end

local pedSpawned, BMPed, lastPedChangeTime = false, nil, 0

local function CreateBMPed()
    local settings, models, locations, scenarios = Config.PedSettings, Config.PedSettings.models, Config.PedSettings.locations, Config.PedSettings.scenarios
    local pedModel = models[math.random(#models)]
    local loc = locations[math.random(#locations)]
    local pedScenario = scenarios[math.random(#scenarios)]

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(0) end

    if BMPed then
        DeletePed(BMPed)
        BMPed = nil
    end

    BMPed = CreatePed(0, pedModel, loc.coords, loc.heading, false, false)
    FreezeEntityPosition(BMPed, true)
    SetEntityInvincible(BMPed, true)
    TaskStartScenarioInPlace(BMPed, pedScenario, 0, true)

    exports['qb-target']:AddTargetEntity(BMPed, {
        options = { { type = "client", event = "smdx-blackmarket:Openblackmarket", icon = "fas fa-user", label = Config.BlackmarketPed } },
        distance = 2.0
    })
end

local function ManagePed()
    local currentTime = GetGameTimer()
    if IsBlackMarketActive() then
        if not pedSpawned then
            CreateBMPed()
            pedSpawned = true
        elseif (currentTime - lastPedChangeTime) / 1000 >= Config.PedSettings.PedChangeIntervalHours * 3600 then
            DeletePed(BMPed)
            CreateBMPed()
            lastPedChangeTime = currentTime
        end
    elseif BMPed then
        DeletePed(BMPed)
        BMPed = nil
        pedSpawned = false
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        if Config.UsePed then
            ManagePed()
        elseif BMPed then
            DeletePed(BMPed)
            BMPed = nil
            pedSpawned = false
        end
    end
end)

local function AddBlip()
    if not Config.BlipSettings.enabled then return end
    local settings = Config.BlipSettings
    local blip = AddBlipForCoord(settings.coords[1].coords)
    SetBlipSprite(blip, settings.sprite)
    SetBlipDisplay(blip, settings.display)
    SetBlipScale(blip, settings.scale)
    SetBlipColour(blip, settings.color)
    SetBlipAsShortRange(blip, settings.shortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(settings.label)
    EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(AddBlip)
