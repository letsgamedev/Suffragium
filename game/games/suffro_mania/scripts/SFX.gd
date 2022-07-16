extends Node


func play(name) -> void:
	var node = find_node(name)
	

	if node != null:
		node.play(0)
		
		
		node.connect("finished", self, "delete")

func delete() -> void:
	queue_free()

