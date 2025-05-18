extends Control

var pokemon
var shiny

# Called when the node enters the scene tree for the first time.
func _ready():
	if shiny:
		$PokemonContainer/AnimatedSprite2D.play(str(pokemon[1])+"s")
	else:
		$PokemonContainer/AnimatedSprite2D.play(str(pokemon[1]))
	$PokemonContainer.theme = load("res://Theme/%s.tres" % pokemon[3])
	if pokemon[2]:
		$PokemonContainer/Label.text =  pokemon[0]
	else:
		$PokemonContainer/Label.text =  "???"
		$PokemonContainer/AnimatedSprite2D.modulate = Color.BLACK
	pass # Replace with function body.

