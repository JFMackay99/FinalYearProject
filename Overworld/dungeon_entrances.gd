extends TileMapLayer

var dungeonEntrances: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func AddDungeonEntrances(newEntrances : Array[Vector3]):
	# Clear old entrances
	for entrance in dungeonEntrances:
		set_cell(Vector2i(entrance.x, entrance.y))
	dungeonEntrances.clear()
	
	for newEntrance in newEntrances:
		set_cell(Vector2i(newEntrance.x, newEntrance.y), 1, Vector2i(0,0))
		dungeonEntrances.append(newEntrance)
