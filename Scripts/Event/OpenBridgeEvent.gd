extends Event

# Path to bridge to open on trigger
export(NodePath) var bridge_path

# Bridge (derived from bridge_path)
var _bridge: Bridge

func _ready():
	_bridge = get_node(bridge_path) as Bridge
	NodeUtils.assert_node_got_by_path(_bridge, "OpenBridgeEvent", self, "Sprite", bridge_path)

# override
func trigger():
	_bridge.open()
