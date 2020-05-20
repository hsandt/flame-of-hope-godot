extends Node

onready var character := $"../Character" as Node2D

# Initial room (0 in normal game, change for debug)
export(int) var start_room_index = 0

func _ready():
	# room 1 entrance is at 240, 268 and each room has a height of 16*17=272
	character.global_position = Vector2(240, 268 - 272 * start_room_index)
