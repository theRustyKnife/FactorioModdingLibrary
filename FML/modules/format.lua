local FML = require "therustyknife.FML"


local M = {}


function M.position(pos)
	local x, y = FML.surface.unpack_position(pos)
	return string.format("[%g, %g]", x, y)
end

function M.time(ticks) -- mostly borrowed from original util
	local s = ticks / 60
	local m = math.floor(s / 60)
	local s = math.floor(s % 60)
	
	return string.format("%d:%02d", m, s)
end


return M
