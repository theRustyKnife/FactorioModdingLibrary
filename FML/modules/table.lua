local FML = require "therustyknife.FML"


local _M = {}
local _DOC = FML.make_doc(_M, {
	type = "module",
	name = "table",
	desc = [[ Utilities for table manipulation. ]],
})
local RICH_NOTE = "Can be used as a method of RichTable."


_DOC.deep_copy = {
	type = "function",
	desc = [[ Make a deep_copy of tab. The result will have the same metatable as tab (not a copy). ]],
	notes = {RICH_NOTE},
	params = {
		tab = {
			type = "table",
			desc = "The table to copy",
		},
	},
	returns = {
		{
			type = "table",
			desc = "The deep copy",
		},
	},
}
function _M.deep_copy(tab)
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

_DOC.is_subset = {
	type = "function",
	desc = [[ Check if a table is a subset of another table. Table type values are checked for equality. ]],
	notes = {RICH_NOTE},
	params = {
		subset = {
			type = "table",
			desc = "The table that is supposed to be the subset",
		},
		superset = {
			type = "table",
			desc = "The table that is supposed to be the superset",
		},
	},
	returns = {
		{
			type = "bool",
			desc = "true if is subset, false otherwise",
		},
	},
}
function _M.is_subset(subset, superset)
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

_DOC.equals = {
	type = "function",
	desc = [[ Check if two tables are equal by value. ]],
	notes = {
		"Be careful when comparing large or deeply nested tables, as they need to be iterated over entirely.",
		RICH_NOTE,
	},
	params = {
		tab1 = {
			type = "table",
		},
		tab2 = {
			type = "table",
		},
	},
	returns = {
		{
			type = "bool",
			desc = "true if equal, false otherwise",
		},
	},
}
function _M.equals(tab1, tab2)
	if tab1 == tab2 then return true; end
	
	return _M.is_subset(tab1, tab2) and _M.is_subset(tab2, tab1)
end

_DOC.insert_all = {
	type = "function",
	desc = [[ Inserts all elements from src to dest. ]],
	params = {
		dest = {
			type = "table",
			desc = "The table to insert into",
		},
		src = {
			type = "table",
			desc = "The table whose elements are to be inserted",
		},
		overwrite = {
			type = "bool",
			desc = "If true, keys already present in dest will be replaced with the ones from src",
			default = "false",
		},
		deep = {
			type = "bool",
			desc = "If true, elements are going to be deep coppied before inserting",
			default = "false",
		},
	},
	returns = {
		{
			type = "table",
			desc = "The dest table",
		},
	},
}
function _M.insert_all(dest, src, overwrite, deep)
	if type(dest) ~= "table" or type(src) ~= "table" then return; end
	for i, v in pairs(src) do
		if overwrite or dest[i] == nil then
			if deep and type(v) == "table" then dest[i] = _M.deep_copy(v)
			else dest[i] = v
			end
		end
	end
	
	return dest
end

_DOC.getn = {
	type = "function",
	desc = [[ Count elements in tab by iteration. ]],
	notes = {RICH_NOTE},
	params = {
		tab = {
			type = "table",
			desc = "The table to count",
		},
	},
	returns = {
		{
			type = "int",
			desc = "The number of elements in tab",
		},
	},
}
function _M.getn(tab)
	local n = 0
	for _ in pairs(tab) do n = n + 1; end
	return n
end

_DOC.get_next_index = {
	type = "function",
	desc = [[ Get the next free integer index in tab. ]],
	notes = {RICH_NOTE},
	params = {
		tab = {
			type = "table",
			desc = "The table to get the next index for",
		},
		start = {
			type = "int",
			desc = "The index to start checking at",
			default = "1",
		},
	},
	returns = {
		{
			type = "int",
			desc = "The found index",
		},
	},
}
function _M.get_next_index(tab, start)
	start = start or 1
	local i = 1
	while true do
		if tab[i] == nil then return i; end
		i = i + 1
	end
end

_DOC.is_empty = {
	type = "function",
	desc = [[ Check if a table is empty. Convenience for 'next(tab) == nil'. ]],
	notes = {RICH_NOTE},
	params = {
		tab = {
			type = "table",
			desc = "The table to check",
		},
	},
	returns = {
		{
			type = "bool",
			desc = "true if empty, false otherwise",
		},
	},
}
function _M.is_empty(tab) return next(tab) == nil; end

_DOC.index_of = {
	type = "function",
	desc = [[ Find the first index of element in tab. ]],
	notes = {RICH_NOTE},
	params = {
		tab = {
			type = "table",
			desc = "The table to check in",
		},
		element = {
			type = "Any",
			desc = "The element to look for",
		},
	},
	returns = {
		{
			type = "Any",
			desc = "The first index of element, nil if not present",
		},
	},
}
function _M.index_of(tab, element)
	for i, v in pairs(tab) do
		if v == element then return i; end
	end
	return nil
end

_DOC.contains = _M.deep_copy(_DOC.index_of)
_DOC.contains.desc = [[ Check if element is present in tab. ]]
_DOC.contains.notes = {"Alias for table.index_of.", RICH_NOTE}
_M.contains = _M.index_of --(tab, element)

_DOC.remove_v = {
	type = "function",
	desc = [[ Remove value from tab. Uses index_of to find the index to remove. ]],
	notes = {RICH_NOTE},
	params = {
		tab = {
			type = "table",
			desc = "The table to remove from",
		},
		value = {
			type = "Any",
			desc = "The value to remove",
		},
	},
}
function _M.remove_v(tab, value)
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

_DOC.enrich = {
	type = "function",
	desc = [[
	Set the metatable of tab to contain functions from this module. Obviously, this will remove any metatable the table 
	had before, so be careful.
	]],
	notes = {
		"The function operates directly on the table passed in, so the returned table is the same one.",
		[[
			This function needs to be called in on_load for each table because metatables are not serialized by Factorio. 
			This might be changed in the future.
		]],
	},
	params = {
		tab = {
			type = "table",
			desc = "The table to enrich",
		},
	},
	returns = {
		{
			type = "RichTable",
			desc = "The enriched table"
		},
	},
}
--TODO: automatic metatable setup on load for tables that had enrich called on them
function _M.enrich(tab)
	return setmetatable(tab, RICH_MT)
end

_DOC.new = {
	type = "function",
	desc = [[ Return a new RichTable. Same as _M.enrich({}) ]],
	returns = {
		{
			type = "RichTable",
			desc = "The new table",
		},
	},
}
function _M.new()
--[[ Make a new rich table. ]]
	return _M.enrich({})
end


return _M
