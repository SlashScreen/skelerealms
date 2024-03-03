@tool
extends PanelContainer


var editing:SKLTCurrency


func edit(e:SKLTCurrency) -> void:
	editing = e
	$VBoxContainer/LineEdit.text = String(e.currency)
	$VBoxContainer/HBoxContainer/Min.value = e.amount_min
	$VBoxContainer/HBoxContainer/Max.value = e.amount_max


func _on_line_edit_text_submitted(new_text: String) -> void:
	editing.currency = StringName(new_text)


func _on_min_value_changed(value: float) -> void:
	editing.amount_min = roundi(value)


func _on_max_value_changed(value: float) -> void:
	editing.amount_max = roundi(value)