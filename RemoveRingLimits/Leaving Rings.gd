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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
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

var goLeft:bool = true
var goRight:bool = true

var baseWarnVelocity:float = 0.0

func vp_update_wv(how:bool):
	warnVelocity = INF if how else baseWarnVelocity

func vp_update_exit_left(how:bool):
	goLeft = !how

func vp_update_exit_right(how:bool):
	goRight = !how

func _init():
	if CurrentGame:
		baseWarnVelocity = warnVelocity
		var pointersVPRingEdgeRemoval:HevLibPointers._ConfigDriver = ModLoader._savedObjects[0].ConfigDriver
		pointersVPRingEdgeRemoval.__subscribe_to_setting_change("vp_update_wv",self,"VelocityPlus","VP_RING","remove_max_speed_limit")
		pointersVPRingEdgeRemoval.__subscribe_to_setting_change("vp_update_exit_left",self,"VelocityPlus","VP_RING","allow_exit_of_ring_to_the_left")
		pointersVPRingEdgeRemoval.__subscribe_to_setting_change("vp_update_exit_right",self,"VelocityPlus","VP_RING","allow_exit_of_ring_to_the_right")
		var cfg:Dictionary = pointersVPRingEdgeRemoval.__get_config("VelocityPlus").get("VP_RING",{})
		vp_update_wv(cfg.get("remove_max_speed_limit",true))
		vp_update_exit_left(cfg.get("allow_exit_of_ring_to_the_left",true))
		vp_update_exit_right(cfg.get("allow_exit_of_ring_to_the_right",true))
		visible = true

func _process(delta):
	if not is_visible_in_tree():
		return 
	if Tool.claim(ship):
		var v:float = CurrentGame.globalCoords(ship.global_position).x
		var leftMost:bool = false
		var rightMost:bool = false
		if goRight and v > 3.005e+07:
			rightMost = true
		if goLeft and v < 10000:
			leftMost = true
		text = "HUD_LEAVING_RINGS" if (leftMost or rightMost) else ""
		Tool.release(ship)
