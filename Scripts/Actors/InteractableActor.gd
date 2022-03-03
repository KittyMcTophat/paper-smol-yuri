extends "res://Scripts/Actors/Actor.gd"

signal dialogue_ended;

export var interact_on_ready: bool = false;
export(String, FILE, "*.txt") var dialogue_file : String = "";

onready var exclamation_mark: Sprite3D = $ExclamationMark;

var dialogue_array : Array = []
var is_player_in_range: bool = false;

func _ready():
	var file_read : File = File.new();
	file_read.open(dialogue_file, File.READ);
	if (dialogue_file != null):
		while file_read.get_position() < file_read.get_len():
			var next_array : Array = ["",""];
			
			next_array[0] = file_read.get_line();
			next_array[1] = file_read.get_line();
			
			dialogue_array.push_back(next_array);
	
	if (interact_on_ready):
		_interact();

func _process(delta):
	if (is_player_in_range && Input.is_action_just_pressed("ui_accept")):
		_interact();

func _interact():
	Global.start_dialogue.call_func(dialogue_array, funcref(self, "_dialogue_over"));

func _dialogue_over():
	emit_signal("dialogue_ended");

func _on_InteractableArea_body_entered(body):
	is_player_in_range = true;
	exclamation_mark.visible = true;

func _on_InteractableArea_body_exited(body):
	is_player_in_range = false;
	exclamation_mark.visible = false;
