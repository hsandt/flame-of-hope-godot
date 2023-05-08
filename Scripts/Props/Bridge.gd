class_name Bridge
extends Node2D

# Bridge sprite, visible when bridge is open
onready var sprite : Sprite = $"Sprite"

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
	ground_border.collision_layer = 0
	ground_border.collision_mask = 0

func close():
	sprite.visible = false
	ground_border.collision_layer = _initial_ground_border_collision_layer
	ground_border.collision_mask = _initial_ground_border_mask_layer
