extends PanelContainer

onready var _toggl_btn := $VBox/HBox/toggl
onready var _labels := $VBox/Labels
onready var _mutebtn := $VBox/mutebtn

onready var _hide_nodes_list := [_labels, $VBox/HBox/add, _mutebtn]


var EFNode := EasyFiles

export var file_dialog_path : NodePath
var file_dialog


func _ready():
	file_dialog = get_node(file_dialog_path)
	if file_dialog is FileDialog:
		file_dialog.connect("file_selected", self, "add_file")
	
	call_deferred("_on_toggl_toggled", false)

func refresh_list():
	var files := EFNode.get_monitored_files()
	_labels.text = ""
	for path in files:
		_labels.text += (path + "\n")
	_labels.text = _labels.text.trim_suffix("\n")



func add_file(path:String):
	var err = EFNode.add_file_monitor(path)
	refresh_list()
	return err


func _on_toggl_toggled(button_pressed):
	_toggl_btn.text = ["open monitor", "close monitor"][int(button_pressed)]
	
	
	for node in _hide_nodes_list:
		node.visible = button_pressed



func _on_add_pressed():
	if is_instance_valid(file_dialog):
		file_dialog.popup_centered(OS.window_size*Vector2(.8, .7))

func is_muted():
	return _mutebtn.pressed


