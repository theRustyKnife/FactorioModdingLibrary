local FML = require "therustyknife.FML"


local _M = {}
local _DOC = FML.make_doc(_M, {
	type = "module",
	name = "table",
	desc = [[ Utilities for table manipulation. ]],
	notes = {[[
	The recommended way to use this module is to override the built-in `table` module like so: `local table = FML.table`.
	Any exisiting code should be compatible with this as the module contains references to all the built-in functions.
	Moreover, this allows you to create `RichTable`s easily like this: `local my_table = table()`.
	]]},
})
local RICH_NOTE = "Can be used as a method of RichTable."


_DOC.deep_copy = {
	type = "function",
	short_desc = [[ Make a deep_copy of tab. ]],
	desc = [[ Make a deep_copy of tab. The result will have the same metatable as tab (not a copy). ]],
	notes = {RICH_NOTE},
	params = {
		{
			type = "table",
			name = "tab",
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
	short_desc = [[ Check if a table is a subset of another table. ]],
	desc = [[ Check if a table is a subset of another table. Table type values are checked for equality. ]],
	notes = {RICH_NOTE},
	params = {
		{
			type = "table",
			name = "subset",
			desc = "The table that is supposed to be the subset",
		},
		{
			type = "table",
			name = "superset",
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
		{
			type = "table",
			name = "tab1",
		},
		{
			type = "table",
			name = "tab2",
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
	desc = [[ Insert all elements from src to dest. ]],
	params = {
		{
			type = "table",
			name = "dest",
			desc = "The table to insert into",
		},
		{
			type = "table",
			name = "src",
			desc = "The table whose elements are to be inserted",
		},
		{
			type = "bool",
			name = "overwrite",
			desc = "If true, keys already present in dest will be replaced with the ones from src",
			default = "false",
		},
		{
			type = "bool",
			name = "deep",
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
		{
			type = "table",
			name = "tab",
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
		{
			type = "table",
			name = "tab",
			desc = "The table to get the next index for",
		},
		{
			type = "int",
			name = "start",
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
	short_desc = [[ Check if a table is empty. ]],
	desc = [[ Check if a table is empty. Convenience for 'next(tab) == nil'. ]],
	notes = {RICH_NOTE},
	params = {
		{
			type = "table",
			name = "tab",
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
		{
			type = "table",
			name = "tab",
			desc = "The table to check in",
		},
		{
			type = "Any",
			name = "element",
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
	short_desc = [[ Remove value from tab. ]],
	desc = [[ Remove value from tab. Uses index_of to find the index to remove. ]],
	notes = {RICH_NOTE},
	params = {
		{
			type = "table",
			name = "tab",
			desc = "The table to remove from",
		},
		{
			type = "Any",
			name = "value",
			desc = "The value to remove",
		},
	},
	returns = {
		{
			type = "Any",
			desc = "The index of the element that got removed",
		},
	},
}
function _M.remove_v(tab, value)
	local index = _M.index_of(tab, value)
	table.remove(tab, index)
	return index
end


_DOC.insert_at_next_index = {
	type = "function",
	desc = [[ Insert the given element at the first free numeric index. ]],
	notes = {"Uses table.get_next_index to find the index.", RICH_NOTE},
	params = {
		{
			type = "table",
			name = "tab",
			desc = "The table to insert into",
		},
		{
			type = "Any",
			name = "element",
			desc = "The element to insert",
		},
	},
	returns = {
		{
			type = "int",
			desc = "The index the element was inserted at",
		},
	},
}
function _M.insert_at_next_index(tab, element)
	local index = _M.get_next_index(tab)
	tab[index] = element
	return index
end

_DOC.numeric_indices = {
	type = "function",
	desc = [[ Find all numeric indices in the table. ]],
	notes = {RICH_NOTE},
	params = {
		{
			type = "table",
			name = "tab",
			desc = "The table to search in",
		},
		{
			type = "bool",
			name = "in_place",
			desc = "If true, the resulting table is going to be set to the `_ids` field of the table.",
			default = "false",
		},
	},
	returns = {
		{
			type = "Array[int]",
			desc = "The numeric indices in ascending order",
		},
	},
}
function _M.numeric_indices(tab, in_place)
	local res = _M()
	local last
	for i, v in pairs(tab) do
		if type(i) == "number" and i%1 == 0 then res:insert(i); end
	end
	res:sort()
	if in_place then tab[_ids] = res; end
	return res
end

_DOC.n_insert = {
	type = "function",
	short_desc = "Insert element and update `_ids`",
	desc = [[ Insert the given element at the given index and update the `_ids` field to reflect the change. ]],
	notes = {
		"Can only be used on tables that already have the `_ids` field present (numerically indexed tables).",
		RICH_NOTE,
	},
	params = {
		{
			type = "table",
			name = "tab",
			desc = "The table to insert into",
		},
		{
			type = "int",
			name = "index",
			desc = "The index to insert at",
		},
		{
			type = "Any",
			name = "value",
			desc = "The value to insert, if nil, `_ids` is still update as if the value wasn't nil",
		},
	},
}
function _M.n_insert(tab, index, value)
	if not tab[index] then
		_M.insert(tab._ids, index)
		_M.sort(tab._ids)
	end
	tab[index] = value
end

_DOC.n_insert_at_next_index = {
	type = "function",
	desc = [[ Insert the given value at the next integer index and update `_ids`. ]],
	notes = {
		"Can only be used on tables that already have the `_ids` field present (numerically indexed tables).",
		RICH_NOTE,
	},
	params = {
		{
			type = "table",
			name = "tab",
			desc = "The table to insert into",
		},
		{
			type = "Any",
			name = "value",
			desc = "The value to insert",
		},
	},
	returns = {
		{
			type = "int",
			desc = "The index the value was inserted to",
		},
	},
}
function _M.n_insert_at_next_index(tab, value)
	local index = _M.get_next_index(tab)
	_M.n_insert(tab, index, value)
	return index
end

_DOC.n_remove = {
	type = "function",
	desc = [[ Set the value at an index to nil and update `_ids`. ]],
	notes = {
		"Can only be used on tables that already have the `_ids` field present (numerically indexed tables).",
		RICH_NOTE,
	},
	params = {
		{
			type = "table",
			name = "tab",
			desc = "The table to remove from",
		},
		{
			type = "int",
			name = "index",
			desc = "The index to remove from",
		},
	},
	returns = {
		{
			type = "Any",
			desc = "The value that was removed",
		},
	},
}
function _M.n_remove(tab, index)
	local res = tab[index]
	tab[index] = nil
	if res then _M.remove_v(tab._ids, index); end
	return res
end

_DOC.n_remove_v = {
	type = "function",
	desc = [[ Remove the given element from the table and udpate `_ids`. ]],
	notes = {
		"Can only be used on tables that already have the `_ids` field present (numerically indexed tables).",
		RICH_NOTE,
	},
	params = {
		{
			type = "table",
			name = "tab",
			desc = "The table to remove from",
		},
		{
			type = "Any",
			name = "element",
			desc = "The vvalue to remove",
		},
	},
	returns = {
		{
			type = "int",
			desc = "The index that was removed, nil if the value wasn't present",
		},
	},
}
function _M.n_remove_v(tab, element)
	local index = _M.remove_v(tab, element)
	if index then _M.remove_v(tab._ids, index); end
	return index
end

_DOC.last = {
	type = "function",
	desc = [[Return the last value in this Array. ]],
	notes = {RICH_NOTE},
	params = {
		{
			type = "Array",
			name = "arr",
			desc = "The Array to check",
		},
	},
	returns = {
		{
			type = "Any",
			desc = "The last value or nil if none",
		},
	},
}
function _M.last(arr) return arr[#arr]; end

_DOC.highest_index = {
	type = "function",
	desc = [[ Get the highest numeric index in the table. ]],
	notes = {RICH_NOTE},
	params = {
		{
			type = "table",
			name = "tab",
			desc = "The table to check",
		},
	},
	returns = {
		{
			type = "int",
			desc = "The index, nil if no numeric indices are in the table",
		},
	},
}
function _M.highest_index(tab)
	return _M.numeric_indices(tab):last()
end

_DOC.ipairs_all = {
	type = "function",
	short_desc = "Get an iterator over all numeric indices.",
	desc = [[
	Return an iterator function that iterates over all numeric indices in the table. The indices are iterated over in
	ascending order.  
	If indices is nil or true, the value of the `_ids` field will be used. If it's false table.numeric_indices is used
	to obtain the indices, otherwise, the value of indices is used.
	]],
	notes = {RICH_NOTE},
	params = {
		{
			type = "table",
			name = "tab",
			desc = "The table to iterate over",
		},
		{
			type = {"Array[int]", "bool"},
			name = "indices",
			desc = "The indices to use",
			default = "nil",
		},
	},
	returns = {
		type = "int, Any function()",
		desc = "The iterator function",
	},
}
function _M.ipairs_all(tab, indices)
	if indices == nil or indices == true then indices = tab._ids or _M.numeric_indices(tab)
	else indices = indices or _M.numeric_indices(tab); end
	indices = indices or _M.numeric_indices(tab)
	local i = 1
	return function()
		local res_i = indices[i]
		local res_v = tab[res_i]
		i = i+1
		return res_i, res_v
	end
end


-- Add Lua's table library functions to allow overriding the table global with this module
local function built_in_note(name)
	return "This is a reference to Lua's built-in "..name.." function - see Lua's ducumentation for more details."
end

_DOC.insert = {
	type = "function",
	short_desc = [[ Insert the given value into the table. ]],
	desc = [[
	Insert the given value into the table. If a position is given, the value is inserted before the element currently 
	at that position, otherwise it is appended to the end of the table.  
	When an element is inserted, both size and element indices are updated. The end of the table is deduced from the `n`
	 field, thus can be specified by the user.
	]],
	notes = {RICH_NOTE, built_in_note("table.insert")},
	params = {
		{
			type = "table",
			name = "table",
			desc = "The table to insert to",
		},
		{
			type = "Any",
			name = "pos",
			desc = "The index in the table to insert at",
			default = "table.n+1",
		},
		{
			type = "Any",
			name = "value",
			desc = "The value to be inserted",
		},
	},
}
_M.insert = table.insert

_DOC.remove = {
	type = "function",
	short_desc = [[ Remove an element from a table ]],
	desc = [[
	Remove an element from a table. If position is specified, the element at that position is removed, otherwise remove
	the last element in the table.  
	When an element is removed the size and indices of remaining elements are updated. The end of the table is deduced
	from the `n` field, thus can be specified by the user.
	]],
	notes = {RICH_NOTE, built_in_note("table.remove")},
	params = {
		{
			type = "table",
			name = "table",
			desc = "The table to remove from",
		},
		{
			type = "Any",
			name = "pos",
			desc = "The position to remove from",
			default = "table.n",
		},
	},
	returns = {
		{
			type = "Any",
			desc = "The value of the element removed",
		},
	},
}
_M.remove = table.remove

_DOC.concat = {
	type = "function",
	short_desc = [[ Concatenate the elements of a table together to form a string. ]],
	desc = [[
	Concatenate the elements of a table together to form a string. Each element must be able to be coerced into a
	string. A separator can be specified which is placed between concatenated elements. Additionally a range can be
	specified within the table, starting at the i-th element and finishing at the j-th element.  
	Concatenation will fail on a table that contains tables because they cannot be coerced into strings.
	]],
	notes = {RICH_NOTE, built_in_note("table.concat")},
	params = {
		{
			type = "table",
			name = "table",
			desc = "The table to concat",
		},
		{
			type = "string",
			name = "sep",
			desc = "The separator to use",
			default = '""',
		},
		{
			type = "int",
			name = "i",
			desc = "The starting position",
			default = "1",
		},
		{
			type = "int",
			name = "j",
			desc = "The end position",
			default = "table.n",
		},
	},
	returns = {
		{
			type = "string",
			desc = "The concatenated table",
		},
	},
}
_M.concat = table.concat

_DOC.sort = {
	type = "function",
	short_desc = [[ Sort the elements of a table in-place (i.e. alter the table). ]],
	desc = [[
	Sort the elements of a table in-place (i.e. alter the table). If the table has a specified size only the range
	specified is sorted.  
	A comparison function can be provided to customise the element sorting. The comparison function must return a bool
	value specifying whether the first argument should be before the second argument in the sequence. The default
	behavior is for the < comparison to be made.
	]],
	notes = {RICH_NOTE, built_in_note("table.sort")},
	params = {
		{
			type = "table",
			name = "table",
			desc = "The table to sort",
		},
		{
			type = "function(Any a,  Any b)",
			name = "comp",
			desc = "The comparator function",
			default = "the < operator",
		},
	},
}
_M.sort = table.sort

function _M.setmetatable(tab, mt)
	if tab.__rich then
		local omt = getmetatable(tab)
		setmetatable(omt.__index, mt)
		setmetatable(omt, mt)
		return tab
	else return setmetatable(tab, mt); end
end

function _M.getmetatable(tab)
	if tab__rich then return getmetatable(getmetatable(tab))
	else return getmetatable(tab); end
end

_DOC.enrich = {
	type = "function",
	short_desc = [[ Set the metatable of tab to contain functions from this module. ]],
	desc = [[
	Set the metatable of tab to contain functions from this module. The original metatable will be set as the metatable
	of the new metatable, so the original functionality should still be available.
	]],
	notes = {
		"The function operates directly on the table passed in, so the returned table is the same one.",
		[[
			This function needs to be called in on_load for each table because metatables are not serialized by Factorio.
			This might be changed in the future.
		]],
	},
	params = {
		{
			type = "table",
			name = "tab",
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
	-- Declare what methods rich tables are going to have
	-- All of them can be called with the colon syntax
	local RICH_MT = {
		__rich = true, -- Indicate that this is a RichTable, so we know how to set metatables
		
		deep_copy = _M.deep_copy,
		is_subset = _M.is_subset,
		equals = _M.equals,
		getn = _M.getn,
		get_next_index = _M.get_next_index,
		is_empty = _M.is_empty,
		index_of = _M.index_of,
		contains = _M.contains,
		remove_v = _M.remove_v,
		numeric_indices = _M.numeric_indices,
		last = _M.last,
		highest_index = _M.highest_index,
		ipairs_all = _M.ipairs_all,
		n_insert = _M.n_insert,
		n_remove = _M.n_remove,
		
		-- The built-in functions happen to be usable as methods too
		insert = _M.insert,
		remove = _M.remove,
		concat = _M.concat,
		sort = _M.sort,
		
		--TODO: override these functions to work with other metatables (if __index is a table, set this as it's metatable)
		getmetatable = _M.getmetatable,
		setmetatable = _M.setmetatable,
	}
	
	local mt = getmetatable(tab)
	if mt then return setmetatable(tab, setmetatable({__index = setmetatable(RICH_MT, mt)}, mt))
	else return setmetatable(tab, {__index = RICH_MT}); end
end

_DOC.new = {
	type = "function",
	short_desc = [[ Return a new RichTable. ]],
	desc = [[ Return a new RichTable. Same as `table.enrich({})`. ]],
	notes = {"The [__call](#__call) metamethod can be used to create a RichTable like so: `table()`."},
	returns = {
		{
			type = "RichTable",
			desc = "The new table",
		},
	},
}
function _M.new()
	return _M.enrich({})
end


_M._DOC.metamethods = {
	__call = {
		short_desc = [[ Create a new RichTable. ]],
		desc = [[
		Create a new RichTable. A table can be passed as a parameter if you want to create a populated table.  
		The constructor with values might look like this: `local my_table = table{"foo", "bar"}`.
		]],
		notes = {[[
		If you want to use RichTables that are serialized, you can call this constructor in the `load` event like so:
		`global.my_global_rich_table = table(global.my_global_rich_table)`. This not only ensures that the table is going
		to be enriched on load, but also creates the table if it doesn't exist, which would have to be done anyway.
		]]},
		params = {
			{
				type = "table",
				name = "tab",
				desc = "The table to use as base",
				default = "{}",
			},
		},
		returns = {
			{
				type = "RichTable",
				desc = "The new table",
			},
		},
	},
}
-- Allow using the module as a class constructor
setmetatable(_M, {__call = function(_, tab) return _M.enrich(tab or {}); end})


return _M
