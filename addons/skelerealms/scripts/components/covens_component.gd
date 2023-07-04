class_name CovensComponent
extends EntityComponent
## Allows an Entity to be part of a [Coven].
## Covens in this context are analagous to Bethesda games' Factions- groups of NPCs that behave in a similar way.
## Coven membership is also reflected in groups that the entity is in.


## IDs of covens this entity is a member of.
## This dictionary is of type StringName:Int, where key is the coven, and int is the rank of this member.
@export var covens:Dictionary


func _init(coven_list:Array[CovenRankData] = []) -> void:
	name = "CovensComponent"
	if coven_list.is_empty():
		return
	# Load rank info
	for crd in coven_list:
		print("Adding to coven %s" % crd.coven.coven_id)
		covens[crd.coven.coven_id] = crd.rank


func _ready():
	super._ready()
	# Add corresponding covens.
	for c in covens:
		parent_entity.add_to_group(c)


## Add this entity to a coven.
func add_to_coven(coven:StringName, rank:int = 1):
	covens[coven] = 1
	parent_entity.add_to_group(coven)


## Remove this entity from the coven.
func remove_from_coven(coven:StringName):
	covens.erase(coven)
	parent_entity.remove_from_group(coven)


## Whether the entity is in a coven or not.
func is_in_coven(coven:StringName) -> bool:
	return covens.has(coven)


## Get this entity's rank in a coven. Returns 0 if they aren't in the coven.
func get_coven_rank(coven:StringName) -> int:
	return covens[coven] if covens.has(coven) else 0
