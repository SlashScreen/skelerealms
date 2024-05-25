@tool
extends PanelContainer


const TRACK_COUNT = 3
const Span = preload("span.gd")
const BOX_CONTROL = preload("schedule_box_control.tscn")
const SNAP_DIST = 12

@onready var timeline:Control = $ScrollContainer/HBoxContainer
var scroll_value:int
var tracks:Array[Dictionary] = [] # Dictionaries are Control:Span
var track_index:Dictionary = {}
var timeline_width:int
var editing:Array[ScheduleEvent]

signal update_event_array(arr:Array[ScheduleEvent])


func _ready() -> void:
	tracks.resize(3)
	for i:int in range(TRACK_COUNT):
		tracks[i] = {}
	timeline_width = timeline.size.x
	var op:OptionButton = $VBoxContainer/HBoxContainer/OptionButton
	op.clear()
	var inherited:Array = find_classes_that_inherit(&"ScheduleEvent")
	for d:Dictionary in inherited:
		op.add_item(d.class)
		op.set_item_metadata(op.item_count - 1, d.path)
	$VBoxContainer/HBoxContainer/Button.pressed.connect(func() -> void:
		var n:ScheduleEvent = load(op.get_selected_metadata()).new()
		n.from = Timestamp.new()
		n.to = Timestamp.new()
		editing.append(n)
		add_box(n)
		update_event_array.emit(editing)
		)


func _process(_delta: float) -> void:
	scroll_value = timeline.position.x
	_update_tracks()


func _update_tracks() -> void:
	_update_boxes()
	_squash()
	_promote()


func _update_boxes() -> void:
	var boxes:Array = %Container.get_children().map(func(n:Node) -> Control: return n.get_child(0))
	for b:Control in boxes:
		if track_index.has(b):
			tracks[track_index[b]][b].sync(b.get_global_rect())
		else:
			tracks[0][b] = Span.new(b.get_global_rect())
			track_index[b] = 0
			b.switch_track(0)
	# Cleanup
	for b:Control in track_index:
		if not boxes.has(b) or b == null:
			tracks[track_index[b]].erase(b)
			track_index.erase(b)


func _squash() -> void:
	# stupid way of doing it but i think it will be ok?
	# For every track, check against items on bottom track. If no collisions, move it downwards
	# TODO: Handle Overlaps on bottom level?
	var did_move:int
	for track in range(tracks.size() - 1, 0, -1):
		var cd:Dictionary = tracks[track]
		var bd:Dictionary = tracks[track - 1]
		var to_move:Array = []
		var bdkeys:Array = bd.keys()
		bdkeys.sort_custom(func(a:Control, b:Control) -> bool: 
			return bd[a].center > bd[b].center
			)
		for event in cd:
			var valid:bool = true
			
			for obstacle in bdkeys:
				# if any obstacle on track below blocks this, stop looking
				if cd[event].overlaps(bd[obstacle]):
					valid = false
					break
			if valid:
				to_move.append(event)
		# Finalize movement
		for e in to_move:
			e.switch_track(track - 1)
			track_index[e] = track - 1
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
		var cdkeys:Array = cd.keys()
		cdkeys.sort_custom(func(a:Control, b:Control) -> bool: 
			return cd[a].center > cd[b].center
			)
		for event in cdkeys:
			var valid:bool = false
			
			for obstacle in cdkeys:
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
			e.switch_track(track + 1)
			track_index[e] = track + 1 
			ad[e] = cd[e]
			cd.erase(e)
		did_move = max(did_move, to_move.size())
	
	if did_move > 0:
		_promote()


func get_time_from_position(pos:int) -> Dictionary:
	var minute:int = ((pos % timeline.HOUR_SEPARATION) / (timeline.HOUR_SEPARATION as float)) * ProjectSettings.get_setting("skelerealms/minutes_per_hour")
	var hour:int =  floori(pos / (timeline.HOUR_SEPARATION as float))
	return {
		&"hour": hour,
		&"minute": minute
	}


func position_from_time(d:Dictionary) -> int:
	var i:int = d.hour * timeline.HOUR_SEPARATION
	i += floori((d.minute / (ProjectSettings.get_setting("skelerealms/minutes_per_hour") as float)) * timeline.HOUR_SEPARATION)
	return i


func snap_to_minute(pos:int) -> int:
	var fac:int = timeline.size.x / (ProjectSettings.get_setting("skelerealms/minutes_per_hour") * ProjectSettings.get_setting("skelerealms/hours_per_day"))
	return pos


func snap_to_hour(pos:int) -> int:
	var nearest_hour:int = roundi(pos / timeline.HOUR_SEPARATION) * timeline.HOUR_SEPARATION
	var dist:int = abs(nearest_hour - pos)
	if dist <= SNAP_DIST:
		return nearest_hour
	else:
		return pos


func edit(s:Array[ScheduleEvent]) -> void:
	editing = s
	for c:Node in %Container.get_children():
		c.queue_free()
	for e:ScheduleEvent in s:
		add_box(e)


func add_box(e:ScheduleEvent) -> void:
	var b:Control = BOX_CONTROL.instantiate()
	b.get_child(0).delete_requested.connect(func() -> void:
		tracks[track_index[b.get_child(0)]].erase(b.get_child(0))
		track_index.erase(b.get_child(0))
		editing.remove_at(editing.find(e))
		update_event_array.emit(editing)
		b.queue_free()
		)
	%Container.add_child(b)
	b.get_child(0).edit(e, self)


static func find_classes_that_inherit(what:StringName) -> Array:
	return ProjectSettings.get_global_class_list()\
		.filter(func(d:Dictionary)->bool: return d.base == what)
