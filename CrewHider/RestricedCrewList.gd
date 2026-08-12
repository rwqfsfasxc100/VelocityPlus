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

extends "res://hud/components/RestricedCrewList.gd"

var pointersVP
signal drawn_crew
var vacPath = NodePath("C/O/Vac")

func _enter_tree():
	pointersVP = ModLoader._savedObjects[0]
	pointersVP.ConfigDriver.__establish_connection("vp_crewrestrictedlist_UV",self)
	yield(self,"drawn_crew")
	vp_crewrestrictedlist_UV()

func vp_crewrestrictedlist_UV():
	if pointersVP:
		var hideCrew = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_CREW","hide_in_OMS")
		if hideCrew:
			visible = false
		else:
			var hideVac = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_CREW","hide_crew_suit")
			for i in list.get_children():
				var vac = i.get_node_or_null(vacPath)
				if vac:
					if hideVac:
						vac.visible = false
					else:
						vac.visible = true
			visible = true

func drawCrew():
	.drawCrew()
	emit_signal("drawn_crew")
