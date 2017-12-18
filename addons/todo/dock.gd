# Copyright (c) Jahn Johansen
# Modifications Copyright (c) Ivan Skodje in accordance with:
# MIT license
tool
extends EditorPlugin

# Dock Title
var dock_title = "TODO List"

# Dock
var dock = null

# TODO Icon Texture
var texture_todo = null

# FIXME Icon Texture
var texture_fixme = null

# A regular expression matcher
var regex = RegEx.new()

# Refresh Time in seconds 
var refresh_time = 5 # (subject to change, need more testing)

# Current time between refresh time
var time = 0

# Content Tree
var content_tree = null


# Called when the node enters the SceneTree
func _enter_tree():
	# Compiles and assign the regular expression pattern to use
	regex.compile("(TODO|FIXME)\\:[:space:]*([^\\n]*)[:space:]*")
	
	# Create instance of our Dock
	dock = preload("scenes/todo_list.tscn").instance()
	
	# Set Dock title
	dock.set_name(dock_title)
	
	# Get the content_tree
	content_tree = dock.get_node("background/scroll_bar/contents")
	
	# Create TODO Icon Texture
	texture_todo = ImageTexture.new()
	texture_todo.load("res://addons/todo/images/todo.png")
	
	# Create FIXME Icon Texture
	texture_fixme = ImageTexture.new()
	texture_fixme.load("res://addons/todo/images/fixme.png")
	
	# Add the control to the lower right dock slot
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)
	
	# Setup Signals
	dock.get_node("tool_bar/refresh").connect("pressed", self, "populate_tree")
	dock.get_node("tool_bar/todo").connect("pressed", self, "populate_tree", ["TODO"])
	dock.get_node("tool_bar/fixme").connect("pressed", self, "populate_tree", ["FIXME"])
	dock.get_node("tool_bar/auto_refresh_toggle").connect("toggled", self, "set_auto_refresh")
	
	# Setup signal with item_activated (triggers when double clicking an item)
	content_tree.connect("item_activated", self, "item_activated")
	
	# Populate Tree
	populate_tree()


# Sets auto refresh (via on/off switch)
func set_auto_refresh(boolean):
	set_process(boolean)


# Runs when auto refresh is enabled
func _process(delta):
	# Increment time with delta
	time += delta
	
	# If we have exceeded our refresh_time, re-populate the content_tree
	if(time >= refresh_time):
		populate_tree()
		time = 0


# Called when the node leaves the SceneTree
func _exit_tree():
	# Tool needs this in order to properly get node
	content_tree = dock.get_node("background/scroll_bar/contents")
	
	# Disconnect signals
	dock.get_node("tool_bar/refresh").disconnect("pressed", self, "populate_tree")
	dock.get_node("tool_bar/todo").disconnect("pressed", self, "populate_tree")
	dock.get_node("tool_bar/fixme").disconnect("pressed", self, "populate_tree")
	dock.get_node("tool_bar/auto_refresh_toggle").disconnect("toggled", self, "set_auto_refresh")
	
	# Remove the control to the lower right dock slot
	remove_control_from_docks(dock)


# Opens the script of selected item
func item_activated():
	# Get meta data
	var file = content_tree.get_selected().get_metadata(0)
	
	# Edit the given resource (script)
	edit_resource(load(file))


# Populates the content tree with TODO's and FIXME's
func populate_tree(type_filter = null):
	# Tool needs this in order to properly get node - Will
	# output SCRIPT ERROR otherwise.
	if(dock != null):
		content_tree = dock.get_node("background/scroll_bar/contents")
	else:
		return
	
	# Clear any existing content (to allow us to repopulate without having to do extra work)
	content_tree.clear()
	
	# Create the first (root) item
	var root = content_tree.create_item()
	
	# Enable the "Expand" flag of Control.
	content_tree.set_column_expand(0, true)
	
	# Hide the root (only display children)
	content_tree.set_hide_root(true)
	
	# Get all todos and fixme's
	var files = find_all_todos()
	
	# Filter to only get results containing TODO and FIXME
	if(type_filter == "TODO"):
		files = filter_results(files, "TODO")
	elif(type_filter == "FIXME"):
		files = filter_results(files, "FIXME")
	
	# For each file
	for file in files:
		var where = file["file"]
		var todos = file["todos"]
		
		# If we have todo items in the todos array
		if(!todos.empty()):
			# Create item that will act as our folder for TODO's/FIXME's 
			# that may appear inside it
			var file_node = content_tree.create_item(root)
			
			# Metadata is used in order to double click 
			# the item and open the file in the editor
			file_node.set_metadata(0, file["file"])
			
			# The text/name that is displayed in the content tree
			file_node.set_text(0, where)
			
			# For each TODO/FIXME
			for todo in todos:
				# Create an todo item, as a child of the file we 
				# currently are in
				var todo_node = content_tree.create_item(file_node)
				
				# Metadata is used in order to double click 
				# the item and open the file in the editor
				todo_node.set_metadata(0, file["file"])
				
				# The text/name that is displayed in the content tree
				todo_node.set_text(0, "%03d: %s" % [todo["line"], todo["text"]])
				
				# Tooltip message when hovering over the item
				todo_node.set_tooltip(0, todo["text"])
				
				# Setup Icons depending on type
				if(todo["type"] == "TODO"):
					todo_node.set_icon(0, texture_todo)
				elif(todo["type"] == "FIXME"):
					todo_node.set_icon(0, texture_fixme)


