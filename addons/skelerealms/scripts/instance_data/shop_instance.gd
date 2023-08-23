class_name ShopInstance
extends ChestInstance


## Base value of how much (from 0-1) of the total price that the merchant will tollerate haggling.
@export var haggle_tolerance:float
## Only items with at least one of these tags can be sold to this vendor.
@export var whitelist:Array[StringName] = []
## No items with at least one of these tags can be sold to this vendor. Supercedes [member whitelist].
@export var blacklist:Array[StringName] = []
## Whether this merchant accepts stolen goods.
@export var accept_stolen:bool
