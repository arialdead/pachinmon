extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Grass.position.x += 0.03
	if $Grass.position.x > -320 + 512:
		$Grass.position.x -= 512
	
	$GrassDark.position.x += 0.06
	if $GrassDark.position.x > -320 + 512:
		$GrassDark.position.x -= 512
	
	$GrassDarker.position.x += 0.1
	if $GrassDarker.position.x > -320 + 512:
		$GrassDarker.position.x -= 512
	
	$Nuages.position.x += 0.02
	if $Nuages.position.x > -320 + 512:
		$Nuages.position.x -= 512
	pass
