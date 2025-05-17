extends Node2D

const current_version = 1.2

#Déclaration des scenes a instancier
@export var ball_scene: PackedScene
const HILLS = preload("res://Boards/hills.tscn")

#Déclaration des variables essentiels ⚠️ A verifier lesquels sont vrmt essentiels
var balls_remaining = 500
var pokeball_counter = 0
var balls = []
var can_play=true
var can_continue=true
var save
var display_shiny = false
var board = "hills"

#Déclaration de variable que c'est chiant a retrouver
@onready var catch_animator = $ColorRect/AnimationPlayer

#Déclaration des variables pour load le board
var emitter
var balls_children
var new_balls_array
var out_zones_array
var pokeball
var pokeball_catching
var pokeleds
var pokeled_animator

var Common = [
	["Pidgey", 16],
	["Rattata", 19],
	["Sentret", 161],
	["Zigzagoon", 263],
	["Bidoof", 399],
	["Patrat", 504],
	["Fletchling", 661]
]
var Uncommon = [
	["Pikachu", 25],
	["Meowth", 52],
	["Eevee", 133],
	["Taillow", 276],
	["Pidove", 519],
	["Bunnelby", 659],
	["Skwovet", 819]
]
var Rare = [
	["Pidgeot", 18],
	["Raticate", 20],
	["Furret", 162],
	["Linoone", 264],
	["Bibarel", 400],
	["Watchog", 505],
	["Fletchinder", 662]
]
var SuperRare = [
	["Sandslash", 28],
	["Zangoose", 335],
	["Seviper", 336],
	["Braviary", 628],
	["Kommo-o", 784],
	["Appletun", 841],
	["Flapple", 842]
]
var SuperSuperRare = [
	["Snorlax", 143],
	["Kangaskhan", 115],
	["Glalie", 362],
	["Salamence", 373],
	["Lucario", 448],
	["Sylveon", 700],
	["Grimmsnarl", 859]
]
var UltraRare = [
	["Celebi", 251], 
	["Shaymin", 492],
	["Keldeo", 647],
	["Zarude", 893],
	["Regieleki", 894],
	["Regidrago", 895],
	["Calyrex", 898]
]
var MegaRare = [
	["Mega Venusaur", 10033],
	["Mega Charizard X", 10034],
	["Mega Blastoise", 10036],
	["Mega Beedrill", 10090],
	["Mega Pidgeot", 10073],
	["Mega Kangaskhan", 10039],
	["Mega Salamence", 10089]
]


var whole_hills_pokedex = {
		"Common" : Common,
		"Uncommon" :Uncommon,
		"Rare" :Rare,
		"SuperRare" : SuperRare,
		"SuperSuperRare" : SuperSuperRare,
		"UltraRare" : UltraRare,
		"Megarare" : MegaRare,
		}

