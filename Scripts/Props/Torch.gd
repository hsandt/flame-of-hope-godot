tool
class_name Torch
extends Ignitable

# Tool preview only (we play full animation via AnimationPlayer at runtime)
var sf_torch_lit := preload("res://Anims/Props/SF_Torch_Lit.tres") as SpriteFrames
var sf_torch_unlit := preload("res://Anims/Props/SF_Torch_Unlit.tres") as SpriteFrames

onready var animated_sprite := $AnimatedSprite as AnimatedSprite
onready var flame_timer := $FlameTimer as Timer
onready var fire_source_collision_shape := $FireSourceArea2D/FireSourceCollisionShape2D as CollisionShape2D
onready var ignitable_collision_shape := $IgnitableArea2D/IgnitableCollisionShape2D as CollisionShape2D

# When false, hide and disable ignitable collider on start
export var activated_on_start: bool = true


func _ready():
	# In Godot 3, _ready is called on parent then on child without the need for
	# super call. We could override existing _setup method, but then this would
	# be called at parent _ready time, where child ignitable_area_collision_shape
	# is still null, causing error
	# So better use the local _ready
	# We assume torches are all activated (visible, collision shapes enabled)
	# in scene, so only deactivate if needed
	if not activated_on_start:
		deactivate()

# override
func can_light_on_start():
	# prevent lighting on start if not activated on start
	return activated_on_start
	
# Show and enable collider (this is unrelated to ignition state)
func activate():
	animation_player.play("Torch_Unlit")

# Hide sprite and disable collider (this is unrelated to ignition state, but we assume
# torch is unlit when this happens, as this should only happen on start with activated_on_start
# false, and lit_on_start also false to be clean)
func deactivate():
	# This should set sprite visible = false, and disable all collision shapes
	animation_player.play("Torch_Hidden")

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

