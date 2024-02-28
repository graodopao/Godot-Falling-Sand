class_name CAGas
extends CAParticle

@export var density: float = 1.0

func step(chunk: Chunk, my_position: Vector2i, metadata: Dictionary, gravity := Vector2.DOWN) -> void:
    super.step(chunk, my_position, metadata, gravity)
    
    # Attempts vertical movement
    if attempt_movement(chunk, my_position, my_position + Vector2i.UP):
        return
    
    var rand_dir := [Vector2i.RIGHT, Vector2i.LEFT]
    
    # If we can't move straight down, try to move diagonally
    for dir in rand_dir:
        if chunk.is_occupied(my_position + dir):
            continue
        if attempt_movement(chunk, my_position, my_position + Vector2i.UP + dir):
            return
    
    # If we can't move down, try to move horizontally
    for dir in rand_dir:
        if attempt_movement(chunk, my_position, my_position + dir):
            return


## Attemtps a movement to the next position. Returns true if the movement was successful, false otherwise
func attempt_movement(chunk: Chunk, current_position: Vector2i, next_position: Vector2i) -> bool:
    if !chunk.has_solid_tile(next_position):
        if chunk.has_gas_tile(next_position):
            if chunk.get_particle_at(next_position).density >= density:
                return false
            
            chunk.get_particle_at(next_position).swap_with_tile(chunk, next_position, current_position)
        elif chunk.has_liquid_tile(next_position):
            chunk.get_particle_at(next_position).swap_with_tile(chunk, next_position, current_position)
        else:
            chunk.move(current_position, next_position)
        return true
        
    return false

## Reserves a space for a particle to move to
func swap_with_tile(chunk: Chunk, my_position: Vector2i, second_position: Vector2i) -> void:
    var pos := check_for_empty_space(chunk, my_position)

    if pos == Vector2i.MAX:
        chunk.move(my_position, second_position)
    else:
        chunk.move(my_position, pos)
        chunk.move(second_position, my_position)
        
    