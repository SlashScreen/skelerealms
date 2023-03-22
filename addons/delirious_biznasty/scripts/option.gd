class_name Option
## A crude implementation of an option/maybe type.

var _data:Variant

## Make a new option containing data.
static func from(d:Variant) -> Option:
	var op: Option = Option.new()
	op._data = d
	return op

## Make a new Option containing nothing.
static func none() -> Option:
	var op: Option = Option.new()
	op._data = null
	return op

## Whether it has something in it.
func some() -> bool:
	return _data != null

## Get the data from within. May be null.
func unwrap() -> Variant:
	return _data