func _ready():
	print("Je fais une roulette ! C'est super :>")
	
	#Prelaunch Animations
	$ColorRect/RarityLabel/AnimationPlayer.play("loop")
	$ColorRect/NewLabel/AnimationPlayer.play("Scaling")
	
	#Load or create save file
	if not FileAccess.file_exists("user://save.save"):
		var hills_pokedex = generate_hills_pokedex()
		var hills_shinydex = generate_hills_pokedex()
		save = {
			"last_time_got_ball" : Time.get_datetime_dict_from_system(),
			"balls" : 500,
			"hills_pokedex" : hills_pokedex,
			"hills_shinydex" : hills_shinydex,
			"pokeball_counter" : 0,
			"last_version" : 1.2,
			"last_board" : "hills",
			"settings" : {
				"master_volume" : 0.5,
				"sfx_volume" : 0.5,
				"bgm_volume" : 0.5
			}
		}
		balls_remaining = 500
		save_file()
	else:
		
		
		var file = FileAccess.open("user://save.save", FileAccess.READ)
		save = file.get_var()
		
		#upgrade from 1.0 to 1.1
		if not save.keys().has("last_version"):
			var shinydex = generate_hills_pokedex()
			
			#fix hills_pokedex
			
			var hills_pokedex = generate_hills_pokedex()
			
			for x in hills_pokedex:
				
				if save.pokedex.keys().has(x):
					if x == "Kommo-o":
						print("Kommo-o trouvé, changement de numéro")
						hills_pokedex[x] = save.pokedex[x]
						hills_pokedex[x][1] = 784
						print(hills_pokedex[x][1])
					print("Corrélation découverte : %s" % x)
					hills_pokedex[x] = save.pokedex[x]
					print(hills_pokedex[x])
				else:
					print("Aie ! différence : %s" % x)
					hills_pokedex[x][2] = save.pokedex["Spectrier"][2]
					print(hills_pokedex[x])
			
			var new_save = {
				"last_time_got_ball" : save.last_time_got_ball,
				"balls" : save.balls,
				"hills_pokedex" : hills_pokedex,
				"hills_shinydex" : shinydex,
				"pokeball_counter" : save.pokeball_counter,
				"last_version" : 1.1,
				"last_board" : "hills"
			}
			save = new_save.duplicate()
		pokeball_counter = save.pokeball_counter
		
		#Tant que la version n'est pas a jour, update petit a petit
		while save.last_version != current_version:
			#Mettre a jour de chaque version, envers chaque version.
			match save.last_version:
				1.1:
					var temp_settings = {
						"master_volume" : $Settings/SettingsWindows/Options/Option2/MasterSlider.value,
						"sfx_volume" : $Settings/SettingsWindows/Options/Option2/SFXSlider.value,
						"bgm_volume" : $Settings/SettingsWindows/Options/Option2/BGMSlider.value
					}
					save["settings"] = temp_settings
					save.last_version = 1.2
		
		$Settings/SettingsWindows/Options/Option2/MasterSlider.value = save.settings.master_volume
		$Settings/SettingsWindows/Options/Option2/SFXSlider.value = save.settings.sfx_volume
		$Settings/SettingsWindows/Options/Option2/BGMSlider.value = save.settings.bgm_volume
		
		var time = Time.get_datetime_dict_from_system()
		var old_time = save.last_time_got_ball
		#calculate time dif
		var temp_balls = 0
		
		var dif_minutes = time.minute - old_time.minute
		if dif_minutes/15 > 1:
			temp_balls += floor(dif_minutes/15)*2
			
		var dif_hours = time.hour - old_time.hour
		if dif_hours > 0:
			temp_balls += dif_hours*8
		
		var dif_days = time.day - old_time.day
		if dif_days > 0:
			temp_balls += dif_days*96*2
		
		if temp_balls > 500:
			temp_balls = 500
		
		
		#add balls
		balls_remaining = save.balls + temp_balls
		if temp_balls > 0:
			save.balls = balls_remaining
			save.last_time_got_ball = time
		file.close()
		save_file()
	
	#load last_board
	var current_board
	match save.last_board:
		"hills":
			var uwu = HILLS.instantiate()
			add_child(uwu)
			move_child(uwu, 0)
			current_board = uwu
	emitter = current_board.emitter
	balls_children = current_board.balls_children
	new_balls_array = current_board.new_balls_array
	for x in new_balls_array:
		x.body_entered.connect(_on_new_ball_body_entered)
	out_zones_array = current_board.out_zones_array
	for x in out_zones_array:
		x.body_entered.connect(_on_out_zone_body_entered)
	pokeball = current_board.pokeball
	pokeball.body_entered.connect(_on_pokeball_body_entered)
	pokeball_catching= current_board.pokeball_catching
	pokeleds = current_board.pokeleds
	pokeled_animator = current_board.pokeled_animator
func generate_hills_pokedex():
	var hills_pokedex = {}
	for rarity in whole_hills_pokedex:
		for pokemon in whole_hills_pokedex[rarity]:
			var uwu = pokemon.duplicate()
			uwu.append(false)
			uwu.append(str(rarity))
			hills_pokedex[pokemon[0]] = uwu
	return hills_pokedex
	
func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		balls_remaining += 1000
	if event.is_action_pressed("ui_accept"):
		action_done()
	if event.is_action_pressed("ui_page_up"):
		for x in save.hills_pokedex:
			save.hills_pokedex[x][2] = true
		for x in save.hills_shinydex:
			save.hills_shinydex[x][2] = true
	
	
