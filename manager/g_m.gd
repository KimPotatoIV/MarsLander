extends Node

##################################################
const SCREEN_SIZE: Vector2 = Vector2(1920.0, 1080.0)

var score: int = 0
var timer: Timer
var fuel: float = 1000.0

var altitude: float
var horizontal_speed: float
var vertical_speed: float

var game_over: bool = false

##################################################
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 120.0
	timer.autostart
	add_child(timer)
	timer.start()
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

##################################################
func _process(delta: float) -> void:
	if game_over:
		timer.paused = true

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
