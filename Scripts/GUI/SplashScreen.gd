extends Control

onready var anim_player : AnimationPlayer = $AnimationPlayer;

func _ready():
	Global.allow_pause = false;
	get_tree().paused = true;

func _on_Timer_timeout():
	anim_player.play("FadeOut");

func _kill():
	Global.allow_pause = true;
	get_tree().paused = false;
	queue_free();
