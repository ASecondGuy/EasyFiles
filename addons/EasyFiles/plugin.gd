tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("EasyFiles", "res://addons/EasyFiles/EasyFiles.gd")


func _exit_tree():
	remove_autoload_singleton("EasyFiles")
