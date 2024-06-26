extends Node2D

# Goal of this spawner is being able to spawn any kind of animal
# and to keep track of enemies alive

@onready var slime_scene: Resource = preload("res://Scenes/slime_scene.tscn")

signal new_xp

@export var MAX_ENEMIES = 10
@export var spawn_radius: float = 100.0

var player: CharacterBody2D = null
var tilemap: TileMap = null

var n_enemies = 0

func _ready() -> void:
    if is_inside_tree():
        player = get_tree().get_nodes_in_group("Player")[0]
        tilemap = get_tree().get_nodes_in_group("Tilemap")[0]

func _on_timer_timeout() -> void:
    spawn_enemy(slime_scene)

func spawn_enemy(enemy_scene: Resource) -> void:
    # some sort of math here to do the following:
    # get a point at the spawn radius of the player
    # set it somewhere random on that circle
    # then move it from not to a bit away from the player
    var spawn_location
    if (player && n_enemies < MAX_ENEMIES):
        spawn_location = find_spawn_location()

        # create the enemy and set its location
        var enemy = slime_scene.instantiate()
        enemy.position = spawn_location
        enemy.slime_death_xp.connect(enemy_death)
        add_child(enemy)
        n_enemies += 1

func find_spawn_location() -> Vector2:
    # calculate a possible spawn location
    var spawn_location = null
    var looking_for_spawn = true

    # might want to add a way to not check indefinitely??
    while (looking_for_spawn):
        var distance_to_player = randf() + spawn_radius
        var angle_to_player = (randf_range(-360.0, 360.0) * PI) / 180
        spawn_location = player.position \
                         + Vector2(cos(angle_to_player), sin(angle_to_player)) * distance_to_player

        # need to make sure that spawn_location is not out of bounds
        if is_spawn_tile(spawn_location):
            looking_for_spawn = false

    return spawn_location

func is_spawn_tile(spawn_location: Vector2) -> bool:
    var cell_position = tilemap.local_to_map(spawn_location)
    var tile_data: TileData = tilemap.get_cell_tile_data(0, cell_position)
    if (tile_data):
        if (tile_data.get_custom_data("spawn_tiles") == "basic_floor"):
            return true

    return false

func enemy_death():
    new_xp.emit()
    n_enemies -= 1
