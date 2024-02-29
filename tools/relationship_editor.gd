extends PanelContainer


var editing:Relationship
@export var TypeDropdown:OptionButton = $HBoxContainer/VBoxContainer/Type/OptionButton

func _ready() -> void:
	TypeDropdown.clear()
	for t:String in Relationship.RelationshipLevel.keys():
		TypeDropdown.add_item(t)
