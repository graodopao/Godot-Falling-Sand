@tool
class_name CAParticle
extends Resource

@export var color: Color
@export var color_variation: Color
@export_range(0, 1) var color_variation_range := 0.0
@export_range(0, 1) var inertia_resistance := 0.0
#@export var metadata_template: Dictionary = { "resource": self, "color": "generate_color"

@export var speed := Vector2.ONE

## The particle's step function
func step(chunk: Chunk, my_position: Vector2i, metadata: Dictionary, gravity := Vector2.DOWN) -> void:
	return

## Generates a new color based on the color and color_variation
func generate_color() -> Color:
	return color.lerp(color_variation, color_variation_range * randf())

## Checks for empty space around the particle and returns a new position if found. Will return Vector2i.MAX if no empty space is found.
func check_for_empty_space(chunk: Chunk, my_position: Vector2i) -> Vector2i:
	for i in range(4):
		var direction := Vector2.RIGHT.rotated(i * TAU / 4)
		var new_position: Vector2i = my_position + Vector2i(direction)
		if !chunk.is_occupied(new_position):
			return new_position

	return Vector2i.MAX

## Generates a dictionary to serve as a tile
func generate_tile():
	return Dictionary({ "particle_resource": self, "color": generate_color(), "free_falling": true, "velocity": Vector2(0, 0), "sleep_timer": 0})

## A touch has a chance of reactivating the particle based on its' inertia resistance
func touch() -> bool:
	return randf() >= inertia_resistance

## Manages the free falling state of the particle
func tick_free_falling(metadata: Dictionary) -> void:
	# If no movement was made on the previous steps, sets the free_falling flag to false
	metadata["sleep_timer"] += 1
	if metadata["sleep_timer"] > 20:
		metadata["free_falling"] = false
		metadata["sleep_timer"] = 0

## Resets the free falling state of the particle
func reset_free_falling(metadata: Dictionary) -> void:
	metadata["free_falling"] = true
	metadata["sleep_timer"] = 0
