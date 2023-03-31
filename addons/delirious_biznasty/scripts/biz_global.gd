extends Node
## A singleton that allows any script to access various important nodes without having to deal with scene scope.


## Reference to the [EntityManager] singleton.
var entity_manager:EntityManager
## Reference to the [QuestEngine].
var quest_engine:QuestEngine
## World states for the GOAP system.
var world_states:Dictionary

