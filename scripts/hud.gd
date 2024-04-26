extends Control



var ui_life_sn = preload("res://scenes/ui_life.tscn")
@onready var lives_box = $Score/LivesBox
@onready var score = $Score:
	set(value):
		score.text = "Score: " + str(value)

func init_lives(num):
	for ui in lives_box.get_children():
		ui.queue_free()
	for i in num:
		var ul = ui_life_sn.instantiate()
		lives_box.add_child(ul)
