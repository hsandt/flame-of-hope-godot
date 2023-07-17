extends Node

export(PackedScene) var temp_sfx_player_prefab

func spawn_sfx(audio_stream: AudioStream):
	# Retrieve dungeon each time (or at least once after each Restart)
	# instead of just in onready since Restart causes full level reload,
	# which would free dungeon and cause invalid reference on further use
	var dungeon = $"/root/Dungeon" as Node2D
	assert(audio_stream != null, "SFXManager.spawn_sfx: expected audio_stream")
	var temp_sfx_player: TempSFXPlayer = temp_sfx_player_prefab.instance()
	dungeon.add_child(temp_sfx_player)
	temp_sfx_player.play(audio_stream)
