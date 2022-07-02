---print ("By Under Development")
------dont leak the script be a good man------

fx_version 'cerulean'
game 'gta5'
description 'qb-dumpster by SpyX444'
version "1.0.0"
author "SpyX"

dependencies { 'qb-target' }

version "1.0.0"

client_scripts {
  'client/client.lua',
  'qb-target',
  'config.lua',
}

server_scripts {
  'config.lua',
  'server/server.lua',
}
