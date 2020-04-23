extends "res://addons/gut/test.gd"

var control : CharacterControl

func before_all():
	control = CharacterControl.new()
	control.input_min_threshold = 0.2

func test_get_binarized_value_below_threshold():
	assert_eq(control._get_binarized_value(0.1), 0.0, "Input below threshold should be binarized to 0.")
	
func test_get_binarized_value_equal_threshold():
	assert_eq(control._get_binarized_value(0.2), 1.0, "Input equal to threshold should be binarized to 0.")
	
func test_get_binarized_value_above_threshold():
	assert_eq(control._get_binarized_value(0.3), 1.0, "Input above threshold should be binarized to 0.")
