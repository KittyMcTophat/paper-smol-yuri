extends KinematicBody

export var full_turn_time : float = 0.5;

onready var _sprite_3d: Sprite3D = $Sprite3D;
onready var _tween_node: Tween = $Tween;

# uses the Tween node to rotate the sprite smoothly
func _turn(target_rotation: float, dead_zone: float = 5.0) -> void:
	var current_rotation: Vector3 = _sprite_3d.transform.basis.get_euler();
	var distance_to_rotate: float = abs(target_rotation - rad2deg(current_rotation.y));
	
	# cancels the rotation if it is within the dead zone
	if (distance_to_rotate < dead_zone || abs(distance_to_rotate - 360) < dead_zone):
		return;
	
	# if it would be quicker, rotates the other way
	if (distance_to_rotate > 180):
		target_rotation -= 360;
		distance_to_rotate = abs(target_rotation - rad2deg(current_rotation.y));
	
	# calculates the duration of the tween to maintain consistent rotational velocity
	var duration: float = full_turn_time * (distance_to_rotate / 360);
	
	# applies the tween
	var target_rotation_vector: Vector3 = Vector3(current_rotation.x, target_rotation, current_rotation.z);
# warning-ignore:return_value_discarded
	_tween_node.interpolate_property(_sprite_3d, "rotation_degrees",\
	null, target_rotation_vector, duration, Tween.TRANS_LINEAR);
# warning-ignore:return_value_discarded
	_tween_node.start();
