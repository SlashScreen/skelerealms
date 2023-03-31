class_name VitalsComponent
extends EntityComponent
## Component keeping check of the main 3 attributes of an entity - health, stamina, and magica.


## Called when this entity's health reaches 0. See [member health].
signal dies
## Called when the stamina value reaches 0. See [member moxie].
signal exhausted
## Called when the magica value reaches 0. See [member will].
signal drained

signal hurt


## Health value.
var health:float
## Stamina value.
var moxie:float
## Magica value
var will:float
## The maximum health value.
var max_health:float
## The maximum stamina value.
var max_moxie:float
## The maximum magica value.
var max_will:float
## Whether this entity is dead.
var is_dead:bool
## Whether this agent is exhausted.
var is_exhausted:bool
## Whether this agent is drained.
var is_drained:bool
