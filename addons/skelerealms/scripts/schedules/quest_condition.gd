class_name QuestCondition
extends ScheduleCondition
## Event is only valid if a quest meets a certain criteria.


## Step or quest ID. Step must be in format QuestID/StepID.
@export var id:String
## Check if the quest is...
@export_enum("active", "completed", "not started") var status:int


func evaluate() -> bool:
	match status:
		0:
			return SkeleRealmsGlobal.quest_engine.is_member_active(id)
		1:
			return SkeleRealmsGlobal.quest_engine.is_member_complete(id)
		2:
			return not (SkeleRealmsGlobal.quest_engine.has_member_been_started(id))
	return false
