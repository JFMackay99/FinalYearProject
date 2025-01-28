extends Node

class_name NoiseHandler

# Noise parameters
@export_enum("Value:5", "ValueCubic:4", "Perlin:3", "Cellular:2", "SimplexSmooth:1", "Simplex:0" ) var NoiseType = 0
@export var NoiseSeed: int = 0
@export var NoiseFrequency: float = 0.05

# Parameter buffers
var NoiseTypeBuffer = NoiseType
var SeedBuffer = NoiseSeed
var NoiseFrequencyBuffer = NoiseFrequency

# Noise Generator
var NoiseGenerator : Noise

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RegenerateNoise()

# Regenerate the noise to get a new noise pattern
func RegenerateNoise():
	# Use new parameters
	NoiseType= NoiseTypeBuffer
	NoiseSeed = SeedBuffer
	NoiseFrequency = NoiseFrequencyBuffer
	
	# Initialise the noise with new parameters
	NoiseGenerator = initialiseNoise(NoiseType, NoiseSeed, NoiseFrequency)

# Initialise the noise generator
func initialiseNoise(noiseTypeAsInt: int, inputSeed: int, frequency: float):
	# Create the noise generator object
	var noiseGenerator = FastNoiseLite.new()
	
	#Set parameters
	noiseGenerator.noise_type = noiseTypeAsInt
	noiseGenerator.seed = inputSeed
	noiseGenerator.frequency = frequency
	
	return noiseGenerator

	

# Retrieve the noise for the given two dimensional coordinate
func Get2DNoise(x : int, y : int):
	return NoiseGenerator.get_noise_2d(x, y)
	
