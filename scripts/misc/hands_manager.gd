class_name HandsManager
extends Node3D

# This is my own messy hands manager from my project. You'll want to make youir own version, probably.
# This will be replaced with an easier-to-use system in the future.


const HEAVY_SWING_COST = 10.0

@export var puppet_root:Node3D
@export var hands:Dictionary = {}
@export var hands_slots:Dictionary = {
	&"left": EquipmentSlots.Slots.HAND_LEFT,
	&"right": EquipmentSlots.Slots.HAND_RIGHT
}
@export var slots_to_hands:Dictionary = {
	EquipmentSlots.Slots.HAND_LEFT: &"left",
	EquipmentSlots.Slots.HAND_RIGHT: &"right"
}
@export var other_hands:Dictionary = {
	&"left": &"right",
	&"right": &"left"
}
@export var can_block:bool = true
var is_blocking:Dictionary
# used for spells
var is_holding:Dictionary
var held_item:Dictionary
var entity:Entity:
	get:
		if entity == null:
			entity = puppet_root.get_puppeteer().parent_entity
		return entity
var equipment:EquipmentComponent:
	get:
		if equipment == null:
			equipment = entity.get_component("EquipmentComponent")
		return equipment
var entity_rid:StringName:
	get:
		return entity.name
var weapons_drawn:bool = false # TODO: Save
var hand_busy:Dictionary = {}
@onready var anim_controller:AnimationController = AnimationController.get_animator(self)

signal light_attack_started(hand:StringName)
signal light_attack_ended(hand:StringName)
signal heavy_attack_started(hand:StringName)
signal heavy_attack_ended(hand:StringName)
signal block_started(hand:StringName)
signal block_ended(hand:StringName)
signal start_holding(hand:StringName)
signal end_holding(hand:StringName)
signal raise_weapons
signal lower_weapons


func get_is_blocking(hand:StringName) -> bool:
	if is_blocking.has(hand):
		return is_blocking[hand]
	else:
		return false


func get_is_holding(hand:StringName) -> bool:
	if is_holding.has(hand):
		return is_holding[hand]
	else:
		return false


func get_held_item(hand:StringName) -> Node3D:
	if held_item.has(hand):
		return held_item[hand]
	else:
		return null


func get_hand(hand:StringName)-> Node3D:
	if hands.has(hand):
		return get_node(hands[hand])
	else:
		return null

func find_hit_test(n:Node) -> HitDetector:
	if n is HitDetector:
		return n
	
	for c in n.get_children():
		var hd:HitDetector = find_hit_test(c)
		if hd:
			return hd
	
	return null


#func get_hand_block_component(hand:StringName) -> BlockingDataComponent:
	#var hand_id:Option = equipment.is_slot_occupied(hands_slots[hand])
	#if not hand_id.some():
		#return null
	#else:
		#var ic:ItemComponent = EntityManager.instance.get_entity(hand_id.unwrap()).get_component("ItemComponent")
		#var block:BlockingDataComponent = ic.data.get_component("BlockingDataComponent")
		#if block:
			#return block
	#return null


func _ready() -> void:
	start_holding.connect(func(hand:StringName) -> void: is_holding[hand] = true)
	end_holding.connect(func(hand:StringName) -> void: is_holding[hand] = false)
	block_started.connect(func(hand:StringName) -> void: is_blocking[hand] = true)
	block_ended.connect(func(hand:StringName) -> void: is_blocking[hand] = false)
	raise_weapons.connect(func() -> void: weapons_drawn = true) # Wait until animation?
	lower_weapons.connect(func() -> void: weapons_drawn = false)
	
	if EntityManager.instance == null:
		await SkeleRealmsGlobal.entity_manager_loaded
	
	_finish_up.call_deferred()


func _finish_up() -> void:
	print("Finishing up...")
	equipment.equipped.connect(func(id:StringName, slot:EquipmentSlots.Slots) -> void:
		var ic:ItemComponent = EntityManager.instance.get_entity(id).get_component("ItemComponent")
		var prefab:Node = ic.data.hand_item.instantiate()
		if prefab is ItemPuppet:
			prefab.inactive = true
		if prefab is RigidBody3D:
			(prefab as RigidBody3D).freeze = true
			(prefab as RigidBody3D).freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		
		var equipped_hand:StringName = slots_to_hands[slot] if slots_to_hands.has(slot) else null
		
		if equipped_hand == null:
			return
		
		if get_held_item(equipped_hand):
			get_held_item(equipped_hand).queue_free()
		get_hand(equipped_hand).add_child(prefab)
		held_item[equipped_hand] = prefab
		)
	
	equipment.unequipped.connect(func(_id:StringName, slot:EquipmentSlots.Slots) -> void:
		var equipped_hand:StringName = slots_to_hands[slot] if slots_to_hands.has(slot) else null
		
		if equipped_hand == null:
			return
		
		if get_held_item(equipped_hand):
			get_held_item(equipped_hand).queue_free()
			held_item.erase(equipped_hand)
		)
	
	raise_weapons.connect(func() -> void:
		for h:StringName in hands:
			get_hand(h).show()
	)
	lower_weapons.connect(func() -> void:
		for h:StringName in hands:
			get_hand(h).hide()
	)
	
	if weapons_drawn:
		for h:StringName in hands:
			get_hand(h).show()
	else:
		for h:StringName in hands:
			get_hand(h).hide()


