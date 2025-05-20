extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rotation+=0.01
	$RainbowGradient.rotation -= 0.01
	if rotation == 360:
		rotation = 0
	if $RainbowGradient.rotation == -360:
		rotation = 0
	self.pivot_offset = self.size/2
	$RainbowGradient.pivot_offset = $RainbowGradient.size/2
	pass
