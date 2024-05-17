extends Area2D
@onready var use_sound = $UseSound

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_body_entered(body):
	use_sound.play()
	body.health += 25
	
	use_sound.play()
	remove_from_group("Potions")
	set_deferred("monitoring", false)
	visible = false



func _on_use_sound_finished():
	queue_free()
