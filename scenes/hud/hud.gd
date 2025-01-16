extends CanvasLayer

##################################################
var score_label: Label
var time_label: Label
var fuel_label: Label

var altitude_label: Label
var horizontal_speed_label: Label
var vertical_speed_label: Label
var game_over_label: Label

##################################################
func _ready() -> void:
	score_label = \
		$HBoxContainer/LMarginContainer/HBoxContainer/RVBoxContainer/ScoreLabel
	time_label = \
		$HBoxContainer/LMarginContainer/HBoxContainer/RVBoxContainer/TimeLabel
	fuel_label = \
		$HBoxContainer/LMarginContainer/HBoxContainer/RVBoxContainer/FuelLabel
	
	altitude_label = \
		$HBoxContainer/RMarginContainer/HBoxContainer/RVBoxContainer/AltitudeLabel
	horizontal_speed_label = \
		$HBoxContainer/RMarginContainer/HBoxContainer/RVBoxContainer/HorizontalSpeedLabel
	vertical_speed_label = \
		$HBoxContainer/RMarginContainer/HBoxContainer/RVBoxContainer/VerticalSpeedLabel
	game_over_label = $GameOverLabel

##################################################
func _process(delta: float) -> void:
	update_hud()
	# ahems UI 업데이트

##################################################
func update_hud() -> void:
	score_label.text = str(GM.get_score()).pad_zeros(4)
	time_label.text = str(int(GM.get_time_left()) / 60).pad_zeros(2) + \
		":" + str(int(GM.get_time_left()) % 60).pad_zeros(2)
	# 60으로 나눈 몫은 분, 나머지는 초
	fuel_label.text = str(int(GM.get_fuel())).pad_zeros(4)
	
	altitude_label.text = str(GM.get_altitude()).pad_zeros(4)
	horizontal_speed_label.text = str(int(GM.get_horizontal_speed())).pad_zeros(3)
	vertical_speed_label.text = str(int(GM.get_vertical_speed())).pad_zeros(3)
	
	game_over_label.visible = GM.get_game_over()
