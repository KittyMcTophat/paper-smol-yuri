extends Control

onready var _anim_player: AnimationPlayer = $AnimationPlayer;
onready var _resume_button : Button = find_node("ResumeButton");

func _unhandled_input(event):
	if (event.is_action_pressed("pause") && !get_tree().paused && Global.allow_pause):
		pause();

func unpause() -> void:
	_anim_player.play("Unpause");
	get_tree().paused = false;

func pause() -> void:
	_anim_player.play("Pause");
	get_tree().paused = true;

func _on_ResumeButton_pressed():
	unpause();

func _on_RestartLevelButton_pressed():
	unpause();
	Global.reload_scene();

func _on_ToggleFullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen;
	OS.window_borderless = !OS.window_borderless;
	if !OS.window_fullscreen:
		OS.window_size = Vector2(ProjectSettings.get_setting("display/window/size/width"),\
		ProjectSettings.get_setting("display/window/size/height"));
		OS.center_window();
	
func _on_QuitButton_pressed():
	get_tree().quit();

func _on_TextSpeedSlider_value_changed(value):
	Global.text_speed = value;
