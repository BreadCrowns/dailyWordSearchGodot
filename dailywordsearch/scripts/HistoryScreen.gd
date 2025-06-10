extends Control

const ThemeConfig = preload("res://scripts/Theme.gd")

@onready var back_button = $VBoxContainer/BackButton
@onready var history_list = $VBoxContainer/ScrollContainer/HistoryList

func _ready():
        _add_background()
        back_button.pressed.connect(_on_back_pressed)
        back_button.add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
        load_history()

func _add_background():
        var bg = ColorRect.new()
        bg.anchor_right = 1
        bg.anchor_bottom = 1
        bg.color = ThemeConfig.BG_COLOR
        add_child(bg)
        move_child(bg, 0)

func load_history():
        for child in history_list.get_children():
                history_list.remove_child(child)
                child.queue_free()
        var path = "user://history.json"
        if FileAccess.file_exists(path):
                var file = FileAccess.open(path, FileAccess.READ)
                var data = JSON.parse_string(file.get_as_text())
                file.close()
                if typeof(data) == TYPE_ARRAY:
                        for entry in data:
                                var label = Label.new()
                                var date = entry.get("date", "")
                                var count = entry.get("solved_words", []).size()
                                label.text = "%s - %d words" % [date, count]
                                label.add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
                                history_list.add_child(label)

func _on_back_pressed():
        var scene = load("res://scenes/MainMenu.tscn")
        if scene:
                var main_menu = scene.instantiate()
                get_tree().root.add_child(main_menu)
                queue_free()
        else:
                push_error("Failed to load MainMenu.tscn")
