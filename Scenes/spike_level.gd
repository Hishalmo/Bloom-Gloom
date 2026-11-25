extends TileMapLayer


# ensures spikes are hidden on start
func _ready() -> void:
	self.visible = false
