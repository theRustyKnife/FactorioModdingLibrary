--/ events

return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config
	local table = therustyknife.FML.table
	local Semver = therustyknife.FML.Semver
	local log = therustyknife.FML.log
	
	
	local handlers = table()
	
	-- Events in here will have the default pre, on, post functions generated
	-- Can't be here: mod_config_change
	local event_names = table{'init', 'load', 'config_change', 'game_config_change', 'startup_settings_change'}
	local event_stages = table{{name='pre', prefix='pre_'}, {name='on', prefix=''}, {name='post', prefix='post_'}}
	
	
	local function run(handlers, ...)
	--% private
	--- Run the handlers for the given event.
	--@ Dictionary[string, Array[function]] handlers: The handlers divided in tables by the stage
	--@ Any ...: Any arguments to be passed to the handlers
		if not handlers then return; end
		for _, stage in event_stages:ipairs() do
			if handlers[stage.name] then for _, handler in handlers[stage.name]:ipairs() do handler(...); end end
		end
	end
	
	--TODO: Document this in the module description - pre and post events shouldn't be used to interact with anything
	local function make_function(name, stage)
		_M['on_'..stage.prefix..name] = function(func) handlers:mk(name):mk(stage.name):insert(func); end
	end
	for _, name in event_names:ipairs() do
		for _, stage in event_stages:ipairs() do make_function(name, stage); end
	end
	
	handlers:mk'mod_config_change'
	local function on_mod_config_change(func, mod, stage) -- The docs bellow are for the public function
	--f on_mod_config_change
	--- Register a handler for config_change of a given mod.
	--* The appropriate `pre` and `post` versions exit too.
	--@ function func: The handler function
	--@ string mod=config.MOD.NAME: The name of the mod to listen for, default is as configured in FML config
		mod = mod or (config.MOD and config.MOD.NAME) or 'FML'
		handlers.mod_config_change:mk(mod):mk(stage.name):insert(func)
	end
	for _, stage in event_stages:ipairs() do
		_M['on_'..stage.prefix..'mod_config_change'] = function(func, mod) on_mod_config_change(func, mod, stage); end
	end
	
	
	function _M.run_init(simulated)
	--% private
	--- Run the on_init procedure.
	--@ bool simultated=false
		run(handlers.init)
		run(handlers.load)
	end
	
	function _M.run_load(simulated)
	--% private
	--- Run the on_load procedure
	--@ bool simulated=false
		run(handlers.load)
	end
	
	function _M.run_configuration_changed(data, simulated)
	--% private
	--- Run the on_configuration_changed procedure.
	--@ ConfigurationChangedData data
	--@ bool simulated=false
		-- Convert versions to Semver objects
		data.new_version = data.new_version and Semver(data.new_version)
		data.old_version = data.old_version and Semver(data.old_version)
		for _, mod_data in pairs(data.mod_changes or {}) do
			mod_data.new_version = mod_data.new_version and Semver(mod_data.new_version)
			mod_data.old_version = mod_data.old_version and Semver(mod_data.old_version)
		end
		
		run(handlers.config_change, data)
		_= (data.new_version or data.old_version) and run(handlers.game_config_change, data)
		
		if data.mod_changes then
			for mod_name, mod_data in pairs(data.mod_changes) do
				run(handlers.mod_config_change[mod_name],
						{new_version=mod_data.new_version, old_version=mod_data.old_version}, data=data)
			end
		end
		
		_= data.mod_startup_settings_changed and run(handlers.startup_settings_change)
		run(handlers.load)
	end
	
	
	script.on_init(_M.run_init)
	script.on_load(_M.run_load)
	script.on_configuration_changed(_M.run_configuration_changed)
end
