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

extends "res://ships/modules/PDT.gd"

var default_fire_mode = true
var default_fire_action = ""

var pointersVP_turret_overrides
var wp

func _enter_tree():
	wp = get_node_or_null(weaponPath)
	default_fire_mode = autoFire
	if wp:
		default_fire_action = wp.command
	else:
		yield(get_tree(),"idle_frame")
		wp = get_node_or_null(weaponPath)
		if wp:
			default_fire_action = wp.command
	pointersVP_turret_overrides = ModLoader._savedObjects[0]
	pointersVP_turret_overrides.ConfigDriver.__establish_connection("vp_turretfixer_UV",self)
	vp_turretfixer_UV()

var do_change_mode = false
var autofire_type = "VP_TURRET_OVERRIDE_NOFIRE"

func vp_turretfixer_UV():
	if pointersVP_turret_overrides:
		do_change_mode = pointersVP_turret_overrides.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","override_turret_autofire")
		autofire_type = pointersVP_turret_overrides.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","turret_override_mode")
	if not wp:
		wp = get_node_or_null(weaponPath)
		if wp:
			default_fire_action = wp.command
	if do_change_mode:
		match autofire_type:
			"VP_TURRET_OVERRIDE_FIRE":
				autoFire = true
				if wp:
					wp.command = default_fire_action
			"VP_TURRET_OVERRIDE_NOFIRE":
				autoFire = false
				if wp:
					wp.command = "w"
			_:
				autoFire = default_fire_mode
				if wp:
					wp.command = default_fire_action
	else:
		if wp:
			wp.command = default_fire_action
		autoFire = default_fire_mode
