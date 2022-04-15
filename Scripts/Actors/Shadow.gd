extends Spatial

class_name Shadow

onready var _raycast : RayCast = $RayCast;
onready var _mesh : MeshInstance = $MeshInstance;

func _ready():
	_mesh.visible = false;

func _process(_delta):
	_raycast.force_raycast_update();
	
	if (_raycast.is_colliding()):
		_mesh.global_transform.origin = _raycast.get_collision_point();
		_mesh.transform.origin.y += 0.001
		
		_mesh.visible = true;
	else:
		_mesh.visible = false;
