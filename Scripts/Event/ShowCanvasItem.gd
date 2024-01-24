extends Event

# Path to door
export(NodePath) var canvas_item_path
export(float) var fade_in_duration = 1.0
# if stay duration <= 0, keep label forever
export(float) var stay_duration = 0.0
export(float) var fade_out_duration = 0.0

# Door sprite (derived from label_path)
var _canvas_item: CanvasItem

# Flag to remember not to trigger twice
var _triggered: bool = false

func _ready():
	_canvas_item = get_node(canvas_item_path) as CanvasItem
	NodeUtils.assert_node_got_by_path(_canvas_item, "ShowLabel", self, "CanvasItem", canvas_item_path)

# override
func trigger():
	# Don't trigger twice
	if _triggered:
		return
	
	_triggered = true
	
	_canvas_item.visible = true
	var modulate_tween := get_tree().create_tween()
	var _tweener1 = modulate_tween.tween_property(_canvas_item, "modulate", Color(1.0, 1.0, 1.0, 1.0), fade_in_duration) \
		.from(Color(1.0, 1.0, 1.0, 0.0))
		
	if stay_duration > 0.0:
		# stay
		var _tweener2 = modulate_tween.tween_interval(stay_duration)
		# fade out
		var _tweener3 = modulate_tween.tween_property(_canvas_item, "modulate", Color(1.0, 1.0, 1.0, 0.0), fade_out_duration)
