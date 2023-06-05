class_name Door
extends Node2D

onready var collision_shape := $StaticBody2D/CollisionShape2D as CollisionShape2D
onready var animated_sprite := $AnimatedSprite as AnimatedSprite
onready var animated_sprite2 := $AnimatedSprite2 as AnimatedSprite

export var open_on_start: bool = false

func _ready():
	if open_on_start:
		open()
	else:
		close()
	
func open():
	visible = false
	collision_shape.disabled = true

func close():
	visible = true
	collision_shape.disabled = false
	animated_sprite.play()
	animated_sprite2.play()
