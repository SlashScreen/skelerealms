class_name GOAPAction
extends Node
## Base class for GOAP actions.


var prerequisites:Dictionary:
	get: 
		return goap_behavior.prerequisites
var effects:Dictionary:
	get: 
		return goap_behavior.effects
var cost:float:
	get: 
		return goap_behavior.cost
var duration:float:
	get: 
		return goap_behavior.duration
## Whether this objective is actively being worked on
var running:bool:
	get: 
		return goap_behavior.running
	set(val):
		goap_behavior.running = val
var parent_goap:GOAPComponent:
	get: 
		return goap_behavior.parent_goap
var entity:Entity:
	get: 
		return goap_behavior.entity

var goap_behavior:GOAPBehavior


func _init(behavior:GOAPBehavior = null) -> void:
	if behavior:
		goap_behavior = behavior
		name = behavior.id


func is_achievable_given(state:Dictionary) -> bool:
	return goap_behavior.is_achievable_given(state)


func is_achievable() -> bool:
	return goap_behavior.is_achievable()


func pre_perform() -> bool:
	return goap_behavior.pre_perform()


func target_reached() -> bool:
	return goap_behavior.target_reached()


func post_perform() -> bool:
	return goap_behavior.post_perform()


func is_target_reached(agent:NavigationAgent3D) -> bool:
	if not agent:
		return true
	return goap_behavior.is_target_reached(agent)


func interrupt() -> void:
	if goap_behavior:
		goap_behavior.interrupt()
