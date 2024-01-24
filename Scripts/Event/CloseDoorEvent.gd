extends Event

# Path to door
export(NodePath) var door_path

# Door sprite (derived from door_path)
var _door: Door

func _ready():
	_door = get_node(door_path) as Door
	NodeUtils.assert_node_got_by_path(_door, "OpenDoorEvent", self, "Door", door_path)

# override
func trigger():
	_door.close()
