io.stdout:write("Enter output path (empty for default): ")
local OUT_DIR = io.stdin:read()
if not OUT_DIR or OUT_DIR == "" then OUT_DIR = "doc-out"; end
local t = os.rename(OUT_DIR, OUT_DIR)
if not t then print("Can't write to directory "..OUT_DIR.."..."); return; end


current_dir = io.popen"cd":read'*l'
package.path = ";"..current_dir.."\\?.lua;"..current_dir.."\\FML\\?.lua;"..current_dir.."\\docs\\?.lua;"..package.path

local other_docs
other_docs = require "docs.init" or {}


print "Loading FML..."
local module_loader = {}; require(".FML.script.module-loader")(module_loader)
local FML_stdlib = module_loader.init(require(".FML.script.FML-stdlib"))
local FML_config = require ".FML.config"

local modules = {}
module_loader.load_from_files(FML_config.MODULES_TO_LOAD, modules, FML_stdlib.safe_require)

local FML_data = module_loader.load_std(FML_stdlib, nil, "data", FML_config, FML_config.VERSION)
local FML_control = module_loader.load_std(FML_stdlib, nil, "runtime", FML_config, FML_config.VERSION)
therustyknife = {}

local function empty() end

serpent = {}
data = {raw = {item = {}}, extend = empty}
script = {on_init = empty, on_load = empty, on_event = empty, on_configuration_changed = empty}
for _, module in ipairs(FML_config.MODULES_TO_LOAD) do
	if modules[module.name] then
		therustyknife.FML = FML_data
		FML_data[module.name] = module_loader.init(modules[module.name])
		therustyknife.FML = FML_control
		FML_control[module.name] = module_loader.init(modules[module.name])
	end
end
data = nil
script = nil

therustyknife = nil


print "Mereging docs..."
local complete_doc = {}
local function _make_doc(doc)
	if not complete_doc[doc.name] then
		complete_doc[doc.name] = doc
		return
	end
	for func_name, func_doc in pairs(doc.funcs) do
		if not complete_doc[doc.name].funcs[func_name] then
			complete_doc[doc.name].funcs[func_name] = func_doc
		end
	end
end
local function _make_doc_for(FML, rec)
	for _, module in pairs(FML) do
		if type(module) == "table" then
			if module._DOC then _make_doc(module._DOC)
			elseif rec then _make_doc_for(module, rec); end
		end
	end
end
_make_doc_for(FML_data)
_make_doc_for(FML_control)
_make_doc_for(other_docs.DOCS, true)


print "Trimming whitespace..."
local function trim(s)
	local from = s:match"^%s*()"
	return from > #s and "" or s:match(".*%S", from)
end

--TODO: link pages mentioned in text

local function _strip_newlines(v)
	if type(v) == "table" then for key, val in pairs(v) do v[key] = _strip_newlines(val); end
	elseif type(v) == "string" then
		v = trim(v)
		local res = ""
		local white_chars = {["\n"] = true, [" "] = true, ["\t"] = true}
		local strip = true
		local first = true
		local last_chars = {"", ""}
		local reg_char = false
		v:gsub(".", function(c)
			if c == "\n" then
				if table.concat(last_chars) == "  " or not reg_char then res = res.."\n"; end
				strip = true
				reg_char = false
			elseif strip and white_chars[c] then strip = true
			elseif strip and c == "`" then
				if last_chars[1] == "`" then res = res.."\n\t"; strip = false; first = false; reg_char = true; end
			elseif strip then
				if last_chars[1] == "`" then res = res.." `"..c
				else res = res..(first and "" or " ")..c; end
				strip = false; first = false; reg_char = true
			else res = res..c; strip = false; first = false; reg_char = true; end
			table.remove(last_chars); table.insert(last_chars, 1, c)
		end)
		return res
	end
	return v
end
_strip_newlines(complete_doc)


print "Generating markdown..."
local function n(n)
	n = n or 1
	local res = ""
	for i=1, n do res = res.."\n"; end
	return res
end
local function b(s) return "**"..s.."**"; end
local function i(s) return "*"..s.."*"; end
local function hr(nn) return "***"..n(nn); end
local function link(text, dest, dest_prefix)
	dest = dest or text
	dest_prefix = dest_prefix or "#"
	return "["..text.."]("..dest_prefix..dest:lower()..")"
end
local function wiki_link(text, page)
	page = page or text
	return "[["..text.."|"..page.."]]"
end
local function h(l, s)
	local res = ""
	for i=1, l do res = res.."#"; end
	return res.." "..s.." "..res
end
local function br(nn) return "  "..n(nn); end

local function code(s) return "`"..s.."`"; end

local function tab_row(...)
	local cols = {...}
	local res = "|"
	for _, col in ipairs(cols) do
		res = res.." "..col.." |"
	end
	return res..n()
end
local function tab_line(nn)
	nn = nn or 1
	local res = "|"
	for i=1, nn do res = res.." --- |"; end
	return res..n()
end

local function type_style(type)
	if type:sub(1, 1) == "[" then
		type = type:sub(2, type:len()-1)
		local nested = type:find("%[")
		local dict_s, dict_e = type:find(": ")
		
		if dict_s and dict_s < (nested or math.huge) then
			return "["..type_style(type:sub(1, dict_s-1))..": "..type_style(type:sub(dict_e+1, type:len())).."]"
		else return "["..type_style(type).."]"; end
	end
	
	local nested = type:find("%[")
	if nested then return type_style(type:sub(1, nested-1))..type_style(type:sub(nested, type:len())); end
	return i(wiki_link(type))
end

