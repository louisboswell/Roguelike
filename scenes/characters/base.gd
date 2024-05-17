extends CharacterBody2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var hostile = true
@onready var attacking = false
@onready var progress_bar = $ProgressBar
@onready var hitbox = $Hitbox

# Base character stats and attributes
var speed = 50
var health = 100
var armor = 10
var damage = 20
var attack_speed = 0.5
var knockback_force = 500


var dead = false
var targets_in_hitbox = []

# Called when the node enters the scene tree for the first time.
func _ready():
	attacking = false
	progress_bar.visible = false
	progress_bar.value = health


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
			if not animation_player.is_playing():
				animation_player.play("Walk")
			move_towards_enemy(closest_enemy, delta)


func move_towards_enemy(enemy, delta):
	if enemy:
		# Calculate the direction vector from the current position to the enemy's position
		var direction = (enemy.global_position - global_position).normalized()
		
		# Calculate the velocity vector
		velocity = direction * speed
		
		# Move the object and slide along surfaces
		move_and_slide()

		var avoid_radius = 100
		var avoid_strength = 500


		# Avoidance logic to steer away from overlapping with other characters
		var avoidance_force = Vector2()
		var neighbors = get_tree().get_nodes_in_group("Friendly")  # Adjust to your characters' group
		for neighbor in neighbors:
			if neighbor != self:  # Exclude self
				var neighbor_distance = global_position.distance_to(neighbor.global_position)
				if neighbor_distance < avoid_radius:  # Adjust avoid_radius as needed
					var away_direction = (global_position - neighbor.global_position).normalized()
					avoidance_force += away_direction / neighbor_distance  # Weighted by distance
		
		velocity += avoidance_force * avoid_strength  # Adjust avoid_strength as needed
		move_and_slide()

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

func _on_hitbox_area_entered(area):
	var target = area.get_parent()
	if target.is_in_group("Hostile") or (hostile and target.is_in_group("Friendly")):
		if target not in targets_in_hitbox:
			targets_in_hitbox.append(target)
		attack_target(target)

func attack_target(target):
	while is_instance_valid(target) and target.health > 0 and target in targets_in_hitbox:
		target.take_damage(damage)
		apply_knockback(target)
		await get_tree().create_timer(attack_speed).timeout

func apply_knockback(target):
	# Calculate the direction from the attacker to the target
	var direction = (target.position - global_position).normalized()

	# If the target is not a RigidBody2D, manually adjust its position
	target.position += direction * knockback_force * get_physics_process_delta_time()


func _on_hitbox_area_exited(area):
	var target = area.get_parent()
	if target in targets_in_hitbox:
		targets_in_hitbox.erase(target)
