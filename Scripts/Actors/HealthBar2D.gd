extends Control

class_name HealthBar2D

onready var health_bar_over : TextureProgress = $NinePatchRect/MarginContainer/HealthBarOver;
onready var health_bar_under : TextureProgress = $NinePatchRect/MarginContainer/HealthBarOver/HealthBarUnder;
onready var health_number_label : Label = $NinePatchRect/MarginContainer/HealthBarOver/Label;
onready var tween : Tween = $Tween;

export var max_health : int = 10;
export var current_health : int = 10;
export var display_number : bool = true;

export (Color) var healthy_color : Color = Color.forestgreen;
export (Color) var caution_color : Color = Color.gold;
export (Color) var danger_color : Color = Color.crimson;
export (Color) var easing_color_damage : Color = Color.red;
export (Color) var easing_color_heal : Color = Color.green;
export (Color) var text_color : Color = Color.black;

export (float, 0, 1, 0.05) var caution_zone : float = 0.5;
export (float, 0, 1, 0.05) var danger_zone : float = 0.2;

func _ready():
	_update_max_health(max_health);
#warning-ignore:RETURN_VALUE_DISCARDED
	_update_health(current_health, false);
	
	health_bar_under.tint_progress = easing_color_damage;
	health_number_label.self_modulate = text_color;
	
	if (display_number):
		_show_number();
	else:
		_hide_number();

func _update_health(new_health : int, do_tween : bool = true) -> int:
	var old_health : int = current_health;
	current_health = int(clamp(new_health, 0, max_health));
	
	_update_health_display(old_health, new_health, do_tween);
	
	return current_health;

func _update_health_display(old_health : int, new_health : int, do_tween : bool) -> void:
	# warning-ignore:return_value_discarded
	tween.stop_all();
	
	_update_label();
	_assign_color();
	
	if (!do_tween):
		health_bar_over.value = current_health;
		health_bar_under.value = current_health;
		return;
	
	if (old_health > new_health):
		health_bar_over.value = current_health;
		health_bar_under.tint_progress = easing_color_damage;
	#warning-ignore:RETURN_VALUE_DISCARDED
		tween.interpolate_property(health_bar_under, "value", null, current_health, 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT);
	#warning-ignore:RETURN_VALUE_DISCARDED
		tween.start();
	
	elif (new_health > old_health):
		health_bar_under.value = current_health;
		health_bar_under.tint_progress = easing_color_heal;
	#warning-ignore:RETURN_VALUE_DISCARDED
		tween.interpolate_property(health_bar_over, "value", null, current_health, 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT);
	#warning-ignore:RETURN_VALUE_DISCARDED
		tween.start();
	
	yield(tween, "tween_completed");
	
	health_bar_over.value = current_health;
	health_bar_under.value = current_health;
	_update_label();
	_assign_color();

func _assign_color():
	if (current_health <= max_health * danger_zone):
		health_bar_over.tint_progress = danger_color;
		return;
	if (current_health <= max_health * caution_zone):
		health_bar_over.tint_progress = caution_color;
		return
	health_bar_over.tint_progress = healthy_color;
	return;

func _update_max_health(new_max_health : int):
	max_health = new_max_health;
	
	health_bar_over.max_value = max_health;
	health_bar_under.max_value = max_health;
	
	_update_label();

func _show_number():
	health_number_label.visible = true;
	display_number = true;
	
func _hide_number():
	health_number_label.visible = false;
	display_number = false;

func _update_label():
	health_number_label.text = "HP:" + str(current_health) + "/" + str(max_health);
