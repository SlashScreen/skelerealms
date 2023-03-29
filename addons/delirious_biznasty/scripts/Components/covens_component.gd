class_name CovensComponent
extends EntityComponent
## Allows an Entity to be part of a Coven.
## Covens in this context are analagous to Bethesda games' Factions- groups of NPCs that behave in a similar way.
## Coven membership is also reflected in groups that the entity is in.


## IDs of covens this entity is a member of.
var covens:Array[String]


func _ready():
	super._ready()
	# Add corresponding covens.
	for c in covens:
		parent_entity.add_to_group(c)


## Add this entity to a coven.
func add_to_coven(coven:String):
	covens.append(coven)
	parent_entity.add_to_group(coven)


## Remove this entity from the coven.
func remove_from_coven(coven:String):
	covens.erase(coven)
	parent_entity.remove_from_group(coven)


## Whether the entity is in a coven or not.
func is_in_coven(coven:String) -> bool:
	return covens.has(coven)
