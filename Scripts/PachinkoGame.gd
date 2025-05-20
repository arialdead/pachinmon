extends Node2D

const current_version = 1.3

#Déclaration des nodes a réferencer
@export_category("Animator") 
@export var rarity_label_animator : AnimationPlayer
@export var new_label_animator : AnimationPlayer
@export var catch_animator : AnimationPlayer
@export var press_to_continue_animator : AnimationPlayer

@export_category("Sliders")
@export var master_slider : Slider
@export var sfx_slider : Slider
@export var bgm_slider : Slider

@export_category("Labels")
@export var stats_label : Label
@export var balls_remaining_label : Label
@export var rarity_label : Label
@export var new_label : Label
@export var pokemon_name_display : Label
@export var balls_text : Label
@export var catching_labels_container : VBoxContainer

@export_category("Nodes")
@export var pokedex_node : Node
@export var settings_node : Node
@export var pokedex_display_node : Node
@export var scroll_pokedex_node : Node
@export var stats_node : Node
@export var board_container : Node
@export var got_x_balls : Node

@export_category("Buttons")
@export var pas_shiny_button : TextureButton
@export var shiny_button : TextureButton
@export var stats_button : TextureButton
@export var balls_nice : Button
 
@export_category("Animated Sprite 2D")
@export var pokemon_sprites : AnimatedSprite2D

#Déclaration des scenes a instancier
@export_category("Scenes")
@export var ball_scene: PackedScene
@export var hills : PackedScene

