extends Node
## Tracks all [Coven]s in the game.


var covens:Dictionary
var regex:RegEx


func _ready():
	GameInfo.game_started.connect(func():
		regex = RegEx.new()
		regex.compile("([^\\/\n\\r]+).t?res")
		_cache_covens(ProjectSettings.get_setting("skelerealms/covens_path"))
		)


## Gets a [Coven] if it exists.
func get_coven(coven:StringName) -> Coven:
	return covens[coven] if covens.has(coven) else null


## Caches all covens in the project.
func _cache_covens(path:String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if '.remap' in file_name:
				file_name = file_name.trim_suffix('.remap')
			if dir.current_is_dir(): # if is directory, cache subdirectory
				_cache_covens("%s/%s" % [path, file_name])
			else: # if filename, cache
				var result = regex.search(file_name)
				if result:
					covens[result.get_string(1) as StringName] = load("%s/%s" % [path, file_name])
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")


## Add coven to system.
func add_coven(c:Coven) -> void:
	covens[c.coven_id] = c


## Remove coven from system.
func remove_coven(id:StringName) -> void:
	covens.erase(id)


## Change the opinion a coven (of) has of another coven (what) by amount.
func change_opinion(of:StringName, what:StringName, amount:int) -> void:
	var c = get_coven(of)
	if not c:
		return
	if c.other_coven_opinions.has(what):
		c.other_coven_opinions[what] = c.other_coven_opinions[what] + amount
	else:
		c.other_coven_opinions[what] = amount
