extends Area2D

##################################################
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	# 드럼에 객체가 들어올 때마다 _on_body_entered 함수 호출 하도록 연결

##################################################
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("MarsLander"):
		GM.set_fuel(GM.get_fuel() + 100.0)
		self.queue_free()
	# 들어온 객체가 MarsLander 그룹이면 연료 추가 및 드럼 삭제
