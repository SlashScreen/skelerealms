class_name Furniture
extends IdlePoint
## A special IdlePoint abstract class that allows for animastions to be played when occupied.
## Add an [InteractiveObject] node somewhere.
## Does not enable crafting or anything by default, but you can extend it to do that if you want.


## Animation that plays on an actor when furniture is occupied.
@export var animation:Animation

# TODO: Animate the actors
# TODO: Allow for multiple users (use sub points? allow for nested furniture?)
