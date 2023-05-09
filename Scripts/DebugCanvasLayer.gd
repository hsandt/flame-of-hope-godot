extends CanvasLayer


onready var level_label := $Level as Label


func _ready():
	if not OS.has_feature("debug"):
		level_label.visible = false
