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

extends Control

func _ready():
	var costEffective = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/CostEffectiveFixTo100/Action")
	var fix = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/RepairFixTo100/Action")
	var replace = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/ReplaceFixTo100/Action")
	var profit = NodePath( "Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MaxProfit/Action" )
	var ce = get_node_or_null(costEffective)
	var f = get_node_or_null(fix)
	var r = get_node_or_null(replace)
	var pr = get_node_or_null(profit)
	
	var manual = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/RepairFromCurrentOperands/Action")
	var manual_costEffective = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/FixToCurrent/Action")
	var manual_fix = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/RepairToCurrent/Action")
	var manual_replace = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/ReplaceToCurrent/Action")
	var m = get_node_or_null(manual)
	var mce = get_node_or_null(manual_costEffective)
	var mf = get_node_or_null(manual_fix)
	var mr = get_node_or_null(manual_replace)
	
	
	var p = get_parent().get_parent()
	if ce:
		ce.connect("pressed",p,"manual_cost_effective_repair")
	if f:
		f.connect("pressed",p,"manual_fix_repair")
	if r:
		r.connect("pressed",p,"manual_replace_repair")
	if pr:
		pr.connect("pressed",p,"manual_max_profit")
	if m:
		m.connect("pressed",p,"manual_current")
	if mce:
		mce.connect("pressed",p,"manual_ce")
	if mf:
		mf.connect("pressed",p,"manual_f")
	if mr:
		mr.connect("pressed",p,"manual_r")
	
	
	pass

func move():
	var pos = get_parent().get_parent().rect_global_position# + get_parent().rect_global_position
	rect_position = Vector2(-pos.x + 10,55)

func _process(delta):
	if is_visible_in_tree():
		move()
