extends Node
## OBEY THE CRIME MASTER[br]
## This keeps track of any crimes committed against various [Coven]s. 


## Bounty amounts for various crime severity levels.
const bounty_amount:Dictionary = {
	0 : 0,
	1 : 500,
	2 : 10000,
	5 : 100000,
}


## Tracked crimes.
## [codeblock]
## {
##		coven: {
##			"punished" : []
##			"unpunished": []
##		}
## }
## [/codeblock]
var crimes:Dictionary = {}


## Move all unpunished crimes to punished crimes.
func punish_crimes(coven:StringName):
	crimes[coven]["punished"].append(crimes[coven]["unpunished"])
	crimes[coven]["unpunished"].clear


# TODO: Track crimes against others?
## Add a crime to the record
func add_crime(crime:Crime):
	# add crime to covens
	var cc = SkeleRealmsGlobal.entity_manager.get_entity(crime.victim).unwrap().get_component("CovensComponent")
	if cc.some():
		for coven in (cc.unwrap() as CovensComponent).covens:
			## Skip if doesn't track crime
			if not CovenSystem.get_coven(coven).track_crime:
				continue
			
			if crimes.has(coven):
				crimes[coven]["unpunished"].append(crime)
			else: # if coven doesnt have crimes against it, initialize table
				crimes[coven] = {
					"punished" : [],
					"unpunished" : [crime]
				}


## Returns the max wanted level for crimes against a Coven.
func max_crime_severity(id:StringName, coven:StringName) -> int:
	if not crimes.has(coven):
		return 0
	var cr = crimes[coven]["unpunished"]\
		.filter(func(x:Crime): return x.perpetrator == id)\
		.map(func(x:Crime): return x.severity)
	return 0 if cr.is_empty() else cr.max()


## Calculate the bounty a Coven has for an entity.
func bounty_for_coven(id:StringName, coven:StringName) -> int:
	if not crimes.has(coven):
		return 0
	return crimes[coven]["unpunished"]\
		.filter(func(x:Crime): return x.perpetrator == id)\
		.reduce(func(sum:int, x:Crime): return sum + bounty_amount[x.severity], 0)
