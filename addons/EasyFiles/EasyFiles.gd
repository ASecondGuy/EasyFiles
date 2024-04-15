extends Node
# This script simplyfies all kinds of file operations.
# This costs you some control over the files you might not use anyway.



signal file_modified(path)

var _test_file
var _file_monitor_timer : Timer = Timer.new(): set = _not_setter
var _files_to_monitor : Array = []: set = _not_setter
var _files_last_modified : Array = []: set = _not_setter


func _not_setter(__):
	pass


func _ready():
	# set up check file timer
	add_child(_file_monitor_timer)
	_file_monitor_timer.start(1)
	_file_monitor_timer.connect("timeout", Callable(self, "force_file_modification_check"))



## file modification checks
###############################
func add_file_monitor(path:String)->int:
	if _files_to_monitor.has(path): return ERR_ALREADY_EXISTS
	# I don' know if relative paths will work but might as well allow them
	if !(path.is_absolute_path() or path.is_relative_path()): ERR_FILE_BAD_PATH
	_files_to_monitor.push_back(path)
	_files_last_modified.push_back(FileAccess.get_modified_time(path))
	return OK


func remove_file_monitor(path:String)->int:
	if !_files_to_monitor.has(path): return ERR_DOES_NOT_EXIST
	_files_last_modified.erase(_files_to_monitor.find(path))
	_files_to_monitor.erase(path)
	return OK


func force_file_modification_check()->void:
	for idx in range(_files_to_monitor.size()):
		var mod_time := FileAccess.get_modified_time(_files_to_monitor[idx])
		if mod_time == _files_last_modified[idx]: continue
		emit_signal("file_modified", _files_to_monitor[idx])
		_files_last_modified[idx] = mod_time


func get_monitored_files()->Array:
	return _files_to_monitor


func set_file_monitor_intervall(time:float=1)->void:
	_file_monitor_timer.start(time)


func get_file_monitor_intervall()->float:
	return _file_monitor_timer.wait_time


func pause_file_monitoring()->void:
	_file_monitor_timer.paused = true


func resume_file_monitoring()->void:
	_file_monitor_timer.paused = false
###########################################


## general Folder operations
############################
func copy_file(from:String, to:String)->int:
	return DirAccess.copy_absolute(from, to)

func delete_file(path:String)->int:
	return DirAccess.remove_absolute(path)

func create_folder(path:String)->int:
	return DirAccess.make_dir_recursive_absolute(path)

func rename(from: String, to: String)->int:
	return DirAccess.rename_absolute(from, to)

func path_exists(path:String)->bool:
	if path.match("*.*"):
		return FileAccess.file_exists(path)
	return DirAccess.dir_exists_absolute(path)
###########################################


## json
#######
func read_json(path:String, key:="", compression=-1):
	var test_json_conv = JSON.new()
	test_json_conv.parse(read_text(path, key, compression))
	return test_json_conv.get_data()

func write_json(path:String, data, key:="", compression=-1)->int:
	return write_text(path, JSON.new().stringify(data), key, compression)
###########################################


## text
#######
func read_text(path:String, key:="", compression=-1)->String:
	var data := ""
	var err : int
	err = _open_read(path, key, compression)
	
	if err==OK:
		data = _test_file.get_as_text()
	else:
		prints("Couldn't read", path, "ErrorCode:", err)
	
	if is_instance_valid(_test_file):
		_test_file.close()
	return data


func write_text(path:String, text:String, key:="", compression=-1)->int:
	var err : int
	err = _open_write(path, key, compression)
	
	if err==OK:
		_test_file.store_string(text)
	else:
		prints("Couldn't write", path, "ErrorCode:", err)
	
	_test_file.close()
	return err
###########################################


## Any Variable
###############
func read_variant(path:String, key:="", compression=-1, allow_objects:= false):
	var data
	var err : int
	err = _open_read(path, key, compression)
	
	if err==OK:
		data = _test_file.get_var(allow_objects)
	else:
		prints("Couldn't read", path, "ErrorCode:", err)
	
	_test_file.close()
	return data


func write_variant(path:String, value, key:="", compression=-1, allow_objects:= false)->int:
	var err : int
	err = _open_write(path, key, compression)
	
	if err==OK:
		_test_file.store_var(value, allow_objects)
	else:
		prints("Couldn't write", path, "ErrorCode:", err)
	
	_test_file.close()
	return err
###########################################


## Binary
#########
func read_bytes(path:String, key:="", compression=-1)->PackedByteArray:
	var data := PackedByteArray([])
	var err : int
	err = _open_read(path, key, compression)
	
	if err==OK:
		data = _test_file.get_buffer(_test_file.get_length())
	else:
		prints("Couldn't read", path, "ErrorCode:", err)
	
	_test_file.close()
	return data


