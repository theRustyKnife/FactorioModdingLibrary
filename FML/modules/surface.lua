return function(_M)
	local FML = therustyknife.FML
	
	
	local _DOC = FML.make_doc(_M, {
		type = "module",
		name = "surface",
		desc = [[ Provides functions related to surface and position manipulation. ]],
	})
	
	
	_DOC.square = {
		desc = [[ Make a square around a point. ]],
		params = {
			{
				type = "Position",
				name = "position",
				desc = "The point that will be the center of the square",
			},
			{
				type = "float",
				name = "size",
				desc = "The length of the edge of the square",
			},
		},
		returns = {
			{
				type = "BoundingBox",
				desc = "The resulting square",
			},
		},
	}
	function _M.square(position, size)
		size = size/2
		local x, y = _M.unpack_position(position)
		return _M.box(x-size, y-size, x+size, y+size)
	end
	
	_DOC.move = {
		desc = [[ Move a position. ]],
		params = {
			{
				type = "Position",
				name = "position",
				desc = "The position to move",
			},
			{
				type = "Direction",
				name = "direction",
				desc = "The direction to move in",
			},
			{
				type = "float",
				name = "distance",
				desc = "How far to move",
			},
		},
		returns = {
			{
				type = "Position",
				desc = "The moved position",
			},
		},
	}
	function _M.move(position, direction, distance)
		local x, y = _M.unpack_position(position)
		
		if     direction == defines.direction.north then y = y - distance
		elseif direction == defines.direction.south then y = y + distance
		elseif direction == defines.direction.east  then x = x + distance
		elseif direction == defines.direction.west  then x = x - distance
		end
		
		return _M.pack_position(x, y)
	end
	
	
	_DOC.unpack_position = {
		type = "function",
		desc = [[ Gets the x and y from a Position, regardless of the format. ]],
		params = {
			{
				type = "Position",
				name = "pos",
				desc = "The position to unpack",
			},
		},
		returns = {
			{
				type = "float",
				desc = "The x coordinate",
			},
			{
				type = "float",
				desc = "The y coordinate",
			},
		},
	}
	function _M.unpack_position(pos)
		local x, y = pos.x, pos.y
		if not x or not y then x, y = unpack(pos); end
		assert(x and y, "Position not in correct format.")
		return x, y
	end
	
	_DOC.pack_position = {
		type = "function",
		desc = [[ Make a Position from x and y. ]],
		params = {
			{
				type = "float",
				name = "x",
				desc = "The x coordinate",
			},
			{
				type = "float",
				name = "y",
				desc = "The y coordinate",
			},
		},
		returns = {
			{
				type = "Position",
				desc = "The packed Position",
			},
		},
	}
	function _M.pack_position(x, y)
		return {x, y, x = x, y = y}
	end
	
	_DOC.box = {
		desc = [[ Make a BoundingBox from two points. ]],
		params = {
			{
				type = "float",
				name = "x1",
				desc = "Left edge coordinate",
			},
			{
				type = "float",
				name = "y1",
				desc = "Top edge coordinate",
			},
			{
				type = "float",
				name = "x2",
				desc = "Right edge coordinate",
			},
			{
				type = "float",
				name = "y2",
				desc = "Bottom edge coordinate",
			},
		},
		returns = {
			{
				type = "BoundingBox",
			},
		},
	}
	function _M.box(x1, y1, x2, y2)
		--TODO: make this according to the API doc as well (top_left, bottom_right)
		--TODO: make this function accept two Positions as well
		return {_M.pack_position(x1, y1), _M.pack_position(x2, y1)}
	end
end
