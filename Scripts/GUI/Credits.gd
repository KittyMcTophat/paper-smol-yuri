extends Control

signal credits_over;

export var scroll_speed : float = 30.0;
export var speedup_multiplier : float = 8.0;
export var start_delay : float = 2.0;
export var end_delay : float = 2.0;
export var speedup_input : String = "ui_accept";
export(float, 0.0, 1.0) var screen_position : float = 0.5;
export(String, FILE, "*.json") var credits_json = null;
export(Color) var background_color : Color = Color.black;
export(AudioStreamSample) var music : AudioStreamSample = null;

var _last_control : Control = null;
var _is_credits_running : bool = false;

onready var _color_rect : ColorRect = $ColorRect;
onready var _audio_player : AudioStreamPlayer = $AudioStreamPlayer;
onready var _node2d : Node2D = $Node2D;
onready var _vbox : VBoxContainer = $Node2D/VBoxContainer;
onready var _image : TextureRect = $Node2D/VBoxContainer/Image;
onready var _title : Label = $Node2D/VBoxContainer/Title;
onready var _default : Label = $Node2D/VBoxContainer/Default;
onready var _spacing : Label = $Node2D/VBoxContainer/Spacing;

# Called when the node enters the scene tree for the first time.
func _ready():
	_node2d.transform.origin.x = ProjectSettings.get_setting("display/window/size/width") * screen_position;
	_node2d.transform.origin.y = ProjectSettings.get_setting("display/window/size/height") + (scroll_speed * start_delay);
	
	_color_rect.color = background_color;
	
	if (music != null):
		_audio_player.stream = music;
		_audio_player.play(0.0);
	
	var file_read : File = File.new();
#warning-ignore:RETURN_VALUE_DISCARDED
	file_read.open(credits_json, File.READ)
	var json_parse : Array = parse_json(file_read.get_as_text());
	for i in json_parse:
		match i["type"]:
			"Title":
				var new_label : Label;
				new_label = _title.duplicate();
				new_label.text = i["text"];
				_vbox.add_child(new_label);
				_last_control = new_label;
			"Default":
				var new_label : Label;
				new_label = _default.duplicate();
				new_label.text = i["text"];
				_vbox.add_child(new_label);
				_last_control = new_label;
			"Spacing":
				for _j in range(i["amount"]):
					_last_control = _spacing.duplicate();
					_vbox.add_child(_last_control);
			"Image":
				var new_texture : Texture = ResourceLoader.load(i["path"]);
				var new_texture_rect : TextureRect = _image.duplicate();
				new_texture_rect.texture = new_texture;
				new_texture_rect.rect_min_size.x = new_texture.get_width() * i["scale"];
				new_texture_rect.rect_min_size.y = new_texture.get_height() * i["scale"];
				_last_control = new_texture_rect;
				_vbox.add_child(new_texture_rect);
			_:
				pass;
	
	_title.visible = false;
	_default.visible = false;
	_spacing.visible = false;

func _process(delta):
	if (_is_credits_running):
		if (speedup_input == ""):
			_node2d.transform.origin.y -= scroll_speed * delta;
		else:
			if (Input.is_action_pressed(speedup_input)):
				_node2d.transform.origin.y -= scroll_speed * delta * speedup_multiplier;
			else:
				_node2d.transform.origin.y -= scroll_speed * delta;
		
		if (_last_control.get_global_transform().origin.y < -_last_control.rect_size.y - (scroll_speed * end_delay)):
			emit_signal("credits_over");

func _roll_credits():
	_is_credits_running = true;
	
	get_tree().paused = true;
	Global.allow_pause = false;
	
	$AnimationPlayer.play("FadeIn");

func _on_AudioStreamPlayer_finished():
	_audio_player.play(0.0);
