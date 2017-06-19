local FML_stdlib = require "script.FML-stdlib"
local module_loader = FML_stdlib.safe_require("script.module-loader", true)

local config = FML_stdlib.safe_require("config", true)


local _M = module_loader.load_std(FML_stdlib, nil, "data", config, config.VERSION) -- Load the standard functions
FML_stdlib.put_to_global("therustyknife", "FML", _M) -- Give gloabal access to the library
package.loaded["therustyknife.FML"] = _M -- Make FML accessible via require - mostly for modules
package.loaded["therustyknife.FML.config"] = config -- Allow modules to require the config easily


--TODO: make sure this works
local log_func = true
-- Try to load the log module first, so we can use the logging functions
if config.MODULES_TO_LOAD["log"] then
	_M.log = module_loader.load_from_file(config.MODULES_TO_LOAD["log"], FML_stdlib.safe_require, log_func)
	-- Make sure we're not entirely dependent on the logging module - use default log if not available
	log_func = _M.log and _M.log.e or true
end

module_loader.load_from_files(
		config.MODULES_TO_LOAD,
		_M,
		function(path) return FML_stdlib.safe_require(path, config.FORCE_LOAD_MODULES); end,
		log_func
	)


return _M
