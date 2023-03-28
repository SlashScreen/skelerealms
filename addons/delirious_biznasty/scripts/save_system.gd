extends Node
## The savegame system.

const DEBUG_MODE:bool = true

## Save the game and write it to user://saves directory.
func save():
	var save_data = {
		"game_info" : {}, # info about the game, like playtime, quests, etc
		"entity_data" : {}, # savegame info from entities
	}
	#collect savegame data from entities
	for sd in get_tree().get_nodes_in_group("savegame"):
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


## Turn the save game blob into a string.
## You can change this to use whatever system you want. By default, it uses JSON because that comes with Godot.
func _serialize(data) -> String:
	return JSON.stringify(data, "\t" if DEBUG_MODE else "", true, true)
