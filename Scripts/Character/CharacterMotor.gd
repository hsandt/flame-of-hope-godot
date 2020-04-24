extends Node

# Character speed
export var speed := 32.0

enum CardinalDirection {
	DOWN,
	LEFT,
	UP,
	RIGHT,
}

const CARDINAL_DIRECTION_NAMES = ["Down", "Left", "Up", "Right"]

var _direction: int # enum CardinalDirection

onready var character: KinematicBody2D = $".."
onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
onready var character_control: CharacterControl = $"../CharacterControl"
onready var character_rod: CharacterRod = $"../CharacterRod"

func _ready():
	_setup()

func _setup():
	_direction = CardinalDirection.DOWN

func _physics_process(_delta: float):
	var move_intention := Vector2.ZERO

	# rename _is_in_different_state?
	if _can_move():
		# we assume move intention coordinates are 0/1 are in old school games using D-pad
		move_intention = character_control.move_intention
		# return here?
	
	# outside conditional block to make sure character stops after Swing
	# we don't use the resulting velocity since we recompute motion each frame form input
	var _resulting_velocity = character.move_and_slide(speed * move_intention)

	# even if character walks against a wall, show walking animation
	var is_walking_anim := move_intention != Vector2.ZERO
	# until base anim + direction name system is implemented, check for conflicting state
	# manually
	if is_walking_anim:
		_update_direction(move_intention)
		animation_player.play("Character_Walk_%s" % CARDINAL_DIRECTION_NAMES[_direction])
	# elif not character_rod.is_swinging:
	# 	animation_player.play("Character_Idle_%s" % CARDINAL_DIRECTION_NAMES[_direction])

func _can_move() -> bool:
#	# character cannot move during Swing
	return !character_rod.is_swinging

func _update_direction(move_intention: Vector2):
	if move_intention.x != 0.0 && move_intention.y != 0.0:
		# diagonal motion:
		# if one of the two directions is the current direction, preserve it
		# else, give priority to vertical direction
		if move_intention.x < 0.0 && _direction == CardinalDirection.LEFT:
			_direction = CardinalDirection.LEFT
		elif move_intention.x > 0.0 && _direction == CardinalDirection.RIGHT:
			_direction = CardinalDirection.RIGHT
		elif move_intention.y < 0.0 && _direction == CardinalDirection.UP:
			_direction = CardinalDirection.UP
		elif move_intention.y > 0.0 && _direction == CardinalDirection.DOWN:
			_direction = CardinalDirection.DOWN
		elif move_intention.y < 0.0:
			_direction = CardinalDirection.UP
		else: # if move_intention.y > 0.0
			_direction = CardinalDirection.DOWN
	elif move_intention.x < 0.0:
		_direction = CardinalDirection.LEFT
	elif move_intention.x > 0.0:
		_direction = CardinalDirection.RIGHT
	elif move_intention.y < 0.0:
		_direction = CardinalDirection.UP
	else: # if move_intention.y > 0.0
		_direction = CardinalDirection.DOWN