func action_done():
	if can_continue and can_play:
		if balls_remaining > 0:
			spawn_ball()
	elif can_continue and not can_play:
		catch_animator.play("Closing")
		$ColorRect/Label3/AnimationTree.pause()
		await get_tree().create_timer(1.0).timeout
		can_play = true
		for ball in balls:
				ball.set_deferred("freeze", false) 
		emitter.get_node("AnimationPlayer").play()
		$ColorRect/Label3/AnimationTree.play("RESET")
		$ColorRect/NewLabel.hide()

func spawn_ball():
	if can_play:
		var ball = ball_scene.instantiate()
		ball.position = emitter.global_position
		balls_children.add_child(ball)
		balls_remaining -= 1
		$SoundPlayer/sfx_ball_launched.play()
		save.balls = balls_remaining
		save_file()
		balls.append(ball)

func save_file():
	var file = FileAccess.open("user://save.save",FileAccess.WRITE)
	save.balls_remaining = balls_remaining
	var temp_settings = {
		"master_volume" : $Settings/SettingsWindows/Options/Option2/MasterSlider.value,
		"sfx_volume" : $Settings/SettingsWindows/Options/Option2/SFXSlider.value,
		"bgm_volume" : $Settings/SettingsWindows/Options/Option2/BGMSlider.value
	}
	save.settings = temp_settings
	file.store_var(save)
	file.close()

func check_for_pokemon():
	if pokeball_counter == 6:
		pokeball_counter = 1
	match pokeball_counter:
		0:
			pokeleds.get_node("Pokeled1").modulate = Color(0.497, 0.497, 0.497)
			pokeleds.get_node("Pokeled2").modulate = Color(0.497, 0.497, 0.497)
			pokeleds.get_node("Pokeled3").modulate = Color(0.497, 0.497, 0.497)
			pokeleds.get_node("Pokeled4").modulate = Color(0.497, 0.497, 0.497)
			pokeleds.get_node("Pokeled5").modulate = Color(0.497, 0.497, 0.497)
		1:
			pokeleds.get_node("Pokeled1").modulate = Color(1, 1, 1)
		2:
			pokeleds.get_node("Pokeled2").modulate = Color(1, 1, 1)
		3:
			pokeleds.get_node("Pokeled3").modulate = Color(1, 1, 1)
		4:
			pokeleds.get_node("Pokeled4").modulate = Color(1, 1, 1)			
		5:
			can_continue = false
			#Décidage du pokémon
			var rarity = get_rarity()
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			var pokemon
			match rarity:
				"C":
					pokemon = Common[rng.randi_range(0,Common.size()-1)]
					$ColorRect/Round.modulate = Color.WHITE
					$ColorRect/RarityLabel.text = "Common... (40%)"
				"UC":
					pokemon = Uncommon[rng.randi_range(0,Uncommon.size()-1)]
					$ColorRect/Round.modulate = Color.SEA_GREEN
					$ColorRect/RarityLabel.text = "Uncommon.. (25%)"
				"R":
					pokemon = Rare[rng.randi_range(0,Rare.size()-1)]
					$ColorRect/Round.modulate = Color.MEDIUM_BLUE
					$ColorRect/RarityLabel.text = "Rare. (15%)"
				"SR":
					pokemon = SuperRare[rng.randi_range(0,SuperRare.size()-1)]
					$ColorRect/Round.modulate = Color.ORANGE_RED
					$ColorRect/RarityLabel.text = "SuperRare ! (10%)"
				"SSR":
					pokemon = SuperSuperRare[rng.randi_range(0,SuperSuperRare.size()-1)]
					$ColorRect/Round.modulate = Color.YELLOW
					$ColorRect/RarityLabel.text = "SuperSuperRare !!! (6%)"
				"UR":
					pokemon = UltraRare[rng.randi_range(0,UltraRare.size()-1)]
					$ColorRect/Round.modulate = Color.REBECCA_PURPLE
					$ColorRect/RarityLabel.text = "UltraRare ?!?!? (3%)"
				"MR":
					pokemon = MegaRare[rng.randi_range(0,MegaRare.size()-1)]
					$ColorRect/Round.modulate = Color.HOT_PINK
					$ColorRect/RarityLabel.text = "MEGARARE !!!!!!! T_T (1%)"
			
			#shiny
			var shiny_check = rng.randi_range (1,512)
			if shiny_check == 1:
				$ColorRect/AnimatedSprite2D.play(str(pokemon[1])+"s")
				$ColorRect/Label2.text = "It's a shiny %s !" % [pokemon[0]]
				#Animation et pokémon
				emitter.get_node("AnimationPlayer").pause()
				if save.hills_shinydex[pokemon[0]][2] == false:
					$ColorRect/NewLabel.show()
					save.hills_shinydex[pokemon[0]][2] = true
				else:
					$ColorRect/NewLabel.hide()
			else:
				$ColorRect/AnimatedSprite2D.play(str(pokemon[1]))
				$ColorRect/Label2.text = "It's %s !" % [pokemon[0]]
				#Animation et pokémon
				emitter.get_node("AnimationPlayer").pause()
				if save.hills_pokedex[pokemon[0]][2] == false:
					$ColorRect/NewLabel.show()
					save.hills_pokedex[pokemon[0]][2] = true
				else:
					$ColorRect/NewLabel.hide()
			can_play = false
			for ball in balls:
				ball.set_deferred("freeze", true) 
			catch_animator.play("Pokemon")
			pokeled_animator.play("Pokemon")
			await get_tree().create_timer(4.5).timeout
			$ColorRect/Label3/AnimationTree.play("new_animation")
			can_continue = true
			save_file()

