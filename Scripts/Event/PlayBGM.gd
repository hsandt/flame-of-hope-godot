extends Event

# BGM Audio Clip
export(AudioStream) var bgm

onready var music_player := $"%MusicPlayer" as AudioStreamPlayer

# override
func trigger():
	# audio
	music_player.stream = bgm
	music_player.play()
