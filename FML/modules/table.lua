local _M = {}
--[[ Utilities for table manipulation. ]]


function _M.deep_copy(tab)
--[[ Make a deep_copy of tab. The result will have the same metatable as tab (not a copy). ]]
	local lookup_table = {}
	
	local function _copy(tab)
		if type(tab) ~= "table" then return tab
		elseif tab.__self then return tab
		elseif lookup_table[tab] then return lookup_table[tab]
		end
		
		local new_table = {}
		lookup_table[tab] = new_table
		
		for i, v in pairs(tab) do new_table[_copy(i)] = _copy(v); end
		
		return setmetatable(new_table, getmetatable(tab))
	end
	
	return _copy(tab)
end

function _M.is_subset(subset, superset)
--[[ Check if a table is a subset of another table. Table type values are checked for equality. ]]
	if subset == superset then return true; end
	
	for i, v in pairs(subset) do
		if type(v) == "table" and not v.__self and type(superset[i]) == "table" and not superset[i].__self then
			if not _M.equals(v, superset[i]) then return false; end
		else
			if not v == superset[i] then return false; end
		end
	end
	
	return true
end

function _M.equals(tab1, tab2)
--[[
Check if two tables are equal by value. Be careful when comparing large or deeply nested tables, as they need to be
iterated over entirely. ]]
	if tab1 == tab2 then return true; end
	
	return _M.is_subset(tab1, tab2) and _M.is_subset(tab2, tab1)
end

function _M.insert_all(dest, src, overwrite, deep)
--[[
Insert all values from src to dest. If overwrite is true, original values in dest are replaced with the ones from src.
If deep is true, tables are coppied using deep_copy before inserting, otherwise, the same table is inserted.
]]
	if type(dest) ~= "table" or type(src) ~= "table" then return; end
	for i, v in pairs(src) do
		if overwrite or dest[i] == nil then
			if deep and type(v) == "table" then dest[i] = _M.deep_copy(v)
			else dest[i] = v
			end
		end
	end
end

function _M.getn(tab)
--[[ Count elements in tab by iteration. ]]
	local n = 0
	for _ in pairs(tab) do n = n + 1; end
	return n
end

function _M.get_next_index(tab, start)
--[[ Get the next free numeric index in tab. Optionally specify the first index to check (default is 1). ]]
	start = start or 1
	local i = 1
	while true do
		if tab[i] == nil then return i; end
		i = i + 1
	end
end

function _M.is_empty(tab)
--[[ Check if a table is empty. Convenience for 'next(tab) == nil'. ]]
	return next(tab) == nil
end

function _M.index_of(tab, element)
--[[ Find the first index of element in tab. Returns nil if tab doesn't conatain element. ]]
	for i, v in pairs(tab) do
		if v == element then return i; end
	end
	return nil
end

_M.contains = _M.index_of --(tab, element)
--[[
Alias for index_of. Returns the index of element (true) or nil (false).
Note that elements indexed by false will not be found.
]]

function _M.remove_v(tab, value)
--[[ Remove value from tab. Uses index_of to find the index to remove. ]]
	table.remove(tab, _M.index_of(tab, value))
end


-- Declare what methods rich tables are going to have
-- All of them can be called with the colon syntax
local RICH_MT = {
	deep_copy = _M.deep_copy,
	is_subset = _M.is_subset,
	equals = _M.equals,
	getn = _M.getn,
	get_next_index = _M.get_next_index,
	is_empty = _M.is_empty,
	index_of = _M.index_of,
	contains = _M.contains,
	remove_v = _M.remove_v,
	
	-- Add Lua's table methods for convenience as well
	insert = table.insert,
	remove = table.remove,
	concat = table.concat,
	sort = table.sort,
	
	--TODO: override these functions to work with other metatables (if __index is a table, set this as it's metatable)
	getmetatable = getmetatable,
	setmetatable = setmetatable,
}
RICH_MT.__index = RICH_MT

--TODO: automatic metatable setup on load for tables that had enrich called on them
function _M.enrich(tab)
--[[
Set the metatable of tab to conatain functions from this module. Obviously, this will remove any metatable the table had
before, so be careful.
This function needs to be called in on_load for each table because metatables are not serialized by Factorio. This might
be changed in the future.
]]
	return setmetatable(tab, RICH_MT)
end

function _M.new()
--[[ Make a new rich table. ]]
	return _M.enrich({})
end


return _M
