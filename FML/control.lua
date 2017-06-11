local FML_stdlib = require "script.FML-stdlib"
local module_loader = FML_stdlib.safe_require("script.module-loader", true)

local config = FML_stdlib.safe_require("config", true)


local _M = module_loader.load_std(FML_stdlib, nil, "runtime") -- Load the standard functions
package.loaded["therustyknife.FML"] = _M -- Make this instance accessible via require
package.loaded["therustyknife.FML.config"] = config -- Config access for modules


--TODO: make sure this works
local log_func = true
-- Try to load the log module first
if config.MODULES_TO_LOAD["log"] then
	_M.log = module_loader.load_from_file(config.MODULES_TO_LOAD["log"], FML_stdlib.safe_require, log_func)
	-- Use default log function if loading failed
	log_func = _M.log and _M.log.e or true
end

module_loader.load_from_files(
		config.MODULES_TO_LOAD,
		_M,
		function(path) return FML_stdlib.safe_require(path, config.FORCE_LOAD_MODULES); end,
		log_func
	)
assert(_M.remote, "FML couldn't find the remote module.")


--TODO: external module loading


--TODO: unhardcode the interface name
_M.remote.add_interface("therustyknife.FML", _M, true, true, true)

--TODO: allow modules to change the parameters of the interface
for name, _ in pairs(config.MODULES_TO_LOAD) do
	if _M[name] then
		_M.remote.add_interface("therustyknife.FML."..name, _M[name], true, true, false)
	end
end


---[[ DEBUG
script.on_init(function()
	_M.log.d(serpent.line(_M.get_structure(true)))
end)
--]]


return _M
