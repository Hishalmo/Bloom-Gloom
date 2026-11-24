extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -500.0

@export var Bloom_level : TileMapLayer
@export var Gloom_level : TileMapLayer
@export var Spike_level : TileMapLayer
@export var greyscale : ColorRect
@onready var player_animation: AnimatedSprite2D = $player_animation

# How far the ripple must spread to cover the whole screen (in screen-heights)
const RIPPLE_MAX_RADIUS = 2.5
const RIPPLE_TIME = 0.3

var is_grey := false
var ripple_tween : Tween

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2

# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

# flips the player with directions
	if velocity.x < 0:
		player_animation.flip_h = 1
	elif velocity.x > 0:
		player_animation.flip_h = 0
# Get the input direction and handle the movement/deceleration.
# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func is_in_wall() -> bool:
	#Player pos in Vec2. (x,y)
	var world_spot = global_position 
	#Same spot measured from the Gloom layers own corner instead of the worlds origin
	var local_spot = Gloom_level.to_local(world_spot) 
	#Which tile square (column, row) that spot falls in
	var cell = Gloom_level.local_to_map(local_spot)
	# -1 means the square is empty.
	return Gloom_level.get_cell_source_id(cell) != -1
	#Gonna kms


#handles switching 
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB") or event.is_action_pressed("Shift"):
		if is_grey and is_in_wall(): #Cheks if the player is inside the wall before switching
			print("Cant switch while in wall!")
			return
		Gloom_level.collision_enabled = not Gloom_level.collision_enabled
		is_grey = not is_grey
		Spike_level.visible = is_grey
		_play_ripple(is_grey)
#tweens the opacity 
		if is_grey == false:
			var t = create_tween()
			t.tween_property(Gloom_level, "modulate:a",1,0.4)
		else:
			var t = create_tween()
			t.tween_property(Gloom_level, "modulate:a",0.2,0.1)

# Spreads (or shrinks) the greyscale ripple outward from the player's position on screen
func _play_ripple(grey_on: bool) -> void:
	var mat := greyscale.material as ShaderMaterial
	var screen_pos := get_global_transform_with_canvas().origin
	mat.set_shader_parameter("center", screen_pos / get_viewport_rect().size)

# Stop any ripple that is still moving, so quick presses don't fight each other
	if ripple_tween:
		ripple_tween.kill()
	ripple_tween = create_tween()
	ripple_tween.set_trans(Tween.TRANS_SINE)
	ripple_tween.set_ease(Tween.EASE_OUT)

	if grey_on:
		greyscale.visible = true
		ripple_tween.tween_property(mat, "shader_parameter/radius", RIPPLE_MAX_RADIUS, RIPPLE_TIME)
	else:
		ripple_tween.tween_property(mat, "shader_parameter/radius", 0.0, RIPPLE_TIME)
		ripple_tween.tween_callback(func(): greyscale.visible = false)
