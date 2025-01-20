extends RefCounted

class_name Map

var overworld: OverworldMap
var entrances: Array
var underground
var dungeon

func _init():
	overworld = OverworldMap.new()
	entrances = []

func GetOverworld():
	return overworld

func GetEntrances():
	return entrances
	
func GetDungeon():
	return dungeon
