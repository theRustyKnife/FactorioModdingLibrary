return function(_M)
	local function pack_method(method, object)
		return function(...) return method(object, ...); end
	end


	--[[ Contains functions for loading modules. ]]


	function _M.load_std(std, res_table, stage, config, version)
	--[[ Maps functions from std to their respective positions in the main module. ]]
		res_table = res_table or {}
		res_table.config = config
		
		res_table.STAGE = stage
		res_table.VERSION = version
		
		res_table.safe_require = std.safe_require
		res_table.get_config = function() return res_table.CONFIG; end
		res_table.get_version_code = pack_method(std.get_version_code, version)
		res_table.get_version_name = pack_method(std.get_version_name, version)
		
		res_table.init_all = function() _M.init_all(res_table, config.MODULES_TO_LOAD); end
		
		if stage == "DATA" or stage == "SETTINGS" then
			res_table.put_to_global = std.put_to_global
			res_table.register_module = pack_method(std.register_module, res_table)
		elseif stage == "RUNTIME" or stage == "RUNTIME_SHARED" then
			res_table.get_structure = pack_method(std.get_structure, res_table)
			res_table.get_global = std.get_global
			res_table.get_fml_global = function(name) return std.get_global("therustyknife", "FML", name); end
			res_table.dump_lib_data = pack_method(std.dump_lib_data, config)
			res_table.FML_EVENT_ID = std.FML_EVENT_ID -- The id of the shared FML event used for *cough* hacking *cough*
		end
		
		return res_table
	end


	function _M.init(module, __M, stage)
	--[[
	Initialize the given module. __M will be used as the module table, but a new table will be created if __M is not given.
	stage is a string representing the current stage.
	The resulting module is returned, or nil if the module wasn't supposed to be initialized in this stage.
	]]
		-- This is to support the "old" return function module definition. It still has legitimate uses.
		assert(type(stage) == "string", debug.traceback("stage needs to be defined to init a module"))
		if type(module) == "function" then
			local res = __M or {}
			res = module(res, stage) or res
			return res
		end
		
		-- Constants are simply returned
		if module.type == "constant" then return module.value; end
		
		-- Modules defined using the mod function
		if module.type == "module" then
			assert(module[stage], tostring(stage).." is not a valid stage")
			local res = __M or {} -- This is the final module table
			-- Iterate over all the components in the current stage
			for _, component in ipairs(module[stage]) do
				if component.type == "file" then module.files[component.path](res, stage) -- Load files by calling them
				elseif component.type == "submodule" then
					assert(module.name, serpent.line(module))
					assert(module.submodules[component.name],
						"No submodule defined for name \""..component.name.."\""..
						(module.name and " in module "..module.name or ""))
					res[component.name] = {_super_module = res} -- Give access to the supermodule via _super_module
					_M.init(module.submodules[component.name], res[component.name], stage) -- Recursively load submodules
				end
			end
			return res
		end
		
		-- Modules defined using the modfunc function
		if module.type == "module-function" then
			if not module.stages[stage] then return nil; end -- Don't load if the current stage is not in stages
			local res = __M or {} -- The final module table
			module.func(res, stage) -- Call the function to init
			return res
		end
	end
	
	function _M.init_all(res_tab, modules, order, stage, init_func)
	--[[
	Init all modules based on order. Results are put into res_tab, which is then returned. stage indicates the current
	stage and init_func is the function used for initialization (init by default).
	]]
		init_func = init_func or _M.init
		res_tab = res_tab or {}
		-- Iterate over the order to init only the appropriate modules
		for _, module in ipairs(order) do
			if res_tab[module.name] == nil and modules[module.name] then -- Only init if the name is free and the module actually exists
				res_tab[module.name] = init_func(modules[module.name], nil, stage) -- Call the init function with the module
			end
		end
		return res_tab
	end
	
	function _M.load_from_file(path, load_func, init, log_func, stage, module_name)
	--[[
	Load module from the given path. load_func is used for loading files (require by default). If init is true, the module
	is initialized straight away. log_func will be used for logging errors, if false no logging will be done, if true log
	will be used.
	]]
		load_func = load_func or require
		if init and type(init) ~= "function" then init = _M.init; end
		if log_func == true then log_func = log; end
		
		-- Store the values from global so we can restore them once we're done
		local _G_to_bak = {"mod", "const", "modfunc", "file", "submod"} 
		local _G_bak = {}; for _, name in ipairs(_G_to_bak) do _G_bak[name] = _G[name]; end
		
		-- Submodules and component functions will be loaded to here by the bellow functions
		local submods = {}
		local files = {}
		
		function _G.file(path)
		--[[
		Load a component from a file. Only usable from inside a mod function defined module.
		]]
			files[path] = files[path] or load_func(path) -- Make sure the file is in the cache, load it if not
			return {type = "file", path = path} -- Only return a reference
		end
		
		function _G.submod(name, path)
		--[[
		Load a submodule. Path is optional, however, it has to be passed at least once for each submodule (for obvious
		reasons). To make the code cleaner, you can put a submod call defining the path outside of any stages and only
		call with name in the appropriate places.
		]]
			-- If path was given, make sure the submodule is in the cache
			if path then submods[name] = submods[name] or _M.load_from_file(path, load_func, false, log_func, stage); end
			return {type = "submodule", name = name} -- Only return a reference
		end
		
		-- These are the "top-level" functions, they set res to the loaded module
		local res
		function _G.mod(module)
		--[[
		The most comprehensive module definition function. It takes the module in form of a table with definitions of
		components/submodules to be loaded in given stages.
		]]
			res = {type = "module", name = module_name, submodules = submods, files = files} -- Save the caches - this table is what will be serialized
			-- Add the stage definitions into the result and make sure all of them exist while at it
			for _, stage in ipairs{"DATA", "SETTINGS", "RUNTIME_SHARED", "RUNTIME"} do res[stage] = module[stage] or {}; end
		end
		
		-- Simply sets the given value as the module - it has to be serializable, preferably some constant (can be table)
		function _G.const(const) res = {type = "constant", value = const}; end
		
		function _G.modfunc(stages, func)
		--[[
		This is more or less the same as the regular function-style definition, except it can have stages defined.
		stages is a table of strings representing the stages. func is the module function. Leaving out stages and only
		passing func is considered the same as defining all stages.
		]]
			func = func or type(stages) == "function" and stages
			res = {type = "module-function", stages = {}, func = func}
			if stages == nil or type(stages) == "table" then -- Add the stages, if nil add all stages
				for _, stage in ipairs(stages or {"DATA", "SETTINGS", "RUNTIME_SHARED", "RUNTIME"}) do
					res.stages[stage] = true -- Use a reverse table for easier lookup
				end
			end
		end
		
		-- Load the module
		local loaded, err = load_func(path)
		-- If no value to be used is found, set err
		if not err and (type(loaded) ~= "function" and not res) then err = "No suitable value found."; end
		if err then -- something went wrong - log if possible and return nil
			if log_func then log_func("Loading FML module from '"..tostring(path).."' failed: "..(err or "No error message.")); end
			return nil
		end
		res = res or loaded
		
		-- Restore the globals
		for _, name in ipairs(_G_to_bak) do _G[name] = _G_bak[name]; end
		
		if init then return init(res, nil, stage); end
		return res
	end
	
	
	function _M.load_from_files(modules, res_table, load_func, init, log_func, stage)
	--[[
	Load all the modules, calling load_from_file for each and putting them into res_table, indexed by their names.
	Since this only internal, we can just ignore any modules whose names are already in the table, assuming they're supposed
	to be there.
	load_func, init and log_func is passed to load_from_file.
	]]
		init = init == true and _M.init_all or init
		
		local res = not init and res_table or {}
		for _, module in ipairs(modules) do -- modules is a value in the form of config.MODULES_TO_LOAD
			if res[module.name] == nil then -- only load if the module doesn't already exist (shouldn't happen)
				res[module.name] = _M.load_from_file(module.path, load_func, false, log_func, nil, module.name)
			end
		end
		
		if init then return init(res_table, res, modules, stage); end
		return res
	end


	--TODO: a mechanism for loading external modules in runtime stage
end
