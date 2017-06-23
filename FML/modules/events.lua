local FML = require "therustyknife.FML"
local config = require "therustyknife.FML.config"

local table = FML.table


--TODO: make this a module, possibly special-cased like remote --UPDATE: special casing not necessary, it's just gonna 
-- be a dependency of the modules that use it.

--[[
TODO: this
Allow permanent event handlers to be registered. These will have to be functions accepting two parameters:
	- table event - All the event data, as in any standard event handler.
	- table _G - The current global scope. The function can't use any upvalues as that would make it a closure and break
	              on serialization. This should be a viable alternative to that.
	- ... - Any other constant parameters specified when registering the handler. This allows the function to use 
	        variables from the local scope at the time of creation. Be careful as these need to be serializable as well 
			and thus, closures can't be used.
Some notes on this:
	Any function calls need to be done either via the extra parameters (if the function is not a closure), or via the _G
	 parameter, in which case the function needs to be reliably present in the global scope, or somepalce accessible 
	from there.
]]


if FML.STAGE ~= "runtime" then return nil; end

local global

local handlers = {
	init = table(), -- same as script.on_init
	load = table(), -- same as script.on_load, but runs after on_init as well
	config_change = table(), -- same as script.on_configuration_changed
	game_config_change = table(), -- runs when the game version changes (after config_change)
	mod_config_change = table(), -- runs when the specified mod's version changes (after game_config_change)
	startup_settings_change = table(), -- runs whenever mod startup settings change, after the other config_change events
}

local function run(handlers, ...)
	for _, handler in ipairs(handlers) do handler(...); end
end

local function init() -- This should be safe to run in on_load as the tables should already exist
	global = FML.get_fml_global("events")
	global.handlers = global.handlers or {} -- The permanent handlers
	global.registered_handlers = table(global.registered_handlers) -- The events to be registered on load
end


local _M = {}
local _DOC = FML.make_doc(_M, {
	type = "module",
	name = "events",
	desc = [[ Provides an extended interface for handling events. ]],
})


-- Script events
_DOC.on_init = {
	type = "function",
	desc = [[ Register a handler for the init event. ]],
	params = {
		{
			type = "function",
			name = "func",
			desc = "The handler function",
		},
	},
}
function _M.on_init(func) handlers.init:insert(func); end
_DOC.on_load = FML.table.deep_copy(_DOC.on_init); _DOC.on_load.desc = [[ Register a handler for the load event. ]]
function _M.on_load(func) handlers.load:insert(func); end
_DOC.on_config_change = FML.table.deep_copy(_DOC.on_init); _DOC.on_load.desc = [[ Register a handler for the config_change event. ]]
function _M.on_config_change(func) handlers.config_change:insert(func); end
_DOC.on_game_config_change = FML.table.deep_copy(_DOC.on_init); _DOC.on_load.desc = [[ Register a handler for the game_config_change event. ]]
function _M.on_game_config_change(func) handlers.game_config_change:insert(func); end
_DOC.on_startup_settings_change = FML.table.deep_copy(_DOC.on_init); _DOC.on_startup_settings_change.desc = [[ Register a handler for the startup_settings_change event. ]]
function _M.on_startup_settings_change(func) handlers.startup_settings_change:insert(func); end

_DOC.on_mod_config_change = {
	type = "function",
	desc = [[ Register a handler for config_change event of the given mod. ]],
	params = {
		{
			type = "function",
			name = "func",
			desc = "The handler function",
		},
		{
			type = "string",
			name = "mod",
			desc = "The name of the mod to listen for",
			default = "The mod this instance of FML is in",
		},
	},
}
function _M.on_mod_config_change(func, mod)
	mod = mod or (config.MOD and config.MOD.NAME) or "FML"
	
	handlers[mod] = handlers[mod] or table()
	handlers[mod]:insert(func)
end


script.on_init(function()
	init() -- Init the globals
	
	run(handlers.init)
	run(handlers.load)
end)

script.on_load(function()
	init() -- Load the globals
	
	run(handlers.load)
end)

script.on_configuration_changed(function(data)
	-- Convert versions to semver objects
	data.new_version = data.new_version and FML.semver(data.new_version)
	data.old_version = data.old_version and FML.semver(data.old_version)
	for mod_name, change in pairs(data.mod_changes or {}) do
		change.new_version = change.new_version and FML.semver(change.new_version)
		change.old_version = change.old_version and FML.semver(change.old_version)
	end
	
	run(handlers.config_change, data)
	
	if data.new_version or data.old_version then
		run(handlers.game_config_change, {new_version = data.new_version, old_version = data.old_version})
	end
	
	if data.mod_changes then
		for mod, change in pairs(data.mod_changes) do
			if handlers.mod_config_change[mod] then
				run(handlers.mod_config_change[mod], {
					new_version = change.new_version,
					old_version = change.old_version,
				})
			end
		end
	end
	
	if data.mod_startup_settings_changed then run(handlers.startup_settings_change); end
end)


--Game events
--TODO: implement
_DOC.on_event = {
	type = "function",
	desc = [[ Add a handler for the given event. ]],
	params = {
		{
			type = {"EventID", "Array[EventID]", "string"},
			name = "event_id",
			desc = "The event(s) to register the handler for",
		},
		{
			type = "function",
			name = "handler",
			desc = "The handler function",
		},
		{
			type = "bool",
			name = "permanent",
			desc = "If true, the handler will be re-setup on load",
			default = "false",
		},
	},
}
function _M.on_event(event_id, handler, permanent)
	if type(event_id) == "table" then
		if permanent then --TODO: make this work
			FML.log.w("Permanent handlers not supported when registering for multiple events - using regular handlers.")
		end
		
		for _, id in pairs(event_id) do _M.on_event(event_id, handler); end
	end
	
	if permanent then
		--TODO: implement
		error("Permanent handlers have not been implemented yet.")
	
	else
		--TODO: implement
		error("Regular handlers have not been implemented yet either.")
	
	end
end


return _M
