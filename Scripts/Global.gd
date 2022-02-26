extends Node

var money : int = 0;

var text_speed : float = 0.1;

var allow_pause : bool = true;

var add_money : FuncRef = null;

onready var coin_counter : Control = preload("res://Scenes/GUI/CoinCounter.tscn").instance();
onready var dialogue_box : Control = preload("res://Scenes/GUI/DialogueSystem.tscn").instance();
onready var pause_menu : Control = preload("res://Scenes/GUI/PauseMenu.tscn").instance();

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	
	add_child(coin_counter);
	add_child(dialogue_box);
	add_child(pause_menu);
	
	add_child(preload("res://Scenes/GUI/SplashScreen.tscn").instance());
