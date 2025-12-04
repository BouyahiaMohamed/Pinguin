extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.scale.x = get_viewport().size.x * 0.0007
