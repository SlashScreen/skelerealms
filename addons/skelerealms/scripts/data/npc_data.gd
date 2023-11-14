extends RefData
class_name NPCData
## Base data for an NPC.
## Not an instance of this NPC, just contains stuff like covens, and behavior for the NPC.


## NPC's model. Expects the root to be a [NPCPuppet].
@export var prefab: PackedScene
## Schedule events for this NPC to follow.
@export var schedule:Array[ScheduleEvent]
## [Coven]s this NPC is a part of, and their default rank.
@export var covens:Array[CovenRankData] = []
## What the default opinion of the player is.
@export var default_player_opinion:int = 0
## Loyalty of this NPC. Determines weights of opinion calculations.
@export_enum("None", "Covens", "Self") var loyalty = 0

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
## Dialogue node name to start when interacted. 
@export var start_dialogue_node:String
## Whether you can interact with this NPC.
@export var interactive:bool = true
## NPC relationships.
@export var relationships:Array[Relationship]

@export_category("AI")
## AI Modules.
@export var modules:Array[AIModule] = [
		DefaultThreatResponseModule.new(),
		DefaultInteractResponseModule.new(),
		DefaultDamageModule.new()
	]
## GOAP Actions.
@export var goap_actions:Array[GOAPBehavior] = []
## The loot table of this kind of NPC.
@export var loot_table:LootTable
