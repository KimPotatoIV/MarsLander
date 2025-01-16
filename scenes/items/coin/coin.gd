extends Area2D

##################################################
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

##################################################
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("MarsLander"):
		GM.set_score(GM.get_score() + 100)
		self.queue_free()
