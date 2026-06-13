extends Node

# Nakama settings
const CONNECT = true

const NAKAMA_IP = "api.nakama.powerblock.hackclub.app"
const NAKAMA_PORT = 443
const NAKAMA_HTTP = "HTTPS"
const NAKAMA_ENCRYPT_KEY = "defaultkey"

# Nakama variables
var nakama_client : NakamaClient
var nakama_socket : NakamaSocket
var nakama_session : NakamaSession

func connect_to_nakama() -> Error:
	if not CONNECT: return FAILED
	
	nakama_client = Nakama.create_client(NAKAMA_ENCRYPT_KEY, NAKAMA_IP, NAKAMA_PORT, NAKAMA_HTTP)
	print("Authenticating...")
	PowerblockAuth.authenticate(PowerblockAuth.AuthMethods.EMAIL)
	nakama_session = await PowerblockAuth.authenticated
	if nakama_session == null:
		push_error("Nakama session is null!")
		return FAILED
	return OK
