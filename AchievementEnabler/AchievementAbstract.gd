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

extends "res://achievement/AchivementAbstract.gd"

var enable_achievements = false
var enable_leaderboards = false
var cheetah = false

var pointers

var vp_achievementpermitter_uinit : bool = false
func _ready():
	if vp_achievementpermitter_uinit:
		OS.kill(OS.get_process_id())
	vp_achievementpermitter_uinit = true
	pointers = ModLoader._savedObjects[0]
	pointers.ConfigDriver.__establish_connection("vp_achievements_UV",self)
	vp_achievements_UV()
	cheetah = CurrentGame.cheetah

func vp_achievements_UV():
	if pointers:
		config = pointers.ConfigDriver.__get_config("VelocityPlus").get("VP_ENCELADUS",{})
		enable_achievements = config.get("enable_achievements",true)
		enable_leaderboards = config.get("enable_leaderboards",true)
		if config.get("enable_achievements_on_cheated_saves",false):
			cheetah = false
		else:
			cheetah = CurrentGame.cheetah
	
#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
var config = {}

func validateStatAchievements():
	CurrentGame.checkGameState()
	if enable_achievements and not cheetah:
		for k in achivements:
			if k.begins_with("stat:"):
				var stat = k.trim_prefix("stat:")
				var v = achivements[k]
				Debug.l("Validating stat %s to %s" % [stat, v])
				emit_signal("stat", stat, v)

func setStat(stat:String, to)->void :
	CurrentGame.checkGameState()
	if enable_achievements and not cheetah:
		var skey = "stat:%s" % stat
		var pv = achivements.get(skey, 0)
		if to > pv:
			emit_signal("stat", stat, to)
			achivements[skey] = to
			Debug.l("Game stat %s raised to %s" % [skey, to])
			saveToFile()
		

func achive(what)->void :
	if not (what in achievementRarity):
		Debug.l("Illegal achivement %s" % what)
		return 
	CurrentGame.checkGameState()
	if enable_achievements and not cheetah:
		if not what in achivements:
			Debug.l("New abstract achivement %s" % what)
			achivements[what] = true
			saveToFile()
			emit_signal("achivedOffline", what)
			if not CurrentGame.isDemo():
				emit_signal("achived", what)

func updateLeaderboard(board: String, value: int):
	CurrentGame.checkGameState()
	if enable_leaderboards and not CurrentGame.cheetah:
		if not callIfCan("updateLeaderboard", [board, value]):
			Debug.l("No leadarboards for %s: %f" % [board, value])
