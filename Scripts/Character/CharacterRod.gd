class_name CharacterRod
extends Node

# Fireball prefab
export(PackedScene) var fireball_prefab

# PFX ignite prefab
export(PackedScene) var pfx_ignite_prefab

# PFX light off smoke
export(PackedScene) var pfx_light_off_smoke

# Rod Swing Audio Clip
export(AudioStream) var swing_sound

# Rod Throw Fireball Audio Clip (we use rod_light_on)
export(AudioStream) var throw_fireball_sound

# Rod Light On Audio Clip
export(AudioStream) var rod_light_on_sound

# Rod Light Off Audio Clip (we use flame_light_off)
export(AudioStream) var rod_light_off_sound

# Is the rod in fire?
var _is_lit: bool

# Is the character swinging the rod?
var is_swinging: bool

# Has the character just ignited a prop during the current swing animation?
# Cleared on Swing end
var has_just_ignited_prop: bool

# Is the character throwing a fireball
var is_throwing_fireball: bool

onready var dungeon = $"/root/Dungeon" as Node2D
onready var fireball_spawn_point = $"../FireballSpawnPoint" as Node2D
# Rod Flame, activated when rod is lit
onready var animation_player := $"../AnimationPlayer" as AnimationPlayer
onready var rod_flame := $"../RodFlame" as CanvasItem
onready var sfx_player := $"../SFXPlayer" as AudioStreamPlayer
# Swing Hitbox shape. Only enabled during hit.
onready var swing_hitbox_shape := $"../SwingHitBox/CollisionShape2D" as CollisionShape2D
onready var character_control := $"../CharacterControl" as CharacterControl
onready var character_motor := $"../CharacterMotor" as CharacterMotor
onready var character_anim := $"../CharacterAnim" as CharacterAnim
onready var flame_timer := $FlameTimer as Timer
onready var light_scale_flicker := $"../DiscLight2D" as ScaleFlicker

func _ready():
	_setup()

func _setup():
	# allows to work with Flame active in the editor, but deactivate on start
	# make sure to pass on_setup: true
	_light_off(true)
	is_swinging = false
	has_just_ignited_prop = false
	is_throwing_fireball = false
	
	# makes sure hitbox is disabled on start, in case we were testing swing anims in the Editor
	swing_hitbox_shape.disabled = true

func _physics_process(_delta: float):
	# consume all one-shot intentions even if we cannot execute them
	# or there are multiple intentions, to avoid sticky input later
	var swing_intention = character_control.consume_swing_intention()
	var throw_fireball_intention = character_control.consume_throw_fireball_intention()
	
	if swing_intention:
		if _can_swing():
			_start_swing()
	
	elif throw_fireball_intention:
		if _can_throw_fireball():
			_start_throw_fireball()

func _play_sfx(stream: AudioStream):
	if not stream:
		print("ERROR: '%s' _play_sfx stream argument is null, will not play" % get_path())
		return
		
	sfx_player.stream = stream
	sfx_player.play()

func _can_swing() -> bool:
	# character cannot interrupt Swing for another Swing (unlike Zelda GB),
	# nor any other Rod action
	return !is_swinging and !is_throwing_fireball
	
func _can_throw_fireball() -> bool:
	return !is_swinging and !is_throwing_fireball and _is_lit
	
const CARDINAL_DIRECTION_NAMES = ["Down", "Left", "Up", "Right"]

# Start swing animation with SFX
func _start_swing():
	# logic & animation
	is_swinging = true
	character_anim.is_swinging = true
	
	# audio
	_play_sfx(swing_sound)

# Stop swing animation (called on swing anim end)
func _stop_swing():
	# logic & animation
	is_swinging = false
	has_just_ignited_prop = false
	character_anim.is_swinging = false

# Start throw fireball animation with SFX 
func _start_throw_fireball():
	# logic & animation
	is_throwing_fireball = true
	character_anim.is_throwing_fireball = true
	
	# audio
	_play_sfx(swing_sound)

# Stop throw fireball animation (called on throw fireball anim end)
func _stop_throw_fireball():
	# logic & animation
	is_throwing_fireball = false
	character_anim.is_throwing_fireball = false

