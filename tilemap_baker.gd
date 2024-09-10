@tool
extends Node

const SAVE_PATH = "res://baked_tilemaps/"

func bake_tilemap(tilemap: TileMap) -> void:
	print("Starting to bake TileMap: ", tilemap.name)
	var used_rect = tilemap.get_used_rect()
	print("Used rect: ", used_rect)
	var tile_size = tilemap.tile_set.tile_size
	print("Tile size: ", tile_size)
	var texture_size = used_rect.size * tile_size
	print("Texture size: ", texture_size)
	
	var sub_viewport = SubViewport.new()
	sub_viewport.size = texture_size
	sub_viewport.transparent_bg = true
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	var camera = Camera2D.new()
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera.make_current()
	
	var tilemap_copy = tilemap.duplicate()
	sub_viewport.add_child(tilemap_copy)
	sub_viewport.add_child(camera)
	
	# Center the camera on the TileMap
	camera.position = used_rect.position * tile_size + (texture_size / 2)
	camera.zoom = Vector2(1, 1)
	
	print("Adding SubViewport to scene")
	tilemap.add_child(sub_viewport)
	
	# Force an update of the SubViewport
	sub_viewport.set_update_mode(SubViewport.UPDATE_ONCE)
	
	# Wait for two frames to ensure the viewport is rendered
	await tilemap.get_tree().process_frame
	await tilemap.get_tree().process_frame
	
	print("Capturing viewport texture")
	var image = sub_viewport.get_texture().get_image()
	
	print("Removing SubViewport")
	tilemap.remove_child(sub_viewport)
	sub_viewport.queue_free()
	
	# Ensure the save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)
	
	# Save the image
	var save_path = SAVE_PATH + tilemap.name + "_baked.png"
	var error = image.save_png(save_path)
	if error == OK:
		print("Baked TileMap saved successfully to: " + save_path)
	else:
		print("Error saving baked TileMap: ", error)
	
	# Debug: Save an additional image to check if it's empty
	var debug_save_path = SAVE_PATH + tilemap.name + "_debug.png"
	error = image.save_png(debug_save_path)
	if error == OK:
		print("Debug image saved to: " + debug_save_path)
	else:
		print("Error saving debug image: ", error)
	
	print("Baking process completed")