#Déclaration des variables essentiels ⚠️ A verifier lesquels sont vrmt essentiels
var balls_remaining = 500
var ball_count = 0
var pokedex_completion = 0
var time_spent = 0
var saved_time = 0
var shiny_completion = 0
var pokeball_counter = 0
var balls = []
var can_play=true
var can_continue=true
var save
var board = "hills"
var display_shiny = false
var current_time = Time.get_unix_time_from_system()


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

	#Prelaunch Animations
	rarity_label_animator.play("loop")
	new_label_animator.play("Scaling")
	
	#Load or create save file
	if not FileAccess.file_exists("user://save.save"):
		var hills_pokedex = generate_hills_pokedex()
		var hills_shinydex = generate_hills_pokedex()
		save = {
			"last_time_got_ball" : Time.get_datetime_dict_from_system(),
			"balls" : 500,
			"ball_count" : 0,
			"pokedex_completion" : 0,
			"shiny_completion" : 0,
			"time_spent" : 0,
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
				"ball_count" : save.ball_count,
				"pokedex_completion" : save.pokedex_completion,
				"shiny_completion" : save.shiny_completion,
				"time_spent" : save.time_spent,
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
				1.2:
					save["ball_count"] = 0
					save["pokedex_completion"] = 0
					save["shiny_completion"] = 0
					save["time_spent"] = 0
					save.last_version = 1.3
		
		master_slider.value = save.settings.master_volume
		sfx_slider.value = save.settings.sfx_volume
		bgm_slider.value = save.settings.bgm_volume
		
		var time = Time.get_datetime_dict_from_system()
		var old_time = save.last_time_got_ball
		#calculate time dif	
		var temp_balls = 0
		
		var dif_minutes = time.minute - old_time.minute
		if dif_minutes >= 1:
			temp_balls += floor(dif_minutes)
			
		var dif_hours = time.hour - old_time.hour
		if dif_hours >= 1:
			temp_balls += floor(dif_hours)*60
		
		var dif_days = time.day - old_time.day
		if dif_days >= 1:
			temp_balls += floor(dif_days)*24*60
		
		if temp_balls > 2000:
			temp_balls = 2000
		
		#load last stats
		ball_count = save.ball_count
		pokedex_completion = save.pokedex_completion
		shiny_completion = save.shiny_completion
		time_spent = save.time_spent
		
		#add balls
		balls_remaining = save.balls + temp_balls
		if temp_balls > 0:
			save.balls = balls_remaining
			save.last_time_got_ball = time
			balls_text.text = "You got %s balls while you were away !" % temp_balls
		else:
			got_x_balls.hide()
		file.close()
		save_file()
	
	#load last_board
	var current_board
	match save.last_board:
		"hills":
			var uwu = hills.instantiate()
			board_container.add_child(uwu)
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
	stats_label.text = "Balles lancées: "+str(ball_count)+"\n"+"Temps perdu: "+str(_format_seconds_to_hhmmss(time_spent))+"\n"+"Pokédex complété à "+str(round(pokedex_completion))+"%"+"\n"+"Shinydex complété à "+str(round(shiny_completion))+"%"
	check_for_pokemon()

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
	if Input.is_action_just_pressed ("ui_accept") and pokedex_node.is_visible_in_tree() == false and settings_node.is_visible_in_tree() == false:
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
		press_to_continue_animator.pause()
		await get_tree().create_timer(1.0).timeout
		can_play = true
		for ball in balls:
				ball.set_deferred("freeze", false) 
		emitter.get_node("AnimationPlayer").play()
		press_to_continue_animator.play("RESET")
		new_label.hide()

func spawn_ball():
	if can_play:
		var ball = ball_scene.instantiate()
		balls_children.add_child(ball)
		print("emitter position : %s | ball position : %s" % [emitter.position,ball.position])
		ball.global_position = emitter.global_position
		balls_remaining -= 1
		$SoundPlayer/sfx_ball_launched.play()
		save.balls = balls_remaining
		ball_count += 1
		save_file()
		balls.append(ball)

func save_file():
	var file = FileAccess.open("user://save.save",FileAccess.WRITE)
	save.balls_remaining = balls_remaining
	save.ball_count = ball_count
	save.time_spent = time_spent
	save.pokedex_completion = pokedex_completion
	save.shiny_completion = shiny_completion
	save.pokeball_counter = pokeball_counter
	var temp_settings = {
		"master_volume" : master_slider.value,
		"sfx_volume" : sfx_slider.value,
		"bgm_volume" : bgm_slider.value
	}
	save.settings = temp_settings
	file.store_var(save)
	file.close()

func check_for_pokemon():
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
			pokeleds.get_node("Pokeled1").modulate = Color(1, 1, 1)
			pokeleds.get_node("Pokeled2").modulate = Color(1, 1, 1)
		3:
			pokeleds.get_node("Pokeled1").modulate = Color(1, 1, 1)
			pokeleds.get_node("Pokeled2").modulate = Color(1, 1, 1)
			pokeleds.get_node("Pokeled3").modulate = Color(1, 1, 1)
		4:
			pokeleds.get_node("Pokeled1").modulate = Color(1, 1, 1)
			pokeleds.get_node("Pokeled2").modulate = Color(1, 1, 1)
			pokeleds.get_node("Pokeled3").modulate = Color(1, 1, 1)
			pokeleds.get_node("Pokeled4").modulate = Color(1, 1, 1)			
		5:
			pokeball_counter = 0
			can_continue = false
			#Décidage du pokémon
			var rarity = get_rarity()
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			var pokemon
			match rarity:
				"Common":
					pokemon = Common[rng.randi_range(0,Common.size()-1)]
					rarity_label.text = "Common... (40%)"
				"UnCommon":
					pokemon = Uncommon[rng.randi_range(0,Uncommon.size()-1)]
					rarity_label.text = "Uncommon.. (25%)"
				"Rare":
					pokemon = Rare[rng.randi_range(0,Rare.size()-1)]
					rarity_label.text = "Rare. (15%)"
				"SuperRare":
					pokemon = SuperRare[rng.randi_range(0,SuperRare.size()-1)]
					rarity_label.text = "Super Rare ! (10%)"
				"SuperSuperRare":
					pokemon = SuperSuperRare[rng.randi_range(0,SuperSuperRare.size()-1)]
					rarity_label.text = "Super Super Rare !!! (6%)"
				"UltraRare":
					pokemon = UltraRare[rng.randi_range(0,UltraRare.size()-1)]
					rarity_label.text = "Ultra Rare ?!?!? (3%)"
				"MegaRare":
					pokemon = MegaRare[rng.randi_range(0,MegaRare.size()-1)]
					rarity_label.text = "MEGA RARE !!!!!!! T_T (1%)"
			
			#shiny
			var shiny_check = rng.randi_range (1,512)
			if shiny_check == 1:
				pokemon_sprites.play(str(pokemon[1])+"s")
				pokemon_name_display.text = "It's a shiny %s !" % [pokemon[0]]
				#Animation et pokémon
				emitter.get_node("AnimationPlayer").pause()
				if save.hills_shinydex[pokemon[0]][2] == false:
					new_label.show()
					save.hills_shinydex[pokemon[0]][2] = true
				else:
					new_label.hide()
			else:
				pokemon_sprites.play(str(pokemon[1]))
				pokemon_name_display.text = "It's %s !" % [pokemon[0]]
				#Animation et pokémon
				emitter.get_node("AnimationPlayer").pause()
				if save.hills_pokedex[pokemon[0]][2] == false:
					new_label.show()
					save.hills_pokedex[pokemon[0]][2] = true
				else:
					new_label.hide()
			can_play = false
			for ball in balls:
				ball.set_deferred("freeze", true) 
			catch_animator.play(rarity)
			pokeled_animator.play("Pokemon")
			pokedex_completion = calculate_pokemon_percentage(save.hills_pokedex, whole_hills_pokedex)
			shiny_completion = calculate_pokemon_percentage(save.hills_shinydex, whole_hills_pokedex)
			save_file()

func get_rarity():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var roll = rng.randi() % 100
	if roll < 40:
		return "Common"
	elif roll < 65:
		return "UnCommon"
	elif roll < 80:
		return "Rare"
	elif roll < 90:
		return "SuperRare"
	elif roll < 96:
		return "SuperSuperRare"
	elif roll < 99:
		return "UltraRare"
	else:
		return "MegaRare"
		

func _format_seconds_to_hhmmss(seconds):
	var total_seconds = int(seconds)
	@warning_ignore("integer_division")
	var hours = total_seconds / 3600
	@warning_ignore("integer_division")
	var minutes = (total_seconds % 3600) / 60
	var secs = total_seconds % 60

	return "%02d:%02d:%02d" % [hours, minutes, secs]

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
			check_for_pokemon()
			save_file()
		pass # Replace with function body.
 
func _process(_delta):
	balls_remaining_label.text = "Balls : %s" % balls_remaining
	rarity_label.pivot_offset = rarity_label.size/2
	catching_labels_container.pivot_offset = catching_labels_container.size/2
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_slider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_slider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), bgm_slider.value)

