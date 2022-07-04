extends Spatial

class_name HealthBar3D

onready var health_bar_2d : HealthBar2D = $Viewport/HealthBar;
onready var viewport : Viewport = $Viewport;

export var max_health : int = 10;
export var current_health : int = 10;
export var display_number : bool = true;
export var health_bar_size : Vector2 = Vector2(80, 24);

export (Color) var healthy_color : Color = Color.forestgreen;
export (Color) var caution_color : Color = Color.gold;
export (Color) var danger_color : Color = Color.crimson;
export (Color) var easing_color_damage : Color = Color.red;
export (Color) var easing_color_heal : Color = Color.green;
export (Color) var text_color : Color = Color.black;

export (float, 0, 1, 0.05) var caution_zone : float = 0.5;
export (float, 0, 1, 0.05) var danger_zone : float = 0.2;

func _ready():
	health_bar_2d.max_health = self.max_health;
	health_bar_2d.current_health = self.current_health;
	health_bar_2d.display_number = self.display_number;
	
	health_bar_2d.healthy_color = self.healthy_color;
	health_bar_2d.caution_color = self.caution_color;
	health_bar_2d.danger_color = self.danger_color;
	health_bar_2d.easing_color_damage = self.easing_color_damage;
	health_bar_2d.easing_color_heal = self.easing_color_heal;
	health_bar_2d.text_color = self.text_color;
	
	health_bar_2d.caution_zone = self.caution_zone;
	health_bar_2d.danger_zone = self.danger_zone;
	
	health_bar_2d._ready();
	
	viewport.size = health_bar_size;
	$MeshInstance.mesh.size = health_bar_size / 100.0;

func _update_health(new_health : int, do_tween : bool = true) -> int:
	current_health = health_bar_2d._update_health(new_health, do_tween);
	
	return current_health;

func _update_max_health(new_max_health : int):
	max_health = new_max_health;
	
	health_bar_2d._update_max_health(new_max_health);

func _show_number():
	health_bar_2d._show_number();
	display_number = true;
	
func _hide_number():
	health_bar_2d._hide_number();
	display_number = false;
