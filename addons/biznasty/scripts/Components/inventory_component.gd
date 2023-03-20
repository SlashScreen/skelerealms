class_name InventoryComponent extends EntityComponent

const entity = preload("../entity_component.gd")

var inventory: PackedStringArray
var snails: int

func add_to_inventory(id:String):
	inventory.append(id)
	
func remove_from_inventory(id:String):
	inventory.remove_at(inventory.find(id))
	
func add_snails(amount:int):
	snails += amount
	clamp_snails()
	
func remove_snails(amount:int):
	snails -= amount
	clamp_snails()
	
func clamp_snails():
	if snails < 0:
		snails = 0
