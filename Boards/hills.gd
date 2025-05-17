extends Node2D

@onready var emitter = $BallEmiter
@onready var balls_children = $BallsChildren
@onready var new_balls_array = [$NewBalls/NewBall,$NewBalls/NewBall2,$NewBalls/NewBall3,$NewBalls/NewBall4,$NewBalls/NewBall5]
@onready var out_zones_array = [$OutZones/OutZone]
@onready var pokeball = $PokeballCatching/Pokeball
@onready var pokeball_catching = $PokeballCatching
@onready var pokeleds = $Pokeleds
@onready var pokeled_animator = $Pokeleds/PokeledAnimator
