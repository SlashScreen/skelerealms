@tool
extends Control


@onready var rank_list:ItemList = $HBoxContainer/VBoxContainer/Ranks
var editing:Coven 


func edit(c:Coven) -> void: 
	editing = c
	$HBoxContainer/VBoxContainer/GridContainer/Hidden.pressed = c.hidden_from_player
	$HBoxContainer/VBoxContainer/GridContainer/IgnoreOthers.pressed = c.ignore_crimes_against_others
	$HBoxContainer/VBoxContainer/GridContainer/IgnoreMembers.pressed = c.ignore_crimes_against_members
	$HBoxContainer/VBoxContainer/GridContainer/TrackCrime.pressed = c.track_crime
	for r:int in c.ranks:
		rank_list.add_item(c.ranks[r])
	for o:StringName in c.other_coven_opinions:
		_add_opinion_to_list(o, c.other_coven_opinions[o])
	$HBoxContainer/VBoxContainer/LineEdit.text = c.coven_id


func _on_add_opinion_pressed() -> void:
	_add_opinion_to_list(&"", 0)


func _on_add_rank_pressed() -> void:
	var rn:LineEdit = $HBoxContainer/VBoxContainer/HBoxContainer/RankName
	if rn.text.is_empty():
		return
	rank_list.add_item(rn.text)
	rn.clear()
	_update_rank_list()


func _on_remove_rank_pressed() -> void:
	if rank_list.is_anything_selected():
		rank_list.remove_item(rank_list.get_selected_items()[0])
		_update_rank_list()


func _update_rank_list() -> void:
	editing.ranks.clear()
	for i:int in rank_list.item_count:
		editing.ranks[i] = rank_list.get_item_text(i)


func _add_opinion_to_list(c:StringName, o:int) -> void:
	var container:HBoxContainer = HBoxContainer.new() 
	
	var c_opinion:SpinBox = SpinBox.new()
	c_opinion.rounded = true
	
	var c_name:LineEdit = LineEdit.new() 
	c_name.placeholder_text = "Coven Name..."
	c_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c_name.text_submitted.connect(func(new_text:String) -> void:
		editing.other_coven_opinions.erase(c_name.text)
		editing.other_coven_opinions[new_text] = roundi(c_opinion.value)
		)
	
	c_opinion.value_changed.connect(func(new_value:float) -> void:
		editing.other_coven_opinions[c_name.text] = roundi(new_value)
		)
	
	if not c.is_empty():
		c_name.text = String(c)
		c_opinion.value = o
	
	var rb:Button = Button.new()
	rb.text = "Remove"
	rb.pressed.connect(func() -> void:
		container.queue_free()
		editing.other_coven_opinions.erase(c_name.text)
		)
	
	container.add_child(c_name)
	container.add_child(c_opinion)
	container.add_child(rb)
	
	$HBoxContainer/VBoxContainer2/Opinions.add_child(container)
