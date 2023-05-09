extends Event

# Victory Audio Clip
export(AudioStream) var victory_jingle

onready var jingle_player := $"/root/Dungeon/JinglePlayer" as AudioStreamPlayer

# override
func trigger():
	# audio
	jingle_player.stream = victory_jingle
	jingle_player.play()
