extends Node
## The savegame system.
## This should be autoloaded.

enum {
	USE_TEMP,
	USE_ZIP,
}

const DEBUG_JSON := false
const SAVE_MODE := USE_TEMP
const ENTITY_EXT := ".entity"
const WORLD_EXT := ".world"
const GAME_INFO_EXT := ".game"
const SAVE_FILE_EXT := ".save"
const GAME_INFO_GROUP := &"savegame gameinfo"
const OTHER_GROUP := &"savegame other"

## Called when the savegame is complete.
## Use this to, for example, freeze the game until complete, or tell the netity manager to clean up stale entities.
signal save_complete
## Called when the loading process is complete. See [signal save_complete].
signal load_complete

var active_save_file: ZIPReader:
	set(val):
		if active_save_file:
			active_save_file.close()
		active_save_file = val
var active_packer: ZIPPacker:
	set(val):
		if active_packer:
			active_packer.close()
		active_packer = val


func cleanup() -> void:
	match SAVE_MODE:
		USE_TEMP:
			_cleanup_temp()
		USE_ZIP:
			active_save_file = null  # close save file
			active_packer = null


## Gets the filepath for the most recent savegame. It is sorted by file modification time.
func _get_most_recent_savegame(character: int) -> String:
	var save_dir: String = "user://saves/%d/" % character
	if not DirAccess.dir_exists_absolute(save_dir):
		return ""

	var dir_files: Array[String] = []
	dir_files.append_array(DirAccess.get_files_at(save_dir))
	# if no saves, we got none
	if dir_files.is_empty():
		return ""
	# sort by modified time
	dir_files.sort_custom(func(a: String, b: String) -> bool: return FileAccess.get_modified_time(save_dir + a) < FileAccess.get_modified_time(save_dir + b))
	var most_recent_file: String = dir_files.pop_back()
	# format
	return save_dir + most_recent_file


## Turn the save game blob into a string.
func _serialize(data: Dictionary) -> PackedByteArray:
	if DEBUG_JSON:
		return JSON.stringify(data, "\t" if ProjectSettings.get_setting("skelerealms/savegame_indents") else "", true, true).to_utf8_buffer()
	else:
		return var_to_bytes_with_objects(data)


## Turn a string into a data blob.
## Like with [method _serialize], you can write your own.
func _deserialize(text: PackedByteArray) -> Dictionary:
	if text.size() == 0:
		return {}
	if DEBUG_JSON:
		return JSON.parse_string(text.get_string_from_utf8())
	else:
		var data := bytes_to_var_with_objects(text)
		if data == null:
			return {}
		else:
			return data


#region saving


## Save the game and write it to user://saves directory.
func save(character: int):
	var file_path: String = _get_most_recent_savegame(character)
	match SAVE_MODE:
		USE_ZIP:
			if file_path.is_empty():
				file_path = _generate_save_file_name()  # Create a new file if there wasn't one already
			active_packer = ZIPPacker.new()
			active_packer.open(file_path)
		USE_TEMP:
			_cleanup_temp()
			if not file_path.is_empty():
				_unzip_into_temp(file_path) # FIXME: Is this absolute?
	
	#1: Entities
	var entities: Array[SKEntity] = SKEntityManager.instance.entities.values()
	_save_entites(entities)
	#2: Game info
	var info_nodes: Array[Node] = get_tree().get_nodes_in_group(GAME_INFO_GROUP)
	save_all_game_info(info_nodes)
	#3: World
	#4: Erased entities
	_save_erased_entities()
	#5: Other
	var other_nodes: Array[Node] = get_tree().get_nodes_in_group(OTHER_GROUP)
	save_all_other(other_nodes)

	if SAVE_MODE == USE_ZIP:
		active_packer.close()
		active_save_file = ZIPReader.new()
		active_save_file.open(file_path)

	save_complete.emit()


## Check if an entity is accounted for in the save system. Returns the save data blob if there is, else none.
## Use sparingly; could get memory intensive.
func entity_in_save(ref_id: StringName) -> Dictionary:
	var file_name: String = "%s%s" % [ref_id, ENTITY_EXT]
	if _file_exists_in_save(file_name):
		return {}

	var bytes: PackedByteArray = _read_buffer_from_file(file_name)

	return _deserialize(bytes)


func _create_entity_file(rid: StringName, data: Dictionary) -> void:
	var bytes: PackedByteArray = _serialize(data)
	var file_name: String = "%s%s" % [rid, ENTITY_EXT]

	_save_buffer_to_file(bytes, file_name)


func _save_entites(entities: Array[SKEntity]) -> void:
	for e: SKEntity in entities:
		_create_entity_file(e.name, e.save())


