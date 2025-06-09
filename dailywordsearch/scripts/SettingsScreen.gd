extends Control

@onready var back_button = $VBoxContainer/BackButton

func _ready():
        back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed():
        var scene = load("res://scenes/MainMenu.tscn")
        if scene:
                var main_menu = scene.instantiate()
                get_tree().root.add_child(main_menu)
                queue_free()
        else:
                push_error("Failed to load MainMenu.tscn")
