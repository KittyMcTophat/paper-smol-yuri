extends Sprite3D

onready var health_bar_over : TextureProgress = $Viewport/HealthBar/HealthBarOver;
onready var health_bar_under : TextureProgress = $Viewport/HealthBar/HealthBarUnder;
onready var viewport : Viewport = $Viewport;
onready var tween : Tween = $Viewport/HealthBar/Tween;

export var max_health : int = 100;
export var current_health : int = 100;
export var health_bar_size : Vector2 = Vector2(72, 24);

export (Color) var healthy_color : Color = Color.darkgreen;
export (Color) var caution_color : Color = Color.darkgoldenrod;
export (Color) var danger_color : Color = Color.darkred;
export (Color) var easing_color : Color = Color.darkred;

export (float, 0, 1, 0.05) var caution_zone : float = 0.5;
export (float, 0, 1, 0.05) var danger_zone : float = 0.2;

func _ready():
	texture = viewport.get_texture();
	
	_update_max_health(max_health);
	_update_health(current_health);
	
	health_bar_under.tint_progress = easing_color;
	
	health_bar_over.rect_min_size = health_bar_size;
	health_bar_under.rect_min_size = health_bar_size;
	viewport.size = health_bar_size;

func _update_health(new_health : int):
	current_health = new_health;
	
	health_bar_over.value = current_health;
#warning-ignore:RETURN_VALUE_DISCARDED
	tween.interpolate_property(health_bar_under, "value", null, current_health, 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT);
#warning-ignore:RETURN_VALUE_DISCARDED
	tween.start();
	
	_assign_color();

func _assign_color():
	if (current_health < max_health * danger_zone):
		health_bar_over.tint_progress = danger_color;
		return;
	if (current_health < max_health * caution_zone):
		health_bar_over.tint_progress = caution_color;
		return
	health_bar_over.tint_progress = healthy_color;
	return;

func _update_max_health(new_max_health : int):
	max_health = new_max_health;
	
	health_bar_over.max_value = max_health;
	health_bar_under.max_value = max_health;

func _on_Timer_timeout():
	_update_health(current_health - 10);
