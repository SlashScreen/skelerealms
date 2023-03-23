class_name QuestEngine
extends Node
## This keeps track of all of the quests.
## Quests will be instantiated as [QuestObject]s underneath this node.


## Array of IDs of all the quests that are currently active.
var active_quests: Array[String]
## Array of IDs of all the quests the player has completed.
var complete_quests:Array[String]


## Loads all quests from the [code]biznasty/quests_directory[/code] project setting, and then instantiates them as child [QuestObject]s.
func load_quest_objects():
	pass


## Checks whether a quest is currently active.
func is_quest_active(qID:String) -> bool:
	return active_quests.has(qID)


## Checks whether a quest has been complete.
func is_quest_complete(qID:String) -> bool:
	return complete_quests.has(qID)


## Checks whether a quest has been started, meaning it is either currently in progress, or already complete.
## Inverting this can check if the quest hasn't been started by the player.
func is_quest_started(qID:String) -> bool:
	return is_quest_active(qID) or is_quest_complete(qID)
