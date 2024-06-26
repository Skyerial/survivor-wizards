extends Area2D

var is_reachable = false

func _process(delta):
    if is_reachable and Input.is_action_just_pressed("ui_interact"):
        $AnimatedSprite2D.play("chest_open")
        # wait a bit and delete the chest
        await get_tree().create_timer(1.0).timeout
        #self.queue_free()

func _on_body_entered(body):
    if body.is_in_group("Player"):
        is_reachable = true

func _on_body_exited(body):
    is_reachable = false
