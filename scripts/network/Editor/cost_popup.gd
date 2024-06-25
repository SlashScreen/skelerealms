@tool
extends ConfirmationDialog


signal popup_accepted(text:String)


func _ready() -> void:
	get_ok_button().button_up.connect(_accept.bind())
	($LineEdit as LineEdit).text_changed.connect(_check_text.bind())
	

func _accept() -> void:
	popup_accepted.emit(($LineEdit as LineEdit).text)


func _check_text(new_text:String) -> void:
	get_ok_button().disabled = not new_text.is_valid_float()
