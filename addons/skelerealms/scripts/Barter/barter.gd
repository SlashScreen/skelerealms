class_name BarterSystem
extends Node


var current_transaction:Transaction

signal begun_barter(vendor:InventoryComponent, customer:InventoryComponent, tx:Transaction)
signal end_barter


# Begin shopping
func start_barter(vendor:InventoryComponent, customer:InventoryComponent) -> void:
	current_transaction = Transaction.new(vendor, customer)
	begun_barter.emit(vendor, customer, current_transaction)


# TODO: Allow for checking what items can and cannot be sold to this vendor
# TODO: Allow haggling?
## Sell or cancel buying an item. Returns whether it succeeded.
func sell_item(item:String) -> bool:
	# Skip if no transaction
	if not current_transaction:
		return false
	# can't sell if already selling item
	if current_transaction.selling.has(item):
		return false
	# Cancel buying
	if current_transaction.buying.has(item):
		current_transaction.buying.erase(item)
		return true
	# Else, add to selling
	current_transaction.selling.append(item)
	return true


## Buy or cancel selling an item. Returns whether it succeeded.
func buy_item(item:String) -> bool:
	# Skip if no transaction
	if not current_transaction:
		return false
	# can't sell if already buying item
	if current_transaction.buying.has(item):
		return false
	# Cancel selling
	if current_transaction.selling.has(item):
		current_transaction.selling.erase(item)
		return true
	# Else, add to buying
	current_transaction.buying.append(item)
	return true


func cancel_barter() -> void:
	current_transaction = null
	end_barter.emit()


func accept_barter(selling_modifier:float, buying_modifier:float) -> bool:
	if not current_transaction:
		return false
	
	var total: int = current_transaction.total_transaction(selling_modifier, buying_modifier)
	# Adding and subtracting is done here because the total is how much money is leaving the customer
	# If vendor cash is less than 0 when the balance is applied, return failure
	if current_transaction.vendor.snails - total < 0: # subtracting because if selling the total will be positive flow to customer
		return false
	# If customer cash is less than 0 when the balance is applied, return failure
	if current_transaction.customer.snails + total < 0: # plus because if buying the total will be negative flow to customer
		return false
	
	# Add total
	current_transaction.vendor.remove_snails(total)
	current_transaction.customer.add_snails(total)

	# Move items
	#? Could optimize
	for item in current_transaction.selling:
		# Move from seller to vendor.
		SkeleRealmsGlobal.entity_manager\
			.get_entity(item)\
			.unwrap()\
			.get_component("ItemComponent")\
			.unwrap()\
			.move_to_inventory(current_transaction.vendor.parent_entity.name)
	for item in current_transaction.buying:
		# Move from vendor to seller.
		SkeleRealmsGlobal.entity_manager\
			.get_entity(item)\
			.unwrap()\
			.get_component("ItemComponent")\
			.unwrap()\
			.move_to_inventory(current_transaction.customer.parent_entity.name)

	#clean up
	current_transaction = null
	end_barter.emit()
	return true
