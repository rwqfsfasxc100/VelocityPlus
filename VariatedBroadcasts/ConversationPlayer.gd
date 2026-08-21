# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends "res://comms/ConversationPlayer.gd"

var pointersVP

func vp_conversation_UV():
	if pointersVP:
		broadcast_variations = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_RING","broadcast_variations")


var broadcast_variations = true
var vp_varbroadcastshandler_uinit : bool = false
func _ready():
	if vp_varbroadcastshandler_uinit:
		OS.kill(OS.get_process_id())
	vp_varbroadcastshandler_uinit = true
	var cname = self.name
	if cname.begins_with("DIALOG_SALVAGE_"):
		pointersVP = ModLoader._savedObjects[0]
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
		pointersVP = ModLoader._savedObjects[0]
		pointersVP.ConfigDriver.__establish_connection("vp_conversation_UV",self)
		vp_conversation_UV()
		if broadcast_variations:
			var RNG = RandomNumberGenerator.new()
			RNG.randomize()
			var random = RNG.randf_range(168,2592)
			poiTimeHours = random
	elif cname.begins_with("DIALOG_MINER_SEEN_"):
		pointersVP = ModLoader._savedObjects[0]
		pointersVP.ConfigDriver.__establish_connection("vp_conversation_UV",self)
		vp_conversation_UV()
		if broadcast_variations:
			var RNG = RandomNumberGenerator.new()
			RNG.randomize()
			var random = RNG.randf_range(168,2592)
			poiTimeHours = random
	elif cname == "DIALOG_PIRATE_BUSINESS_DEAL":
		pointersVP = ModLoader._savedObjects[0]
		pointersVP.ConfigDriver.__establish_connection("vp_conversation_UV",self)
		vp_conversation_UV()
		if broadcast_variations:
			var RNG = RandomNumberGenerator.new()
			RNG.randomize()
			var random = RNG.randf_range(168,2592)
			poiTimeHours = random
