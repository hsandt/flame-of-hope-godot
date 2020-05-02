extends Area2D

onready var camera := $"/root/Dungeon/Camera2D" as Camera2D

func _on_RoomEntrance_body_entered(_body):
	# Collision is set with Character only, so we don't need to check for body nature,
	# we know it's the character
	# Move the camera to the Room (parent) position, since it is anchored Fixed TopLeft
	camera.position = get_parent().position
