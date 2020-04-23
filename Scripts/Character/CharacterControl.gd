class_name CharacterControl
extends Node2D

# Input binarization min threshold. Values below (in abs) are cut, values above clamped to -1 or +1.
# Note that this should be higher than the deadzone set in Project Settings for move_ actions to affect input
export var input_min_threshold := 0.125

# Move intention vector, exposed for CharacterMotor
var move_intention : Vector2

# True iff character wants to swing this frame (until consumed)
var _swing_intention : bool

func _ready():
	_setup()

func _setup():
	move_intention = Vector2.ZERO
	_swing_intention = false

func _process(_delta: float):
	var horizontal_input = - Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
	var vertical_input = - Input.get_action_strength("move_up") + Input.get_action_strength("move_down")
	move_intention = Vector2(_get_binarized_value(horizontal_input), _get_binarized_value(vertical_input))
	print(move_intention)

	_swing_intention = Input.is_action_pressed("swing")

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
