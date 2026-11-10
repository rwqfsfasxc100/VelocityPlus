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

var vp_omsdisplayexpansionlogcheck_uinit : bool = false
func _ready():
	if vp_omsdisplayexpansionlogcheck_uinit:
		OS.kill(OS.get_process_id())
	vp_omsdisplayexpansionlogcheck_uinit = true
	var pointersVP_shipped_goods_display:HevLibPointers._ConfigDriver = ModLoader._savedObjects[0].ConfigDriver
	pointersVP_shipped_goods_display.__subscribe_to_setting_change("vp_shippedgoods_UV",self,"VelocityPlus","VP_RING","show_shipped_cargo_value")
	show_shipped_cargo_value = pointersVP_shipped_goods_display.__get_value("VelocityPlus","VP_RING","show_shipped_cargo_value",true)

func vp_shippedgoods_UV(how:bool):
	show_shipped_cargo_value = how

var this_dive_transactions_gain:float = 0.0
var this_dive_transactions_spent:float = 0.0

var vp_this_dive_time_spent_astrogating:float = 0.0

var show_shipped_cargo_value:bool = true
func logEvent(type: String, details = {}):
	.logEvent(type,details)
	if show_shipped_cargo_value:
		if type == "LOG_EVENT_DIVE":
			if "LOG_EVENT_DETAILS_TRADE_SELL" in details:
				this_dive_transactions_gain += abs(details["LOG_EVENT_DETAILS_TRADE_SELL"])
			if "LOG_EVENT_DETAILS_TRADE_BUY" in details:
				this_dive_transactions_spent += abs(details["LOG_EVENT_DETAILS_TRADE_BUY"])
			if "LOG_EVENT_DETAILS_DIALOG_MONEY" in details:
				this_dive_transactions_gain += abs(details["LOG_EVENT_DETAILS_DIALOG_MONEY"])
			if "LOG_EVENT_DETAILS_DIALOG_EXPENSES" in details:
				this_dive_transactions_spent += abs(details["LOG_EVENT_DETAILS_DIALOG_EXPENSES"])