func get_rarity():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var roll = rng.randi() % 100
	if roll < 40:
		return "C"
	elif roll < 65:
		return "UC"
	elif roll < 80:
		return "R"
	elif roll < 90:
		return "SR"
	elif roll < 96:
		return "SSR"
	elif roll < 99:
		return "UR"
	else:
		return "MR"

func _on_out_zone_body_entered(body):
	balls.erase(body)
	body.queue_free()
	pass # Replace with function body.

func _on_new_ball_body_entered(body):
	balls.erase(body)
	body.queue_free()
	$SoundPlayer/sfx_new_ball.play()
	balls_remaining += 1
	save.balls = balls_remaining
	save_file()
	pass # Replace with function body.
	
func _on_pokeball_body_entered(body):
	if body != pokeball_catching:
		if body is RigidBody2D:
			var direction = (body.global_position - global_position).normalized()
			var force = direction * 400.0  # 💥 adapte cette valeur selon le punch souhaité
			body.apply_impulse(Vector2.ZERO, force)
		if pokeball_catching.get_node("Timer").is_stopped():
			
			$SoundPlayer/sfx_pokeball.play()
			pokeball_catching.get_node("AnimationPlayer").play("new_animation")
			pokeball_catching.get_node("Timer").start()
			pokeball_counter += 1
			save_file()
			check_for_pokemon()
		pass # Replace with function body.

func _process(_delta):
	$HUD2/Label.text = "Balls : %s" % balls_remaining
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), $Settings/SettingsWindows/Options/Option2/MasterSlider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), $Settings/SettingsWindows/Options/Option2/SFXSlider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), $Settings/SettingsWindows/Options/Option2/BGMSlider.value)


func _on_button_pressed():
	$Pokedex.hide()
	pass # Replace with function body.


func _on_texture_rect_pressed():
	display_shiny = false
	$Pokedex/passhiny.show()
	$Pokedex/shiny.hide()
	match board:
		"hills":
			$Pokedex/ScrollContainer/PokedexDisplay.load_pdx(save.hills_pokedex, false)
	$Pokedex.show()
	pass # Replace with function body.




func _on_click_pressed():
	action_done()
	pass # Replace with function body.


func _on_shiny_enable_pressed():
	if display_shiny:
		match board:
			"hills":
				$Pokedex/ScrollContainer/PokedexDisplay.load_pdx(save.hills_pokedex, false)
		display_shiny = false
		$Pokedex/passhiny.show()
		$Pokedex/shiny.hide()
	else:
		match board:
			"hills":
				$Pokedex/ScrollContainer/PokedexDisplay.load_pdx(save.hills_shinydex, true)
		display_shiny = true
		$Pokedex/passhiny.hide()
		$Pokedex/shiny.show()
	pass # Replace with function body.


func _on_close_settings_pressed():
	$Settings.hide()
	pass # Replace with function body.


func _on_settings_button_pressed():
	$Settings.show()
	pass # Replace with function body.
