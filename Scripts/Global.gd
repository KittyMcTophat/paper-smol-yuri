extends Node

var money : int = 0;

var text_speed : float = 0.033;

var allow_pause : bool = true;
var allow_jump : bool = true;

onready var coin_counter : Control = preload("res://Scenes/GUI/CoinCounter.tscn").instance();
onready var dialogue_box : Control = preload("res://Scenes/GUI/DialogueSystem.tscn").instance();
onready var pause_menu : Control = preload("res://Scenes/GUI/PauseMenu.tscn").instance();

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	
	add_child(coin_counter);
	add_child(dialogue_box);
	add_child(pause_menu);
	
	add_child(preload("res://Scenes/GUI/SplashScreen.tscn").instance());

func load_scene(scene: String):
#warning-ignore:RETURN_VALUE_DISCARDED
	get_tree().change_scene_to(load(scene));
	money = coin_counter.get_money();
	
	allow_pause = true;
	allow_jump = true;
	get_tree().paused = false;

func reload_scene():
#warning-ignore:RETURN_VALUE_DISCARDED
	get_tree().reload_current_scene();
	coin_counter.set_money(money);
	
	allow_pause = true;
	allow_jump = true;
	get_tree().paused = false;
