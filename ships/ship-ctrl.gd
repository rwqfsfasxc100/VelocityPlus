extends "res://ships/ship-ctrl.gd"
#
#var MPUs = []
#var HUDs = []
#
#func _ready():
#	var children = get_children()
#	for child in children:
#		var scriptobj = child.get_script()
#		if scriptobj != null:
#			var script = scriptobj.get_path()
#			if script == "res://hud/Hud.gd":
#				HUDs.append(child)
#			if script == "res://ships/modules/MineralProcessingUnit.gd":
#				MPUs.append(child)
#	var mname = self.shipName
##	breakpoint
#
#func _process(delta):
#	if !self.cutscene and self.isPlayerControlled():
#		if Input.is_action_pressed("velocityplus_toggle_mpu"):
#			for mpu in MPUs:
#				mpu.enabled = not mpu.enabled
#		if Input.is_action_just_pressed("velocityplus_toggle_hud"):
#			for hud in HUDs:
#				hud.visible = !hud.visible
#var key_actions = []
#
#var action_dict = {}

#func _ready():
#	set_process_input(true)
#	key_actions = InputMap.get_actions()
#	for action in key_actions:
#		action_dict.merge({action:false})

#func _input(event):
#	breakpoint

const ConfigDriverVP = preload("res://HevLib/pointers/ConfigDriver.gd")

func handleTrajectoryProgress(delta):
	var config = ConfigDriverVP.__get_config("VelocityPlus")
	if config.get("VP_CREW",{}).get("pilots_reduce_astro_calculations",true):
		var education = 0
		var experience = 0
		var crewData = CurrentGame.getCurrentlyActiveCrewNames()
		for crew in crewData:
			var dta = CurrentGame.state.crew[crew]
			if dta.occupation == "CREW_OCCUPATION_PILOT":
				if dta.experience >= experience:
					experience = dta.experience
				if dta.talent >= education:
					education = dta.talent
		
		var minimum = float(config.get("VP_CREW",{}).get("minimum_astrogation_time",3))
		var maximum = float(config.get("VP_CREW",{}).get("maximum_astrogation_time",10))
		var bias = float(config.get("VP_CREW",{}).get("pilot_skill_bias",0.3))
		var exmod = lerp(education,experience,bias)
		var diff = (exmod * maximum)
		var shrink = (maximum - diff)/maximum
		var modifier = lerp(minimum,maximum,shrink)
		trajectoryTime = clamp(modifier,minimum,maximum)
	.handleTrajectoryProgress(delta)

func sensorGet(sensor):
	
	if ConfigDriverVP.__get_value("VelocityPlus","VP_RING","display_negative_depth"):
		match sensor:
			"diveDepth":
				var depth = CurrentGame.globalCoords(global_position).x / 10000 - 1.0
				return depth
			_:
				return .sensorGet(sensor)
	else:
		return .sensorGet(sensor)

func isInEscapeCondition():
	if test:
		return false
	if dead:
		return false
	if escapeCutscene:
		return true
	if cutscene:
		return false
	if not isPlayerControlled():
		return false
	
	
	if CurrentGame.globalCoords(global_position).x < 0 and ConfigDriverVP.__get_value("VelocityPlus","VP_RING","allow_exit_of_ring_to_the_left") == false:
		return true
	if CurrentGame.globalCoords(global_position).x > 3.006e+07 and ConfigDriverVP.__get_value("VelocityPlus","VP_RING","allow_exit_of_ring_to_the_right") == false:
		return true
	if linear_velocity.length() > 2000 and ConfigDriverVP.__get_value("VelocityPlus","VP_RING","remove_max_speed_limit") == false:
		return true
	
	
	return false

func aiControl(delta):
	if shipName == "SHIP_POD":
		aiControlCompanion(delta)
	else:
		.aiControl(delta)


