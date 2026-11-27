extends CharacterBody2D


const SPEED = 200.0 * 4
const JUMP_VELOCITY = -550.0 * 4

var coyote_active: bool
var recursion_lock := false

@export var Bloom_level : TileMapLayer
@export var Gloom_level : TileMapLayer
@export var Spike_level : TileMapLayer
@export var greyscale : ColorRect
@export var death_shader : ColorRect
@onready var player_animation: AnimatedSprite2D = $player_animation


func _ready() -> void:
	self.global_position = CheckpointSystem.checkpoint
	await get_tree().create_timer(0.5).timeout
	Music.spawn()
	Music.Ost_change(false)



# How far the ripple must spread to cover the whole screen (in screen-heights)
const RIPPLE_MAX_RADIUS = 2.5
const RIPPLE_TIME = 0.3

var is_grey := false
var ripple_tween : Tween

var can_move = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2 * 4

# Handle jump.
	if can_move and Input.is_action_just_pressed("ui_accept") and (is_on_floor() or coyote_active):
		velocity.y = JUMP_VELOCITY



# flips the player with directions
	if velocity.x < 0:
		player_animation.flip_h = 1
	elif velocity.x > 0:
		player_animation.flip_h = 0
# Get the input direction and handle the movement/deceleration.
# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and can_move:
		velocity.x = direction * SPEED
		player_animation.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		player_animation.play("default")
		
# coyote time 
# basically stores the state "is_on_floor()" in a var then compares it after the engine updates the values...
# in move_and_slide(). if the values dont match then the player must be falling thus opening the window for coyote...
# if you feel it is way too forgiving just tweak the timer on line 51
	var coyote_is_on_floor = is_on_floor()
	move_and_slide()
	if coyote_is_on_floor != is_on_floor():
		coyote_active = true
		$coyote_timer.start(.15)
func _on_coyote_timer_timeout() -> void:
		coyote_active = false

func restart():
	if recursion_lock == false:
		recursion_lock = true
		can_move = false
		Music._death()
		await get_tree().create_timer(0.4).timeout
		get_tree().reload_current_scene()


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
	#EVERYONE 👥 GET IN ⬇️ THE CAR 🚗 WE ARE LEAVING 🏃🏼THIS TOWN 🌇 NOW!!! 😧 AHHH WHAT THE 😱 IMPOSSIBLE
	#⁉️THIS ISN'T THE CAR 🚗 NOOO 🙅🏼 NOOO 😭 OHH‼️HERMIT PURPLE 💜


# handles switching 
func _unhandled_input(event: InputEvent) -> void:
	if can_move and (event.is_action_pressed("LMB") or event.is_action_pressed("Shift")):
		if is_grey and is_in_wall(): #Cheks if the player is inside the wall before switching
			$"Cant_switch_while_in_wall!".play()
			print("Cant switch while in wall!")
			return
		Gloom_level.collision_enabled = not Gloom_level.collision_enabled
		is_grey = not is_grey
		Spike_level.visible = is_grey
		Music.Ost_change(is_grey)
		_play_ripple(is_grey)

# Managing SFX for switching 
		if is_grey == true:
			$Gloom_switch.play()
		if is_grey == false:
			$Bloom_switch.play()

# tweens the opacity 
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
