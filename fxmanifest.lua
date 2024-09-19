fx_version 'cerulean'
game 'gta5'
version '1.0.0'
lua54 'yes'

author 'SkapMicke - SMDX Development'
description 'A blackmarket script for the QBCore Framework made by SMDX Development'

shared_scripts {
	'config.lua'
}

files {
    'html/ui.html',
    'html/style.css',
    'html/scripts.js'
   }
   
   ui_page 'html/ui.html'

   server_scripts {
    'server/main.lua'  
}

client_scripts {
    'client/main.lua'
}