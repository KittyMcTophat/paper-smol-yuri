extends Spatial

onready var _raycast : RayCast = $RayCast;
onready var _sprite3D : Sprite3D = $Sprite3D;

func _physics_process(_delta):
	_raycast.force_raycast_update();
	
	if (_raycast.is_colliding()):
		_sprite3D.global_transform.origin = _raycast.get_collision_point();
		_sprite3D.transform.origin.y += 0.01
		
		#global_transform = align_y_axis(global_transform, _raycast.get_collision_normal());
		
		_sprite3D.visible = true;
	else:
		_sprite3D.visible = false;

func align_y_axis(xform: Transform, new_y: Vector3) -> Transform:
	xform.basis.y = new_y;
	xform.basis.x = -xform.basis.z.cross(new_y);
	xform.basis = xform.basis.orthonormalized();
	return xform;
