fx_version 'bodacious'
game 'gta5'

author 'theMani_kh'
description 'an advacned Lumberjack job'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'server/main.lua',
	'server/class.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua',
}