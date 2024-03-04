class_name CAMovableSolid
extends CASolid


func step(chunk: Chunk, my_position: Vector2i, metadata: Dictionary, gravity := Vector2.DOWN) -> void:
	super.step(chunk, my_position, metadata, gravity)
	
	var down_dir = Vector2i(round(gravity))


	# Vertical movement
	#metadata["velocity"] = chunk.find_line_intersection(my_position, vel_sign)
	if attempt_movement(chunk, my_position, my_position + down_dir, metadata):
		return
	
	# Diagonal movement
	var rand_dir := [Vector2i.RIGHT, Vector2i.LEFT]
	rand_dir.shuffle()
	
	for dir in rand_dir:
		if (chunk.is_occupied(my_position + dir)):
			continue
		if attempt_movement(chunk, my_position, my_position + down_dir + dir, metadata):
			return
		
	tick_free_falling(metadata)


## Attemtps a movement to the next position. Returns true if the movement was successful, false otherwise
func attempt_movement(chunk: Chunk, current_position: Vector2i, next_position: Vector2i, metadata: Dictionary) -> bool:
	if !chunk.has_solid_tile(next_position):
		if chunk.has_liquid_tile(next_position):
			# Makes it so that the solid tile is swapped with the liquid tile
			chunk.get_particle_at(next_position).swap_with_tile(chunk, next_position, current_position)
		else:
			#chunk.move(current_position, next_position)
			chunk.iterate_and_apply_method_between_two_points(current_position, next_position)
			#chunk.move(current_position, next_position)
		
		reset_free_falling(metadata)
		return true
	
	return false


# func attempt_movement(chunk: Chunk, current_position: Vector2i, next_position: Vector2i) -> bool:
#     if (chunk.has_solid_tile(next_position)):
#         return false

#     chunk.move(current_position, next_position)
#     return true
