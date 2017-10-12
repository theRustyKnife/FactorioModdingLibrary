--/ events.id
--- A utility for custom event names.

return function(_M)
	local FML = therustyknife.FML
	local table = therustyknife.FML.table
	
	
	function _M.make(id)
	--- Create a custom event name from the given string.
	--@ {string, Array[string]} id: The name or names of the custom event
	--: {FMLEventID, Array[FMLEventID]}: The generated id or array of them
		if type(id) == 'table' then
			local res = table()
			for _, id_inner in ipairs(id) do res:insert(_M.make(id)); end
			return res
		else return {__FMLEventID=true, id=id}; end
	end
	
	function _M.type(id)
	--- Get the type of the given id.
	--@ AnyEventID id: The id to check
	--: string: `'vanilla'`, `'input'`, `'FML'` or nil if it's not an event id
		local id_type = type(id)
		if id_type == 'string' then return 'input'
		elseif id_type == 'number' then return 'vanilla'
		elseif id_type == 'table' and id.__FMLEventID then return 'FML'
		else return nil; end
	end
	
	--f __call
	--% type: metamethod
	--- Create a custom event name from the given string.
	--* This is the same as `make`.
	--@ {string, Array[string]} id: The name or names of the custom event
	--: {FMLEventID, Array[FMLEventID]}: The generated id or array of them
	setmetatable(_M, {__call=function(_, id) return _M.make(id); end})
end
