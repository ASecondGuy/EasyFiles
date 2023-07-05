@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("EasyFiles", "res://addons/EasyFiles/EasyFiles.gd")
	add_custom_type("EasyFilesNode", "Node", 
	load("res://addons/EasyFiles/EasyFiles.gd"), load("res://addons/EasyFiles/icon.svg"))


func _exit_tree():
	remove_autoload_singleton("EasyFiles")
	remove_custom_type("EasyFilesNode")
