extends Event

# Path to door
export(NodePath) var label_path
export(float) var fade_in_duration = 1.0

# Door sprite (derived from label_path)
var _label: Label

# Flag to remember not to trigger twice
var _triggered: bool = false

onready var jingle_player := $"/root/Dungeon/JinglePlayer" as AudioStreamPlayer

func _ready():
	_label = get_node(label_path) as Label
	NodeUtils.assert_node_got_by_path(_label, "ShowLabel", self, "Label", label_path)

# override
func trigger():
	# Don't trigger twice
	if _triggered:
		return
	
	_triggered = true
	
	_label.visible = true
	get_tree().create_tween() \
		.tween_property(_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), fade_in_duration) \
		.from(Color(1.0, 1.0, 1.0, 0.0))
