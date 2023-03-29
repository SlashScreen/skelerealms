extends RefData
class_name NPCData
## Base data for an NPC.
## Not an instance of this NPC, just contains stuff like covens.

## NPC's model. Expects the root to be a [NPCPuppet].
@export var prefab: PackedScene
@export var schedule:Array[ScheduleEvent]
