--TODO: a way to keep frames the same width


mod{
	submod("controls", ".controls"),
	DATA = {
		file ".styles",
		file ".data",
	},
	RUNTIME_SHARED = {
		file ".shared",
	},
	RUNTIME = {
		submod "controls",
		file ".basic-entity",
		file ".entity-opening",
	}
}
