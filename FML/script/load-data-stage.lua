return function(stage)
	local FML_stdlib = {}; require("script.FML-stdlib")(FML_stdlib)
	local module_loader = {}; FML_stdlib.safe_require("script.module-loader", true)(module_loader)

	local config = FML_stdlib.safe_require("config", true)


	local load_func = FML_stdlib.safe_require
	if config.FORCE_LOAD_MODULES then
		load_func = function(path) return FML_stdlib.safe_require(path, config,FORCE_LOAD_MODULES); end
	end

	local module_lookup = FML_stdlib.get_module_lookup(config.MODULES_TO_LOAD)


	local _M = module_loader.load_std(FML_stdlib, nil, stage, config, config.VERSION) -- Load the standard functions
	FML_stdlib.put_to_global("therustyknife", "FML", _M) -- Give global access to the library

	-- Load log fully, so we can log whatever happens here
	local log_func = log
	if module_lookup.log then
		_M.log = module_loader.load_from_file(module_lookup.log, load_func, true, log_func)
		log_func = _M.log and _M.log.w or log_func
	end

	module_loader.load_from_files(config.MODULES_TO_LOAD, _M, load_func, true, log_func)


	return _M
end