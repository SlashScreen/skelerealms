class_name ItemData 
extends RefData
## Class for an item's base data. 
## Not an item instance.

## The model for an item.
@export var prefab: PackedScene
## A custom model for when this item is held in an NPC's hand. Will default to [member prefab] if not set.
@export var hand_item: PackedScene:
	get:
		if hand_item == null:
			return prefab
		else:
			return hand_item
	set(val):
		hand_item = val
## How much it weighs.
@export var weight: float
## The base cost in snails.
@export var worth: int
## Whether this item can be stacked in the inventory or not. Does nothing on its' own. To be used in inventory systems.
@export var stackable:bool
## Tags this item has.
@export var tags:Array[StringName] = []
