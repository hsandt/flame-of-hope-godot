class_name NodeUtils

# Check if node is not null and return true if so.
# Else, print error and return false.
# This is meant for nodes obtained with:
#   node = get_node(path) as NodeType
# `node`: get_node result
# `script_type`: type of script that called get_node, as a string
# `script`: script that called get_node (should be `self`
#   in caller context)
# `node_type`: NodeType as a string
# `node_path`: path passed to get_node
static func check_node_got_by_path(node, script_type, script, node_type, node_path):
	if node:
		return true
	else:
		print(("ERROR: {script_type} '{script_path}' references {node_type} " +
				"with path: '{node_path}', but there is no {node_type} there.").format({
			"script_type": script_type,
			"script_path": script.get_path(),
			"node_type": node_type,
			"node_path": node_path
		}))
		return false
