local FML = require "therustyknife.FML"


local _M = {}
local _DOC = FML.make_doc(_M, {
	type = "module",
	name = "format",
	desc = [[ Functions for pretty printing certain things. ]],
})


-- Require surface for printing positions and stuff
if FML.surface then
	_DOC.position = {
		type = "function",
		desc = [[ Format a Position to a human-readable format. ]],
		params = {
			pos = {
				type = "Position",
				desc = "The position to format",
			},
		},
		returns = {
			{
				type = "string",
				desc = "The formatted position",
			},
		},
	}
	function _M.position(pos)
		local x, y = FML.surface.unpack_position(pos)
		return string.format("[%g, %g]", x, y)
	end
end


_DOC.time = {
	type = "function",
	desc = [[ Format a time in ticks into minutes and seconds. ]],
	params = {
		ticks = {
			type = "int",
			desc = "The time in ticks",
		},
	},
	returns = {
		{
			type = "string",
			desc = "The formatted time",
		},
	},
}
function _M.time(ticks)
	local s = ticks / 60
	local m = math.floor(s / 60)
	s = math.floor(s % 60)
	
	return string.format("%d:%02d", m, s)
end


return _M
