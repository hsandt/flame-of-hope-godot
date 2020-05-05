extends Area2D

# Vertical offset between room topleft and camera so camera is centered on room
export(float) var camera_offset_y = 1

onready var camera := $"/root/Dungeon/Camera2D" as Camera2D

func _on_RoomEntrance_body_entered(_body):
	# Collision is set with Character only, so we don't need to check for body nature,
	# we know it's the character
	# Move the camera to the Room (parent) position, since it is anchored Fixed TopLeft
	camera.position = get_parent().position + camera_offset_y * Vector2.DOWN
