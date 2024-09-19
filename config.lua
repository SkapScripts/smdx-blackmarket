local QBCore = exports['qb-core']:GetCoreObject()

-----------------------
-- CONFIGURATION --
-----------------------
Config = {}

Config.MoneyType = 'bank' -- Choose between cash/bank.

Config.Lang = "ENG" -- ENG for english, SWE for Swedish.

Config.DispatchSystem = "ps-disptach"-- to disable it so the police don't get alerted. Just use "none", For QB standard "qb-disptach", For ps use "ps-dispatch. If you want us to add any, Open a ticket in our discord!
Config.ChanceValue = 0.5 -- 50 = 50% chance the police will get alerted.

------------------
-- DISCORD LOGS --
------------------

Config.Discordlogs = true --True if you want to use discord logs.
Config.DiscordWebhookURL = "YOU_DISCORD_WEBHOOK_URL_HERE"
Config.DiscordName = "BlackMarket Logger"
Config.Titel = "Item Purchase Log"
Config.Color = 16711680 -- Red color

------------------
-- PED SETTINGS --
------------------

Config.UsePed = true  -- Set to true if you want to use ped system, Set to false if you want to use item system.
Config.BlackMarketItem = "blackmarketipad" -- Blackmarket item name.

Config.PedSettings = {
    models = { -- List with different ped models that randomizes every restart. (along with the loc)
        "a_m_m_business_01",
        "s_m_y_dealer_01",
        "g_m_m_chigoon_01"
    },
    locations = {
        -- {coords = vector3(910.68, -1065.23, 36.94), heading = 87.06}, -- Choose where you want the ped to spawn. These is randomized between every server restart.
        {coords = vector3(472.04, -1078.16, 28.35), heading = 186.48}
        -- {coords = vector3(652.53, -1166.85, 11.84), heading = 185.23}
    },
    scenarios = { -- List of scenarios that the ped can perform (change to your own liking: https://github.com/DioneB/gtav-scenarios)
        "WORLD_HUMAN_STAND_MOBILE",
        "WORLD_HUMAN_SMOKING",
        "WORLD_HUMAN_CHEERING"
    },
    PedChangeIntervalHours = 1 -- Time in hours before ped changes location
}

------------------
-- TIME SETTINGS --
------------------
Config.BlackMarketActiveTimes = {
    startHour = 13,  -- Starttime (13:00)
    endHour = 08     -- Endtime (08:00)
}

-------------------
-- BLIP SETTINGS --
-------------------
Config.BlipSettings = {
    enabled = true, -- DOn't forget to turn to false if you use item.
    coords = Config.PedSettings.locations,
    label = "Blackmarket",
    sprite = 306,
    color = 40,
    display = 4,
    scale = 0.8,
    shortRange = true,
}

------------------------
-- BLACK MARKET ITEMS --
------------------------
Config.BlackMarketItems = {
    {
        name = "Knife",
        itemID = "weapon_knife",
        priceRange = {min = 1000, max = 2000}, 
        event = "smdx-blackmarket:giveKnife",
    },
    {
        name = "Pistol",
        itemID = "weapon_pistol",
        priceRange = {min = 1000, max = 2000},
        event = "smdx-blackmarket:givePistol",
    },
    {
        name = "Tazer",
        itemID = "weapon_stungun",
        priceRange = {min = 1000, max = 2000},
        event = "smdx-blackmarket:giveStungun",
    }
    -- More items here
}

------------------
-- LOCALES  ENG --
------------------
if Config.Lang == "ENG" then
    Config.BlackmarketPed = "Open Blackmarket"
    Config.Police = "You cannot access the Black Market as a police officer."
    Config.WelcomeMessage = "Welcome to Blackmarket"
    Config.Buying = "Buying a " -- Always leave a blank space at the end.
    Config.Phone = "Opening Blackmarket Phone"
    Config.Action = "Action canceled."
    Config.NotAvailable = "The black market is not available right now."
    Config.ConnectingBM = "Connecting to the Black Market..."
    Config.NotEnough = "You don't have enough cash."
    Config.YouBought = "Thank you, You bought a " -- Always leave a blank space at the end.
    Config.Disptachtitle = "Ongoing Blackmarket trading"
    Config.Disptachmessage = "An ongoing blackmarket handling is on going!"
------------------
-- LOCALES  SWE --
------------------
elseif Config.Lang == "SWE" then
    Config.BlackmarketPed = "Öppna Blackmarket"
    Config.Police = "Du har inte tillgång till svartamarknaden som polis."
    Config.WelcomeMessage = "Välkommen till Svartamarknaden!"
    Config.Buying = "Köper " -- Lämna alltid ett tomt mellanrum i slutet.
    Config.Phone = "Öppnar svartmarknadsluren..."
    Config.Action = "Åtgärd avbruten..."
    Config.NotAvailable = "Svartamarknaden är inte tillgänglig just nu."
    Config.ConnectingBM = "Ansluter till svarta marknaden..."
    Config.NotEnough = "Du har inte tillräckligt med stålar."
    Config.YouBought = "Tack grabben, Du köpte en " -- Lämna alltid ett tomt mellanrum i slutet.
    Config.Disptachtitle = "Pågående svartamarknads handling."
    Config.Disptachmessage = "Det är en pågående handling på svartamarknaden!"
end