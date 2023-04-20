extends Node
## Tracks all [Coven]s in the game.


var covens:Dictionary
var regex:RegEx


func _ready():
	regex = RegEx.new()
	regex.compile("([^\\/\n\\r]+).tres")
	_cache_covens(ProjectSettings.get_setting("skelerealms/covens_path"))


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
			if dir.current_is_dir(): # if is directory, cache subdirectory
				_cache_covens(file_name)
			else: # if filename, cache filename
				var result = regex.search(file_name)
				if result:
					covens[result.get_string(1) as StringName] = "%s/%s" % [path, file_name]
			file_name = dir.get_next()
		dir.list_dir_end()
	
	else:
		print("An error occurred when trying to access the path.")
