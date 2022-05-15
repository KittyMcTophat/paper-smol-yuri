extends CanvasLayer

class_name Wobbler

onready var material : ShaderMaterial = $ColorRect.material;
onready var tween : Tween = $Tween;

func _ready():
	#$ColorRect.visible = false;
	set_wobbling_intensity(0.0, 0.0);

func set_wobbling_intensity(amount : float, time : float = 1.0):
	$ColorRect.visible = true;
# warning-ignore:return_value_discarded
	tween.interpolate_property(material, "shader_param/max_pixel_offset", null, amount, time);
# warning-ignore:return_value_discarded
	tween.start();

func _on_Tween_tween_completed(_object, _key):
	if (material.get_shader_param("max_pixel_offset") == 0):
		$ColorRect.visible = false;
