class_name CAImmovableSolid
extends CASolid


func step(chunk: Chunk, my_position: Vector2i, metadata: Dictionary, gravity := Vector2.DOWN) -> void:
    super.step(chunk, my_position, metadata, gravity)
    chunk.set_free_falling(chunk.get_tile_info(my_position), false)
