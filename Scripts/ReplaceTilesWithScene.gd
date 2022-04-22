extends GridMap

export var scene : PackedScene = null;

func _ready():
	for tile_pos in get_used_cells():
		var origin = map_to_world(tile_pos.x, tile_pos.y, tile_pos.z);
		var new_child = scene.instance();
		
		add_child(new_child);
		new_child.transform.origin = origin;
	
	clear();
