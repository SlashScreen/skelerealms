class_name Timestamp
extends Resource


# SO much repetitive code

@export var use_minute:bool = false
@export var minute:int
@export var use_hour:bool = true
@export var hour:int
@export var use_day:bool = false
@export var day:int
@export var use_week:bool = false
@export var week:int
@export var use_month:bool = false
@export var month:int
@export var use_year:bool = false
@export var year:int


static func build_from_world_timestamp() -> Timestamp:
	var stamp:Timestamp = Timestamp.new()
	
	# Set using
	stamp.use_minute = true
	stamp.use_hour = true
	stamp.use_day = true
	stamp.use_week = true
	stamp.use_month = true
	stamp.use_year = true
	
	# Set times
	stamp.minute = GameInfo.minute
	stamp.hour = GameInfo.hour
	stamp.day = GameInfo.day
	stamp.week = GameInfo.week
	stamp.month = GameInfo.month
	stamp.year = GameInfo.year
	
	return stamp

func is_in_between(from:Timestamp, to:Timestamp) -> bool:
	# if we are using the minute and the minute is not between the other two.
	# Ditto for all fields.
	if use_minute and not (from.minute < minute and minute <= to.minute):
		return false
	if use_hour and not (from.hour < hour and hour <= to.hour):
		return false
	if use_day and not (from.day < day and day <= to.day):
		return false
	if use_week and not (from.week < week and week <= to.week):
		return false
	if use_month and not (from.month < month and month <= to.month):
		return false
	if use_year and not (from.year < year and year <= to.year):
		return false
	
	return true
