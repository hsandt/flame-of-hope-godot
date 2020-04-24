class_name CharacterRod
extends Node

# Swing Audio Clip
export var swing_sound: AudioStream
	
# Rod Light On Audio Clip
export var rod_light_on_sound: AudioStream

# Is the rod in fire?
var _is_lit: bool

# Is the character swinging the rod?
var is_swinging: bool

# Swing Hitbox shape. Only enabled during hit.
onready var swing_hitbowing_hitbox_shape: CollisionShape2D = $"../SwingHitBox/CollisionShape2D"
	
# Rod Flame, activated when rod is lit
onready var rod_flame: CanvasItem = $"../RodFlame"
onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"
onready var character_control: CharacterControl = $"../CharacterControl"
onready var character_anim: CharacterAnim = $"../CharacterAnim"

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

func _can_swing() -> bool:
	# character cannot interrupt Swing for another Swing (unlike Zelda GB)
	return !is_swinging
	
const CARDINAL_DIRECTION_NAMES = ["Down", "Left", "Up", "Right"]

func _start_swing():
	is_swinging = true
	
	# animation
	character_anim.is_swinging = true
	
	# audio
	audio_stream_player.stream = swing_sound
	audio_stream_player.play()

# Anim event callback
func _stop_swing():
	is_swinging = false

	# animation
	character_anim.is_swinging = false

func _light_on():
	_is_lit = true
	rod_flame.visible = true
	rod_flame.playing = true
	
	# audio
	# note we use the same source for all Character SFX, so this will cover the Swing sound (a few frames after)
	audio_stream_player.stream = rod_light_on_sound
	audio_stream_player.play()

func _light_off():
	_is_lit = false
	rod_flame.visible = false
	# do not play animated sprite in the background while invisible
	rod_flame.playing = false

func _on_SwingHitBox_area_entered(area: Area2D):
	if not _is_lit:
		if area.get_collision_layer_bit(Layer.FIRE_SOURCE):
			# we touched a fire source, light rod on
			_light_on()
	else:
		if area.get_collision_layer_bit(Layer.IGNITABLE):
			# we touched a fire source, light rod on
			var fire_pit := area.get_parent() as FirePit
			fire_pit.ignite()

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name.begins_with("Character_Swing_"):
		_stop_swing()
