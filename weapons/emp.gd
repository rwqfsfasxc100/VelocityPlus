extends "res://weapons/emp.gd"

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _physics_process(delta):
	if firepower > 0:
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
				if "comp_val" in p:
					if "fillerContent" in p and "mineralContent" in p:
						if ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","microwaves_melt_ore") and p.fillerContent > 0.05 and p.mass > 0.02:
							var pv = getPowerDraw()
							var cv = p.comp_val
							var filler = p.fillerContent * p.mass
							var mc = (cv - filler) / cv
							var mm = p.mass * mc
							var proc = min(filler, delta * pv / 2500)
							var nm = max(mm, p.mass - proc)
							
							var rpm = p.mass - nm
							if nm > 0:
								p.mass = nm
								mc = mm / nm
							p.fillerContent = 1 - mc
				else:
					if "fillerContent" in p and "mineralContent" in p:
						if ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","microwaves_melt_ore") and p.fillerContent > 0.05 and p.mass > 0.02:
							var pv = getPowerDraw()
							var filler = p.fillerContent * p.mass
							var mm = p.mass * p.mineralContent
							var proc = min(filler, delta * pv / 2500)
							var nm = max(mm, p.mass - proc)
							
							var rpm = p.mass - nm
							if nm > 0:
								p.mass = nm
								p.mineralContent = mm / nm
							p.fillerContent = 1 - p.mineralContent
								
				Tool.release(hitpoint.collider)