# Anim Call Method event
func _spawn_fireball():
	if not _is_lit:
		print("ERROR: _spawn_fireball called but CharacterRod is not lit")
		return
	
	# consume current flame
	_light_off(false)
	
	# instantiate fireball and setup position and velocity
	var fireball: Fireball = fireball_prefab.instance()
	# add to current level, not root, so projectiles are removed on scene change
	dungeon.add_child(fireball)
	# spawn point must be set in animation
	fireball.setup(fireball_spawn_point.global_position, character_motor.direction)
	
	# audio
	_play_sfx(throw_fireball_sound)

# light rod on during game, with SFX
func _ignite():
	_light_on()

	
	# audio
	# note we use the same source for all Character SFX, so this will cover the Swing sound (a few frames after)
	_play_sfx(rod_light_on_sound)

# silently set rod lit state to on (logical and visual), useful on setup
# and also during game when combined with SFX
func _light_on():
	_is_lit = true
	rod_flame.visible = true
	rod_flame.play()
	
	# start timer until flame goes off (duration is set in Inspector on FlameTimer)
	flame_timer.start()
	
	# show flame light wtih flicker
	light_scale_flicker.show_with_flicker()

func _rekindle():
	# restart timer to extend burn duration
	flame_timer.start()
	
	# audio
	# note we use the same source for all Character SFX, so this will cover the Swing sound (a few frames after)
	_play_sfx(rod_light_on_sound)

# reverse of ignite, light rod off during game, with SFX
func _go_off():
	_light_off(false)
	
	# visual
	_spawn_pfx(pfx_light_off_smoke)
	
	# audio
	_play_sfx(rod_light_off_sound)	

# silently set rod lit state to off (logical and visual), useful on setup
# and also during game when combined with SFX
func _light_off(on_setup: bool):
	_is_lit = false
	rod_flame.visible = false
	# do not play animated sprite in the background while invisible
	rod_flame.stop()
	
	if on_setup:
		# on setup, instant hide
		light_scale_flicker.visible = false
	else:
		# mid-game, we need to stop timer to avoid warning on timeout
		flame_timer.stop()
		
		# and hide flame light gradually
		light_scale_flicker.hide_with_scale_to_zero()

func _spawn_pfx(pfx_prefab):
	var pfx = pfx_prefab.instance()
	get_tree().root.get_node("/root/Dungeon").add_child(pfx)
	pfx.global_position = rod_flame.global_position

func _on_SwingHitBox_area_entered(area: Area2D):
	if area.get_collision_layer_bit(Layer.FIRE_SOURCE):
		# Spawn PFX for rod being ignited itself unless we have just ignited a prop,
		# in which case we have already played an Ignite PFX and we are probably just
		# rekindling the rod and don't want to play an extra PFX
		# (but we play a PFX when rekindling on a prop already lit up)
		if not has_just_ignited_prop:
			_spawn_pfx(pfx_ignite_prefab)
	
		if _is_lit:
			# we touched a fire source but already lit, rekindle rod
			# note that when lighting an ignitable, this is still called on the
			# same frame, so this also rekindle the rod without having to swing
			# once more (originally unintended design, but convenient for player,
			# so we kept it)
			_rekindle()
		else:
			# we touched a fire source, ignite rod
			_ignite()
	elif area.get_collision_layer_bit(Layer.IGNITABLE):
		if _is_lit:
			# we touched a fire source, light rod on
			var ignitable := area.get_parent() as Ignitable
			ignitable.ignite()
			# since we just touched what is now a fire source,
			# restart the flame timer
			flame_timer.start()
			
			# remember we did it until end of Swing animation
			has_just_ignited_prop = true

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name.begins_with("Character_Swing_"):
		_stop_swing()
	elif anim_name.begins_with("Character_Throw_Fireball_"):
		_stop_throw_fireball()

func _on_FlameTimer_timeout():
	if _is_lit:
		_go_off()
	else:
		print("WARNING: FlameTimer timed out while Rod was not lit, nothing will happen.")
