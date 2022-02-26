extends Control

var is_active : bool = false;

onready var speaker : Label = $MarginContainer/DialogueBox/MarginContainer/VBoxContainer/Speaker;
onready var dialogue : Label = $MarginContainer/DialogueBox/MarginContainer/VBoxContainer/Dialogue;

var current_dialogue : File = null;



func advance_text() -> void:
	pass
