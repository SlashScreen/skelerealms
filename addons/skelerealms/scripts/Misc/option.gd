class_name Option
## A crude implementation of an option/maybe type.
## May get rid of this, because it adds complexity to replicate features that nullability kind of already does...


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


## Wrap any value as an option. If it's null, it's none.
static func wrap(data:Variant) -> Option:
	if data:
		return from(data)
	else:
		return none()


## Whether it has something in it.
func some() -> bool:
	return _data != null


## Get the data from within. May be null.
func unwrap() -> Variant:
	return _data


## Call a function on this option if it contains a value. The argument is the unwrapped contents. 
func bind(fn:Callable) -> Variant:
	if some():
		return fn.call(unwrap())
	else:
		return null
