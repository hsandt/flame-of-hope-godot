class_name ScaleFlicker
extends Node2D


export(float) var flicker_period = 2.0
export(float) var flicker_max_scale = 1.1
export(float) var scale_to_zero_duration = 0.5

var _tween_flicker: SceneTreeTween
var _tween_scale_to_zero: SceneTreeTween


# Since show_with_flicker and hide_with_scale_to_zero can be called in other scripts'
# _ready, we cannot count on our _ready to initialize stuff (we could wait one frame
# if we really wanted to) instead, we lazily init when we need to with the methods below
	
func _init_tween_flicker():
	_tween_flicker = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	var _scale_tweener1 = _tween_flicker.tween_property(self, "scale", flicker_max_scale * Vector2.ONE, flicker_period / 2.0).from(1.0 * Vector2.ONE)
	var _scale_tweener2 = _tween_flicker.tween_property(self, "scale", 1.0 * Vector2.ONE, flicker_period / 2.0)
	
func _init_tween_scale_to_zero():
	_tween_scale_to_zero = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	var _scale_to_zero_tweener = _tween_scale_to_zero.tween_property(self, "scale", Vector2.ZERO, scale_to_zero_duration)
	var _scale_to_zero_callback = _tween_scale_to_zero.tween_callback(self, "set_visible", [false])
	
func show_with_flicker():
	# cancel any concurrent tween
	if _tween_scale_to_zero != null and _tween_scale_to_zero.is_running():
		_tween_scale_to_zero.stop()

	# actually show the node
	visible = true

	# In Godot 3, we use SceneTreeTweens which cannot be reused after kill/finish
	# because Tween::clear sets valid to false, and it's not reversible
	# (play() would error "Tween invalid. Either finished or created outside scene tree.")
	# In this case _tween_flicker is looping indefinitely so we know it's gonna be valid
	# and we can reuse it, but to be generic and safe, we still check it
	if _tween_flicker != null and _tween_flicker.is_valid():
		# play the existing one
		_tween_flicker.play()
	else:
		# this auto-plays, so no need to play manually
		_init_tween_flicker()

func hide_with_scale_to_zero():
	# cancel any concurrent tween
	if _tween_flicker != null and _tween_flicker.is_running():
		_tween_flicker.stop()
	
	# same principle as show_with_flicker, except _tween_scale_to_zero is
	# a short one-time tween so most of the time after the first tween,
	# it has previously finished and is not valid so we must really check validity
	if _tween_scale_to_zero != null and _tween_scale_to_zero.is_valid():
		_tween_scale_to_zero.play()
	else:
		_init_tween_scale_to_zero()
