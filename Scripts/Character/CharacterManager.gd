extends Node

onready var character := $"../Character" as Node2D

# Initial room (0 in normal game, change for debug)
export(int) var start_room_index = 0

func _ready():
	# Note that this is run even in release, so we can place character and camera
	# where we want immediately in case they are not preset correctly in the level
	
	# room 1 entrance is at 240, 268 and each room has a height of 16*17=272
	_warp_character(Vector2(240, 268 - 272 * start_room_index))

	# Wait a short time, just enough to load/reload the game if using restart
	# and so character enters RoomEntrance and triggers camera motion
	# with no smoothing so it is immediate the first time;
	# but short enough to guarantee character won't enter next room in that duration)
	yield(get_tree().create_timer(0.1), "timeout")

	# Then enable smoothing so camera moves smoothly on further Room Entrances
	var camera: Camera2D = get_tree().get_nodes_in_group("camera")[0]
	camera.smoothing_enabled = true
	

func _unhandled_input(event):
	if OS.has_feature("debug"):
		if event.is_action_pressed("cheat_restart"):
			var _err = get_tree().reload_current_scene()

func _warp_character(position: Vector2):
	character.global_position = position
