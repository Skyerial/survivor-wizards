extends CharacterBody2D

# This defines the slime behaviour
# The slime walks toward the player, slightly lagging on movement, see DRG survivors
# Should hurt the player when it collides with it

@export var speed: float = 50.0
var health = 100
var alive: bool = true

var player: CharacterBody2D = null

signal slime_death_xp

func _ready():
    if is_inside_tree():
        player = get_tree().get_nodes_in_group("Player")[0]

    $AnimatedSprite2D.connect("animation_finished", cleanup)
    $AnimatedSprite2D.play("run_forwards")

func _process(delta):
    if alive:
        death()
        velocity = find_direction() * speed
        move_and_slide()

func find_direction() -> Vector2:
    var direction = player.position - self.position

    return direction.normalized()

func death():
    if health <= 0 and alive:
        slime_death_xp.emit()
        # stop slime movement, play animation and when done delete
        $AnimatedSprite2D.play("death")
        alive = false

func cleanup():
    queue_free()
