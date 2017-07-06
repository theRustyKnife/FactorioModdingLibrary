local FML_stdlib = require("script.FML-stdlib"){}
local module_loader = FML_stdlib.safe_require("script.module-loader", true){}

local config = FML_stdlib.safe_require("config", true)


local _M = module_loader.load_std(FML_stdlib, nil, "runtime", config, config.VERSION) -- Load the standard functions
FML_stdlib.put_to_global("therustyknife", "FML", _M) -- Give global access to the library

local module_lookup = FML_stdlib.get_module_lookup(config.MODULES_TO_LOAD)


local function load_func = FML_stdlib.safe_require
if config.FORCE_LOAD_MODULES then
	load_func = function(path) return FML_stdlib.safe_require(path, config,FORCE_LOAD_MODULES); end
end

-- Load log fully, so we can log whatever happens here
local log_func = log
if module_lookup.log then
	_M.log = module_loader.load_from_file(module_lookup.log, load_func, true, log_func)
	log_func = _M.log and _M.log.w or log_func
end

assert(module_lookup.remote, "Path to remote module not found.")
_M.remote = module_loader.load_from_file(module_lookup.remote, load_func, true, log_func)
assert(_M.remote, "Remote module failed to load.")

_M.to_export = {
	config = config,
	FML_stdlib = FML_stdlib.safe_require("script.FML-stdlib"),
	module_loader = FML_stdlib.safe_require("script.module-loader"),
	modules = {},
}
module_loader.load_from_files(config.MODULES_TO_LOAD, _M.to_export.modules, load_func, false, log_func)

function _M.serialize() _M.serialized = serpent.dump(_M.to_export); end
_M.serialize()

function _M.get() return _M.serialized; end


--TODO: unhardcode the interface name
_M.remote.add_interface("therustyknife.FML", {get = get}, false, true, true)


return _M




------------------ LEGACY ------------------
--[[
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


local modules_to_serialize = module_loader.load_from_files(config.MODULES_TO_LOAD, nil, FML_stdlib.safe_require, false, log_func)
local serialized_modules = serpent.dump(modules_to_serialize)
function _M.get_modules() return serialized_modules; end


--TODO: unhardcode the interface name
_M.remote.add_interface("therustyknife.FML", _M, true, true, true)

--TODO: allow modules to change the parameters of the interface
for name, _ in pairs(module_lookup) do
	if _M[name] then
		_M.remote.add_interface("therustyknife.FML."..name, _M[name], true, true, false)
	end
end
--]]


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
