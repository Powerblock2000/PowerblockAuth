extends Control
@onready var label: Label = $Label
@onready var button: Button = $Button

func _ready() -> void:
	PowerblockAuth.set_branding(load("res://icon.svg"), Color(0.0, 1.0, 0.0, 1.0))
	await NakamaManager.connect_to_nakama(PowerblockAuth.AuthMethods.EMAIL)
	button.show()

func _process(_delta: float) -> void:
	label.text = ("Status: %s" % NakamaManager.status)

func _on_button_pressed() -> void:
	NakamaManager.clear_tokens()
