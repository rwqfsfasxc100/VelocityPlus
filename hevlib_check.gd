extends Node

static func __hevlib_check() -> bool:
	var mod = "res://HevLib/ModMain.gd"
	var dir = Directory.new()
	var does = dir.file_exists(mod)
	if does:
		Debug.l("HevLib is installed")
		return true
	else:
		Debug.l("HevLib is not installed")
		return false
