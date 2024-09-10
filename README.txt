How to install/use the plugin:
1. Go Project -> Project Settings -> Plugins -> Create New Plugin
2. Make sure the folder for the plugin is "tilemap_baker" and placed like this: res://addons/tilemap_baker/
3. Under "Script Name", call it "tilemap_baker_plugin"
4. Copy the code from "tilemap_baker_plugin" and paste it
5. Make a new script in the "tilemap_baker" folder and call it "tilemap_baker"
6. Copy the code from "tilemap_baker" and paste is in there.
7. Save and then  you open Godot back up go to Project -> Project Settings -> Plugins. Click checkbox to enable the plugin.
8. Restart Godot. When you come back in there should be a message in "Output" saying "Texture Baker plugin entered tree"
9. When you want to bake a Tilemap or Sprite2D, select it in the scene tree, then go to Project -> Tools -> Bake Selected Tilemap or Sprite2D
10. In "Output" you will see what the code is doing, when it is done, where is saved the picture and what it is named.
