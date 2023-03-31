class_name ItemData 
extends RefData
## Class for an item's base data. 
## Not an item instance.

## The model for an item.
@export var prefab: PackedScene
## How much it weighs.
@export var weight: float
## The base cost in snails.
@export var worth: int
## The components that describe this item.
@export var components:Array[ItemDataComponent]


## Whether it has a component type. [code]c[/code] is the name of the component type, like "HoldableDataComponent".
func has_component(c:String) -> bool:
	return components.any(func(x:ItemDataComponent): return x.get_type() == c)


## Gets the first component of a type. [code]c[/code] is the name of the component type, like "HoldableDataComponent".
func get_component(c:String) -> Option:
	var valid_components = components.filter(func(x:ItemDataComponent): return x.get_type() == c)
	if valid_components.is_empty():
		return Option.none()
	else:
		return Option.from(valid_components[0])
