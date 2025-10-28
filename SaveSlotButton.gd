extends "res://SaveSlotButton.gd"

func checkSave():
	.checkSave()
	var data = getSave(saveSlotFile)
	pass


func getSave(file):
	var f = File.new()
	if f.file_exists(file):
		f.open_encrypted_with_pass(file, File.READ, "FTWOMG")
		var sg = f.get_line()
		var savedState = parse_json(sg)
		f.close()
		return savedState
