extends GridContainer

const POKEMON_TEMPLATE = preload("res://pokemon_template.tscn")

# Called when the node enters the scene tree for the first time.
func load_pdx(pdx, shiny):
	for x in get_children():
		x.queue_free()
	print("pdx : %s" % pdx)
	for x in pdx:
		var uwu = POKEMON_TEMPLATE.instantiate()
		print("x : %s" % x)
		uwu.pokemon = pdx[x]
		uwu.shiny = shiny
		add_child(uwu)
	pass # Replace with function body.


