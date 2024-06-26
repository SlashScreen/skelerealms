extends EditorInspectorPlugin


## Perhaps unintuitively named, this handles things that need to be synced to the sk config; AttributesComponent, SkillsComponent, Equipment Slots.


const SlotSelector = preload("slot_enum_selector.gd")


func _can_handle(object: Object) -> bool:
	return object is VitalsComponent or object is AttributesComponent or object is SkillsComponent or object is EquippableDataComponent


func _parse_begin(object: Object) -> void:
	if object is AttributesComponent:
		_handle_attributes(object)
	elif object is SkillsComponent:
		_handle_skills(object)


func _parse_property(object: Object, _type: Variant.Type, name: String, _hint_type: PropertyHint, _hint_string: String, _usage_flags: int, _wide: bool) -> bool:
	if object is EquippableDataComponent:
		return _handle_slots(object, name)
	return false


func _handle_attributes(object: AttributesComponent) -> void:
	var b := Button.new()
	b.text = "Sync attributes set"
	b.pressed.connect(func() -> void: object.attributes = SkeleRealmsGlobal.config.attributes.duplicate())
	add_custom_control(b)


func _handle_skills(object: SkillsComponent) -> void:
	var b := Button.new()
	b.text = "Sync skill set"
	b.pressed.connect(func() -> void: object.skills = SkeleRealmsGlobal.config.skills.duplicate())
	add_custom_control(b)


func _handle_slots(object:EquippableDataComponent, n:StringName) -> bool:
	if n == "valid_slots":
		add_property_editor("valid_slots", SlotSelector.new())
		return true 
	return false
