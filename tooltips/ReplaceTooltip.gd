extends Button
# Fixes issue no. 5340
# https://git.kodera.pl/games/delta-v/-/issues/5340

func _process(delta):
	if disabled:
		hint_tooltip = "DKB_CANNOT_REPLACE"
	else:
		hint_tooltip = "DKB_REPLACE_EQUIPMENT"
