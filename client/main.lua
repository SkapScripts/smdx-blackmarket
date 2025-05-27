local QBCore = exports['qb-core']:GetCoreObject()
if Config.TargetSystem ~= "ox" and Config.TargetSystem ~= "qb" then
    error("[SkapBlackMarket] Invalid TargetSystem: " .. tostring(Config.TargetSystem))
end
local function GetRandomPrice(min, max)
    return math.random(min, max)
end

function IsBlackMarketActive()
    local currentHour = GetClockHours()
    local startHour, endHour = Config.BlackMarketActiveTimes.startHour, Config.BlackMarketActiveTimes.endHour
    return (startHour < endHour and currentHour >= startHour and currentHour < endHour) or
           (startHour >= endHour and (currentHour >= startHour or currentHour < endHour))
end

AddEventHandler('SkapBlackMarket:Openblackmarket', function(data)
    print("[💡] Data in:", json.encode(data))
    local pedKey = type(data) == "table" and data.args or data
    print("[✅] Använder pedKey:", pedKey)

    if type(pedKey) ~= "string" then
        print("[❌] pedKey måste vara en sträng. Fick istället:")
        print(json.encode(pedKey))
        return
    end

    if not IsBlackMarketActive() then
        QBCore.Functions.Notify(Config.NotAvailable, 'error', 5000)
        return
    end

    local pedConfig = Config.BlackMarketPeds[pedKey]
    if not pedConfig then
        print("[❌] Ingen ped-konfiguration hittades för:", pedKey)
        return
    end

    QBCore.Functions.Notify(Config.WelcomeMessage, 'success', 5000)

    local allItems = {}
    for _, item in pairs(pedConfig.items) do
        table.insert(allItems, item)
    end

    for i = #allItems, 2, -1 do
        local j = math.random(i)
        allItems[i], allItems[j] = allItems[j], allItems[i]
    end

    local selectedItems = {}
    for i = 1, math.min(3, #allItems) do
        if allItems[i] and allItems[i].priceRange then
            local price = GetRandomPrice(allItems[i].priceRange.min, allItems[i].priceRange.max)
            table.insert(selectedItems, {
                name = allItems[i].name,
                itemID = allItems[i].itemID,
                price = price,
                iconPath = allItems[i].iconPath or "nui://qs-inventory/html/images/default.png" -- ✅ detta är nyckeln!
            })
        else
            print("[❌] Ogiltigt item:", json.encode(allItems[i]))
        end
    end
    

    print("[📦] Skickar följande items till meny:", json.encode(selectedItems))

    if Config.BlackMarketMenuType == "nui" then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openUI",
            data = { products = selectedItems }
        })

    elseif Config.BlackMarketMenuType == "qb" then
        local menu = {
            {
                header = pedConfig.label or "Blackmarket",
                isMenuHeader = true
            }
        }

        for _, item in ipairs(selectedItems) do
            table.insert(menu, {
                header = ("%s - $%s"):format(item.name, item.price),
                txt = "Klicka för att köpa",
                icon = "fas fa-box",
                params = {
                    event = "SkapBlackMarket:tryBuyItem",
                    args = item
                }
            })
        end

        exports['qb-menu']:openMenu(menu)

    elseif Config.BlackMarketMenuType == "ox" then
        local options = {}
    
        for _, item in ipairs(selectedItems) do
            table.insert(options, {
                title = ("%s - $%s"):format(item.name, item.price),
                description = "Tryck för att köpa",
                icon = "box",
                image = item.iconPath or "nui://qs-inventory/html/images/default.png",
                onSelect = function()
                    TriggerEvent("SkapBlackMarket:tryBuyItem", item)
                end
            })
        end
    
        lib.registerContext({
            id = 'blackmarket_menu',
            title = pedConfig.label or "Blackmarket",
            options = options
        })
    
        lib.showContext('blackmarket_menu')
    end
    
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    if math.random() <= Config.ChanceValue then
        if Config.DispatchSystem == "qb-dispatch" then
            TriggerEvent('police:client:policeAlert', playerCoords, Config.Disptachmessage)
        elseif Config.DispatchSystem == "ps-dispatch" then
            exports["ps-dispatch"]:BlackmarketTrading()
        elseif Config.DispatchSystem == "cd-dispatch" then
            local data = exports['cd_dispatch']:GetPlayerInfo()
            TriggerServerEvent('cd_dispatch:AddNotification', {
                job_table = { Config.PoliceJob },
                coords = data.coords,
                title = '10-15 - Blackmarket Trade',
                message = 'A ' .. data.sex .. ' is buying illegalities at ' .. data.street,
                flash = 0,
                unique_id = data.unique_id,
                sound = 1,
                blip = {
                    sprite = 431,
                    scale = 1.2,
                    colour = 3,
                    flashes = false,
                    text = 'Blackmarket Trade',
                    time = 5,
                    radius = 0
                }
            })
        end
    end
