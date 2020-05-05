extends Sprite

# Swing Audio Clip
export(AudioStream) var victory_jingle

# List of ignitable elements that need to be lit to open this door
export(Array, NodePath) var opening_ignitable_paths

# Number of ignitables that need to be lit to open this door (derived from opening_ignitable_paths)
var _opening_ignitable_count := 0

# Number of ignitables already lit
var _opening_ignitable_lit_count := 0

onready var jingle_player := $"/root/Dungeon/JinglePlayer" as AudioStreamPlayer
onready var collision_shape := $StaticBody2D/CollisionShape2D as CollisionShape2D

func _ready():
	for ignitable_path in opening_ignitable_paths:
		if ignitable_path.is_empty():
			print("WARNING: Door '%s' references opening ignitable with empty path. Delete it from the array for cleanup" % get_path())
			continue
		
		var ignitable = get_node(ignitable_path)
		if not ignitable:
			print("WARNING: Door '%s' references opening ignitable with path: '%s', but it is null" % [get_path(), ignitable_path])
			continue
		
		ignitable = ignitable as Ignitable
		if not ignitable:
			print("WARNING: Door '%s' references opening ignitable %s, but it is not an Ignitable" % [get_path(), ignitable_path])
			continue

			# deferred connection to avoid disabling collision during physics process (only matters for lit signal)
		var error1 = ignitable.connect("lit", self, "_on_opening_ignitable_lit", [], CONNECT_DEFERRED)
		var error2 = ignitable.connect("unlit", self, "_on_opening_ignitable_unlit", [], CONNECT_DEFERRED)
		if error1 or error2:
			print("WARNING: Ignitable connection failed with error1: %s and error2: %s" % [error1, error2])
			continue
		
		# only count valid ignitables to avoid getting stuck in case
		# we prepared an array too big (e.g. size = 4 but filled only 3)
		_opening_ignitable_count += 1

func _on_opening_ignitable_lit():
	# increment count, and open door if all connected ignitables have been lit
	_opening_ignitable_lit_count += 1
	print(_opening_ignitable_lit_count)
	if _opening_ignitable_lit_count >= _opening_ignitable_count:
		_open()

func _on_opening_ignitable_unlit():
	# decrement count, but never close the door again
	_opening_ignitable_lit_count -= 1
	print(_opening_ignitable_lit_count)

func _open():
	visible = false
	collision_shape.disabled = true
	
	# audio
	jingle_player.stream = victory_jingle
	jingle_player.play()
