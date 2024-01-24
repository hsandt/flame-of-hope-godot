extends CanvasLayer


func _ready():
	if not OS.has_feature("debug"):
		visible = false
