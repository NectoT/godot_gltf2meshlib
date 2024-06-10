@tool
extends EditorImportPlugin


func _get_importer_name():
	return "zincles.gltf2mesh"


func _get_visible_name():
	return "GLTF To Mesh"


func _get_recognized_extensions():
	return ["gltf", "glb"]


func _get_save_extension():
	return "mesh"


func _get_resource_type():
	return "Mesh"


func _get_preset_count():
	return 1


func _get_preset_name(preset_index):
	return "Default"


func _get_import_options(path, preset_index):
	return [
		{
			"name": "generate_lods",
			"default_value": true
		}
		# TODO
		#{
			#"name": "apply_root_scale", 
			#"default_value": false
		#},
		#{
			#"name": "root_scale", 
			#"default_value": 1.0, 
			#"property_hint": PROPERTY_HINT_RANGE,
			#"hint_string": "0.001,1000"
		#},
		#{
			#"name": "merge_several_meshes",
			#"default_value": true
		#}
	]


func _get_option_visibility(path, option_name, options):
	return true


func _get_import_order():
	return 9999


#region importer_logics.


func _is_ImporterMeshInstance3D(node: Node) -> bool:
	#print("Node: ", node)
	if is_instance_of(node, ImporterMeshInstance3D):
		return true
	return false


## Returns the first node in the root_node tree matched by matcher function, or
## null if no node matches.
## The matcher should accept one argument (Node),returns a bool.
func find_first_matched_node(root_node: Node, matcher: Callable) -> Node:
	var result: Array[Node] = []

	for node in root_node.get_children():
		var matches: bool = matcher.call(node)
		if matches == true:
			return node
	
	for node in root_node.get_children():
		var matched_node = find_first_matched_node(node, matcher)
		if matched_node != null:
			return matched_node
			
	return null


func _import(gltf_path: String, save_path, options, platform_variants, gen_files):
	# Init.
	#print("Source File: ", gltf_path)
	#print("Save Path: ", save_path)

	var root_node: Node
	var file = FileAccess.open(gltf_path, FileAccess.READ)
	if file == null:
		print("Error: File Not Found!")
		return ERR_PARSE_ERROR

	# load the GLTF file, init as Node.
	var gltf_document_load := GLTFDocument.new()
	var gltf_state_load := GLTFState.new()
	var error := gltf_document_load.append_from_file(gltf_path, gltf_state_load)
	if error == OK:
		root_node = gltf_document_load.generate_scene(gltf_state_load)
	else:
		print("Error: %s " % error_string(error))
		return error

	# Get first MeshInstance3D node.
	var mesh_node := find_first_matched_node(root_node, _is_ImporterMeshInstance3D)
	
	if mesh_node == null:
		return ERR_PARSE_ERROR
	
	var importer_mesh = (mesh_node as ImporterMeshInstance3D).mesh as ImporterMesh
	
	if options['generate_lods']:
		importer_mesh.generate_lods(25, 60, [])
	
	# Save mesh.
	root_node.queue_free()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(importer_mesh.get_mesh(), filename)

#endregion
