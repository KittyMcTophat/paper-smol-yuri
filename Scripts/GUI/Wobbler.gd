extends CanvasLayer

class_name Wobbler

onready var material : ShaderMaterial = $ColorRect.material;
onready var tween : Tween = $Tween;

var target_wobble : float = 0.0;

func _ready():
	set_wobbling_intensity(0.0, 0.0);

func set_wobbling_intensity(amount : float, time : float = 1.0):
	$ColorRect.visible = true;
# warning-ignore:return_value_discarded
	tween.stop_all();
# warning-ignore:return_value_discarded
	tween.interpolate_property(material, "shader_param/max_pixel_offset",\
	material.get_shader_param("max_pixel_offset"), amount, time);
# warning-ignore:return_value_discarded
	tween.start();
	target_wobble = amount;

func _on_Tween_tween_completed(_object, _key):
	material.set("shader_param/max_pixel_offset", target_wobble);
	if (target_wobble == 0.0):
		$ColorRect.visible = false;
		material.set("shader_param/max_pixel_offset", 0.0);
	# warning-ignore:return_value_discarded
		tween.stop_all();
