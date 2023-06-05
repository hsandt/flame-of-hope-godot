class_name TempSFXPlayer
extends Node2D
# Play passed SFX and auto free on SFX end


onready var sfx_player: AudioStreamPlayer = $"SFXPlayer"


func play(audio_stream: AudioStream):
	sfx_player.stream = audio_stream
	sfx_player.play()


func _on_SFXPlayer_finished():
	queue_free()
