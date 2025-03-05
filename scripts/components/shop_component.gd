class_name ShopComponent
extends ChestComponent
## Component that handles merchant inventory and trading behavior.
## Extends ChestComponent to add merchant-specific features like haggling and item restrictions.

## Base value of how much (from 0-1) of the total price that the merchant will tollerate haggling.
@export var haggle_tolerance:float  ## Percentage (0-1) of price reduction the merchant will accept through haggling
## Only items with at least one of these tags can be sold to this vendor.
@export var whitelist:Array[StringName] = []  ## Tags that determine which items can be sold to this merchant
## No items with at least one of these tags can be sold to this vendor. Supercedes [member whitelist].
@export var blacklist:Array[StringName] = []  ## Tags that prevent items from being sold to this merchant (overrides whitelist)
## Whether this merchant accepts stolen goods.
@export var accept_stolen:bool  ## Whether the merchant will buy stolen goods
