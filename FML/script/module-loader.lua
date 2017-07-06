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
		end
		
		return res_table
	end


	function _M.init(module, _M, ...)
	--[[
	Init a loaded module. If module is a function, it's going to be called with any other parameters passed. If _M wasn't
	passed, or it is nil, an empty table is going to be passed to the module instead.
	The resulting value is going to be returned, if the module returned a value and true, that value will be returned, plus
	true to indicate the fact that the module wishes not to use the table it was given.
	If module is anything else than a function, it's going to be returned as-is.
	]]
		if type(module) == "function" then
			local res = _M or {}
			local ret, override = module(res, ...)
			return (override and ret) or res, override
		end
		return module
	end

	function _M.init_all(FML, modules, init_func)
	--[[
	Init all the modules in the given FML instance. Use init_func for initialization, or the init function if none is given.
	]]
		init_func = init_func or _M.init
		for _, module in ipairs(modules) do
			if FML[module.name] then FML[module.name] = init_func(FML[module.name]); end
		end
	end

	function _M.load_from_file(path, load_func, init, log_func)
	--[[
	Load and return a module from the file at path, using load_func. Returns nil if the module didn't return a table.
	log_func can be nil, boolean or function(message). Logging won't work if load_func doesn't return the error as second
	return value. If init is true, the module will be initialized using the init function and returned in it's final form,
	if it's a function, it will be called with the module as parameter and the return value of the function will be used as
	the final form.
	]]
		load_func = load_func or require
		if init and type(init) ~= "function" then init = _M.init; end
		if log_func == true then log_func = log; end
		
		local loaded, err = load_func(path)
		if type(loaded) ~= "table" and type(loaded) ~= "function" then
			if err and log_func then
				log_func("Loading FML module from '"..tostring(path).."' failed: "..(err or "No error message."))
			end
			return nil
		end
		
		if init then return init(loaded); end
		return loaded
	end

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
				res_table[module.name] = _M.load_from_file(module.path, load_func, init, log_func) or res_table[module.name]
			end
		end
		
		return res_table
	end


	--TODO: a mechanism for loading external modules in runtime stage
end
