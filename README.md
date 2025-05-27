# SkapBlackMarket

Welcome to SkapBlackMarket script!
Discord Server: https://discord.gg/NKaDpHKkkH
==========================
Preview video is coming...

With this script we focused on adding as much as we can into our config.lua, To make it as easy as possible for you to configure it
to your own liking.

# Features
- Customizable peds and their locations.
- Randomising peds & their locations.
- Blackmarket active time. Only active between the time you state in the config.lua.
- Dispatch, Do you want the police to have a chance to get alerted when a player opens the blackmarketUI? (Only for peds)
- You can also choose how big of a chance the alert has in the "Config.ChanceValue"
- Turn off/on blips for the blackmarket. Always turn off if you use items.

And more to coming!

Planning for the future:
- Add pictures to the blackmarket items.
- Add some sort of pickup system.
- Add the possibility to do a quest for the blackmarket guy and earn things for it.
And much more!
==========================
Hope you like the script as it is right now!
More will come for it!

# Install:

Item:
blackmarketipad             = { name = "blackmarketipad", label = "Ipad", weight = 150, type = "item", image = "blackmarketipad.png", unique = false, useable = false, shouldClose = true, combinable = nil, description = "An ipad?...", },

You can find an picture in html/images

# ps-dispatch compatibility (install)

1. Go into ps-dispatch/client/alerts.lua and add this code anywhere:

```
local function BlackmarketTrading()
    local coords = GetEntityCoords(cache.ped)

    local dispatchData = {
        message = locale('blackmarket'),
        codeName = 'blackmarkettrading',
        code = '10-10',
        icon = 'fas fa-hand-fist',
        priority = 2,
        coords = coords,
        gender = GetPlayerGender(),
        street = GetStreetAndZone(coords),
        alertTime = nil,
        jobs = { 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('BlackmarketTrading', BlackmarketTrading)
```

2. Add this code into ps-dispatch/shared/config.lua:

```
['blackmarket'] = { -- Need to match the codeName in alerts.lua
        radius = 0,
        sprite = 119,
        color = 1,
        scale = 1.5,
        length = 2,
        sound = 'Lose_1st',
        sound2 = 'GTAO_FM_Events_Soundset',
        offset = false,
        flash = false
    },
```

# Discord Logs:
In our config file we'll find a "Config.Discordlogs = true", Make sure to replace the "YOUR_DISCORD_WEBOOK_URL_HERE"
With your Webhook URL. 
If you donät know what a discord webhook is, Or don't know how to install it. Here's a video for it:
https://www.youtube.com/watch?v=fKksxz2Gdnc


