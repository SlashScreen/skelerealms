extends Node
## The savegame system.


## Save the game and write it to user://saves directory.
func save():
	var save_data = {
		"game_info" : {}, # info about the game, like playtime, quests, etc
		"entity_data" : {}, # savegame info from entities
	}
	
	#collect savegame data from entities
	for sd in get_tree().get_nodes_in_group("savegame_entity"):
		save_data["entity_data"][sd.name] = sd.save()
		
	var save_text:String = _serialize(save_data) # serialize
	
	DirAccess.make_dir_recursive_absolute("user://saves/")
	# TODO: allow for custom save file names
	# Create savegame file
	var file = FileAccess.open("user://saves/%s.dat" % Time.get_datetime_string_from_system().replace(":", ""), FileAccess.WRITE)
	file.store_string(save_text)
	# I think these two are redundant but I wanna be safe 
	file.flush()
	file.close()


func load_most_recent():
	var dir_files:Array[String] = []
	dir_files.append_array(DirAccess.get_files_at("user://saves/"))
	# sort by modified time
	dir_files.sort_custom(func(a:String, b:String): return FileAccess.get_modified_time("user://saves/%s" % a) < FileAccess.get_modified_time("user://saves/%s" % b))
	var most_recent_file:String = dir_files.pop_back()
	print("user://saves/%s" % most_recent_file)
	load_game("user://saves/%s" % most_recent_file)


func load_game(path:String):
	var file = FileAccess.open(path, FileAccess.READ) # open file
	var data_blob:String = file.get_as_text() # read file
	var save_data:Dictionary = _deserialize(data_blob) # parse data
	# load entity data - loop through all data, get entity, call load
	for data in save_data["entity_data"]:
		BizGlobal.entity_manager.get_entity(data).unwrap().load(save_data["entity_data"][data])


## Turn the save game blob into a string.
## You can change this to use whatever system you want. By default, it uses JSON because that comes with Godot.
func _serialize(data) -> String:
	return JSON.stringify(data, "\t" if ProjectSettings.get_setting("biznasty/savegame_indents") else "", true, true)


func _deserialize(text:String) -> Variant:
	return JSON.parse_string(text)
