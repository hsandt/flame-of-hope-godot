tool
extends Node2D

export var lit_on_start := false setget set_lit_on_start

onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	if lit_on_start:
		animation_player.play("FirePit_Lit")
	else:
		animation_player.play("FirePit_Unlit")
		
func set_lit_on_start(new_lit_on_start):
	lit_on_start = new_lit_on_start
	
	if Engine.editor_hint:
		# in game runtime we play FirePit_Lit/Unlit which also changes the Body
		# sprite, but for preview in editor, showing/hiding Flame is enough
		$Flame.visible = new_lit_on_start
