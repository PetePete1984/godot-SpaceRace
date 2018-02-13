# Surface, Orbital, Tech
var type = null
# dictionary key
var project = null
# if continuous = true, ignore remaining_industry and keep it running (usually only on Tech type)
var continuous = false
# total industry cost (fixed for buildings, variable for ships)
var total_cost = 0
# industry cost left until finished
var remaining_industry = 0
# position on the corresponding grid
var position = Vector2()
# for advanced projects that target existing objects: target grid type
var target_type = null