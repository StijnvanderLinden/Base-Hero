extends Node

signal status_changed(message: String)
signal session_changed(in_session: bool)
signal peer_registered(peer_id: int)

@export var player_scene: PackedScene
@export var default_port: int = 7000
@export var max_clients: int = 4

var players_root: Node3D
var registered_peers: Array[int] = []
var peer_spawn_positions: Dictionary = {}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func set_players_root(root: Node3D) -> void:
	players_root = root


func host_game(port: int) -> Error:
	leave_game(false)

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, max_clients)
	if error != OK:
		status_changed.emit("Failed to host on port %d." % port)
		return error

	multiplayer.multiplayer_peer = peer
	var host_peer_id := multiplayer.get_unique_id()
	var host_spawn_position := _spawn_position_for_slot(0)
	registered_peers = [host_peer_id]
	peer_spawn_positions[host_peer_id] = host_spawn_position
	_spawn_player(host_peer_id, host_spawn_position)
	peer_registered.emit(host_peer_id)
	status_changed.emit("Hosting on port %d." % port)
	session_changed.emit(true)
	return OK


func join_game(address: String, port: int) -> Error:
	leave_game(false)

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	if error != OK:
		status_changed.emit("Failed to start client for %s:%d." % [address, port])
		return error

	multiplayer.multiplayer_peer = peer
	status_changed.emit("Connecting to %s:%d..." % [address, port])
	session_changed.emit(true)
	return OK


func leave_game(announce: bool = true) -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

	registered_peers.clear()
	peer_spawn_positions.clear()
	_clear_players()
	session_changed.emit(false)
	if announce:
		status_changed.emit("Offline. Host or join to begin.")


func _spawn_player(peer_id: int, spawn_position: Vector3) -> void:
	if players_root == null or player_scene == null:
		return
	if players_root.has_node(_player_name(peer_id)):
		return

	var player = player_scene.instantiate()
	player.name = _player_name(peer_id)
	if player.has_method("setup"):
		player.setup(peer_id, spawn_position)
	players_root.add_child(player)


@rpc("authority", "call_remote", "reliable")
func _spawn_player_remote(peer_id: int, spawn_position: Vector3) -> void:
	_spawn_player(peer_id, spawn_position)


func _remove_player(peer_id: int) -> void:
	if players_root == null:
		return

	var node_name := _player_name(peer_id)
	if not players_root.has_node(node_name):
		return

	players_root.get_node(node_name).queue_free()


@rpc("authority", "call_remote", "reliable")
func _remove_player_remote(peer_id: int) -> void:
	_remove_player(peer_id)


func _clear_players() -> void:
	if players_root == null:
		return

	for child in players_root.get_children():
		child.queue_free()


func _player_name(peer_id: int) -> String:
	return "Player_%d" % peer_id


func _spawn_position_for_slot(slot_index: int) -> Vector3:
	var safe_slot_index = max(slot_index, 0)
	var row := int(safe_slot_index / 2)
	var column = safe_slot_index % 2
	return Vector3((float(column) * 4.0) - 2.0, 0.6, -float(row) * 4.0)


func _on_peer_connected(peer_id: int) -> void:
	status_changed.emit("Peer %d connected." % peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	registered_peers.erase(peer_id)
	peer_spawn_positions.erase(peer_id)
	_remove_player(peer_id)
	if multiplayer.is_server():
		_remove_player_remote.rpc(peer_id)
	status_changed.emit("Peer %d disconnected." % peer_id)


func _on_connected_to_server() -> void:
	_register_with_server.rpc_id(1)
	status_changed.emit("Connected as peer %d." % multiplayer.get_unique_id())


func _on_connection_failed() -> void:
	leave_game(false)
	status_changed.emit("Connection failed.")


func _on_server_disconnected() -> void:
	leave_game(false)
	status_changed.emit("Disconnected from server.")


@rpc("any_peer", "call_remote", "reliable")
func _register_with_server() -> void:
	if not multiplayer.is_server():
		return

	var peer_id := multiplayer.get_remote_sender_id()
	if peer_id <= 0:
		return
	if registered_peers.has(peer_id):
		return

	for existing_peer_id in registered_peers:
		var existing_spawn_position: Vector3 = peer_spawn_positions.get(existing_peer_id, Vector3.ZERO)
		_spawn_player(existing_peer_id, existing_spawn_position)
		_spawn_player_remote.rpc_id(peer_id, existing_peer_id, existing_spawn_position)

	var spawn_position := _spawn_position_for_slot(registered_peers.size())
	registered_peers.append(peer_id)
	peer_spawn_positions[peer_id] = spawn_position
	_spawn_player(peer_id, spawn_position)
	_spawn_player_remote.rpc(peer_id, spawn_position)
	peer_registered.emit(peer_id)
