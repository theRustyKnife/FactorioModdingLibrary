module{
	name = 'FML',
	
	_ALL = {
		file 'config' 'config',
		file '.event-id' 'FML_EVENT_ID',
		file '.FML-stdlib',
		
		-- Let's define all the modules in _ALL and let them handle stages
		submod('log', 'modules.log'),
		submod('cast', 'modules.cast'),
		submod('table', 'modules.table'),
		submod('random_util', 'modules.random-util'),
		submod('Semver', 'modules.Semver'),
		submod('events', 'modules.events'),
		submod('remote', 'modules.remote'),
		submod('Object', 'modules.Object'),
		submod('format', 'modules.format'),
		submod('data', 'modules.data'),
		submod('GUI', 'modules.GUI'),
		submod('prototype_util', 'modules.prototype-util'),
		submod('blueprint_data', 'modules.blueprint-data'),
		submod('surface', 'modules.surface'),
		submod('handlers', 'modules.handlers'),
	},
}
