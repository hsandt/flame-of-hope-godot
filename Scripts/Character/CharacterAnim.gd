class_name CharacterAnim
extends Node

const CARDINAL_DIRECTION_NAMES = ["Down", "Left", "Up", "Right"]

var anim_base_name := "Idle" setget _set_anim_base_name
var _anim_dir_name := "Down"

onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

func _ready():
	pass

func _update_anim():
	animation_player.play("Character_%s_%s" % [anim_base_name, _anim_dir_name])

func _set_anim_base_name(new_anim_base_name):
	if anim_base_name != new_anim_base_name:
		anim_base_name = new_anim_base_name
		_update_anim()
	
func set_anim_dir(direction: int): # direction: enum CardinalDirection
	var old_anim_dir_name = _anim_dir_name
	_anim_dir_name = CARDINAL_DIRECTION_NAMES[direction]
	if old_anim_dir_name != _anim_dir_name:
		_update_anim()
