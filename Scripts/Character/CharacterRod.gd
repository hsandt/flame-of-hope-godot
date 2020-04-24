class_name CharacterRod
extends Node

# Swing Audio Clip
export var swing_sound: AudioStream
	
# Rod Light On Audio Clip
export var rod_light_on_sound: AudioStream

var _is_lit: bool
var is_swinging: bool

# Swing Hitbox, used in Circle Overlap test
onready var swing_hitbox: Area2D = $"../SwingHitBox"
	
# Rod Flame, activated when rod is lit
onready var rod_flame: CanvasItem = $"../RodFlame"
onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
#onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"
onready var character_control: CharacterControl = $"../CharacterControl"
onready var character_anim: CharacterAnim = $"../CharacterAnim"
func _ready():
	_setup()

func _setup():
	# allows to work with Flame active in the editor, but deactivate on start
	call_deferred("_light_off")
	is_swinging = false

func _physics_process(_delta):
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
	character_anim.anim_base_name = "Swing"
	
	# audio
#	audio_stream_player.stream = swing_sound
#	audio_stream_player.play()

func _swing_hit():
	swing_hitbox.set_block_signals(false)
	# if not _is_lit:
	# 	# we don't check for triggers specifically, anyway all Fire Sources should be triggers
	# 	int resultsCount = Physics2D.OverlapCircleNonAlloc(
	# 		(Vector2)swing_hitbox.transform.position + swing_hitbox.offset,
	# 		swing_hitbox.radius, PhysicsResults,
	# 		Layers.FireSourceMask)
	# 	if resultsCount > 0:

	# else
	# 	# rod is lit, it can ignite via ignitors
	# 	# we don't check for triggers specifically, anyway all Ignitors should be triggers
	# 	int resultsCount = Physics2D.OverlapCircleNonAlloc(
	# 		(Vector2)swing_hitbox.transform.position + swing_hitbox.offset,
	# 		swing_hitbox.radius, PhysicsResults,
	# 		Layers.IgnitorMask)
		
	# 	for (int i = 0 i < resultsCount i++)
	# 		var ignitor = PhysicsResults[i].GetComponentOrFail<Ignitor>()
	# 		ignitor.Ignite()

func _on_swing_hitbox_enter(other):
	if not _is_lit:
		if other.layer == "FireSource":
			# we touched a fire source, light rod on
			_light_on()
	else:
		if other.layer == "Ignitor":
			# we touched a fire source, light rod on
			other.Ignite()

# Anim event callback
func _stop_swing():
	is_swinging = false

	# animation
	character_anim.anim_base_name = "Idle"

func _light_on():
	_is_lit = true
	rod_flame.SetActive(true)
	
	# audio
	# note we use the same source for all Character SFX, so this will cover the Swing sound (a few frames after)
#	audio_stream_player.stream = rod_light_on_sound
#	audio_stream_player.play()

func _light_off():
	_is_lit = false
	rod_flame.playing = false
	rod_flame.visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	print(anim_name)
	if anim_name.begins_with("Character_Swing_"):
		_stop_swing()
