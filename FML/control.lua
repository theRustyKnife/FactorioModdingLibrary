local FML_stdlib = require "script.FML-stdlib"
local module_loader = FML_stdlib.safe_require("script.module-loader", true)

local config = FML_stdlib.safe_require("config", true)


local _M = module_loader.load_std(FML_stdlib, nil, "runtime", config, config.VERSION) -- Load the standard functions
package.loaded["therustyknife.FML"] = _M -- Make this instance accessible via require
package.loaded["therustyknife.FML.config"] = config -- Config access for modules

local module_lookup = FML_stdlib.get_module_lookup(config.MODULES_TO_LOAD)


local log_func = true
-- Try to load the log module first
if module_lookup["log"] then
	_M.log = module_loader.load_from_file(module_lookup["log"], FML_stdlib.safe_require, true, log_func)
	-- Use default log function if loading failed
	log_func = _M.log and _M.log.w or true
end

module_loader.load_from_files(
		config.MODULES_TO_LOAD,
		_M,
		function(path) return FML_stdlib.safe_require(path, config.FORCE_LOAD_MODULES); end,
		true,
		log_func
	)
assert(_M.remote, "FML couldn't find the remote module.")


--TODO: external module loading


--TODO: unhardcode the interface name
_M.remote.add_interface("therustyknife.FML", _M, true, true, true)

--TODO: allow modules to change the parameters of the interface
for name, _ in pairs(module_lookup) do
	if _M[name] then
		_M.remote.add_interface("therustyknife.FML."..name, _M[name], true, true, false)
	end
end


--[[ DEBUG
local function awesome_function()
	_M.log.d("test from function")
end

awesome_function()

_M.log.d("test from control")

script.on_init(function()
	_M.log.d(serpent.line(_M.get_structure(true)))
end)
--]]


return _M
