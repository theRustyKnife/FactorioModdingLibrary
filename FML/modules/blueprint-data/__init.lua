--/ blueprint-data
--- Allows saving data for entities in blueprints.

--TODO: decouple data types from entities - make a proxy for each registered entity and give it the highest slot count
-- any data can have. Then just choose the appropriate entity based on the name.
-- This would require a way to distinguish the data types by something else than entity names. Since the number of
-- different setting types may change with mod config, it can't be just a number indexing the particular setting.
-- Maybe doing some kind of hash on the setting's name would work (if it results in a number, obviously).


module{
	name = 'blueprint_data',
	
	DATA = {file ".data", file ".util"},
	RUNTIME_SHARED = {file ".shared", file ".util"},
	RUNTIME = {file ".local", file ".util"},
}
