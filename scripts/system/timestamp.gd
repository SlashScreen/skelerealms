class_name Timestamp
extends Resource


# SO much repetitive code

@export_flags("Minute:1", "Hour:2", "Day:4", "Week:8", "Month:16", "Year:32") var compare:int = 0b00010
var use_minute:bool:
	get:
		return compare & 1 == 1
@export var minute:int
var use_hour:bool:
	get:
		return compare & 2 == 2
@export var hour:int
var use_day:bool:
	get:
		return compare & 4 == 4
@export var day:int
var use_week:bool:
	get:
		return compare & 8 == 8
@export var week:int
var use_month:bool:
	get:
		return compare & 16 == 16
@export var month:int
var use_year:bool:
	get:
		return compare & 32 == 32
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
	if use_minute and not (from.minute <= minute and minute < to.minute):
		return false
	if use_hour and not (from.hour <= hour and hour < to.hour):
		return false
	if use_day and not (from.day <= day and day < to.day):
		return false
	if use_week and not (from.week <= week and week < to.week):
		return false
	if use_month and not (from.month <= month and month < to.month):
		return false
	if use_year and not (from.year <= year and year < to.year):
		return false
	
	return true


## If timestamp is less than or equal to
func lte(to:Timestamp) -> bool:
	# if we are using the minute and the minute is less than to.minute
	# Ditto for all fields.
	if use_minute and not (minute <= to.minute):
		return false
	if use_hour and not (hour <= to.hour):
		return false
	if use_day and not (day <= to.day):
		return false
	if use_week and not (week <= to.week):
		return false
	if use_month and not ( month <= to.month):
		return false
	if use_year and not (year <= to.year):
		return false
	
	return true


## If timestamp is greater than or equal to
func gte(to:Timestamp) -> bool:
	# if we are using the minute and the minute is less than to.minute
	# Ditto for all fields.
	if use_minute and not (minute >= to.minute):
		return false
	if use_hour and not (hour >= to.hour):
		return false
	if use_day and not (day >= to.day):
		return false
	if use_week and not (week >= to.week):
		return false
	if use_month and not ( month >= to.month):
		return false
	if use_year and not (year >= to.year):
		return false
	
	return true
