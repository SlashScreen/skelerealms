class_name BarterSystem
extends Node


var current_transaction:Transaction

## Emitted when the barter process begins
signal begun_barter(vendor:InventoryComponent, customer:InventoryComponent, tx:Transaction)
## Emitted when the barter process is ended - cancelled or accepted.
signal ended_barter
## Emitted when the barter is cancelled. Note that `ended_barter` is also called when this happens.
signal cancelled_barter


## Begin the barter process.
func start_barter(vendor:InventoryComponent, customer:InventoryComponent) -> void:
	current_transaction = Transaction.new(vendor, customer)
	begun_barter.emit(vendor, customer, current_transaction)


# TODO: Allow for checking what items can and cannot be sold to this vendor
# TODO: Allow haggling?
## Sell or cancel buying an item. Returns whether it succeeded.
## Will return false if the item cannot be sold, or is cancelling a buy.
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
## Will return false if the item cannot be bought, or is cancelling a sell.
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


## Cancel the current barter session if applicable.
func cancel_barter() -> void:
	if current_transaction:
		current_transaction = null
		ended_barter.emit()
		cancelled_barter.emit()


## Resolve the transaction, and stop the trandaction. The arguments are multipliers for the money being moved around - for vendor to customer, and customer to vendor, respectively.
## Will return false if either part doesn't have enough money to complete the transaction.
func accept_barter(selling_modifier:float, buying_modifier:float, currency: StringName) -> bool:
	if not current_transaction:
		return false

	var total: int = current_transaction.total_transaction(selling_modifier, buying_modifier)
	# Adding and subtracting is done here because the total is how much money is leaving the customer
	# If vendor cash is less than 0 when the balance is applied, return failure
	if current_transaction.vendor.currencies[currency] - total < 0: # subtracting because if selling the total will be positive flow to customer
		return false
	# If customer cash is less than 0 when the balance is applied, return failure
	if current_transaction.customer.currencies[currency] + total < 0: # plus because if buying the total will be negative flow to customer
		return false

	# Add total
	current_transaction.vendor.remove_money(total, currency)
	current_transaction.customer.add_money(total, currency)

	# Move items
	#? Could optimize
	for item in current_transaction.selling:
		# Move from customer to vendor.
		SKEntityManager.instance\
			.get_entity(item)\
			.get_component("ItemComponent")\
			.move_to_inventory(current_transaction.vendor.parent_entity.name)
	for item in current_transaction.buying:
		# Move from vendor to customer.
		SKEntityManager.instance\
			.get_entity(item)\
			.get_component("ItemComponent")\
			.move_to_inventory(current_transaction.customer.parent_entity.name)

	#clean up
	current_transaction = null
	ended_barter.emit()
	return true


## Determine whether a shop will accept an item or not.
## NOTE: Broken right now.
func shop_will_accept_item(shop:Resource, item:StringName) -> bool:
	var ic:ItemComponent = SKEntityManager.instance.get_entity(item).get_component("ItemComponent")
	
	if not shop.whitelist.is_empty():
		if not ic.data.tags.any(func(tag): return shop.whitelist.has(tag)): # if no tags in whitelist
			return false
	
	if not shop.blacklist.is_empty():
		if ic.data.tags.any(func(tag): return shop.blacklist.has(tag)): # if any tag in blacklist
			return false
	
	if not shop.accept_stolen and ic.stolen: # if item stolen and vendor accepts no stolen
		return false
	
	return true
