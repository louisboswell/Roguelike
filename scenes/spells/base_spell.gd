extends Node2D

@onready var timer = $Timer

var speed = 100
var damage = 50
var target_pos : Vector2

# Move forward at speed when created
func _ready():
	timer.start()

func _process(delta):
	# Move towards target position
	var direction = target_pos - global_position
	direction = direction.normalized()
	position += direction * speed * delta


func _on_hitbox_area_entered(area:Area2D):
	var target = area.get_parent()

	if is_instance_valid(target) and target.is_in_group("Hostile"):
		target.take_damage(damage)
		queue_free()

func _on_timer_timeout():
	queue_free()
