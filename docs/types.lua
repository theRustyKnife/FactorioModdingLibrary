return {
	bool = {_DOC = {
		type = "type",
		name = "bool",
		short_desc = "A truth value, `true` or `false`.",
		desc = [[
		A truth value, `true` or `false`. Usually, anything that can be tested for truthiness, can be used as a bool
		value. This means anything except `nil` and `false` is `true`.
		]],
	}},
	["nil"] = {_DOC = {
		type = "type",
		name = "nil",
		desc = "No value.",
	}},
	string = {_DOC = {
		type = "type",
		name = "string",
		desc = [[ A string of characters. ]],
		notes = {"See [Lua documentation](https://www.lua.org/manual/5.2/manual.html#6.4) for details."},
	}},
	["function"] = {_DOC = {
		type = "type",
		name = "function",
		desc = [[ A function. ]],
	}},
	int = {_DOC = {
		type = "type",
		name = "int",
		desc = [[ An integer value. ]],
	}},
	uint = {_DOC = {
		type = "type",
		name = "uint",
		desc = [[
		An unsigned integer value. In most cases, this is still a regular number internally, it just means that the
		function is expecting the appropriate value.
		]],
	}},
	float = {_DOC = {
		type = "type",
		name = "float",
		short_desc = "Fancy terminology for Lua's built-in number.",
		desc = [[
		Fancy terminology for Lua's built-in number. It can be any number accepted by the interpreter.
		]],
	}},
}
