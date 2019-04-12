"""
	Copyright 2019 Brandon Ludwig
	
    This file is part of Minesweeper.

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
"""


extends Node2D

onready var tile = preload("res://Tile.tscn")

var tile_size = Vector2(32, 32)
var grid = []
var size = Vector2(40, 30)
var max_mines = (size.x * size.y) * 0.1
var is_started = false
const MS_TILE : = preload("res://ms_tile.png")
const MS_TILE_UC : = preload("res://ms_tile_uc.png")
const MS_TILE_FLAG : = preload("res://ms_tile_flag.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_window_size(Vector2(tile_size.x * size.x, tile_size.y * size.y))
	set_position(Vector2(16, 16))
	print(OS.get_window_size())
	randomize()
	
	initialize_grid()
	OS.center_window()

func initialize_grid():
	for x in range(size.x):
		grid.append([])
		for y in range(size.y):
			var t = tile.instance()
			t.get_node("CollisionShape2D").shape.set_extents(tile_size/2)
			t.get_node("Sprite").set_scale(Vector2(tile_size.x / 16, tile_size.y / 16))
			t.get_node("Label").set_size(tile_size)
			var pos = Vector2(x * (tile_size.x), y * (tile_size.y))
			t.set_position(pos)
			t.index = Vector2(x, y)
			grid[x].append(t)
			add_child(t)
			t.connect("left_click", self, "_on_left_click")
			t.connect("right_click", self, "_on_right_click")

func spawn_mines(start_tile):
	var mines = 0
	for i in range(max_mines):
		var mine_location = Vector2(randi()%int(size.x), randi()%int(size.y))
		while mine_location.x >= start_tile.index.x-1 and mine_location.x <= start_tile.index.x+1\
			and mine_location.y >= start_tile.index.y-1 and mine_location.y <= start_tile.index.y+1:
				mine_location = Vector2(randi()%int(size.x), randi()%int(size.y))
				print("changed mine")
				
		var mine_tile = grid[mine_location.x][mine_location.y]
		mine_tile.get_node("Label").text = "*"
		mine_tile.is_mine = true
		
		# Label surrounding tiles
		for x in range(mine_location.x-1, mine_location.x+2):
			for y in range(mine_location.y-1, mine_location.y+2):
				if x >= 0 and x < size.x and y >= 0 and y < size.y:
					var t = grid[x][y]
					if t.is_mine == false:
						t.adjacent_mines += 1
						t.get_node("Label").text = str(t.adjacent_mines)

func get_surrounding_tiles(tile):
	var tiles = []
	for x in range(tile.index.x - 1, tile.index.x + 2):
		for y in range(tile.index.y - 1, tile.index.y + 2):
			if x >= 0 and x < size.x and y >= 0 and y < size.y and grid[x][y] != tile:
				tiles.append(grid[x][y])
	return tiles
	
func clear_surrounding_tiles(tile):
	var tiles = get_surrounding_tiles(tile)
	for i in tiles:
		if i.is_masked:
			if !i.is_mine and !i.is_flagged:
				i.hide_mask()
				if i.adjacent_mines == 0:
					clear_surrounding_tiles(i)
			
func _on_left_click(tile):
	if tile.is_masked:
		tile.hide_mask()
		if !is_started:
			spawn_mines(tile)
			is_started = true
		if tile.is_mine:
			game_over()
		elif tile.adjacent_mines == 0:
			clear_surrounding_tiles(tile)
	else:
		var tiles = get_surrounding_tiles(tile)
		var flags_valid = true
		var flag_count = 0
		for t in tiles:
			if t.is_flagged:
				flag_count += 1
				if !t.is_mine:
					flags_valid = false
		
		if tile.adjacent_mines == flag_count:
			if flags_valid:
				clear_surrounding_tiles(tile)
			else:
				game_over()
			
func _on_right_click(tile):
	if tile.is_masked:
		tile.flag()

func check_win():
	for i in grid:
		for k in i:
			if k.is_masked and !k.is_mine:
				return false
	return true
		
func game_over():
	for i in grid:
		for k in i:
			k.hide_mask()