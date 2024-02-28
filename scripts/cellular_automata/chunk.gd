class_name Chunk
extends Node2D

## Emitted when the matrix is initialized.
signal initialized

## The size of the matrix.
@export var size := Vector2i.ONE * 32

## The chunk matrix.
var matrix: Array;

## Frozen points are skipped when updating the matrix. This array is cleared after each update.
var frozen_points: Array[Vector2i]

## A matrix of particles to update.
#var update_matrix: Array;

## Used for testing.
@export var reference_ca: CAParticle
@export var boundary_particle: CAImmovableSolid

func _ready():
	initialize_matrix()
	var center = round(size / 2)
	position = -size / 2

	# insert(center - Vector2i.UP * 2, reference_ca)
	# insert(center - Vector2i.UP, reference_ca)
	# insert(center, reference_ca)

	# Creates boundaries.
	for x in size.x:
		insert(Vector2i(x, 0), boundary_particle)
		insert(Vector2i(x, size.y - 1), boundary_particle)
	
	for y in size.y:
		insert(Vector2i(0, y), boundary_particle)
		insert(Vector2i(size.x - 1, y), boundary_particle)


# Updates the matrix, bottom to top, left to right.
func update():
	# Inserts a reference CA particle at the mouse position.
	var mouse_position := get_local_mouse_position()
	if mouse_position > Vector2.ZERO and mouse_position < Vector2(size) and Input.is_action_pressed("click"):
		mouse_position = mouse_position.clamp(Vector2i.ONE, size - Vector2i.ONE * 2)
		insert(mouse_position, reference_ca)
	

	# Updates the matrix.
	for column in range(size.y - 1, -1, -1):
		for row in size.x - 1:
			var coordinates := Vector2i(row, column)
			if !is_occupied(coordinates) or is_frozen_point(coordinates) or !is_free_falling(coordinates): continue
			
			get_particle_at(coordinates).step(self, coordinates, get_tile_info(coordinates), Vector2.DOWN)
			
	# insert(Vector2i.ONE, reference_ca)
	# insert(Vector2i(round(size.x / 2), 1), reference_ca)
	# insert(Vector2i(size.x - 2, 1), reference_ca)

	queue_redraw()

	frozen_points.clear()


## Draws the matrix.
func _draw():
	for x in size.x:
		for y in size.y:
			if !is_occupied(Vector2i(x, y)): continue
			
			var tile_position = Vector2(x, y)
			
			draw_rect(Rect2(tile_position, Vector2(1, 1)), get_color_at(Vector2i(x, y)))


## Initializes the matrix with nulls.
func initialize_matrix() -> void:
	matrix.resize(size.x)

	for x in size.x:
		matrix[x] = Array()
		matrix[x].resize(size.y)
	
	#update_array = Array(matrix)
	initialized.emit();

## Moves a particle in the matrix.
func move(particle_position: Vector2i, new_position: Vector2i) -> void:
	particle_position = particle_position.clamp(Vector2i.ZERO, size - Vector2i.ONE)
	new_position = new_position.clamp(Vector2i.ZERO, size - Vector2i.ONE)

	if !is_occupied(particle_position): return

	var tile = get_tile_info(particle_position)
	var previous_tile = get_tile_info(new_position)
	
	matrix[particle_position.x][particle_position.y] = previous_tile
	matrix[new_position.x][new_position.y] = tile
	
	freeze_point(particle_position)
	freeze_point(new_position)

## Inserts a particle in the matrix.
func insert(new_postion: Vector2i, particle: CAParticle) -> void:
	matrix[new_postion.x][new_postion.y] = particle.generate_tile()

## Returns the particle at the given position.
func get_particle_at(matrix_position: Vector2i) -> CAParticle:
	if !is_occupied(matrix_position): return null
	return matrix[matrix_position.x][matrix_position.y]["particle_resource"]

## Returns the color of the tile at the given position. Warning: Using this function on a non-occupied tile will result in a new Color object being created,
## which may cause unintended behavior. Check if the tile is occupied before using this function.
func get_color_at(matrix_position: Vector2i) -> Color:
	if !is_occupied(matrix_position): return Color()
	return matrix[matrix_position.x][matrix_position.y]["color"]

## Returns the tile info at the given position.
func get_tile_info(matrix_position: Vector2i):
	return matrix[matrix_position.x][matrix_position.y]

