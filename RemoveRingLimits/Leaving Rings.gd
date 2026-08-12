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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
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

extends "res://hud/Leaving Rings.gd"

var goLeft = false
var goRight = false
var noSpeedLimit = false

var pointersVPRingEdgeRemoval

var baseWarnVelocity = 0

func vp_leavingring_UV():
	if pointersVPRingEdgeRemoval:
		speed_limit_config = pointersVPRingEdgeRemoval.ConfigDriver.__get_config("VelocityPlus").get("VP_RING",{})
		noSpeedLimit = speed_limit_config.get("VP_RING",{}).get("remove_max_speed_limit")
	if noSpeedLimit:
		warnVelocity = 1.79769e308
	else:
		warnVelocity = baseWarnVelocity

var speed_limit_config = {}
func _init():
	if CurrentGame != null:
		pointersVPRingEdgeRemoval = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
		pointersVPRingEdgeRemoval.ConfigDriver.__establish_connection("vp_leavingring_UV",self)
		baseWarnVelocity = warnVelocity
		vp_leavingring_UV()
		visible = true

func _process(delta):
	if not is_visible_in_tree():
		return 
	if Tool.claim(ship):
		var v = CurrentGame.globalCoords(ship.global_position).x
		var leftMost = false
		var rightMost = false
		if v > 3.005e+07 and not speed_limit_config.get("allow_exit_of_ring_to_the_right",true):
			rightMost = true
		if v < 10000 and not speed_limit_config.get("allow_exit_of_ring_to_the_left",true):
			leftMost = true
		
		if leftMost or rightMost:
			text = "HUD_LEAVING_RINGS"
		else:
			text = ""
		
		Tool.release(ship)
