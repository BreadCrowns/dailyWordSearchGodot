extends Control

# Node references for the grid, word labels, and dynamic line container
@onready var grid = $MarginContainer/VBoxContainer/MarginContainer/AspectRatioContainer/GridContainer
@onready var line_layer = $MarginContainer/VBoxContainer/MarginContainer/AspectRatioContainer/LineLayer
@onready var back_button = $MarginContainer/VBoxContainer/HBoxContainer/back_button
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

# Initialization
func _ready():
       http_request = HTTPRequest.new()
       add_child(http_request)
       http_request.request_completed.connect(_on_puzzle_request_completed)
       puzzle_date = Time.get_date_string_from_system()
       request_puzzle(puzzle_date)
       set_process_input(true)
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
            label.add_theme_font_override("font", load("res://fonts/Roboto-Regular.ttf"))
            #label.add_theme_font_override("font", preload("res://fonts/RobotoFont.tres"))
            label.set_meta("grid_pos", Vector2i(x, y))
            grid.add_child(label)

# Load and display the word list
func load_words():
       for i in range(min(5, words.size())):
               word_list_col1[i].text = words[i].to_upper()
               word_list_col1[i].add_theme_color_override("font_color", Color.WHITE)
               word_list_col1[i].add_theme_font_size_override("font_size", 30)
               word_list_col1[i].add_theme_font_override("font", load("res://fonts/Roboto-BlackItalic.ttf"))
       for i in range(5, min(10, words.size())):
               word_list_col2[i - 5].text = words[i].to_upper()
               word_list_col2[i - 5].add_theme_color_override("font_color", Color.WHITE)
               word_list_col2[i - 5].add_theme_font_size_override("font_size", 30)
               word_list_col2[i - 5].add_theme_font_override("font", load("res://fonts/Roboto-BlackItalic.ttf"))
       if words.size() > 10:
               word_label_center.text = words[10].to_upper()
       else:
               word_label_center.text = ""
       word_label_center.add_theme_color_override("font_color", Color.WHITE)
       word_label_center.add_theme_font_size_override("font_size", 30)
       word_label_center.add_theme_font_override("font", load("res://fonts/Roboto-BlackItalic.ttf"))

# Input handling
func _input(event):
    if event is InputEventScreenTouch or event is InputEventMouseButton:
        if event.pressed:
            if not is_point_inside_grid(event.position):
                dragging = false
                return
            drag_start = get_grid_cell_from_position(event.position)
            dragging = true
            # create temp line
            active_line = Line2D.new()
            active_line.width = 30
            active_line.default_color = Color.from_hsv(randf(), 1.0, 1.0)
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

       var match := words.any(func(w): return w.to_lower() == selected_word.to_lower() or w.to_lower() == selected_word.reverse().to_lower())
       if match:
               var normalized = selected_word.to_lower()
               if normalized not in solved_words:
                       solved_words.append(normalized)
               for label in word_list_col1 + word_list_col2 + [word_label_center]:
                       if words.size() > 10 and label == word_label_center and (words[10].to_lower() == normalized or words[10].to_lower() == normalized.reverse()):
                               label.text = words[10].to_upper()
                               label.add_theme_color_override("font_color", Color.GREEN)
                               break
                       elif label.text.to_lower() == normalized or label.text.to_lower() == normalized.reverse():
                               label.add_theme_color_override("font_color", Color.GREEN)
                               break
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
