class_name DefaultCrimeReportModule
extends AIModule


func _ready() -> void:
	CrimeMaster.crime_committed.connect(react.bind())


## React to a committed crime. If the perpetrator can be seen, the crime will be reported. 
func react(crime:Crime, pos:Vector3) -> void:
	if _npc.can_see_entity(crime.perpetrator):
		# TODO: take in whether they report crimes against other covens. 
		# TODO: Try aggress
		_npc.printe("Witnessed crime.")
		CrimeMaster.add_crime(crime, _npc.parent_entity.name)
		_npc.crime_witnessed.emit()


func get_type() -> String:
	return "DefaultCrimeReportModule"
