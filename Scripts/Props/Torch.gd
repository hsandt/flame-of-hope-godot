tool
class_name Torch
extends Ignitable

var sf_torch_lit := preload("res://Anims/Props/SF_Torch_Lit.tres") as SpriteFrames
var sf_torch_unlit := preload("res://Anims/Props/SF_Torch_Unlit.tres") as SpriteFrames

# override
func _get_anim_prefix():
	return "Torch"

# override
func _tool_update_preview(new_lit_on_start: bool):
	# in game runtime we play Torch_Lit/Unlit which plays a sub-animation,
	# but for preview in editor, showing 1 frame is enough
	# also, children are not ready on save, so check for node existence
	if has_node("AnimatedSprite"):
		if new_lit_on_start:
			$AnimatedSprite.frames = sf_torch_lit
		else:
			$AnimatedSprite.frames = sf_torch_unlit
	
