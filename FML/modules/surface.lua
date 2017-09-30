--/ surface
--- Provides functions related to surface and position manipulation.

return function(_M)
	local FML = therustyknife.FML
	
	
	function _M.square(position, size)
	--- Make a square around a point.
	--@ Position position: The point that will be the center of the square
	--@ float size: The length of the edge of the square
	--: BoundingBox: The resulting square
		size = size/2
		local x, y = _M.unpack_position(position)
		return _M.box(x-size, y-size, x+size, y+size)
	end
	
	function _M.move(position, direction, distance)
	--- Move a position.
	--@ Position position: The position to move
	--@ Direction dirction: The direction to move in
	--@ float distance: How far to move
	--: Position: The moved position
		local x, y = _M.unpack_position(position)
		
		if     direction == defines.direction.north then y = y - distance
		elseif direction == defines.direction.south then y = y + distance
		elseif direction == defines.direction.east  then x = x + distance
		elseif direction == defines.direction.west  then x = x - distance
		end
		
		return _M.pack_position(x, y)
	end
	
	function _M.shift(position, dx, dy)
	--- Shift a position by specific x and y values.
	--- The dx and dy may also be specified as a |:Position:|.
	--@ Position position: The position to shift
	--@ float dx
	--@ float dy
	--: Position: The shifted position
		local x, y = _M.unpack_position(position)
		if type(dx) ~= "number" then dx, dy = _M.unpack_position(dx); end
		return _M.pack_position(x + dx, y + dy)
	end
	
	--TODO: shift BoundingBox
	
	function _M.expand(box, dx, dy)
	--- Expand a BoundingBox from the center out by the given values.
	--* The values can be negative to shrink the box.
	--@ BoundingBox box: The BoundingBox to expand
	--@ float dx
	--@ float dy
	--: BoundingBox: The expanded BoundingBox
		dy = (dy or dx)/2
		dx = dx/2
		local x1, y1, x2, y2 = _M.unbox(box)
		return _M.box(x1-dx, y1-dy, x2+dx, y2+dy)
	end
	
	
	function _M.unpack_position(pos)
	--- Gets the x and y from a Position, regardless of the format.
	--@ Position pos: The position to unpack
	--: float: The x coordinate
	--: float: The y coordinate
		local x, y = pos.x, pos.y
		if not x or not y then x, y = unpack(pos); end
		assert(x and y, "Position not in correct format.")
		return x, y
	end
	
	function _M.pack_position(x, y)
	--- Make a Position from x and y.
	--@ float x
	--@ float y
	--: Position: The packed Position
		return setmetatable({x = x, y = y}, {__index = {x, y}})
	end
	
	function _M.box(x1, y1, x2, y2)
	--- Make a BoundingBox from two points
	--@ float x1: Left edge coordinate
	--@ float y1: Top edge coordinate
	--@ float x2: Right edge coordinate
	--@ float y2: Bottom edge coordinate
	--: BoundingBox
		--TODO: make this function accept two Positions as well
		local left_top, right_bottom = _M.pack_position(x1, y1), _M.pack_position(x2, y2)
		return setmetatable({left_top = left_top, right_bottom = right_bottom}, {__index = {left_top, right_bottom}})
	end
	
	function _M.unbox(box)
	--- Get the individual coordinate values from a BoundingBox.
	--@ BoundingBox box: The box to unbox
	--: float: Left edge coordinate
	--: float: Top edge coordinate
	--: float: Right edge coordinate
	--: float: Bottom edge coordinate
		local x1, y1 = _M.unpack_position(box[1] or box.left_top)
		local x2, y2 = _M.unpack_position(box[2] or box.right_bottom)
		return x1, y1, x2, y2
	end
end
