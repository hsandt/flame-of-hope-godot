extends Node

onready var character: Character = $"../Character"

# Initial room (0 in normal game, change for debug)
export(int) var start_room_index = 0

func _ready():
	# Note that this is run even in release, so we can place character and camera
	# where we want immediately in case they are not preset correctly in the level
	
	_warp_character(start_room_index)

	# Wait a short time, just enough to load/reload the game if using restart
	# and so character enters RoomEntrance and triggers camera motion
	# with no smoothing so it is immediate the first time;
	# but short enough to guarantee character won't enter next room in that duration)
	yield(get_tree().create_timer(0.1), "timeout")

	# Then enable smoothing so camera moves smoothly on further Room Entrances
	var camera: Camera2D = get_tree().get_nodes_in_group("camera")[0]
	camera.smoothing_enabled = true
	
	# Play intro sequence if starting in first room, as normally
	# but skip it if debug warping to another room
	if start_room_index == 0:
		_play_intro_sequence()
	

func _unhandled_input(event):
	if OS.has_feature("debug"):
		if event.is_action_pressed("cheat_restart"):
			var _err = get_tree().reload_current_scene()
		elif event.is_action_pressed("go_to_room1"):
			_warp_character(0)
		elif event.is_action_pressed("go_to_room2"):
			_warp_character(1)
		elif event.is_action_pressed("go_to_room3"):
			_warp_character(2)
		elif event.is_action_pressed("go_to_room4"):
			_warp_character(3)

func _warp_character(room_index: int):
	# room 1 entrance is at 240, 268 and each room has a height of 16*17=272
	character.global_position = Vector2(240, 268 - 272 * room_index)

	# to support warping during intro sequence, stop it now
	stop_intro_sequence()


func _play_intro_sequence():
	# Light rod on silently for setup
	var rod = character.rod
	
	# pass go_off_after_timer = false so the first flame is infinite
	# note that the first ignite will rekindle the rod, with timer this time,
	# thus starting the timer and deactivating infinite flame as we want
	rod._light_on(false)
	
	# Move character lower so it starts outside room
	# (far enough so his own light disc is not visible on screen at first)
	character.position += 60.0 * Vector2.DOWN
	
	# Take control of character
	var control = character.control
	control.control_mode = Enum.ControlMode.SIMULATION
	
	# Prevent throwing fireball because player would lose the initial flame
	# before igniting the first fire pit, causing soft lock
	control.can_throw_fireball = false
	
	# Move up to just enter room
	control.move_intention = Vector2.UP
	yield(get_tree().create_timer(1.5), "timeout")
	control.move_intention = Vector2.ZERO
	
	# Give control back to player
	stop_intro_sequence()


func stop_intro_sequence():
	var control = character.control
	
	# control may still be null on ready and we have not started playing intro
	# anyway on first warp, so skip it in this case
	if control != null:
		control.control_mode = Enum.ControlMode.PLAYER_INPUT
	
