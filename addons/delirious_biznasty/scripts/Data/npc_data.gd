extends RefData
class_name NPCData
## Base data for an NPC.
## Not an instance of this NPC, just contains stuff like covens.

## NPC's model. Expects the root to be a [NPCPuppet].
@export var prefab: PackedScene
@export var schedule:Array[ScheduleEvent]
@export_category("Flags")
## Whether this NPC is essential to the story, and them dying would screw things up.
@export var essential:bool = true
## Whether this NPC is a ghost.
@export var ghost:bool
## Whether this NPC can't take damage.
@export var invulnerable:bool
## Whether this NPC is unique.
@export var unique:bool = true
## Whether this NPC affects the stealth meter when it sees you.
@export var affects_stealth_meter:bool = true
