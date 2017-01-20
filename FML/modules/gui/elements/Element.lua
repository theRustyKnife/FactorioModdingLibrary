local FML = require "therustyknife.FML"


local global = FML.gui.global
global.elements = global.elements or {}


local M = FML.Object:extend()


function M:new()
	local res = M.super:new()
	
	res.id = FML.table.get_next_index(global.elements)
	global.elements[res.id] = res
	
	return res
end


function M:destroy()
	global.elements[self.id] = nil
end


return M
