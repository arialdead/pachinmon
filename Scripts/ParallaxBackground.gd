extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var vp_size = DisplayServer.window_get_size()
	print(vp_size)
	var new_size = 0.1
	if vp_size.x > vp_size.y:
		new_size = float(vp_size.x)/float(384)
		$Ciel.scale = Vector2(new_size,new_size)
		print(new_size)
	#$ParallaxLayer.motion_offset.x += 0.3
	#$ParallaxLayer2.motion_offset.x += 0.6
	#$ParallaxLayer3.motion_offset.x += 0.9
	#$ParallaxLayer4.motion_offset.x += 0.05
	pass
