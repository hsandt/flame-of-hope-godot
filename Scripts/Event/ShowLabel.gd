extends Event

# Path to door
export(NodePath) var label_path
export(float) var fade_in_duration = 1.0
# if stay duration <= 0, keep label forever
export(float) var stay_duration = 0.0
export(float) var fade_out_duration = 0.0

# Door sprite (derived from label_path)
var _label: Label

# Flag to remember not to trigger twice
var _triggered: bool = false

func _ready():
	_label = get_node(label_path) as Label
	NodeUtils.assert_node_got_by_path(_label, "ShowLabel", self, "Label", label_path)

# override
func trigger():
	# Don't trigger twice
	if _triggered:
		return
	
	_triggered = true
	
	_label.visible = true
	var modulate_tween := get_tree().create_tween()
	modulate_tween.tween_property(_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), fade_in_duration) \
		.from(Color(1.0, 1.0, 1.0, 0.0))
		
	if stay_duration > 0.0:
		# stay
		modulate_tween.tween_interval(stay_duration)
		# fade out
		modulate_tween.tween_property(_label, "modulate", Color(1.0, 1.0, 1.0, 0.0), fade_out_duration)
