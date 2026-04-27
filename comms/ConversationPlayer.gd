extends "res://comms/ConversationPlayer.gd"

var pointersVP

func vp_conversation_UV():
	if pointersVP:
		broadcast_variations = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_RING","broadcast_variations")


var broadcast_variations = true
func _ready():
	var cname = self.name
	if cname.begins_with("DIALOG_SALVAGE_"):
		pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
		pointersVP.ConfigDriver.__establish_connection("vp_conversation_UV",self)
		vp_conversation_UV()
		if broadcast_variations:
			var rename_this_comms_to = ""
			var RNG = RandomNumberGenerator.new()
			RNG.randomize()
			if cname.begins_with("DIALOG_SALVAGE_EXPOSE_"):
				var random = RNG.randf_range(6,80)
				poiTimeHours = random
				if random >= 1 and random < 16:
					rename_this_comms_to = "DIALOG_SALVAGE_EXPOSE_FAST_" + cname.split("DIALOG_SALVAGE_EXPOSE_")[1]
			var randCheck = RNG.randf_range(0,1)
			if randCheck == 0:
				var stat = pointersVP.Achievements.__get_stat_data("stat:salvaged_ships")
				if cname.begins_with("DIALOG_SALVAGE_START_"):
					if stat >= 0 and stat < 7:
						rename_this_comms_to = "DIALOG_SALVAGE_START_NEW_" + cname.split("DIALOG_SALVAGE_START_")[1]
					if stat >= 7 and stat < 15:
						rename_this_comms_to = "DIALOG_SALVAGE_START_BEGINNER_" + cname.split("DIALOG_SALVAGE_START_")[1]
					if stat >= 35 and stat < 50:
						rename_this_comms_to = "DIALOG_SALVAGE_START_EXPERIENCED_" + cname.split("DIALOG_SALVAGE_START_")[1]
					if stat >= 50:
						rename_this_comms_to = "DIALOG_SALVAGE_START_MASTER_" + cname.split("DIALOG_SALVAGE_START_")[1]
				
				if cname.begins_with("DIALOG_SALVAGE_BYE_"):
				
					if stat >= 0 and stat < 7:
						rename_this_comms_to = "DIALOG_SALVAGE_BYE_NEW_" + cname.split("DIALOG_SALVAGE_BYE_")[1]
					if stat >= 7 and stat < 15:
						rename_this_comms_to = "DIALOG_SALVAGE_BYE_BEGINNER_" + cname.split("DIALOG_SALVAGE_BYE_")[1]
					if stat >= 35 and stat < 50:
						rename_this_comms_to = "DIALOG_SALVAGE_BYE_EXPERIENCED_" + cname.split("DIALOG_SALVAGE_BYE_")[1]
					if stat >= 50:
						rename_this_comms_to = "DIALOG_SALVAGE_BYE_MASTER_" + cname.split("DIALOG_SALVAGE_BYE_")[1]
			if rename_this_comms_to:
				self.name = rename_this_comms_to
	elif cname.begins_with("DIALOG_POI_RANDOM_"):
		pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
		pointersVP.ConfigDriver.__establish_connection("vp_conversation_UV",self)
		vp_conversation_UV()
		if broadcast_variations:
			var RNG = RandomNumberGenerator.new()
			RNG.randomize()
			var random = RNG.randf_range(168,2592)
			poiTimeHours = random
	elif cname.begins_with("DIALOG_MINER_SEEN_"):
		pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
		pointersVP.ConfigDriver.__establish_connection("vp_conversation_UV",self)
		vp_conversation_UV()
		if broadcast_variations:
			var RNG = RandomNumberGenerator.new()
			RNG.randomize()
			var random = RNG.randf_range(168,2592)
			poiTimeHours = random
	elif cname == "DIALOG_PIRATE_BUSINESS_DEAL":
		pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
		pointersVP.ConfigDriver.__establish_connection("vp_conversation_UV",self)
		vp_conversation_UV()
		if broadcast_variations:
			var RNG = RandomNumberGenerator.new()
			RNG.randomize()
			var random = RNG.randf_range(168,2592)
			poiTimeHours = random
