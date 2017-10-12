--/ GUI
--TODO: soome meaningful description

--TODO: a way to keep frames the same width


module{
	name = 'GUI',
	
	submod('controls', '.controls'),
	
	DATA = {
		file '.styles' 'STYLES',
		file '.data',
	},
	RUNTIME_SHARED = {
		file '.shared',
	},
	RUNTIME = {
		submod 'controls',
		file '.styles' 'STYLES',
		file '.basic-entity',
		file '.entity-opening',
	}
}
