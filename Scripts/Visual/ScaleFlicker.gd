class_name ScaleFlicker
extends Node2D


export(float) var flicker_period = 2.0
export(float) var flicker_max_scale = 1.1

var _tween: SceneTreeTween


func _init_tween():
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	var _scale_tweener1 = _tween.tween_property(self, "scale", flicker_max_scale * Vector2.ONE, flicker_period / 2.0).from(1.0 * Vector2.ONE)
	var _scale_tweener2 = _tween.tween_property(self, "scale", 1.0 * Vector2.ONE, flicker_period / 2.0)
	
func start_scale_flicker():
	# _on_visibility_changed is called before _ready so we cannot count on the latter
	# to initialize stuff
	# instead, we lazily init when we need to
#	https://github.com/godotengine/godot/issues/73908
	if _tween == null:
		# this auto-plays, so no need to play manually
		_init_tween()
	else:
		# play the existing one
		_tween.play()

func stop_scale_flicker():
	# same as above, except if tween doesn't exist, stop does nothing
# need signal connection in scene
	if _tween != null:
		_tween.stop()

func _on_visibility_changed():
	if visible:
		start_scale_flicker()
	else:
		stop_scale_flicker()
