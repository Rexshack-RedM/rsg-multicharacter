fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'rsg-multicharacter'
version '2.3.5'

ui_page "html/index.html"

client_scripts {
    'client/main.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/versionchecker.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/RDRLino-Regular.ttf', 
    'html/reset.css',
    'html/script.js',
    'html/profanity.js',
    'html/assets/*.png',
}

dependencies {
    'rsg-core'
}

lua54 'yes'
