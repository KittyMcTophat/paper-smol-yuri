extends Node

signal scene_is_changing;
signal scene_is_reloading;

onready var damage_particle : PackedScene = preload("res://Scenes/Actors/Battle/BaseActors/DamageParticle.tscn");
onready var heal_particle : PackedScene = preload("res://Scenes/Actors/Battle/BaseActors/HealParticle.tscn");
onready var charge_particle : PackedScene = preload("res://Scenes/Actors/Battle/BaseActors/ChargeParticle.tscn");

var money : int = 0;
var cats_found : int = 0;

var text_speed : float = 0.033;

var allow_pause : bool = true;
var allow_jump : bool = true;
var first_load : bool = true;

var current_level_controller : LevelController = null;

var coin_counter : CoinCounter = null;
var dialogue_box : DialogueBox = null;
var pause_menu : PauseMenu = null;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	
	add_child(preload("res://Scenes/GUI/AllGUI.tscn").instance());
	
	coin_counter = $AllGUI/CoinCounter;
	dialogue_box = $AllGUI/DialogueSystem;
	pause_menu = $AllGUI/PauseMenu;
	
	randomize();

func load_scene(scene: String):
#warning-ignore:RETURN_VALUE_DISCARDED
	var next_scene : PackedScene = load(scene);
	
	_pause_the_stuff();
	
	current_level_controller.fade_rect_anim_player.play("Fade_In");
	yield(current_level_controller.fade_rect_anim_player, "animation_finished");
	yield(get_tree(), "idle_frame");
	
	emit_signal("scene_is_changing");
	
	first_load = true;
	get_tree().change_scene_to(next_scene);
	money = coin_counter.get_money();
	
	_unpause_the_stuff();

func reload_scene():
	_pause_the_stuff();
	
	current_level_controller.fade_rect_anim_player.play("Fade_In");
	yield(current_level_controller.fade_rect_anim_player, "animation_finished");
	yield(get_tree(), "idle_frame");
	
	emit_signal("scene_is_reloading");
	
	first_load = false;
#warning-ignore:RETURN_VALUE_DISCARDED
	get_tree().reload_current_scene();
	coin_counter.set_money(money);
	
	_unpause_the_stuff();

func _pause_the_stuff():
	allow_pause = false;
	allow_jump = false;
	get_tree().paused = true;

func _unpause_the_stuff():
	allow_pause = true;
	allow_jump = true;
	get_tree().paused = false;
