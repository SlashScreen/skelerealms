class_name NPCComponent 
extends EntityComponent
## The brain for an NPC.


## Base data for this NPC.
@export var data: NPCData

var player_opinion:int
var in_combat:bool

var _path:Array[NavPoint]
var _current_tagret_point:NavPoint
var _nav_component:NavigatorComponent
var _puppet_component:PuppetSpawnerComponent
var _interactive_component:InteractiveComponent
var _goap_component:GOAPComponent


func _ready():
	super._ready()
	($"../InteractiveComponent" as InteractiveComponent).interacted.connect(interact.bind())


func _on_enter_scene():
	$"../PuppetSpawnerComponent".spawn(data.prefab)


func _on_exit_scene():
	$"../PuppetSpawnerComponent".despawn()

# TODO: All of this

func _process(delta):
	# Path following
	# If in scene, use navmesh agent
	# If not in scene, lerp between points.
	pass


## Interact with this npc. See [InteractiveComponent].
func interact(refID:String):
	pass


# TODO: Average covens and player opinion
func determine_opinion(refID:String) -> int:
	return 0


## Calculate this NPC's path to a [NavPoint].
func set_destination(dest:NavPoint):
	# Recalculate path
	_path = _nav_component.calculate_path_to(dest)


func add_objective(goals:Dictionary, remove_after_satisfied:bool, priority:float):
	_goap_component.add_objective(goals, remove_after_satisfied, priority)


func on_percieve(ref_id:String):
	pass


func follow_schedule():
	pass
