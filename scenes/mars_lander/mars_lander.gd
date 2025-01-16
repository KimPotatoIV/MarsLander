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
# 착륙선 상태 관리를 위한 열거형 정의

##################################################
const GRAVITY: Vector2 = Vector2(0, 37.3 / 4)
# 실제 화성 중력에 비례하여 계산
const THRUST: float = 37.3 * 3 / 4
# 추력
const ROTATION_SPEED: float = 1.0
# 회전 속도
const FUEL_RATE: float = 10.0
# 연료 소모 속도 제어 값

var state: LANDER_STATE = LANDER_STATE.IDLE
# 현재 상태
var state_animation: AnimatedSprite2D
# 애니메이션 노드

var horizontal_speed_for_check: float = 0.0
# 착륙 시 게임 오버 여부를 확인하기 위한 좌우 이동량 값
var vertical_speed_for_check: float = 0.0
# 착륙 시 게임 오버 여부를 확인하기 위한 상하 이동량 값

var score_timer: Timer
# 초당 점수가 1씩 올라가게 하는 타이머

var thrust_audio
var turn_audio
var explosion_audio
# 각 상황에 따른 사운드 재생을 위한 오디오

##################################################
func _ready() -> void:
	state_animation = $AnimatedSprite2D
	
	add_to_group("MarsLander")
	# 아이템 객체에 닿을 시 확인하기 위해 MarsLander 그룹에 추가
	
	score_timer = Timer.new()
	score_timer.wait_time = 1.0
	score_timer.autostart
	add_child(score_timer)
	score_timer.start()
	score_timer.connect("timeout", Callable(self, "_on_score_timer_timeout"))
	# 초당 1씩 점수를 올리기 위한 타이머 설정 및 _on_score_timer_timeout 함수에 연결
	
	thrust_audio = $ThrustAudioStreamPlayer
	turn_audio = $TurnAudioStreamPlayer
	explosion_audio = $ExplosionAudioStreamPlayer
	# 각 오디오 연결

##################################################
func _physics_process(delta: float) -> void:
	velocity += GRAVITY * delta
	# 중력 적용
	
	check_landing()
	# horizontal_speed_for_check와 vert는ical_speed_for_check 업데이트
	# 착륙 시에는 게임 오버 여부 판단
	
	if GM.get_game_over():
		score_timer.paused = true
		velocity = Vector2(0,0)
		return
	# 게임 오버 시 타이머 정지 및 중력 제거, 아래 코드 실행 안 되도록 반환
	
	if Input.is_action_pressed("ui_up"):
		thrust(delta)
	# 위 방향키 누를 시 thrust 함수 실행
	elif Input.is_action_just_released("ui_up"):
		if thrust_audio.playing:
			thrust_audio.stop()
	# 위 방향키 놓을 시 thrust 사운드 정지
	elif Input.is_action_pressed("ui_left"):
		turn(true, delta)
	elif Input.is_action_pressed("ui_right"):
		turn(false, delta)
	# 좌 우 방향키 누를 시 turn 함수 실행
	elif Input.is_action_just_released("ui_left") or \
		Input.is_action_just_released("ui_right"):
		if turn_audio.playing:
			turn_audio.stop()
	# 좌우 방향키 놓을 시 turn_audio 사운드 정지
	else:
		set_state(LANDER_STATE.IDLE)
	# 입력이 없으면 IDLE 상태로 설정

	move_and_slide()
	#물리 엔진에 적용

##################################################
func _process(delta: float) -> void:
	GM.set_altitude(global_position.y)
	GM.set_horizontal_speed(velocity.x)
	GM.set_vertical_speed(velocity.y)
	# 고도, 좌우상하 이동량을 게임 매니저에 설정

##################################################
func check_landing() -> void:
	if is_on_floor() or is_on_wall():
	# 착륙선이 벽이나 땅에 닿았을 때
		if horizontal_speed_for_check > 3.0 or vertical_speed_for_check > 10.0:
			if GM.get_game_over() == false:
				GM.set_game_over(true)
				set_state(LANDER_STATE.EXPLOSION)
		# 확인 값이 일정 수치 이상이면 게임 오버 및 EXPLOSION 상태로 변경
	else:
		horizontal_speed_for_check = GM.get_horizontal_speed()
		vertical_speed_for_check = GM.get_vertical_speed()
	# 비행 중에는 확인 값 수치 설정

##################################################
func thrust(delta: float) -> void:
	velocity += Vector2.UP.rotated(rotation).normalized() * THRUST * delta
	# 현재 방향 및 속도를 적용
	GM.set_fuel(GM.get_fuel() - delta * FUEL_RATE)
	# FUEL_RATE에 따라 연료 소모
	set_state(LANDER_STATE.THRUST)
	# THRUST 상태로 설정

##################################################
func turn(is_left: bool, delta: float) -> void:
	if is_on_floor():
		return
	# 착륙 중이면 회전 안 되도록 반환
	
	if is_left:
		rotation -= ROTATION_SPEED * delta
		set_state(LANDER_STATE.TURN_LEFT)
	else:
		rotation += ROTATION_SPEED * delta
		set_state(LANDER_STATE.TURN_RIGHT)
	# 좌우 각각 입력에 따라 회전 및 TURN_LEFT, TURN_RIGHT 상태로 변경
		
	rotation = clamp(rotation, -PI / 2, PI / 2)
	# 좌우 각각 -90도, 90도 이상 회전되지 않도록 제한
	
	if rotation <= -PI / 2 or rotation >= PI / 2:
		return
	else:
		GM.set_fuel(GM.get_fuel() - delta * FUEL_RATE)
	# 최대 회전 각도에 따라 더 이상의 연료 소모를 막음

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
		# 폭발 시 기존 다른 모든 사운드를 멈추고 재생

##################################################
func _on_score_timer_timeout() -> void:
	GM.set_score(GM.get_score() + 1)
	# 매 초마다 점수 1씩 증가
