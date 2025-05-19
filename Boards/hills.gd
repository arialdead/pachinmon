extends Control

@onready var emitter = $BoardContainer/BallEmiter
@onready var balls_children = $BoardContainer/BallsChildren
@onready var new_balls_array = [$BoardContainer/NewBalls/NewBall,$BoardContainer/NewBalls/NewBall2,$BoardContainer/NewBalls/NewBall3,$BoardContainer/NewBalls/NewBall4,$BoardContainer/NewBalls/NewBall5]
@onready var out_zones_array = [$BoardContainer/OutZones/OutZone]
@onready var pokeball = $BoardContainer/PokeballCatching/Pokeball
@onready var pokeball_catching = $BoardContainer/PokeballCatching
@onready var pokeleds = $BoardContainer/Pokeleds
@onready var pokeled_animator = $BoardContainer/Pokeleds/PokeledAnimator
