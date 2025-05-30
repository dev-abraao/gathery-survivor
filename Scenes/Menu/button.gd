extends Button


func _ready():
	$Button.add_stylebox_override("hover", $Button.get_stylebox("normal"))
	$Button.add_stylebox_override("pressed", $Button.get_stylebox("normal"))
	$Button.add_stylebox_override("focus", $Button.get_stylebox("normal"))
