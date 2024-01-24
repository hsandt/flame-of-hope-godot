extends Event

onready var player_character := $"/root/Dungeon/Character" as Character

# override
func trigger():
	player_character.control.can_throw_fireball = true
