extends Node

func save():
	var save_data = get_tree()\
			.get_nodes_in_group("savegame")\
			.map(func(n): n.save())
	# TODO: Serialize
