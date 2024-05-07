class_name ScriptComponent
extends SKEntityComponent
## This class can be bound to any entity and acts as a way to make ad-hoc components, to fill the role Papyrus plays in Creation Kit.
## To create a script for this, simply extend this class, and add it to the [RefData] or [InstanceData] of the appropriate object. 
## If you want to add a custom script to a world object instead, you can.... write a normal script...


## Stores references to all components of this entity, save for this one.
## Dictionary layout is "ComponentType" : SKEntityComponent.
## This is declared in _ready(), so be careful when overriding.
var _components:Dictionary = {}


func _init(sc:Script) -> void:
	if not sc.get_base_script().get_instance_base_type() == get_script().get_instance_base_type():
		push_warning("The script \"%s\" does not inherit ScriptComponent. Deleting component to prevent unexpected behavior." % sc.get_instance_base_type())
		call_deferred("queue_free") ## Queue next frame. I think. May not work.
	set_script(sc)


func _ready() -> void:
	super._ready()
	name = "ScriptComponent"
	await parent_entity.instantiated
	for c in parent_entity.get_children():
		if c == self:
			continue
		_components[c.name] = c
