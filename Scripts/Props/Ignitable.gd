class_name Ignitable
extends Node2D

signal lit

# Light On Audio Clip
export(AudioStream) var light_on_sound

# Is the fire pit lit on level start?
export(bool) var lit_on_start = false setget _set_lit_on_start

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sfx_player: AudioStreamPlayer = $"SFXPlayer"

func _ready():
	if Engine.editor_hint:
		return
	
	_setup()
		
func _setup():
	if lit_on_start:
		_lit()
	else:
		_unlit()

func ignite():
	# state
	_lit()

	# audio
	sfx_player.stream = light_on_sound
	sfx_player.play()

# virtual
func _get_anim_prefix():
	assert(false, "get_anim_prefix not overridden in Ignitable subclass")

# virtual (if you override it, make the subclass script tool)
func _tool_update_preview(_new_lit_on_start: bool):
	return

func _lit():
	animation_player.play("%s_Lit" % _get_anim_prefix())
	emit_signal("lit")

func _unlit():
	animation_player.play("%s_Unlit"  % _get_anim_prefix())

func _set_lit_on_start(new_lit_on_start: bool):
	lit_on_start = new_lit_on_start
	
	if Engine.editor_hint:
		_tool_update_preview(new_lit_on_start)

