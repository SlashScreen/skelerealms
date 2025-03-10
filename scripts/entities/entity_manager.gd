class_name SKEntityManager
extends Node
## Central manager for all entities in the SkeleRealms system.
## Handles entity lifecycle (creation, loading, cleanup), persistence, and lookup.
## Uses a cascading pattern for entity retrieval:
## 1. Memory cache (active entities)
## 2. Save file data
## 3. Original resource on disk


## Singleton instance of the entity manager
static var instance: SKEntityManager

## Dictionary mapping entity IDs to their instances
var entities: Dictionary[StringName, SKEntity] = {}

## Tracks entities that have been permanently removed from the game
var erased_entities: Dictionary[StringName, bool] = {}

## Reference to the tag tracking system for entity resource management
@onready var tag_tracker: SKTagTracker = (ResourceLoader.load(ProjectSettings.get_setting("skelerealms/config_path")) as SKConfig).tag_tracker


signal entity_created(id: StringName)
signal entity_erased(id: StringName)


func _init() -> void:
	instance = self


func _ready():
	SkeleRealmsGlobal.entity_manager_loaded.emit()


## Retrieves an entity by its ID using a cascading lookup pattern:
## 1. Checks active entities in memory
## 2. Attempts to load from save file
## 3. Creates new instance from disk resource
## [param id] The unique identifier of the entity
## Returns: The requested entity or null if not found/erased
func get_entity(id: StringName) -> SKEntity:
	# Check if entity was deleted
	if erased_entities.has(id):
		return null
	
	# Stage 1: Check memory cache
	if entities.has(id):
		(entities[id] as SKEntity).reset_stale_timer()  # FIXME: If another entity is carrying a reference to this entity, then we might break stuff by cleaning it up in this way?
		return entities[id]
	
	# Stage 2: Check save file
	var potential_data = SaveSystem.entity_in_save(id)
	if not potential_data.is_empty():
		var e: SKEntity = add_entity_from_scene(ResourceLoader.load(ResourceUID.get_id_path(tag_tracker.get_uid_for_name(id))))
		e.load_data(potential_data)
		e.reset_stale_timer()
		return e
	
	# Stage 3: Load from disk
	if tag_tracker.is_name_entity(id):
		var e: SKEntity = add_entity_from_scene(ResourceLoader.load(ResourceUID.get_id_path(tag_tracker.get_uid_for_name(id))))
		e.generate()
		e.reset_stale_timer()
		return e

	# Fallback: Check direct child nodes
	return get_node_or_null(id as String)


## Adds an entity instance to the manager
## [param e] The entity to add
## Returns: The added entity
func _add_entity_raw(e: SKEntity) -> SKEntity:
	entities[e.name] = e
	add_child(e)
	entity_created.emit(e.name)
	return e


## Removes inactive entities that haven't been accessed for a while
## Should ONLY be called after saving to prevent data loss
func _cleanup_stale_entities():
	for c in get_children():
		if (c as SKEntity).stale_timer >= ProjectSettings.get_setting("skelerealms/entity_cleanup_timer"):
			remove_entity(c.name)


## Permanently removes an entity from the game
## [param rid] The ID of the entity to remove
func remove_entity(rid: StringName) -> void:
	if entities.has(rid):
		entities[rid].queue_free()
		entities.erase(rid)
		erased_entities[rid] = true
		entity_erased.emit(rid)

## Creates an entity instance from a scene resource
## For non-unique entities, generates a new unique ID
## [param scene] The scene resource containing the entity
## Returns: The instantiated entity
func add_entity_from_scene(scene: PackedScene) -> SKEntity:
	var e: SKEntity = scene.instantiate()
	if not e:
		push_error("Scene at path %s isn't a valid entity." % scene.resource_path)

	if not e.unique:
		var valid: bool = false
		var new_id: String = ""
		while not valid:
			new_id = SKIDGenerator.generate_id()
			valid = not entities.has(new_id)
			e.generate.call_deferred()
		e.name = new_id
	return _add_entity_raw(e)


## Creates and positions a new entity instance in the world
## [param scene] The scene resource containing the entity
## [param position] position to spawn at
## [param rotation] Initial rotation
## [param world] World identifier to spawn in
func add_entity_from_scene_at_position(scene: PackedScene, position: Vector3, rotation: Quaternion, world: StringName) -> void:
	var e := add_entity_from_scene(scene)
	e.position = position
	e.rotation = rotation
	e.world = world


## Maps worlds to their contained entities
## Returns: Dictionary mapping world IDs to arrays of entity IDs
## TODO: Cache this mapping for faster world loading
func get_entities_in_worlds() -> Dictionary[StringName, Array]:
	var res: Dictionary[StringName, Array] = {}
	for rid: StringName in entities:
		var world: StringName = entities[rid].world
		res.get_or_add(world, []).append(String(rid))
	return res


## Handles initialization when entering a new world
## [param world] The world being entered
## TODO: Load relevant entities from save files
func on_new_world_entered(world: StringName) -> void:
	pass
