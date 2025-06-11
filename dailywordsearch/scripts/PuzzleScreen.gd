extends Control

const ThemeConfig = preload("res://scripts/Theme.gd")

# Node references for the grid, word labels, and dynamic line container
@onready var grid = $MarginContainer/VBoxContainer/MarginContainer/AspectRatioContainer/GridContainer
@onready var line_layer = $MarginContainer/VBoxContainer/MarginContainer/AspectRatioContainer/LineLayer
@onready var back_button = $MarginContainer/VBoxContainer/HBoxContainer/back_button
@onready var title_label = $MarginContainer/VBoxContainer/title
@onready var ui_container = $MarginContainer
@onready var word_list_col1 = [
		$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_0,
		$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_1,
		$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_2,
		$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_3,
		$MarginContainer/VBoxContainer/word_list_container/word_columns/left_column/word_label_left_4,
]
@onready var word_list_col2 = [
		$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_0,
		$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_1,
		$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_2,
		$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_3,
		$MarginContainer/VBoxContainer/word_list_container/word_columns/right_column/word_label_right_4,
]
@onready var word_label_center = $MarginContainer/VBoxContainer/word_list_container/center_word_container/word_label_center

# Grid configuration
const GRID_SIZE = 12
var grid_letters: String = "NERSIEEBLNMEAPCESNPIBPMAEMDMTUFRBAAHMTAORDREMMZHOORSSESECROTAGUTHLREGTEZNEURIBOROIEMFBMEBMOFLOMDLBRGLABITENNEEENNHESPROCSFZUISCOSRHEHELHAFLMRAEA"

# Word list
var words: Array = ["Corpse", "Shamble", "Bite", "Infected", "Rot", "Moan", "Groan", "Pursue", "Flesh", "Hunger", "Zombie"]

# Puzzle date and history tracking
var puzzle_date: String
var solved_words: Array = []
var http_request: HTTPRequest

# Dragging state variables
var drag_start: Vector2i = Vector2i(-1, -1)
var drag_end: Vector2i = Vector2i(-1, -1)
var dragging: bool = false
var active_line: Line2D = null

# Constants
const SECRET_INDEX := 10

# Appearance configuration
var bg_rect: ColorRect

func _init_background():
		bg_rect = ColorRect.new()
		bg_rect.anchor_right = 1
		bg_rect.anchor_bottom = 1
		bg_rect.color = ThemeConfig.BG_COLOR
		add_child(bg_rect)
		move_child(bg_rect, 0)

func _apply_colors():
		title_label.add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
		for child in grid.get_children():
				if child is Label:
						child.add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
		for label in word_list_col1 + word_list_col2 + [word_label_center]:
				if label.get_theme_color("font_color") != Color.GREEN:
						label.add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
		for line in line_layer.get_children():
				if line is Line2D:
						line.default_color = ThemeConfig.LINE_COLOR
						line.modulate = ThemeConfig.LINE_COLOR

func _apply_title_font():
		title_label.add_theme_font_override("font", load(ThemeConfig.TITLE_FONT_PATH))

func _apply_grid_font_to_child(child):
		if child is Label:
				child.add_theme_font_override("font", load(ThemeConfig.GRID_FONT_PATH))

func _apply_word_font_to_label(label):
				label.add_theme_font_override("font", load(ThemeConfig.WORD_FONT_PATH))

func _add_strikethrough(label: Control, color: Color):
				if label.has_node("Strike"):
								return
				var rect := ColorRect.new()
				rect.name = "Strike"
				rect.color = color
				rect.anchor_left = 0
				rect.anchor_right = 1
				rect.anchor_top = 0.5
				rect.anchor_bottom = 0.5
				rect.offset_top = -1
				rect.offset_bottom = 1
				label.add_child(rect)


# Initialization
func _ready():
		ui_container.visible = false
		set_process_input(false)
		http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(_on_puzzle_request_completed)
		puzzle_date = Time.get_date_string_from_system()

		_init_background()
		_apply_title_font()
		_apply_colors()

		request_puzzle(puzzle_date)
		back_button.pressed.connect(_on_back_pressed)

# Handle back button press
func _on_back_pressed():
		var scene = load("res://scenes/MainMenu.tscn")
		if scene:
				var main_menu = scene.instantiate()
				get_tree().root.add_child(main_menu)
				queue_free()
		else:
				push_error("Failed to load MainMenu.tscn")

func request_puzzle(date: String):
		var url = "https://your-project.firebaseio.com/puzzles/%s.json" % date
		http_request.request(url)

func _on_puzzle_request_completed(result, response_code, headers, body):
		if result == OK and response_code == 200:
			var text = body.get_string_from_utf8()
			var data = JSON.parse_string(text)
			if typeof(data) == TYPE_DICTIONARY:
				grid_letters = data.get("grid", grid_letters)
				words = data.get("words", words)
		generate_grid()
		load_words()
		_apply_colors()
		ui_container.visible = true
		set_process_input(true)

# Generate the letter grid from the predefined string
func generate_grid():
		if grid_letters.length() < GRID_SIZE * GRID_SIZE:
				push_error("GRID_LETTERS string is too short for grid size")
				return

		for child in grid.get_children():
				grid.remove_child(child)
				child.queue_free()

		var index := 0
		for y in range(GRID_SIZE):
				for x in range(GRID_SIZE):
						var label = Label.new()
						label.text = grid_letters[index]
						index += 1
						label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
						label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
						label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						label.size_flags_vertical = Control.SIZE_EXPAND_FILL
						label.custom_minimum_size = Vector2(48, 48)
						label.add_theme_font_size_override("font_size", 24)
						_apply_grid_font_to_child(label)
						label.add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
						label.set_meta("grid_pos", Vector2i(x, y))
						grid.add_child(label)

