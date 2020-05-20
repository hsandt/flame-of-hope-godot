class_name Door
extends Sprite

onready var collision_shape := $StaticBody2D/CollisionShape2D as CollisionShape2D

func open():
	visible = false
	collision_shape.disabled = true
