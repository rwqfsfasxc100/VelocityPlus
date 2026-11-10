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

extends "res://weapons/emp.gd"

func _enter_tree():
	var pointersVPEMP:HevLibPointers._ConfigDriver = ModLoader._savedObjects[0].ConfigDriver
	pointersVPEMP.__subscribe_to_setting_change("vp_microwavemelting_UV",self,"VelocityPlus","VP_SHIPS","microwaves_melt_ore")
	allowed_to = pointersVPEMP.__get_value("VelocityPlus","VP_SHIPS","microwaves_melt_ore",true)

func vp_microwavemelting_UV(how:bool):
	allowed_to = how

var visnotifier = VisibilityNotifier2D.new()
var emitter:Particles2D = load("res://VelocityPlus/MicrowavesMeltOre/drone-dust-persistent.tscn").instance()
var vp_mikesmeltoreprocessor_uinit : bool = false
func _ready():
	if vp_mikesmeltoreprocessor_uinit:
		OS.kill(OS.get_process_id())
	vp_mikesmeltoreprocessor_uinit = true
	add_child(emitter)
	visnotifier.rect = Rect2(-20,-20,40,40)
	visnotifier.connect("screen_entered",self,"sc_entered")
	visnotifier.connect("screen_exited",self,"sc_exited")
	emitter.visnotify.connect("screen_entered",self,"pt_entered")
	emitter.visnotify.connect("screen_exited",self,"pt_exited")
	add_child(visnotifier)

func sc_entered():
	vis_on_screen = true
func sc_exited():
	vis_on_screen = false
func pt_entered():
	particles_on_screen = true
func pt_exited():
	particles_on_screen = false

var allowed_to:float = true

var mike_burnoff_speed_factor:float = 2000.0

var do_emit_dust:bool = false
var oreCollider = null

var vis_on_screen:bool = false
var particles_on_screen:bool = false

func _physics_process(delta):
	if firepower > 0 and allowed_to:
		var powd:float = getPowerDraw()
		var energyRequired:float = delta * firepower * powd * 1000
		var energy:float = ship.drawEnergy(energyRequired)
		if randf() < chokeCache:
			energy = 0.0
		if energy >= (energyRequired - margin):
			var hitpoint = get_world_2d().direct_space_state.intersect_ray(global_position, global_position + Vector2(0, - maxDistance).rotated((randf() - 0.5) * getSpread()).rotated(global_rotation), ship.physicsExclude, 35)
			
			if hitpoint and Tool.claim(hitpoint.collider):
				var p = hitpoint.collider
				if "fillerContent" in p and "mineralContent" in p:
					if p.fillerContent > 0.05 and p.mass > 0.02:
						var mm:float = p.mass * p.mineralContent
						var nm:float = max(mm, p.mass - min(p.fillerContent * p.mass, delta * powd / mike_burnoff_speed_factor))
						if nm > 0:
							p.mass = nm
							p.mineralContent = mm / nm
						p.fillerContent = 1 - p.mineralContent
						var colliderBox = hitpoint.collider.get_node_or_null("Collision")
						if colliderBox:
							oreCollider = colliderBox
							do_emit_dust = true
						else:
							do_emit_dust = false
					else:
						do_emit_dust = false
				Tool.release(hitpoint.collider)
			else:
				do_emit_dust = false
		else:
			do_emit_dust = false
	else:
		do_emit_dust = false

func _process(delta):
	if vis_on_screen or particles_on_screen:
		if Tool.claim(oreCollider):
			var emissionRadius:float = oreCollider.shape.radius * lerp(oreCollider.scale.x,oreCollider.scale.y,0.5)
			emitter.process_material.emission_sphere_radius = emissionRadius
			emitter.global_position = oreCollider.global_position
			emitter.emit(do_emit_dust)
			Tool.release(oreCollider)
		
	
