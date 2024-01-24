extends Event

# List of path of torch elements that need to be lit to trigger this event
export(Array, NodePath) var torch_paths

# Activate Torches Audio Clip
export(AudioStream) var sfx_activate_torches

# List of torch elements (derived by torch_paths)
var _torches: Array


func _ready():
	for torch_path in torch_paths:
		var torch := get_node(torch_path) as Ignitable
		NodeUtils.assert_node_got_by_path(torch, "ActivateTorchEvent", self, "Torch", torch_path)
		_torches.append(torch)


# override
func trigger():
	# prepare average position calculation for SFX
	var central_position := Vector2.ZERO
	
	for torch in _torches:
		torch.activate()
		central_position += torch.global_position
	
	if _torches.size() > 0:
		central_position /= _torches.size()
	
	# audio
	SfxManager.spawn_sfx(sfx_activate_torches, central_position)
