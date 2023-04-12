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
@export var start_dialogue_node:String
@export var interactive:bool = true
@export var relationships:Array[Relationship]
@export_category("Combat info")
## Will this actor initiate combat? [br]
## Peaceful: Will not initiate combat. [br]
## Bluffing: Variant of peaceful, they will warn and try to act tough, but never attack. 
## Aggressive: Will attack enemies on sight. [br]
## Very agressive: Will attack enemies and neutrals. [br]
## Frenzied: Will attack anything.
@export_enum("Peaceful", "Bluffing", "Aggressive", "Very Aggressive", "Frenzied") var aggression:int = 2
## Response to combat. [br]
## Coward: Flees from combat. [br]
## Cautious: Cautious: Will flee unless stronger than target. [br]
## Average: Will fight unless outmatched. [br]
## Brave: Will fight unless very outmatched. [br]
## Foolhardy: Will never flee.
@export_enum("Coward", "Cautious", "Average", "Brave", "Foolhardy") var confidence:int = 2
## Response to witnessing combat.
@export_enum("Helps nobody", "Helps allies", "Helps friends and allies") var assistance:int = 2
## How NPCs behave whn hit by friends. [br]
## Neutral: Aggro friends immediately when hit. [br]
## Friend: During combat, won't attack player unless hit a number of times in an amount of time. Outside of combat, it will aggro the friendly immediately. [br]
## Ally: During combat, will ignore all attacks from friend. Outside of combat, behaves in the same way is "Friend" in combat. [br]
@export_enum("Neutral", "Friend", "Ally") var friendly_fire_behavior:int = 1
@export_category("AI Modules")
@export var threat_response_module:AIModule = DefaultThreatResponseModule.new()

## Get all the modules instead of having to refer to them one by one.
var modules:Array[AIModule]:
	get:
		return [threat_response_module]