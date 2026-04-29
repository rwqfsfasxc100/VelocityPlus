extends "res://CurrentGame.gd"

var pointersVP_natural_time_skip

var file = File.new()
func _ready():
	yield(get_tree(),"idle_frame")
	pointersVP_natural_time_skip = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_natural_time_skip.ConfigDriver.__establish_connection("vp_natural_time_skip_UV",self)
	vp_natural_time_skip_UV()

func vp_natural_time_skip_UV():
	if pointersVP_natural_time_skip:
		natural_time_skip = pointersVP_natural_time_skip.ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","natural_time_skip")

var natural_time_skip = true


func loadFromFile():
	var age = OS.get_unix_time() - file.get_modified_time(saveFile)
	.loadFromFile()
	if natural_time_skip:
		yieldTimeSkip(age)
	
func yieldTimeSkip(age):
	yield(Tool.makeTimer(3, self), "timeout")
	Debug.l("Natural Time Skip: save is %s old, advancing by %s seconds" % [timeToString(age),age])
	advanceTimeBySeconds(age)
	for c in getCrew():
		while shouldPayWages(c) and canAffordSalary(c):
			paySalary(c)
