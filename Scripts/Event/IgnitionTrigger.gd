extends Node


# Parameters

# List of path of ignitable elements that need to be lit to trigger this event
export(Array, NodePath) var trigger_ignitable_paths

# List of path of events triggered simultaneously by this trigger condition
export(Array, NodePath) var event_paths

# List of ignitable elements (derived by trigger_ignitable_paths)
var _trigger_ignitables: Array

# Number of ignitables that need to be lit to trigger this event
# (derived from trigger_ignitable_paths)
var _trigger_ignitable_count := 0

# List of events triggered by this trigger condition
# (derived by event_paths)
var _events: Array


# State

# Number of ignitables already lit
var _trigger_ignitable_lit_count := 0


func _ready():
	for ignitable_path in trigger_ignitable_paths:
		var ignitable = get_node(ignitable_path) as Ignitable
		NodeUtils.assert_node_got_by_path(ignitable, "IgnitionTrigger", self, "Ignitable", ignitable_path)
		
		# deferred connection to avoid disabling collision during physics process (only matters for lit signal)
		var error1 = ignitable.connect("lit", self, "_on_trigger_ignitable_lit", [], CONNECT_DEFERRED)
		var error2 = ignitable.connect("unlit", self, "_on_trigger_ignitable_unlit", [], CONNECT_DEFERRED)
		if error1 or error2:
			print("WARNING: Ignitable connection failed with error1: %s and error2: %s. Ignoring this ignitable." % [error1, error2])
			continue
		
		# only count valid ignitables to avoid getting stuck in case
		# we prepared an array too big (e.g. size = 4 but filled only 3)
		_trigger_ignitables.append(ignitable)
		
		_trigger_ignitable_count += 1

	for event_path in event_paths:
		var event := get_node(event_path) as Event
		NodeUtils.assert_node_got_by_path(event, "IgnitionTrigger", self, "Event", event_path)
		_events.append(event)

func _on_trigger_ignitable_lit():
	# increment count, and trigger event if all connected ignitables have been lit
	_trigger_ignitable_lit_count += 1
	if _trigger_ignitable_lit_count >= _trigger_ignitable_count:
		_trigger_event()

func _on_trigger_ignitable_unlit():
	# decrement count, but don't "untrigger" the event
	# if it has already been triggered, ignitables should have been
	# disconnected anyway
	_trigger_ignitable_lit_count -= 1

func _trigger_event():
	for event in _events:
		event.trigger()
	
	_disconnect_ignitables()

func _disconnect_ignitables():
	for ignitable in _trigger_ignitables:
		ignitable.disconnect("lit", self, "_on_trigger_ignitable_lit")
		ignitable.disconnect("unlit", self, "_on_trigger_ignitable_unlit")
