io.stdout:write("Enter output path (empty for default): ")
local OUT_DIR = io.stdin:read()
if not OUT_DIR or OUT_DIR == "" then OUT_DIR = "doc-out"; end
local t = os.rename(OUT_DIR, OUT_DIR)
if not t then print("Can't write to directory "..OUT_DIR.."..."); return; end

local other_docs
if not pcall(function() other_docs = require "docs.init" end) then other_docs = {}; end


current_dir = io.popen"cd":read'*l'
package.path = ";"..current_dir.."\\?.lua;"..current_dir.."\\FML\\?.lua;"..package.path


local function empty() end


print "Loading FML in data stage..."
_G.data = {raw = {item = {}}, extend = empty}
local FML_data = require ".FML.data"
_G.data = nil

print "Loading FML in runtime stage..."
script = {on_init = empty, on_load = empty, on_configuration_changed = empty, on_event = empty}
remote = {add_interface = empty, remove_interface = empty, call = empty, interfaces = {}}
local FML_control = require ".FML.control"
script = nil
remote = nil


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
local function _make_doc_for(FML)
	for _, module in pairs(FML) do
		if type(module) == "table" and module._DOC then _make_doc(module._DOC); end
	end
end
_make_doc_for(FML_data)
_make_doc_for(FML_control)
_make_doc_for(other_docs.DOCS)


print "Trimming whitespace..."
local function trim(s)
	local from = s:match"^%s*()"
	return from > #s and "" or s:match(".*%S", from)
end

local function _strip_newlines(v)
	if type(v) == "table" then for key, val in pairs(v) do v[key] = _strip_newlines(val); end
	elseif type(v) == "string" then
		v = trim(v)
		local res = ""
		local white_chars = {["\n"] = true, [" "] = true, ["\t"] = true}
		local strip = true
		local last_chars = {"", ""}
		v:gsub(".", function(c)
			if c == "\n" then
				if not strip then
					if table.concat(last_chars) == "  " then res = res.."\n"
					else res = res.." "; end
				end
				strip = true
			elseif strip and white_chars[c] then strip = true
			else res = res..c; strip = false; end
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

local function parse_type(t)
	if not t then return "Any"; end
	if type(t) == "string" then return t; end
	return "{"..table.concat(t, ", ").."}"
end

local function parse_params(params, default)
	if not params then return default or ""; end
	local res = ""
	for _, param in ipairs(params) do
		if res ~= "" then res = res..", "; end
		if not param.name and param.type == "..." then res = res.."..."
		else
			res = res..i(parse_type(param.type))
			if param.name then res = res.." "..param.name; end
		end
	end
	return res
end

local function func_header(name, params)
	return b(link(name)).."("..parse_params(params)..")"
end

local function func_detail(name, func)
	local res = ""
	local function write(s) res = res..s; end
	
	write(h(3, name)..n())
	
	write(parse_params(func.returns, i("nil")).." "..func_header(name, func.params)..br())
	write(func.desc..n(2))
	
	if func.notes then
		write(b("Notes:")..br())
		for _, note in ipairs(func.notes) do write(i(note)..br()); end
	end
	
	if func.params then
		write(h(4, "Parameters")..n())
		for _, param in ipairs(func.params) do
			write("* "..i(parse_type(param.type)).." "..param.name)
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
			else write(i(parse_type(ret.type))); end
			if ret.desc then write(" - "..ret.desc); end
			write(n())
		end
	end
	return res
end


for name, module in pairs(complete_doc) do
	print("\t- "..name.."...")
	local res = ""
	local function write(s) res = res..s; end
	
	-- The title part
	write(i(module.type).." "..b(module.name)..n(2)..module.desc..n(2))
	
	-- Notes
	if module.notes then
		write(b("Notes:")..br())
		for _, note in ipairs(module.notes) do write(i(note)..br()); end
		write(n())
	end
	
	write(hr(2))
	
	if module.metamethods then
		-- Metamethod overview
		write(h(2, "Metamethod Overview")..n())
		
		-- Table header
		write(tab_row("return value", "Metamethod", "Description"))
		write(tab_line(3))
		
		-- Table rows
		for name, func in pairs(module.metamethods) do
			write(tab_row(parse_params(func.returns, i("nil")), func_header(name, func.params), func.short_desc or func.desc))
		end
		
		write(n()..hr(2))
	end
	
	if module.funcs then
		-- Function overview
		write(h(2, "Function Overview")..n())
		
		-- Table header
		write(tab_row("Return Value", "Function", "Description"))
		write(tab_line(3))
		
		-- Table rows
		for name, func in pairs(module.funcs) do
			write(tab_row(parse_params(func.returns, i("nil")), func_header(name, func.params), func.short_desc or func.desc))
		end
		
		write(n()..hr(2))
	end
	
	if module.metamethods then
		--Metamethod detail
		write(h(2, "Metamethod Detail")..n())
		
		-- The individual functions
		for name, func in pairs(module.metamethods) do
			write(func_detail(name, func)..n()..hr(2))
		end
	end
	
	if module.funcs then
		-- Function detail
		write(h(2, "Function Detail")..n())
		
		-- The individual functions
		for name, func in pairs(module.funcs) do
			write(func_detail(name, func)..n()..hr(2))
		end
	end
	
	
	local out_file = io.open(OUT_DIR.."\\"..name..".md", "w")
	out_file:write(res)
	out_file:flush()
end
print("Done.")
