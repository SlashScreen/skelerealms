class_name SKLTOnCondition
extends SKLootTableItem


@export_multiline var condition:String = ""
@export var items:Array[SKLootTableItem] = []


func resolve() -> Array[ItemData]:
	if not _check_condition():
		return []
	
	var o:Array[ItemData] = []
	for i:SKLootTableItem in items:
		o.append_array(i.resolve())
	return o


func _check_condition() -> bool:
	if condition == "":
		return false
	
	var e:Expression = Expression.new()
	
	var err:int = e.parse(condition)
	if not err == 0:
		print("Loot table script error: %s" % e.get_error_text())
		return false
	
	var res = e.execute()
	
	if e.has_execute_failed():
		print("Loot table script execution failed.")
		return false
	if res == null:
		return false
	if res is bool:
		return res
	else:
		print("Loot table script warning: Expression should return boolean value.")
		return true