var companion_finish = false
func aiControlCompanion(delta):
	if talkStandDown > 0:
		talkStandDown -= delta
	aiCombatCounter -= delta
	if powerBalance <= 0 and not alwaysAI:
		return
	if cutscene:
		return

	if aiAware:
		if proxyAI:
			aiAware.setDerelictMode(false)
		else:
			aiAware.setDerelictMode(isHelpless())


	autopilot = true
	aiExamineCnt += delta
	var collisionsIgnore = cargo + temporaryCargo
	var excavator = hasSystem("SYSTEM_EXCAVATOR")
	var dock = hasSystem("SYSTEM_DOCKING_CLAMPS")
	var grinder = hasSystem("SYSTEM_GRINDER")
	var dronesHauls = hasSystem("SYSTEM_DND_HAUL")

	if grinder:
		excavator = grinder


	if aiExamineCnt > aiExamineEvery:
		aiDesire *= (1 - aiDesireErosion)
		if aiPlayDead > 0:
			aiDesire = aiPlayDead
			aiTarget = null
			aiAction = AI.playDead

		var canExcavate = excavator != null
		var canGrind = grinder != null
		var canDock = dock != null

		if aiMinimumReactiveMass > 0:
			var piad = clamp((2 * aiMinimumReactiveMass - reactiveMass) / aiMinimumReactiveMass, 0, 1) * aiPlaySafeMargin
			

			if piad > aiDesire:
				aiDesire = piad
				aiTarget = null
				companion_finish = true
				var cf = ConfigDriverVP.__get_value("VelocityPlus","VP_SHIPS","scoop_automatic_return_protocol_override")
				match cf:
					"VP_RETURN_TO_CRADLE":
						aiAction = AI.dock
					"VP_HOLD_POSITION":
						aiAction = AI.stop
					"VP_BIRDFEED":
						aiAction = AI.birdFeed
					"VP_RETURN_TO_ENCELADUS":
						aiAction = AI.exit
			else:
				companion_finish = false
		aiExamineCnt = 0
		if aiDesire < aiDesireOffset:
			aiTarget = null
			aiAction = AI.ignore
			aiDesire = aiDesireOffset

		aiThoughts = {}
		aiCollisions = {}
		aiCollisionPoints = {}

		var greedAdjust = clamp((CurrentGame.globalCoords(global_position).x - aiGreedDepthLimit) / aiGreedDepthLimit, aiGreedMin, 1) if aiGreedDepthLimit > 0 else 1.0
		var aiE = getObjectInSurroundingArea()
		var priorityTarget = null
		if Tool.claim(aiHomeCradle):
			if "guidingDrone" in aiHomeCradle and aiHomeCradle.guidingDrone:
				aiE += aiHomeCradle.ship.droneQueue
				for pri in aiHomeCradle.ship.droneQueue:
					if aiHomeCradle.ship.isValidSystemTarget(self, pri):
						aiE = [pri]
						priorityTarget = pri
						break
			Tool.release(aiHomeCradle)

		var known = Tool.multiClaimWhatYouCanAndReturnIt(aiE)
		for pt in known:
			if Tool.claim(aiHomeCradle):
				if "sanbusTargetting" in aiHomeCradle and aiHomeCradle.sanbusTargetting:
					if not aiHomeCradle.ship.isValidSystemTarget(self, aiTarget):
						Tool.release(aiHomeCradle)
						continue
				Tool.release(aiHomeCradle)
			if pt != self and pt is RigidBody2D and not ("fracturing" in pt and pt.fracturing) and not ("docked" in pt and pt.docked):
				var disp = aiGetDispositionTowards(pt)
				if disp:
					var distance = clamp(global_position.distance_to(pt.global_position) / aiNominalDistance, 0.02, 1)

					var hate = 0
					var fear = 0
					var curiosity = 0
					var greed = 0
					var support = 0

					if disp.hostility > 0:
						hate += getCombatCapacity() * disp.hostility
					if disp.fear > 0:
						if pt.has_method("getCombatCapacity"):
							fear += disp.fear * pt.getCombatCapacity()
					if disp.curiosity > 0:
						if not aiKnow.has(pt):
							if alwaysAI:
								if pt.has_method("isPlayerControlled") and pt.isPlayerControlled():
									curiosity += disp.curiosity
							else:
								curiosity += disp.curiosity
					if disp.greed > 0:
						if pt.has_method("isPlayerControlled"):
							greed += disp.greed
						else:
							if pt.mass > aiExcavationMassLimit:
								greed += greedAdjust * disp.greed * clamp((pt.linear_velocity.length() * aiExcavationLinearValue + abs(pt.angular_velocity * aiExcavationRotationValue) - aiExcavationValueOffset) * (aiExcavationValue / pt.mass), 0, 1)
								
							else:
								if Tool.claim(aiHomeCradle):
									if "mineralTargetting" in aiHomeCradle and aiHomeCradle.mineralTargetting:
										if aiHomeCradle.ship.isValidMineralTarget(pt, aiHomeCradle.mineralConfig):
											greed += greedAdjust * disp.greed * CurrentGame.getMarketPrice(pt) / aiPriceGreedFactor
									if "guidingDrone" in aiHomeCradle and aiHomeCradle.guidingDrone:
										if pt == priorityTarget:
											greed += 10

									Tool.release(aiHomeCradle)
								else:
									greed += greedAdjust * disp.greed * CurrentGame.getMarketPrice(pt) / aiPriceGreedFactor


					if disp.support > 0 and not aiIsTaken(pt):
						support += disp.support

					if pt == aiTarget:
						fear *= aiCommitment
						hate *= aiCommitment
						curiosity *= aiCommitment
						greed *= aiCommitment
						support *= aiCommitment

					fear /= clamp(pow(distance, 2), 0.5, 2)
					hate /= clamp(distance, 0.5, 2)
					curiosity /= clamp(pow(distance, 0.5), 0.5, 2)
					greed /= clamp(distance, 0.5, 2)
					if "trajectoryTarget" in pt and pt.trajectoryTarget:
						support *= 2
					else:
						support *= clamp(pow(abs(0.5 - distance) * 2, 3), 0.5, 2)
					if Debug.debug:
						aiThoughts[pt] = {"disp": disp, "spec": {"fear": fear, "hostility": hate, "curiosity": curiosity, "greed": greed, "support": support}}

					if curiosity > aiDesire:
						
						aiDesire = curiosity
						aiAction = AI.examine
						aiTarget = pt

					if support > aiDesire:
						
						aiDesire = support
						aiTarget = pt
						if canDock and "powerBalance" in pt and pt.powerBalance <= 0:
							aiAction = AI.dock
						else:
							aiAction = AI.support

					if greed > aiDesire and (canExcavate or canGrind):

						var limit = 0
						if canExcavate:
							limit = aiExcavationMassLimit
						if canGrind:
							limit = aiGrindMassLimit

						if pt.mass > limit:
							if canFire():
								aiAction = AI.excavate
								aiDesire = greed
								aiTarget = pt
						else:
							aiAction = AI.catch
							aiDesire = greed
							aiTarget = pt


					if hate > aiDesire:
						
						aiDesire = hate
						if hasWeapon():
							if hate > aiHostilityToFire:
								aiAction = AI.fight
							else:
								aiAction = AI.watch
						else:
							aiAction = AI.flee
							
						aiTarget = pt

					if fear > aiDesire:
						
						aiDesire = fear
						if fear > aiHostilityToFire:
							aiAction = AI.run
						else:
							aiAction = AI.flee
						aiTarget = pt
		Tool.multiReleaseGlobal()

	if aiDockTime > aiDockingSecureTime:
		collisionsIgnore.append(aiTarget)
		aiTarget = null
		if abs(angular_velocity) > 0.5:
			aiAction = AI.stop
		else:
			aiAction = AI.exit

	if aiDesire < aiImperativeStrenght:
		aiTarget = aiImperativeTarget
		if not aiTarget:
			aiTargetVelocity = aiImperativeDirection
		aiAction = aiImperative

	var wrat = null
	if Tool.claim(aiTarget):
		wrat = aiTarget
		if Tool.claim(aiHomeCradle):
			if aiHomeCradle and "sanbusTargetting" in aiHomeCradle and aiHomeCradle.sanbusTargetting:
				if aiAction == AI.catch:
					aiHomeCradle.ship.addSystemTarget(self, aiTarget)
				else:
					aiHomeCradle.ship.clearSystemTarget(self)
			Tool.release(aiHomeCradle)
	else:
		if Tool.claim(aiHomeCradle):
			if aiHomeCradle and "sanbusTargetting" in aiHomeCradle and aiHomeCradle.sanbusTargetting:
				aiHomeCradle.ship.clearSystemTarget(self)
			Tool.release(aiHomeCradle)

		

	autopilotDesiredAngularVelocity = null
	if desiredAngularVelocity:
		autopilotDesiredAngularVelocity = desiredAngularVelocity
	var aiFacingTarget = Vector2(0, - 1)

	if aiAction == AI.playDead or aiAction == AI.playDeadButTalk:
		setReactorState(false)
	else:
		setReactorState(reactiveMass > 0)

	var focusOnWrat = aiTurnsTowardsTargets
	
	var autopilotDesiredRotationOverride = false
	if ai:
		match aiAction:
			AI.catch:
				aiEnableDroneSystems(true)
			AI.excavate:
				aiEnableDroneSystems(true)
			_:
				aiEnableDroneSystems(false)
				
	var aiDebugAction = "%s doing [%s] on [%s]" % [transponder, aiAction, wrat]
	if aiDebugAction != lastAiDebugThought:
		Debug.l(aiDebugAction)
		lastAiDebugThought = aiDebugAction
	var losAdjsutment = aiLosDesireAdjust[aiAction]
	var ignoreExcavatorOverride = false
	match aiAction:
		AI.birdFeed:
			if wrat:
				var bss = aiBirdFeedSpot.rotated(wrat.global_rotation)
				var targetSpot = wrat.global_position + bss
				var dist = targetSpot - global_position
				var wdist = wrat.global_position - global_position
				focusOnWrat = false
				aiTargetVelocity = dist.normalized() * clamp(dist.length() * aiBirdFeedDistanceFactor, 0, aiSupportMaxVelocity) + wrat.linear_velocity
				var tacc = - wdist.normalized().dot(bss.normalized())
				if tacc > aiBirdFeedAccurancy:
					focusOnWrat = true
					var acc = Vector2(0, - 1).rotated(global_rotation).dot(wdist.normalized())
					if acc > aiBirdFeedAccurancy:
						ignoreExcavatorOverride = true
						fireMatching("x", - 1.0)
		AI.playDead:
			aiTargetVelocity = Vector2(0, 0)
			focusOnWrat = false
		AI.playDeadButTalk:
			aiTargetVelocity = Vector2(0, 0)
			focusOnWrat = false
			if wrat:
				var dist = (wrat.global_position - global_position)
				if dist.length() <= aiCuriosityDisance and not aiKnow.has(aiTarget) and (powerBalance > capacitorToTalk):
					if Tool.claim(aiTarget):
						aiStartDialog(aiTarget)
						Tool.release(aiTarget)
		AI.stop:
			aiTargetVelocity = Vector2(0, 0)
			autopilotDesiredRotation = global_rotation
		AI.watch:
			if wrat:
				aiPlayDead = 0.0
				autopilotComfort = false
				var dist = (wrat.global_position - global_position)
				var speed = clamp(dist.length() - aiHunterEngagementDistance, - aiHunterMaxVelocity, aiHunterMaxVelocity)
				aiTargetVelocity = dist.normalized() * speed + wrat.linear_velocity
				if dist.length() < aiHunterTalkDistance and (powerBalance > capacitorToTalk):
					if not aiKnow.has(aiTarget):
						aiStartDialog(aiTarget)
		AI.fight:
			aiCombatCounter = aiCombatTime
			aiMargin = aiCombatMargin
			if wrat:
				aiPlayDead = 0.0
				autopilotComfort = false
				var dist = (wrat.global_position - global_position)
				var speed = clamp(dist.length() - aiHunterEngagementDistance, - aiHunterMaxVelocity, aiHunterMaxVelocity)
				aiTargetVelocity = dist.normalized() * speed + wrat.linear_velocity
				if powerBalance > 0:
					if hasMusicChange:
						if isBoss or getConfig("turbine.power", 0) >= 1000:
							CurrentGame.emit_signal("moodChange", "boss", delta)
						else:
							CurrentGame.emit_signal("moodChange", "battle", delta)
				if dist.length() < aiHunterTalkDistance and (powerBalance > capacitorToTalk):
					if not aiKnow.has(aiTarget):
						aiStartDialog(aiTarget)
				if dist.length() < aiHunterFireDistance:
					var facing = Vector2(0, - 1).rotated(global_rotation)
					var aim = facing.dot(dist.normalized())
					
					if aim > aiHunterAccurancy and canFire() and aiHaveClearShotTo(wrat):
						fireMatching("w", 1.0)
			else:
				aiDesire = 0
		AI.flee:
			aiCombatCounter = aiCombatTime
			aiMargin = aiCombatMargin
			if wrat:
				if hasMusicChange:
					if powerBalance > 0:
						CurrentGame.emit_signal("moodChange", "battle", delta)
				focusOnWrat = false
				aiPlayDead = 0.0
				autopilotComfort = false
				var dist = (wrat.global_position - global_position)
				aiTargetVelocity = - dist.normalized() * aiFleeMaxVelocity
				if dist.length() < aiHunterTalkDistance and (powerBalance > capacitorToTalk):
					if not aiKnow.has(wrat):
						aiStartDialog(wrat)

		AI.run:
			aiCombatCounter = aiCombatTime
			aiMargin = aiCombatMargin
			if wrat:
				aiPlayDead = 0.0
				autopilotComfort = false
				var dist = (wrat.global_position - global_position)
				aiTargetVelocity = - dist.normalized() * aiFleeMaxVelocity
				if hasMusicChange:
					if powerBalance > 0:
						CurrentGame.emit_signal("moodChange", "battle", delta)
				if dist.length() < aiHunterTalkDistance and (powerBalance > capacitorToTalk):
					if not aiKnow.has(wrat):
						aiStartDialog(wrat)

				if dist.length() < aiFleeFireDistance:
					var facing = Vector2(0, - 1).rotated(global_rotation)
					var aim = facing.dot(dist.normalized())
					if aim > aiFleeAccurancy and canFire() and aiHaveClearShotTo(wrat):
						fireMatching("w", 1.0)

		AI.support:
			if wrat:
				var dist = (wrat.global_position - global_position)
				var tdist = dist
				
				var r = (aiOrbitPreference * 2 - 1) * aiOrbitOffset
				
				var orbit = Vector2(0, - aiCuriosityDisance).rotated(r + wrat.global_rotation)
				tdist = dist + orbit
				if dist.length() < aiFriendlyCommsDistance:
					if not aiKnow.has(wrat):
						aiStartDialog(wrat)

				match aiSupportBehaviour:
					"stay":
						aiTargetVelocity = Vector2(0, 0)
					_:
						var speed = clamp(tdist.length() * aiSupportVelocityScale, - aiSupportMaxVelocity, aiSupportMaxVelocity)
						aiTargetVelocity = tdist.normalized() * speed + wrat.linear_velocity
						focusOnWrat = false

		AI.examine:
			if wrat:
				if not aiTurnsToTalk:
					focusOnWrat = false
				var dist = (wrat.global_position - global_position)
				var tdist = dist
				var speed = clamp(tdist.length() - aiCuriosityDisance, - aiCuriosityMaxVelocity, aiCuriosityMaxVelocity)
				if dist.length() > aiCuriosityDisance:
					var r = (aiOrbitPreference * 2 - 1) * aiOrbitOffset
					var orbit = Vector2(0, - aiCuriosityDisance).rotated(r + global_rotation)
					tdist = dist + orbit
					speed = clamp(tdist.length(), - aiCuriosityMaxVelocity, aiCuriosityMaxVelocity)
				
				aiTargetVelocity = tdist.normalized() * speed + wrat.linear_velocity
				aiTargetVelocity = aiTargetVelocity.normalized() * min(aiTargetVelocity.length(), aiCuriosityMaxVelocity)
				if speed <= 0 and not aiKnow.has(aiTarget) and (powerBalance > capacitorToTalk) and aiCuriousHail:
					if Tool.claim(aiTarget):
						aiStartDialog(aiTarget)
						Tool.release(aiTarget)
						

			else:
				aiDesire = 0

		AI.catch:
			if wrat:
				collisionsIgnore.append(aiTarget)
				if dronesHauls and dronesHauls.ref.enabled and aiTarget != autopilotVelocityOffsetTarget and isValidMineralTarget(aiTarget, dronesHauls.ref.system.mineralConfig):
					var dist = (wrat.global_position - global_position)
					var speed = clamp(dist.length() / aiLookaheadSeconds, aiExcavationVelocity, aiMaxExcavationVelocity)
					var vdiff = (wrat.linear_velocity - linear_velocity).normalized()
					var dnorm = dist.normalized()
					var f = dnorm.dot(vdiff) if vdiff != Vector2.ZERO else 1.0
					var fac = clamp(abs(f), 0, 1)
					
					aiTargetVelocity = dist.normalized() * speed * fac + wrat.linear_velocity
					if excavator and Tool.claim(excavator.ref):
						Tool.release(excavator.ref)
						
						if fac > aiHaulDroneAccurancy:
							fireMatching("x", 1.0)
						aiMargin = 0
				else:
					if addSystemTarget(self, aiTarget):
						if aiExcavationTime > aiExcavationTimeLimit and excavator and Tool.claim(excavator.ref):
							var dist = (wrat.global_position - excavator.ref.global_position)
							var speed = clamp(dist.length() - aiCatchDistance, - aiExcavationVelocity, aiExcavationVelocity)
							
							aiTargetVelocity = dist.normalized() * speed + wrat.linear_velocity
							if dist.length() > aiCatchDistance:
								aiExcavationTime = 0
							Tool.release(excavator.ref)

						if aiExcavationTime < aiExcavationTimeLimit:
							var dist = (wrat.global_position - global_position)
							var speed = clamp(dist.length() / aiLookaheadSeconds, aiExcavationVelocity, aiMaxExcavationVelocity)
							var vdiff = (wrat.linear_velocity - linear_velocity).normalized()
							var dnorm = dist.normalized()
							var f = dnorm.dot(vdiff) if vdiff != Vector2.ZERO else 1.0
							var fac = clamp(abs(f), 0, 1)
							
							aiTargetVelocity = dist.normalized() * speed * fac + wrat.linear_velocity
							if excavator and Tool.claim(excavator.ref):
								var xdist = (wrat.global_position - excavator.ref.global_position).length()
								Tool.release(excavator.ref)
								
								if xdist < aiCatchDistance and fac > aiCatchAccurancy and vdiff.length() < aiCatchSameVelocity:
									aiExcavationTime += delta
									fireMatching("x", 1.0)
									aiMargin = 0
		AI.excavate:
			if wrat:
				collisionsIgnore.append(aiTarget)
				var dist = (wrat.global_position - global_position)
				var speed = clamp(dist.length() - aiExcavationDistance, - aiExcavationVelocity, aiExcavationVelocity)
				aiTargetVelocity = dist.normalized() * speed + wrat.linear_velocity
				if dist.length() < aiExcavationFireDistance * 2:
					var facing = Vector2(0, - 1).rotated(global_rotation)
					var aim = facing.dot(dist.normalized())
					
					if aim > aiExcavationAim and canFire() and aiHaveClearShotTo(wrat):
						fireMatching("w", 1.0)
			else:
				aiDesire = 0
		AI.exit:
			aiTargetVelocity = Vector2( - autopilotMaxVelocity, 0)
			focusOnWrat = false

		AI.go:
			if wrat:
				collisionsIgnore.append(aiTarget)
				var dist = wrat.global_position - global_position
				var speed = clamp((dist.length() - aiDockingDisance) * aiDockingDistanceFactor, 0, aiDockingVelocity)
				aiTargetVelocity = wrat.linear_velocity + dist.normalized() * speed
				if dist.length() <= aiPerfectDockingDisance:
					autopilotDesiredRotation = wrat.global_rotation
					focusOnWrat = false
					autopilotDesiredRotationOverride = true
		AI.dock:
			if wrat:
				aiFacingTarget = aiDockFacing
				var dist = (wrat.global_position - global_position)
				var vd = wrat.linear_velocity - linear_velocity
				
				if vd.length() < aiDockingStuckDetectionVelocityMaxDiff:
					aiDockingStuckTime += delta
				else:
					aiDockingStuckTime = 0
				
				collisionsIgnore.append(aiTarget)
				if "temporaryCargo" in aiTarget:
					collisionsIgnore.append_array(aiTarget.temporaryCargo)
				if "cargo" in aiTarget:
					collisionsIgnore.append_array(aiTarget.cargo)
				if "physicsExclude" in aiTarget:
					collisionsIgnore.append_array(aiTarget.physicsExclude)
				if dist.length() > aiDockingDisance and aiDockingStuckTime < aiDockingStuckDetectionTime:
					var facing = pow(dist.normalized().dot(aiFacingTarget.rotated(global_rotation)), 3) / max(abs(angular_velocity * 90), 1)
					if not aiDockRequireFacing:
						facing = 1
					
					if aiDockAlignToTarget:
						focusOnWrat = false
						autopilotDesiredRotation = wrat.global_rotation
						autopilotDesiredRotationOverride = true
						facing = 1
					var speed = clamp(dist.length() * aiDockingDistanceFactor * facing, 0, aiDockingVelocity)
					aiTargetVelocity = dist.normalized() * speed + wrat.linear_velocity
					aiDockTime = 0
					
					if dock != null:
						fireMatching("x", 1.0)
					
				else:
					if dock != null:
						var speed = clamp(dist.length() * aiDockingDistanceFactor, - aiDockingVelocity, aiDockingVelocity)
						aiTargetVelocity = dist.normalized() * speed + wrat.linear_velocity
						focusOnWrat = false
						var v1 = Vector2(0, 1).rotated(global_rotation)
						var vt1 = Vector2(0, 1).rotated(wrat.global_rotation)
						var vt2 = Vector2(0, - 1).rotated(wrat.global_rotation)

						var ad = min(abs(v1.angle_to(vt1)), abs(v1.angle_to(vt2)))

						if (ad > aiDockingRotationOffset or abs(angular_velocity - wrat.angular_velocity) > aiDockingAngularOffset * 2) and aiDockingStuckTime < aiDockingStuckDetectionTime:
							
							aiDockTime = 0
							fireMatching("x", 1.0)
							
							var off = clamp(aiDockingRotationOffset * ad, 0, aiDockingRotationOffset)
							if dist.length() <= aiPerfectDockingDisance:
								if wrat.angular_velocity != 0:
									autopilotDesiredAngularVelocity = wrat.angular_velocity - sign(wrat.angular_velocity) * off
								else:
									autopilotDesiredAngularVelocity = off
							else:
									autopilotDesiredAngularVelocity = 0
							autopilotDesiredAngularVelocity = wrat.angular_velocity
							
						else:
							
							
							aiDockTime += delta
							aiTargetVelocity = dist.normalized() * speed + wrat.linear_velocity
							var off = clamp(aiDockingRotationOffset * ad, 0, aiDockingRotationOffset)
							if wrat.angular_velocity != 0:
								autopilotDesiredAngularVelocity = wrat.angular_velocity - sign(wrat.angular_velocity) * off
							else:
								autopilotDesiredAngularVelocity = off
					else:
						aiTargetVelocity = Vector2(0, 0)
						


				
		_:
			aiTargetVelocity = aiTargetCourse

	if companion_finish:
		if farewellDialogTree and not aiFarewells and aiImperative != aiAction:
			dialogTree = farewellDialogTree
			aiFarewells = true
			if Tool.claim(aiImperativeTarget):
				aiStartDialog(aiImperativeTarget, true)
				Tool.release(aiImperativeTarget)


	if aiTargetVelocity != null and powerBalance > 0:
		if randf() <= aiChance:
			aiLosChecks.clear()
			var ignoreEnergy = getIgnoreCollisionEnergy()
			aiObstacles = []
			var collisionTest = aiTestCollision(aiTargetVector, aiMargin, collisionsIgnore, aiLookaheadSeconds, ignoreEnergy, true, aiExpose, false, true)
			var willCrashWith = collisionTest[0]
			if willCrashWith:
				
				var time = collisionTest[2].min()
				if time == null:
					time = aiLookaheadSeconds
				
				if Debug.debug or aiExpose:
					aiObstacles += willCrashWith
				aiTargetDesirebility = aiVectorDesirability(aiTargetVelocity, aiTargetVector) - aiCollisionAvoidance * aiLookaheadSeconds / time
			else:
				aiTargetDesirebility = aiVectorDesirability(aiTargetVelocity, aiTargetVector)
			
			
			if losAdjsutment != 0 and wrat:
				if aiHaveClearShotTo(wrat, [], false, null, global_position + aiTargetVector * aiAimingLookaheadSeconds * aiAimingLookaheadStage):
					aiAimingLookaheadStage = clamp(aiAimingLookaheadSeconds - sign(losAdjsutment) * delta / aiAimingLookaheadWindup, 0, 1)
					aiTargetDesirebility += losAdjsutment
				else:
					aiAimingLookaheadStage = clamp(aiAimingLookaheadSeconds + sign(losAdjsutment) * delta / aiAimingLookaheadWindup, 0, 1)
			else:
				aiAimingLookaheadStage = clamp(aiAimingLookaheadSeconds - sign(losAdjsutment) * delta / aiAimingLookaheadWindup, 0, 1)
			var newTargetVector = aiTargetVector
			var newTargetDesirebility = aiTargetDesirebility

			
			var gotAny = false

			aiCastCounter += delta
			var castTime = 1.0 / (aiCastsPerSecond)

			
			var seekRadius = aiSeekRadius
			var castMax = aiCastMax

			while aiCastCounter > 0 and castMax > 0:
				castMax -= 1
				aiCastCounter -= castTime
				
				var testTarget = (Vector2(randf() - 0.5, randf() - 0.5).normalized()) * randf() * seekRadius + lerp(aiTargetVector, linear_velocity, clamp( - aiTargetDesirebility, 0, 1))
				testTarget = testTarget.normalized() * clamp(testTarget.length(), 0, autopilotMaxVelocity)
				var testCollision = aiTestCollision(testTarget, aiMargin, collisionsIgnore, aiLookaheadSeconds, ignoreEnergy, true, aiExpose, false, true)
				var testDesire = - 1000.0
				if testCollision[0]:
					if Debug.debug or aiExpose:
						
						aiObstacles += testCollision[0]
					var time = testCollision[2].min()
					if time == null:
						time = aiLookaheadSeconds
					
					testDesire = aiVectorDesirability(aiTargetVelocity, testTarget) - aiCollisionAvoidance * aiLookaheadSeconds / time
				else:
					testDesire = aiVectorDesirability(aiTargetVelocity, testTarget)
				if losAdjsutment != 0 and wrat:
					if aiHaveClearShotTo(wrat, [], false, null, global_position + testTarget * aiAimingLookaheadSeconds * aiAimingLookaheadStage):
						testDesire += losAdjsutment
				if testDesire >= 0.0:
					gotAny = true
				if Debug.debug or aiExpose:
					aiPaths.append(Vector3(testTarget.x, testTarget.y, testDesire))
				if testDesire >= newTargetDesirebility:
					
					newTargetVector = testTarget
					newTargetDesirebility = testDesire

				if Debug.debug or aiExpose:
					if aiPaths.size() > maxAiPaths:
						aiPaths.pop_front()

			if newTargetDesirebility > aiTargetDesirebility:
				
				
				aiTargetVector = newTargetVector
				aiTargetDesirebility = newTargetDesirebility

			if gotAny:
				aiMargin = clamp(aiMargin + delta * aiMarginStepPerSecond, aiMinMargin, aiMaxMargin)
			else:
				aiMargin = clamp(aiMargin - delta * aiMarginStepPerSecond, aiMinMargin, aiMaxMargin)
				
				

			if not autopilotDesiredRotationOverride:
				var excavatorOverride = false
				if not ignoreExcavatorOverride and aiKeepRotationWhileExcavating and excavator and Tool.claim(excavator.ref):
					var open = excavator.ref.open
					if open > aiExcavatorOpenKeepCourse:
						autopilotDesiredRotation = rotation
						autopilotDesiredVelocity = linear_velocity
						excavatorOverride = true
					Tool.release(excavator.ref)
				if not excavatorOverride:
					var aitv = aiTarget.global_position - global_position if wrat else Vector2(0, 0)
					var velocityDiff = linear_velocity - aiTargetVector
					var vd = velocityDiff.length()
					if wrat and focusOnWrat and aiDesire > aiMinDesireToRotate and (aitv.length() < aiCuriosityDisance or vd < aiSmallVelocityDifference):
						autopilotDesiredRotation = aiFacingTarget.angle_to(aitv)
					else:
						if (aiTargetVector.length() > aiMinimalRotationVelocityFactor):
							autopilotDesiredRotation = aiFacingTarget.angle_to(aiTargetVector)
							if linear_velocity.length() > getFlipAboveVelocity():
								autopilotDesiredRotation += PI

							var burnfinder = clamp((vd - aiSmallVelocityDifference) / aiBurnfinderStartVelocity, 0.0, 1.0)
							autopilotDesiredRotation = lerp_angle(autopilotDesiredRotation, aiFacingTarget.angle_to( - velocityDiff), burnfinder)

			autopilotDesiredVelocity = aiTargetVector
			
			if Tool.claim(autopilotVelocityOffsetTarget):
				autopilotDesiredVelocity -= autopilotVelocityOffsetTarget.linear_velocity
				Tool.release(autopilotVelocityOffsetTarget)
			
	else:
		autopilotDesiredVelocity = Vector2(0, 0)
	if wrat:
		Tool.release(aiTarget)
	if autopilotDesiredVelocity.length() > aiMaxVelocity:
		autopilotDesiredVelocity = autopilotDesiredVelocity.normalized() * aiMaxVelocity
	