func write_bytes(path:String, value:PackedByteArray, key:="", compression:=-1)->int:
	var err : int
	
	err = _open_write(path, key, compression)
	
	if err==OK:
		_test_file.store_buffer(value)
	else:
		prints("Couldn't write", path, "ErrorCode:", err)
	
	_test_file.close()
	return err
###########################################


## CSV
######
func read_csv(path:String, key:="", custom_delimiter=",", compression=-1)->Array:
	var data := []
	var err : int
	err = _open_read(path, key, compression)
	
	if err==OK:
		while _test_file.get_length() > _test_file.get_position():
			data.push_back(_test_file.get_csv_line(custom_delimiter))
	else:
		prints("Couldn't read", path, "ErrorCode:", err)
	
	_test_file.close()
	return data


func write_csv(path:String, value:Array, custom_delimiter=",", key:="", compression=-1)->int:
	var err : int
	
	# validate value
	if !value is Array: return ERR_INVALID_DATA
	for i in range(value.size()):
		if value[i] is PackedStringArray: continue
		if value[i] is Array:
			value[i] = PackedStringArray(value[i])
			continue
		value[i] = PackedStringArray()
	
	err = _open_write(path, key, compression)
	
	if err==OK:
		for line in value:
			_test_file.store_csv_line(line, custom_delimiter)
			_test_file.flush()
	else:
		prints("Couldn't write", path, "ErrorCode:", err)
	
	_test_file.close()
	return err
###########################################


## RSV
######
func read_rsv(path:String, key:="", compression=-1)->Array:
	var bytes := read_bytes(path, key, compression)
	var out := []
	
	var i := 0
	var current_value := PackedByteArray()
	var current_row := []
	
	while i < bytes.size():
		var b := bytes[i]
		if b == 0xFF:# End of value
			if current_value.size() == 1 and current_value[0] == 0xFE:# Null value
				current_row.push_back(null)
			else:
				current_row.push_back(current_value.get_string_from_utf8())
			current_value.resize(0)
		elif b == 0xFD:# End of Row
			out.append(PackedStringArray(current_row))
			current_row.clear()
			current_value.resize(0)
		else:
			# append newest byte to the value
			current_value.append(b)
		i+=1
	
	return out


func write_rsv(path:String, value:Array, key:="", compression=-1)->int:
	# validate value
	if !value is Array: return ERR_INVALID_DATA
	for i in range(value.size()):
		if value[i] is PackedStringArray: continue
		if value[i] is Array:
			value[i] = PackedStringArray(value[i])
			continue
		value[i] = PackedStringArray()
	
	var err := _open_write(path, key, compression)
	
	if err == OK:
		for row in value:
			for element in row:
				if element == null:
					# store null value
					_test_file.store_8(0xFE)
				elif element is String:
					_test_file.store_buffer(element.to_utf8_buffer())
				# End of value
				_test_file.store_8(0xFF)
			_test_file.store_8(0xFD)
	
	_test_file.close()
	return err
###########################################

## file search
##############
func get_files_in_directory(path:String, recursive=false, filter:="*"):
	var found = []
	var dirs = []
	if !path.ends_with("/"): path += "/"
	
	var dir := DirAccess.open(path)
	if DirAccess.get_open_error() == OK:
		dir.include_hidden = false
		dir.include_navigational = false
		if dir.list_dir_begin()  != OK:
			return []
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


## Helper Functions

func _open_read(path:String, key="", compression=-1)->int:
	if is_instance_valid(_test_file):
		if _test_file.is_open(): return ERR_BUSY
	if key != "":
		_test_file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, key)
		return FileAccess.get_open_error()
	elif compression != -1:
		if compression < 0 or compression > 3: return ERR_INVALID_PARAMETER
		_test_file = FileAccess.open_compressed(path, FileAccess.READ, compression)
		return FileAccess.get_open_error()
	else:
		_test_file = FileAccess.open(path, FileAccess.READ)
		return FileAccess.get_open_error()


func _open_write(path:String, key="", compression=-1)->int:
	if is_instance_valid(_test_file):
		if _test_file.is_open(): return ERR_BUSY
	if key != "":
		_test_file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, key)
		return FileAccess.get_open_error()
	elif compression != -1:
		if compression < 0 or compression > 3: return ERR_INVALID_PARAMETER
		_test_file = FileAccess.open_compressed(path, FileAccess.WRITE, compression)
		return FileAccess.get_open_error()
	else:
		_test_file = FileAccess.open(path, FileAccess.WRITE)
		return FileAccess.get_open_error()
###########################################


