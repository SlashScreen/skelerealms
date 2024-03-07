@tool
extends HBoxContainer


var editing:InstanceData


func edit(i:InstanceData) -> void:
	editing = i
	$RefID.text = i.ref_id
	$World.text = i.world
	$X.value = i.position.x
	$Y.value = i.position.y
	$Z.value = i.position.z


func _on_ref_id_text_submitted(new_text: String) -> void:
	editing.ref_id = new_text


func _on_world_text_submitted(new_text: String) -> void:
	editing.world = StringName(new_text)


func _on_x_value_changed(value: float) -> void:
	editing.position.x = value


func _on_y_value_changed(value: float) -> void:
	editing.position.y = value


func _on_z_value_changed(value: float) -> void:
	editing.position.z = value
