extends RefCounted

class_name Map

var overworld: OverworldMap
var entrances: Array
var underground : Underground
var dungeon : Dungeon

var overworldToDungeonScale = 3


func _init():
	overworld = OverworldMap.new()
	underground = Underground.new()
	dungeon = Dungeon.new()
	
	entrances = []

func GetOverworld():
	return overworld

func GetEntrances():
	return entrances
	
func GetDungeon():
	return dungeon
