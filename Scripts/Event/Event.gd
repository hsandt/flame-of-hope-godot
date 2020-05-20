class_name Event
extends Node

# virtual
func trigger():
	assert(false, "_trigger not overridden in Event subclass {}".format(typeof(self)))
