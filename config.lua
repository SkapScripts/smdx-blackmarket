QBCore = exports['qb-core']:GetCoreObject()

-----------------------
-- CONFIGURATION --
-----------------------
Config = {}

Config.MoneyType = 'bank' -- Choose between cash/bank.

Config.Lang = "ENG" -- ENG for english, SWE for Swedish.

Config.DispatchSystem = "ps-disptach" -- ps-dispatch / cd-disptach / qb-dispatch / none
Config.ChanceValue = 0.5 -- 50 = 50% chance the police will get alerted.

Config.PoliceJob = 'police' -- Name of the policejob

Config.GiveAmmo = false -- Set to true and you will get ammo in weapons when a player buy's it
Config.DefaultAmmo = 25 -- How much ammo the weapon gets if ammo is enabled

Config.BlackMarketMenuType = "nui" -- nui / qb / ox
Config.TargetSystem = "qb" -- qb/ox

------------------
-- DISCORD LOGS --
------------------
-- The webhook is at line 1 in server.lua
Config.Discordlogs = true --True if you want to use discord logs.
Config.DiscordName = "BlackMarket Logger"
Config.Titel = "Item Purchase Log"
Config.Color = 16711680 -- Red color

------------------
-- PED SETTINGS --
------------------

Config.BlackMarketPeds = {
    ["airport"] = {
        label = "Airport",
        model = "s_m_y_dealer_01",
        coords = {
            vector4(473.85, -1078.14, 28.35, 181.32),
            vector4(480.00, -1075.00, 28.35, 90.00)
        },
        scenarios = { "WORLD_HUMAN_SMOKING", "WORLD_HUMAN_STAND_MOBILE" },
        items = {
            { name = "Pistol", itemID = "weapon_pistol", priceRange = { min = 1000, max = 2000 }, iconPath = "nui://qs-inventory/html/images/weapon_pistol.png" },
            { name = "Knife", itemID = "weapon_knife", priceRange = { min = 500, max = 1000 }, iconPath = "nui://qs-inventory/html/images/weapon_knife.png" }
        }
    },
    ["docks"] = {
        label = "Docks",
        model = "g_m_m_chigoon_01",
        coords = {
            vector4(470.05, -1078.16, 28.35, 178.72),
            vector4(465.00, -1080.00, 28.35, 270.00)
        },
        scenarios = { "WORLD_HUMAN_CHEERING", "WORLD_HUMAN_DRUG_DEALER" },
        items = {
            { name = "Tazer", itemID = "weapon_stungun", priceRange = { min = 1500, max = 2500 }, iconPath = "nui://qs-inventory/html/images/weapon_stungun.png" }
        }
    }
}

Config.DefaultScenarios = { -- Global fallback. If no scenario is set at the ped, It will fallback to these.
    "WORLD_HUMAN_STAND_MOBILE",
    "WORLD_HUMAN_SMOKING",
    "WORLD_HUMAN_CHEERING"
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
    enabled = false, -- DOn't forget to turn to false if you use item.
    coords = Config.BlackMarketPeds.coords,
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
    },
    {
        name = "Pistol",
        itemID = "weapon_pistol",
        priceRange = {min = 1000, max = 2000},
    },
    {
        name = "Tazer",
        itemID = "weapon_stungun",
        priceRange = {min = 1000, max = 2000},
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