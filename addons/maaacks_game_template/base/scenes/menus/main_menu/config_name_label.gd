@tool
extends Label
class_name ConfigNameLabel
## Displays the value of `application/config/name`, set in project settings.

const NO_NAME_STRING : String = "Title"

@export var auto_update : bool = true

func update_name_label():
	text = "Roll & Grow"

func _ready():
	if auto_update:
		update_name_label()
