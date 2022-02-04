extends MarginContainer

onready var EF := $EasyFilesNode
onready var _file_dialog := $FileDialog
onready var _choose_file_btn := $HBox/ControlPanel/chooseFileBtn
onready var _file_format := $HBox/ControlPanel/FileSpecific/fileFormatSelector/OptionButton
onready var _file_only := $HBox/ControlPanel/FileSpecific
onready var _folder_only := $HBox/ControlPanel/Folderspecific
onready var _out_edit := $HBox/TabContainer/Edit
onready var _out_string := $HBox/TabContainer/String
onready var _out_bin := $HBox/TabContainer/Bytes
onready var _file_filter := $HBox/ControlPanel/Folderspecific/FileFilter/LineEdit
onready var _file_monitor := $HBox/ControlPanel/FileMonitorDisplay
onready var _search_recursive_btn := $HBox/ControlPanel/Folderspecific/CheckBox
onready var _file_add_monitor_btn := $HBox/ControlPanel/FileSpecific/monitorbtn
#onready var 
#onready var 

const AUTO_FILEFORMAT_LOOKUP := {
	"txt" : 1,
	"gd" : 1,
	"tres" : 1,
	"tscn" : 1,
	"json" : 2,
	"var" : 3,
	"variable" : 3,
	"save" : 3,
	"bin" : 4,
	"csv" : 1,#5,
}

var current_path := ""


func _ready():
	_file_monitor.EFNode = EF
	_on_FileDialog_file_selected("res://addons/EasyFiles/test.txt")
	
	var err = EF.connect("file_modified", self, "_file")
	if err != OK: print("EasyFilesExample error: " + str(err))
	
	err = EF.add_file_monitor("res://addons/EasyFiles/test.txt")
	if err != OK: print("EasyFilesExample error: " + str(err))
	
	update_control_panel()

func _file(path):
	prints("modified:", path)
	if !_file_monitor.is_muted():
		OS.alert(str("This file was modified:\n", path), "FILE MODIFIED!")


func _on_chooseFileBtn_pressed():
	_file_dialog.popup_centered(OS.window_size*Vector2(.8, .7))


func _on_FileDialog_file_selected(path:String):
	_folder_only.hide()
	_file_only.show()
	_choose_file_btn.text = "Select File: " + path.get_file()
	current_path = path
	update_control_panel()

func _on_FileDialog_files_selected(paths):
	_on_FileDialog_file_selected(paths[0])

func _on_FileDialog_dir_selected(dir:String):
	_file_only.hide()
	_folder_only.show()
	_choose_file_btn.text = "Select dir: " + dir.get_file()
	current_path = dir
	if !current_path.ends_with("/"): current_path+="/"
	update_control_panel()

func update_control_panel():
	_file_monitor.refresh_list()
	
	
	# if it is a folder
	
	if current_path.get_extension() == "" or current_path.ends_with("/"):
		var recursive : bool = _search_recursive_btn.pressed
		var files : Array = EF.get_files_in_directory(current_path, recursive, _file_filter.text)
		var out = "Found %s files in %s" % [files.size(), current_path.split("/")[-1]]
		if recursive:
			out += " and subdirectories"
		out += ":\n"
		
		for path in files:
			out+= path.trim_prefix(current_path).trim_prefix("/") + "\n"
		
		_out_edit.text = out.trim_suffix("\n")
		_out_string.text = out.trim_suffix("\n")
		return
	
	# if it is a file
	
	_file_add_monitor_btn.text = ["Add to monitor", "Remove from monitor"][int(EF.get_monitored_files().has(current_path))]
	
	var mode : int = _file_format.selected
	if mode == 0:
		mode = AUTO_FILEFORMAT_LOOKUP.get(current_path.get_extension(), 0)
	
	match mode:
		1: # text
			var data = EF.read_text(current_path)
			_out_edit.text = data
			_out_string.text = data
			_out_bin.text = _text_to_bytes(data).hex_encode()
		2: # json
			_out_edit.text = str(EF.read_json(current_path))
		3: # var
			_out_edit.text = var2str(EF.read_variant(current_path))
		4: # bin
			_out_edit.text = EF.read_bytes(current_path).hex_encode()
		5: # csv
			pass
	
	


func _on_savebtn_pressed():
	if current_path.get_extension() == "": return
	var mode : int = _file_format.selected
	if mode == 0:
		mode = AUTO_FILEFORMAT_LOOKUP.get(current_path.get_extension(), 0)
	
	match mode:
		1: # text
			EF.write_text(current_path, _out_edit.text)
		2: # json
			EF.write_json(current_path, _out_edit.text)
		3: # var
			EF.write_variant(current_path, str2var(_out_edit.text))
		4: # bin
			EF.write_bytes(current_path, _text_to_bytes(_out_edit.text))
		5: # csv
			pass
	
	update_control_panel()



func _text_to_bytes(text:String)->PoolByteArray:
	var data := []
	for i in range(0, text.length()-1, 2):
		data.push_back(("0x"+text.substr(i, 1)).hex_to_int())
	return PoolByteArray(data)






func _on_monitorbtn_pressed():
	if EF.add_file_monitor(current_path) == ERR_ALREADY_EXISTS:
		EF.remove_file_monitor(current_path)
	update_control_panel()
