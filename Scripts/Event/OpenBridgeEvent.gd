extends Event

# Path to bridge
export(NodePath) var bridge_path

# Bridge sprite (derived from bridge_path)
var _bridge: Sprite

func _ready():
	_bridge = get_node(bridge_path) as Sprite
	NodeUtils.assert_node_got_by_path(_bridge, "OpenBridgeEvent", self, "Sprite", bridge_path)
	
	# if an event is supposed to open bridge later,
	# it should be hidden on start (when Bridge script is created,
	# this will be done from Bridge._ready)
	_bridge.visible = false

# override
func trigger():
	_bridge.visible = true
