extends Spatial

func _set_name(name : String):
	var viewport : Viewport = $Viewport;
	var margin_container = $Viewport/NinePatchRect/CenterContainer/MarginContainer;
	
	margin_container.get_node("Label").text = name;
	yield(margin_container, "resized");
	viewport.size = margin_container.rect_size;
	
	var quad_mesh : QuadMesh = $MeshInstance.mesh;
	
	quad_mesh.set_size(Vector2(viewport.size.x / 100.0, viewport.size.y / 100.0));
	quad_mesh.set_center_offset(Vector3(0.0, quad_mesh.size.y / 2.0, 0.0));
