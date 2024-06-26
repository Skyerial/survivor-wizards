extends Node2D

var spawn_location: Vector2 = Vector2()
var direction: Vector2 = Vector2()
@export var speed: float = 200
var range: float
var damage: float

func _ready():
    global_position = spawn_location
    # set rotation of sprite
    set_bullet_rotation()
    $AnimatedSprite2D.play("bullet_flying")

func _process(delta):
    translate(direction * (speed) * delta)
    if global_position.distance_to(spawn_location) > range:
        queue_free()
    # delete bullets after it has flown a certain distance from the character

func set_bullet_rotation():
    var angle = direction.angle()
    rotate(angle)

func _on_area_2d_body_entered(body: Node2D):
    # ToDo when enemy has health and more functionality
    # damage enemy and delete the bullet
    if body.is_in_group("enemies"):
        body.health -= damage
        queue_free()
