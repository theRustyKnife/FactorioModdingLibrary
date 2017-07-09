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
}
