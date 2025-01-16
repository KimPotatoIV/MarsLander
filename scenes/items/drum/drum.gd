extends Area2D

##################################################
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

##################################################
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("MarsLander"):
		GM.set_fuel(GM.get_fuel() + 100.0)
		self.queue_free()
