class_name Crime
extends Resource
## Crime is a resource used to track crimes.


## Possible crime types and their severity.
## Edit to customize the types of crimes that can be committed.
## I guess I could do this in a config file (YAML?) but I dont want to do that right now.
const CRIMES:Dictionary = {
	&"assault": 2, # Beating someone up
	&"theft": 1, # Stealing, pickpocketing
	&"murder": 5, # Killing someone
	&"tomfoolery":1 # Mischeif
}

## Type of crime. See [constant CRIMES].
var crime_type:StringName
var perpetrator:String
var victim:String
## Severity of this crime
var severity:int:
	get:
		return CRIMES[crime_type] if CRIMES.has(crime_type) else 0


func _init(crime_type:StringName = &"", perpetrator:String = "", victim:String = "") -> void:
	self.crime_type = crime_type
	self.perpetrator = perpetrator
	self.victim = victim


func serialize() -> Dictionary:
	return {
		"crime_type":crime_type,
		"perpetrator":perpetrator,
		"victim":victim,
	}
