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

extends "res://sfx/thruster.gd"

var VP_pointers


func vp_thrusterTempModeration_UV():
	if VP_pointers:
		var config = VP_pointers.ConfigDriver.__get_config("VelocityPlus").get("VP_SHIPS",{})
		adjust_thrust_to_temperature = config.get("adjust_thrust_to_temperature",false)
		adjust_thrust_multi = config.get("adjust_thrust_multi",1.0)

var adjust_thrust_to_temperature = false
var adjust_thrust_multi = 1.0

var temp = 0
var avgTarget = 0
var count = 0

var interruptObject
func a1(how):
	adjust_thrust_to_temperature = how
func a3(how):
	adjust_thrust_multi = how
var vp_tempbasedthrusthandler_uinit : bool = false
func _ready():
	if vp_tempbasedthrusthandler_uinit:
		OS.kill(OS.get_process_id())
	vp_tempbasedthrusthandler_uinit = true
	if ship.isPlayerControlled() and ship.isRealShip():
		VP_pointers = ModLoader._savedObjects[0]
		VP_pointers.ConfigDriver.__subscribe_to_setting_change("a1",self,"VelocityPlus","VP_SHIPS","adjust_thrust_to_temperature")
		VP_pointers.ConfigDriver.__subscribe_to_setting_change("a3",self,"VelocityPlus","VP_SHIPS","adjust_thrust_multi")
		vp_thrusterTempModeration_UV()
		yield(CurrentGame.get_tree(),"idle_frame")
		interruptObject = load("res://VelocityPlus/TemperatureBasedThrust/ThrusterShipInterrupt.gd").new(VP_pointers,ship,self)
		ship = interruptObject

func _physics_process(delta):
	if adjust_thrust_to_temperature:
		count += 1
		if count > 5:
			count = 0
			var reactors = ship.reactors
			var rt = 0
			var rc = reactors.size()
			if rc:
				temp = ship.sensorGet("reactor_temperature")
				for i in reactors:
					rt += i.targetTemperature
				avgTarget = floor(float(rt) / float(rc))
			else:
				temp = 1
				avgTarget = 1

func getThrust(force = false):
	var outThrust = .getThrust(force)
	if adjust_thrust_to_temperature and not externalPower:
		if temp > 1000:
			var multi = (float(temp)/float(avgTarget))
			var s0 = multi - 1.0
			var s1 = s0 * adjust_thrust_multi
			var s2 = s1 + 1.0
			if multi != 1:
				var newthrust = max(outThrust * s2,outThrust * 0.1)
				return newthrust
	return outThrust