func is_hand_busy(hand:StringName) -> bool:
	if hand_busy.has(hand):
		return hand_busy[hand]
	else:
		return false


func _mark_hand_busy_state(hand: StringName, state: bool) -> void:
	print("Marked hand")
	hand_busy[hand] = state


func _process(delta:float) -> void:
	for ih:StringName in is_holding:
		if is_holding[ih]:
			get_hand(ih).held.emit(delta)


# ALL OF THIS IS STUPID
func _handle_light_attack(hand:StringName) -> void: 
	print(hand_busy)
	if is_hand_busy(hand):
		return
	print("light attack on %s" % hand)
	var item_id:Option = equipment.is_slot_occupied(hands_slots[hand])
	var animation:String = "punch" # TODO: change this to work with animation trees
	# get custom swing animation if applicable
	if item_id.some():
		var item_c:ItemComponent = EntityManager.instance.get_entity(item_id.unwrap()).get_component("ItemComponent")
		
		# return early if spell, since it does its own thing
		var sdc:SpellDataComponent = item_c.data.get_component("SpellDataComponent")
		if sdc:
			return
		
		#var hdc:HittingDataComponent = item_c.data.get_component("HittingDataComponent")
		#if hdc:
			#animation = (hdc as HittingDataComponent).light_swing_animation
	
	anim_controller.trigger("attack_%s_%s" % [animation, hand])


func _handle_heavy_attack(hand:StringName) -> void: 
	if is_hand_busy(hand):
		return
	print("heavy attack on %s" % hand)
	if (entity.get_component("VitalsComponent") as VitalsComponent).vitals[&"moxie"] < HEAVY_SWING_COST:
		# TODO: Flash stamina bar
		return
	var item_id:Option = equipment.is_slot_occupied(hands_slots[hand])
	var animation:String = "punch"
	# get custom swing animation if applicable
	if item_id.some():
		var item_c:ItemComponent = EntityManager.instance.get_entity(item_id.unwrap()).get_component("ItemComponent")
		
		# return early if spell, since it does its own thing
		var sdc:SpellDataComponent = item_c.data.get_component("SpellDataComponent")
		if sdc:
			return
		
		#var hdc:HittingDataComponent = item_c.data.get_component("HittingDataComponent")
		#if hdc:
			#animation = (hdc as HittingDataComponent).heavy_swing_animation
	
	anim_controller.trigger("attack_%s_%s" % [animation, hand])
	(entity.get_component("VitalsComponent") as VitalsComponent).change_moxie(-HEAVY_SWING_COST)


func _start_heavy_attack_collision(hand:StringName) -> void:
	print("heavy attack on %s" % hand)
	var hand_item:Node3D = get_held_item(hand)
	var hand_id:Option = equipment.is_slot_occupied(hands_slots[hand])
	# TODO: Do fists
	if not hand_id.some() or not hand_item:
		var hd:HitDetector = find_hit_test(get_hand(hand))
		if hd:
			#hd.activate(func(bodies:Node3D) -> void: _heavy_attack_callback(bodies, "", null, hand))
			return
	
	var item_c:ItemComponent = EntityManager.instance.get_entity(hand_id.unwrap()).get_component("ItemComponent")
	#var melee_o:MeleeDataComponent = item_c.data.get_component("MeleeDataComponent")
	#if melee_o:
		#var hd:HitDetector = find_hit_test(hand_item)
		#hd.activate(func(bodies:Node3D) -> void: _heavy_attack_callback(bodies, hand_id.unwrap(), melee_o, hand))


#func _heavy_attack_callback(body:Node3D, _hand_id:String, melee_component:MeleeDataComponent, hand:StringName) -> void:
	#print("hit something.")
	#var d:Node = SkeleRealmsGlobal.get_damageable_node(body)
	#if d:
		#if d is DamageableComponent and (d as DamageableComponent).parent_entity.name == entity_rid:
			#return
		#print("Damageable")
		#if melee_component:
			#d.damage(DamageInfo.new(entity_rid, melee_component.damage_effects, melee_component.spell_effects, melee_component.info))
		#else:
			## TODO: Unarmed damage modifier
			#d.damage(DamageInfo.new(entity_rid, {&"blunt": 2}, [], {&"fists":true}))
	#else:
		#print("Not damageable")
		#_end_light_attack_collision(hand)


