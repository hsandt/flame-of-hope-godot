class_name Bridge
extends Node2D

# Bridge sprite, visible when bridge is open
onready var sprite : Sprite = $"Sprite"

# Animation showing bridge appearing
onready var animation_player : AnimationPlayer = $"AnimationPlayer"

# Ground border: invisible walls active when bridge is closed
onready var ground_border : TileMap = $"GroundBorder"

# Initial vars to restore initial ground border state on open/close

# Should be GroundBorder layer
var _initial_ground_border_collision_layer : int

# Should be Character layer
var _initial_ground_border_mask_layer : int

func _ready():
	# Always hide ground border at runtime, it's only visible during editing
	ground_border.visible = false

	_initial_ground_border_collision_layer = ground_border.collision_layer
	_initial_ground_border_mask_layer = ground_border.collision_mask
	
	close()

func open():
	sprite.visible = true
	animation_player.play("ANIM_Bridge_Appear")
	# wait for animation to finish to disable invisible ground_border and
	# allow player to walk on bridge

func close():
	sprite.visible = false
	ground_border.collision_layer = _initial_ground_border_collision_layer
	ground_border.collision_mask = _initial_ground_border_mask_layer

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ANIM_Bridge_Appear":
		ground_border.collision_layer = 0
		ground_border.collision_mask = 0
