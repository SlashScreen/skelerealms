@tool
class_name InstanceData
extends Resource
## The base class for an instance of an NPC, item, Etc.

@export var ref_id:StringName
@export var world:StringName
@export var position:Vector3
## Custom script for a [ScriptComponent] that can optionally override the base data's script for this instance only.
@export var override_custom_script:Script


## Get all of the entitiy components associated with this type of entity.
## Override this and create the components this needs.
## Example: An item instance should have, say, [ItemComponent], [InteractiveComponent], [PuppetComponent].
func get_archetype_components() -> Array[SKEntityComponent]:
	return []


## I'm too tired to explain what this does, but it will return [member override_custom_script] if it isnt null, else it will return the original script.
func _try_override_script(sc:Script) -> Script:
	return sc if override_custom_script == null else override_custom_script


func convert_to_scene() -> PackedScene:
	return null


static func _transfer_properties(from:Object, to:Object) -> void:
	var from_p:Array[Dictionary] = from.get_property_list()
	var to_p:Array[Dictionary] = to.get_property_list()
	
	for d:Dictionary in from_p:
		if d.name == &"script":
			continue
		if to_p.any(func(x:Dictionary) -> bool: return d.name == x.name):
			to.set(d.name, from.get(d.name))
