--/ table
--- Utilities for table manipulation.
--- It is recommended to override the built-in global `table` with this module.
--* The module contains all the built-in `table` functions, so it should be compatible with existing code.


return function(_M)
	local FML = therustyknife.FML
	
	
	local RICH_NOTE = "Can be used as a method of RichTable."
		
	
	function _M.deep_copy(tab)
	--- Make a copy of a table.
	--* The result will have the same metatable as the original, not a copy.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to copy
	--: table: The deep copy
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
	--- Check if a table is a subset of another table.
	--- Table type values are checked for equality using the `==` operator.
	--* Can be used as a method of RichTable.
	--@ table subset: The table that is supposed to be the subset
	--@ table superset: The table that is supposed to be the superset
	--: bool: true if subset, false otherwise
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
	--- Check if two tables are equal by value.
	--* Be careful when comparing large or deeply nested tables, as they need to be iterated over entirely.
	--* Can be used as a method of RichTable.
	--@ table tab1
	--@ table tab2
	--: bool: true if equal, false otherwise
		if tab1 == tab2 then return true; end
		
		return _M.is_subset(tab1, tab2) and _M.is_subset(tab2, tab1)
	end

	function _M.merge(dest, src, overwrite, deep)
	--- Insert all elements from src to dest.
	--@ table dest: The table to insert into
	--@ table src: The table whose elements are to be isnerted
	--@ bool overwrite=false: If true, keys already present in dest will be replaced with those from src
	--@ bool deep=false: If true, elements will be deep coppied before inserting
	--: table: The dest table
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
	
	function _M.insert_all(dest, src, deep)
	--- Insert all elements from src to dest using the insert function.
	--* Can be used as a method of RichTable.
	--@ table dest: The table to insert into
	--@ table src: The table whose elements to insert
	--@ bool deep=false: If true, values will be deep coppied before insertion
	--: table: A reference to the original table, with the inserted values
		for _, v in pairs(src) do
			_M.insert(dest, (deep and _M.deep_copy(v)) or v)
		end
		
		return dest
	end
	
	function _M.any(tab, func)
	--- Check if any value in table fulfills a criteria.
	--- Iterate over a table and apply a function to the elements. As soon as the function returns true, any will return true.
	--- If such situation does not happen, false is returned.
	--* Can be used as method of RichTable.
	--@ table tab: The table to apply the function to
	--@ function func: The function to apply
	--: bool: true if any of the calls returned true
		if not tab then return false; end
		for i, v in pairs(tab) do
			if func(i, v) then return true; end
		end
		return false
	end
	
	function _M.any_tab(tab, func)
	--- Same as any, but only calls the function for tables.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to apply the function to
	--@ function func: The function to apply
	--: bool: true if any of the calls returned true
		if not tab then return false; end
		for i, v in pairs(tab)do
			if type(v) == "table" and func(i, v) then return true; end
		end
		return false
	end
	
	--f getn
	--- Return the count of elements in the table.
	--- This is an alias for the `table_size` function. It is in the C++ backend so it's faster than anything in Lua.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to count
	--: uint: The number of element in the table
	_M.getn = table_size
	
	function _M.get_free_index(tab, start)
	--- Get the first free integer index in tab.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to get the index for
	--@ int start=1: The index to start checking at
	--: int: The found index
		start = start or 1
		local i = 1
		while true do
			if tab[i] == nil then return i; end
			i = i + 1
		end
	end
	
	--TODO: docs
	--TODO: insert functions using this
	function _M.get_next_index(tab)
		return _M.maxn(tab)+1
	end
	
	function _M.is_empty(tab)
	--- Check if a table is empty.
	--- Convenience for `next(tab) == nil`.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to check
	--: bool: true if empty, false otherwise
		return next(tab) == nil
	end

	function _M.index_of(tab, element)
	--- Find the first index of element in tab.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to check in
	--@ Any element: The element to look for
	--: Any: The first index of element, nil if not present
		for i, v in pairs(tab) do
			if v == element then return i; end
		end
		return nil
	end
	
	--f contains
	--- Check if element is present in tab.
	--* Alias for `table.index_of`.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to check in
	--@ Any element: The element to look for
	--: bool: true if present, false otherwise
	_M.contains = _M.index_of --(tab, element)

	function _M.remove_v(tab, value)
	--- Remove a value from a table.
	--- Uses `table.index_of` to find the index to remove.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to remove from
	--@ Any value: The value to remove
	--: Any: The index of the element that got removed
		local index = _M.index_of(tab, value)
		table.remove(tab, index)
		return index
	end

	function _M.insert_at_free_index(tab, element)
	--- Insert the given element at the first free numeric index.
	--* Uses `table.get_free_index` to find the index.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to insert into
	--@ Any element: The element to insert
	--: int: The index the element was inserted at
		local index = _M.get_free_index(tab)
		tab[index] = element
		return index
	end
	
	function _M.insert_at_next_index(tab, element)
	--- Insert the given element at a numeric index at the end of the table.
	--* Uses `table.get_next_index` to find the index.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to insert into
	--@ Any element: The element to insert
	--: int: The index the element was inserted at
		local index = _M.get_next_index(tab)
		tab[index] = element
		return index
	end
	
	function _M.numeric_indices(tab, in_place)
	--- Find all numeric indices in the table.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to search in
	--@ bool in_place=false: If true, the resulting table is going to be set to the `_ids` field of the table.
	--: Array[int]: The numeric indices in ascending order
		local res = _M()
		local last
		for i, v in pairs(tab) do
			if type(i) == "number" and i%1 == 0 then res:insert(i); end
		end
		res:sort()
		if in_place then tab._ids = res; end
		return res
	end
	
	function _M.n_insert(tab, index, value)
	--- Insert element and update `_ids`.
	--* Can only be used on tables that already have the `_ids` field present (numerically indexed tables).
	--* Can be used as a method of RichTable.
	--@ table tab: The table to insert into
	--@ int index: The index to insert at
	--@ Any value: The value to insert, if nil, `_ids` is still updated as if the value wasn't nil
		if not tab[index] then
			_M.insert(tab._ids, index)
			_M.sort(tab._ids)
		end
		tab[index] = value
	end
	
	function _M.n_insert_at_free_index(tab, value)
	--- Insert the given value at the first free integer index and update `_ids`.
	--* Can only be used on tables that already have the `_ids` field present (numerically indexed tables).
	--* Can be used as a method of RichTable.
	--@ table tab: The table to insert into
	--@ Any value: The value to insert
	--: int: The index the value was inserted at
		local index = _M.get_free_index(tab)
		_M.n_insert(tab, index, value)
		return index
	end
	
	function _M.n_insert_at_next_index(tab, value)
	--- Insert the given element at a numeric index at the end of the table and update `_ids`.
	--* Can only be used on tables that already have the `_ids` field present (numerically indexed tables).
	--* Can be used as a method of RichTable.
	--@ table tab: The table to insert into
	--@ Any value: The value to insert
	--: int: The index the value was inserted at
		local index = _M.get_next_index(tab)
		_M.n_insert(tab, index, value)
		return index
	end
	
	function _M.n_remove(tab, index)
	--- Set the value at an index to nil and update `_ids`.
	--* Can only be used on tables that already have the `_ids` field present (numerically indexed tables).
	--* Can be used as a method of RichTable.
	--@ table tab: The table to remove from
	--@ int index: The index to remove from
	--: Any: The value that was removed
		local res = tab[index]
		tab[index] = nil
		if res then _M.remove_v(tab._ids, index); end
		return res
	end
	
	function _M.n_remove_v(tab, element)
	--- Remove the given element from the table and udpate `_ids`.
	--* Can only be used on tables that already have the `_ids` field present (numerically indexed tables).
	--* Can be used as a method of RichTable.
	--@ table tab: The table to remove from
	--@ Any element: The value to remove
	--: int: The index that was removed, nil if the value wasn't present
		local index = _M.remove_v(tab, element)
		if index then _M.remove_v(tab._ids, index); end
		return index
	end
	
	function _M.last(arr)
	--- Return the last value in this Array.
	--* Can be used as a method of RichTable.
	--@ Array arr: The Array to check
	--: Any: The last value in this Array
		return arr[#arr]
	end
	
	function _M.highest_index(tab)
	--- Get the highest index in the table.
	--- Unlike with `maxn`, zero and negative indices are also considered here.
	--* Use `maxn` whenever possible isntead of this - it is much faster.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to check
	--: int: The index, nil if no numeric indices are in the table
		return _M.numeric_indices(tab):last()
	end
	
	function _M.foreach(tab, func)
	--- Call a function for every element in the table using `pairs` for iteration.
	--* The function receives the value and it's index as parameters.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to iterate over
	--@ function func: The function to call
		for i, v in pairs(tab) do func(v, i); end
	end
	
	function _M.foreachi(tab, func)
	--- Call a function for every element in the table using `ipairs` for iteration.
	--* The function receives the value and it's index as parameters.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to iterate over
	--@ function func: The function to call
		for i, v in ipairs(tab) do func(v, i); end
	end
	
	function _M.foreachi_all(tab, func, indices)
	--- Call a function for every element in the table using `ipairs_all` for iteration.
	--* The function receives the value and it's index as parameters.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to iterate over
	--@ function func: The function to call
	--@ {Array[int], bool} indices=nil: The indices to use
		for i, v in _M.ipairs_all(tab, indices) do func(v, i); end
	end
	
	function _M.foreach_tab(tab, func)
	--- Call a function for every table-type element in the table.
	--* The function receives the value and it's index as parameters.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to iterate over
	--@ function func: The function to call
		for i, v in pairs(tab) do
			if type(v) == "table" then func(v, i); end
		end
	end
	
	function _M.filter(tab, func, set)
	--- Remove elements from table based on a condition.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to filter
	--@ function func: The filter function - if it returns false, the element will be removed. Gets value and index as parameters
	--@ Any set=nil: The value to set to filtered fields
		for i, v in pairs(tab) do
			if not func(v, i) then tab[i] = set; end
		end
	end
	
	function _M.select(tab, func)
	--- Select a subset of a table based on a condition.
	--* Can be used as a method of RichTable
	--@ table tab: The table to select from
	--@ function func: The filter function - if returns true, the element will be selected. Gets value and index as parameters
	--: RichTable: The selected subset
		local res = _M()
		for i, v in pairs(tab) do
			if func(v, i) then res[i] = v; end
		end
		return res
	end
	
	function _M.map(tab, func)
	--- Create a transformed copy of the table based on a mapping function.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to map
	--@ function func: The mapping function, gets value and index as parameters
	--: RichTable: The mapped table
		local res = _M()
		for i, v in pairs(tab) do res[i] = func(v, i); end
		return res
	end
	
	function _M.transform(tab, func)
	--- Transform all elements in a table using a function.
	--* Can be used as a method of RichTable.
	--@ table tab: THe table to transform
	--@ function func: The transform function
		for i, v in pairs(tab) do tab[i] = func(v, i); end
	end
	
	function _M.reverse(tab)
	--- Reverse the values and indices of a table.
	--- Create a table with values from another table as indices and indices as values.  
	--- Such table can then be used for finiding whether or not a table contains a vlaue or not. Depending on how many times
	--- you want to do this, it may be significantly faster than using `table.contains`.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to reverse
	--: RichTable: The reversed table
		local res = _M()
		for i, v in pairs(tab) do res[v] = i; end
		return res
	end
	
	function _M.indices(tab)
	--- Get an Array of the indices this table uses.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to find indices for
	--: Array[Any]: An array of indices in the table
		local res = _M()
		for i, _ in pairs(tab) do res:insert(i); end
		return res
	end
	
	function _M.ipairs_all(tab, indices)
	--- Get an iterator over all numeric indices.
	--- The indices are iterated over in ascending order. If indices is nil or true, the value of the `_ids` field will
	--- be used. If it's false table.numeric_indices is used to obtain the indices, otherwise, the value of indices is used.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to iterate over
	--@ {Array[int], bool} indices=nil: The indices to use
	--: function: The iterator function
		if indices == nil or indices == true then indices = tab._ids or _M.numeric_indices(tab)
		else indices = indices or _M.numeric_indices(tab); end
		local i = 1
		return function()
			local res_i = indices[i]
			local res_v = tab[res_i]
			i = i+1
			return res_i, res_v
		end
	end
	
	function _M.mk(parent, name)
	--- Make a table at a specified key in the given parent table.
	--- This is mostly a shorthand for initializing the global table, reducing `global.my_table = table(global.my_table)`
	--- to `table.mk(global, "my_table")`. If called on a RichTable, this becomes `rich_tab:mk("my_table")`, or even
	--- `rich_tab:mk"my_table"`.  
	--- There are other uses however and other parameter variations. The parent parameter may be omitted entirely, in which
	--- case `_G` is used. `_G` will also be used if `nil` was passed as parent.
	--* Can be used as a method of RichTable.
	--@ table parent: The table to make the new one in
	--@ Any name: The key that will be used for the new table
	--: RichTable: The newly created table
		if name == nil then
			name = parent
			parent = _G
		end
		if parent == nil then parent = _G; end
		parent[name] = _M(parent[name])
		return parent[name]
	end
	
	
	--f unpack
	--- Unpack the elements of a table to individual vars.
	--* Can be used as a method of RichTable.
	--* This is a reference to the built-in function, see Lua's documentation for details.
	--@ table tab: The table to unpack
	--: ...: The unpacked values
	_M.unpack = unpack
	
	--f insert
	--- Insert the given value into the table.
	--- If a position is given, the value is inserted before the element currently at that position, otherwise it is
	--- appended to the end of the table.  
	--- When an element is inserted, both size and element indices are updated. The end of the table is deduced from the
	--- current table size (`#` operator).
	--* Can be used as a method of RichTable.
	--* This is a reference to the built-in function, see Lua's documentation for details.
	--@ table table: The table to insert into
	--@ Any pos=#table+1: The index in the table to insert at
	--@ Any value: The value to insert
	_M.insert = table.insert
	
	--f remove
	--- Remove an element from a table.
	--- If position is specified, the element at that position is removed, otherwise remove the last element in the table.  
	--- When an element is removed the size and indices of remaining elements are updated.
	--* Can be used as a method of RichTable.
	--* This is a reference to the built-in function, see Lua's documentation for details.
	--@ table table: The table to remove from
	--@ Any pos: The position to remove from
	--: Any: The value of the element removed
	_M.remove = table.remove
	
	--f concat
	--- Concatenate the elements of a table together to form a string.
	--- Each element must be able to be coerced into a string. A separator can be specified which is placed between
	--- concatenated elements. Additionally a range can be specified within the table, starting at the i-th element and
	--- finishing at the j-th element.  
	--- Concatenation will fail on a table that contains tables because they cannot be coerced into strings.
	--* Can be used as a method of RichTable.
	--* This is a reference to the built-in function, see Lua's documentation for details.
	--@ table table: The table to concat
	--@ string sep="": The separator to use
	--@ int i=1: The starting position
	--@ int j=#table: The end position
	--: string: The concatenated table
	_M.concat = table.concat
	
	--f sort
	--- Sort the elements of a table in-place (i.e. alter the table).
	--- If the table has a specified size only the range specified is sorted.  
	--- A comparison function can be provided to customise the element sorting. The comparison function must return a bool
	--- value specifying whether the first argument should be before the second argument in the sequence. The default
	--- behavior is for the < comparison to be made.
	--* Can be used as a method of RichTable.
	--* This is a reference to the built-in function, see Lua's documentation for details.
	--@ table table: The table to sort
	--@ function comp=<: The comparator function
	_M.sort = table.sort
	
	--f maxn
	--- Return the largest positive numerical index of the given table.
	--- Zero is returned if no positive numerical indices are found on the table. (To do its job this function does a
	--- linear traversal of the whole table.)
	--* Can be used as a method of RichTable.
	--* This is a reference to the built-in function, see Lua's documentation for details.
	--@ table table: The table to search
	--: uint: The found index, or zero if none was found
	_M.maxn = table.maxn
	
	--f pack
	--- Return a new table with all parameters.
	--- Parameters are stored in keys 1, 2, etc. and with a field "n" with the total number of parameters.
	--* nil is considered a valid value in this instance.
	--* The resulting table may not be a sequence.
	--* This is a reference to the built-in function, see Lua's documentation for details.
	--@ Any ...: The values to pack into an array
	--: table: The resulting array
	_M.pack = table.pack

	function _M.setmetatable(tab, mt)
	--- Set mt as the metatable of tab.
	--- This is a proxy function for the built-in setmetatable. This one takes into account RichTables.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to set metatable for
	--@ table mt: The metatable
	--: table: The original table
		if tab.__rich then
			local omt = getmetatable(tab)
			setmetatable(omt.__index, mt)
			setmetatable(omt, mt)
			return tab
		else return setmetatable(tab, mt); end
	end

	function _M.getmetatable(tab)
	--- Get the metatable of tab.
	--- This is a proxy for the built-in getmetatable. This one takes into account RichTables.
	--* Can be used as a method of RichTable.
	--@ table tab: The table to get metatable of
	--: table: The metatable or nil if none is set
		if tab__rich then return getmetatable(getmetatable(tab))
		else return getmetatable(tab); end
	end
	
	function _M.enrich(tab)
	--- Set the metatable of tab to contain functions from the table module.
	--- The original metatable will be set as the metatable of the new metatable, so the original functionality should
	--- still be available.
	--* The function operates directly on the table passed in, so the returned table is the same one.
	--* This function needs to be called in `on_load` for each table because metatables are not serialized by Factorio.
	--@ table tab: The table to enrich
	--: RichTable: The enriched table
		--TODO: automatic metatable setup on load for tables that had enrich called on them
		-- Declare what methods rich tables are going to have
		-- All of them can be called with the colon syntax
		local RICH_MT = {
			__rich = true, -- Indicate that this is a RichTable, so we know how to set metatables
			
			deep_copy = _M.deep_copy,
			is_subset = _M.is_subset,
			equals = _M.equals,
			getn = _M.getn,
			get_next_index = _M.get_next_index,
			get_free_index = _M.get_free_index,
			is_empty = _M.is_empty,
			index_of = _M.index_of,
			contains = _M.contains,
			remove_v = _M.remove_v,
			numeric_indices = _M.numeric_indices,
			last = _M.last,
			highest_index = _M.highest_index,
			ipairs_all = _M.ipairs_all,
			n_insert = _M.n_insert,
			n_insert_at_next_index = _M.n_insert_at_next_index,
			n_insert_at_free_index = _M.n_insert_at_free_index,
			n_remove = _M.n_remove,
			any = _M.any,
			any_tab = _M.any_tab,
			insert_all = _M.insert_all,
			foreach = _M.foreach,
			foreachi = _M.foreachi,
			foreachi_all = _M.foreachi_all,
			foreach_tab = _M.foreach_tab,
			filter = _M.filter,
			select = _M.select,
			map = _M.map,
			transform = _M.transform,
			reverse = _M.reverse,
			indices = _M.indices,
			mk = _M.mk,
			insert_at_next_index = _M.insert_at_next_index,
			insert_at_free_index = _M.insert_at_free_index,
			
			-- Serpent functions can be used as methods
			--TODO: Docs for this.
			line = serpent.line,
			block = serpent.block,
			dump = serpent.dump,
			
			-- The built-in functions that happen to be usable as methods too
			insert = _M.insert,
			remove = _M.remove,
			concat = _M.concat,
			sort = _M.sort,
			unpack = _M.unpack,
			maxn = _M.naxn,
			
			-- The built-in iterators
			--TODO: Docs for this.
			pairs = pairs,
			ipairs = ipairs,
			next = next,
			
			getmetatable = _M.getmetatable,
			setmetatable = _M.setmetatable,
		}
		
		local mt = getmetatable(tab)
		if mt then return setmetatable(tab, setmetatable({__index = setmetatable(RICH_MT, mt)}, mt))
		else return setmetatable(tab, {__index = RICH_MT}); end
	end
	
	function _M.new()
	--- Return a new RichTable.
	--- Same as `table.enrich({})`.
	--* The __call metamethod can be used instead - `table()`.
	--: RichTable: The new table
		return _M.enrich({})
	end
	
	--f __call
	--% type: metamethod
	--- Create a new RichTable.
	--- A table can be passed as a parameter if you want to create a populated table.  
	--- The constructor with values might look like this: `local my_table = table{"foo", "bar"}`.  
	--- If you want to use RichTables that are serialized, you can call this constructor in the `load` event like so:
	--- `global.my_global_rich_table = table(global.my_global_rich_table)`. This not only ensures that the table is going
	--- to be enriched on load, but also creates the table if it doesn't exist, which would have to be done anyway.
	--@ table tab={}: The table to use as base
	--: RichTable: The new table
	setmetatable(_M, {__call = function(_, tab) return _M.enrich(tab or {}); end})
end
