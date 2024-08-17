class_name WorldLoader
extends Node
## World scene loader


var world_paths:Dictionary = {}
var regex:RegEx
var load_check_thread:Thread = Thread.new()


## Called when the loading process begins.
## Hook into this to pop up a loading screen.
signal begin_world_loading
## Called when the world has finished loading, and gameplay can resume.
## Use this to either continue gameplay, or pop up a button on the loading screen to continue gameplay.
signal world_loading_ready
## Called while the scene is loading with its progress. Progress from 0 to 1.
signal load_scene_progess_updated(percent:int)


func _enter_tree() -> void:
	if get_child_count() > 0:
		GameInfo.world = get_child(0).name


func _ready():
	regex = RegEx.new()
	regex.compile("([^\\/\n\\r]+)\\.t?scn") 
	_cache_worlds(ProjectSettings.get_setting("skelerealms/worlds_path"))
	GameInfo.is_loading = false


## Load a new world.
func load_world(wid:String) -> void:
	print("loading world")
	
	if not world_paths.has(wid):
		push_error("World not found: %s" % wid)
		return
	
	GameInfo.console_unfreeze()
	begin_world_loading.emit()
	GameInfo.game_loading.emit(wid)
	GameInfo.is_loading = true
	await get_tree().process_frame
	print("processed frame. Unloading world...")
	_unload_world()
	# Spawn waiting thread
	print("spawned waiting thread")
	ResourceLoader.load_threaded_request(world_paths[wid], "PackedScene", true)
	if load_check_thread.is_started(): 
		load_check_thread.wait_to_finish()
	load_check_thread = Thread.new()
	print("Atarting thread")
	load_check_thread.start(_load_check_thread.bind(world_paths[wid]))


# Side thread
func _load_check_thread(path:String) -> void:
	# wait until done
	var prog = []
	var last_progress = 0
	print("waiting for load to finish.")
	while not ResourceLoader.load_threaded_get_status(path, prog) == ResourceLoader.THREAD_LOAD_LOADED:
		if not last_progress == prog[0]:
			(func(): load_scene_progess_updated.emit(prog[0])).call_deferred()
		last_progress = prog[0]
	print("Finishing up...")
	_finish_load.call_deferred(ResourceLoader.load_threaded_get(path) as PackedScene)


# Main thread
func _finish_load(w:PackedScene) -> void:
	print("finished loading world")
	add_child(w.instantiate())
	print("finished loading world. Instantiating...")
	world_loading_ready.emit()
	GameInfo.is_loading = false
	print("World instantiated.")
	GameInfo.game_loaded.emit()


func _unload_world():
	remove_child(get_child(0))


## Searches the worlds directory and caches filepaths, matching them to their name
func _cache_worlds(path:String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if '.tscn.remap' in file_name:
				file_name = file_name.trim_suffix('.remap')
			if dir.current_is_dir(): # if is directory, cache subdirectory
				_cache_worlds("%s/%s" % [path, file_name])
			else: # if filename, cache filename
				var result = regex.search(file_name)
				if result:
					world_paths[result.get_string(1)] = "%s/%s" % [path, file_name]
			file_name = dir.get_next()
		dir.list_dir_end()
	
	else:
		print("An error occurred when trying to access the path.")
