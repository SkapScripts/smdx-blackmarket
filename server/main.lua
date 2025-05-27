local WebhookURL = "https://discord.com/api/webhooks/1358657511808565349/Ypl1nezfaoy82Wyim0p7JnZ_PhSVs_0e4E-tttTafFSKxvL6zGcPVC4-NCVLX2MbknlU"

RegisterNetEvent("SkapBlackMarket:attemptPurchase", function(itemID, itemName, itemPrice)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local playerName = GetPlayerName(src)

    print(("[🛠️ Server] %s försöker köpa %s (%s) för %d"):format(playerName, itemName, itemID, itemPrice))

    if not xPlayer then return end

    if xPlayer.Functions.GetMoney(Config.MoneyType) >= itemPrice then
        TriggerClientEvent("SkapBlackMarket:startProgressBar", src, itemPrice, itemName, itemID)
        LogToDiscord("🛒 Köpförsök", ("**%s** försöker köpa **%s** för **%d kr**"):format(playerName, itemName, itemPrice))
    else
        TriggerClientEvent("SkapBlackMarket:noMoney", src)
        LogToDiscord("❌ Misslyckat köp", ("**%s** försökte köpa **%s** för **%d kr**, men hade inte tillräckligt med pengar."):format(playerName, itemName, itemPrice))
    end
end)


RegisterNetEvent("SkapBlackMarket:completePurchase", function(itemPrice, itemName, itemID)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local playerName = GetPlayerName(src)

    print(("[✅ Slutför köp] %s vill köpa %s för %d"):format(playerName, itemID, itemPrice))
    if not xPlayer then return end

    if xPlayer.Functions.GetMoney(Config.MoneyType) >= itemPrice then
        xPlayer.Functions.RemoveMoney(Config.MoneyType, itemPrice)

        local metadata = nil
        if Config.GiveAmmo and string.sub(itemID, 1, 7) == "weapon_" then
            metadata = { ammo = Config.DefaultAmmo }
        end

        local added = xPlayer.Functions.AddItem(itemID, 1, nil, metadata)
        TriggerClientEvent("SkapBlackMarket:boughtItem", src, itemName)

        LogToDiscord("✅ Slutfört köp", ("**%s** köpte **%s** för **%d kr**."):format(playerName, itemName, itemPrice))
    else
        TriggerClientEvent("SkapBlackMarket:noMoney", src)
        LogToDiscord("❌ Misslyckat slutförande", ("**%s** försökte slutföra köp av **%s** för **%d kr**, men hade inte pengar."):format(playerName, itemName, itemPrice))
    end
end)


local function LogToDiscord(title, description)
    if not Config.Discordlogs then return end
    local message = {
        ["username"] = Config.DiscordName,
        ["embeds"] = {{
            ["title"] = Config.Titel,
            ["description"] = description,
            ["color"] = Config.Color, 
            ["footer"] = { ["text"] = "Blackmarket Logs" },
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    }
    PerformHttpRequest(WebhookURL, function(err, text, headers)
        if err == 204 then
            print("[Blackmarket] Webhook skickad")
        else
            print("[Blackmarket] Webhook FEL: ", err)
        end
    end, "POST", json.encode(message), { ["Content-Type"] = "application/json" })
end

RegisterNetEvent("SkapBlackMarket:logCanceled", function(itemName)
    local src = source
    local playerName = GetPlayerName(src)
    LogToDiscord("⚠️ Canceled purchase", ("**%s** canceled his purchase of **%s**."):format(playerName, itemName))
end)

RegisterNetEvent("SkapBlackMarket:Bought", function(itemName)
    local src = source
    local playerName = GetPlayerName(src)
    LogToDiscord("⚠️ Bought", ("**%s** Bought a **%s**."):format(playerName, itemName))
end)
