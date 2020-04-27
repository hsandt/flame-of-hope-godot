extends Sprite

export(Array, NodePath) var opening_ignitable_paths

# Number of ignitables that need to be lit to open this door
var _opening_ignitable_count := 0

# Number of ignitables already lit
var _opening_ignitable_lit_count := 0

onready var collision_shape := $StaticBody2D/CollisionShape2D as CollisionShape2D

func _ready():
	for ignitable_path in opening_ignitable_paths:
		var ignitable = get_node(ignitable_path) as Ignitable
		if ignitable:
			var error = ignitable.connect("lit", self, "_on_opening_ignitable_lit")
			if not error:
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
