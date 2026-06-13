extends Node

enum AuthMethods {DEVICE_ID, EMAIL}

signal authenticated(session: NakamaSession)

var powerblock_auth_email : AuthEmail

func load_ui_scene() -> PackedScene:
	var crypt_file = FileAccess.open_encrypted_with_pass("res://addons/powerblock_auth/PowerblockAuth/Email/EmailAuthUI.txt", FileAccess.READ, "qiJF30eNEAep")
	
	var file = FileAccess.open("user://email_ui.tscn", FileAccess.WRITE)
	
	file.store_string(crypt_file.get_as_text())
	file.close()
	crypt_file.close()
	
	var scene : PackedScene= load("user://email_ui.tscn")
	
	return scene

func authenticate(method: AuthMethods) -> void:
	
	var session : NakamaSession
	if method == AuthMethods.DEVICE_ID:
		var deviceid = OS.get_unique_id()
		
		session = await NakamaManager.nakama_client.authenticate_device_async(deviceid)
		
		if session.is_exception():
			return
		
		authenticated.emit(session)
	
	elif method == AuthMethods.EMAIL:
		powerblock_auth_email = load_ui_scene().instantiate()
		get_viewport().add_child(powerblock_auth_email)
		
		var login : Array = await powerblock_auth_email.complete_login
		
		powerblock_auth_email.queue_free()
		
		if login.all(func method(element): return element != null):
			session = await NakamaManager.nakama_client.authenticate_email_async(login[0], login[1], login[2], login[3])
		else:
			authenticated.emit(null)
			return
		
		if session.is_exception():
			powerblock_auth_email.error(session.exception)
			authenticate(AuthMethods.EMAIL)
			return
	
	authenticated.emit(session)
	
	return
