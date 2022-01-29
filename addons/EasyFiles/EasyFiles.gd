extends Node
# This script simplyfies all kinds of file operations.
# This costs you some control over the files you might not use anyway.



signal file_modified(path)


var _dir := Directory.new() setget _not_setter # protected var
var _test_file := File.new() setget _not_setter # protected var
var _file_moinitor_timer := Timer.new() setget _not_setter # protected var
var _files_to_monitor := [] setget _not_setter # protected var
var _files_last_modified := [] setget _not_setter # protected var


func _not_setter(__):
	pass


func _ready():
	# set up check file timer
	add_child(_file_moinitor_timer)
	_file_moinitor_timer.start(1)
	_file_moinitor_timer.connect("timeout", self, "_test_file_modifications")



## file modification checks
###############################
func add_file_monitor(path:String)->int:
	if _files_to_monitor.has(path): return ERR_ALREADY_EXISTS
	# I don' know if relative paths will work but might as well allow them
	if !(path.is_abs_path() or path.is_rel_path()): ERR_FILE_BAD_PATH
	_files_to_monitor.push_back(path)
	_files_last_modified.push_back(_test_file.get_modified_time(path))
	return OK


func remove_file_monitor(path:String)->int:
	if !_files_to_monitor.has(path): return ERR_DOES_NOT_EXIST
	_files_last_modified.remove(_files_to_monitor.find(path))
	_files_to_monitor.erase(path)
	return OK


func _test_file_modifications()->void:
	for idx in range(_files_to_monitor.size()):
		var mod_time := _test_file.get_modified_time(_files_to_monitor[idx])
		if mod_time == _files_last_modified[idx]: continue
		emit_signal("file_modified", _files_to_monitor[idx])
		_files_last_modified[idx] = mod_time


func get_monitored_files()->Array:
	return _files_to_monitor


func set_file_monitor_intervall(time:float=1)->void:
	_file_moinitor_timer.start(time)


func get_file_monitor_intervall()->float:
	return _file_moinitor_timer.wait_time


func pause_file_monitoring()->void:
	_file_moinitor_timer.paused = true


func resume_file_monitoring()->void:
	_file_moinitor_timer.paused = false
###########################################


## general Folder operations
############################
func copy_file(from:String, to:String)->int:
	return _dir.copy(from, to)

func delete_file(path:String)->int:
	return _dir.remove(path)

func create_folder(path:String)->int:
	return _dir.make_dir_recursive(path)

func rename(from: String, to: String)->int:
	return _dir.rename(from, to)

func path_exists(path:String)->bool:
	if path.match("*.*"):
		return _dir.file_exists(path)
	return _dir.dir_exists(path)
###########################################


## json
#######
func read_json(path:String, key:=""):
	return parse_json(read_text(path, key))

func write_json(path:String, data, key:="")->int:
	return write_text(path, to_json(data), key)
###########################################


## text
#######
func read_text(path:String, key:="")->String:
	var f := File.new()
	var data := ""
	var err : int
	if key == "":
		err = f.open(path, f.READ)
	else:
		err = f.open_encrypted_with_pass(path, f.READ, key)
	
	if err==OK:
		data = f.get_as_text()
	else:
		prints("Couldn't read", path, "ErrorCode:", err)
	
	f.close()
	return data


func write_text(path:String, text:String, key:="")->int:
	var f = File.new()
	var err : int
	if key == "":
		err = f.open(path, f.WRITE)
	else:
		err = f.open_encrypted_with_pass(path, f.WRITE, key)
	
	if err==OK:
		f.store_string(text)
	else:
		prints("Couldn't write", path, "ErrorCode:", err)
	f.close()
	return err
###########################################


## Any Variable
###############
func read_variant(path:String, key:=""):
	var f := File.new()
	var data := ""
	var err : int
	if key == "":
		err = f.open(path, f.READ)
	else:
		err = f.open_encrypted_with_pass(path, f.READ, key)
	
	if err==OK:
		data = f.get_var(true)
	else:
		prints("Couldn't read", path, "ErrorCode:", err)
	
	return data


func write_variant(path:String, value, key:="")->int:
	var f := File.new()
	var err : int
	if key == "":
		err = f.open(path, f.WRITE)
	else:
		err = f.open_encrypted_with_pass(path, f.WRITE, key)
	
	if err==OK:
		f.store_var(value, true)
	else:
		prints("Couldn't write", path, "ErrorCode:", err)
	
	f.close()
	return err
###########################################


## Binary
#########
func read_bytes(path:String, key:="")->PoolByteArray:
	var f := File.new()
	var data := PoolByteArray([])
	var err : int
	if key == "":
		err = f.open(path, f.READ)
	else:
		err = f.open_encrypted_with_pass(path, f.READ, key)
	
	if err==OK:
		data = f.get_buffer(f.get_len())
	else:
		prints("Couldn't read", path, "ErrorCode:", err)
	
	return data


func write_bytes(path:String, value:PoolByteArray, key:="")->int:
	var f := File.new()
	var err : int
	if key == "":
		err = f.open(path, f.WRITE)
	else:
		err = f.open_encrypted_with_pass(path, f.WRITE, key)
	
	if err==OK:
		f.store_buffer(value)
	else:
		prints("Couldn't write", path, "ErrorCode:", err)
	
	f.close()
	return err
###########################################


## CSV
######
#func read_csv(path:String, key:="")->Array:
#	var f := File.new()
#	var data := []
#	var err : int
#	if key == "":
#		err = f.open(path, f.READ)
#	else:
#		err = f.open_encrypted_with_pass(path, f.READ, key)
#
#	if err==OK:
#		while f.get_len() > f.get_position():
#			data.push_back(f.get_csv_line())
#	else:
#		prints("Couldn't read", path, "ErrorCode:", err)
#
#	return data
###########################################



## file search
##############
func get_files_in_directory(path:String, recursive=false, filter:="*"):
	var found = []
	var dirs = []
	
	var dir := Directory.new()
	if dir.open(path) == OK:
		# warning-ignore:return_value_discarded
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				dirs.push_back(file_name)
			else:
				if file_name.match(filter):
					found.push_back(path+file_name)
			file_name = dir.get_next()
	else:
		return []
	
	if !recursive: return found
	
	#check other dirs if recursive
	for new_dir in dirs:
		for file in get_files_in_directory(path+new_dir+"/", true, filter):
			found.push_back(file)
	
	return found
###########################################



