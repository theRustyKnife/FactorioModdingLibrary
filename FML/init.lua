-- require config without messing up any other configs that have been required with the same path
local t = package.loaded[".config"]
package.loaded[".config"] = nil
local config = require ".config"
package.loaded[".config"] = t


local M = {}


package.loaded["therustyknife.FML.config"] = config -- allow the modules access to config without having to know where it is
package.loaded["therustyknife.FML"] = M -- allow the individual modules to call eachother


if global then
	global[config.GLOBAL_NAME] = global[config.GLOBAL_NAME] or {} -- init the global table
	M.global = global[config.GLOBAL_NAME]
	
	
	function M.global.get(name)
		M.global[name] = M.global[name] or {}
		return M.global[name]
	end
end


for i, v in pairs(config.MODULES_TO_LOAD) do -- load all the modules specified in config
	local function t_load() M[i] = require(v); end
	
	if config.FORCE_LOAD_MODULES then t_load()
	else pcall(t_load)
	end
	
	if type(package.loaded[v]) ~= "table" then
		package.loaded[v] = nil
		M[i] = nil
	end
end


return M
