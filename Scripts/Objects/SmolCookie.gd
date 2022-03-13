extends Spatial

export (String, FILE, "*.tscn,*.scn") var next_scene : String = "";

func _on_Area_body_entered(_body):
	collect();

func collect():
	if (next_scene != ""):
		Global.load_scene(next_scene);
	else:
		print("No scene, gromit!");
