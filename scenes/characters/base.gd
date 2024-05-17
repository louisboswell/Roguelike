extends CharacterBody2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var hostile = true
@onready var attacking = false
@onready var progress_bar = $ProgressBar
@onready var hitbox = $Hitbox
@onready var nav = $NavigationAgent2D

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


func _physics_process(delta):
	
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
				
			nav.target_position = closest_enemy.global_position
			var direction = nav.get_next_path_position() - global_position
			direction = direction.normalized()
			
			var intended_velocity = direction * speed
			nav.set_velocity(intended_velocity)

	

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
		#apply_knockback(target)
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


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	# Check here if all enemies are dead
	if len(get_tree().get_nodes_in_group("Hostile")) != 0:
		move_and_slide()
