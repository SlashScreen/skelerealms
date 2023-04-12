class_name Coven
extends Resource
## Analagous to a Faction in creation kit games, where a Coven is a group of Entities that behave a certain way.
## Entities must have a [CovensComponent] to be a part of a coven.
## Entities are automatically added to a group with the coven's ID when they are a part of a coven, so to get all entities part of a coven, you can get all of group.
## Unlike Creation Kit, Entties are assigned to a coven on the Entity side- the Coven jsut holds information.
## To give them a default response to the player, create a "Player" coven, and give them a default reactio nto that.


@export_category("Information")
## ID for this coven. Also used as a key in translations. See [member coven_name].
@export var coven_id:StringName
## The opinion this coven has of other covens. The dictionary shopuld be of StringName:int.
@export var other_coven_opinions:Dictionary
## Whether the player should see this in the menu if they are a part of the coven.
@export var hidden_from_player:bool
## The ranks of this coven. Shape is int:String, where key is the rank, and value is the translation key for the rank.
@export var ranks:Dictionary
@export_category("Crime")
## Whether members of this coven ignore crimes perpetrated to other members.
@export var ignore_crimes_against_others:bool
## Whether members care abourt crimes done against their own members.
@export var ignore_crimes_against_members:bool
## Whether this coven remembers crimes done against it.
@export var track_crime:bool


## Translated coven name.
var coven_name:String:
	get:
		return tr(coven_id)


## Get the translated name of a rank.
func rank_name(rank:int) -> String:
	return tr(ranks[rank]) if ranks.has(rank) else ""
