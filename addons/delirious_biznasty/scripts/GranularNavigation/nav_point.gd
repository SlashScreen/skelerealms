class_name NavPoint
## Point in a world.


var position:Vector3
var world:String


static func new(w:String, pos:Vector3) -> NavPoint:
	var np = NavPoint
	np.world = w
	np.position = pos
	return np
