return {
	JUNCTION = {
		NAME = "Modules",
		HEADER_TEXT = "This is a list of all the modules and concepts in FML.",
		CATEGORIES = {
			{
				name = "module",
				title = "Modules",
			},
			{
				name = "class",
				title = "Classes",
			},
			{
				name = "type",
				title = "Types",
			},
			{
				name = "concept",
				title = "Concepts",
			},
		},
	},
	DOCS = {
		RichTable = {_DOC = {
			type = "concept",
			name = "RichTable",
			short_desc = "A table that has various methods for it's manipulation.",
			desc = [=[
			A table that has various methods for it's manipulation. It is basically a table with it's metatable set to
			the [[table|table]] module. This allows you to use all the functions from there as methods of `RichTable`s
			using the colon syntax.
			]=],
			notes = {"You can find the functions usable from `RichTable`s on the [[table|table]] module page."},
		}},
		Semver = {_DOC = {
			type = "class",
			name = "Semver",
			desc = [[ A class representing semanic versions. ]],
			notes = {"Taken from [GitHub](https://github.com/kikito/semver.lua)."},
			funcs = {
				nextMajor = {
					type = "method",
					desc = [[ Increment the major version number. ]],
					notes = {"The object is not modified by this method."},
					returns = {
						{
							type = "Semver",
							desc = "The new version",
						},
					},
				},
				nextMinor = {
					type = "method",
					desc = [[ Increment the minor version number. ]],
					notes = {"The object is not modified by this method."},
					returns = {
						{
							type = "Semver",
							desc = "The new version",
						}
					},
				},
				nextPatch = {
					type = "method",
					desc = [[ Increment the patch version number. ]],
					notes = {"The object is not modified by this method."},
					returns = {
						{
							type = "Semver",
							desc = "The new version",
						},
					},
				},
			},
			metamethods = {
				__eq = {
					desc = [[ Check if two versions are equal. ]],
					notes = {"Build is ignored in comparisons."},
					params = {
						{
							type = "Semver",
							name = "other",
							desc = "The `Semver` to compare to",
						},
					},
					returns = {
						{
							type = "bool",
							desc = "`true` if the versions are equal",
						},
					},
				},
				__lt = {
					desc = [[ Check if this `Semver` is lower than the other `Semver`. ]],
					notes = {"Build is ignored in comparisons."},
					params = {
						{
							type = "Semver",
							name = "other",
							desc = "The `Semver` to compare to",
						},
					},
					returns = {
						{
							type = "bool",
							desc = "`true` if this version is lower",
						},
					},
				},
				__pow = {
					short_desc = [[ Check if this `Semver` is backwards-compatible with another one. ]],
					desc = [[
					Check if this `Semver` is backwards-compatible with another one. In other words, it's safe to upgrade
					from this version to the other version.
					]],
					params = {
						{
							type = "Semver",
							name = "other",
							desc = "The version to check compatibility with",
						},
					},
					returns = {
						{
							type = "bool",
							desc = "`true` if other is compatible",
						},
					},
				},
				__tostring = {
					desc = [[ Get a string reprentation of this `Semver`. ]],
					returns = {
						{
							type = "string",
							desc = "The string reprentation of the version",
						},
					},
				},
				__call = {
					desc = [[ Create a new `Semver` object. ]],
					params = {
						{
							type = {"string", "int"},
							name = "major",
							desc = [[
							The major version number. If this is a string, it is interpreted as the whole version and
							any other parameters are ignored
							]],
						},
						{
							type = "int",
							name = "minor",
							desc = "The minor version number",
							default = "0",
						},
						{
							type = "int",
							name = "patch",
							desc = "The patch version number",
							default = ",",
						},
						{
							type = "string",
							name = "prerelease",
							desc = "The prerelease portion of the version",
							default = "nil",
						},
						{
							type = "string",
							name = "build",
							desc = "The build portion of the version",
							default = "nil",
						},
					},
					returns = {
						{
							type = "Semver",
							desc = "The new Semver object",
						},
					},
				},
			},
		}},
	},
}
