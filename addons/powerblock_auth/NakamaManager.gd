extends Node

# Nakama settings
const CONNECT = true

const NAKAMA_IP = "127.0.0.1"
const NAKAMA_PORT = 443
const NAKAMA_HTTP = "https"
const NAKAMA_ENCRYPT_KEY = "defaultkey"

# Nakama variables
var nakama_client : NakamaClient
var nakama_socket : NakamaSocket
var nakama_session : NakamaSession

var previous_auth_method : PowerblockAuth.AuthMethods

signal _connected(error: Error)

var status : String
var authenticating : bool = true

func clear_tokens():
	if not FileAccess.file_exists("user://nakama_session.cfg"): return ERR_FILE_CANT_OPEN
	
	var config : ConfigFile = ConfigFile.new()
	config.load("user://nakama_session.cfg")
	config.set_value("nakama", "auth_token", "")
	config.set_value("nakama", "refresh_token", "")
	config.save("user://nakama_session.cfg")
	get_tree().quit()

func _process(delta: float) -> void:
	if nakama_session and not authenticating:
		if nakama_session.is_expired():
			nakama_session = await nakama_client.session_refresh_async(nakama_session)
			
			if nakama_session.is_exception():
				PowerblockAuth.authenticate(previous_auth_method)
				nakama_session = await PowerblockAuth.authenticated
				save_auth_keys()

func try_reload_session() -> NakamaSession:
	if not FileAccess.file_exists("user://nakama_session.cfg"): return null
	
	#push_warning("Trying to reload session")
	
	var config : ConfigFile = ConfigFile.new()
	config.load("user://nakama_session.cfg")
	var session_token = config.get_value("nakama", "auth_token")
	if session_token == null:
		print("Session token null")
		return null
	var session : NakamaSession = nakama_client.restore_session(session_token)
	if session.token == "" or session.token == null:
		print("Session failed refreshing: %s" % session.created)
		return null
	return session

func save_auth_keys() -> void:
	var config : ConfigFile = ConfigFile.new()
	config.set_value("nakama", "refresh_token", nakama_session.refresh_token)
	config.set_value("nakama", "auth_token", nakama_session.token)
	config.save("user://nakama_session.cfg")

func connect_to_nakama(method: PowerblockAuth.AuthMethods) -> Error:
	connect_to_nakama_defered.call_deferred(method)
	return await _connected

func connect_to_nakama_defered(method: PowerblockAuth.AuthMethods) -> void:
	status = "Connection started..."
	
	if not CONNECT:
		_connected.emit(FAILED)
		status = "CONNECT is false"
		return
	
	status = "Creating client..."
	nakama_client = Nakama.create_client(NAKAMA_ENCRYPT_KEY, NAKAMA_IP, NAKAMA_PORT, NAKAMA_HTTP)
	print("Authenticating...")
	status = "Authenticating session..."
	
	var try_session : NakamaSession = try_reload_session()
	if try_session == null:
		PowerblockAuth.authenticate(method)
		nakama_session = await PowerblockAuth.authenticated
		if nakama_session == null:
			print("Nakama session is null!")
			_connected.emit(FAILED)
			return
	else:
		nakama_session = try_session
	
	print(nakama_session)
	
	save_auth_keys()
	status = "Saving session tokens..."
	
	nakama_socket = await Nakama.create_socket_from(nakama_client)
	status = "Connecting the socket..."
	var connected : NakamaAsyncResult = await nakama_socket.connect_async(nakama_session)
	if connected.is_exception():
		push_error("Error connection socket: %s" % connected.exception)
		_connected.emit(FAILED)
		return
	
	previous_auth_method = method
	
	status = "Connected to Nakama!"
	_connected.emit(OK)
	authenticating = false
	return