# Filter results that matches type
func filter_results(unfiltered_results, type):
	# Empty array to insert our results
	var results = []
	
	# For each file in the unfiltered results
	for file in unfiltered_results:
		# Prepare dictionary
		var filtered = {}
		
		# Set filtered file to be equal to existing file (path)
		filtered["file"] = file["file"]
		
		# Create an empty array for the todos key
		filtered["todos"] = []
		
		# For each unfiltered TODOs
		for todo in file["todos"]:
			# If we match the type (TODO, FIXME, etc.)
			if todo["type"] == type:
				# Append into filtered todos
				filtered["todos"].append(todo)
		
		# Append filtered to results
		results.append(filtered)
	
	# Return an array with filtered todos/fixme results
	return results


# Locate all files within directory, containing specific extensions and optionally look recursively
func find_files(directory, extensions, recur = false):
	# Create empty array that will store our results
	var results = []
	
	# Create directory variable
	var dir = Directory.new()
	
	# Attempt to open directory
	if(dir.open(directory) != OK):
		return results # Failed to open directory, return empty array
	
	# Initialise the stream used to list all files and directories
	dir.list_dir_begin()
	
	# Get our first file (which may also be a sub-directory)
	var file = dir.get_next()
	
	# While we have files
	while(file != ""):
		# Location
		var location = ""
		
		# Set full path to file. If the directory is "res://", do not add an additional '/'
		if(dir.get_current_dir() != "res://"):
			location = dir.get_current_dir() + "/" + file
		else:
			location = dir.get_current_dir() + "" + file
		
		# If file is equal to '.' or '..', get next file and start over
		if (file in [".", ".."]):
			file = dir.get_next()
			continue
		
		# If we have recursive enabled and dir is a directory
		if (recur && dir.current_is_dir()):
			# Run recursively and look through subfiles, then append subfile(s) to results
			for subfile in find_files(location, extensions, true):
				results.append(subfile)
		
		# If we are dealing with a file, and the extension matches our specific extensions
		if(!dir.current_is_dir() && file.extension().to_lower() in extensions):
			# Append file to results
			results.append(location)
		
		# Move on to next dir file
		file = dir.get_next()
	
	# Close the current stream
	dir.list_dir_end()
	
	# Return the results containing full paths to relevant files
	return results


# Find all scripts inside the node recursively
func get_all_scripts(node):
	# Empty array for scripts
	var scripts = []
	
	# Get script from node
	var script = node.get_script()
	
	# If script is not null, append script
	if(script != null):
		scripts.append(script)
	
	# Recursively look through each children for scripts
	for child in node.get_children():
		for script in get_all_scripts(child):
			scripts.append(script)
	
	# Return all scripts
	return scripts


# Look for all TODO/FIXMEs
func find_all_todos():
	# Get an array of all files matching expressions, 
	# looking recursively within the res:// folder
	var files = find_files("res://", ["gd", "tscn", "xscn", "scn"], true)
	
	# Empty array of checked files
	var checked = []
	
	# Empty array of todo files
	var todos = []
	
	# Look through each file in files
	for file in files:
		# If the file is a GDScript (.gd)
		if (file.extension().to_lower() == "gd"):
			# If we have previously checked this file, skip it
			if(file in checked):
				continue
			
			# Create a dictionary with file path and todo's
			var file_todos = {"file": file, "todos": []}
			
			# For each todo in the file
			for todo in todos_in_file(file):
				# Append todo to todos array
				file_todos["todos"].append(todo)
			
			# Append file todos to todos
			todos.append(file_todos)
			
			# Append file to checked
			checked.append(file)
#		# If the file is a scene (.tscn, .xscn, .scn), look for built-in scripts
		elif (file.extension().to_lower() in ["tscn", "xscn", "scn"]):
			# Load instance of the scene
			var scene = load(file).instance()
			
			# Load all scripts from that scene
			var scripts = get_all_scripts(scene)
			
			# For each script, get todos
			for script in scripts:
				# If we have previously checked this file, skip it
				if (script.get_path() in checked):
					continue
				
				# Create dictionary
				var file_todos = {"file": script.get_path(), "todos": []}
				
				# For each todo in file
				for todo in todos_in_string(script.get_source_code()):
					# Appen todo to dictionary's todos array
					file_todos["todos"].append(todo)
				
				# Append the file todos into todos
				todos.append(file_todos)
				
				# Put file path into checked
				checked.append(script.get_path())
	
	# Return todos
	return todos


# Search for TODOs in a file location and return them as an array
func todos_in_file(location):
	# Empty array of todos
	var todos = []
	
	# Create file
	var file = File.new()
	
	# Attempt to open file stream
	file.open(location, File.READ)
	
	# Get each todo in an string array
	todos = todos_in_string(file.get_as_text())
	
	# Close file stream
	file.close()
	
	# Return todo array
	return todos


# Search for TODOs in text and return them as an array
func todos_in_string(string):
	# Get each line into an array from string
	string = string.split("\n")
	
	# Empty array of todos
	var todos = []
	
	# Keep track of lines in order to iterate
	var line_count = 0
	
	# While our string array is not empty
	while (string.size()):
		# Get line
		var line = string[0]
		
		# Remove line from string array
		string.remove(0)
		
		# Increment line count
		line_count += 1
		
		# Try to find pattern, return position if found
		var pos = regex.find(line, 0)
		
		# If pos has been found
		if(pos != -1):
			# Append dictionary to todos array
			todos.append({
			"line": line_count, # Line Number we found the match
			"type": regex.get_capture(1), # Type match (TODO, FIXME, etc.)
			"text": regex.get_capture(2) # Message
			})
	
	# Return the todos array, containing each dictionary with data needed in order
	# to view line number, type of comment, and the message
	return todos