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
	
	_DOC.shift = {
		short_desc = "Shift a position by specific x and y values.",
		desc = [[
		Shift a position by specific x and y values.  
		The dx and dy may also be specified as a [[Position|Position]].
		]],
		params = {
			{
				type = "Position",
				name = "position",
				desc = "The position to shift",
			},
			{
				type = "float",
				name = "dx",
			},
			{
				type = "float",
				name = "dy",
			},
		},
		returns = {
			{
				type = "Position",
				desc = "The shifted position",
			},
		},
	}
	function _M.shift(position, dx, dy)
		local x, y = _M.unpack_position(position)
		if type(dx) ~= "number" then dx, dy = _M.unpack_position(dx); end
		return _M.pack_position(x + dx, y + dy)
	end
	
	_DOC.expand = {
		desc = [[ Expand a BoundingBox from the center out by the given values. ]],
		notes = {"The values can be negative to shrink the box."},
		params = {
			{
				type = "BoundingBox",
				name = "box",
				desc = "The BoundingBox to expand",
			},
			{
				type = "float",
				name = "dx",
			},
			{
				type = "float",
				name = "dy",
				default = "same as dx",
			},
		},
		returns = {
			{
				type = "BoundingBox",
				desc = "The expanded BoundingBox",
			},
		},
	}
	function _M.expand(box, dx, dy)
		dy = (dy or dx)/2
		dx = dx/2
		local x1, y1, x2, y2 = _M.unbox(box)
		return _M.box(x1-dx, y1-dy, x2+dx, y2+dy)
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
		return setmetatable({x = x, y = y}, {__index = {x, y}})
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
		--TODO: make this function accept two Positions as well
		local left_top, right_bottom = _M.pack_position(x1, y1), _M.pack_position(x2, y1)
		return setmetatable({left_top = left_top, right_bottom = right_bottom}, {__index = {left_top, right_bottom}})
	end
	
	_DOC.unbox = {
		desc = [[ Get the individual coordinate values from a BoundingBox. ]],
		params = {
			{
				type = "BoundingBox",
				name = "box",
				desc = "The box to unbox",
			},
		},
		returns = {
			{
				type = "float",
				desc = "Left edge coordinate",
			},
			{
				type = "float",
				desc = "Top edge coordinate",
			},
			{
				type = "float",
				desc = "Right edge coordinate",
			},
			{
				type = "float",
				desc = "Bottom edge coordinate",
			},
		},
	}
	function _M.unbox(box)
		local x1, y1 = _M.unpack_position(box[1] or box.left_top)
		local x2, y2 = _M.unpack_position(box[2] or box.right_bottom)
		return x1, y1, x2, y2
	end
end
