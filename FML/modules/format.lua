--/ format
--- Functions for pretty printing certain things.

return function(_M)
	local FML = therustyknife.FML


	-- Require surface for printing positions and stuff
	if FML.STAGE == "RUNTIME" or FML.STAGE == "RUNTIME_SHARED" then
		function _M.position(pos)
		--- Format a Position to a human-readable format.
		--@ Position pos: The position to format
		--: string: The formatted position
			local x, y = FML.surface.unpack_position(pos)
			return string.format("[%g, %g]", x, y)
		end
	end


	function _M.time(ticks)
	--- Format a time in ticks into minutes and seconds.
	--@ uint ticks: The time in ticks
	--: string: The formatted time
		local s = ticks / 60
		local m = math.floor(s / 60)
		s = math.floor(s % 60)
		
		return string.format("%d:%02d", m, s)
	end
end