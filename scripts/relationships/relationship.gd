class_name Relationship
extends Resource


@export var other_person:String
@export var level:RelationshipLevel = RelationshipLevel.ACQUAINTANCE
@export_category("Optional")
@export var relationship_type:RelationshipAssociation
@export var role:String # gotta figure out how to make it dynamic enum


## Level determining how close the two NPCs are.
enum RelationshipLevel {
	NEMESIS, ## NPC Will always engage on sight.
	ENEMY, ## Depending on combat settings, NPC may engage this level and below on sight.
	FOE, ## Dislike eachother a lot.
	RIVAL, ## Homestuck tells me these also smooch.
	ACQUAINTANCE, ## No real relationship to speak of.
	FRIEND, ## Friendly.
	BFF, ## Closer friend.
	ALLY, ## Depending on NPC behavior settings, may assist this level and above in combat.
	LOVER, ## smouch
}
