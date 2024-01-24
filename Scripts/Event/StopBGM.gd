extends Event

export(float) var fade_out_duration = 1.0

var _tween_volume_to_zero: SceneTreeTween

onready var music_player := $"%MusicPlayer" as AudioStreamPlayer
onready var tween: Tween = $"Tween"

# override
func trigger():
	# audio
	_init_tween_fade_out()


func _init_tween_fade_out():
	# Make sure to interpolate linear value linearly, then apply log (linear2db) on top of it,
	# by passing a callback on self instead of property "volume_db" directly
	# Since only a Godot 3 old Tween node supports interpolate_method, not a SceneTreeTween, we use that
	# See https://github.com/godotengine/godot-proposals/issues/5065
	tween.remove_all()
	tween.interpolate_method(self, "_interpolate_music_volume", 1.0, 0.0, fade_out_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
	
func _interpolate_music_volume(volume_linear: float):
	music_player.volume_db = linear2db(volume_linear)
