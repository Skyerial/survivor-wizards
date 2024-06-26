extends ProgressBar

var player: CharacterBody2D

func _ready():
    if is_inside_tree():
        player = get_tree().get_nodes_in_group("Player")[0]
        player.health_changed.connect(update)

func update():
    value = player.current_health * 100 / player.max_health
