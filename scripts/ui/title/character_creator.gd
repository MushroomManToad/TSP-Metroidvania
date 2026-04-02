class_name CharacterCreator

extends CanvasLayer

@onready var name_input: LineEdit = $NameInputContainer/LineEdit
@onready var randomize_button: TextureButton = $ControlButtons/VBoxContainer/HBoxContainer/RandomizeButton
@onready var create_button: TextureButton = $ControlButtons/VBoxContainer/HBoxContainer/CreateButton
@onready var import_button: TextureButton = $ControlButtons/VBoxContainer/HBoxContainer/ImportButton
@onready var export_button: TextureButton = $ControlButtons/VBoxContainer/HBoxContainer/ExportButton

@onready var body_tab: PonyCCBodyTabManager = $MainUIBox/HBoxContainer/MainUIBG/BodyTab
@onready var head_tab: PonyCCHeadTabManager = $MainUIBox/HBoxContainer/MainUIBG/HeadTab
@onready var mane_tab: PonyCCManeTabManager = $MainUIBox/HBoxContainer/MainUIBG/ManeTab
@onready var tail_tab: PonyCCTailTabManager = $MainUIBox/HBoxContainer/MainUIBG/TailTab
@onready var butt_mark_tab: PonyCCButtMarkTabManager = $MainUIBox/HBoxContainer/MainUIBG/ButtMarkTab

@onready var main_ui_box: PonyCCMainUIBox = $MainUIBox

@onready var pony_base: PonyBase = $PonyRenderContainer/PonyBase

var file_num = -1

func set_file_num(val : int):
	file_num = val

func _ready() -> void:
	name_input.grab_focus()

func load_pony_from_file(path : String):
	if FileAccess.file_exists(path):
		var json_as_text = FileAccess.get_file_as_string(path)
		var json_as_dict = JSON.parse_string(json_as_text)
		if json_as_dict is Dictionary:
			# From here, we can parse the dict element by element and
			# pass their values to the correct locations.
			
			## Name (for name field)
			if json_as_dict.has(PonyImporterExporter.id_pony_name):
				name_input.text = json_as_dict.get(PonyImporterExporter.id_pony_name)
			
			## Body NumColor
			if json_as_dict.has(PonyImporterExporter.id_num_body_colors):
				main_ui_box._on_body_tab_toggled(true)
				pony_base.set_base_num_colors(json_as_dict.get(PonyImporterExporter.id_num_body_colors))
			
			## Body Color
			if json_as_dict.has(PonyImporterExporter.id_body_colors):
				main_ui_box._on_body_tab_toggled(true)
				var body_colors : Array = str_to_var(json_as_dict.get(PonyImporterExporter.id_body_colors))
				body_tab.base_color.update_color(Color.from_string(body_colors[0], Color.MAGENTA))
				body_tab.shading.update_color(Color.from_string(body_colors[1], Color.MAGENTA))
				body_tab.outline.update_color(Color.from_string(body_colors[2], Color.MAGENTA))
				body_tab.back_outline.update_color(Color.from_string(body_colors[3], Color.MAGENTA))
			
			## Eye NumColor
			if json_as_dict.has(PonyImporterExporter.id_num_eye_colors):
				main_ui_box._on_head_tab_toggled(true)
				pony_base.set_num_eye_colors(json_as_dict.get(PonyImporterExporter.id_num_eye_colors))
			
			## EyeColor
			if json_as_dict.has(PonyImporterExporter.id_eye_colors):
				main_ui_box._on_head_tab_toggled(true)
				var eye_colors : Array = str_to_var(json_as_dict.get(PonyImporterExporter.id_eye_colors))
				head_tab.eye_color.update_color(Color.from_string(eye_colors[0], Color.MAGENTA))
			
			## Mane Shape
			if json_as_dict.has(PonyImporterExporter.id_mane_sprite):
				main_ui_box._on_mane_tab_toggled(true)
				var mane_id = json_as_dict.get(PonyImporterExporter.id_mane_sprite)
				(mane_tab.mane_buttons.get(mane_id) as ManeTailButton)._on_toggled(true)
			
			## Tail Shape
			if json_as_dict.has(PonyImporterExporter.id_tail_sprite):
				main_ui_box._on_tail_tab_toggled(true)
				var tail_id = json_as_dict.get(PonyImporterExporter.id_tail_sprite)
				(tail_tab.tail_buttons.get(tail_id) as TailManeButton)._on_toggled(true)
			
			## Mane Color
			var num_mane_colors = 0
			main_ui_box._on_mane_tab_toggled(true)
			if json_as_dict.has(PonyImporterExporter.id_num_mane_colors):
				num_mane_colors = json_as_dict.get(PonyImporterExporter.id_num_mane_colors)
			if json_as_dict.has(PonyImporterExporter.id_mane_colors):
				var mane_colors : Array = str_to_var(json_as_dict.get(PonyImporterExporter.id_mane_colors))
				for i in range(0, min(num_mane_colors, 8)):
					mane_tab.color_buttons[i].update_color(Color.from_string(mane_colors[i], Color.MAGENTA))
			
			## Tail Colors
			var num_tail_colors = 0
			main_ui_box._on_tail_tab_toggled(true)
			if json_as_dict.has(PonyImporterExporter.id_num_tail_colors):
				num_tail_colors = json_as_dict.get(PonyImporterExporter.id_num_tail_colors)
			if json_as_dict.has(PonyImporterExporter.id_tail_colors):
				var tail_colors : Array = str_to_var(json_as_dict.get(PonyImporterExporter.id_tail_colors))
				for i in range(0, min(num_tail_colors, 8)):
					tail_tab.color_buttons[i].update_color(Color.from_string(tail_colors[i], Color.MAGENTA))
			
			## Butt Mark
			if json_as_dict.has(PonyImporterExporter.id_butt_mark_colors):
				main_ui_box._on_butt_mark_tab_toggled(true)
				var bm_colors : Array = str_to_var(json_as_dict.get(PonyImporterExporter.id_butt_mark_colors))
				for i in range(0, min(len(bm_colors),49)):
					var color : Color = Color.from_string(bm_colors[i], Color.MAGENTA)
					var is_invisible : bool = color.a == 0.
					
					if is_invisible:
						butt_mark_tab.butt_mark_draw_grid[i].set_invisible()
					else:
						butt_mark_tab.butt_mark_draw_grid[i].set_color(color)
				butt_mark_tab.update_butt_mark_image()
			
			## TODO: Return to originally loaded tab
			main_ui_box._on_body_tab_toggled(true)
	else:
		print("Attempted to load non-existent file", path)
