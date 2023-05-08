class_name Door
extends Node2D

onready var collision_shape := $StaticBody2D/CollisionShape2D as CollisionShape2D
onready var animated_sprite := $AnimatedSprite as AnimatedSprite
onready var animated_sprite2 := $AnimatedSprite2 as AnimatedSprite

func _ready():
	animated_sprite.play()
	animated_sprite2.play()

func open():
	visible = false
	collision_shape.disabled = true
