extends Node

var _dir := Directory.new()


## general Folder operations
func copy_file(from:String, to:String)->int:
	return _dir.copy(from, to)

func delete_file(path:String)->int:
	return _dir.remove(path)

func create_folder(path:String)->int:
	return _dir.make_dir_recursive(path)

func rename(from: String, to: String)->int:
	return _dir.rename(from, to)

func path_exists(path:String):
	if path.match("*.*"):
		return _dir.file_exists(path)
	return _dir.dir_exists(path)
##########################################

## json
func read_json(path:String, key:=""):
	return parse_json(read_text(path, key))

func write_json(path:String, data, key:=""):
	return write_text(path, to_json(data), key)
###########################################

## text 
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

func write_text(path:String, text:String, key:=""):
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
###########################################

## binary
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

func write_variant(path:String, value, key:=""):
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
#########################################

func read_csv(path:String, key:="")->Array:
	var f := File.new()
	var data := []
	var err : int
	if key == "":
		err = f.open(path, f.READ)
	else:
		err = f.open_encrypted_with_pass(path, f.READ, key)
	
	if err==OK:
		while f.get_len() > f.get_position():
			data.push_back(f.get_csv_line())
	else:
		prints("Couldn't read", path, "ErrorCode:", err)
	
	return data



## file search
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
###############################################



