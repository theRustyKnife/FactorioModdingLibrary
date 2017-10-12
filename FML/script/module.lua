--/ module
--- Utilities for loading modules in the conforming format.


-- This has to be just a simple function because we couldn't init this module without itself already ready
local function res(_M)
	local INIT_FILE = '.__init'


	local function assert(v, message, level)
	--% private
	--- Same as Lua's assert, but allows level to be passed as in error.
	--@ Any v: The value to check is true
	--@ string message="Assertion failed!": The message to pass to error
	--@ int level=1: The stack level to blame for the error (same as in Lua's error)
	--: Any: The value of v
	--: string: The value of message
	--: int: The value of level
		if not v then error(message or "Assertion failed!", (level or 1)+1); end
		return v, message, level
	end


	local function get_callable_table(tab, func)
	--% private
	--- Make the given table's __call metamethod call func.
	--@ table tab: The table to make callable
	--@ function func: The function to call
	--: table: The same table passed in
		return setmetatable(tab, {__call=function(_, ...) return func(...); end})
	end


	--TODO: implement load_all, init_all and import_all with dependency support
	--TODO: allow modfuncs to have stages specified


	function _M.load(args)
	--- Load a module from a file.
	--- Only returns the module in the uninitialized state. If only path is passed in, it can be done so as a positional
	--- argument.
	--* Any values in the global scope that would be overwriten by the module functions are restored after loading is done.
	--@ kw string path: The path to the file to load
	--@ kw function load_func=require: The function to use for loading files
	--@ kw string super=nil: Path to the module containing this one, used to determine dependency validity
	--@ kw table _G=_G: The global scope into which the module functions will be put
	--@ kw string super_path=nil: If not nil, an attempt at loading with this prefixed to path will be made
	--: ModuleDef: The loaded module defeintion
		local path
		if type(args) == 'string' then path = args; args = {}
		elseif type(args) == 'table' then path = args.path
		end
		local err_level = args.err_level or 2
		assert(path, "No path given to load.", err_level)
		local load_func = args.load_func or require
		local super = args.super
		local _G_l = args._G or _G
		local super_path = args.super_path
		
		local res_mod
		local components = {}
		local submods = {}
		
		local funcs = {
			module = function(mod, func)
				assert(not res_mod, "Module can only have one root.", 2)
				
				-- Allow only passing a function, although no one will probably do that
				if type(mod) == 'function' then func = mod; mod = nil; end
				-- If only string is passed as mod, use it as the name
				if type(mod) == 'string' then mod = {name=mod}; end
				mod = mod or {}
				mod.file_path = path
				
				-- If this is a direct function definition, only consider name and stages
				if func then
					mod.stages = {}
					for _, stage in ipairs(mod) do mod.stages[stage] = true; end
					if not next(mod.stages) then mod.stages = nil; end
				end
				
				res_mod = {type='module', mod=mod, func=func}
			end,
			const = function(value)
				assert(not res_mod, "Module can only have one root.", 2)
				res_mod = {type='const', value=value}
			end,
			file = function(path)
				components[path] = components[path] or {type='file', file=load_func(path)}
				local res = {type='file', path=path}
				return get_callable_table(res, function(name)
						res.name = name
						res.type = 'const'
						return setmetatable(res, nil)
					end)
			end,
			submod = function(name, path)
				if path then submods[name] = submods[name] or {type='submodule', path=path, name=name}; end
				return {type='submodule', name=name}
			end,
			_MODULE_NO_INIT = true,
		}
		
		-- Backup the orignal values from _G
		local _G_bak = {}
		for name, func in pairs(funcs) do _G_bak[name] = _G_l[name]; _G_l[name] = func; end
		
		-- These paths will be tried to load
		local paths = {path, path..INIT_FILE, super_path and super_path..path, super_path and super_path..path..INIT_FILE}
		
		local success, loaded
		local err
		for _, p in ipairs(paths) do
			local t_err
			success, t_err = pcall(function() loaded = load_func(p) end)
			if success then break; end
			if type(t_err) == 'string' and t_err:find('module '..p..' not found;', 1, true) then
				-- This is most likely just a file-not-found - try the other files before raising an error
				err = (err and err.."\n" or "")..t_err
			else error("Couldn't load module from \""..path.."\":\n"..tostring(t_err), err_level)
			end
		end
		
		if not res_mod and loaded then
			if type(loaded) ~= 'function' then _G_l.const(loaded); else _G_l.module(loaded); end
		end
		
		assert(success and res_mod,
			"Couldn't load module from \""..path.."\":\n"..tostring(err or "Module didn't load anything."), err_level)
		
		-- Restore the original values to _G
		for name, _ in pairs(funcs) do _G_l[name] = _G_bak[name]; end
		
		-- Consts don't require any other loading
		if res_mod.type == 'const' then return res_mod; end
		
		local info = res_mod.mod
		local res = {
			type = 'module',
			name = info.name,
			func = res_mod.func,
			stages = info.stages or {},
			components = components,
			submods = {},
			dependencies = info.dependencies,
			file_path = info.file_path,
		}
		if res.name then res.path = (super and super..'.' or '')..res.name; end
		
		-- Parse the stages into the result
		for stage, to_load in pairs(info) do
			-- Only strings as stage names and existing keys can't be used
			if type(stage) == 'string' and not res[stage] then res.stages[stage] = to_load; end
		end
		
		-- Load all the submodules
		for name, sub_info in pairs(submods) do
			res.submods[name] = _M.load{path=sub_info.path, load_func=load_func, super=res.path, _G=_G_l, super_path=path}
		end
		
		return res
	end

	function _M.init(args)
	--- Initializes the given module for the given stage.
	--- If the `_ALL` stage is defined, it will be always loaded, before any other stages. If no `stage` is passed, only
	--- `_ALL` will be run, nothing if it's not defined.
	--* The `_M` parameter doesn't apply for consts - those are simply returned in their current form.
	--* The `args` parameter is only given to functions that are part of the passed module directly, not submodules.
	--@ kw ModuleDef module: The module to init
	--@ kw string stage=nil: The stage to use for init
	--@ kw table _M={}: The table to init the module into
	--@ kw table args={}: Any arguments to be passed to the module function when initializing, as the third argument
	--: Module: The module
		assert(args and type(args) == 'table' and args.module, "No module to init given.", 2)
		local module = args.module
		local stage = args.stage
		local __M = args.__M or {}
		local err_level = args.err_level or 2
		local extra_args = args.args or {}
		assert(type(extra_args) == 'table', "args can only be a table.", err_level)
		
		-- consts should be safe to load whenever...
		if module.type == 'const' then return module.value; end
		
		-- The function directly in the module is always first
		if module.func then
			if not module.stages or not next(module.stages) or module.stages[stage or '_ALL'] then
				local res = module.func(__M, stage or '_ALL', extra_args)
				if not next(__M) and res ~= nil then __M = res; end
			end
			return __M
		end
		
		if module.stages and next(module.stages) then
			local mod_stage = stage or '_ALL' -- This is to init submodules with the correct stage and to pass stage to file
			local function _init_stage(stage)
				for _, comp in ipairs(module.stages[stage]) do
					if comp.type == 'file' then
						module.components[comp.path].file(__M, mod_stage, extra_args)
					elseif comp.type == 'const' then
						__M[comp.name] = module.components[comp.path].file
					elseif comp.type == 'submodule' then
						assert(module.submods[comp.name],
							"No submodule named \""..comp.name.."\" could be found.", err_level)
						__M[comp.name] = _M.init{module=module.submods[comp.name], stage=mod_stage, err_level=err_level+1}
					end
				end
			end
			
			if module.stages._ALL then _init_stage('_ALL'); end -- Always run _ALL
			if stage and module.stages[stage] then _init_stage(stage); end -- Only run the if stage is given and defined.
		end
		
		return __M
	end

	function _M.import(args)
	--- Imports a given module.
	--- This is basically just load and init merged into one function.
	--* `_M` follows the same rules as in init.
	--@ kw string path: The path to the module
	--@ kw function load_func=require: The function to use for loading files
	--@ kw string super=nil: Path to the supermodule
	--@ kw table _G=_G: The global scope to use
	--@ kw string stage=nil: The stage to use for init
	--@ kw table _M: The table to init into
	--@ kw table args={}: The extra arguments to pass to init
	--: Module: The loaded and initialized module
		args = args or {}
		return _M.init{
			module = _M.load{
				path = args.path,
				load_func = args.load_func,
				super = args.super,
				_G = args._G,
				err_level = 3,
			},
			stage = args.stage,
			_M = args._M,
			err_level = 3,
			args = args.args,
		}
	end
	
	
	-- Let's return so it's simple to load
	return _M
end


if _MODULE_NO_INIT then return res
else return res{}
end
