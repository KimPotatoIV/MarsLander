extends Node

##################################################
const SCREEN_SIZE: Vector2 = Vector2(1920.0, 1080.0)

var score: int = 0
var timer: Timer
var fuel: float = 1000.0

var altitude: float
# 고도
var horizontal_speed: float
# 좌우 이동량
var vertical_speed: float
# 상하 이동량
var game_over: bool = false

##################################################
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 120.0
	timer.autostart
	add_child(timer)
	timer.start()
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	# 시간 제한 타이머를 설정 후 timeout 시 _on_timer_timeout 함수에 연결

##################################################
func _process(delta: float) -> void:
	if game_over:
		timer.paused = true
	# 게임 오버 시 시간 제한 타이머 정지

##################################################
func _on_timer_timeout() -> void:
	game_over = true

##################################################
func get_score() -> int:
	return score

##################################################
func set_score(value: int) -> void:
	score = value
	
##################################################
func get_time_left() -> float:
	return timer.time_left
	
##################################################
func get_fuel() -> float:
	return fuel

##################################################
func set_fuel(value: float) -> void:
	fuel = value

##################################################
func get_altitude() -> float:
	return SCREEN_SIZE.y - int(altitude)
	# 화면 세로 크기에서 빼야 고도가 제대로 나타남
	# 고도 엔진은 2D Y축이 위에서 아래로 향하기 때문

##################################################
func set_altitude(value: float) -> void:
	altitude = value

##################################################
func get_horizontal_speed() -> float:
	return horizontal_speed

##################################################
func set_horizontal_speed(value: float) -> void:
	horizontal_speed = value

##################################################
func get_vertical_speed() -> float:
	return vertical_speed

##################################################
func set_vertical_speed(value: float) -> void:
	vertical_speed = value

##################################################
func get_game_over() -> bool:
	return game_over

##################################################
func set_game_over(value: bool) -> void:
	game_over = value
