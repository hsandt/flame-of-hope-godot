extends Node2D


# Initial PFX to play on start
# For delayed PFX, use Timer + callback set_emitting(true)
export(Array, NodePath) var initial_particle_node_paths


func _ready():
	for particle_node_path in initial_particle_node_paths:
		var particle_node = get_node(particle_node_path)
		
		if not particle_node:
			push_error("No node at %s" % particle_node_path)
			continue
			
		var particle = particle_node as CPUParticles2D
		if not particle:
			push_error("Node at %s is not a particle" % particle_node_path)
			continue
		
		particle.emitting = true
