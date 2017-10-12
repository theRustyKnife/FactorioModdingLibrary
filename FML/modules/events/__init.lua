--/ events
--- Provides an extended interface for handling events.
--+ r Dictionary[string: Array[EventID]] GROUPS: Groups of events that often go together


module{
	name = 'events',
	
	submod('id', '.id'),
	
	RUNTIME = {
		submod 'id',
		file '.script',
		file '.game',
		file '.shortcuts',
	},
	RUNTIME_SHARED = {
		submod 'id',
		file '.script',
		file '.game',
		file '.shortcuts',
		file '.custom_shared',
	},
}
