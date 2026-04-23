class_name Game_Settings

## GENERAL
var LANGUAGE : int = Language.EN

## CONTROLS
# (min, max) -> Controls the range over which walk stick strength actually varies
# i.e. at default (0.2, 0.7), player has no horizontal movement below 0.2
# and moves at full speed about 0.7
var WALK_DEADZONE : float = 0.2


func on_ready():
	## TODO Load data including language from saved settings.
	pass
