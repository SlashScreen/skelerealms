class_name QuestCondition
extends ScheduleCondition
## Event is only valid if a quest meets a certain criteria.

## If this is true, it tries to match a certain quest's step. If false, it matches the entire quest.
@export var quest_step:bool = false
## Step or quest ID. Step must be in format QuestID/StepID.
@export var id:String
## Check if the quest is...
@export_enum("active", "completed", "not started") var status:int


func evaluate() -> bool:
	match status:
		0:
			return SkeleRealmsGlobal.quest_engine.is_step_in_progress(id) if quest_step else SkeleRealmsGlobal.quest_engine.is_quest_active(id)
		1:
			return SkeleRealmsGlobal.quest_engine.is_step_complete(id) if quest_step else SkeleRealmsGlobal.quest_engine.is_quest_complete(id)
		2:
			return not (SkeleRealmsGlobal.quest_engine.is_step_complete(id) and SkeleRealmsGlobal.quest_engine.is_step_in_progress(id)) if quest_step else not SkeleRealmsGlobal.quest_engine.is_quest_started(id)
	return false
