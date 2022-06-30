fx_version 'cerulean'
game 'gta5'
author 'negbook'

lua54 'yes'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/vue.js',
    'html/listener.js'
}

client_scripts {
'@nb-loop/nb-loop.lua',
'nb-dialog.lua',
'example.lua'
}

dependencies {
	'nb-loop'
}

exports {
    "Input",
    "Password"
}