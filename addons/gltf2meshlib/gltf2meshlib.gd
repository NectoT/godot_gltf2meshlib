@tool
extends EditorPlugin

var importer: EditorImportPlugin
var mesh_importer: EditorImportPlugin


# Init importer
func _enter_tree():
	importer = preload("importer.gd").new()
	add_import_plugin(importer)
	
	mesh_importer = preload('mesh_importer.gd').new()
	add_import_plugin(mesh_importer)


# deactivate importer
func _exit_tree():
	remove_import_plugin(importer)
	importer = null
	remove_import_plugin(mesh_importer)
	mesh_importer = null
