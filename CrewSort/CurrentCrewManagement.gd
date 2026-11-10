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

extends "res://enceladus/CurrentCrewManagement.gd"

var vp_crewwsort_sort_mode:int = 4
var vp_crewwsort_prio_active:bool = true
var vp_crewsort_dir:int = 0

var vp_omsdisplayexpansionlogcheck_uinit : bool = false
func _ready():
	if vp_omsdisplayexpansionlogcheck_uinit:
		OS.kill(OS.get_process_id())
	vp_omsdisplayexpansionlogcheck_uinit = true
	var pointersVP_crew_sort:HevLibPointers._ConfigDriver = ModLoader._savedObjects[0].ConfigDriver
	pointersVP_crew_sort.__subscribe_to_setting_change("vp_crewsort_UV",self,"VelocityPlus","VP_CREW","crew_sort_method")
	pointersVP_crew_sort.__subscribe_to_setting_change("vp_crewsortactive_UV",self,"VelocityPlus","VP_CREW","crew_sort_active_first")
	pointersVP_crew_sort.__subscribe_to_setting_change("vp_crewsortorder_UV",self,"VelocityPlus","VP_CREW","crew_sort_direction")
	vp_crewwsort_sort_mode = pointersVP_crew_sort.__get_value("VelocityPlus","VP_CREW","crew_sort_method",4)
	vp_crewwsort_prio_active = pointersVP_crew_sort.__get_value("VelocityPlus","VP_CREW","crew_sort_active_first",true)
	vp_crewsort_dir = pointersVP_crew_sort.__get_value("VelocityPlus","VP_CREW","crew_sort_direction",0)

func vp_crewsort_UV(how:int):
	vp_crewwsort_sort_mode = how
	fillCrew()

func vp_crewsortorder_UV(how:int):
	vp_crewsort_dir = how
	fillCrew()
	
func vp_crewsortactive_UV(how:bool):
	vp_crewwsort_prio_active = how
	fillCrew()

func fillCrew():
	.fillCrew()
	if vp_crewwsort_sort_mode > 0:
		var crewNodes:Array = crewNode.get_children()
		crewNodes.sort_custom(self,"sort_crew_by")
		for i in crewNodes.size():
			crewNode.move_child(crewNodes[i],i)
	elif vp_crewwsort_prio_active:
		var crewNodes:Array = crewNode.get_children()
		crewNodes.sort_custom(self,"sort_crew_active_only")
		for i in crewNodes.size():
			crewNode.move_child(crewNodes[i],i)

func sort_crew_active_only(a:MarginContainer,b:MarginContainer):
	if a.active and not b.active:
		return true
	return false
func sort_crew_by(a:MarginContainer,b:MarginContainer):
	if vp_crewwsort_prio_active:
		var aa:bool = a.active
		var ba:bool = b.active
		if aa and not ba:
			return true
		if ba and not aa:
			return false
	var ao:String = a.occupation
	var ap:float = a.salary
	var ae:float = (a.experience + a.talent) / 2.0
	var bo:String = b.occupation
	var bp:float = b.salary
	var be:float = (b.experience + b.talent) / 2.0
	if vp_crewwsort_sort_mode == 1:
		if ap != bp:
			return ap > bp if vp_crewsort_dir else ap < bp
		if ao != bo:
			return ao > bo if vp_crewsort_dir else ao < bo
		if ae != be:
			return ae < be if vp_crewsort_dir else ae > be
	elif vp_crewwsort_sort_mode == 2:
		if ap != bp:
			return ap > bp if vp_crewsort_dir else ap < bp
		if ae != be:
			return ae < be if vp_crewsort_dir else ae > be
		if ao != bo:
			return ao > bo if vp_crewsort_dir else ao < bo
	if vp_crewwsort_sort_mode == 3:
		if ae != be:
			return ae < be if vp_crewsort_dir else ae > be
		if ap != bp:
			return ap > bp if vp_crewsort_dir else ap < bp
		if ao != bo:
			return ao > bo if vp_crewsort_dir else ao < bo
	elif vp_crewwsort_sort_mode == 4:
		if ae != be:
			return ae < be if vp_crewsort_dir else ae > be
		if ao != bo:
			return ao > bo if vp_crewsort_dir else ao < bo
		if ap != bp:
			return ap > bp if vp_crewsort_dir else ap < bp
	if vp_crewwsort_sort_mode == 5:
		if ao != bo:
			return ao > bo if vp_crewsort_dir else ao < bo
		if ae != be:
			return ae < be if vp_crewsort_dir else ae > be
		if ap != bp:
			return ap > bp if vp_crewsort_dir else ap < bp
	elif vp_crewwsort_sort_mode == 6:
		if ao != bo:
			return ao > bo if vp_crewsort_dir else ao < bo
		if ap != bp:
			return ap > bp if vp_crewsort_dir else ap < bp
		if ae != be:
			return ae < be if vp_crewsort_dir else ae > be
	return a.fullName > b.fullName if vp_crewsort_dir else a.fullName < b.fullName