# Load and display the word list
func load_words():
		for i in range(min(5, words.size())):
				word_list_col1[i].text = words[i].to_upper()
				word_list_col1[i].add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
				word_list_col1[i].add_theme_font_size_override("font_size", 30)
				_apply_word_font_to_label(word_list_col1[i])
		for i in range(5, min(10, words.size())):
				word_list_col2[i - 5].text = words[i].to_upper()
				word_list_col2[i - 5].add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
				word_list_col2[i - 5].add_theme_font_size_override("font_size", 30)
				_apply_word_font_to_label(word_list_col2[i - 5])
		if words.size() > 10:
				word_label_center.text = "?????"
		else:
				word_label_center.text = ""
		word_label_center.add_theme_color_override("font_color", ThemeConfig.LETTER_COLOR)
		word_label_center.add_theme_font_size_override("font_size", 30)
		_apply_word_font_to_label(word_label_center)

# Input handling
func _input(event):
		if event is InputEventScreenTouch or event is InputEventMouseButton:
				if event.pressed:
						if not is_point_inside_grid(event.position):
								dragging = false
								return
						drag_start = get_grid_cell_from_position(event.position)
						dragging = true
						active_line = Line2D.new()
						active_line.width = 30
						active_line.default_color = ThemeConfig.LINE_COLOR
						active_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
						active_line.end_cap_mode = Line2D.LINE_CAP_ROUND
						line_layer.add_child(active_line)
						var start_pos = get_grid_cell_center(drag_start) - line_layer.get_global_position()
						active_line.add_point(start_pos)
						active_line.add_point(start_pos)
				else:
						if not dragging or active_line == null:
								return
						dragging = false
						drag_end = get_grid_cell_from_position(event.position)
						var result = false
						if is_straight_line(drag_start, drag_end):
								result = process_selection(drag_start, drag_end)
						if result:
								var end_pos = get_grid_cell_center(drag_end) - line_layer.get_global_position()
								active_line.set_point_position(1, end_pos)
						else:
								line_layer.remove_child(active_line)
								active_line.queue_free()
						active_line = null
		elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and dragging and active_line != null:
				var current_pos = event.position - line_layer.get_global_position()
				active_line.set_point_position(1, current_pos)

# Word selection logic
func process_selection(start: Vector2i, end: Vector2i) -> bool:
				var direction = end - start
				var step = direction.sign()
				if not is_straight_line(start, end):
								return false

				var selected_word := ""
				var pos = start
				while pos != end + step:
								var index = pos.y * GRID_SIZE + pos.x
								if index >= 0 and index < grid_letters.length():
												selected_word += grid_letters[index]
								pos += step

				var match_index := -1
				for i in range(words.size()):
								var lw = words[i].to_lower()
								if lw == selected_word.to_lower() or lw == selected_word.reverse().to_lower():
												match_index = i
												break

				if match_index != -1:
								var normalized = words[match_index].to_lower()
								if normalized not in solved_words:
												solved_words.append(normalized)

								var label: Label = null
								if match_index < 5:
												label = word_list_col1[match_index]
								elif match_index < 10:
												label = word_list_col2[match_index - 5]
								else:
												label = word_label_center

								if match_index == SECRET_INDEX:
												label.text = words[match_index].to_upper()
												label.add_theme_color_override("font_color", ThemeConfig.SECRET_COLOR)
												_add_strikethrough(label, ThemeConfig.SECRET_COLOR)
												if active_line:
																active_line.default_color = ThemeConfig.SECRET_COLOR
																active_line.modulate = ThemeConfig.SECRET_COLOR
								else:
												label.modulate = Color(1, 1, 1, 0.5)
												_add_strikethrough(label, ThemeConfig.LINE_COLOR)

								if solved_words.size() == words.size():
												_record_history()
								return true

				return false

func _record_history():
		var path = "user://history.json"
		var history = []
		if FileAccess.file_exists(path):
				var file = FileAccess.open(path, FileAccess.READ)
				var data = JSON.parse_string(file.get_as_text())
				file.close()
				if typeof(data) == TYPE_ARRAY:
						history = data
		history.append({"date": puzzle_date, "solved_words": solved_words})
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(JSON.stringify(history))
		file.close()

# Utilities
func get_grid_cell_from_position(pos: Vector2) -> Vector2i:
		var grid_pos = grid.get_global_position()
		var grid_size = grid.get_size()
		var cell_size = grid_size / float(GRID_SIZE)
		var local_pos = pos - grid_pos
		var x = clamp(floor(local_pos.x / cell_size.x), 0, GRID_SIZE - 1)
		var y = clamp(floor(local_pos.y / cell_size.y), 0, GRID_SIZE - 1)
		return Vector2i(x, y)

func get_grid_cell_center(pos: Vector2i) -> Vector2:
		var grid_pos = grid.get_global_position()
		var cell_size = grid.get_size() / Vector2(GRID_SIZE, GRID_SIZE)
		return grid_pos + (Vector2(pos) * cell_size) + (cell_size / 2)

func is_point_inside_grid(pos: Vector2) -> bool:
		var grid_rect = Rect2(grid.get_global_position(), grid.get_size())
		return grid_rect.has_point(pos)

func is_straight_line(start: Vector2i, end: Vector2i) -> bool:
		var direction = end - start
		return abs(direction.x) == abs(direction.y) or direction.x == 0 or direction.y == 0
