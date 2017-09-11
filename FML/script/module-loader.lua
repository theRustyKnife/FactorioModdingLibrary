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
		res_table.make_doc = std.make_doc
		res_table.get_version_code = pack_method(std.get_version_code, version)
		res_table.get_version_name = pack_method(std.get_version_name, version)
		
		res_table.init_all = function() _M.init_all(res_table, config.MODULES_TO_LOAD); end
		
		if stage == "data" then
			res_table.put_to_global = std.put_to_global
			res_table.register_module = pack_method(std.register_module, res_table)
		elseif stage == "runtime" then
			res_table.get_structure = pack_method(std.get_structure, res_table)
			res_table.get_global = std.get_global
			res_table.get_fml_global = function(name) return std.get_global("therustyknife", "FML", name); end
			res_table.dump_lib_data = pack_method(std.dump_lib_data, config)
			res_table.FML_EVENT_ID = std.FML_EVENT_ID -- The id of the shared FML event used for *cough* hacking *cough*
		end
		
		return res_table
	end


	function _M.init(module, __M, stage)
		if type(module) == "function" then
			local res = __M or {}
			module(res, stage)
			return res
		end
		
		if module.type == "constant" then return module.value; end
		if module.type == "module" then
			local res = __M or {}
			for _, component in ipairs(module[stage]) do
				if component.type == "file" then module.files[component.path](res, stage)
				elseif component.type == "submodule" then
					res[component.name] = {_super_module = res}
					_M.init(module.submodules[component.name], res[component.name], stage)
				end
			end
			return res
		end
	end
	
	function _M.init_all(res_tab, modules, order, stage, init_func)
	--[[
	Init all the modules in the given FML instance. Use init_func for initialization, or the init function if none is given.
	]]
		init_func = init_func or _M.init
		res_tab = res_tab or {}
		for _, module in ipairs(order) do
			if res_tab[module.name] == nil and modules[module.name] then
				res_tab[module.name] = init_func(modules[module.name], nil, stage)
			end
		end
		return res_tab
	end
	
	function _M.load_from_file(path, load_func, init, log_func)
		load_func = load_func or require
		if init and type(init) ~= "function" then init = _M.init; end
		if log_func == true then log_func = log; end
		
		-- Store the values from global so we can restore them once we're done
		local _G_to_bak = {"mod", "const", "file", "submod"}
		local _G_bak = {}; for _, name in ipairs(_G_to_bak) do _G_bak[name] = _G[name]; end
		
		-- Submodules and component functions will be loaded to here by the bellow functions
		local submods = {}
		local files = {}
		function _G.file(path)
			files[path] = files[path] or load_func(path)
			return {type = "file", path = path}
		end
		function _G.submod(name, path)
			if path then submods[name] = submods[name] or _M.load_from_file(path, load_func, false, log_func); end
			return {type = "submodule", name = name}
		end
		
		-- These are the "top-level" function, they set res to the loaded module
		local res
		function _G.mod(module, type)
			res = {type = "module", submodules = submods, files = files}
			for _, stage in ipairs{"DATA", "SETTINGS", "RUNTIME_SHARED", "RUNTIME"} do res[stage] = module[stage]; end
		end
		function _G.const(const) res = {type = "constant", value = const}; end
		
		-- Load the module
		local loaded, err = load_func(path)
		if not err and (type(loaded) ~= "function" and not res) then err = "No suitable value found."; end
		if err then
			log_func and log_func("Loading FML module from '"..tostring(path).."' failed: "..(err or "No error message."))
			return nil
		end
		res = res or loaded
		
		-- Restore the globals
		for _, name in ipairs(_G_to_bak) do _G[name] = _G_to_bak[name]; end
		
		if init then return init(res); end
		return res
	end
	
	--[[ LEGACY
	function _M.load_from_file(path, load_func, init, log_func)
	---[[
	--Load and return a module from the file at path, using load_func. Returns nil if the module didn't return a table.
	--log_func can be nil, boolean or function(message). Logging won't work if load_func doesn't return the error as second
	--return value. If init is true, the module will be initialized using the init function and returned in it's final form,
	--if it's a function, it will be called with the module as parameter and the return value of the function will be used as
	--the final form.
	--]-]
		load_func = load_func or require
		if init and type(init) ~= "function" then init = _M.init; end
		if log_func == true then log_func = log; end
		
		_G._M_require = load_func -- To allow nested modules to load submodules using the proper function --TODO: consider replacing require with this
		local loaded, err = load_func(path)
		_G._M_require = nil
		if type(loaded) ~= "table" and type(loaded) ~= "function" then
			if err and log_func then
				log_func("Loading FML module from '"..tostring(path).."' failed: "..(err or "No error message."))
			end
			return nil
		end
		
		-- For loading nested/multi-file modules
		local function _make_mod(module)
			if type(module) == "table" and module._M then
				function module:__load(_M, init_func, ...)
					_M = _M or {}
					for _, m in ipairs(self) do
						if type(m) == "function" then init_func(m, _M, ...)
						else m:__load(_M, init_func, ...); end
					end
				end
				for _, m in ipairs(module) do _make_mod(m); end
			end
		end
		_make_mod(loaded)
		
		if init then return init(loaded); end
		return loaded
	end
	--]]

	function _M.load_from_files(modules, res_table, load_func, init, log_func)
	--[[
	Load all the modules, calling load_from_file for each and putting them into res_table, indexed by their names.
	Since this only internal, we can just ignore any modules whose names are already in the table, assuming they're supposed
	to be there.
	load_func, init and log_func is passed to load_from_file.
	]]
		res_table = res_table or {}
		for _, module in ipairs(modules) do
			if res_table[module.name] == nil then
				res_table[module.name] = _M.load_from_file(module.path, load_func, init, log_func)
			end
		end
		return res_table
	end


	--TODO: a mechanism for loading external modules in runtime stage
end
