class_name ItemDataComponent
extends Resource
## Base class for item data components that describe the capabilities of an item. See [ItemData]. [br]
## Items are a special case, in that they are built up of components.
## This may seem a bit weird and convoluted, and while it is, this allows for a much more extensible and flexible system.
## For example, you could give a shoe both the "Can equip to character" component, the "Holdable" component, and the "Throwable" component,
## and that would allow the character to wear the shoe, take it off, and huck it at somebody's head.
