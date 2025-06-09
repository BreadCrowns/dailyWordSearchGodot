extends Control

@onready var back_button = $VBoxContainer/BackButton
@onready var history_list = $VBoxContainer/ScrollContainer/HistoryList

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	load_history()

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
			history_list.add_child(label)

func _on_back_pressed():
	var scene = load("res://scenes/MainMenu.tscn")
	if scene:
		var main_menu = scene.instantiate()
		get_tree().root.add_child(main_menu)
		queue_free()
	else:
		push_error("Failed to load MainMenu.tscn")
