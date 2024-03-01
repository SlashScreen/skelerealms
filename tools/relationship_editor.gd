@tool
extends PanelContainer


var editing:Relationship
@onready var type_dropdown:OptionButton = $HBoxContainer/VBoxContainer/Type/OptionButton

signal delete_request


func _ready() -> void:
	type_dropdown.clear()
	for t:String in Relationship.RelationshipLevel.keys():
		type_dropdown.add_item(t)


func edit(r:Relationship) -> void:
	editing = r
	$HBoxContainer/VBoxContainer/Other/OtherEdit.text = editing.other_person
	$HBoxContainer/VBoxContainer/Role/RoleEdit.text = editing.role


func _on_button_pressed() -> void:
	delete_request.emit()


func _on_other_edit_text_submitted(new_text: String) -> void:
	editing.other_person = new_text


func _on_role_edit_text_submitted(new_text: String) -> void:
	editing.role = new_text


func _on_option_button_item_selected(index: int) -> void:
	var i:Relationship.RelationshipLevel = Relationship.RelationshipLevel.keys().find(type_dropdown.get_item_text(index))
	editing.level = i
