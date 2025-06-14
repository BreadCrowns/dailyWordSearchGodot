extends Control

@onready var version_label = $VBoxContainer/InfoSection/InfoVBox/VersionLabel
@onready var build_label = $VBoxContainer/InfoSection/InfoVBox/BuildLabel
@onready var platform_label = $VBoxContainer/InfoSection/InfoVBox/PlatformLabel
@onready var device_label = $VBoxContainer/InfoSection/InfoVBox/DeviceLabel

func _ready():
	version_label.text = "App Version: 1.0.0"
	build_label.text = "Build: 100001"
	platform_label.text = "Platform: " + OS.get_name()
	device_label.text = "Device ID: " + OS.get_unique_id()

func _on_HelpButton_pressed():
	OS.shell_open("https://yourdomain.com/help")

func _on_ContactButton_pressed():
	OS.shell_open("mailto:support@yourdomain.com")

func _on_PrivacyButton_pressed():
	OS.shell_open("https://yourdomain.com/privacy")

func _on_TermsButton_pressed():
	OS.shell_open("https://yourdomain.com/terms")

func _on_CreditsButton_pressed():
	get_tree().change_scene_to_file("res://CreditsScreen.tscn")
