local FML = require "therustyknife.FML"
local config = require "therustyknife.FML.config"
local new_tab = FML.table.new


--TODO: make this a module, possibly special-cased like remote

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


local global

local handlers = {
	init = new_tab(), -- same as script.on_init
	load = new_tab(), -- same as script.on_load, but runs after on_init as well
	config_change = new_tab(), -- same as script.on_configuration_changed
	game_config_change = new_tab(), -- runs when the game version changes (after config_change)
	mod_config_change = new_tab(), -- runs when the specified mod's version changes (after game_config_change)
}

local function run(handlers, ...)
	for _, handler in ipairs(handlers) do handler(...); end
end

local function init() -- This should be safe to run in on_load as the tables should already exist
	global = FML.get_fml_global("events")
	global.handlers = global.handlers or {} -- The permanent handlers
	global.registered_handlers = FML.table.enrich(global.registered_handlers or {}) -- The events to be registered on load
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
		func = {
			type = "function",
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

_DOC.on_mod_config_change = {
	type = "function",
	desc = [[ Register a handler for config_change event of the given mod. ]],
	params = {
		func = {
			type = "function",
			desc = "The handler function",
		},
		mod = {
			type = "string",
			desc = "The name of the mod to listen for",
			default = "The mod this instance of FML is in",
		},
	},
}
function _M.on_mod_config_change(func, mod)
	mod = mod or (config.MOD and config.MOD.NAME) or "FML"
	
	handlers[mod] = handlers[mod] or new_tab()
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
	for _, change in pairs(data.mod_changes or {}) do
		change.new_version = change.new_version and FML.semver(data.new_version)
		change.old_version = change.old_version and FML.semver(data.old_version)
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
end)


--Game events
--TODO: implement
_DOC.on_event = {
	type = "function",
	desc = [[ Add a handler for the given event. ]],
	params = {
		event_id = {
			type = {"EventID", "Array[EventID]"},
			desc = "The event(s) to register the handler for",
		},
		handler = {
			type = "function",
			desc = "The handler function",
		},
		permanent = {
			type = "bool",
			desc = "If true, the handler will be re-setup on load",
			default = "false",
		},
	},
}
function _M.on_event(event_id, handler, permanent)
	error("Not implementeds.")
end


return _M
