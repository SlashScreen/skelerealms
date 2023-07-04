class_name RefData 
extends Resource
## Base class for data blobs about objects that come bundled with the game. An item's type, for example.

## ID of this blob.
@export var id: String
## Custom script to be applied to this entity, if any. See [ScriptComponent].
@export var custom_script:Script


func build_new_instance() -> InstanceData:
	return null
