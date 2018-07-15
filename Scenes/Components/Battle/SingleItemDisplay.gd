extends Control

# TODO: damaged ships below 25? 30? percent are tinted red
# TODO: might prefer to make the texturebutton an overlay over all other nodes
# signal emitted when any textureButton is clicked, payload is assigned by the instantiating parent
signal clicked

func _ready():
	pass

func set_ship(ship):
	var texture_frame = get_node("Ship/Container/Ship")
	var ship_name = get_node("Ship/Container/ShipName")
	
	texture_frame.set_texture(TextureHandler.get_ship(ship.owner, ship.size))
	ship_name.set_text(ship.ship_name)
	get_node("Ship").show()
	
func connect_button(type):
	var button = get_node("%s/TextureButton" % type)
	button.connect("pressed", self, "_on_pressed")

func set_planet(planet):
	var texture_frame = get_node("Planet/Container/Planet")
	var planet_name = get_node("Planet/Container/PlanetName")
	var small_planet = true
	texture_frame.set_texture(TextureHandler.get_planet(planet, small_planet))
	planet_name.set_text(planet.planet_name)
	get_node("Planet").show()
	
func _on_pressed():
	emit_signal("clicked")