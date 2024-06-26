extends CharacterBody2D

# @export so they can be changed from the editor
@export var speed: float = 100.0

enum cardinal_direction {NORTH, EAST, SOUTH, WEST}

# signals for player
signal health_changed
signal xp_changed
signal enable_choices

# globals for player
var alive: bool = true
var max_health: float = 100.0
var current_health: float = 100.0
var player_faces: cardinal_direction = cardinal_direction.EAST
var experience: float = 0.0

func _ready():
    var enemy_spawner = get_parent().get_node("enemy_spawner")
    enemy_spawner.new_xp.connect(update_xp)

func _physics_process(delta):
    # do player stuff
    if alive:
        player_movement()
        player_animations()

        # do engine stuff
        move_and_slide()

func player_movement():
    var x_movement = Input.get_action_strength("ui_move_right") - Input.get_action_strength("ui_move_left")
    var y_movement = Input.get_action_strength("ui_move_down") - Input.get_action_strength("ui_move_up")
    var movement_input = Vector2(x_movement, y_movement).normalized()
    velocity = movement_input * speed

func player_animations():
    if Input.is_action_pressed("ui_move_right"):
        player_faces = cardinal_direction.EAST
        $AnimatedSprite2D.flip_h = false
        $AnimatedSprite2D.play("run_sideways")
    elif Input.is_action_pressed("ui_move_left"):
        player_faces = cardinal_direction.WEST
        $AnimatedSprite2D.flip_h = true
        $AnimatedSprite2D.play("run_sideways")
    elif Input.is_action_pressed("ui_move_up"):
        player_faces = cardinal_direction.NORTH
        $AnimatedSprite2D.play("run_backwards")
    elif Input.is_action_pressed("ui_move_down"):
        player_faces = cardinal_direction.SOUTH
        $AnimatedSprite2D.play("run_forwards")

    # set animation to idle when nothing is happening
    if !Input.is_anything_pressed():
        if player_faces == cardinal_direction.EAST || player_faces == cardinal_direction.WEST:
            $AnimatedSprite2D.play("idle_sideways")
        if player_faces == cardinal_direction.NORTH:
            $AnimatedSprite2D.play("idle_backwards")
        if player_faces == cardinal_direction.SOUTH:
            $AnimatedSprite2D.play("idle_forwards")

# deal with enemy damaging the player
# when multiple enemies it might be better to signal damage from enemy to player
# and then have player update its health or even let the enemy handle that
func _on_enemy_detector_body_entered(body: Node2D):
    if body.is_in_group("enemies"):
        current_health -= 10
        health_changed.emit()

    if current_health <= 0:
        alive = false
        $AnimatedSprite2D.play("death")

func update_xp():
    experience += 10
    xp_changed.emit()
    if experience == 100:
        get_tree().paused = true
        experience = 0
        xp_changed.emit()
        enable_choices.emit()