end)


RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('buyItem', function(data, cb)
    local item = data.item
    if item and item.price and item.itemID and item.name then
        local price = tonumber(item.price)
        print("📦 Försöker köpa:", item.name, price, item.itemID)
        TriggerServerEvent("SkapBlackMarket:attemptPurchase", item.itemID, item.name, price)
    else
        print("❌ Felaktig item data mottagen")
    end
    cb('ok')
end)

RegisterNetEvent('SkapBlackMarket:startProgressBar')
AddEventHandler('SkapBlackMarket:startProgressBar', function(itemPrice, itemName, itemID)
    exports['progressbar']:Progress({
        name = "buying_" .. itemName:lower() .. "_bm",
        duration = 5000,
        label = Config.Buying .. itemName,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true
        },
        animation = {
            animDict = "switch@michael@talks_to_guard",
            anim = "001393_02_mics3_3_talks_to_guard_idle_guard",
            flags = 49
        }
    }, function(cancelled)
        if not cancelled then
            TriggerServerEvent("SkapBlackMarket:completePurchase", itemPrice, itemName, itemID)
        else
            QBCore.Functions.Notify(Config.Action, 'error', 5000)
            TriggerServerEvent("SkapBlackMarket:logCanceled", itemName)
        end
    end)
end)

RegisterNetEvent('SkapBlackMarket:useItem')
AddEventHandler('SkapBlackMarket:useItem', function()
    if not IsBlackMarketActive() then
        QBCore.Functions.Notify(Config.NotAvailable, 'error', 5000)
        return
    end

    local allItems = {}
    for _, item in pairs(Config.TabletItems) do
        table.insert(allItems, item)
    end
    for i = #allItems, 2, -1 do
        local j = math.random(i)
        allItems[i], allItems[j] = allItems[j], allItems[i]
    end

    local selectedItems = {}
    for i = 1, math.min(3, #allItems) do
        if allItems[i] and allItems[i].priceRange then
            local price = GetRandomPrice(allItems[i].priceRange.min, allItems[i].priceRange.max)
            table.insert(selectedItems, {
                name = allItems[i].name,
                itemID = allItems[i].itemID,
                price = price,
                iconPath = allItems[i].iconPath or "nui://qs-inventory/html/images/default.png" 
            })
        else
            print("[❌] Ogiltigt item:", json.encode(allItems[i]))
        end
    end
    

    QBCore.Functions.Notify(Config.WelcomeMessage, 'success', 5000)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openUI",
        data = { products = selectedItems }
    })
end)


RegisterNetEvent('SkapBlackMarket:noMoney')
AddEventHandler('SkapBlackMarket:noMoney', function()
    QBCore.Functions.Notify(Config.NotEnough, 'error')
end)

RegisterNetEvent('SkapBlackMarket:boughtItem')
AddEventHandler('SkapBlackMarket:boughtItem', function(itemName)
    QBCore.Functions.Notify(Config.YouBought .. itemName, 'success', 5000)
    TriggerServerEvent("SkapBlackMarket:Bought", itemName)
end)

local spawnedPeds = {}

local function SpawnAllBlackMarketPeds()
    for pedKey, pedData in pairs(Config.BlackMarketPeds) do
        RequestModel(pedData.model)
        while not HasModelLoaded(pedData.model) do Wait(0) end

        local pedCoordsList = pedData.coords
        if type(pedCoordsList) ~= "table" then
            pedCoordsList = { pedCoordsList } -- för backward compat om coords är en enskild vector4
        end

        for i, pos in ipairs(pedCoordsList) do
            local pedName = ("%s_%d"):format(pedKey, i)
            local ped = CreatePed(0, pedData.model, pos.xyz, pos.w, false, false)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)

            local scenarioList = pedData.scenarios or Config.DefaultScenarios
            local scenario = scenarioList[math.random(#scenarioList)]
            TaskStartScenarioInPlace(ped, scenario, 0, true)

           if Config.TargetSystem == "ox" then
            exports.ox_target:addLocalEntity(ped, {
        {
            name = "open_blackmarket_" .. pedKey,
            icon = "fas fa-user-secret",
            label = pedData.label or "Blackmarket",
            onSelect = function()
                TriggerEvent("SkapBlackMarket:Openblackmarket", { args = pedKey })
            end
        }
    })
else
    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = "client",
                event = "SkapBlackMarket:Openblackmarket",
                icon = "fas fa-user-secret",
                label = pedData.label or "Blackmarket",
                args = pedKey
            }
        },
        distance = 2.0
    })
end

            spawnedPeds[pedName] = ped
        end
    end
end

RegisterNetEvent("SkapBlackMarket:tryBuyItem", function(item)
    if not item or not item.itemID or not item.name or not item.price then return end

    TriggerEvent("SkapBlackMarket:startProgressBar", item.price, item.name, item.itemID)
end)


CreateThread(SpawnAllBlackMarketPeds)