func _save_game_info(id: StringName, data: Dictionary) -> void:
	var bytes: PackedByteArray = _serialize(data)
	var file_name: String = "%s%s" % [id, GAME_INFO_EXT]

	_save_buffer_to_file(bytes, file_name)


func save_all_game_info(objects: Array[Node]) -> void:
	for n: Node in objects:
		_save_game_info(n.name, n.save())


func _save_other(id: StringName, data: Dictionary) -> void:
	var bytes: PackedByteArray = _serialize(data)
	var file_name: String = "%s%s" % [id, OTHER_GROUP]

	_save_buffer_to_file(bytes, file_name)


func save_all_other(objects: Array[Node]) -> void:
	for n: Node in objects:
		_save_other(n.name, n.save())


func open_zip_for_saving(path: String) -> ZIPPacker:
	var zip := ZIPPacker.new()
	zip.open(path, ZIPPacker.APPEND_ADDINZIP)
	return zip


func open_zip_for_loading(path: String) -> ZIPReader:
	var zip := ZIPReader.new()
	zip.open(path)
	return zip


func save_world(world: StringName, rids: Array) -> void:
	var casted_rids := Array(rids, TYPE_STRING_NAME, &"", null)
	var bytes: PackedByteArray = var_to_bytes(casted_rids)
	var file_name: String = "%s%s" % [world, WORLD_EXT]

	_save_buffer_to_file(bytes, file_name)


## Saves erased entities as a list of IDs spearates by LIST_SEPARATOR into "erased.info".
func _save_erased_entities() -> void:
	var buffer: PackedByteArray = var_to_bytes(SKEntityManager.instance.erased_entities)
	_save_buffer_to_file(buffer, "erased.info")


#endregion

#region loading


## Load a game from a filepath.
func load_game(path: String):
	pass


## Load the most recent savegame, if applicable.
func load_most_recent(character: int):
	var most_recent: String = _get_most_recent_savegame(character)
	# only load most recent if there are some
	if not most_recent.is_empty():
		load_game(most_recent)


func load_world_entities(world: StringName) -> Array[StringName]:
	var buffer := _read_buffer_from_file("%s%s" % [world, WORLD_EXT])
	return bytes_to_var(buffer)


#endregion

#region utils


func _save_buffer_to_file(buffer: PackedByteArray, filename: String) -> void:
	match SAVE_MODE:
		USE_TEMP:
			var file := FileAccess.open(_get_temp_path(filename), FileAccess.WRITE)
			file.store_buffer(buffer)
			file.close()
		USE_ZIP:
			active_packer.open(filename, ZIPPacker.APPEND_ADDINZIP)
			active_packer.write_file(buffer)
			active_packer.close_file()


func _file_exists_in_save(filename: String) -> bool:
	match SAVE_MODE:
		USE_TEMP:
			return FileAccess.file_exists(_get_temp_path(filename))
		USE_ZIP:
			return active_save_file.file_exists(filename)
		_:
			return false


func _read_buffer_from_file(filename: String) -> PackedByteArray:
	if not _file_exists_in_save(filename):
		return PackedByteArray()
	match SAVE_MODE:
		USE_TEMP:
			return FileAccess.get_file_as_bytes(_get_temp_path(filename))
		USE_ZIP:
			return active_save_file.read_file(filename)
		_:
			return PackedByteArray()


func _get_temp_root() -> String:
	return OS.get_temp_dir().path_join("skelesave").path_join(str(SkeleRealmsGlobal.current_character))


func _get_temp_path(filename: String) -> String:
	return _get_temp_root().path_join(filename)


func _generate_save_file_name() -> String:
	return "%s%s" % [Time.get_datetime_string_from_system(), SAVE_FILE_EXT]


func _unzip_into_temp(filepath: String) -> void:
	_cleanup_temp()
	_extract_all_from_zip(filepath, _get_temp_root())


func _extract_all_from_zip(filepath: String, to: String) -> void:
	var reader = ZIPReader.new()
	reader.open(filepath)

	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	var root_dir := DirAccess.open(to)

	var files := reader.get_files()
	for file_path: String in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file := FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer := reader.read_file(file_path)
		file.store_buffer(buffer)


func _cleanup_temp() -> void:
	var dir := DirAccess.open(_get_temp_root())
	_erase_directory(dir)


func _erase_directory(dir: DirAccess) -> void:
	for file: StringName in dir.get_files():
		if file.ends_with("/"):
			dir.change_dir(file)
			_erase_directory(dir)
			dir.change_dir("../")
		
		dir.remove(file)

#endregion
