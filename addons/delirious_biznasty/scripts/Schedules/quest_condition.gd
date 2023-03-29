class_name QuestCondition
extends ScheduleCondition
## Event is only valid if a quest meets a certain criteria.

## If this is true, it tries to match a certain quest's step. If false, it matches the entire quest.
@export var quest_step:bool = false
## Step or quest ID.
@export var id:String
@export_enum("active", "completed", "not started") var status:int
