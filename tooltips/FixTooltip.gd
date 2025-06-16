extends Button
# Fixes issue no. 5340
# https://git.kodera.pl/games/delta-v/-/issues/5340


func _physics_process(delta):
	if disabled:
		hint_tooltip = "DKB_CANNOT_REPAIR"
	else:
		hint_tooltip = "DKB_REPAIR_EQUIPMENT"
