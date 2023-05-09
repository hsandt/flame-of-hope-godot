extends Event

# Path to door
export(NodePath) var label_path

# Door sprite (derived from label_path)
var _label: Label

onready var jingle_player := $"/root/Dungeon/JinglePlayer" as AudioStreamPlayer

func _ready():
	_label = get_node(label_path) as Label
	NodeUtils.assert_node_got_by_path(_label, "ShowLabel", self, "Label", label_path)

# override
func trigger():
	_label.visible = true
