local M = {}


function M:new()
	local res = {}
	
	setmetatable(res, self)
	self.__index = self
	
	return res
end

function M:extend()
	local child = {}
	child.super = {}
	
	setmetatable(child, self)
	setmetatable(child.super, self)
	self.__index = self
	
	return child
end


return M
