extends Area2D

##################################################
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	# 코인에 객체가 들어올 때마다 _on_body_entered 함수 호출 하도록 연결

##################################################
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("MarsLander"):
		GM.set_score(GM.get_score() + 100)
		self.queue_free()
	# 들어온 객체가 MarsLander 그룹이면 점수 추가 및 코인 삭제
