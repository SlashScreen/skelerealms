class_name CovensComponent
extends SKEntityComponent
## Component that manages entity membership in [class Coven]s (factions).
## Similar to faction systems in Bethesda games, covens group NPCs with similar behaviors and relationships.

@export var covens:Dictionary[StringName, int]  ## Dictionary mapping coven IDs to member ranks 


func _init(coven_list:Array[CovenRankData] = []) -> void:
	name = &"CovensComponent"
	if coven_list.is_empty():
		return
	# Load rank info
	for crd in coven_list:
		covens[crd.coven.coven_id] = crd.rank


func _ready():
	super._ready()
	# Add entity to coven groups
	for c in covens:
		parent_entity.add_to_group(c)


## Adds the entity to a coven with specified rank
## [param coven] The coven ID to join
## [param rank] The rank within the coven (default: 1)
func add_to_coven(coven:StringName, rank:int = 1):
	covens[coven] = 1
	parent_entity.add_to_group(coven)


## Removes the entity from a specified coven
## [param coven] The coven ID to leave
func remove_from_coven(coven:StringName):
	covens.erase(coven)
	parent_entity.remove_from_group(coven)


## Checks if the entity belongs to a specific coven. Returns true if entity is a member.
## [param coven] The coven ID to check
func is_in_coven(coven:StringName) -> bool:
	return covens.has(coven)


## Gets the entity's rank within a specific coven. Returns rank (0 if not a member).
## [param coven] The coven ID to check
func get_coven_rank(coven:StringName) -> int:
	return covens[coven] if covens.has(coven) else 0
