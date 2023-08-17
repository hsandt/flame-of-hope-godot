# Alternative to Timer to use in contexts where the Timer is used by a coroutine
# that works on certain nodes, but the nodes may be freed in the middle of the coroutine
# (due to game restart, etc.)
# 
# This is a temporary timer that you should place with static function
# `TimerUtils.create_temp_timer_under` so it is placed under some representative node
# affected by the coroutine, and freed when the node is freed, thus avoiding
# an error due to coroutine trying to access the freed node:
# > resume: Resumed function 'my_coroutine()' after yield, but class instance is gone
#
# This simulates what SceneTreeTimer does (auto-free on timeout) while having
# a proper timer node placed under a parent so it gets freed with it.
#
# Adapted from https://github.com/godotengine/godot/issues/24311#issuecomment-1059531870
#
# USAGE
# See TimerUtils.gd
extends Timer
class_name TempTimer

func _ready() -> void:
	# Temporary timers are always one-shot
	one_shot = true
	
	# Free itself on timeout, if parent node was not already freed
	var _err = connect("timeout", self, "_on_timeout")

func _on_timeout() -> void:
	queue_free()
