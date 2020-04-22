extends Node

# Input Map
# Define input for the following actions:
#   app_toggle_hidpi
#   app_toggle_fullscreen
#   app_take_screenshot
#   app_exit

# Parameters
## If true, auto-switch to fullscreen on standalone game start
export(bool) var auto_fullscreen_in_standalone = false

# Parameters (set on _ready)
## Window initial size, used for hi-dpi resize
var initial_size : Vector2

# State
## is window at 2x resolution?
var hidpi_active = false

func _ready():
	initial_size = OS.window_size
	
	if not OS.window_fullscreen and auto_fullscreen_in_standalone:
		if OS.has_feature("standalone"):
			print("[AppManager] Playing standalone game with auto-fullscreen ON, enabling fullscreen")
			call_deferred("toggle_fullscreen")

func _input(event):
	# let user toggle hi-dpi resolution freely
	# (hi-dpi is hard to detect and resize is hard to force on start)
	if event.is_action_pressed("app_toggle_hidpi"):
		toggle_hidpi()
		
	if event.is_action_pressed("app_toggle_fullscreen"):
		toggle_fullscreen()
		
	if event.is_action_pressed("app_take_screenshot"):
		take_screenshot()
		
	if event.is_action_pressed("app_exit"):
		get_tree().quit()

func toggle_hidpi():
	if hidpi_active:
		# back to normal size
		OS.set_window_size(initial_size)
	else:
		# set hi-dpi size (nothing more than 2x window size)
		OS.set_window_size(initial_size * 2)
		
	# toggle
	hidpi_active = not hidpi_active
	print("[AppManager] Toggled hi-dpi size: %s" % hidpi_active)
	
func toggle_fullscreen():
	OS.window_fullscreen = not OS.window_fullscreen
	print("[AppManager] Toggled fullscreen: %s" % OS.window_fullscreen)
	
func take_screenshot():
	var datetime = OS.get_datetime()
	
	# Make sure all numbers less than 10 are padded with a leading 0 so
	# alphabetical sorting matches sorting by date. Modify in-place.
	for key in ["month", "day", "hour", "minute", "second"]:
		datetime[key] = "%02d" % datetime[key]
	var screenshot_filename = "{year}-{month}-{day}_{hour}-{minute}-{second}.png".format(datetime)
	var screenshot_filepath = "user://Screenshots".plus_file(screenshot_filename)
	
	var dir = Directory.new()
	if dir.open("user://Screenshots") != OK:
		# no Screenshots directory in user dir, make it
		if dir.make_dir("user://Screenshots") != OK:
			print("[AppManager] Failed to make directory user://Screenshots")
	
	save_screenshot_in(screenshot_filepath)

func save_screenshot_in(screenshot_filepath):
	var image = get_viewport().get_texture().get_data()
	# In OpenGL, viewport data is vertically reversed
	image.flip_y()
	image.save_png(screenshot_filepath)
	print("[AppManager] Saved screenshot in %s" % screenshot_filepath)
