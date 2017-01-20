local M = {}


function M.distance(pos1, pos2)
	return ((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2)^0.5
end

function M.move_position(position, direction, distance)
	local x, y = M.unpack_position(position)
	
	if     direction == defines.direction.north then y = y - distance
	elseif direction == defines.direction.south then y = y + distance
	elseif direction == defines.direction.east  then x = x + distance
	elseif direction == defines.direction.west  then x = x - distance
	end
	
	return M.pack_position(x, y)
end

function M.flip_direction(direction)
	return (direction + 4) % 10 -- simplified implementation based on the defines values - I hope they don't change...
end

function M.create_dummy_from(entity, dummy_name, destructible, operable) --TODO: redo this and possibly move it somewhere else
	local res = entity.surface.create_entity{
		name = dummy_name,
		position = entity.position,
		force = entity.force
	}
	res.destructible = destructible or false
	res.operable = operable or false
	
	return res
end

function M.area_around(position, distance)
	local x, y = M.unpack_position(position)
	local x1, y1, x2, y2 = x - distance, y - distance, x + distance, y + distance
	
	return {M.pack_position(x1, y1), M.pack_position(x2, y2)}
end

function M.unpack_position(pos)
	local x, y = pos.x, pos.y
	
	if not x or not y then -- support both position formats ({x=x, y=y} and {[1]=x, [2]=y})
		x, y = pos[1], pos[2]
	end
	if not x or not y then error("Position not in correct format.") end
	
	return x, y
end

function M.pack_position(x, y)
	return {x, y, x = x, y = y}
end


return M