func _end_heavy_attack_collision(hand:StringName) -> void: # TODO ASAP: Make sure items cant get unequipped while paused
	print("Ending heavy attack")
	var hand_item:Node = get_held_item(hand)
	var hand_id:Option = equipment.is_slot_occupied(hands_slots[hand])
	
	if not hand_id.some() or not hand_item:
		var hd:HitDetector = find_hit_test(get_hand(hand))
		if hd:
			hd.deactivate()
			return
	
	var item_c:ItemComponent = EntityManager.instance.get_entity(hand_id.unwrap()).get_component("ItemComponent")
	#var melee_o:MeleeDataComponent = item_c.data.get_component("MeleeDataComponent")
	#
	#if melee_o:
		#var hd:HitDetector = find_hit_test(hand_item)
		#hd.deactivate()


func _start_light_attack_collision(hand:StringName) -> void:
	print("Starting light attack")
	var hand_item:Node = get_held_item(hand)
	var hand_id:Option = equipment.is_slot_occupied(hands_slots[hand])
	if not hand_id.some() or not hand_item:
		var hd:HitDetector = find_hit_test(get_hand(hand))
		if hd:
			#hd.activate(func(bodies:Node3D) -> void: _light_attack_callback(bodies, "", null, hand))
			return
	
	var item_c:ItemComponent = EntityManager.instance.get_entity(hand_id.unwrap()).get_component("ItemComponent")
	#var melee_o:MeleeDataComponent = item_c.data.get_component("MeleeDataComponent")
	#if melee_o:
		#var hd:HitDetector = find_hit_test(hand_item)
		#hd.activate(func(bodies:Node3D) -> void: _light_attack_callback(bodies, hand_id.unwrap(), melee_o, hand))


#func _light_attack_callback(body:Node3D, _hand_id:String, melee_component:MeleeDataComponent, hand:StringName) -> void:
	#print("hit something.")
	#var d:Node = SkeleRealmsGlobal.get_damageable_node(body)
	#if d:
		#if d is DamageableComponent and (d as DamageableComponent).parent_entity.name == entity_rid:
			#return
		#print("Damageable")
		#if melee_component:
			#d.damage(DamageInfo.new(entity_rid, melee_component.damage_effects, melee_component.spell_effects, melee_component.info))
		#else:
			## TODO: Unarmed damage modifier
			#d.damage(DamageInfo.new(entity_rid, {&"blunt": 2}, [], {&"fists":true}))
	#else:
		#print("Not damageable")
		#_end_light_attack_collision(hand)


func _end_light_attack_collision(hand:StringName) -> void: # TODO ASAP: Make sure items cant get unequipped while paused
	print("Ending light attack")
	var hand_item:Node = get_held_item(hand)
	var hand_id:Option = equipment.is_slot_occupied(hands_slots[hand])
	
	if not hand_id.some() or not hand_item:
		var hd:HitDetector = find_hit_test(get_hand(hand))
		if hd:
			hd.deactivate()
			return
	
	var item_c:ItemComponent = EntityManager.instance.get_entity(hand_id.unwrap()).get_component("ItemComponent")
	#var melee_o:MeleeDataComponent = item_c.data.get_component("MeleeDataComponent")
	
	#if melee_o:
		#var hd:HitDetector = find_hit_test(hand_item)
		#hd.deactivate()


# Block behavior:
# Check this hand first. If it blocks with this input, IE Shield, block until released.
# Check other hand - if this hand is empty and other hand does other input blocking, block with that hand.

func _handle_block(hand:StringName) -> void:
	if not can_block:
		return
	
	var slot:EquipmentSlots.Slots = hands_slots[hand]
	
	#if equipment.is_slot_occupied(slot).some():
		#var block_component:BlockingDataComponent = get_hand_block_component(hand)
		#if block_component:
			#match block_component.mode:
				#BlockingDataComponent.BlockingBehavior.SAME_HAND:
					#print("block same hand")
					#block_started.emit(hand)
	#else:
		#var block_component:BlockingDataComponent = get_hand_block_component(other_hands[hand]) # other hand
		#if block_component:
			#match block_component.mode:
				#BlockingDataComponent.BlockingBehavior.OTHER_HAND:
					#print("block other hand")
					#block_started.emit(hand)


func get_animator() -> AnimationPlayer:
	return $"../AnimationPlayer"
