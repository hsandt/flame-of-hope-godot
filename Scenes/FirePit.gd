extends Node2D

export var lit_on_start := false

onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	if lit_on_start:
		animation_player.play("FirePit_Lit")
	else:
		animation_player.play("FirePit_Unlit")
		
