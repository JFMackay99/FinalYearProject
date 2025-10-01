extends BasicUndergroundConstructor

class_name ThreadedUndergroundConstructor

var threads : Array[Thread]

func _init() -> void:
	for i in range(Constants.MAX_HEIGHT_LEVELS):
		threads.append(Thread.new())

func MarkAllLayerHeights(overworld : OverworldMap, layers : Array[LayerBase]):
	
	for i in threads.size():
		var thread = threads[i]
		var layer = layers[i]
		thread.start(MarkLayerHeights.bind(overworld, layer))
	
	for thread in threads:
		thread.wait_to_finish()
	
