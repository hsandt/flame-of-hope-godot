extends Area2D


# List of path of events triggered simultaneously by this trigger condition
export(Array, NodePath) var event_paths

# List of events triggered by this trigger condition
# (derived by event_paths)
var _events: Array


func _ready():
	for event_path in event_paths:
		var event := get_node(event_path) as Event
		NodeUtils.assert_node_got_by_path(event, "EnterAreaTrigger", self, "Event", event_path)
		_events.append(event)


func _on_body_entered(_body):
	# call_deferred is important when event.trigger() modifies physics state (e.g. enables or
	# disables a collider, such as open/close door) while we are already checking it,
	# to avoid error such as:
	# > body_set_shape_disabled: Can't change this state while flushing queries.
	# > Use call_deferred() or set_deferred() to change monitoring state instead.
	call_deferred("_trigger_events")


func _trigger_events():
	for event in _events:
		event.trigger()
