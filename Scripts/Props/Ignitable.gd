class_name Ignitable
extends Node2D

signal lit
signal rekindle
signal unlit

# PFX ignite prefab
export(PackedScene) var pfx_ignite_prefab

# PFX light off smoke
export(PackedScene) var pfx_light_off_smoke

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
onready var light_scale_flicker: ScaleFlicker = $"DiscLight2D"
onready var room_light: Light2D = $"RoomLight2D"
onready var pfx_ignite_anchor: Node2D = $"PFXIgniteAnchor"

func _ready():
	if Engine.editor_hint:
		return
	
	_setup()

func _setup():
	_is_lit = false
	
	if lit_on_start:
		call_deferred("_light_on")
	else:
		# make sure to pass on_setup: true so we don't emit the unlit signal, causing
		# any connected IgnitionTrigger._on_trigger_ignitable_unlit to fail
		# as it cannot unregister an ignitable never registered
		_light_off(true)
		_play_unlit_animation()

# full ignition during game (light on + SFX)
func ignite():
	_spawn_pfx(pfx_ignite_prefab)
	
	if _is_lit:
		_rekindle()
	else:
		_light_on_with_sound()

# virtual
func on_lit_triggered_event():
	pass

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

# full light on during game (light on + SFX)
func _light_on_with_sound():
	_light_on()
	
	# audio
	_play_sfx(light_on_sound)

# silently set light on (with anim and signal)
func _light_on():
	_is_lit = true
	_play_lit_animation()
	
	# signal for both puzzle like connected doors and child class (e.g. Torch)
	# this is called even on start, so doors always have the correct count if
	# for some reason some torches start on
	emit_signal("lit")

func _play_lit_animation():
	animation_player.play("%s_Lit" % _get_anim_prefix())
	
	# show flame light wtih flicker
	light_scale_flicker.show_with_flicker()
	if room_light != null:
		room_light.visible = true

# when already lit, call this to just rekindle the flame
# without triggering lit-specific behaviors
func _rekindle():
	emit_signal("rekindle")	
	
	# audio
	_play_sfx(light_on_sound)

# full going off during game (light off + SFX)
func _go_off():
	_light_off(false)
	
	# visual
	_spawn_pfx(pfx_light_off_smoke)
	
	# audio
	_play_sfx(light_off_sound)

# silently set light off (with anim and signal)
# if on_setup is false, play transition from on to off state
func _light_off(on_setup: bool):
	_is_lit = false
	_play_unlit_animation()
	
	if on_setup:
		# on setup, instant hide
		light_scale_flicker.visible = false
		if room_light != null:
			room_light.visible = false
	else:
		# signal for child class (e.g. Torch)
		emit_signal("unlit")
		
		# hide flame light gradually
		light_scale_flicker.hide_with_scale_to_zero()
		if room_light != null:
			room_light.visible = false

func _play_unlit_animation():
	animation_player.play("%s_Unlit" % _get_anim_prefix())
	
func _set_lit_on_start(new_lit_on_start: bool):
	lit_on_start = new_lit_on_start
	
	if Engine.editor_hint:
		# defer to let child be loaded if this is called on start/save scene
		call_deferred("_tool_update_preview", new_lit_on_start)

func _spawn_pfx(pfx_prefab):
	var pfx = pfx_prefab.instance()
	get_tree().root.get_node("/root/Dungeon").add_child(pfx)
	pfx.global_position = pfx_ignite_anchor.global_position
