extends Spatial

onready var _raycast : RayCast = $RayCast;
onready var _sprite3D : Sprite3D = $Sprite3D;

func _process(delta):
	if (_raycast.is_colliding()):
		_sprite3D.global_transform.origin = _raycast.get_collision_point();
		_sprite3D.transform.origin.y += 0.01
		_sprite3D.visible = true;
	else:
		_sprite3D.visible = false;
