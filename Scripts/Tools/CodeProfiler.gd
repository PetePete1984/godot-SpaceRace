extends Node

var profiles = {}
var times = {}

func start(key):
	profiles[key] = OS.get_ticks_msec()
	#print("Started profiling '%s'" % key)
	return true
	pass

func stop(key):
	if profiles.has(key):
		var now = OS.get_ticks_msec()
		var elapsed = now - profiles[key]
		times[key] = elapsed
		#print("Process '%s' took %d msec" % [key, elapsed])

	return true
	pass

func report():
	for key in times:
		print("Process '%s' took %d msec" % [key, times[key]])