local function parse_type(t)
	if not t then return type_style("Any"); end
	if type(t) == "string" then return type_style(t); end
	local res = ""
	for _, tt in ipairs(t) do res = res..(res~="" and "," or "")..type_style(tt); end
	return "{"..res.."}"
end

local function parse_params(params, default)
	if not params then return default and parse_type(default) or ""; end
	local res = ""
	for _, param in ipairs(params) do
		if res ~= "" then res = res..", "; end
		if not param.name and param.type == "..." then res = res.."..."
		else
			res = res..parse_type(param.type)
			if param.name then res = res.." "..param.name; end
		end
	end
	return res
end

local function func_header(func)
	return b(link(func.name)).."("..parse_params(func.params)..")"
end

local function func_detail(func)
	local res = ""
	local function write(s) res = res..s; end
	
	write(h(3, func.name)..n())
	
	write(parse_params(func.returns, "nil").." "..func_header(func)..br())
	write(func.desc..n(2))
	
	if func.notes then
		write(b("Notes:")..br())
		for _, note in ipairs(func.notes) do write(i(note)..br()); end
	end
	
	if func.params then
		write(h(4, "Parameters")..n())
		for _, param in ipairs(func.params) do
			write("* "..parse_type(param.type).." "..param.name)
			if param.default then write(" (default: "..code(param.default)..")"); end
			if param.desc then write(" - "..param.desc); end
			write(n())
		end
	end
	
	if func.returns then
		write(h(4, "Returns")..n())
		for _, ret in ipairs(func.returns) do
			write("* ")
			if ret.type == "..." then write("...")
			else write(parse_type(ret.type)); end
			if ret.desc then write(" - "..ret.desc); end
			write(n())
		end
	end
	return res
end


local function _func_order(func_a, func_b) return func_a.name < func_b.name; end
local function _sort_funcs(funcs)
	local res = {}
	for name, func in pairs(funcs) do
		func.name = name
		table.insert(res, func)
	end
	table.sort(res, _func_order)
	return res
end
local function sort_funcs(module)
	if module.metamethods then module.metamethods = _sort_funcs(module.metamethods); end
	if module.funcs then module.funcs = _sort_funcs(module.funcs); end
end

local to_list = {}

for name, module in pairs(complete_doc) do
	print("\t- "..name.."...")
	
	sort_funcs(module)
	
	-- Save some info for listing in the junction page
	to_list[module.type] = to_list[module.type] or {}
	to_list[module.type][module.name] = module
	
	local res = ""
	local function write(s) res = res..s; end
	
	-- FML title
	write(h(5, i("FML "..FML_config.VERSION.NAME))..n())
	
	-- Title
	write(h(1, module.name)..n(2))
	-- The subtitle part
	if module.type then write(i(module.type).." "); end
	write(b(module.name)..n(2)..module.desc..n(2))
	
	-- Notes
	if module.notes then
		write(b("Notes:")..br())
		for _, note in ipairs(module.notes) do write(i(note)..br()); end
		write(n())
	end
	
	write(hr(2))
	
	if module.metamethods and next(module.metamethods) then
		-- Metamethod overview
		write(h(2, "Metamethod Overview")..n())
		
		-- Table header
		write(tab_row("return value", "Metamethod", "Description"))
		write(tab_line(3))
		
		-- Table rows
		for _, func in ipairs(module.metamethods) do
			write(tab_row(parse_params(func.returns, "nil"), func_header(func), func.short_desc or func.desc))
		end
		
		write(n()..hr(2))
	end
	
	if module.funcs and next(module.funcs) then
		-- Function overview
		write(h(2, "Function Overview")..n())
		
		-- Table header
		write(tab_row("Return Value", "Function", "Description"))
		write(tab_line(3))
		
		-- Table rows
		for _, func in ipairs(module.funcs) do
			write(tab_row(parse_params(func.returns, "nil"), func_header(func), func.short_desc or func.desc))
		end
		
		write(n()..hr(2))
	end
	
	if module.metamethods and next(module.metamethods) then
		--Metamethod detail
		write(h(2, "Metamethod Detail")..n())
		
		-- The individual functions
		for _, func in ipairs(module.metamethods) do
			write(func_detail(func)..n()..hr(2))
		end
	end
	
	if module.funcs and next(module.funcs) then
		-- Function detail
		write(h(2, "Function Detail")..n())
		
		-- The individual functions
		for name, func in pairs(module.funcs) do
			write(func_detail(func)..n()..hr(2))
		end
	end
	
	
	local out_file = io.open(OUT_DIR.."\\"..name..".md", "w")
	out_file:write(res)
	out_file:flush()
end


if other_docs.JUNCTION then
	print "Generating junction page..."
	local res = ""
	local function write(s) res = res..s; end
	
	-- FML title
	write(h(5, i("FML "..FML_config.VERSION.NAME))..n())
	
	-- Header
	write(other_docs.JUNCTION.HEADER_TEXT..n(2))

	-- The individual categories
	for _, category in ipairs(other_docs.JUNCTION.CATEGORIES or {}) do
		if to_list[category.name] then
			-- Sort alphabetically
			local names = {}
			for _, module in pairs(to_list[category.name]) do table.insert(names, module.name); end
			table.sort(names)
			
			-- The category title
			write(h(2, category.title)..n(2))
			
			-- Table header
			write(tab_row("Name", "Description")..tab_line(2))
			-- The modules
			for _, name in ipairs(names) do
				local module = to_list[category.name][name]
				write(tab_row(wiki_link(module.name), module.short_desc or module.desc))
			end
			write(n())
		end
	end
	
	local out_file = io.open(OUT_DIR.."\\"..other_docs.JUNCTION.NAME..".md", "w")
	out_file:write(res)
	out_file:flush()
end


print("Done.")
