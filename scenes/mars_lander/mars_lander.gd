extends CharacterBody2D

##################################################
enum LANDER_STATE
{
	IDLE,
	THRUST,
	TURN_LEFT,
	TURN_RIGHT,
	EXPLOSION
}

##################################################
const GRAVITY: Vector2 = Vector2(0, 37.3 / 4)
const THRUST: float = 37.3 * 3 / 4
const ROTATION_SPEED: float = 1.0
const FUEL_RATE: float = 10.0

var state: LANDER_STATE = LANDER_STATE.IDLE
var state_animation: AnimatedSprite2D

var horizontal_speed_for_check: float = 0.0
var vertical_speed_for_check: float = 0.0

var score_timer: Timer

var thrust_audio
var turn_audio
var explosion_audio

##################################################
func _ready() -> void:
	state_animation = $AnimatedSprite2D
	
	add_to_group("MarsLander")
	
	score_timer = Timer.new()
	score_timer.wait_time = 1.0
	score_timer.autostart
	add_child(score_timer)
	score_timer.start()
	score_timer.connect("timeout", Callable(self, "_on_score_timer_timeout"))
	
	thrust_audio = $ThrustAudioStreamPlayer
	turn_audio = $TurnAudioStreamPlayer
	explosion_audio = $ExplosionAudioStreamPlayer

##################################################
func _physics_process(delta: float) -> void:
	velocity += GRAVITY * delta
	
	check_landing()
	
	if GM.get_game_over():
		score_timer.paused = true
		velocity = Vector2(0,0)
		return
	
	if Input.is_action_pressed("ui_up"):
		thrust(delta)
	elif Input.is_action_just_released("ui_up"):
		if thrust_audio.playing:
			thrust_audio.stop()
	elif Input.is_action_pressed("ui_left"):
		turn(true, delta)
	elif Input.is_action_pressed("ui_right"):
		turn(false, delta)
	elif Input.is_action_just_released("ui_left") or \
		Input.is_action_just_released("ui_right"):
		if turn_audio.playing:
			turn_audio.stop()
	else:
		set_state(LANDER_STATE.IDLE)

	move_and_slide()

##################################################
func _process(delta: float) -> void:
	GM.set_altitude(global_position.y)
	GM.set_horizontal_speed(velocity.x)
	GM.set_vertical_speed(velocity.y)

##################################################
func check_landing() -> void:
	if is_on_floor() or is_on_wall():
		if horizontal_speed_for_check > 3.0 or vertical_speed_for_check > 10.0:
			if GM.get_game_over() == false:
				GM.set_game_over(true)
				set_state(LANDER_STATE.EXPLOSION)
	else:
		horizontal_speed_for_check = GM.get_horizontal_speed()
		vertical_speed_for_check = GM.get_vertical_speed()

##################################################
func thrust(delta: float) -> void:
	velocity += Vector2.UP.rotated(rotation).normalized() * THRUST * delta
	GM.set_fuel(GM.get_fuel() - delta * FUEL_RATE)
	set_state(LANDER_STATE.THRUST)

##################################################
func turn(is_left: bool, delta: float) -> void:
	if is_on_floor():
		return
	
	if is_left:
		rotation -= ROTATION_SPEED * delta
		set_state(LANDER_STATE.TURN_LEFT)
	else:
		rotation += ROTATION_SPEED * delta
		set_state(LANDER_STATE.TURN_RIGHT)
		
	rotation = clamp(rotation, -PI / 2, PI / 2)
	
	if rotation <= -PI / 2 or rotation >= PI / 2:
		return
	else:
		GM.set_fuel(GM.get_fuel() - delta * FUEL_RATE)

##################################################
func set_state(state_value: LANDER_STATE) -> void:
	if state_value == LANDER_STATE.IDLE:
		state_animation.play("idle")
	elif state_value == LANDER_STATE.THRUST:
		state_animation.play("thrust")
		if not thrust_audio.playing:
			thrust_audio.play()
	elif state_value == LANDER_STATE.TURN_LEFT:
		state_animation.play("turn_left")
		if not turn_audio.playing:
			turn_audio.play()
	elif state_value == LANDER_STATE.TURN_RIGHT:
		state_animation.play("turn_right")
		if not turn_audio.playing:
			turn_audio.play()
	elif state_value == LANDER_STATE.EXPLOSION:
		state_animation.play("explosion")
		if thrust_audio.playing:
			thrust_audio.stop()
		if turn_audio.playing:
			turn_audio.stop()
			
		if not explosion_audio.playing:
			explosion_audio.play()

##################################################
func _on_score_timer_timeout() -> void:
	GM.set_score(GM.get_score() + 1)
