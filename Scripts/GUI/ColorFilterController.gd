extends CanvasLayer

class_name ColorFilterController

export(float, 0.0, 1800.0) var time_to_tween : float = 1.0;

onready var shader_material : ShaderMaterial = $ColorFilterRect.material;
onready var tween : Tween = $Tween;

func set_color(color : String, amount : float):
	var param_path : String = "shader_param/"
	match(color):
		"red", "r":
			param_path += "r_mult";
		"green", "g":
			param_path += "g_mult";
		"blue", "b":
			param_path += "b_mult";
	
# warning-ignore:return_value_discarded
	tween.interpolate_property(shader_material, param_path,\
	null, amount,\
	time_to_tween, Tween.TRANS_SINE);
	
# warning-ignore:return_value_discarded
	tween.start();

func set_grayscale(value : bool):
	if (value):
		print("No colors, gromit!");
		$AnimationPlayer.play("Grayscale On");
		return;
	print("Everyone knows the moon's made of colors...");
	$AnimationPlayer.play("Grayscale Off");
