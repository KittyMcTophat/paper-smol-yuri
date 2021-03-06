extends Control

class_name PauseMenu

onready var _anim_player: AnimationPlayer = $AnimationPlayer;

var music_pos : float = 0.0;

func _ready():
	#if OS.has_feature("editor"):
	#	Global.text_speed = 0.0;
	#	$ColorRect/CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/TextSpeedSlider.value = 0.0;
	Global.text_speed = $ColorRect/CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/TextSpeedSlider.value;
	
	_update_volume($ColorRect/CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer2/MarginContainer/HBoxContainer/VolumeSlider.value);

func _unhandled_input(event):
	if (event.is_action_pressed("pause") && !get_tree().paused && Global.allow_pause):
		pause();
	if (event.is_action_pressed("toggle_fullscreen")):
		_toggle_fullscreen();

func unpause() -> void:
	_anim_player.play("Unpause");
	get_tree().paused = false;
	#MusicManager.current_music_player.play(music_pos);

func pause() -> void:
	_anim_player.play("Pause");
	get_tree().paused = true;
	#music_pos = MusicManager.current_music_player.get_playback_position();
	#MusicManager.current_music_player.playing = false;

func _on_ResumeButton_pressed():
	unpause();

func _on_RestartLevelButton_pressed():
	unpause();
	Global.reload_scene();

func _on_ToggleFullscreenButton_pressed():
	_toggle_fullscreen();

var is_grayscale : bool = false;

func set_color(color : String, is_on : bool):
	var value : float = 1.0;
	if !is_on:
		value = 0.0
		if (all_color_buttons_off()):
			Global.color_filter.set_grayscale(true);
			is_grayscale = true;
	else:
		if is_grayscale:
			Global.color_filter.set_grayscale(false);
			is_grayscale = false;
	
	Global.color_filter.set_color(color, value);

func all_color_buttons_off() -> bool:
	if $ColorRect/CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/GridContainer/HBoxContainer/RedButton.pressed:
		return false;
	if $ColorRect/CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/GridContainer/HBoxContainer/GreenButton.pressed:
		return false;
	if $ColorRect/CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/GridContainer/HBoxContainer/BlueButton.pressed:
		return false;
	return true;

func _on_RedButton_toggled(button_pressed):
	set_color("red", button_pressed);

func _on_GreenButton_toggled(button_pressed):
	set_color("green", button_pressed);

func _on_BlueButton_toggled(button_pressed):
	set_color("blue", button_pressed);

func _on_QuitButton_pressed():
	get_tree().quit();

func _on_TextSpeedSlider_value_changed(value):
	Global.text_speed = value;

func _toggle_fullscreen():
	OS.window_fullscreen = !OS.window_fullscreen;
	OS.window_borderless = !OS.window_borderless;
	if OS.window_fullscreen:
		$ColorRect/CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/GridContainer/ToggleFullscreenButton.text = "Exit Fullscreen"
	else:
		$ColorRect/CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/GridContainer/ToggleFullscreenButton.text = "Fullscreen"
		OS.window_size = Vector2(ProjectSettings.get_setting("display/window/size/width"),\
		ProjectSettings.get_setting("display/window/size/height"));
		OS.center_window();

func _on_WobbleButton_toggled(button_pressed):
	if (button_pressed):
		Global.wobbler.set_wobbling_intensity(50.0, 10.0);
	else:
		Global.wobbler.set_wobbling_intensity(0.0);

func _on_VolumeSlider_value_changed(value):
	_update_volume(value)

func _update_volume(volume : float):
	volume = abs(volume);
	var bus : int = AudioServer.get_bus_index("Master");
	AudioServer.set_bus_volume_db(bus, linear2db(volume));
