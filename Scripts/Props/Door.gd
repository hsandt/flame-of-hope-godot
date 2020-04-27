extends Sprite

# Swing Audio Clip
export(AudioStream) var victory_jingle

# List of ignitable elements that need to be lit to open this door
export(Array, NodePath) var opening_ignitable_paths

# Number of ignitables that need to be lit to open this door (derived from opening_ignitable_paths)
var _opening_ignitable_count := 0

# Number of ignitables already lit
var _opening_ignitable_lit_count := 0

onready var jingle_player := $"/root/Level1/JinglePlayer" as AudioStreamPlayer
onready var collision_shape := $StaticBody2D/CollisionShape2D as CollisionShape2D

func _ready():
	for ignitable_path in opening_ignitable_paths:
		var ignitable = get_node(ignitable_path) as Ignitable
		if ignitable:
			# deferred connection to avoid disabling collision during physics process
			var error = ignitable.connect("lit", self, "_on_opening_ignitable_lit", [], CONNECT_DEFERRED)
			if not error:
				# only count valid ignitables to avoid getting stuck in case
				# we prepared an array too big (e.g. size = 4 but filled only 3)
				_opening_ignitable_count += 1
			else:
				print("WARNING: Ignitable connection failed with error %s" % error)
		else:
			print("WARNING: Opening Ignitable on %s is not an Ignitable" % get_path())

func _on_opening_ignitable_lit():
	_opening_ignitable_lit_count += 1
	print(_opening_ignitable_lit_count)
	if _opening_ignitable_lit_count >= _opening_ignitable_count:
		_open()

func _open():
	visible = false
	collision_shape.disabled = true
	
	# audio
	jingle_player.stream = victory_jingle
	jingle_player.play()
