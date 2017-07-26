return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config

	local table = FML.table


	--TODO: make a part of this module in the remote instance, that would handle all the processing heavy checks and just
	-- raise an event if it happens

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

	Another thought:
	Allow handlers to be specified as interface Callbacks. This way, the mod that registered the handler would only have to 
	make sure the interface is re-exposed after deserialization. This could be handled by FML in a large part:
		- There will be a function, which would take a function, interface name and function name
			- This function will expose the interface with the given function inside, and return a Callback to it.
			- It will be called in a similar fassion the script.on_event function is - directly in the script.body and 
			  every time the script is loaded.
		- When registering a handler, the Callback could be passed in and will be saved as the handler function.

	This would also make using this module without installing it into the local instance easier, as Callbacks would be 
	basically natively supported.
	]]
	
	
	if FML.STAGE ~= "runtime" then return nil, true; end
	
	
	local global
	
	local handlers = {
		init = table(), -- same as script.on_init
		load = table(), -- same as script.on_load, but runs after on_init as well
		delayed_load = table(), -- same as load, but runs after all the load handlers finished (internal only)
		config_change = table(), -- same as script.on_configuration_changed
		game_config_change = table(), -- runs when the game version changes (after config_change)
		mod_config_change = table(), -- runs when the specified mod's version changes (after game_config_change)
		startup_settings_change = table(), -- runs whenever mod startup settings change, after the other config_change events
		
		runtime = table(), -- all the runtime event handlers, including permanent ones
	}

	local function run(handlers, ...)
		for _, handler in ipairs(handlers) do handler(...); end
	end

	local function init() -- This should be safe to run in on_load as the tables should already exist
		global = FML.get_fml_global("events")
		global.handlers = global.handlers or {} -- The permanent handlers
		global.registered_handlers = table(global.registered_handlers) -- The events to be registered on load
	end


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
	function _M.on_delayed_load(func) handlers.delayed_load:insert(func); end
	_DOC.on_config_change = FML.table.deep_copy(_DOC.on_init); _DOC.on_config_change.desc = [[ Register a handler for the config_change event. ]]; _DOC.on_config_change.params[1].type = "function"
	function _M.on_config_change(func) handlers.config_change:insert(func); end
	_DOC.on_game_config_change = FML.table.deep_copy(_DOC.on_init); _DOC.on_game_config_change.desc = [[ Register a handler for the game_config_change event. ]]; _DOC.on_game_config_change.params[1].type = "function"
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

	
	function _M.sim_init() run(handlers.init); run(handlers.load); run(handlers.delayed_load); end
	function _M.sim_load() run(handlers.load); run(handlers.delayed_load); end

	script.on_init(function()
		init() -- Init the globals
		
		run(handlers.init)
		run(handlers.load)
		run(handlers.delayed_load)
	end)

	script.on_load(function()
		init() -- Load the globals
		
		run(handlers.load)
		run(handlers.delayed_load)
	end)

	script.on_configuration_changed(function(data)
		-- Convert versions to Semver objects
		data.new_version = data.new_version and FML.Semver(data.new_version)
		data.old_version = data.old_version and FML.Semver(data.old_version)
		for mod_name, change in pairs(data.mod_changes or {}) do
			change.new_version = change.new_version and FML.Semver(change.new_version)
			change.old_version = change.old_version and FML.Semver(change.old_version)
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
		
		run(handlers.load)
		run(handlers.delayed_load)
	end)


	--Game events
	--TODO: finish
	local runtime_handlers = table()

	_DOC.on = {
		type = "function",
		desc = [[ Add a handler for the given event. ]],
		params = {
			{
				type = {"EventID", "Array[{EventID, string}]", "string"},
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
				desc = "If true, the handler will be re-setup on load (Not implemented yet)",
				default = "false",
			},
		},
	}
	function _M.on(event_id, handler, permanent)
		if type(event_id) == "table" then
			if permanent then --TODO: make this work
				FML.log.w("Permanent handlers not supported when registering for multiple events - using regular handlers.")
			end
			
			for _, id in pairs(event_id) do _M.on(id, handler); end
			return
		end
		
		if permanent then
			--TODO: implement
			FML.log.w("Permanent handlers not implemented yes - using regular handlers.")
		end--else
			if not runtime_handlers[event_id] then
				runtime_handlers[event_id] = table()
				local handlers = runtime_handlers[event_id]
				handlers:numeric_indices(true)
				script.on_event(event_id, function(...)
					for _, handler in handlers:ipairs_all() do handler(...); end
				end)
			end
			return runtime_handlers[event_id]:n_insert_at_next_index(handler)
		--end
	end

	_DOC.remove_handler = {
		type = "function",
		desc = [[ Remove the given handler from the given events. ]],
		notes = {[[
		Be careful when removing by id from multiple events as the id is only unique across one event. This may be changed
		in the future.
		]]},
		params = {
			{
				type = {"EventID", "Array[{EventID, string}]", "string"},
				name = "event_id",
				desc = "The event(s) to remove the handler from, if nil, all events will be considered",
			},
			{
				type = {"int", "function"},
				name = "what",
				desc = "Which handler to remove, can either be a handler id or a handler function",
			},
		},
	}
	function _M.remove_handler(event_id, what)
		if type(event_id) == "table" then
			local last_func
			for _, event_id in ipairs(event_id) do last_func = _M.remove_handler(event_id, what) or last_func; end
			return last_func
		end
		
		if not runtime_handlers[event_id] then return nil; end
		
		if type(what) == "function" then runtime_handlers[event_id]:n_remove_v(what)
		else runtime_handlers[event_id]:n_remove(what); end
	end

	--TODO: raise_event
	
	
	-- Custom events --TODO: move this into another file/module
	-- Add all the base events directly to the module to allow for simple syntax like events.on_tick
	for name, event_id in pairs(defines.events) do
		if not _M[name] then _M[name] = function(...) _M.on(event_id, ...); end; end
	end
	
	_M.GROUPS = {
		DESTROYED = {
			defines.events.on_entity_died,
			defines.events.on_preplayer_mined_item,
			defines.events.on_robot_pre_mined,
		},
		BUILT = {
			defines.events.on_built_entity,
			defines.events.on_robot_built_entity,
		},
	}
	
	-- Ease of use functions for groups
	for name, events in pairs(_M.GROUPS) do
		name = "on_"..name:lower()
		if not _M[name] then _M[name] = function(...) _M.on(events, ...); end; end
	end
end