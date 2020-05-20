extends Node

# List of path of ignitable elements that need to be lit to trigger this event
export(Array, NodePath) var trigger_ignitable_paths

# Path of event triggered by this trigger condition
export(NodePath) var event_path

# Number of ignitables that need to be lit to trigger this event
# (derived from trigger_ignitable_paths)
var _trigger_ignitable_count := 0

# Number of ignitables already lit
var _trigger_ignitable_lit_count := 0

# Event triggered by this trigger condition
# (derived by event_path)
var _event: Event

func _ready():
	var invalid_ignitable_paths := []
	
	for ignitable_path in trigger_ignitable_paths:
		if ignitable_path.is_empty():
			invalid_ignitable_paths.append(ignitable_path)
			print("WARNING: IgnitionEvent '%s' references trigger ignitable with empty path. It will be removed at runtime, but you should delete it in the Inspector" % get_path())
			continue
		
		var ignitable = get_node(ignitable_path)
		if not ignitable:
			invalid_ignitable_paths.append(ignitable_path)
			print("WARNING: IgnitionEvent '%s' references trigger ignitable with path: '%s', but it is null. It will be removed at runtime." % [get_path(), ignitable_path])
			continue
		
		ignitable = ignitable as Ignitable
		if not ignitable:
			invalid_ignitable_paths.append(ignitable_path)
			print("WARNING: Door '%s' references trigger ignitable %s, but it is not an Ignitable. It will be removed at runtime." % [get_path(), ignitable_path])
			continue

			# deferred connection to avoid disabling collision during physics process (only matters for lit signal)
		var error1 = ignitable.connect("lit", self, "_on_trigger_ignitable_lit", [], CONNECT_DEFERRED)
		var error2 = ignitable.connect("unlit", self, "_on_trigger_ignitable_unlit", [], CONNECT_DEFERRED)
		if error1 or error2:
			print("WARNING: Ignitable connection failed with error1: %s and error2: %s. Disconnect will fail later." % [error1, error2])
			continue
		
		# only count valid ignitables to avoid getting stuck in case
		# we prepared an array too big (e.g. size = 4 but filled only 3)
		_trigger_ignitable_count += 1
		
	# cleanup any invalid node path (just so _trigger doesn't have to check them again before disconnect)
	for invalid_ignitable_path in invalid_ignitable_paths:
		trigger_ignitable_paths.erase(invalid_ignitable_path)
		
	_event = get_node(event_path) as Event
	NodeUtils.check_node_got_by_path(_event, "IgnitionEvent", self, "Event", event_path)
			
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
	_event.trigger()
	_disconnect_ignitables()

func _disconnect_ignitables():
	for ignitable_path in trigger_ignitable_paths:
		var ignitable := get_node(ignitable_path)
		ignitable.disconnect("lit", self, "_on_trigger_ignitable_lit")
		ignitable.disconnect("unlit", self, "_on_trigger_ignitable_unlit")
