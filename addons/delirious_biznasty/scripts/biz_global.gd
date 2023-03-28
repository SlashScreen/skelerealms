extends Node
## A singleton that allows any script to access various important nodes without having to deal with scene scope.


## Reference to the [EntityManager] singleton.
var entity_manager:EntityManager
## Reference to the [GameInfo] singleton.
var game_info:GameInfo
## World states for the GOAP system.
var world_states:Dictionary
