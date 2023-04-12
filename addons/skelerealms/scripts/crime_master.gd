extends Node
## OBEY THE CRIME MASTER
# TODO: Integrate better with Coven system


const bounty_amount:Dictionary = {
	0 : 0,
	1 : 500,
	2 : 10000,
	5 : 100000,
}


# TODO: keep track of crimes against covens
## Region: String : Crimes: Array[Crime] 
var crimes:Dictionary = {}


## Wipe the records for a region. Used when the player has served time.
func wipe_record(region:String):
	crimes[region] = []


## Add a crime to the record
func add_crime(region:String, crime:Crime):
	if crimes.has(region):
		crimes[region].append(crime)
	else:
		crimes[region] = [crime]


## Returns the max wanted level for crimes in a region.
func max_crime_severity(region:String) -> int:
	if not crimes.has(region):
		return 0
	return max(crimes[region].map(func(x:Crime): return x.severity))


## Calculate the bounty for a region.
func bounty_for_region(region:String) -> int:
	if not crimes.has(region):
		return 0
	return crimes[region].reduce(func(sum:int, x:Crime): return sum + bounty_amount[x.severity], 0)
