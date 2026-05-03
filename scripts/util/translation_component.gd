extends Node

## Pass the name of the properties to translate
@export var translatable_properties : Array[String]

func _ready() -> void:
	for tp in translatable_properties:
		if tp:
			# Get the value from the passed property
			var current_value = get(tp)
			
			# Verify input is a string
			if typeof(current_value) == TYPE_STRING:            
				# Translate from dictionary
				set(tp, GameManager.LanguageDirectory.translate(get(tp)))
