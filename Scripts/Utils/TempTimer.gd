# Temporary timer to place under node when working with a coroutine affecting that node,
# so it gets cleared when node is cleared and we don't try to continue coroutine on invalid
# reference, causing error
# > resume: Resumed function '_play_intro_sequence()' after yield, but class instance is gone
# Source: https://github.com/godotengine/godot/issues/24311#issuecomment-1059531870
extends Reference
class_name TempTimer

class FrameTimer_ extends Node:
	signal timeout

	var frames := 1

	func _ready() -> void:
		var _err = get_tree().connect("idle_frame", self, "_on_timeout")

	func _on_timeout() -> void:
		frames -= 1
		if frames == 0:
			emit_signal("timeout")
			queue_free()

static func idle_frame(node:Node, frames:int = 1):
	var t   := FrameTimer_.new()
	t.frames = frames
	node.add_child(t)
	
	return t

# Usage
# Instead of:
#	yield(get_tree().create_timer(seconds), "timeout")
# write:
#	yield(TempTimer.idle_frame(self, FPS*seconds (rounded to nearest int)), "timeout")

# My alternative using Godot native Timer, if you don't need idle_frame

static func create_timer_under(node: Node, duration: float):
	var temp_timer = Timer.new()
	node.add_child(temp_timer)
	temp_timer.start(duration)
	return temp_timer
	
# Usage
# Instead of:
#	yield(get_tree().create_timer(seconds), "timeout")
# write:
#	yield(TempTimer.create_timer_under(node, seconds), "timeout")
# where node is some node with lifetime in sync with when we want to keep running the coroutine
# (typically the object affected by coroutine, or an object with same lifetime)
