class_name CharacterControl
extends Node

# Input binarization min threshold. Values below (in abs) are cut, values above clamped to -1 or +1.
# Note that this should be higher than the deadzone set in Project Settings for move_ actions to affect input
export(float) var input_min_threshold = 0.125

# Current control mode
var control_mode: int # Enum.ControlMode

# Intro-only: when false, character cannot throw fireball (avoids soft lock)
var can_throw_fireball: bool

# Move intention vector, exposed for CharacterMotor
var move_intention : Vector2

# True iff character wants to swing this frame (until consumed)
var _swing_intention : bool

# True iff character wants to throw fireball this frame (until consumed)
var _throw_fireball_intention : bool

func _ready():
	_setup()

func _setup():
	control_mode = Enum.ControlMode.PLAYER_INPUT
	can_throw_fireball = true  # default to true so when debugging in non-intro rooms, we can fully play
	move_intention = Vector2.ZERO
	_swing_intention = false
	_throw_fireball_intention = false

func _unhandled_input(event: InputEvent):
	if control_mode == Enum.ControlMode.PLAYER_INPUT:
		# one-time press actions are handled here instead of _process + is_action_just_pressed
		# in both cases, never clear if not pressing this frame, or we may miss the input entirely
		# due to this _process being called 2x before CharacterRod._physics_process
		if event.is_action_pressed("swing"):
			_swing_intention = true
		if event.is_action_pressed("throw_fireball") and can_throw_fireball:
			_throw_fireball_intention = true

func _process(_delta: float):
	if control_mode == Enum.ControlMode.PLAYER_INPUT:
		var horizontal_input = - Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
		var vertical_input = - Input.get_action_strength("move_up") + Input.get_action_strength("move_down")
		move_intention = Vector2(_get_binarized_value(horizontal_input), _get_binarized_value(vertical_input))

func _get_binarized_value(value: float) -> float:
	# Process input so that each coordinate is 0/1 as in old school games with D-pad,
	# even when using gamepad left stick.
	# For analog input (stick), ceil any sufficient input coordinate to 1,
	# independently from the other.
	# For digital input, this computation will preserve the binary value.
	if abs(value) >= input_min_threshold:
		return sign(value)
	else:
		return 0.0

func consume_swing_intention() -> bool:
	if _swing_intention:
		_swing_intention = false
		return true
	else:
		return false

func consume_throw_fireball_intention() -> bool:
	if _throw_fireball_intention:
		_throw_fireball_intention = false
		return true
	else:
		return false
