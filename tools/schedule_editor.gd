@tool
extends PanelContainer


@onready var timeline:Control = $ScrollContainer/HBoxContainer
var scroll_value:int
var tracks:Array[Dictionary] = [] # Dictionaries are Control:Span


func _process(_delta: float) -> void:
	scroll_value = timeline.position.x


func _update_tracks() -> void:
	_squash()
	_promote()


func _squash() -> void:
	# stupid way of doing it but i think it will be ok?
	# For every track, check against items on bottom track. If no collisions, move it downwards
	# TODO: Handle Overlaps on bottom level?
	var did_move:int
	for track in range(tracks.size(), 1, -1):
		var cd:Dictionary = tracks[track]
		var bd:Dictionary = tracks[track - 1]
		var to_move:Array = []
		for event in cd:
			var valid:bool = true
			for obstacle in bd:
				# if any obstacle on track below blocks this, stop looking
				if cd[event].overlaps(bd[obstacle]):
					valid = false
					break
			if valid:
				to_move.append(event)
		# Finalize movement
		for e in to_move:
			cd[e].switch_track(track - 1)
			bd[e] = cd[e]
			cd.erase(e)
		did_move = max(did_move, to_move.size())
	# If we moved any, squash again. If not, then we are done quashing
	if did_move > 0:
		_squash()


func _promote() -> void:
	# and "least efficient algorithm" award goes to...
	# For every item in each track, check against other items in track to see if it needs to move
	# If it collides with anything, move it. 
	# TODO: Handle overlaps on top level
	var did_move:int
	for track in range(tracks.size() - 1):
		var cd:Dictionary = tracks[track]
		var ad:Dictionary = tracks[track + 1]
		var to_move:Array = []
		for event in cd:
			var valid:bool = false
			for obstacle in cd:
				if obstacle == event:
					continue
				if to_move.has(obstacle): # ignore ones we are already moving
					continue
				# if any overlap, we will move upwards
				if cd[event].overlaps(cd[obstacle]):
					valid = true
					break
			if valid:
				to_move.append(event)
		# Finalize movement
		for e in to_move:
			cd[e].switch_track(track + 1)
			ad[e] = cd[e]
			cd.erase(e)
		did_move = max(did_move, to_move.size())
	
	if did_move > 0:
		_promote()


class Span:
	extends Object
	
	
	var start: float
	var end: float 
	var size:
		get:
			return end - start
	
	
	func overlaps(other: Span) -> bool: 
		return contains_point(other.start) or contains_point(other.end) or encloses(other) or other.encloses(self)
	
	
	func contains_point(pt:float) -> bool:
		return start <= pt and pt <= end
	
	
	func encloses(other: Span) -> bool:
		return start <= other.start and end >= other.end
	
	
	func _init(r:Rect2):
		start = r.position.x
		end = r.end.x
