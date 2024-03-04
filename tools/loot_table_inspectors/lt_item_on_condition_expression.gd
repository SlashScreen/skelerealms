@tool
extends PanelContainer


@onready var ce:CodeEdit = $VBoxContainer/CodeEdit
var editing:SKLTOnCondition
var inspector:Control


func edit(e:SKLTOnCondition, i:Control) -> void:
	editing = e
	inspector = i
	ce.text = e.condition
	inspector.table_updated.connect(func(o:Object, tbl:Array[SKLootTableItem]) -> void: 
		if o == self:
			editing.items = tbl
		)


func _on_code_edit_text_changed() -> void:
	editing.condition = ce.text


func _on_inspect_pressed() -> void:
	inspector.inspect(self, editing.items)
