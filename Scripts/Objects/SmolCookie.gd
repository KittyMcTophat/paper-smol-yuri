extends Spatial

class_name SmolCookie

signal cookie_collected;

export (String, FILE, "*.tscn,*.scn") var next_scene : String = "";

func _on_Area_body_entered(_body):
	collect();

func collect():
	emit_signal("cookie_collected");
	if (next_scene != ""):
		Global.load_scene(next_scene);
	else:
		# https://www.youtube.com/watch?v=iVGVXPuO3xQ
		print("No scene, gromit!");
