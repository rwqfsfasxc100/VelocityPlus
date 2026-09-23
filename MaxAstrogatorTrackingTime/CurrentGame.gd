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

extends "res://CurrentGame.gd"

var pointersVP_astro_tracking_time:HevLibPointers

var astrogation_tracking_time_modifier = true

var vp_maxastrotrackingstatmodifier_uinit : bool = false
func _ready():
	if vp_maxastrotrackingstatmodifier_uinit:
		OS.kill(OS.get_process_id())
	vp_maxastrotrackingstatmodifier_uinit = true
	pointersVP_astro_tracking_time = ModLoader._savedObjects[0]
	pointersVP_astro_tracking_time.ConfigDriver.__establish_connection("vp_astrogator_tracking_time_UV",self)
	vp_astrogator_tracking_time_UV()

func vp_astrogator_tracking_time_UV():
	if pointersVP_astro_tracking_time:
		astrogation_tracking_time_modifier = pointersVP_astro_tracking_time.ConfigDriver.__get_value("VelocityPlus","VP_CREW","astrogation_tracking_time_modifier")

func deriveStats(stats):
	var s = .deriveStats(stats)
	var multi = astrogation_tracking_time_modifier
	stats.CREW_STATS_ASTROGATOR_TIME = max(12 * 3600, 24 * 3600 * (stats.CREW_OCCUPATION_ASTROGATOR.experience * 30 * 3 * (multi / 90)))
	return s
