tool
class_name FirePit
extends Ignitable

# override
func _get_anim_prefix():
	return "FirePit"

# override
func _tool_update_preview(new_lit_on_start: bool):
	# in game runtime we play FirePit_Lit/Unlit which also changes the Body
	# sprite, but for preview in editor, showing/hiding Flame is enough
	# also, children are not ready on save, so check for node existence
	$FlameBig.visible = new_lit_on_start
