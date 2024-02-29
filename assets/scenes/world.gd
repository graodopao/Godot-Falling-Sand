extends Node2D

## The size of the world in chunk units. 
@export var size: Vector2i

@export var boundary_tile: CAParticle
@export var edit_tile: CAParticle

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_chunks()

func generate_chunks():
	var temp_matrix = []
	temp_matrix.resize(size.x)

	for x in size.x:
		temp_matrix[x] = Array()
		temp_matrix[x].resize(size.y)

	# Create the world
	for x in range(size.x):
		for y in range(size.y):
			var chunk = Chunk.new()
			chunk.boundary_particle = boundary_tile
			chunk.reference_ca = edit_tile

			chunk.position = Vector2i(x * 32, y * 32)
			add_child(chunk)

func set_chunk_connections(matrix: Array, chunk_position: Vector2i, chunk: Chunk):
	
	for x in range(chunk_position.x - 1, chunk_position.x + 1):
		for y in range(chunk_position.y - 1, chunk_position.y + 1):
			if x == chunk_position.x and y == chunk_position.y:
				continue

			var relative_direction = ""
			relative_direction += ["left", "", "right"][sign(x - chunk_position.x) + 1]
			relative_direction += ["up", "", "down"][sign(y - chunk_position.y) + 1]

			if x >= 0 and x < size.x and y >= 0 and y < size.y:
				chunk.connected_chunk[relative_direction] = matrix[x][y]


