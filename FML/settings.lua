local FML_stdlib = {}; require("script.FML-stdlib")(FML_stdlib)
local module_loader = {}; FML_stdlib.safe_require("script.module-loader", true)(module_loader)

local config = FML_stdlib.safe_require("config", true)


local load_func = FML_stdlib.safe_require
if config.FORCE_LOAD_MODULES then
	load_func = function(path) return FML_stdlib.safe_require(path, config,FORCE_LOAD_MODULES); end
end

local module_lookup = FML_stdlib.get_module_lookup(config.MODULES_TO_LOAD)


-- Load and serialize FML into a prototype
local to_export = {
	config = config,
	FML_stdlib = FML_stdlib.safe_require("script.FML-stdlib"),
	module_loader = FML_stdlib.safe_require("script.module-loader"),
	console = FML_stdlib.safe_require("script.console"),
	modules = {},
}
module_loader.load_from_files(config.MODULES_TO_LOAD, to_export.modules, load_func, false, log_func)
local serialized = serpent.dump(to_export)

data:extend{
	{
		type = "string-setting",
		setting_type = "runtime-global",
		name = config.FML_SETTING_NAME,
		default_value = serialized,
		allowed_values = {serialized},
	},
}
