local QBCore = exports['qb-core']:GetCoreObject()

local function GetRandomPrice(priceRange)
    return math.random(priceRange.min, priceRange.max)
end

for _, item in ipairs(Config.BlackMarketItems) do
    RegisterServerEvent(item.event)
    AddEventHandler(item.event, function()
        local src = source
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if not item.priceRange then
            print("Error: Price range not defined for item: " .. item.name)
            return
        end

        local itemPrice = GetRandomPrice(item.priceRange)
        if xPlayer.Functions.GetMoney(Config.MoneyType) >= itemPrice then
            TriggerClientEvent("smdx-blackmarket:startProgressBar", src, itemPrice, item.name, item.itemID)
        else
            TriggerClientEvent('smdx-blackmarket:noMoney', src)
        end
    end)
end

RegisterNetEvent("smdx-blackmarket:completePurchase")
AddEventHandler("smdx-blackmarket:completePurchase", function(itemPrice, itemName, itemID)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if xPlayer.Functions.GetMoney(Config.MoneyType) >= itemPrice then
        xPlayer.Functions.RemoveMoney(Config.MoneyType, itemPrice)
        xPlayer.Functions.AddItem(itemID, 1)
        TriggerClientEvent('smdx-blackmarket:boughtItem', src, itemName)
    else
        TriggerClientEvent('smdx-blackmarket:noMoney', src)
    end
end)

QBCore.Functions.CreateUseableItem(Config.BlackMarketItem, function(source)
    TriggerClientEvent('smdx-blackmarket:useItem', source)
end)

RegisterServerEvent('logItemPurchase')
AddEventHandler('logItemPurchase', function(logData)
    local message = {
        ["username"] = Config.DiscordName,
        ["embeds"] = {{
            ["title"] = Config.Titel,
            ["description"] = string.format("**Player:** %s\n**Item:** %s\n**Price:** %s", logData.playerName, logData.item.name, logData.item.price),
            ["color"] = 16711680
        }}
    }
    PerformHttpRequest(Config.DiscordWebhookURL, function(statusCode)
        print("Webhook skickad med statuskod: " .. statusCode)
    end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end)
