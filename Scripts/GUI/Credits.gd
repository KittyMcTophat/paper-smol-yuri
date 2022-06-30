extends CanvasLayer

class_name Credits

signal credits_start;
signal credits_over;

export var scroll_speed : float = 20.0;
export var speedup_multiplier : float = 8.0;
export var start_delay : float = 2.0;
export var end_delay : float = 2.0;
export var speedup_input : String = "ui_accept";
export(float, 0.0, 1.0) var screen_position : float = 0.5;
export(String, FILE, "*.json") var credits_json = null;
export var background_color : Color = Color.black;
export var music : AudioStreamSample = null;
export var fade_out_when_done : bool = false;

var _is_credits_running : bool = false;

onready var _color_rect : ColorRect = $Control/ColorRect;
onready var _vbox : VBoxContainer = $Control/VBoxContainer;

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_x();
	_vbox.rect_position.y = $Control.rect_size.y + (scroll_speed * start_delay);
	
#warning-ignore:RETURN_VALUE_DISCARDED
	get_viewport().connect("size_changed", self, "_update_x");
	
	_color_rect.color = background_color;
	
	var file_read : File = File.new();
#warning-ignore:RETURN_VALUE_DISCARDED
	file_read.open(credits_json, File.READ)
	var json_parse : Array = parse_json(file_read.get_as_text());
	
	var _image : TextureRect = $Control/VBoxContainer/Image;
	var _title : Label = $Control/VBoxContainer/Title;
	var _default : Label = $Control/VBoxContainer/Default;
	var _spacing : Label = $Control/VBoxContainer/Spacing;
	
	for i in json_parse:
		match i["type"]:
			"Title":
				var new_label : Label;
				new_label = _title.duplicate();
				new_label.text = i["text"];
				_vbox.add_child(new_label);
			"Default":
				var new_label : Label;
				new_label = _default.duplicate();
				new_label.text = i["text"];
				_vbox.add_child(new_label);
			"Spacing":
				for _j in range(i["amount"]):
					_vbox.add_child(_spacing.duplicate());
			"Image":
				var new_texture : Texture = ResourceLoader.load(i["path"]);
				var new_texture_rect : TextureRect = _image.duplicate();
				new_texture_rect.texture = new_texture;
				new_texture_rect.rect_min_size.x = new_texture.get_width() * i["scale"];
				new_texture_rect.rect_min_size.y = new_texture.get_height() * i["scale"];
				_vbox.add_child(new_texture_rect);
			_:
				pass;
	
	_title.visible = false;
	_default.visible = false;
	_spacing.visible = false;

func _process(delta):
	if (!_is_credits_running):
		return;
	
	if (speedup_input == ""):
		_vbox.rect_position.y -= scroll_speed * delta;
	else:
		if (Input.is_action_pressed(speedup_input)):
			_vbox.rect_position.y -= scroll_speed * delta * speedup_multiplier;
		else:
			_vbox.rect_position.y -= scroll_speed * delta;
	
	if (_vbox.get_global_transform().origin.y < -_vbox.rect_size.y - (scroll_speed * end_delay)):
		_is_credits_running = false;
		
		get_tree().paused = false;
		Global.allow_pause = true;
		
		emit_signal("credits_over");
		
		if (fade_out_when_done):
			$AnimationPlayer.play("FadeOut");

func _roll_credits():
	_is_credits_running = true;
	
	get_tree().paused = true;
	Global.allow_pause = false;
	
	emit_signal("credits_start");
	
	$AnimationPlayer.play("FadeIn");
	
	MusicManager.change_music(music);

func _update_x():
	_vbox.anchor_left = screen_position;
	_vbox.anchor_right = screen_position;
