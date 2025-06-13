extends "res://comms/ConversationPlayer.gd"

var HevLib = preload("res://HevLib/Functions.gd").new()

func _ready():
	var name = self.name
	var RNG = RandomNumberGenerator.new()
	RNG.randomize()
	if name.begins_with("DIALOG_SALVAGE_EXPOSE_"):
		var random = RNG.randf_range(6,80)
		poiTimeHours = random
		if random >= 1 and random < 16:
			self.name = "DIALOG_SALVAGE_EXPOSE_FAST_" + name.split("DIALOG_SALVAGE_EXPOSE_")[1]
		if random >=30 and random < 45:
			self.name = "DIALOG_SALVAGE_EXPOSE_DELAYED_" + name.split("DIALOG_SALVAGE_EXPOSE_")[1]
		if random >= 45 and random < 60:
			self.name = "DIALOG_SALVAGE_EXPOSE_SLOW_" + name.split("DIALOG_SALVAGE_EXPOSE_")[1]
		if random >= 60 and random <= 80:
			self.name = "DIALOG_SALVAGE_EXPOSE_OLD_" + name.split("DIALOG_SALVAGE_EXPOSE_")[1]
		
	if name.begins_with("DIALOG_PIRATE_BUSINESS_DEAL"):
		var random = RNG.randf_range(168,2592)
		poiTimeHours = random
	if name.begins_with("DIALOG_POI_RANDOM_"):
		var random = RNG.randf_range(168,2592)
		poiTimeHours = random
	if name.begins_with("DIALOG_MINER_SEEN_"):
		var random = RNG.randf_range(168,2592)
		poiTimeHours = random
	
	var randCheck = RNG.randf_range(0,1)
	if randCheck == 0:
		var stat = HevLib.__get_stat_data("stat:salvaged_ships")
		if name.begins_with("DIALOG_SALVAGE_START_"):
			if stat == 0:
				self.name = "DIALOG_SALVAGE_START_NEW_" + name.split("DIALOG_SALVAGE_START_")[1]
			if stat >= 1 and stat <= 5:
				self.name = "DIALOG_SALVAGE_START_BEGINNER_" + name.split("DIALOG_SALVAGE_START_")[1]
			if stat >= 35 and stat < 50:
				self.name = "DIALOG_SALVAGE_START_EXPERIENCED_" + name.split("DIALOG_SALVAGE_START_")[1]
			if stat >= 50:
				self.name = "DIALOG_SALVAGE_START_MASTER_" + name.split("DIALOG_SALVAGE_START_")[1]
		
		if name.begins_with("DIALOG_SALVAGE_BYE_"):
		
			if stat == 0:
				self.name = "DIALOG_SALVAGE_BYE_NEW_" + name.split("DIALOG_SALVAGE_BYE_")[1]
			if stat >= 1 and stat <= 5:
				self.name = "DIALOG_SALVAGE_BYE_BEGINNER_" + name.split("DIALOG_SALVAGE_BYE_")[1]
			if stat >= 35 and stat < 50:
				self.name = "DIALOG_SALVAGE_BYE_EXPERIENCED_" + name.split("DIALOG_SALVAGE_BYE_")[1]
			if stat >= 50:
				self.name = "DIALOG_SALVAGE_BYE_MASTER_" + name.split("DIALOG_SALVAGE_BYE_")[1]
		
