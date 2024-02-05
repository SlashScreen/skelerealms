class_name Skelesave


const CLASS_LOOKUP = [
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
	0, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 7, 7,
	9, 10, 10, 10, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
]
const TRANSITION_LOOKUP = [
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 1, 0, 0, 0, 2, 3, 5, 4, 6, 7, 8,
	0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0
]
const ARR_DELIM = 0xFF
const NULL_DELIM = 0xFE
const VALUE_DELIM = 0xFD
const KEY_DELIM = 0xFC
const ARR_START = 0xFB


static func is_valid_utf8(bytes:PackedByteArray) -> bool:
	var last_state:int = 1
	for byte:int in bytes:
		var current_byte_class:int = CLASS_LOOKUP[byte]
		var new_lookup_index:int = last_state * 12 + current_byte_class
		last_state = TRANSITION_LOOKUP[new_lookup_index]
		if last_state == 0:
			return false
	return last_state == 1


static func serialize(data:Dictionary) -> PackedByteArray:
	var output:PackedByteArray = PackedByteArray()
	for d:Variant in data:
		output.append_array(_stringify_value(d))
		output.append(KEY_DELIM)
		output.append_array(_stringify_value(data[d]))
		output.append(VALUE_DELIM)
	return output


static func _stringify_value(data:Variant) -> PackedByteArray:
	if data == null:
		return PackedByteArray([NULL_DELIM])
	elif data is Dictionary:
		return serialize(data)
	elif data is bool:
		return ("true" if data else "false").to_utf8_buffer()
	elif data is int:
		return ("%d" % data).to_utf8_buffer()
	elif data is float:
		return ("%f" % data).to_utf8_buffer()
	elif data is Array:
		var output:PackedByteArray = PackedByteArray()
		for i:Variant in data:
			output.append_array(_stringify_value(i))
			output.append(ARR_DELIM)
		return output
	else:
		return (data as Object).to_string().to_utf8_buffer()


static func deserialize(data:PackedByteArray) -> Dictionary:
	var output:Dictionary = {}
	var pos:int = 0
	var current_phrase:PackedByteArray = PackedByteArray()
	var current_array:Array = []
	var current_key:String = ""
	var current_value:Variant = null

	while pos < data.size():
		match data[pos]:
			KEY_DELIM:
				current_key = current_phrase.get_string_from_utf8()
				current_phrase.clear()
			VALUE_DELIM:
				current_value = _decode_value(current_phrase)
				current_phrase.clear()
			_:
				current_phrase.append(data[pos])
	return output


static func _decode_value(data:PackedByteArray) -> Variant:
	if data[0] == NULL_DELIM:
		return null
	if data.has(KEY_DELIM):
		return deserialize(data)
	if data.has(ARR_DELIM):
		var output = []
		var current_member:PackedByteArray = PackedByteArray()
		# TODO: array
		for i:int in range(data.size()):
			match data[i]:
				ARR_DELIM:
					output.append(_decode_value(current_member))
					current_member.clear()
				_:
					current_member.append(data[i])
		return output # TODO
	var stringified:String = data.get_string_from_utf8()
	if stringified == "true":
		return true
	if stringified == "false":
		return false
	if stringified.is_valid_int():
		return stringified.to_int()
	if stringified.is_valid_float():
		return stringified.to_float()
	return stringified
