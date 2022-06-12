extends Control

class_name DialogueBox

var is_active : bool = false;
var current_line_done : bool = false;

onready var portrait : TextureRect = $MarginContainer/DialogueBox/MarginContainer/HBoxContainer/PortraitBorder/MarginContainer/Portrait;
onready var portrait_border : NinePatchRect = $MarginContainer/DialogueBox/MarginContainer/HBoxContainer/PortraitBorder;
onready var speaker_label : Label = $MarginContainer/DialogueBox/MarginContainer/HBoxContainer/TextContainer/Speaker;
onready var dialogue_label : Label = $MarginContainer/DialogueBox/MarginContainer/HBoxContainer/TextContainer/Dialogue;
onready var anim_player : AnimationPlayer = $AnimationPlayer;

var current_dialogue : Array = [];
var _actor : InteractableActor = null;

var current_line : int = 0;
var current_char : int = 0;
var time_since_last_char : float = 0;

func _process(delta):
	if (!is_active):
		return;
	
	time_since_last_char += delta;
	while (time_since_last_char >= Global.text_speed && !current_line_done):
		print_next_char();

func start_dialogue(dialogue_json : Array, actor : InteractableActor):
	Global.allow_pause = false;
	get_tree().paused = true;
	is_active = true;
	anim_player.play("Show");
	
	current_dialogue = dialogue_json;
	_actor = actor;
	
	current_line = -1;
	current_char = 0;
	
	speaker_label.text = "";
	dialogue_label.text = "";
	
	advance_text();

func end_dialogue():
	Global.allow_pause = true;
	get_tree().paused = false;
	is_active = false;
	anim_player.play("Hide");
	if (_actor != null):
		_actor._dialogue_over();

func advance_text():
	current_line += 1;
	current_char = 0;
	time_since_last_char = 0;
	
	current_line_done = false;
	
	if (current_line >= current_dialogue.size()):
		end_dialogue();
	else:
		if (current_dialogue[current_line].has("speaker")):
			speaker_label.text = current_dialogue[current_line]["speaker"];
		if (current_dialogue[current_line].has("portrait")):
			portrait_border.visible = true;
			if (current_dialogue[current_line]["portrait"] != ""):
				portrait.texture = load(current_dialogue[current_line]["portrait"]);
		else:
			portrait_border.visible = false;

func print_next_char():
	current_char += 1;
	if (current_char >= current_dialogue[current_line]["text"].length()):
		current_line_done = true;
		return;
	dialogue_label.text = current_dialogue[current_line]["text"].substr(0, current_char + 1);
	time_since_last_char -= Global.text_speed;

func _on_AdvanceTextButton_pressed():
	if (current_line_done):
		advance_text();
