extends CharacterBody2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var hostile = true
@onready var attacking = false
@onready var progress_bar = $ProgressBar
@onready var hitbox = $Hitbox
@onready var ray_cast_2d = $RayCast2D
@onready var timer = $Timer

var spell = preload("res://scenes/spells/base_spell.tscn")

# Base character stats and attributes
var speed = 50
var health = 100
var armor = 10
var damage = 20
var cast_speed = 0.5
var cast_range = 100


var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	attacking = false
	progress_bar.visible = false
	progress_bar.value = health
	timer.start()


func _process(delta):
	
	
	if attacking and not dead:
		var closest_enemy = null
		var closest_distance = INF

		
		var enemies = get_tree().get_nodes_in_group("Hostile")
		
		if hostile:
			enemies = get_tree().get_nodes_in_group("Friendly")
		
		for enemy in enemies:
			var distance = global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy

		if closest_enemy:
			# Point ray cast to the closest enemy
			ray_cast_2d.target_position = closest_enemy.global_position - global_position
			ray_cast_2d.force_raycast_update()

			# Check if the closest enemy is in range
			if ray_cast_2d.is_colliding() and global_position.distance_to(closest_enemy.global_position) < cast_range:
				if timer.is_stopped():
					cast_spell()


func cast_spell():
	var target = ray_cast_2d.get_collider()
	var projectile = spell.instantiate()

	projectile.target_pos = ray_cast_2d.get_collision_point()
	projectile.global_position = position
	projectile.damage = damage
	projectile.z_index = 20

	get_parent().add_child(projectile)
	timer.start()

func take_damage(damage):
	if dead:
		return
	health -= damage
	progress_bar.visible = true
	progress_bar.value = health
	
	if health <= 0:
		dead = true
		progress_bar.visible = false
		animation_player.play("Die")
