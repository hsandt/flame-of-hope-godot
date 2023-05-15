tool
class_name Torch
extends Ignitable

var sf_torch_lit := preload("res://Anims/Props/SF_Torch_Lit.tres") as SpriteFrames
var sf_torch_unlit := preload("res://Anims/Props/SF_Torch_Unlit.tres") as SpriteFrames

onready var flame_timer := $FlameTimer as Timer

# override
func on_lit_triggered_event():
	# like Zelda, preserve flames forever if the event was triggered
	# thanks to deferred call, we know this is called after _on_Torch_lit
	# so this will be applied last and override timer behavior indeed
	flame_timer.stop()
	
# override
func _get_anim_prefix():
	return "Torch"

# override
func _tool_update_preview(new_lit_on_start: bool):
	# in game runtime we play Torch_Lit/Unlit which plays a sub-animation,
	# but for preview in editor, showing 1 frame is enough
	# also, children are not ready on save, so check for node existence
	if new_lit_on_start:
		$AnimatedSprite.frames = sf_torch_lit
	else:
		$AnimatedSprite.frames = sf_torch_unlit

func _on_Torch_lit():
	# start timer until flame goes off (duration is set in Inspector on FlameTimer)
	# note: if being lit also triggered event, on_lit_triggered_event
	# will be called at the end of the frame to cancel that
	flame_timer.start()

func _on_Torch_rekindle():
	# restart timer to extend burn duration
	flame_timer.start()

func _on_Torch_unlit():
	# stop timer to avoid warning on timeout
	flame_timer.stop()

func _on_FlameTimer_timeout():
	if _is_lit:
		_go_off()
	else:
		print("WARNING: FlameTimer timed out while Torch was not lit, nothing will happen.")

