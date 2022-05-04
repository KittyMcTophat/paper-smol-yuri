extends Actor

class_name InteractableActor

signal dialogue_ended;

export var interact_on_ready: bool = false;
export var only_on_first_load: bool = false;
export(String, FILE, "*.json") var dialogue_file : String = "";
export var use_export_dialogue_instead : bool = false;
export(String, MULTILINE) var exported_dialogue : String = """[
	{"speaker":"lmao", "text":"i forgot to replace this text"}
]""";

onready var exclamation_mark: Sprite3D = $ExclamationMark;

var is_player_in_range : bool = false;

func _ready():
	if (interact_on_ready):
		if (only_on_first_load && Global.first_load == false):
				emit_signal("dialogue_ended");
				return;
		if (Global.get_node_or_null("AllGUI/SplashScreen")):
		#warning-ignore:RETURN_VALUE_DISCARDED
			Global.get_node("AllGUI/SplashScreen").connect("splash_screen_over", self, "_interact");
		else:
			_interact();

func _process(_delta):
	if (is_player_in_range && Input.is_action_just_pressed("ui_accept")):
		_interact();

func _interact():
	if (!use_export_dialogue_instead):
		var file_read : File = File.new();
#warning-ignore:RETURN_VALUE_DISCARDED
		file_read.open(dialogue_file, File.READ);
		Global.dialogue_box.start_dialogue(parse_json(file_read.get_as_text()), self);
		file_read.close();
	else:
		Global.dialogue_box.start_dialogue(parse_json(exported_dialogue), self);

func _dialogue_over():
	emit_signal("dialogue_ended");

func _on_InteractableArea_body_entered(_body):
	is_player_in_range = true;
	exclamation_mark.visible = true;
	Global.allow_jump = false;

func _on_InteractableArea_body_exited(_body):
	is_player_in_range = false;
	exclamation_mark.visible = false;
	Global.allow_jump = true;
