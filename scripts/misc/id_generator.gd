@tool
class_name SKIDGenerator
extends RefCounted


const CHARACTERS: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"


static func generate_id(length:int = 10) -> String:
	var output := ""
	
	for _i:int in length:
		output += CHARACTERS[randi_range(0, CHARACTERS.length() - 1)]
	
	return output
