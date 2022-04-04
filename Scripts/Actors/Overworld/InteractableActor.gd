extends Actor

class_name InteractableActor

signal dialogue_ended;

export var interact_on_ready: bool = false;
export(String, FILE, "*.json") var dialogue_file : String = "";

onready var exclamation_mark: Sprite3D = $ExclamationMark;

var dialogue_json_parse : Array = []
var is_player_in_range : bool = false;

func _ready():
	var file_read : File = File.new();
#warning-ignore:RETURN_VALUE_DISCARDED
	file_read.open(dialogue_file, File.READ);
	dialogue_json_parse = parse_json(file_read.get_as_text());
	
	if (interact_on_ready):		
		if (Global.get_node_or_null("SplashScreen")):
		#warning-ignore:RETURN_VALUE_DISCARDED
			Global.get_node("SplashScreen").connect("splash_screen_over", self, "_interact");
		else:
			_interact();

func _process(_delta):
	if (is_player_in_range && Input.is_action_just_pressed("ui_accept")):
		_interact();

func _interact():
	# wait three frames to prevent graphical errors when interact_on_ready is enabled
	for _i in range(3):
		yield(get_tree(), "idle_frame");
	
	Global.dialogue_box.start_dialogue(dialogue_json_parse, self);

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
