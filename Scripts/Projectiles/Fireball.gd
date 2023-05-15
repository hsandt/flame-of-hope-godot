extends KinematicBody2D
class_name Fireball

# Travel speed
export(float) var speed = 64.0

export(PackedScene) var pfx_explosion_prefab

# Current velocity for manual kinematic motion
var velocity : Vector2

# Animated sprite (flame)
onready var animated_sprite := $AnimatedSprite as AnimatedSprite

func _ready():
	animated_sprite.play()

func _physics_process(delta):
	var kinematic_collision2d: KinematicCollision2D = move_and_collide(velocity * delta)
	if kinematic_collision2d:
		# fireball ignites any ignitable
		var ignitable := kinematic_collision2d.collider.get_parent() as Ignitable
		if ignitable:
			ignitable.ignite()
			# Don't spawn PFX Ignite, Ignitable will do it on their side
			# (also on Swing Ignite)
		else:
			# Default explosion PFX (when hitting wall, etc.)
			_spawn_pfx(pfx_explosion_prefab)
		
		# fireball disappears whether it hit an ignitable or some obstacle
		# including FireballBlocker
		queue_free()

func setup(init_position, direction):
	global_position = init_position
	# rotate the flame sprite (not the Fireball root, else the sprite will rotate
	# around the ground center instead of its own center, due to the animated sprite's
	# Transform Position offset to make it look above the ground)
	# we assume no parent is rotated, so rotation = rotation_global
	animated_sprite.rotation_degrees = _get_rotation_degrees(direction)
	velocity = speed * _get_direction_vector(direction)

func _get_rotation_degrees(direction: int) -> float:  # direction: CardinalDirection
	var quarter_index: int
	
	# fireball sprite is originally downward, then turn clockwise by step of 90 degrees
	match direction:
		Enum.CardinalDirection.DOWN:
			quarter_index = 0
		Enum.CardinalDirection.LEFT:
			quarter_index = 1
		Enum.CardinalDirection.UP:
			quarter_index = 2
		_: # Enum.CardinalDirection.RIGHT:
			quarter_index = 3
	
	return 90.0 * quarter_index
	
func _get_direction_vector(direction: int) -> Vector2:  # direction: CardinalDirection
	match direction:
		Enum.CardinalDirection.DOWN:
			return Vector2.DOWN
		Enum.CardinalDirection.LEFT:
			return Vector2.LEFT
		Enum.CardinalDirection.UP:
			return Vector2.UP
		_: # Enum.CardinalDirection.RIGHT:
			return Vector2.RIGHT

func _spawn_pfx(pfx_prefab):
	var pfx = pfx_prefab.instance()
	get_tree().root.get_node("/root/Dungeon").add_child(pfx)
	pfx.global_position = global_position
