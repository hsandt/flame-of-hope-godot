extends Node


# Parameters

# List of path of ignitable elements that need to be lit to trigger this event
export(Array, NodePath) var trigger_ignitable_paths

# List of path of events triggered simultaneously by this trigger condition
export(Array, NodePath) var event_paths

# List of ignitable elements (derived by trigger_ignitable_paths)
var _trigger_ignitables: Array

# List of events triggered by this trigger condition
# (derived by event_paths)
var _events: Array


# State

# List of ignitable elements currently lit
# This is safer as just counting them as the count sometimes goes out of sync
var _lit_trigger_ignitables: Array

# Number of ignitables already lit (derived from _lit_trigger_ignitables)
var _trigger_ignitable_lit_count := 0


func _ready():
	for ignitable_path in trigger_ignitable_paths:
		var ignitable := get_node(ignitable_path) as Ignitable
		NodeUtils.assert_node_got_by_path(ignitable, "IgnitionTrigger", self, "Ignitable", ignitable_path)
		
		# deferred connection to:
		# 1. avoid disabling collision during physics process (only matters for lit signal)
		# 2. make sure this happens after ignitable's own lit/unlit callback so we can override
		#    FlameTimer behavior in _notify_ignitables_lit_triggered_event
		var error1 = ignitable.connect("lit", self, "_on_trigger_ignitable_lit", [ignitable], CONNECT_DEFERRED)
		var error2 = ignitable.connect("unlit", self, "_on_trigger_ignitable_unlit", [ignitable], CONNECT_DEFERRED)
		if error1 or error2:
			print("WARNING: Ignitable connection failed with error1: %s and error2: %s. Ignoring this ignitable." % [error1, error2])
			continue
		
		# only count valid ignitables to avoid getting stuck in case
		# we prepared an array too big (e.g. size = 4 but filled only 3)
		_trigger_ignitables.append(ignitable)

	for event_path in event_paths:
		var event := get_node(event_path) as Event
		NodeUtils.assert_node_got_by_path(event, "IgnitionTrigger", self, "Event", event_path)
		_events.append(event)

func _on_trigger_ignitable_lit(ignitable : Ignitable):
	var index = _lit_trigger_ignitables.find(ignitable)
	if index >= 0:
		push_error("_on_trigger_ignitable_lit: ignitable %s was just lit " % ignitable +
			"but it was already registered, so don't register it")
		return
	
	# add ignitable to list of lit ones and increment count
	_lit_trigger_ignitables.append(ignitable)
	_trigger_ignitable_lit_count += 1
	
	if _trigger_ignitable_lit_count >= len(_trigger_ignitables):
		# all connected ignitables have been lit, so trigger event(s)
		_trigger_event()

func _on_trigger_ignitable_unlit(ignitable : Ignitable):
	var index = _lit_trigger_ignitables.find(ignitable)
	if index == -1:
		push_error("_on_trigger_ignitable_unlit: ignitable %s was just unlit " % ignitable +
			"but it was never registered in the first place, so don't unregister it")
		return
	
	# remove ignitable from list of list ones and
	# decrement count, but don't "untrigger" the event (e.g. don't close the door)
	# if it has already been triggered, ignitables should have been
	# disconnected anyway
	_lit_trigger_ignitables.remove(index)
	_trigger_ignitable_lit_count -= 1

func _trigger_event():
	for event in _events:
		event.trigger()
	
	_notify_ignitables_lit_triggered_event()
	_disconnect_ignitables()

func _notify_ignitables_lit_triggered_event():
	for ignitable in _trigger_ignitables:
		ignitable.on_lit_triggered_event()

func _disconnect_ignitables():
	for ignitable in _trigger_ignitables:
		ignitable.disconnect("lit", self, "_on_trigger_ignitable_lit")
		ignitable.disconnect("unlit", self, "_on_trigger_ignitable_unlit")
