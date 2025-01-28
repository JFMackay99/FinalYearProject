extends Camera2D

@export var cameraSpeed = 4

var xPos = 0
var yPos = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		if Input.is_action_pressed("ui_left"):
			xPos-=cameraSpeed
			self.move_local_x(-cameraSpeed)
		if Input.is_action_pressed("ui_right"):
			xPos += cameraSpeed
			self.move_local_x(cameraSpeed)
		if Input.is_action_pressed("ui_down"):
			yPos += cameraSpeed
			self.move_local_y(cameraSpeed)
		if Input.is_action_pressed("ui_up"):
			yPos -= cameraSpeed
			self.move_local_y(-cameraSpeed)
		if Input.is_action_pressed("ui_accept"):
			self.move_local_x(-xPos)
			self.move_local_y(-yPos)
			xPos = 0
			yPos = 0
			
	

func UpdateSpeed(value: float) -> void:
	cameraSpeed = value


func UpdateZoom(value: float) -> void:
	#value will be a percentage
	# camera zoom function wants a 2d vector
	var normalisedScale: float = value /100
	var vectorScale = Vector2(normalisedScale, normalisedScale)
	self.set_zoom(vectorScale)
	
	
	
