@tool
extends Object


var start: float
var end: float 
var size:
	get:
		return end - start


func overlaps(other: Object) -> bool: 
	return contains_point(other.start) or contains_point(other.end) or encloses(other) or other.encloses(self)


func contains_point(pt:float) -> bool:
	return start <= pt and pt <= end


func encloses(other: Object) -> bool:
	return start <= other.start and end >= other.end


func sync(r:Rect2) -> void:
	start = r.position.x
	end = r.end.x


func _init(r:Rect2):
	sync(r)
