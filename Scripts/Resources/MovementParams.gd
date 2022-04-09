extends Resource

class_name MovementParams

export var jump_strength : float = 5.0;
export var movement_speed : float = 4.0;
export var h_velocity_lerp_weight : float = 5.0;
export var midair_h_lerp_multiplier : float = 0.5;
export var vertical_lerp_weight : float = 3.0;
export var kill_y : float = -5.0;
export var midair_jumps : int = 0;
export var allow_moonjump : bool = false;
export var gravity : Vector3 = Vector3(0.0, -9.8, 0.0);