func _on_button_pressed():
	pokedex_node.hide()
	pass # Replace with function body.


func _on_texture_rect_pressed():
	pas_shiny_button.show()
	shiny_button.show()
	match board:
		"hills":
			pokedex_display_node.load_pdx(save.hills_pokedex, false)
	pokedex_node.show()
	pass # Replace with function body.

func _on_shiny_enable_pressed():
	pas_shiny_button.set_disabled(true)
	shiny_button.set_disabled(false)
	stats_button.set_disabled(false)
	display_shiny = false
	stats_node.hide()
	scroll_pokedex_node.show()
	match board:
		"hills":
			pokedex_display_node.load_pdx(save.hills_pokedex, false)
	pass # Replace with function body.


func _on_close_settings_pressed():
	settings_node.hide()
	pass # Replace with function body.


func _on_settings_button_pressed():
	settings_node.show()
	pass # Replace with function body.


func _on_stats_button_pressed():
	scroll_pokedex_node.hide()
	stats_node.show()
	stats_button.set_disabled(true)
	pas_shiny_button.set_disabled(false)
	shiny_button.set_disabled(false)
	pass # Replace with function body.


func _on_shiny_pressed():
	display_shiny = true
	stats_node.hide()
	scroll_pokedex_node.show()
	pas_shiny_button.set_disabled(false)
	stats_button.set_disabled(false)
	shiny_button.set_disabled(true)
	match board:
			"hills":
				pokedex_display_node.load_pdx(save.hills_shinydex, true)
	pass # Replace with function body.

func _on_timer_timeout():
	time_spent += 1
	stats_label.text = "Balles lancées: "+str(ball_count)+"\n"+"Temps perdu: "+str(_format_seconds_to_hhmmss(time_spent))+"\n"+"Pokédex complété à "+str(round(pokedex_completion))+"%"+"\n"+"Shinydex complété à "+str(round(shiny_completion))+"%"
	pass # Replace with function body.

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_file()

func calculate_pokemon_percentage(dict1, dict2):
	var count1 := 0
	for key in dict1.keys():
		var data = dict1[key]
		if typeof(data) == TYPE_ARRAY and data.size() >= 3:
			if data[2] == true:
				count1 += 1
	
	var count2 := 0
	for rarity in dict2.keys():
		var pokemon_list = dict2[rarity]
		if typeof(pokemon_list) == TYPE_ARRAY:
			count2 += pokemon_list.size()
	
	if count2 == 0:
		push_error("dict2 est vide, division par zéro évitée.")
		return 0.0

	var percentage := float(count1) / float(count2) * 100.0
	return percentage


func _on_catch_animator_animation_finished(anim_name):
	if anim_name != "Closing":
		press_to_continue_animator.play("new_animation")
		can_continue = true
	pass # Replace with function body.


func _on_one_minute_timer_timeout():
	print("Got new ball !")
	balls_remaining += 1
	$SoundPlayer/sfx_new_ball.play()
	save.last_time_got_ball = Time.get_datetime_dict_from_system()
	save_file()
	pass # Replace with function body.


func _on_balls_nice_pressed():
	got_x_balls.hide()
	pass # Replace with function body.
