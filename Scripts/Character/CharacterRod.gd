class_name CharacterRod
extends Node

# Swing Audio Clip
export(AudioStream) var swing_sound
	
# Rod Light On Audio Clip
export(AudioStream) var rod_light_on_sound

# Rod Light Off Audio Clip (we use flame_light_off)
export(AudioStream) var rod_light_off_sound

# Is the rod in fire?
var _is_lit: bool

# Is the character swinging the rod?
var is_swinging: bool

# Swing Hitbox shape. Only enabled during hit.
onready var swing_hitbowing_hitbox_shape := $"../SwingHitBox/CollisionShape2D" as CollisionShape2D
# Rod Flame, activated when rod is lit
onready var rod_flame := $"../RodFlame" as CanvasItem
onready var animation_player := $"../AnimationPlayer" as AnimationPlayer
onready var sfx_player := $"../SFXPlayer" as AudioStreamPlayer
onready var character_control := $"../CharacterControl" as CharacterControl
onready var character_anim := $"../CharacterAnim" as CharacterAnim
onready var flame_timer := $FlameTimer as Timer

func _ready():
	_setup()

func _setup():
	# allows to work with Flame active in the editor, but deactivate on start
	_light_off()
	is_swinging = false
	
	# makes sure hitbox is disabled on start, in case we were testing swing anims in the Editor
	swing_hitbowing_hitbox_shape.disabled = true

func _physics_process(_delta: float):
	# consume swing intention even if cannot swing now (no input buffering)
	if character_control.consume_swing_intention():
		# check if character can swing
		if _can_swing():
			_start_swing()

func _play_sfx(stream: AudioStream):
	if not stream:
		print("ERROR: '%s' _play_sfx stream argument is null, will not play" % get_path())
		return
		
	sfx_player.stream = stream
	sfx_player.play()

func _can_swing() -> bool:
	# character cannot interrupt Swing for another Swing (unlike Zelda GB)
	return !is_swinging
	
const CARDINAL_DIRECTION_NAMES = ["Down", "Left", "Up", "Right"]

func _start_swing():
	is_swinging = true
	
	# animation
	character_anim.is_swinging = true
	
	# audio
	_play_sfx(swing_sound)

# Anim event callback
func _stop_swing():
	is_swinging = false

	# animation
	character_anim.is_swinging = false

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

# reverse of ignite, light rod off during game, with SFX
func _go_off():
	_light_off()
	
	# audio
	_play_sfx(rod_light_off_sound)	

# silently set rod lit state to off (logical and visual), useful on setup
# and also during game when combined with SFX
func _light_off():
	_is_lit = false
	rod_flame.visible = false
	# do not play animated sprite in the background while invisible
	rod_flame.stop()
	
	# stop timer to avoid warning on timeout
	flame_timer.stop()

func _on_SwingHitBox_area_entered(area: Area2D):
	if not _is_lit:
		if area.get_collision_layer_bit(Layer.FIRE_SOURCE):
			# we touched a fire source, ignite rod
			_ignite()
	else:
		if area.get_collision_layer_bit(Layer.IGNITABLE):
			# we touched a fire source, light rod on
			var ignitable := area.get_parent() as Ignitable
			ignitable.ignite()
			# since we just touched what is now a fire source,
			# restart the flame timer
			flame_timer.start()

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name.begins_with("Character_Swing_"):
		_stop_swing()

func _on_FlameTimer_timeout():
	if _is_lit:
		_go_off()
	else:
		print("WARNING: FlameTimer timed out while Rod was not lit, nothing will happen.")
