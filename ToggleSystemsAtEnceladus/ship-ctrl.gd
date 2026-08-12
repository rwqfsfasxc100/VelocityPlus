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

extends "res://ships/ship-ctrl.gd"

var pointersVP_toggle_systems_at_enceladusprime

func vp_enceladusprime_ship_toggles_UV():
	if pointersVP_toggle_systems_at_enceladusprime:
		toggle_systems_at_enceladus = pointersVP_toggle_systems_at_enceladusprime.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","toggle_systems_at_enceladus")

var toggle_systems_at_enceladus = false


const omsToggleCfg = "omstoggles.%s.%s"


func handleSystemToggles():
	if not setup:
		yield(self,"setup")
	if not "omstoggles" in shipConfig:
		shipConfig.merge({"omstoggles":{}})
	var oms = shipConfig["omstoggles"]
	var systems = getSystems()
	if systems.keys().size() > 0:
		for system in systems:
			var sys = systems[system]
			var toggleable = sys.togleable
			var current = sys.name
			if toggleable:
				var cg = getConfig(omsToggleCfg % [system,current],true)
				sys.ref.enabled = cg

func _enter_tree():
	pointersVP_toggle_systems_at_enceladusprime = ModLoader._savedObjects[0]
	pointersVP_toggle_systems_at_enceladusprime.ConfigDriver.__establish_connection("vp_enceladusprime_ship_toggles_UV",self)
	vp_enceladusprime_ship_toggles_UV()

var vp_toggleequipmentpersisthandler_uinit : bool = false
func _ready():
	if vp_toggleequipmentpersisthandler_uinit:
		OS.kill(OS.get_process_id())
	vp_toggleequipmentpersisthandler_uinit = true
	if toggle_systems_at_enceladus:
		handleSystemToggles()



