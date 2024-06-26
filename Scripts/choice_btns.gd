extends HBoxContainer

var player: CharacterBody2D

signal increase_shooting_speed
signal increase_damage
signal increase_range

var shooting_speed: float
var damage: float
var range: float

func _ready():
    if is_inside_tree():
        player = get_tree().get_nodes_in_group("Player")[0]
        player.enable_choices.connect(show_buttons.bind(true))

        for choice in get_children():
            choice.pressed.connect(handle_choice_made.bind(choice))

func show_buttons(visibilty: bool) -> void:
    set_random_button_values()
    visible = visibilty

func set_random_button_values():
    for btn in get_children():
        match btn.name:
            "Button":
                shooting_speed = round(randf_range(5.0, 30.0))
                btn.text = "+" + str(shooting_speed) + " shooting_speed"
            "Button2":
                damage = round(randf_range(5.0, 50.0))
                btn.text = "+" + str(damage) + " damage"
            "Button3":
                range = round(randf_range(5.0, 25.0))
                btn.text = "+" + str(range) + " range"

func handle_choice_made(choice: Button) -> void:
    match choice.name:
        "Button":
            increase_shooting_speed.emit(shooting_speed)
        "Button2":
            increase_damage.emit(damage)
        "Button3":
            increase_range.emit(range)

    show_buttons(false)

