extends Control

const ThemeConfig = preload("res://scripts/Theme.gd")

@onready var back_button = $VBoxContainer/BackButton
@onready var title_label = $VBoxContainer/Label

func _ready():
        _add_background()
        back_button.pressed.connect(_on_back_pressed)
        back_button.add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
        title_label.add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)

func _add_background():
        var bg = ColorRect.new()
        bg.anchor_right = 1
        bg.anchor_bottom = 1
        bg.color = ThemeConfig.BG_COLOR
        add_child(bg)
        move_child(bg, 0)

func _on_back_pressed():
        var scene = load("res://scenes/MainMenu.tscn")
        if scene:
                var main_menu = scene.instantiate()
                get_tree().root.add_child(main_menu)
                queue_free()
        else:
                push_error("Failed to load MainMenu.tscn")
