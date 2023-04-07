class_name Crime
## Crime is a resource used to track crimes.


## Possible crime types and their severity.
## Edit to customize the types of crimes that can be committed.
const crimes:Dictionary = {
	"assault": 2, # Beating someone up
	"theft": 1, # Stealing, pickpocketing
	"murder": 5, # Killing someone
	"tomfoolery":1 # Mischeif
}

## Type of crime. See [member crimes].
var crime_type:StringName
var perpetrator:String
var victim:String
## Sevwerity of this crime
var severity:int:
	get:
		return crimes[crime_type] if crimes.has(crime_type) else 0

func serialize() -> Dictionary:
	return {
		"crime_type":crime_type,
		"perpetrator":perpetrator,
		"victim":victim,
	}
