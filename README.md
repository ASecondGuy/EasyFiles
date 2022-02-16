# EasyFiles
Writing 5 lines of Code to read & write files is too much for you?
With this plugin you only need 1
It also adds a file monitoring signal.
It makes everything about files just a little bit easier.

# How to use
Easy Files is available as a autoload script or a Node. 
## Read & Write
The Script has several functions to read & write text, json, variant (any variable), bytes (PoolByteArray) and csv.
All of them work the same so I'll just explain the text version.
### read
[ERROR](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error) read_text([String](https://docs.godotengine.org/en/stable/classes/class_string.html) path, [String](https://docs.godotengine.org/en/stable/classes/class_string.html) key="", [int](https://docs.godotengine.org/en/stable/classes/class_int.html#class-int) compression=-1)

path is the filepath. Relative & paths should work as well.

key is the password for encryption. To leave encryption off input "".

compression sets the [compression algorythm](https://docs.godotengine.org/en/stable/classes/class_file.html#enum-file-compressionmode). Input -1 to keep compression off. Compression is not compatible with encryption. This will be ignored if a key is given.

Example:
```GDScript
# only reading
print(EasyFiles.read_text("res://text.txt"))
# with encription
print(EasyFiles.read_text("res://text.txt", "the very cool password"))
# with compression using ZSTD compression
print(EasyFiles.read_text("res://text.txt", "", 2))
# with encryption overwriting compression
print(EasyFiles.read_text("res://text.txt", "most secure password ever", 2))
```

### write
String read_text([String](https://docs.godotengine.org/en/stable/classes/class_string.html) path, [String](https://docs.godotengine.org/en/stable/classes/class_string.html) text, [String](https://docs.godotengine.org/en/stable/classes/class_string.html) key="", [int](https://docs.godotengine.org/en/stable/classes/class_int.html#class-int) compression=-1)

path is the filepath. Relative & paths should work as well.

text is the text you want to save. For most other write functions this is called value.

key is the password for encryption. To leave encryption off input "".

compression sets the [compression algorythm](https://docs.godotengine.org/en/stable/classes/class_file.html#enum-file-compressionmode). Input -1 to keep compression off. Compression is not compatible with encryption. This will be ignored if a key is given.

Example:
```GDScript
# only writing
EasyFiles.write_text("res://text.txt", "Important Text")
# with encription
EasyFiles.write_text("res://text.txt", "Important Text", "the very cool password")
# with compression using ZSTD compression
EasyFiles.write_text("res://text.txt", "Important Text", "", 2)
# with encryption overwriting compression
EasyFiles.write_text("res://text.txt", "Important Text", "most secure password ever", 2)
```
## General File Operations

- [ERROR](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error) copy_file([String](https://docs.godotengine.org/en/stable/classes/class_string.html) from, [String](https://docs.godotengine.org/en/stable/classes/class_string.html) to)

- [ERROR](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error) delete_file([String](https://docs.godotengine.org/en/stable/classes/class_string.html) path)

- [ERROR](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error) create_folder([String](https://docs.godotengine.org/en/stable/classes/class_string.html) path)

- [ERROR](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error) rename([String](https://docs.godotengine.org/en/stable/classes/class_string.html) from, [String](https://docs.godotengine.org/en/stable/classes/class_string.html) to)

- [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html#class-bool) path_exists([String](https://docs.godotengine.org/en/stable/classes/class_string.html) path)

  This function works for files and Directories

## File Monitoring

Files get checked every second. Use **set_file_monitor_intervall(float time)** to change that interval. Use **force_file_modification_check()** to manually check whenever you want. Avoid using this too often. Use **pause_file_monitoring()** and **resume_file_monitoring()** to pause or resume the automatic checking. 
Use **get_monitored_files()** to get a list of all monitored files.
Use **add_file_monitor()** and **remove_file_monitor()** too add or remove files to monitor.
Connect to the file_modified signal. It also gives the path to the modified file.
Use multiple EasyFiles nodes to seperatly monitor groups of files.

- void set_file_monitor_intervall([float](https://docs.godotengine.org/en/stable/classes/class_float.html#class-float) time)
  time is the new intervall.
  
- void force_file_modification_check()
  Manually check whenever you want. Avoid using this too often.
- void pause_file_monitoring()
- void resume_file_monitoring()
- [Array](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array) get_monitored_files()
- [ERROR](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error) add_file_monitor([String](https://docs.godotengine.org/en/stable/classes/class_string.html) path)
  
  Will throw ERR_ALREADY_EXISTS if file is already monitored.
- [ERROR](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error) remove_file_monitor([String](https://docs.godotengine.org/en/stable/classes/class_string.html) path)

  Will throw ERR_DOES_NOT_EXIST if file is not being monitored.




And that is all. I hope you find this addon useful. 

If you want consider too

<a href="https://www.buymeacoffee.com/ASecondGuy" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
