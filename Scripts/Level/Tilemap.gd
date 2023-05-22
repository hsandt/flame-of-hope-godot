extends Node2D

# Ground border: invisible walls
onready var ground_border : TileMap = $"GroundBorder"

func _ready():
	# Always hide ground border at runtime, it's only visible during editing
	ground_border.visible = false
