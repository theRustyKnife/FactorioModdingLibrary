--/ blueprint-data
--- Allows saving data for entities in blueprints.


module{
	name = 'blueprint_data',
	
	DATA = {file ".data", file ".util"},
	RUNTIME_SHARED = {file ".shared", file ".util"},
	RUNTIME = {file ".local", file ".util"},
}
