extends Node

var money : int = 0;

var add_money : FuncRef = null;

onready var pause_menu : Control = preload("res://Scenes/GUI/PauseMenu.tscn").instance();
onready var coin_counter : Control = preload("res://Scenes/GUI/CoinCounter.tscn").instance();

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	
	add_child(pause_menu);
	add_child(coin_counter);
