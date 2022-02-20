extends Control

onready var _anim_player: AnimationPlayer = $AnimationPlayer;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);

func _unhandled_input(event):
	if (event.is_action_pressed("pause") && !get_tree().paused):
		pause();

func unpause() -> void:
	_anim_player.play("Unpause");
	get_tree().paused = false;
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);

func pause() -> void:
	_anim_player.play("Pause");
	get_tree().paused = true;
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

func _on_ResumeButton_pressed():
	unpause();

func _on_ToggleFullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
	OS.window_borderless = !OS.window_borderless
	pass
	
func _on_QuitButton_pressed():
	get_tree().quit();
