extends Control

signal splash_screen_over;

onready var anim_player : AnimationPlayer = $AnimationPlayer;

func _ready():
	Global.allow_pause = false;
	get_tree().paused = true;

func _on_Timer_timeout():
	anim_player.play("FadeOut");
	Global.allow_pause = true;
	get_tree().paused = false;
	emit_signal("splash_screen_over");

func _kill():
	queue_free();
