extends Reference

const path = "res://Data/history.txt"

static func read_history():
	var races_in_order = []
	var history = []
	var races = {}
	var race = null
	
	var buffer = []
	var buffering = false
	
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		while not file.eof_reached():
			history.append(file.get_line())
		file.close()
		
		for line in history:
			if line.begins_with("//") or line.begins_with("END"):
				if race != null:
					races[race.type] = str2var(var2str(race))
					races_in_order.append(race.type)
				race = {
					"type": line.replace("// ", "").to_lower(),
					"race_name": line.replace("// ", "")
				}
			elif line.begins_with("specnum"):
				race.index = line.replace("specnum ", "").to_int()
			
			elif line in ["power", "intro", "text", "peace", "neutral", "hostile"]: #line.begins_with("power"):
				buffer = []
				buffering = true
			
			elif line.begins_with("endpower"):
				race.power = join(buffer)
				buffering = false
				
			elif line.begins_with("endintro"):
				race.intro = join(buffer).replace("@", " ").replace("_", " ")
				buffering = false
				
			elif line.begins_with("endtext"):
				race.text = join(buffer).replace("@", " ").replace("_", " ")
				buffering = false
				
			elif line.begins_with("endpeace"):
				race.peace = join(buffer)
				if race.peace != null:
					race.peace = race.peace.replace("@", " ").replace("_", " ")
				buffering = false
				
			elif line.begins_with("endneutral"):
				race.neutral = join(buffer)
				if race.neutral != null:
					race.neutral = race.neutral.replace("@", " ").replace("_", " ")
				buffering = false
				
			elif line.begins_with("endhostile"):
				race.hostile = join(buffer)
				if race.hostile != null:
					race.hostile = race.hostile.replace("@", " ").replace("_", " ")
				buffering = false
			else:
				if line != "":
					if buffering:
						buffer.append(line)
	
	else:
		print("File not found: Data/history.txt")
	return {
		"races": races,
		"races_in_order": races_in_order
	}
	pass
	
static func join(array, join = "\n"):
	if array.size() == 0:
		return null
	var result = ""
	for a in array:
		result += a + join
	return result