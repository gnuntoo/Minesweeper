extends Area2D

var is_mine = false
var is_masked = true
var is_flagged = false
var adjacent_mines = 0
var tile = self
var index = Vector2()

signal Tile_pressed
signal left_click
signal right_click

const MS_TILE : = preload("res://ms_tile.png")
const MS_TILE_UC : = preload("res://ms_tile_uc.png")
const MS_TILE_FLAG : = preload("res://ms_tile_flag.png")


# Called when the node enters the scene tree for the first time.
func _ready():
#	connect("pressed", self, "_on_Tile_pressed")
	pass

func _on_Tile_pressed():
#	emit_signal("Tile_pressed", tile)
	pass
	
func hide_mask():
#	var mask = self.get_node("Mask")
#	mask.hide()
	$Sprite.set_texture(MS_TILE_UC)
	$Label.set_visible(true)
	self.is_masked = false

func flag():
	if !is_flagged:
		$Sprite.set_texture(MS_TILE_FLAG)
		is_flagged = true
	else:
		$Sprite.set_texture(MS_TILE)
		is_flagged = false
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.pressed:
		if event.button_index == BUTTON_LEFT:
			emit_signal("left_click", tile)
		elif event.button_index == BUTTON_RIGHT:
			emit_signal("right_click", tile)