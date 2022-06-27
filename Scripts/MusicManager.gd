extends Node

onready var tween : Tween = Tween.new();
onready var current_music_player : AudioStreamPlayer = AudioStreamPlayer.new();

func _ready():
	pause_mode = PAUSE_MODE_PROCESS;
	
	add_child(tween);
	add_child(current_music_player);

func change_music(new_music : AudioStream, trans_time : float = 0.0):
	if (new_music != null && current_music_player.stream != null):
		if (current_music_player.stream.resource_path == new_music.resource_path):
			return;
	
	var prev_music_player : AudioStreamPlayer = null;
	
	prev_music_player = current_music_player;
	current_music_player = AudioStreamPlayer.new();
	add_child(current_music_player);
	current_music_player.stream = new_music;
	current_music_player.play();
	
	if trans_time <= 0.0:
		prev_music_player.queue_free();
		return;
	
# warning-ignore:return_value_discarded
	tween.interpolate_property(current_music_player, "volume_db", -100.0, 0.0, trans_time, Tween.TRANS_LINEAR);
# warning-ignore:return_value_discarded
	tween.interpolate_property(prev_music_player, "volume_db", null, -100.0, trans_time, Tween.TRANS_LINEAR);
# warning-ignore:return_value_discarded
	tween.start();
	
	yield(tween, "tween_all_completed");
	
	prev_music_player.queue_free();
