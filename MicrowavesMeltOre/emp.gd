extends "res://weapons/emp.gd"

var pointersVPEMP

var dustScene := load("res://VelocityPlus/MicrowavesMeltOre/drone-dust-persistent.tscn")

func _enter_tree():
	pointersVPEMP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVPEMP.ConfigDriver.__establish_connection("vp_microwavemelting_UV",self)
	vp_microwavemelting_UV()

func vp_microwavemelting_UV():
	if pointersVPEMP:
		allowed_to = pointersVPEMP.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","microwaves_melt_ore")

var visnotifier
var emitter
func _ready():
	emitter = dustScene.instance()
	add_child(emitter)
	visnotifier = VisibilityNotifier2D.new()
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

var allowed_to = true
var legacy_multimineral_handle = false

var mike_burnoff_speed_factor = 2000

var do_emit_dust = false
var oreCollider = null

var vis_on_screen = false
var particles_on_screen = false

func _physics_process(delta):
	if firepower > 0 and allowed_to:
		var energyRequired = delta * firepower * getPowerDraw() * 1000
		var energy = ship.drawEnergy(energyRequired)
		if randf() < chokeCache:
			energy = 0
		if energy >= energyRequired - margin:
			var space_state = get_world_2d().direct_space_state
			var ray = Vector2(0, - maxDistance).rotated((randf() - 0.5) * getSpread())
			var hitpoint = space_state.intersect_ray(global_position, global_position + ray.rotated(global_rotation), ship.physicsExclude, 35)
			
			if hitpoint and Tool.claim(hitpoint.collider):
				var p = hitpoint.collider
				if "fillerContent" in p and "mineralContent" in p:
					var processing = false
					if legacy_multimineral_handle and "comp_val" in p:
						if p.fillerContent > 0.05 and p.mass > 0.02:
							var pv = getPowerDraw()
							var cv = p.comp_val
							var filler = p.fillerContent * p.mass
							var mc = (cv - filler) / cv
							var mm = p.mass * mc
							var proc = min(filler, delta * pv / mike_burnoff_speed_factor)
							var nm = max(mm, p.mass - proc)
							
							var rpm = p.mass - nm
							if nm > 0:
								p.mass = nm
								mc = mm / nm
							p.fillerContent = 1 - mc
							processing = true
					else:
						if p.fillerContent > 0.05 and p.mass > 0.02:
							var pv = getPowerDraw()
							var filler = p.fillerContent * p.mass
							var mm = p.mass * p.mineralContent
							var proc = min(filler, delta * pv / mike_burnoff_speed_factor)
							var nm = max(mm, p.mass - proc)
							
							var rpm = p.mass - nm
							if nm > 0:
								p.mass = nm
								p.mineralContent = mm / nm
							p.fillerContent = 1 - p.mineralContent
							processing = true
					
					if processing:
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
			var emissionRadius = oreCollider.shape.radius * lerp(oreCollider.scale.x,oreCollider.scale.y,0.5)
			emitter.process_material.emission_sphere_radius = emissionRadius
			emitter.global_position = oreCollider.global_position
			emitter.emit(do_emit_dust)
			Tool.release(oreCollider)
		
	
