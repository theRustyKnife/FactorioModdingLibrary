if not script then return nil; end -- requires script to load


-- require config without messing up any other configs that have been required with the same path
local t = package.loaded[".config"]
package.loaded[".config"] = nil
local config = require ".config"
package.loaded[".config"] = t

local FML = require "therustyknife.FML"


assert(FML.Object, "Object module has to be loaded before gui.")


local M = {}


package.loaded["therustyknife.FML.gui.config"] = config
FML.gui = M


M.global = FML.global.get("gui")

for name, path in pairs(config.ELEMENTS_TO_LOAD) do M[name] = require(path); end -- load all the elements as specified by config


return M
