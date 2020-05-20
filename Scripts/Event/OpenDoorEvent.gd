extends Event

# Path to door sprite
export(NodePath) var sprite_path

# Swing Audio Clip
export(AudioStream) var victory_jingle

# Door sprite (derived from sprite_path)
var _sprite: Sprite

onready var jingle_player := $"/root/Dungeon/JinglePlayer" as AudioStreamPlayer
onready var collision_shape := $StaticBody2D/CollisionShape2D as CollisionShape2D

func _ready():
	_sprite = get_node(sprite_path) as Sprite
	NodeUtils.check_node_got_by_path(_sprite, "OpenDoorEvent", self, "Sprite", sprite_path)

# override
func trigger():
	_sprite.visible = false
	collision_shape.disabled = true
	
	# audio
	jingle_player.stream = victory_jingle
	jingle_player.play()
