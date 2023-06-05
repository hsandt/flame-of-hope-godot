extends Node

export(PackedScene) var temp_sfx_player_prefab

onready var dungeon = $"/root/Dungeon" as Node2D

func spawn_sfx(audio_stream: AudioStream):
	assert(audio_stream != null, "SFXManager.spawn_sfx: expected audio_stream")
	var temp_sfx_player: TempSFXPlayer = temp_sfx_player_prefab.instance()
	dungeon.add_child(temp_sfx_player)
	temp_sfx_player.play(audio_stream)
