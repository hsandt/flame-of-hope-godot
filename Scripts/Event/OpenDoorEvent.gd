extends Event

# Path to door
export(NodePath) var door_path

# Victory Audio Clip
export(AudioStream) var victory_jingle

# Door sprite (derived from sprite_path)
var _door: Door

onready var jingle_player := $"/root/Dungeon/JinglePlayer" as AudioStreamPlayer

func _ready():
	_door = get_node(door_path) as Door
	NodeUtils.assert_node_got_by_path(_door, "OpenDoorEvent", self, "Door", door_path)

# override
func trigger():
	_door.open()
	
	# audio
	jingle_player.stream = victory_jingle
	jingle_player.play()
