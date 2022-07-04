extends KinematicBody

class_name Actor

export var full_turn_time : float = 0.5;

onready var _sprite_3d : Sprite3D = $Sprite3D;
onready var _tween_node : Tween = $Tween;
onready var _anim_player : AnimationPlayer = $AnimationPlayer;

var _facing_back : bool = false;

# uses the Tween node to rotate the sprite smoothly
func _turn(target_rotation : float, dead_zone : float = 5.0) -> void:
	var current_rotation : Vector3 = _sprite_3d.transform.basis.get_euler();
	var distance_to_rotate : float = abs(target_rotation - rad2deg(current_rotation.y));
	
	# cancels the rotation if it is within the dead zone
	if (distance_to_rotate < dead_zone || abs(distance_to_rotate - 360) < dead_zone):
		return;
	
	# if it would be quicker, rotates the other way
	if (distance_to_rotate > 180):
		target_rotation -= 360;
		distance_to_rotate = abs(target_rotation - rad2deg(current_rotation.y));
	
	# calculates the duration of the tween to maintain consistent rotational velocity
	var duration : float = full_turn_time * (distance_to_rotate / 360);
	
	# applies the tween
	var target_rotation_vector : Vector3 = Vector3(current_rotation.x, target_rotation, current_rotation.z);
# warning-ignore:return_value_discarded
	_tween_node.interpolate_property(_sprite_3d, "rotation_degrees",\
	null, target_rotation_vector, duration, Tween.TRANS_LINEAR);
# warning-ignore:return_value_discarded
	_tween_node.start();

# plays an animation, and uses the back version if needed
func _play_anim(anim_name : String) -> void:
	if (_anim_player == null):
		# https://www.youtube.com/watch?v=iVGVXPuO3xQ
		print("No animation player, gromit!");
		return;
	if (_anim_player.get_animation(anim_name) == null):
		return;
	if (_facing_back):
		# only uses the back vesion of an nimation if one exists
		if (_anim_player.get_animation(anim_name + "_Back") != null):
			anim_name = anim_name + "_Back";
	if (_anim_player.current_animation == anim_name):
		return;

	_anim_player.play(anim_name);

# gets the current animation
func _current_animation() -> String:
	if (_anim_player == null):
		print("No animation player, gromit!");
		return "";
	return _anim_player.current_animation;

# squashes the sprite, then tweens it back to its original scale
func _squash(squash_size : Vector3 = Vector3(1.0, 1.0, 1.0), time : float = 0.3):
	_sprite_3d.scale = squash_size;
# warning-ignore:return_value_discarded
	_tween_node.interpolate_property(_sprite_3d, "scale", squash_size, Vector3(1.0, 1.0, 1.0), time, Tween.TRANS_LINEAR, Tween.EASE_IN);
# warning-ignore:return_value_discarded
	_tween_node.start();

func get_fuckin_launched(v_velocity : float = 6.0, h_velocity : float = 1.5, rot_velocity : float = 7.5, direction : Vector2 = Vector2.ZERO) -> RigidBody:
	var rigidbody : RigidBody = RigidBody.new();
	get_parent().add_child(rigidbody);
	rigidbody.global_transform.origin = self.global_transform.origin
	rigidbody.collision_layer = self.collision_layer;
	rigidbody.collision_mask = self.collision_mask;
	
	for i in get_child_count():
		var child : Node = get_child(i);
		var new_child : Node = child.duplicate();
		rigidbody.add_child(new_child);
		if new_child is Shadow:
			new_child.queue_free();
	
	hide();
	
	if (direction == Vector2.ZERO):
		direction = Vector2(randf() - 0.5, randf() - 0.5);
		direction = direction.normalized();
	
	rigidbody.angular_velocity.y = 0.0;
	rigidbody.angular_velocity.x = direction.x * rot_velocity;
	rigidbody.angular_velocity.z = direction.y * rot_velocity;
	
	rigidbody.linear_velocity.y = v_velocity;
	rigidbody.linear_velocity.x = direction.y * -h_velocity;
	rigidbody.linear_velocity.z = direction.x * h_velocity;
	
	return rigidbody;
