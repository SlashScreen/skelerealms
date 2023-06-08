class_name WorldLoader
extends Node
## World scene loader


var world_paths:Dictionary = {}
var regex:RegEx


## Called when the loading process begins.
## Hook into this to pop up a loading screen.
signal begin_world_loading
## Called when the world has finished loading, and gameplay can resume.
## Use this to either continue gameplay, or pop up a button on the loading screen to continue gameplay.
signal world_loading_ready


func _enter_tree() -> void:
	if get_child_count() > 0:
		GameInfo.world = get_child(0).name


func _ready():
	regex = RegEx.new()
	regex.compile("([^\\/\n\\r]+).tscn") 
	_cache_worlds(ProjectSettings.get_setting("skelerealms/worlds_path"))
	


## Load a new world.
func load_world(wid:String):
	begin_world_loading.emit()
	_unload_world()
	print(world_paths)
	
	if not world_paths.has(wid):
		print("World not found: %s" % wid)
		return
	
	var w = load(world_paths[wid]) as PackedScene
	if !w:
		print("Error loading world: %s" % wid)
	
	add_child(w.instantiate())
	
	world_loading_ready.emit()


func _unload_world():
	remove_child(get_child(0))


## Searches the worlds directory and caches filepaths, matching them to their name
func _cache_worlds(path:String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir(): # if is directory, cache subdirectory
				_cache_worlds(file_name)
			else: # if filename, cache filename
				var result = regex.search(file_name)
				if result:
					world_paths[result.get_string(1)] = "%s/%s" % [path, file_name]
			file_name = dir.get_next()
		dir.list_dir_end()
	
	else:
		print("An error occurred when trying to access the path.")
