extends "res://enceladus/CurrentCrewManagement.gd"

var pointersVP_crew_sort:HevLibPointers

var vp_crewwsort_sort_mode:int = 4
var vp_crewwsort_prio_active:bool = true

var vp_omsdisplayexpansionlogcheck_uinit : bool = false
func _ready():
	if vp_omsdisplayexpansionlogcheck_uinit:
		OS.kill(OS.get_process_id())
	vp_omsdisplayexpansionlogcheck_uinit = true
	pointersVP_crew_sort = ModLoader._savedObjects[0]
	pointersVP_crew_sort.ConfigDriver.__subscribe_to_setting_change("vp_crewsort_UV",self,"VelocityPlus","VP_CREW","crew_sort_method")
	pointersVP_crew_sort.ConfigDriver.__subscribe_to_setting_change("vp_crewsortactive_UV",self,"VelocityPlus","VP_CREW","crew_sort_active_first")
	vp_crewwsort_sort_mode = pointersVP_crew_sort.ConfigDriver.__get_value("VelocityPlus","VP_CREW","crew_sort_method",4)
	vp_crewwsort_prio_active = pointersVP_crew_sort.ConfigDriver.__get_value("VelocityPlus","VP_CREW","crew_sort_active_first",true)

func vp_crewsort_UV(how:int):
	vp_crewwsort_sort_mode = how
	
func vp_crewsortactive_UV(how:bool):
	vp_crewwsort_prio_active = how

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
			return ap < bp
		if ao != bo:
			return ao < bo
		if ae != be:
			return ae > be
	elif vp_crewwsort_sort_mode == 2:
		if ap != bp:
			return ap < bp
		if ae != be:
			return ae > be
		if ao != bo:
			return ao < bo
	if vp_crewwsort_sort_mode == 3:
		if ae != be:
			return ae > be
		if ap != bp:
			return ap < bp
		if ao != bo:
			return ao < bo
	elif vp_crewwsort_sort_mode == 4:
		if ae != be:
			return ae > be
		if ao != bo:
			return ao < bo
		if ap != bp:
			return ap < bp
	if vp_crewwsort_sort_mode == 5:
		if ao != bo:
			return ao < bo
		if ae != be:
			return ae > be
		if ap != bp:
			return ap < bp
	elif vp_crewwsort_sort_mode == 6:
		if ao != bo:
			return ao < bo
		if ap != bp:
			return ap < bp
		if ae != be:
			return ae > be
	return a.fullName < b.fullName
