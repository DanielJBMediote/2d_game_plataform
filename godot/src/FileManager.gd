extends Node

func write(data):
	var file : File = File.new()
	file.open("user://GameData.json", file.WRITE)
	file.store_line(parse_json(data))
	file.close()

func read():
	var file : File = File.new()
	file.open("user://GameData.json", file.READ)
	var text = file.get_as_text()
	file.close()
	return parse_json(text)

