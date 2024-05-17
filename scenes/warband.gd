extends Node2D

var knight = preload("res://scenes/characters/knight.tscn")
var viking = preload("res://scenes/characters/viking.tscn")
var wizard = preload("res://scenes/characters/wizard.tscn")
var ogre = preload("res://scenes/characters/ogre.tscn")

@onready var placed_array : Dictionary = {}
@onready var char_array : Array = []
@onready var tile_map : TileMap = $TileMap

var character = knight
var attacking = false

func _ready():
	_convert_cells_to_array()


# Initiliase placed dictionary to 0
func _convert_cells_to_array():
	var used_cells = tile_map.get_used_cells(2)

	for cell in used_cells:
		placed_array[cell] = 0
	
func _check_boundary(pos):
	if pos in placed_array.keys():
		return true
	else:
		return false

func _reset():
	for cell in placed_array.keys():
		if placed_array[cell]:
			if is_instance_valid(placed_array[cell]):
				placed_array[cell].queue_free()
			placed_array[cell] = 0 
		tile_map.set_cell(2, cell, 0, Vector2i(1,5))
	attacking = false
	
	for i in get_tree().get_nodes_in_group("Hostile"):
		i.attacking = false
		i.animation_player.stop()

func _process(delta):
	pass

func _input(event):
	var mouse_pos = to_local(get_global_mouse_position())
	var cell_pos = tile_map.local_to_map(mouse_pos)
	
	if attacking:
		return
	if not _check_boundary(cell_pos):
		return
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not placed_array[cell_pos]:
			var new_char = character.instantiate()
			new_char.position = tile_map.map_to_local(cell_pos)
			new_char.z_index = cell_pos.y
			new_char.add_to_group("Friendly")
			
			add_child(new_char)
			new_char.hostile = false
			placed_array[cell_pos] = new_char
			tile_map.erase_cell(2, cell_pos)
			
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if placed_array[cell_pos]:
			placed_array[cell_pos].free()
			placed_array[cell_pos] = 0
			tile_map.set_cell(2, cell_pos, 0, Vector2i(1,5))
		
		
		


func _on_reset_pressed():
	_reset()


func _on_wizard_pressed():
	character = wizard


func _on_viking_pressed():
	character = viking


func _on_knight_pressed():
	character = knight


func _on_ogre_pressed():
	character = ogre



func _on_fight_pressed():
	attacking = true
	for i in placed_array.keys():
		if placed_array[i]:
			placed_array[i].attacking = true
		tile_map.erase_cell(2, i)
	
	for i in get_tree().get_nodes_in_group("Hostile"):
		i.attacking = true
