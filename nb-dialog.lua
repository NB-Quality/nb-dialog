local Loop = nil
local Empty = ""
local current_chars = 0 
local _showkeyboard = function(title,text) DisplayOnscreenKeyboard(1, "nb-dialog:title", "", text, Empty,Empty,Empty, current_chars) end 	
local _cancelkeyboard = CancelOnscreenKeyboard
local _clearkeyboard = function() _showkeyboard("nb-dialog:title",Empty) end 
local _addchar = function(length) current_chars = current_chars + length end 
local _deletechar = function() if current_chars > 0 then current_chars = current_chars - 1 end  end
local _clearchar = function() current_chars = 0 end 
local isPasswordMode = false 
local OpenKeyboard = function()
    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
    if not Loop then Loop = PepareLoop(100) 
        Loop(function()
            SendNUIMessage({
                action    = 'updateFocus'
            })
        end)
    end 
	_clearkeyboard()
	_clearchar()
end 

local UpdateKeyboard = function(text,length,text_full) 
	local str = text_full
	local pt = {}
	for i=1,#str do table.insert(pt,"*") end 
	if isPasswordMode then str = table.concat(pt) end 
	_showkeyboard("nb-dialog:title",str)
	_addchar(length)
end 

local ClearKeyboard = function()
    _clearkeyboard()
	_clearchar()
end 

local BackKeyboard = function(text_full) 
    local str = text_full
	local pt = {}
	for i=1,#str do table.insert(pt,"*") end 
	if isPasswordMode then str = table.concat(pt) end 
	_showkeyboard("nb-dialog:title",str)
	_deletechar()
end 
local current_promise = nil 
local ReturnKeyboard = function(text)
    if Loop then Loop:delete() end 
	PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	_cancelkeyboard()
	_clearchar ()
	if current_promise then current_promise:resolve(text) end 
end 

RegisterNUICallback("update", function(data, cb)
    UpdateKeyboard(data.string,data.length,data.fullstring)
	SetNuiFocus(true, false) cb('ok')
end)
RegisterNUICallback("delete", function(data, cb)
    BackKeyboard(data.string)
    SetNuiFocus(true, false) cb('ok')
end)
RegisterNUICallback("clear", function(data, cb)
    ClearKeyboard(data.string)
    SetNuiFocus(true, false) cb('ok')
end)
RegisterNUICallback("enter", function(data, cb)
    SendNUIMessage({
        action    = 'closeInput'
    })
    ReturnKeyboard(data.string)
	SetNuiFocus(false, false) cb('ok')
end)
Input = function(title,maxlength,x,y)
    isPasswordMode = false 
    AddTextEntry('nb-dialog:title', title)
	SendNUIMessage({
        action    = 'displayInput',
		debug = false
    })
   SendNUIMessage({
        action    = 'setIMEPos',
        x    = x or 1.0,
        y    = y or 1.0
    })
	SendNUIMessage({
            action    = 'setMaxLength',
            maxlength = maxlength or 20
    })
    OpenKeyboard()
	SetNuiFocus(true, false)
    current_promise = promise.new()
    return Citizen.Await(current_promise)
end
Password = function(title,maxlength,x,y)
    isPasswordMode = true 
    AddTextEntry('nb-dialog:title', title)
	SendNUIMessage({
        action    = 'displayInput',
		debug = false
    })
   SendNUIMessage({
        action    = 'setIMEPos',
        x    = x or 1.0,
        y    = y or 1.0
    })
	SendNUIMessage({
            action    = 'setMaxLength',
            maxlength = maxlength or 20
    })
    OpenKeyboard()
	SetNuiFocus(true, false)
    current_promise = promise.new()
    return Citizen.Await(current_promise)
end
