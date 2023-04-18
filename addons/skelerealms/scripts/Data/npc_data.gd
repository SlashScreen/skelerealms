extends RefData
class_name NPCData
## Base data for an NPC.
## Not an instance of this NPC, just contains stuff like covens, and behavior for the NPC.
## The combat settings assume that [DefaultThreatResponseModule] is applied to this NPC.


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

@export_category("Combat info")
## Will this actor initiate combat? [br]
## Peaceful: Will not initiate combat. [br]
## Bluffing: Variant of peaceful, they will warn and try to act tough, but never attack. [br
## Aggressive: Will attack anything below the [member attack_threshold] on sight. [br]
## Frenzied: Will attack anything, ignoring opinion.
@export_enum("Peaceful", "Bluffing", "Aggressive", "Frenzied") var aggression:int = 2
## Agressive NPCs will attack any entity with an opinion below this threshold.  
@export_range(-100, 100) var attack_threshold:int = -50
## Response to combat. [br]
## Coward: Flees from combat. [br]
## Cautious: Cautious: Will flee unless stronger than target. [br]
## Average: Will fight unless outmatched. [br]
## Brave: Will fight unless very outmatched. [br]
## Foolhardy: Will never flee.
@export_enum("Coward", "Cautious", "Average", "Brave", "Foolhardy") var confidence:int = 2
## Response to witnessing combat. [br]
## Helps Nobody: Does not help anybody. [br]
## Helps people: Helps people above [member assistance_threshold].
@export_enum("Helps nobody", "Helps people") var assistance:int = 1
## If [member assistance] is "Helps people", it will assist entities with an opinion above this threshold.
@export_range(-100, 100) var assistance_threshold:int = 0
## How NPCs behave when hit by friends. [br]
## Neutral: Aggro friends immediately when hit. [br]
## Friend: During combat, won't attack player unless hit a number of times in an amount of time. Outside of combat, it will aggro the friendly immediately. [br]
## Ally: During combat, will ignore all attacks from friend. Outside of combat, behaves in the same way is "Friend" in combat. [br]
@export_enum("Neutral", "Friend", "Ally") var friendly_fire_behavior:int = 1

@export_category("AI Modules")
## AI Modules.
@export var modules:Array[AIModule] = [
		DefaultThreatResponseModule.new(),
		DefaultInteractResponseModule.new()
	]
