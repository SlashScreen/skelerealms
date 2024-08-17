class_name WorldLoader
extends Node
## World scene loader


var world_paths:Dictionary = {}
var regex:RegEx
var loading_path:String
var last_load_progress := 0 


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


func _process(_delta: float) -> void:
	if not GameInfo.is_loading:
		return 
	
	var prog = []
	match ResourceLoader.load_threaded_get_status(loading_path, prog):
		ResourceLoader.THREAD_LOAD_LOADED:
			print("Finishing up...")
			var ps := ResourceLoader.load_threaded_get(loading_path) as PackedScene
			if not ps:
				push_error("Failed to load world at %s" % loading_path)
				_abort()
			_finish_load.call_deferred(ps)
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Could not load world due to thread loading error.")
			_abort()
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if not last_load_progress == prog[0]:
				(func(): load_scene_progess_updated.emit(prog[0])).call_deferred()
				last_load_progress = prog[0]


## Load a new world.
func load_world(wid:String) -> void:
	print("loading world")
	
	if not world_paths.has(wid):
		push_error("World not found: %s" % wid)
		return
	
	GameInfo.console_unfreeze()
	begin_world_loading.emit()
	GameInfo.game_loading.emit(wid)
	await get_tree().process_frame
	print("Processed frame. Continuing...")
	GameInfo.is_loading = true
	#await get_tree().process_frame
	#print("processed frame. Unloading world...")
	var e:Error = ResourceLoader.load_threaded_request(world_paths[wid], "PackedScene", true)
	if not e == OK:
		push_error("Load thread error: %d" % e)
		_abort()
		return
	
	last_load_progress = 0
	loading_path = world_paths[wid]
	
	_unload_world()


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


func _abort() -> void:
	# TODO: Crash game? 
	world_loading_ready.emit()
	GameInfo.is_loading = false
	GameInfo.game_loaded.emit()


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
