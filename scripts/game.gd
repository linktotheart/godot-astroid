extends Node2D

@onready var hud = $UI/Hud
@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives := 3:
	set(value):
		lives = value
		hud.init_lives(value)
	
var aestroid_scene = preload("res://scenes/asteroids.tscn")

func _ready():
	lives = 3
	score = 0
	player.connect("laser_shot", on_player_laser_shot)
	player.connect("died", on_player_died)
	for ast in asteroids.get_children():
		ast.connect("exploded", _on_asteroid_exploded)
		
	
func _physics_process(delta):
	if Input.is_action_just_pressed("end"):
		get_tree().reload_current_scene()
	
	
	
func on_player_laser_shot(laser):
	lasers.add_child(laser)

func _on_asteroid_exploded(pos, size, points):
	score += points
	for i in range(2):
		match size:
			Astroid.sizes.LARGE:
				spawn_astroids(pos, Astroid.sizes.MEDIUM)
			Astroid.sizes.MEDIUM:
				spawn_astroids(pos, Astroid.sizes.SMALL)
			Astroid.sizes.SMALL:
				pass
	


func spawn_astroids(pos, size):
	var ast = aestroid_scene.instantiate()
	ast.global_position = pos
	ast.size = size
	ast.connect("exploded", _on_asteroid_exploded)
	#asteroids.add_child(ast)
	asteroids.call_deferred("add_child", ast)
	
func on_player_died():
	lives -= 1
	print(lives)
	if lives <= 0:
		get_tree().reload_current_scene()
	else:
		await get_tree().create_timer(1).timeout
		player.respawn(Vector2(640, 320))
