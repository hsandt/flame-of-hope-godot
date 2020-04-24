tool
extends Node2D

export var lit_on_start := false setget set_lit_on_start

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var flame_big: AnimatedSprite = $FlameBig

func _ready():
	if Engine.editor_hint:
		return
	
	if lit_on_start:
		animation_player.play("FirePit_Lit")
	else:
		animation_player.play("FirePit_Unlit")
		flame_big.stop()
		
func set_lit_on_start(new_lit_on_start):
	lit_on_start = new_lit_on_start
	
	if Engine.editor_hint:
		# in game runtime we play FirePit_Lit/Unlit which also changes the Body
		# sprite, but for preview in editor, showing/hiding Flame is enough
		# also, don't use flame_big, it's only defined at runtime
		$FlameBig.visible = new_lit_on_start
