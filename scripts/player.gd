class_name Player extends CharacterBody2D

@export var speed := 15.0
@export var max_speed := 370.0
@export var rot_speed := 260.0
@onready var muzzle = $Muzzle
@onready var sprite_2d = $Sprite2D
@onready var cshape = $CollisionShape2D

var laser_sn = preload("res://scenes/laser.tscn")
var shoot_timer := 0.15
var shoot_cd := false
var alive := true

signal laser_shot(laser)
signal died

func _process(delta):
	if !alive:
		return
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot_lasers()
			await get_tree().create_timer(shoot_timer).timeout
			shoot_cd = false			

func _physics_process(delta):
	if !alive:
		return
	# get inputs
	var input_vector := Vector2(0, Input.get_axis("forward","backward"))
	velocity += input_vector.rotated(rotation) * speed
	velocity = velocity.limit_length(max_speed)
	
	# rotate the ship
	if Input.is_action_pressed("right"):
		rotate(deg_to_rad(rot_speed * delta))
	if Input.is_action_pressed("left"):
		rotate(deg_to_rad(-rot_speed * delta))
		
	# stop the ship
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 4)
	
	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0


func shoot_lasers():
	if !alive:
		return
	var laser = laser_sn.instantiate()
	laser.global_position = muzzle.global_position
	laser.rotation = rotation
	emit_signal("laser_shot", laser)

func die():
	if alive == true:
		alive = false
		emit_signal("died")
		sprite_2d.visible = false
		cshape.set_deferred("disabled", true)

		
func respawn(pos):
	if alive == false:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		sprite_2d.visible = true
		cshape.set_deferred("disabled", false)

