class_name Option

var data:Variant

static func from(d:Variant) -> Option:
	var op: Option = Option.new()
	op.data = d
	return op

static func none() -> Option:
	var op: Option = Option.new()
	op.data = null
	return op

func some() -> bool:
	return data != null

func unwrap() -> Variant:
	return data
