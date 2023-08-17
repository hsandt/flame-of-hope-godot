class_name TimerUtils

# This function creates a TempTimer under a node so it supports node deletion
# during a coroutine (see TempTimer.gd).
#
# USAGE
# Instead of:
#	yield(get_tree().create_timer(seconds), "timeout")
# write:
#	yield(TimerUtils.create_temp_timer_under(node, seconds), "timeout")
# where node is some node with lifetime in sync with when we want to keep running the coroutine
# (typically the object affected by coroutine, or an object with same lifetime)

static func create_temp_timer_under(node: Node, duration: float):
	var temp_timer = TempTimer.new()
	node.add_child(temp_timer)
	temp_timer.start(duration)
	return temp_timer
