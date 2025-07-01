extends Node3D

@export var player: CharacterBody3D
@export var player_camera: Camera3D

@onready var test_portal: MeshInstance3D = $MeshInstance3D
@onready var exit_portal := $MeshInstance3D2
@onready var portal_viewport: SubViewport = $MeshInstance3D/SubViewport

var portal_camera: Camera3D


func _ready() -> void:
	#portal_viewport = SubViewport.new()
	#portal_viewport.name = self.name + "_SubViewport"
	#portal_viewport.size = _calculate_viewport_size()
	#portal_viewport.set_update_mode(SubViewport.UPDATE_ALWAYS)
	#exit_portal.portal_viewport.set_update_mode(SubViewport.UPDATE_ALWAYS)
	#self.add_child(portal_viewport, true)
	
	# Disable tonemapping on portal cameras
	var adjusted_env: Environment = player_camera.environment.duplicate() \
		if player_camera.environment \
		else player_camera.get_world_3d().environment.duplicate()
	
	adjusted_env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	adjusted_env.tonemap_exposure = 1
	
	portal_camera = Camera3D.new()
	portal_camera.name = self.name + "_Camera3D"
	portal_camera.environment = adjusted_env
	
	# Ensure that portals don't see other portals.
	#portal_camera.cull_mask = portal_camera.cull_mask ^ portal_render_layer
	
	portal_viewport.add_child(portal_camera, true)
	#portal_camera.global_position = exit_portal.global_position
	test_portal.material_override.set_shader_parameter("albedo", portal_viewport.get_texture())


func _process(_delta: float) -> void:
	#portal_camera.global_transform = player_camera.global_transform
	portal_camera.global_transform = to_exit_transform(player_camera.global_transform)
	if Input.is_key_pressed(KEY_E):
		player.global_position = Vector3(0, 0, 0)


func to_exit_transform(g_transform: Transform3D) -> Transform3D:
	var relative_to_portal: Transform3D = global_transform.affine_inverse() * g_transform
	var flipped: Transform3D = relative_to_portal.rotated(Vector3.UP, PI)
	var relative_to_target = exit_portal.global_transform * flipped
	#print(relative_to_target)
	return relative_to_target
