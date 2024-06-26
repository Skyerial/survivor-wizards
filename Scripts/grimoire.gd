extends Node2D

@export var bullet: PackedScene
var player: CharacterBody2D = null
var ui_choice_buttons: HBoxContainer = null

enum modifiers {SHOOTING_SPEED, DAMAGE, RANGE}

# base stats of the weapon which can be enhanced based on the players buffs
var shooting_speed: float = 1.0
var range: float = 100.0
var damaga: float = 50.0
var casting: bool = false


func _ready():
    if is_inside_tree():
        player = get_tree().get_nodes_in_group("Player")[0]
        ui_choice_buttons = get_tree().get_nodes_in_group("UI")[0]
    # this only needs to be done once cause it will then keep looping as long
    # as the player is alive
    connect_choice_signals()
    player_attacking()

func connect_choice_signals():
    ui_choice_buttons.increase_shooting_speed.connect(update_stats.bind(modifiers.SHOOTING_SPEED))
    ui_choice_buttons.increase_damage.connect(update_stats.bind(modifiers.DAMAGE))
    ui_choice_buttons.increase_range.connect(update_stats.bind(modifiers.RANGE))

func player_attacking() -> void:
    # should shoot where mouse is aiming
    # should shoot with a certain speed
    while player.current_health > 0:
        if enemy_in_range():
            var direction = get_closest_enemy()
            grimoire_position(direction.x)
            $AnimationPlayer.play("casting")

        await get_tree().create_timer(shooting_speed).timeout

func _on_animation_player_animation_finished(anim_name):
    if anim_name == "casting":
        $AnimationPlayer.play("idle")

func grimoire_position(x: float) -> void:
    if x >= 0 and $Sprite2D.position.x < 0:
        $Sprite2D.position.x *= -1
    elif x < 0 and $Sprite2D.position.x > 0:
        $Sprite2D.position.x *= -1

# check if there is an enemy within range, stop immediately when we find one enemy in range
func enemy_in_range() -> bool:
    var possible_direction_distance: float

    for node in get_tree().get_nodes_in_group("enemies"):
        possible_direction_distance = global_position.distance_to(node.global_position)
        if possible_direction_distance < range:
            return true

    return false

# get the direction to the closest enemy
func get_closest_enemy() -> Vector2:
    var possible_direction_distance: float
    var direction_distance: float = range
    var direction: Vector2 = Vector2()

    for node in get_tree().get_nodes_in_group("enemies"):
        possible_direction_distance = global_position.distance_to(node.global_position)
        if possible_direction_distance < direction_distance:
            direction = global_position.direction_to(node.global_position)
            direction_distance = possible_direction_distance

    return direction

func fire_bullet() -> void:
    var direction = get_closest_enemy()

    # basically if we found an enemy spawn a bullet to shoot at it, otherwise do nothing
    if !direction.is_zero_approx():
        var bullet_instance: Node2D = bullet.instantiate()
        bullet_instance.direction = direction
        bullet_instance.spawn_location = $Sprite2D.global_position
        bullet_instance.range = range
        bullet_instance.damage = damaga
        # add it as child of root so it is not related with the player and its position
        get_tree().root.add_child.call_deferred(bullet_instance)

func update_stats(value: float, mod: modifiers) -> void:
    match mod:
        modifiers.SHOOTING_SPEED:
            shooting_speed += value
        modifiers.DAMAGE:
            damaga += value
        modifiers.RANGE:
            range += value

    get_tree().paused = false
