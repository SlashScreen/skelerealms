class_name Transaction
extends RefCounted
## An object keeping track of stuff being bought and sold while bartering.


## Who is selling
var vendor:InventoryComponent
## Who is buying (Player)
var customer:InventoryComponent
## What the customer is selling
var selling:Array[String] = []
## What the customer is buying
var buying:Array[String] = []
## Balance of transaction
var balance:int


func _init(v:InventoryComponent, c:InventoryComponent) -> void:
	vendor = v
	customer = c


## Get the total amount for the transaction, in terms of change in the customer's money.
func total_transaction(selling_modifier:float, buying_modifier:float) -> int:
	var total:int = 0
	# Total selling amount and add
	total += selling.reduce(
		func(accum: int, item:String):
			return accum + roundi(( EntityManager.instance.get_entity(item)\
				.get_component("ItemComponent")\
				as ItemComponent)\
				.data\
				.worth * selling_modifier)
	,0
	)
	# Total selling amount and subtract
	total -= buying.reduce(
		func(accum: int, item:String):
			return accum + roundi(( EntityManager.instance.get_entity(item)\
				.get_component("ItemComponent")\
				as ItemComponent)\
				.data\
				.worth * buying_modifier)
	,0
	)
	return total
