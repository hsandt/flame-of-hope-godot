class_name CharacterAnim
extends Node

const CARDINAL_DIRECTION_NAMES = ["Down", "Left", "Up", "Right"]

var direction: int setget _set_direction  # Enum.CardinalDirection
var is_walking: bool setget _set_is_walking
var is_swinging: bool setget _set_is_swinging
var is_throwing_fireball: bool setget _set_is_throwing_fireball

onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

func _ready():
	_setup()
	
func _setup():
	direction = Enum.CardinalDirection.DOWN
	is_walking = false
	is_swinging = false
	is_throwing_fireball = false
	_update_anim()

func _update_anim():
	# Decide anim priority here (in case parallel states are allowed in logic)
	var new_anim_state
	if is_throwing_fireball:
		new_anim_state = "Throw_Fireball"
	elif is_swinging:
		new_anim_state = "Swing"
	elif is_walking:
		new_anim_state = "Walk"
	else:
		new_anim_state = "Idle"
	
	# Ex: "Character_Swing_Left"
	var new_anim = "Character_%s_%s" % [new_anim_state, CARDINAL_DIRECTION_NAMES[direction]]
	
	# Godot already checks if new_anim is the current animation, so even if after
	# a parameter change, the anim happens to be remain the same, it won't be restarted
	animation_player.play(new_anim)
	
func _set_direction(new_direction: int): # direction: Enum.CardinalDirection
	if direction != new_direction:
		direction = new_direction
		_update_anim()

func _set_is_walking(new_is_walking: bool):
	if is_walking != new_is_walking:
		is_walking = new_is_walking
		_update_anim()

func _set_is_swinging(new_is_swinging: bool):
	if is_swinging != new_is_swinging:
		is_swinging = new_is_swinging
		_update_anim()

func _set_is_throwing_fireball(new_throwing_fireball: bool):
	if is_throwing_fireball != new_throwing_fireball:
		is_throwing_fireball = new_throwing_fireball
		_update_anim()
