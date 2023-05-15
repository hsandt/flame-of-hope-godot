extends AudioStreamPlayer

# Workaround to simulate distance attenuation but not stereo
# See https://github.com/godotengine/godot-proposals/issues/4692
# I had to adapt the code:
# 1. Use 2D instead of 3D, using parent global position
# 2. Store initial volume DB set in scene and use it as base volume
# 3. Add default export values to avoid division by 0 when not filling values
# 4. Instead of processing each frame, set the volume only when calling play
#    In counterpart, it won't work with autoplay sounds, and if the sound
#    plays for a long time while camera moves relatively to source, the volume
#    won't be updated unless you manually call set_volume_from_current_distance_to_camera.
#    But this is fine for short sounds.

export(float) var max_distance = 300.0

var base_volume_db: float
var playercam: Camera2D
var native_width: float
var native_height: float


func _ready():
	# Store initial volume DB set in scene
	base_volume_db = volume_db
	
	# We cannot get the camera 2D until https://github.com/godotengine/godot/pull/69426
	# is merged, so for now, retrieve it via group
	playercam = get_tree().get_nodes_in_group("camera")[0]

	var viewport = get_viewport()
	native_width = viewport.get_visible_rect().size.x
	native_height = viewport.get_visible_rect().size.y


func set_volume_from_current_distance_to_camera():
	var camera_center := playercam.get_camera_screen_center()
	var parent_pos: Vector2 = get_parent().global_position
	
	if abs(parent_pos.x - camera_center.x) <= native_width / 2.0 and \
			abs(parent_pos.y - camera_center.y) <= native_height / 2.0:
		# Inside room rectangle (which is also camera rectangle), keep uniform volume
		volume_db = base_volume_db
	else:
		# Else, decrease volume with distance
		# Note that we still use distance from camera center, not camera edge,
		# so there is indeed a gap between the camera edge and the outer area,
		# where the volume suddenly drops
		var distance: float = parent_pos.distance_to(camera_center)
		var linear_energy: float = max(0.0, 1.0 - (distance / max_distance))
		volume_db = base_volume_db + linear2db(linear_energy)


# override
func play(from_position: float = 0.0):
	set_volume_from_current_distance_to_camera()
	.play(from_position)