## Freezes a point in the matrix.
func freeze_point(matrix_position: Vector2i) -> void:
	frozen_points.append(matrix_position)

## Returns true if the given position is frozen.
func is_frozen_point(matrix_position: Vector2i) -> bool:
	return frozen_points.find(matrix_position) != -1

## Sets the free falling property of a tile.
func set_free_falling(tile: Dictionary, value: bool) -> void:
	tile["free_falling"] = value

## Sets the free falling property of every tile in the matrix.
func activate_free_falling_on_all() -> void:
	for x in size.x:
		for y in size.y:
			if is_occupied(Vector2i(x, y)):
				set_free_falling(get_tile_info(Vector2i(x, y)), true)

## Returns true if the given position is free falling.
func is_free_falling(matrix_position: Vector2i) -> bool:
	if !is_occupied(matrix_position): return false
	return matrix[matrix_position.x][matrix_position.y]["free_falling"]

## Runs the touch method on points surrounding the given position.
# func touch_point_surroundings(matrix_position: Vector2i) -> void:
# 	for x in range(-1, 2):
# 		for y in range(-1, 2):
# 			var position = matrix_position + Vector2i(x, y)
# 			if !is_occupied(position): continue

# 			if (get_particle_at(position).touch()):
# 				set_free_falling(get_tile_info(position), false)

# --- Collision detection ---

## Returns true if the given position is occupied.
func is_occupied(matrix_position: Vector2i) -> bool:
	if matrix_position.x < 0 or matrix_position.x >= size.x or matrix_position.y < 0 or matrix_position.y >= size.y: return false
	return matrix[matrix_position.x][matrix_position.y] != null


## Returns true if the given position is a solid tile.
func has_solid_tile(matrix_position: Vector2i) -> bool:
	if !is_occupied(matrix_position): return false

	return matrix[matrix_position.x][matrix_position.y]["particle_resource"] is CASolid

## Returns true if the given position is a liquid tile.
func has_liquid_tile(matrix_position: Vector2i) -> bool:
	if !is_occupied(matrix_position): return false

	return matrix[matrix_position.x][matrix_position.y]["particle_resource"] is CALiquid

## Returns true if the given position is a gas tile.
func has_gas_tile(matrix_position: Vector2i) -> bool:
	if !is_occupied(matrix_position): return false

	return matrix[matrix_position.x][matrix_position.y]["particle_resource"] is CAGas

# FILEPATH: /home/ograodopao/Desktop/LP/assets/scripts/cellular_automata/chunk.gd
# BEGIN: ed8c6549bwf9

func iterate_and_apply_method_between_two_points(pos1: Vector2, pos2: Vector2, function: Callable = func(): return) -> Vector2:
	# If the two points are the same no need to iterate. Just run the provided function
	if pos1.distance_to(pos2) < 0.001:
		#function.call_func()
		return Vector2.INF
	
	# var matrixX1 = int(pos1.x)
	# var matrixY1 = int(pos1.y)
	# var matrixX2 = int(pos2.x)
	# var matrixY2 = int(pos2.y)
	
	var xDiff = pos1.x - pos2.x
	var yDiff = pos1.y - pos2.y
	var xDiffIsLarger = abs(xDiff) > abs(yDiff)
	
	var xModifier = 1 if xDiff < 0 else -1
	var yModifier = 1 if yDiff < 0 else -1
	
	var longerSideLength = max(abs(xDiff), abs(yDiff))
	var shorterSideLength = min(abs(xDiff), abs(yDiff))
	var slope = 0.0 if (shorterSideLength == 0 or longerSideLength == 0) else float(shorterSideLength) / float(longerSideLength)
	
	var shorterSideIncrease: int
	for i in range(1, longerSideLength + 1):
		shorterSideIncrease = round(i * slope)
		var yIncrease
		var xIncrease

		if xDiffIsLarger:
			xIncrease = i
			yIncrease = shorterSideIncrease
		else:
			yIncrease = i
			xIncrease = shorterSideIncrease
		# var currentY = 
		# var currentX = 
		var currentPos = Vector2(pos1.x + (xIncrease * xModifier), pos1.y + (yIncrease * yModifier))
		
		move(Vector2i(pos1), Vector2i(currentPos))
			
		#if is_within_bounds(currentX, currentY):
			#function.call_func()
	return Vector2.INF

# END: ed8c6549bwf9
