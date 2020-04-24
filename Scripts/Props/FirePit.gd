tool
class_name FirePit
extends Node2D

# Fire Pit Light On Audio Clip
export var fire_pit_light_on_sound: AudioStream

# Is the fire pit lit on level start?
export var lit_on_start := false setget _set_lit_on_start

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var audio_stream_player: AudioStreamPlayer = $"AudioStreamPlayer"
onready var flame_big: AnimatedSprite = $FlameBig

func _ready():
	if Engine.editor_hint:
		return
	
	_setup()
		
func _setup():
	if lit_on_start:
		_set_lit()
	else:
		_set_unlit()

func _set_lit():
	animation_player.play("FirePit_Lit")
	flame_big.play()

func _set_unlit():
	animation_player.play("FirePit_Unlit")
	flame_big.stop()

func ignite():
	# state
	_set_lit()

	# audio
	audio_stream_player.stream = fire_pit_light_on_sound
	audio_stream_player.play()

func _set_lit_on_start(new_lit_on_start):
	lit_on_start = new_lit_on_start
	
	if Engine.editor_hint:
		# in game runtime we play FirePit_Lit/Unlit which also changes the Body
		# sprite, but for preview in editor, showing/hiding Flame is enough
		# also, don't use flame_big, it's only defined at runtime
		$FlameBig.visible = new_lit_on_start
