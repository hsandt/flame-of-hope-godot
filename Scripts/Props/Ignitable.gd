class_name Ignitable
extends Node2D

signal lit
signal unlit

# Light On Audio Clip
export(AudioStream) var light_on_sound

# Light Off Audio Clip (only temporary ignitables can be lit off)
export(AudioStream) var light_off_sound

# Is the fire pit lit on level start?
export(bool) var lit_on_start = false setget _set_lit_on_start

# Is the ignitable in fire?
var _is_lit: bool

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sfx_player: AudioStreamPlayer = $"SFXPlayer"

func _ready():
	if Engine.editor_hint:
		return
	
	_setup()
		
func _setup():
	_is_lit = false
	
	if lit_on_start:
		call_deferred("_light_on")
	else:
		call_deferred("_light_off")

# full ignition during game (light on + SFX)
func ignite():
	# state
	_light_on()

	# audio
	_play_sfx(light_on_sound)

# virtual
func _get_anim_prefix():
	assert(false, "_get_anim_prefix not overridden in Ignitable subclass")

# virtual (if you override it, make the subclass script tool)
func _tool_update_preview(_new_lit_on_start: bool):
	return

func _play_sfx(stream: AudioStream):
	if not stream:
		print("ERROR: '%s' _play_sfx stream argument is null, will not play" % get_path())
		return
		
	sfx_player.stream = stream
	sfx_player.play()

# silently set light on (with anim and signal)
func _light_on():
	_is_lit = true
	animation_player.play("%s_Lit" % _get_anim_prefix())
	
	# signal for both puzzle like connected doors and child class (e.g. Torch)
	# this is called even on start, so doors always have the correct count if
	# for some reason some torches start on
	emit_signal("lit")
	
# full going off during game (light off + SFX)
func _go_off():
	_light_off()
	
	# audio
	_play_sfx(light_off_sound)

# silently set light off (with anim and signal)
func _light_off():
	_is_lit = false
	animation_player.play("%s_Unlit"  % _get_anim_prefix())
	
	# signal for child class (e.g. Torch)
	emit_signal("unlit")

func _set_lit_on_start(new_lit_on_start: bool):
	lit_on_start = new_lit_on_start
	
	if Engine.editor_hint:
		# defer to let child be loaded if this is called on start/save scene
		call_deferred("_tool_update_preview", new_lit_on_start)
