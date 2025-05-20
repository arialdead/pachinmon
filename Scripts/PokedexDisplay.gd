extends GridContainer

@export var res_pokemon_template: PackedScene

func _ready():
	get_parent().get_v_scroll_bar().modulate.a = 0

# Called when the node enters the scene tree for the first time.
func load_pdx(pdx, shiny):
	for x in get_children():
		x.queue_free()
	print("pdx : %s" % pdx)
	for x in pdx:
		var uwu = res_pokemon_template.instantiate()
		print("x : %s" % x)
		uwu.pokemon = pdx[x]
		uwu.shiny = shiny
		add_child(uwu)
	pass # Replace with function body.

func _process(delta):
	self.columns = floor(get_parent().size.x / 80)
