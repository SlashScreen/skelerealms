class_name QuestNode
extends Node
## This is an instance of a [Quest] within the scene.


## The quest data.
var _q_data:Quest


## Evaluate whether the quest is complete or not.
func evaluate() -> bool:
	return true
