@tool
extends EditorPlugin

const SAVE_PATH = "res://baked_textures/"
const PADDING = 2  # Padding in pixels

func _enter_tree():
	print("Texture Baker plugin entered tree")
	add_tool_menu_item("Bake Selected Tilemap or Sprite2D", bake_selected_node)

func _exit_tree():
	print("Texture Baker plugin exiting tree")
	remove_tool_menu_item("Bake Selected Tilemap or Sprite2D")

func bake_selected_node():
	print("Bake Selected Node function called")
	var selection = get_editor_interface().get_selection()
	var selected_nodes = selection.get_selected_nodes()
	
	if selected_nodes.size() == 0:
		print("No node selected")
		return
	
	var node = selected_nodes[0]
	if node is TileMap:
		print("Selected TileMap: ", node.name)
		bake_tilemap.call_deferred(node)
	elif node is Sprite2D:
		print("Selected Sprite2D: ", node.name)
		bake_sprite2d.call_deferred(node)
	else:
		print("Selected node is not a TileMap or Sprite2D")

func bake_tilemap(tilemap: TileMap) -> void:
	print("Starting to bake TileMap: ", tilemap.name)
	var used_rect = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size
	
	# Add padding to the texture size
	var padded_size = used_rect.size + Vector2i(PADDING * 2, PADDING * 2)
	var texture_size = padded_size * tile_size
	
	var sub_viewport = create_viewport(texture_size)
	var camera = create_camera()
	var tilemap_copy = tilemap.duplicate()
	
	sub_viewport.add_child(tilemap_copy)
	sub_viewport.add_child(camera)
	
	# Position the TileMap copy so that the top-left of the used rect (with padding) aligns with the viewport's top-left
	tilemap_copy.position = (-used_rect.position + Vector2i(PADDING, PADDING)) * tile_size
	
	# Position camera at the top-left of the viewport
	camera.position = Vector2.ZERO
	
	var image = await capture_viewport(tilemap, sub_viewport)
	if image:
		save_image(image, tilemap.name)

func bake_sprite2d(sprite: Sprite2D) -> void:
	print("Starting to bake Sprite2D: ", sprite.name)
	var texture_size = sprite.texture.get_size()
	
	# Add padding to the texture size
	var padded_size = texture_size + Vector2(PADDING * 2, PADDING * 2)
	
	var sub_viewport = create_viewport(padded_size)
	var camera = create_camera()
	var sprite_copy = sprite.duplicate()
	
	sub_viewport.add_child(sprite_copy)
	sub_viewport.add_child(camera)
	
	# Position the sprite at the top-left of the viewport (considering padding)
	sprite_copy.position = Vector2(PADDING, PADDING)
	sprite_copy.centered = false  # Ensure the sprite's top-left corner is at its position
	
	# Position camera at the top-left of the viewport
	camera.position = Vector2.ZERO
	
	var image = await capture_viewport(sprite, sub_viewport)
	if image:
		save_image(image, sprite.name)

func create_viewport(size: Vector2) -> SubViewport:
	var sub_viewport = SubViewport.new()
	sub_viewport.size = size
	sub_viewport.transparent_bg = true
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	return sub_viewport

func create_camera() -> Camera2D:
	var camera = Camera2D.new()
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera.make_current()
	return camera

func capture_viewport(node: Node, sub_viewport: SubViewport) -> Image:
	print("Adding SubViewport to scene")
	node.add_child(sub_viewport)
	
	# Force an update of the SubViewport
	sub_viewport.set_update_mode(SubViewport.UPDATE_ONCE)
	
	# Wait for two frames to ensure the viewport is rendered
	await node.get_tree().process_frame
	await node.get_tree().process_frame
	
	print("Capturing viewport texture")
	var image = sub_viewport.get_texture().get_image()
	
	print("Removing SubViewport")
	node.remove_child(sub_viewport)
	sub_viewport.queue_free()
	
	return image

func save_image(image: Image, node_name: String) -> void:
	# Ensure the save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)
	
	# Save the image
	var save_path = SAVE_PATH + node_name + "_baked.png"
	var error = image.save_png(save_path)
	if error == OK:
		print("Baked texture saved successfully to: " + save_path)
	else:
		print("Error saving baked texture: ", error)
	
	print("Baking process completed")

func _get_plugin_name():
	return "Texture Baker"
